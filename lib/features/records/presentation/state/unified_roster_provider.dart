import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../core/database/app_database.dart';
import '../../../../core/security/encryption_service.dart';
import '../../../../core/services/reporting/pdf_dossier_service.dart';
import '../../../../core/services/reporting/monthly_audit_vault_metadata.dart';

/// State representation for the Records & Institutional Intelligence module
class RecordsDashboardState {
  final List<UnifiedInstitutionalRecord> records;
  final List<Society> societies;
  final Map<String, Society> societiesMap;
  final List<FinancialRecord> financialRecords;
  final List<Event> monthlyEvents;
  final List<EventWithSociety> monthlyEventsWithSocieties;
  final List<Achievement> achievements;
  final bool isLoading;
  final bool isGeneratingDossier;
  final String? errorMessage;
  final String searchQuery;
  final String selectedPillar;
  final ConfidentialVaultData? lastArchivedVaultDoc;
  final bool isVaultArchiving;
  final String? vaultArchiveMessage;

  const RecordsDashboardState({
    this.records = const [],
    this.societies = const [],
    this.societiesMap = const {},
    this.financialRecords = const [],
    this.monthlyEvents = const [],
    this.monthlyEventsWithSocieties = const [],
    this.achievements = const [],
    this.isLoading = true,
    this.isGeneratingDossier = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedPillar = 'All',
    this.lastArchivedVaultDoc,
    this.isVaultArchiving = false,
    this.vaultArchiveMessage,
  });

  RecordsDashboardState copyWith({
    List<UnifiedInstitutionalRecord>? records,
    List<Society>? societies,
    Map<String, Society>? societiesMap,
    List<FinancialRecord>? financialRecords,
    List<Event>? monthlyEvents,
    List<EventWithSociety>? monthlyEventsWithSocieties,
    List<Achievement>? achievements,
    bool? isLoading,
    bool? isGeneratingDossier,
    String? errorMessage,
    String? searchQuery,
    String? selectedPillar,
    ConfidentialVaultData? lastArchivedVaultDoc,
    bool? isVaultArchiving,
    String? vaultArchiveMessage,
  }) {
    return RecordsDashboardState(
      records: records ?? this.records,
      societies: societies ?? this.societies,
      societiesMap: societiesMap ?? this.societiesMap,
      financialRecords: financialRecords ?? this.financialRecords,
      monthlyEvents: monthlyEvents ?? this.monthlyEvents,
      monthlyEventsWithSocieties: monthlyEventsWithSocieties ?? this.monthlyEventsWithSocieties,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      isGeneratingDossier: isGeneratingDossier ?? this.isGeneratingDossier,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPillar: selectedPillar ?? this.selectedPillar,
      lastArchivedVaultDoc: lastArchivedVaultDoc ?? this.lastArchivedVaultDoc,
      isVaultArchiving: isVaultArchiving ?? this.isVaultArchiving,
      vaultArchiveMessage: vaultArchiveMessage ?? this.vaultArchiveMessage,
    );
  }

  /// Returns filtered institutional roster records according to search query and selected pillar
  List<UnifiedInstitutionalRecord> get filteredRecords {
    return records.where((r) {
      final soc = societiesMap[r.societyId];
      final matchesPillar = selectedPillar == 'All' ||
          (soc != null && soc.pillar.toLowerCase() == selectedPillar.toLowerCase());
      if (!matchesPillar) return false;

      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      return r.fullName.toLowerCase().contains(q) ||
          r.identifier.toLowerCase().contains(q) ||
          r.cnic.toLowerCase().contains(q) ||
          r.department.toLowerCase().contains(q) ||
          r.role.toLowerCase().contains(q) ||
          (soc?.name.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  int get studentCount => records.where((r) => !r.isExecutive).length;
  int get cabinetCount => records.where((r) => r.isExecutive).length;
}

/// Riverpod StateNotifier managing institutional records, financial vouchers, monthly events, and dossier compilation
class RecordsDashboardNotifier extends StateNotifier<RecordsDashboardState> {
  final AppDatabase database;

  RecordsDashboardNotifier(this.database) : super(const RecordsDashboardState()) {
    loadAllRecords();
  }

  /// Concurrently loads unified roster, societies, financial vouchers, current month events, and achievements
  Future<void> loadAllRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final now = DateTime.now();

      final results = await Future.wait([
        database.getUnifiedInstitutionalRoster(),
        database.select(database.societies).get(),
        database.select(database.financialRecords).get(),
        database.getMonthlyEventsWithSocieties(targetMonth: now, includeOnlyConcluded: false),
        database.select(database.achievements).get(),
      ]);

      final unified = results[0] as List<UnifiedInstitutionalRecord>;
      final socs = results[1] as List<Society>;
      final fins = results[2] as List<FinancialRecord>;
      final eventsWithSocieties = results[3] as List<EventWithSociety>;
      final achs = results[4] as List<Achievement>;

      final Map<String, Society> sMap = {for (var s in socs) s.id: s};

      state = state.copyWith(
        records: unified,
        societies: socs,
        societiesMap: sMap,
        financialRecords: fins,
        monthlyEvents: eventsWithSocieties.map((e) => e.event).toList(),
        monthlyEventsWithSocieties: eventsWithSocieties,
        achievements: achs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Backward-compatible alias for existing tests
  Future<void> loadRoster() => loadAllRecords();

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  void setPillarFilter(String pillar) {
    state = state.copyWith(selectedPillar: pillar);
  }

  /// Deletes a student roster record or cabinet officer and refreshes the unified roster
  Future<void> deleteRecord(UnifiedInstitutionalRecord record) async {
    try {
      if (record.isExecutive) {
        await (database.delete(database.cabinetMembers)..where((t) => t.id.equals(record.id))).go();
      } else {
        await (database.delete(database.societyMembers)..where((t) => t.id.equals(record.id))).go();
      }
      await loadAllRecords();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete record: $e');
    }
  }

  /// Deletes a financial ledger voucher and refreshes the financial records
  Future<void> deleteFinancialRecord(FinancialRecord record) async {
    try {
      await (database.delete(database.financialRecords)..where((t) => t.id.equals(record.id))).go();
      await loadAllRecords();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete financial record: $e');
    }
  }

  /// Inserts a new financial record transaction into SQLite and refreshes state
  Future<void> recordFinancialTransaction({
    required String title,
    required double amount,
    required String type,
    String? sponsorName,
    String? notes,
  }) async {
    final now = DateTime.now();
    await database.into(database.financialRecords).insert(
      FinancialRecordsCompanion.insert(
        id: const Uuid().v4(),
        monthYear: DateFormat('MM-yyyy').format(now),
        title: title,
        amount: amount,
        type: type,
        sponsorName: Value(sponsorName?.trim().isEmpty == true ? null : sponsorName?.trim()),
        notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
      ),
    );
    await loadAllRecords();
  }

  /// Registers a new student member into the society members archive and refreshes state
  Future<void> registerStudentRecord({
    required String societyId,
    required String fullName,
    required String rollNo,
    required String cnic,
    required String department,
    required int semester,
    String? phone,
  }) async {
    await database.into(database.societyMembers).insert(
      SocietyMembersCompanion.insert(
        id: const Uuid().v4(),
        societyId: societyId,
        fullName: fullName.trim(),
        rollNo: rollNo.trim(),
        cnic: cnic.trim(),
        department: department.trim(),
        semester: semester,
        phone: Value(phone?.trim().isEmpty == true ? null : phone?.trim()),
        joinedDate: Value(DateTime.now()),
        isActive: const Value(true),
      ),
    );
    await loadAllRecords();
  }

  /// Concurrently fetches aggregated data across three domains:
  /// 1. Institutional Roster: active cabinet officers and enrolled students organized by society.
  /// 2. Financial Ledger: recorded vouchers, sponsorships, grants, and expenditures.
  /// 3. Event Audit: concluded events, specific impact metrics, and attached images/metadata.
  Future<PdfDossierData> fetchAggregatedMonthlyAuditData({DateTime? targetMonth}) async {
    final target = targetMonth ?? DateTime.now();

    // Concurrently trigger queries across all three domains via Future.wait
    final results = await Future.wait([
      // Domain 1: Institutional Roster
      Future.wait([
        database.getUnifiedInstitutionalRoster(),
        database.select(database.societies).get(),
        database.select(database.cabinetMembers).get(),
        database.select(database.societyMembers).get(),
      ]),
      // Domain 2: Financial Ledger
      database.select(database.financialRecords).get(),
      // Domain 3: Event Audit
      Future.wait([
        database.getMonthlyEventsWithSocieties(targetMonth: target, includeOnlyConcluded: false),
        database.select(database.eventSpeakers).get(),
      ]),
      // Achievements & Milestones
      database.select(database.achievements).get(),
    ]);

    // Unpack Domain 1: Institutional Roster
    final rosterData = results[0] as List<dynamic>;
    final unifiedRecords = rosterData[0] as List<UnifiedInstitutionalRecord>;
    final societies = rosterData[1] as List<Society>;
    final cabinetMembers = rosterData[2] as List<CabinetMember>;
    final societyMembers = rosterData[3] as List<SocietyMember>;

    // Unpack Domain 2: Financial Ledger
    final financialRecords = results[1] as List<FinancialRecord>;

    // Unpack Domain 3: Event Audit
    final eventData = results[2] as List<dynamic>;
    final monthlyEventItems = eventData[0] as List<EventWithSociety>;
    final allSpeakers = eventData[1] as List<EventSpeaker>;
    final concludedEvents = monthlyEventItems.map((e) => e.event).toList();

    // Unpack Achievements
    final achievements = results[3] as List<Achievement>;

    // 1. Process Domain 1: Organize Human Resources by Society
    final Map<String, Society> socMap = {for (var s in societies) s.id: s};
    final societyRosters = <PdfSocietyRosterSummary>[];

    for (final soc in societies) {
      final socCabinets = cabinetMembers
          .where((c) => c.societyId == soc.id && c.isActive)
          .map((c) => PdfCabinetMemberItem(
                role: c.role,
                fullName: c.fullName,
                cnic: c.cnic,
                department: c.department,
                semester: c.semester,
                phone: c.phone,
              ))
          .toList();

      final socEnrolled = societyMembers
          .where((m) => m.societyId == soc.id && m.isActive)
          .map((m) => PdfSocietyMemberItem(
                fullName: m.fullName,
                rollNo: m.rollNo,
                cnic: m.cnic,
                department: m.department,
                semester: m.semester,
              ))
          .toList();

      societyRosters.add(
        PdfSocietyRosterSummary(
          societyId: soc.id,
          societyName: soc.name,
          acronym: soc.acronym,
          pillar: soc.pillar,
          facultyAdvisor: soc.facultyAdvisor,
          cabinetCount: socCabinets.length,
          enrolledCount: socEnrolled.length,
          cabinetMembers: socCabinets,
          enrolledMembers: socEnrolled,
        ),
      );
    }

    // 2. Process Domain 2: Financial Ledger Items & Metrics
    double totalBudgetSpent = 0.0;
    double totalSponsorships = 0.0;
    final financialLedgerItems = <PdfFinancialLedgerItem>[];

    for (final f in financialRecords) {
      final isExp = f.type.toLowerCase() == 'expense';
      if (isExp) {
        totalBudgetSpent += f.amount;
      } else {
        totalSponsorships += f.amount;
      }

      financialLedgerItems.add(
        PdfFinancialLedgerItem(
          id: f.id,
          title: f.title,
          amount: f.amount,
          type: f.type,
          sponsorOrPayee: f.sponsorName,
          notes: f.notes,
          date: f.recordedAt,
        ),
      );
    }

    // 3. Process Domain 3: Event Audit Items with Metrics & Attached Media Manifest
    final eventAuditItems = <PdfEventAuditItem>[];
    int totalAttendees = 0;

    for (final item in monthlyEventItems) {
      final evt = item.event;
      totalAttendees += evt.attendeesCount;

      final soc = item.society ?? socMap[evt.societyId];
      final socName = soc != null
          ? ((soc.acronym != null && soc.acronym!.trim().isNotEmpty)
              ? '${soc.name} (${soc.acronym!.trim()})'
              : soc.name)
          : (evt.collaboratorNames != null && evt.collaboratorNames!.trim().isNotEmpty
              ? evt.collaboratorNames!
              : 'Directorate of Youth Development Centre');
      final pillar = soc != null ? soc.pillar : 'Institutional Development';
      final variance = evt.allocatedBudget - evt.actualExpense;

      // Filter keynote speakers for this event
      final eventSpeakers = allSpeakers
          .where((s) => s.eventId == evt.id)
          .map((s) => {
                'name': s.name,
                'designation': s.designation ?? 'Keynote Speaker',
                'organization': s.organization.isNotEmpty ? s.organization : 'Institutional Guest',
              })
          .toList();

      // Parse attached images manifest & load bytes if files exist on local disk
      final galleryPaths = evt.galleryImages;
      final thumbnailBytesList = <Uint8List>[];

      for (final p in galleryPaths) {
        try {
          final file = File(p);
          if (file.existsSync()) {
            thumbnailBytesList.add(await file.readAsBytes());
          }
        } catch (_) {}
      }

      eventAuditItems.add(
        PdfEventAuditItem(
          id: evt.id,
          title: evt.title,
          description: evt.description,
          date: evt.eventDate,
          societyName: socName,
          societyId: soc?.id ?? evt.societyId,
          pillar: pillar,
          venue: evt.venue,
          attendeesCount: evt.attendeesCount,
          allocatedBudget: evt.allocatedBudget,
          actualExpense: evt.actualExpense,
          fiscalVariance: variance,
          positiveImpactSummary: evt.positiveImpactSummary,
          isCollaboration: evt.isCollaboration,
          collaboratorNames: evt.collaboratorNames,
          speakers: eventSpeakers,
          imagePaths: galleryPaths,
          thumbnailBytes: thumbnailBytesList,
        ),
      );
    }

    // Strategic Pillars Distribution
    final Map<String, int> pillarDist = {
      'Education': societies.where((s) => s.pillar == 'Education').length,
      'Employment': societies.where((s) => s.pillar == 'Employment').length,
      'Engagement': societies.where((s) => s.pillar == 'Engagement').length,
      'Environment': societies.where((s) => s.pillar == 'Environment').length,
    };

    // Backward-compatible unified roster items
    final unifiedRosterItems = unifiedRecords.map((r) {
      final soc = socMap[r.societyId];
      return PdfUnifiedRosterItem(
        fullName: r.fullName,
        role: r.role,
        identifier: r.identifier,
        societyName: soc?.name ?? 'General YDC',
        pillar: soc?.pillar ?? 'Education',
        department: r.department,
        semester: r.semester,
        isExecutive: r.isExecutive,
      );
    }).toList();

    // Backward-compatible concluded event items
    final legacyConcludedEvents = concludedEvents.map((e) {
      final soc = socMap[e.societyId];
      final host = soc != null ? '${soc.name} (${soc.pillar})' : 'YDC Directorate';
      return PdfConcludedEventItem(
        title: e.title,
        date: e.eventDate,
        hostSociety: host,
        attendeesCount: e.attendeesCount,
        allocatedBudget: e.allocatedBudget,
        actualExpense: e.actualExpense,
      );
    }).toList();

    return PdfDossierData(
      monthYear: DateFormat('MMMM yyyy').format(target),
      totalSocieties: societies.length,
      totalMembers: unifiedRecords.where((r) => !r.isExecutive).length,
      totalCabinet: unifiedRecords.where((r) => r.isExecutive).length,
      totalEvents: concludedEvents.length,
      totalAttendees: totalAttendees,
      totalBudgetSpent: totalBudgetSpent,
      totalSponsorships: totalSponsorships,
      pillarDistribution: pillarDist,
      achievements: achievements.map((a) => {'title': a.title, 'description': a.description ?? ''}).toList(),
      financialItems: financialRecords.map((f) => {
        'title': f.title,
        'amount': f.amount,
        'type': f.type,
        'sponsorName': f.sponsorName ?? '',
        'notes': f.notes ?? '',
      }).toList(),
      concludedEvents: legacyConcludedEvents,
      unifiedRoster: unifiedRosterItems,
      societyRosters: societyRosters,
      financialLedger: financialLedgerItems,
      eventAudits: eventAuditItems,
    );
  }

  /// Encrypts the Master Monthly Audit Dossier using AES-256-GCM envelope encryption,
  /// tags it with master category 'Monthly Audits', packages structured metadata covering
  /// the target month/year and references to all covered societies and events, and persists
  /// the sealed record into the local SQLite Confidential Institutional Vault.
  Future<ConfidentialVaultData> archiveMonthlyAuditDossier({
    required Uint8List pdfBytes,
    required PdfDossierData dossierData,
    DateTime? targetMonth,
    String pin = '1234',
  }) async {
    state = state.copyWith(
      isVaultArchiving: true,
      vaultArchiveMessage: 'Encrypting Master Monthly Audit Dossier (AES-256-GCM)...',
    );

    try {
      final effectiveDate = targetMonth ?? DateTime.now();
      final monthYear = dossierData.monthYear;
      final periodCode = DateFormat('yyyy-MM').format(effectiveDate);
      final checksum = await EncryptionService.calculateChecksum(pdfBytes);
      final fileName = 'Master_Monthly_Audit_${DateFormat('yyyyMM').format(effectiveDate)}.pdf';

      // 1. Pass in-memory Master Monthly Audit PDF byte data directly into AES-256-GCM encryption pipeline
      final encPath = await EncryptionService.encryptAndStoreFile(
        rawBytes: pdfBytes,
        originalFileName: fileName,
        masterPassword: pin,
      );

      // 2. Map covered societies & events into structured audit metadata
      final coveredSocieties = dossierData.societyRosters.map((s) {
        return AuditCoveredSociety(
          id: s.societyId,
          name: s.societyName,
          acronym: s.acronym,
          pillar: s.pillar,
          cabinetCount: s.cabinetCount,
          enrolledCount: s.enrolledCount,
        );
      }).toList();

      final coveredEvents = dossierData.eventAudits.map((e) {
        return AuditCoveredEvent(
          id: e.id,
          title: e.title,
          eventDate: e.date,
          hostSociety: e.societyName,
          pillar: e.pillar,
          attendeesCount: e.attendeesCount,
          allocatedBudget: e.allocatedBudget,
          actualExpense: e.actualExpense,
        );
      }).toList();

      final metadata = MonthlyAuditVaultMetadata(
        monthYear: monthYear,
        periodCode: periodCode,
        effectiveDate: effectiveDate,
        totalSocieties: dossierData.totalSocieties,
        totalEvents: dossierData.totalEvents,
        totalMembers: dossierData.totalMembers,
        totalCabinet: dossierData.totalCabinet,
        totalAttendees: dossierData.totalAttendees,
        totalBudgetSpent: dossierData.totalBudgetSpent,
        totalSponsorships: dossierData.totalSponsorships,
        coveredSocieties: coveredSocieties,
        coveredEvents: coveredEvents,
      );

      final metadataNotes = metadata.toVaultMetadataNotes();
      final refNum = 'AUST/YDC/AUDIT/$periodCode/${checksum.length >= 8 ? checksum.substring(0, 8).toUpperCase() : checksum.toUpperCase()}';

      // Check if Monthly Audit record already exists for this period to update or create
      final allVaultRecords = await database.select(database.confidentialVault).get();
      final existingRecords = allVaultRecords
          .where((r) =>
              r.category == 'Monthly Audits' &&
              (r.referenceNumber?.startsWith('AUST/YDC/AUDIT/$periodCode') ?? false))
          .toList();

      ConfidentialVaultData inserted;
      if (existingRecords.isNotEmpty) {
        final existing = existingRecords.first;
        if (existing.encryptedFilePath != encPath) {
          try {
            final oldFile = File(existing.encryptedFilePath);
            if (oldFile.existsSync()) {
              await oldFile.delete();
            }
          } catch (_) {}
        }
        await (database.update(database.confidentialVault)
              ..where((tbl) => tbl.id.equals(existing.id)))
            .write(
          ConfidentialVaultCompanion(
            title: Value('[Master Audit Dossier] Monthly Institutional Audit — $monthYear'),
            referenceNumber: Value(refNum),
            effectiveDate: Value(effectiveDate),
            expiryDate: Value(effectiveDate.add(const Duration(days: 3650))),
            encryptedFilePath: Value(encPath),
            fileChecksum: Value(checksum),
            fileSizeBytes: Value(pdfBytes.length),
            originalFileName: Value(fileName),
            metadataNotes: Value(metadataNotes),
            uploadedAt: Value(DateTime.now()),
          ),
        );
        inserted = (await (database.select(database.confidentialVault)
              ..where((tbl) => tbl.id.equals(existing.id)))
            .get())
            .first;
      } else {
        final companion = ConfidentialVaultCompanion.insert(
          id: const Uuid().v4(),
          societyId: const Value(null),
          category: 'Monthly Audits',
          title: '[Master Audit Dossier] Monthly Institutional Audit — $monthYear',
          referenceNumber: Value(refNum),
          effectiveDate: Value(effectiveDate),
          expiryDate: Value(effectiveDate.add(const Duration(days: 3650))),
          encryptedFilePath: encPath,
          fileChecksum: checksum,
          fileSizeBytes: Value(pdfBytes.length),
          originalFileName: Value(fileName),
          metadataNotes: Value(metadataNotes),
        );

        inserted = await database.into(database.confidentialVault).insertReturning(companion);
      }

      state = state.copyWith(
        isVaultArchiving: false,
        lastArchivedVaultDoc: inserted,
        vaultArchiveMessage: 'Archived to Vault (${inserted.referenceNumber})',
      );

      return inserted;
    } catch (e) {
      state = state.copyWith(
        isVaultArchiving: false,
        vaultArchiveMessage: 'Vault archive error: $e',
      );
      rethrow;
    }
  }

  /// Triggers aggregated data fetching across all 3 domains and generates the master A4 PDF dossier.
  /// Automatically intercepts the completion hook by piping raw in-memory PDF byte data directly
  /// into the AES-256-GCM encryption pipeline and sealing it into the SQLite Confidential Vault under 'Monthly Audits'.
  Future<Uint8List> generateMonthlyAuditDossier({
    DateTime? targetMonth,
    bool autoArchiveToVault = true,
  }) async {
    state = state.copyWith(isGeneratingDossier: true);
    try {
      final dossierData = await fetchAggregatedMonthlyAuditData(targetMonth: targetMonth);
      final pdfBytes = await PdfDossierService.generateMonthlyDossier(dossierData);

      // Trigger Hook: Intercept the completion of the 'Generate Dossier (PDF)' function
      if (autoArchiveToVault) {
        try {
          await archiveMonthlyAuditDossier(
            pdfBytes: pdfBytes,
            dossierData: dossierData,
            targetMonth: targetMonth,
          );
        } catch (vaultErr) {
          debugPrint('Error during automated vault archiving: $vaultErr');
        }
      }

      state = state.copyWith(isGeneratingDossier: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isGeneratingDossier: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

/// Central Riverpod Provider for the Records & Institutional Intelligence module
final recordsDashboardProvider = StateNotifierProvider.family<
    RecordsDashboardNotifier, RecordsDashboardState, AppDatabase>(
  (ref, db) => RecordsDashboardNotifier(db),
);

// Backward-compatible alias for existing codebase and tests
typedef UnifiedRosterState = RecordsDashboardState;
typedef UnifiedRosterNotifier = RecordsDashboardNotifier;
final unifiedRosterProvider = recordsDashboardProvider;
