import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ydc_aust/core/database/app_database.dart';
import 'package:ydc_aust/core/security/encryption_service.dart';
import 'package:ydc_aust/core/services/reporting/pdf_dossier_service.dart';
import 'package:ydc_aust/core/services/reporting/monthly_audit_vault_metadata.dart';
import 'package:ydc_aust/features/records/presentation/screens/records_screen.dart';
import 'package:ydc_aust/features/records/presentation/state/unified_roster_provider.dart';
import 'package:ydc_aust/features/vault/presentation/state/vault_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Monthly Audit Dossier & Events Integration Tests', () {
    testWidgets('RecordsScreen renders "Monthly Events & Activities Audit" section below Financial Ledger with clean Empty State', (tester) async {
      tester.view.physicalSize = const Size(1300, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = AppDatabase(NativeDatabase.memory());

      // Seed a society with no events
      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: 'soc-test-1',
          name: 'Green Campus Society',
          pillar: 'Environment',
          facultyAdvisor: 'Dr. Asif',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RecordsScreen(database: db),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Section 3 header
      expect(find.text('Monthly Events & Activities Audit'), findsOneWidget);
      expect(find.text('Summary of institutional events, workshops, seminars, and student engagements conducted this month.'), findsOneWidget);

      // Verify Empty State widget when no events occurred
      expect(find.text('No Events Recorded This Month'), findsOneWidget);
      expect(find.text('No institutional events, workshops, or activities occurred during the current month.'), findsOneWidget);

      await db.close();
    });

    testWidgets('RecordsScreen displays data table for events that occurred during the current month', (tester) async {
      tester.view.physicalSize = const Size(1300, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = AppDatabase(NativeDatabase.memory());
      const socId = 'soc-active-1';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'Computer Science Guild',
          acronym: const drift.Value('CSG'),
          pillar: 'Education',
          facultyAdvisor: 'Dr. Tariq',
        ),
      );

      final now = DateTime.now();
      // Insert event that occurred in current month (2 days ago)
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-audit-101',
          title: 'AUST AI & Cloud Computing Bootcamp',
          description: 'Hands-on practical training on modern AI and cloud architectures.',
          eventDate: now.subtract(const Duration(days: 2)),
          societyId: const drift.Value(socId),
          allocatedBudget: const drift.Value(75000.0),
          actualExpense: const drift.Value(68000.0),
          attendeesCount: const drift.Value(320),
          positiveImpactSummary: const drift.Value('320 students certified in AI basics.'),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RecordsScreen(database: db),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify section header and badge
      expect(find.text('Monthly Events & Activities Audit'), findsOneWidget);
      expect(find.text('1 Events Logged'), findsOneWidget);

      // Verify Event row in the data table
      expect(find.text('AUST AI & Cloud Computing Bootcamp'), findsOneWidget);
      expect(find.text('Computer Science Guild'), findsOneWidget);
      expect(find.text('320 Attendees'), findsOneWidget);
      expect(find.text('Budget: Rs. 75,000'), findsOneWidget);
      expect(find.text('Expense: Rs. 68,000'), findsOneWidget);
      expect(find.text('Concluded'), findsOneWidget);

      await db.close();
    });

    test('Riverpod recordsDashboardProvider concurrently fetches data across Institutional Roster, Financial Ledger, and Event Audit domains', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const socId = 'soc-concurrent-test';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'Eco Protection Society',
          acronym: const drift.Value('EPS'),
          pillar: 'Environment',
          facultyAdvisor: 'Dr. Muhammad Asif',
        ),
      );

      // Domain 1: Institutional Roster (Cabinet + Student)
      await db.into(db.cabinetMembers).insert(
        CabinetMembersCompanion.insert(
          id: 'cab-1',
          societyId: socId,
          tenureSession: '2025-2026',
          role: 'President',
          fullName: 'Zainab Bibi',
          cnic: '13101-1456782-4',
          email: 'zainab@aust.edu.pk',
          phone: '0301-4455667',
          department: 'Earth Sciences',
          semester: 7,
        ),
      );

      await db.into(db.societyMembers).insert(
        SocietyMembersCompanion.insert(
          id: 'stu-1',
          societyId: socId,
          fullName: 'Hamza Tanveer',
          rollNo: 'FA21-ENV-001',
          cnic: '13101-9874561-3',
          department: 'Civil Engineering',
          semester: 5,
        ),
      );

      // Domain 2: Financial Ledger (Inflow Sponsorship + Outflow Expense)
      await db.into(db.financialRecords).insert(
        FinancialRecordsCompanion.insert(
          id: 'fin-1',
          monthYear: '09-2026',
          title: 'HEC Climate Action Grant',
          amount: 250000.0,
          type: 'Grant',
          sponsorName: const drift.Value('Higher Education Commission'),
          notes: const drift.Value('Special institutional sustainability grant'),
        ),
      );

      await db.into(db.financialRecords).insert(
        FinancialRecordsCompanion.insert(
          id: 'fin-2',
          monthYear: '09-2026',
          title: 'Tree Saplings & Soil Logistics',
          amount: 45000.0,
          type: 'Expense',
          sponsorName: const drift.Value('Khyber Forest Nursery'),
          notes: const drift.Value('500 pine and cedar saplings'),
        ),
      );

      // Domain 3: Event Audit (Concluded Event + Speaker)
      const eventId = 'evt-dossier-test';
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: eventId,
          title: 'AUST Clean & Green Campus Drive 2026',
          description: 'Comprehensive tree plantation and environmental sanitation campaign across campus.',
          eventDate: DateTime.now().subtract(const Duration(days: 3)),
          societyId: const drift.Value(socId),
          allocatedBudget: const drift.Value(50000.0),
          actualExpense: const drift.Value(45000.0),
          attendeesCount: const drift.Value(400),
          positiveImpactSummary: const drift.Value('500 trees planted across university academic grounds.'),
        ),
      );

      await db.into(db.eventSpeakers).insert(
        EventSpeakersCompanion.insert(
          id: 'spk-1',
          eventId: eventId,
          name: 'Engr. Tariq Mehmood',
          organization: 'WWF Pakistan',
          designation: const drift.Value('Senior Conservationist'),
        ),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(recordsDashboardProvider(db).notifier);

      // Trigger multi-domain aggregated data fetching
      final dossierData = await notifier.fetchAggregatedMonthlyAuditData();

      // Verify Domain 1 (Institutional Roster organized by society)
      expect(dossierData.societyRosters, isNotEmpty);
      final epsRoster = dossierData.societyRosters.firstWhere((s) => s.societyId == socId);
      expect(epsRoster.societyName, equals('Eco Protection Society'));
      expect(epsRoster.cabinetCount, equals(1));
      expect(epsRoster.enrolledCount, equals(1));
      expect(epsRoster.cabinetMembers.first.fullName, equals('Zainab Bibi'));
      expect(epsRoster.cabinetMembers.first.role, equals('President'));
      expect(epsRoster.enrolledMembers.first.fullName, equals('Hamza Tanveer'));

      // Verify Domain 2 (Financial Ledger)
      expect(dossierData.financialLedger.length, equals(2));
      final grant = dossierData.financialLedger.firstWhere((f) => f.title == 'HEC Climate Action Grant');
      expect(grant.amount, equals(250000.0));
      expect(grant.isInflow, isTrue);

      final expense = dossierData.financialLedger.firstWhere((f) => f.title == 'Tree Saplings & Soil Logistics');
      expect(expense.amount, equals(45000.0));
      expect(expense.isInflow, isFalse);

      // Verify Domain 3 (Event Audit)
      expect(dossierData.eventAudits.length, equals(1));
      final eventAudit = dossierData.eventAudits.first;
      expect(eventAudit.title, equals('AUST Clean & Green Campus Drive 2026'));
      expect(eventAudit.attendeesCount, equals(400));
      expect(eventAudit.allocatedBudget, equals(50000.0));
      expect(eventAudit.actualExpense, equals(45000.0));
      expect(eventAudit.fiscalVariance, equals(5000.0));
      expect(eventAudit.positiveImpactSummary, contains('500 trees planted'));
      expect(eventAudit.speakers.length, equals(1));
      expect(eventAudit.speakers.first['name'], equals('Engr. Tariq Mehmood'));

      // Generate complete Master Institutional Monthly Audit Dossier PDF
      final pdfBytes = await notifier.generateMonthlyAuditDossier();
      expect(pdfBytes, isNotEmpty);
      final magicHeader = String.fromCharCodes(pdfBytes.take(4));
      expect(magicHeader, equals('%PDF'));

      await db.close();
    });

    test('PdfDossierService compiles complete Master Institutional Monthly Audit with all 3 Sections', () async {
      final dossierData = PdfDossierData(
        monthYear: 'September 2026',
        totalSocieties: 2,
        totalMembers: 40,
        totalCabinet: 8,
        totalEvents: 1,
        totalAttendees: 250,
        totalBudgetSpent: 50000,
        totalSponsorships: 150000,
        pillarDistribution: {'Education': 1, 'Environment': 1},
        achievements: [],
        financialItems: [],
        societyRosters: [
          PdfSocietyRosterSummary(
            societyId: 'soc-1',
            societyName: 'Computer Science Guild',
            acronym: 'CSG',
            pillar: 'Education',
            facultyAdvisor: 'Dr. Tariq Shah',
            cabinetCount: 4,
            enrolledCount: 20,
            cabinetMembers: [
              PdfCabinetMemberItem(
                role: 'President',
                fullName: 'Muhammad Awais',
                cnic: '13101-5566778-1',
                department: 'Computer Science',
                semester: 7,
                phone: '0333-8899001',
              ),
            ],
            enrolledMembers: [
              PdfSocietyMemberItem(
                fullName: 'Kashif Mehmood',
                rollNo: 'FA21-BCS-089',
                cnic: '13101-9988112-7',
                department: 'Computer Science',
                semester: 4,
              ),
            ],
          ),
        ],
        financialLedger: [
          PdfFinancialLedgerItem(
            id: 'fin-in-1',
            title: 'PTCL Tech Sponsorship',
            amount: 150000.0,
            type: 'Sponsorship',
            sponsorOrPayee: 'PTCL Abbottabad',
            notes: 'Hackathon sponsorship grant',
          ),
          PdfFinancialLedgerItem(
            id: 'fin-out-1',
            title: 'Student Shields & Certificates',
            amount: 35000.0,
            type: 'Expense',
            sponsorOrPayee: 'National Awards Co',
            notes: 'Laser engraved wooden shields',
          ),
        ],
        eventAudits: [
          PdfEventAuditItem(
            id: 'evt-aud-1',
            title: 'Annual Tech Olympiad 2026',
            description: 'Inter-collegiate coding competitions, algorithmic puzzles, and speed programming.',
            date: DateTime(2026, 9, 15),
            societyName: 'Computer Science Guild',
            pillar: 'Education',
            venue: 'Main University Auditorium',
            attendeesCount: 250,
            allocatedBudget: 50000.0,
            actualExpense: 42000.0,
            fiscalVariance: 8000.0,
            positiveImpactSummary: '250 students participated from 6 colleges in the Hazara division.',
            isCollaboration: true,
            collaboratorNames: 'HEC IT Directorate & ALLDOTDEV',
            speakers: [
              {
                'name': 'Dr. Tariq Shah',
                'designation': 'Chairman Computer Science',
                'organization': 'AUST',
              }
            ],
            imagePaths: ['assets/images/olympiad_1.jpg', 'assets/images/olympiad_2.jpg'],
          ),
        ],
      );

      final pdfBytes = await PdfDossierService.generateMonthlyDossier(dossierData);
      expect(pdfBytes, isNotEmpty);
      final magicHeader = String.fromCharCodes(pdfBytes.take(4));
      expect(magicHeader, equals('%PDF'));
    });

    test('Automated Archiving of the Monthly Audit Dossier: Intercepts PDF generation, encrypts via AES-256-GCM, tags as Monthly Audits, and writes structured metadata for societies and events', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const socId1 = 'soc-audit-1';
      const socId2 = 'soc-audit-2';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId1,
          name: 'Computer Science Guild',
          acronym: const drift.Value('CSG'),
          pillar: 'Education',
          facultyAdvisor: 'Dr. Tariq Shah',
        ),
      );
      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId2,
          name: 'Debating Society',
          acronym: const drift.Value('AUST-DS'),
          pillar: 'Engagement',
          facultyAdvisor: 'Prof. Usman',
        ),
      );

      // Add cabinet members
      await db.into(db.cabinetMembers).insert(
        CabinetMembersCompanion.insert(
          id: 'cab-1',
          societyId: socId1,
          tenureSession: '2025-2026',
          role: 'President',
          fullName: 'Muhammad Awais',
          cnic: '13101-5566778-1',
          email: 'awais@aust.edu.pk',
          phone: '0333-1122334',
          department: 'Computer Science',
          semester: 7,
        ),
      );

      // Add student members
      await db.into(db.societyMembers).insert(
        SocietyMembersCompanion.insert(
          id: 'stu-1',
          societyId: socId1,
          fullName: 'Kashif Mehmood',
          rollNo: 'FA21-BCS-089',
          cnic: '13101-9988112-7',
          department: 'Computer Science',
          semester: 4,
        ),
      );

      // Add concluded event
      const eventId = 'evt-audit-target';
      final now = DateTime.now();
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: eventId,
          title: 'AUST Tech Showcase 2026',
          description: 'Grand robotics and software exhibition.',
          eventDate: now.subtract(const Duration(days: 1)),
          societyId: const drift.Value(socId1),
          allocatedBudget: const drift.Value(60000.0),
          actualExpense: const drift.Value(55000.0),
          attendeesCount: const drift.Value(350),
          positiveImpactSummary: const drift.Value('350 attendees and 40 projects displayed.'),
        ),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(recordsDashboardProvider(db).notifier);

      // Trigger the Generate Dossier (PDF) function
      final pdfBytes = await notifier.generateMonthlyAuditDossier();
      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(4)), equals('%PDF'));

      // Check state hook
      final state = container.read(recordsDashboardProvider(db));
      expect(state.lastArchivedVaultDoc, isNotNull);
      expect(state.lastArchivedVaultDoc!.category, equals('Monthly Audits'));

      // Verify the record was inserted into the local SQLite Confidential Institutional Vault
      final vaultDocs = await (db.select(db.confidentialVault)
            ..where((tbl) => tbl.category.equals('Monthly Audits')))
          .get();
      expect(vaultDocs.length, equals(1));

      final vaultDoc = vaultDocs.first;
      expect(vaultDoc.category, equals('Monthly Audits'));
      expect(vaultDoc.title, contains('[Master Audit Dossier] Monthly Institutional Audit'));
      expect(vaultDoc.fileSizeBytes, equals(pdfBytes.length));
      expect(vaultDoc.encryptedFilePath.endsWith('.enc'), isTrue);

      // Verify AES-256-GCM encrypted file exists and decrypts to original PDF in-memory
      final encFile = File(vaultDoc.encryptedFilePath);
      expect(await encFile.exists(), isTrue);

      final decryptedBytes = await EncryptionService.decryptFileInMemory(
        encryptedFilePath: vaultDoc.encryptedFilePath,
        masterPassword: '1234',
      );
      expect(decryptedBytes, equals(pdfBytes));

      // Verify structured metadata for month/year, societies, and events
      expect(vaultDoc.metadataNotes, isNotNull);
      final metadata = MonthlyAuditVaultMetadata.parseFromNotes(vaultDoc.metadataNotes);
      expect(metadata, isNotNull);
      expect(metadata!.totalSocieties, equals(2));
      expect(metadata.coveredSocieties.any((s) => s.name == 'Computer Science Guild'), isTrue);
      expect(metadata.coveredSocieties.any((s) => s.name == 'Debating Society'), isTrue);
      expect(metadata.totalEvents, equals(1));
      expect(metadata.coveredEvents.first.title, equals('AUST Tech Showcase 2026'));
      expect(metadata.coveredEvents.first.attendeesCount, equals(350));

      // Clean up encrypted file
      if (await encFile.exists()) {
        await encFile.delete();
      }
      await db.close();
    });

    test('Automated Archiving: Re-generation updates existing audit record in vault and cleans up superseded ciphertext file', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(recordsDashboardProvider(db).notifier);

      // Generate first audit dossier
      final bytes1 = await notifier.generateMonthlyAuditDossier();
      expect(bytes1, isNotEmpty);
      final docs1 = await (db.select(db.confidentialVault)
            ..where((tbl) => tbl.category.equals('Monthly Audits')))
          .get();
      expect(docs1.length, equals(1));
      final firstPath = docs1.first.encryptedFilePath;
      expect(await File(firstPath).exists(), isTrue);

      // Re-generate dossier for the same period
      final bytes2 = await notifier.generateMonthlyAuditDossier();
      expect(bytes2, isNotEmpty);
      final docs2 = await (db.select(db.confidentialVault)
            ..where((tbl) => tbl.category.equals('Monthly Audits')))
          .get();
      // Should update the existing record rather than duplicating
      expect(docs2.length, equals(1));
      expect(docs2.first.id, equals(docs1.first.id));

      final secondPath = docs2.first.encryptedFilePath;
      // Second encrypted file exists
      expect(await File(secondPath).exists(), isTrue);

      // Clean up second encrypted file
      if (await File(secondPath).exists()) {
        await File(secondPath).delete();
      }
      await db.close();
    });

    test('Confidential Vault Integration: VaultFilterState includes Monthly Audits and filters correctly', () async {
      final db = AppDatabase(NativeDatabase.memory());

      expect(VaultFilterState.defaultStaticCategories.contains('Monthly Audits'), isTrue);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final vaultNotifier = container.read(vaultProvider(db).notifier);

      // Insert dummy vault documents with different categories
      await db.into(db.confidentialVault).insert(
        ConfidentialVaultCompanion.insert(
          id: 'v-1',
          category: 'Monthly Audits',
          title: '[Master Audit Dossier] Monthly Institutional Audit — September 2026',
          referenceNumber: const drift.Value('AUST/YDC/AUDIT/2026-09/01'),
          encryptedFilePath: 'dummy_audit.enc',
          fileChecksum: 'abcdef1234567890',
        ),
      );
      await db.into(db.confidentialVault).insert(
        ConfidentialVaultCompanion.insert(
          id: 'v-2',
          category: 'MOU',
          title: 'HEC Academic Collaboration MoU',
          referenceNumber: const drift.Value('AUST/YDC/MOU/2026/01'),
          encryptedFilePath: 'dummy_mou.enc',
          fileChecksum: '1234567890abcdef',
        ),
      );

      // Unlock and load
      vaultNotifier.unlock('1234');
      await vaultNotifier.loadVaultRecords();

      final unlockedState = container.read(vaultProvider(db));
      expect(unlockedState.vaultDocs.length, equals(2));

      // Filter by Monthly Audits
      vaultNotifier.selectCategory('Monthly Audits');
      final filteredState = container.read(vaultProvider(db));
      expect(filteredState.filteredDocs.length, equals(1));
      expect(filteredState.filteredDocs.first.category, equals('Monthly Audits'));
      expect(filteredState.filteredDocs.first.title, contains('Master Audit Dossier'));

      await db.close();
    });

    testWidgets('RecordsScreen: Generate Dossier (PDF) triggers automated archiving preview dialog with security badges', (tester) async {
      tester.view.physicalSize = const Size(1300, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = AppDatabase(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RecordsScreen(database: db),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the 'Generate Dossier (PDF)' button
      final generateBtn = find.text('Generate Dossier (PDF)');
      expect(generateBtn, findsOneWidget);
      await tester.tap(generateBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify the preview modal opens with enterprise vault security indicators
      expect(find.text('Master Institutional Monthly Audit Dossier — A4 Preview'), findsOneWidget);
      expect(find.text('AES-256-GCM Vault Auto-Archiving Active'), findsOneWidget);
      expect(find.text('Master Category: Monthly Audits'), findsOneWidget);

      await db.close();
    });

    testWidgets('Monthly Events Audit showcases individual Societies in UI and compiles grouped Section 3 in PDF', (tester) async {
      tester.view.physicalSize = const Size(1300, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = AppDatabase(NativeDatabase.memory());

      // 1. Seed multiple societies
      const socId1 = 'soc-acc-1';
      const socId2 = 'soc-csg-1';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId1,
          name: 'AUST Career Counseling',
          acronym: const drift.Value('ACC'),
          pillar: 'Employment',
          facultyAdvisor: 'Dr. Shahzad',
        ),
      );

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId2,
          name: 'Computer Science Guild',
          acronym: const drift.Value('CSG'),
          pillar: 'Education',
          facultyAdvisor: 'Dr. Tariq',
        ),
      );

      final now = DateTime.now();

      // 2. Insert events hosted by individual societies
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-acc-101',
          title: 'Resume Clinic & Corporate Career Fair 2026',
          description: 'CV evaluation and career mentorship by industry recruiters.',
          eventDate: now.subtract(const Duration(days: 4)),
          societyId: const drift.Value(socId1),
          allocatedBudget: const drift.Value(45000.0),
          actualExpense: const drift.Value(39000.0),
          attendeesCount: const drift.Value(210),
          positiveImpactSummary: const drift.Value('210 students received resume reviews.'),
        ),
      );

      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-csg-102',
          title: 'National Hackathon & Speed Coding Championship',
          description: '24-hour coding marathon on algorithmic problem solving.',
          eventDate: now.subtract(const Duration(days: 2)),
          societyId: const drift.Value(socId2),
          allocatedBudget: const drift.Value(80000.0),
          actualExpense: const drift.Value(72000.0),
          attendeesCount: const drift.Value(350),
          positiveImpactSummary: const drift.Value('350 competitive coders participated.'),
        ),
      );

      // 3. Pump RecordsScreen
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RecordsScreen(database: db),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 4. Verify UI: Events Count & Table
      expect(find.text('2 Events Logged'), findsOneWidget);
      expect(find.text('Resume Clinic & Corporate Career Fair 2026'), findsOneWidget);
      expect(find.text('National Hackathon & Speed Coding Championship'), findsOneWidget);

      // Verify Host Society column displays both society names and acronyms
      expect(find.text('AUST Career Counseling'), findsOneWidget);
      expect(find.text('ACC'), findsOneWidget);
      expect(find.text('Computer Science Guild'), findsOneWidget);
      expect(find.text('CSG'), findsOneWidget);

      // 5. Test Data Fetching & PDF Compilation
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(recordsDashboardProvider(db).notifier);

      final dossierData = await notifier.fetchAggregatedMonthlyAuditData();
      expect(dossierData.eventAudits.length, equals(2));

      final accAudit = dossierData.eventAudits.firstWhere((e) => e.societyId == socId1);
      expect(accAudit.societyName, contains('AUST Career Counseling'));
      expect(accAudit.allocatedBudget, equals(45000.0));
      expect(accAudit.actualExpense, equals(39000.0));
      expect(accAudit.fiscalVariance, equals(6000.0));

      final csgAudit = dossierData.eventAudits.firstWhere((e) => e.societyId == socId2);
      expect(csgAudit.societyName, contains('Computer Science Guild'));
      expect(csgAudit.allocatedBudget, equals(80000.0));
      expect(csgAudit.actualExpense, equals(72000.0));
      expect(csgAudit.fiscalVariance, equals(8000.0));

      // Generate PDF Dossier with grouped Section 3
      final pdfBytes = await PdfDossierService.generateMonthlyDossier(dossierData);
      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(4)), equals('%PDF'));

      await db.close();
    });
  });
}
