import 'dart:io';
import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/security/encryption_service.dart';
import '../../../../core/services/reporting/pdf_dossier_service.dart';
import '../../../../core/services/reporting/monthly_audit_vault_metadata.dart';

class VaultFilterState {
  static const List<String> defaultStaticCategories = [
    'All',
    'Monthly Audits',
    'MOU',
    'Contract',
    'PMYP',
    'Internee_Record',
    'Audit',
  ];

  final String selectedCategory;
  final String searchQuery;
  final List<ConfidentialVaultData> vaultDocs;
  final List<Society> societies;
  final bool isLoading;
  final bool isUnlocked;
  final String? pinError;
  final bool isArchiving;
  final String? archiveStatusMessage;

  const VaultFilterState({
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.vaultDocs = const [],
    this.societies = const [],
    this.isLoading = false,
    this.isUnlocked = false,
    this.pinError,
    this.isArchiving = false,
    this.archiveStatusMessage,
  });

  /// Dynamically combines default static institutional categories with active society workspaces
  List<String> get dynamicCategories {
    final list = List<String>.from(defaultStaticCategories);
    for (final soc in societies) {
      final label = soc.acronym != null && soc.acronym!.trim().isNotEmpty
          ? soc.acronym!.trim()
          : soc.name.trim();
      if (!list.contains(label)) {
        list.add(label);
      }
    }
    return list;
  }

  /// Filters vault documents matching category (static or society workspace) and search query
  List<ConfidentialVaultData> get filteredDocs {
    return vaultDocs.where((doc) {
      final matchesCat = _checkCategoryMatch(doc);
      if (!matchesCat) return false;

      if (searchQuery.trim().isEmpty) return true;
      final q = searchQuery.toLowerCase().trim();
      return doc.title.toLowerCase().contains(q) ||
          (doc.referenceNumber?.toLowerCase().contains(q) ?? false) ||
          (doc.originalFileName?.toLowerCase().contains(q) ?? false) ||
          (doc.metadataNotes?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  bool _checkCategoryMatch(ConfidentialVaultData doc) {
    if (selectedCategory == 'All') return true;

    // Check direct category match
    if (doc.category.toLowerCase() == selectedCategory.toLowerCase()) {
      return true;
    }

    // Check if selectedCategory corresponds to a Society
    for (final soc in societies) {
      final socLabel = soc.acronym != null && soc.acronym!.trim().isNotEmpty
          ? soc.acronym!.trim()
          : soc.name.trim();

      if (socLabel.toLowerCase() == selectedCategory.toLowerCase() ||
          soc.name.toLowerCase() == selectedCategory.toLowerCase()) {
        if (doc.societyId != null && doc.societyId == soc.id) {
          return true;
        }
        if (doc.category.toLowerCase() == soc.name.toLowerCase() ||
            (soc.acronym != null &&
                doc.category.toLowerCase() == soc.acronym!.toLowerCase())) {
          return true;
        }
      }
    }

    return false;
  }

  VaultFilterState copyWith({
    String? selectedCategory,
    String? searchQuery,
    List<ConfidentialVaultData>? vaultDocs,
    List<Society>? societies,
    bool? isLoading,
    bool? isUnlocked,
    String? pinError,
    bool? isArchiving,
    String? archiveStatusMessage,
  }) {
    return VaultFilterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      vaultDocs: vaultDocs ?? this.vaultDocs,
      societies: societies ?? this.societies,
      isLoading: isLoading ?? this.isLoading,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      pinError: pinError,
      isArchiving: isArchiving ?? this.isArchiving,
      archiveStatusMessage: archiveStatusMessage ?? this.archiveStatusMessage,
    );
  }
}

class VaultNotifier extends StateNotifier<VaultFilterState> {
  final AppDatabase database;
  static const String masterPin = '1234';
  StreamSubscription<List<Society>>? _societiesSubscription;

  VaultNotifier(this.database) : super(const VaultFilterState()) {
    _initSocietiesStream();
    loadSocieties();
  }

  void _initSocietiesStream() {
    _societiesSubscription = (database.select(database.societies)
          ..where((tbl) => tbl.isActive.equals(true))
          ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.name)]))
        .watch()
        .listen(
      (activeSocs) {
        state = state.copyWith(societies: activeSocs);
      },
      onError: (e) {
        debugPrint('Error in societies watch stream: $e');
      },
    );
  }

  @override
  void dispose() {
    _societiesSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadSocieties() async {
    try {
      final activeSocs = await (database.select(database.societies)
            ..where((tbl) => tbl.isActive.equals(true))
            ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.name)]))
          .get();
      state = state.copyWith(societies: activeSocs);
    } catch (e) {
      debugPrint('Error loading societies for vault: $e');
    }
  }

  Future<void> loadVaultRecords() async {
    state = state.copyWith(isLoading: true);
    try {
      final docs = await (database.select(database.confidentialVault)
            ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.uploadedAt)]))
          .get();
      await loadSocieties();
      state = state.copyWith(vaultDocs: docs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Error loading vault documents: $e');
    }
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setCategory(String category) => selectCategory(category);

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  bool unlock(String pin) {
    if (pin.trim() == masterPin) {
      state = state.copyWith(isUnlocked: true, pinError: null);
      loadVaultRecords();
      return true;
    } else {
      state = state.copyWith(
        pinError: 'Incorrect PIN. Default institutional PIN is 1234.',
      );
      return false;
    }
  }

  void lock() {
    state = state.copyWith(
      isUnlocked: false,
      vaultDocs: const [],
      searchQuery: '',
      pinError: null,
    );
  }

  Future<void> deleteDoc(ConfidentialVaultData doc) async {
    try {
      final f = File(doc.encryptedFilePath);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (e) {
      debugPrint('Error deleting encrypted file: $e');
    }

    await (database.delete(database.confidentialVault)
          ..where((tbl) => tbl.id.equals(doc.id)))
        .go();
    await loadVaultRecords();
  }

  /// Automatically generates an Event Archive PDF, encrypts with AES-256-GCM,
  /// and saves a locked record into the Confidential Vault.
  Future<ConfidentialVaultData> archiveEvent({
    required Event event,
    Society? society,
    List<EventSpeaker> speakers = const [],
    String pin = masterPin,
  }) async {
    state = state.copyWith(
      isArchiving: true,
      archiveStatusMessage: 'Compiling & encrypting event archive...',
    );

    try {
      Society? effectiveSoc = society;
      if (effectiveSoc == null && event.societyId != null) {
        final socs = await (database.select(database.societies)
              ..where((tbl) => tbl.id.equals(event.societyId!)))
            .get();
        if (socs.isNotEmpty) {
          effectiveSoc = socs.first;
        }
      }

      final socName = effectiveSoc?.name ?? 'University Directorate';
      final socAcronym = effectiveSoc?.acronym;
      final socPillar = effectiveSoc?.pillar ?? 'Engagement';

      final speakersList = speakers
          .map((s) => {
                'name': s.name,
                'designation': s.designation ?? 'Guest Speaker',
                'organization': s.organization,
              })
          .toList();

      final archiveData = PdfEventArchiveData(
        title: event.title,
        eventDate: event.eventDate,
        societyName: socName,
        acronym: socAcronym,
        pillar: socPillar,
        venue: event.venue,
        allocatedBudget: event.allocatedBudget,
        actualExpense: event.actualExpense,
        attendeesCount: event.attendeesCount,
        description: event.description,
        positiveImpactSummary: event.positiveImpactSummary,
        isCollaboration: event.isCollaboration,
        collaboratorNames: event.collaboratorNames,
        speakers: speakersList,
        imagePaths: event.galleryImages,
      );

      final pdfBytes = await PdfDossierService.generateEventArchivePdf(archiveData);
      final checksum = await EncryptionService.calculateChecksum(pdfBytes);

      final sanitizedTitle = event.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(RegExp(r'\s+'), '_');
      final fileName = 'EVENT_${sanitizedTitle}_${DateFormat('yyyyMMdd').format(event.eventDate)}.pdf';

      final encPath = await EncryptionService.encryptAndStoreFile(
        rawBytes: pdfBytes,
        originalFileName: fileName,
        masterPassword: pin,
      );

      final categoryTag = socAcronym != null && socAcronym.trim().isNotEmpty
          ? socAcronym.trim()
          : (society?.name != null ? society!.name.trim() : 'Event_Archive');

      final dateStr = DateFormat('yyyyMMdd').format(event.eventDate);
      final refNum = 'AUST/YDC/EVT/$dateStr/${event.id.length >= 6 ? event.id.substring(0, 6) : event.id}';

      final companion = ConfidentialVaultCompanion.insert(
        id: const Uuid().v4(),
        societyId: drift.Value(society?.id ?? event.societyId),
        category: categoryTag,
        title: '[Event Archive] ${event.title}',
        referenceNumber: drift.Value(refNum),
        effectiveDate: drift.Value(event.eventDate),
        expiryDate: drift.Value(event.eventDate.add(const Duration(days: 1825))),
        encryptedFilePath: encPath,
        fileChecksum: checksum,
        fileSizeBytes: drift.Value(pdfBytes.length),
        originalFileName: drift.Value(fileName),
        metadataNotes: drift.Value(
          'Automated Event Archive • Venue: ${event.venue ?? "Campus"} • Attendees: ${event.attendeesCount} • Budget: Rs. ${event.allocatedBudget}',
        ),
      );

      final inserted = await database.into(database.confidentialVault).insertReturning(companion);

      if (state.isUnlocked) {
        await loadVaultRecords();
      }

      state = state.copyWith(
        isArchiving: false,
        archiveStatusMessage: null,
      );

      return inserted;
    } catch (e) {
      state = state.copyWith(
        isArchiving: false,
        archiveStatusMessage: null,
      );
      rethrow;
    }
  }

  /// Automatically generates or captures a Society Dossier PDF (cabinet hierarchy + student roster),
  /// encrypts it using AES-256-GCM, and commits it into the Vault.
  Future<ConfidentialVaultData> archiveFinalizedRoster({
    required Society society,
    List<CabinetMember> cabinet = const [],
    List<SocietyMember> members = const [],
    Uint8List? pdfBytes,
    String? sessionYear,
    int totalEvents = 0,
    String pin = masterPin,
  }) async {
    state = state.copyWith(
      isArchiving: true,
      archiveStatusMessage: 'Encrypting finalized institutional roster...',
    );

    try {
      final now = DateTime.now();
      final effectiveSession = sessionYear ?? DateFormat('yyyy').format(now);

      final Uint8List rawPdfBytes;
      if (pdfBytes != null) {
        rawPdfBytes = pdfBytes;
      } else {
        final dossierData = PdfSocietyDossierData(
          societyName: society.name,
          acronym: society.acronym,
          pillar: society.pillar,
          facultyAdvisor: society.facultyAdvisor,
          logoPath: society.logoPath,
          monthYear: DateFormat('MMMM yyyy').format(now),
          cabinet: cabinet
              .map((c) => PdfCabinetMemberItem(
                    role: c.role,
                    fullName: c.fullName,
                    cnic: c.cnic,
                    department: c.department,
                    semester: c.semester,
                    phone: c.phone,
                  ))
              .toList(),
          members: members
              .map((m) => PdfSocietyMemberItem(
                    fullName: m.fullName,
                    rollNo: m.rollNo,
                    cnic: m.cnic,
                    department: m.department,
                    semester: m.semester,
                  ))
              .toList(),
          totalEvents: totalEvents,
        );
        rawPdfBytes = await PdfDossierService.generateSocietyDossier(dossierData);
      }

      final checksum = await EncryptionService.calculateChecksum(rawPdfBytes);

      final socTag = society.acronym != null && society.acronym!.trim().isNotEmpty
          ? society.acronym!.trim()
          : society.name.trim();

      final sanitizedSoc = socTag.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(RegExp(r'\s+'), '_');
      final fileName = '${sanitizedSoc}_Finalized_Roster_$effectiveSession.pdf';

      final encPath = await EncryptionService.encryptAndStoreFile(
        rawBytes: rawPdfBytes,
        originalFileName: fileName,
        masterPassword: pin,
      );

      final refNum = 'AUST/YDC/ROSTER/$sanitizedSoc/$effectiveSession';

      final companion = ConfidentialVaultCompanion.insert(
        id: const Uuid().v4(),
        societyId: drift.Value(society.id),
        category: socTag,
        title: '[Finalized Roster] Finalized Cabinet & Member Roster — ${society.name} ($effectiveSession)',
        referenceNumber: drift.Value(refNum),
        effectiveDate: drift.Value(now),
        expiryDate: drift.Value(now.add(const Duration(days: 3650))),
        encryptedFilePath: encPath,
        fileChecksum: checksum,
        fileSizeBytes: drift.Value(rawPdfBytes.length),
        originalFileName: drift.Value(fileName),
        metadataNotes: drift.Value(
          'Immutable Finalized Roster • ${cabinet.length} Cabinet Officers • ${members.length} Enrolled Members • Sealed into Vault.',
        ),
      );

      final inserted = await database.into(database.confidentialVault).insertReturning(companion);

      if (state.isUnlocked) {
        await loadVaultRecords();
      }

      state = state.copyWith(
        isArchiving: false,
        archiveStatusMessage: null,
      );

      return inserted;
    } catch (e) {
      state = state.copyWith(
        isArchiving: false,
        archiveStatusMessage: null,
      );
      rethrow;
    }
  }

  /// Automatically encrypts the Master Monthly Audit Dossier using AES-256-GCM,
  /// structures comprehensive metadata for the month/year alongside covered societies and events,
  /// and seals the record into the SQLite Confidential Institutional Vault under the 'Monthly Audits' master category.
  Future<ConfidentialVaultData> archiveMonthlyAuditDossier({
    required Uint8List pdfBytes,
    required PdfDossierData dossierData,
    DateTime? targetMonth,
    String pin = masterPin,
  }) async {
    state = state.copyWith(
      isArchiving: true,
      archiveStatusMessage: 'Encrypting Master Monthly Audit Dossier (AES-256-GCM)...',
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

      // Check for existing Monthly Audit record for this period to update or create
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
            title: drift.Value('[Master Audit Dossier] Monthly Institutional Audit — $monthYear'),
            referenceNumber: drift.Value(refNum),
            effectiveDate: drift.Value(effectiveDate),
            expiryDate: drift.Value(effectiveDate.add(const Duration(days: 3650))),
            encryptedFilePath: drift.Value(encPath),
            fileChecksum: drift.Value(checksum),
            fileSizeBytes: drift.Value(pdfBytes.length),
            originalFileName: drift.Value(fileName),
            metadataNotes: drift.Value(metadataNotes),
            uploadedAt: drift.Value(DateTime.now()),
          ),
        );
        inserted = (await (database.select(database.confidentialVault)
              ..where((tbl) => tbl.id.equals(existing.id)))
            .get())
            .first;
      } else {
        final companion = ConfidentialVaultCompanion.insert(
          id: const Uuid().v4(),
          societyId: const drift.Value(null),
          category: 'Monthly Audits',
          title: '[Master Audit Dossier] Monthly Institutional Audit — $monthYear',
          referenceNumber: drift.Value(refNum),
          effectiveDate: drift.Value(effectiveDate),
          expiryDate: drift.Value(effectiveDate.add(const Duration(days: 3650))),
          encryptedFilePath: encPath,
          fileChecksum: checksum,
          fileSizeBytes: drift.Value(pdfBytes.length),
          originalFileName: drift.Value(fileName),
          metadataNotes: drift.Value(metadataNotes),
        );

        inserted = await database.into(database.confidentialVault).insertReturning(companion);
      }

      if (state.isUnlocked) {
        await loadVaultRecords();
      }

      state = state.copyWith(
        isArchiving: false,
        archiveStatusMessage: null,
      );

      return inserted;
    } catch (e) {
      state = state.copyWith(
        isArchiving: false,
        archiveStatusMessage: null,
      );
      rethrow;
    }
  }
}

final vaultProvider = StateNotifierProvider.family<VaultNotifier, VaultFilterState, AppDatabase>(
  (ref, db) => VaultNotifier(db),
);
