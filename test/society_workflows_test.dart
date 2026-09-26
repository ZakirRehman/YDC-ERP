import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:ydc_aust/core/database/app_database.dart';
import 'package:ydc_aust/core/services/ocr/sheet_parser.dart';
import 'package:ydc_aust/core/services/reporting/pdf_dossier_service.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ydc_aust/features/events/presentation/screens/events_screen.dart';
import 'package:ydc_aust/features/events/presentation/state/event_image_attachment_provider.dart';
import 'package:ydc_aust/features/events/presentation/widgets/event_detail_dialog.dart';
import 'package:ydc_aust/features/events/presentation/widgets/register_event_dialog.dart';
import 'package:ydc_aust/core/security/encryption_service.dart';
import 'package:ydc_aust/features/records/presentation/screens/records_screen.dart';
import 'package:ydc_aust/features/societies/presentation/screens/societies_screen.dart';
import 'package:ydc_aust/features/vault/presentation/screens/vault_screen.dart';
import 'package:ydc_aust/features/vault/presentation/state/vault_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Workflow Feature 1: Smart Data Routing during Ingestion Tests', () {
    test('ParsedStudentRecord correctly identifies executive roles vs standard students', () {
      final exec1 = ParsedStudentRecord(
        name: 'Hamza Ali',
        rollNo: 'FA21-BCS-001',
        cnic: '13101-1234567-1',
        department: 'Computer Science',
        role: 'President',
      );
      expect(exec1.isExecutive, isTrue);

      final exec2 = ParsedStudentRecord(
        name: 'Zahra Khan',
        rollNo: 'FA21-BSE-012',
        cnic: '13101-1234567-2',
        department: 'Software Engineering',
        role: 'Vice President',
      );
      expect(exec2.isExecutive, isTrue);

      final exec3 = ParsedStudentRecord(
        name: 'Bilal Ahmed',
        rollNo: 'SP22-BCS-090',
        cnic: '13101-1234567-3',
        department: 'Computer Science',
        role: 'General Secretary',
      );
      expect(exec3.isExecutive, isTrue);

      final exec4 = ParsedStudentRecord(
        name: 'Sarah Noor',
        rollNo: 'SP22-BIT-030',
        cnic: '13101-1234567-4',
        department: 'Information Technology',
        role: 'VP',
      );
      expect(exec4.isExecutive, isTrue);

      final standard1 = ParsedStudentRecord(
        name: 'Usman Tariq',
        rollNo: 'FA23-BCS-044',
        cnic: '13101-1234567-5',
        department: 'Computer Science',
        role: 'Member',
      );
      expect(standard1.isExecutive, isFalse);

      final standard2 = ParsedStudentRecord(
        name: 'Ayesha Bibi',
        rollNo: 'FA23-BBA-011',
        cnic: '13101-1234567-6',
        department: 'Management Sciences',
        role: '',
      );
      expect(standard2.isExecutive, isFalse);
    });

    test('OCR Stream parsing extracts executive roles from physical roster lines', () {
      const sampleOcr = '''
      Muhammad Ali      FA21-BCS-001    13101-4567891-3    0300-1234567    President
      Fatima Zahra      SP22-SE-019     13101-7894561-2    0312-9876543    General Secretary
      Kashif Mehmood    FA22-BCS-088    13101-9988776-5    0333-1122334
      ''';

      final records = SheetParser.parseRawOcrStream(sampleOcr);
      expect(records.length, equals(3));
      expect(records[0].role, equals('President'));
      expect(records[0].isExecutive, isTrue);
      expect(records[1].role, equals('General Secretary'));
      expect(records[1].isExecutive, isTrue);
      expect(records[2].role, isEmpty);
      expect(records[2].isExecutive, isFalse);
    });

    test('Database batch insertion correctly routes executive records to cabinetMembers and students to societyMembers', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const societyId = 'soc-test-123';

      // Insert dummy society
      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: societyId,
          name: 'Tech & AI Guild',
          pillar: 'Education',
          facultyAdvisor: 'Dr. Asif',
        ),
      );

      final records = [
        ParsedStudentRecord(
          name: 'Executive Lead',
          rollNo: 'FA21-BCS-001',
          cnic: '13101-1111111-1',
          department: 'Computer Science',
          role: 'President',
          phone: '0300-1111111',
        ),
        ParsedStudentRecord(
          name: 'General Member',
          rollNo: 'FA22-BCS-002',
          cnic: '13101-2222222-2',
          department: 'Computer Science',
          role: 'Member',
          phone: '0300-2222222',
        ),
      ];

      const uuid = Uuid();
      await db.batch((batch) {
        for (final r in records) {
          if (r.isExecutive) {
            batch.insert(
              db.cabinetMembers,
              CabinetMembersCompanion.insert(
                id: uuid.v4(),
                societyId: societyId,
                tenureSession: '2025-2026',
                role: r.role,
                fullName: r.name,
                cnic: r.cnic,
                email: 'student@aust.edu.pk',
                phone: r.phone,
                department: r.department,
                semester: r.semester,
              ),
            );
          } else {
            batch.insert(
              db.societyMembers,
              SocietyMembersCompanion.insert(
                id: uuid.v4(),
                societyId: societyId,
                fullName: r.name,
                rollNo: r.rollNo,
                cnic: r.cnic,
                department: r.department,
                semester: r.semester,
              ),
            );
          }
        }
      });

      final cabinet = await (db.select(db.cabinetMembers)..where((t) => t.societyId.equals(societyId))).get();
      final members = await (db.select(db.societyMembers)..where((t) => t.societyId.equals(societyId))).get();

      expect(cabinet.length, equals(1));
      expect(cabinet.first.fullName, equals('Executive Lead'));
      expect(cabinet.first.role, equals('President'));

      expect(members.length, equals(1));
      expect(members.first.fullName, equals('General Member'));
      expect(members.first.rollNo, equals('FA22-BCS-002'));

      await db.close();
    });
  });

  group('Workflow Feature 2: Edit Functionality for Society Records Tests', () {
    test('Can update student member full name, roll number, cnic, department, semester', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const societyId = 'soc-edit-test';
      const memberId = 'mem-edit-1';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: societyId,
          name: 'Green Society',
          pillar: 'Environment',
          facultyAdvisor: 'Dr. Maria',
        ),
      );

      await db.into(db.societyMembers).insert(
        SocietyMembersCompanion.insert(
          id: memberId,
          societyId: societyId,
          fullName: 'Original Name',
          rollNo: 'FA21-BCS-001',
          cnic: '13101-0000000-1',
          department: 'CS',
          semester: 1,
        ),
      );

      // Perform update
      await (db.update(db.societyMembers)..where((t) => t.id.equals(memberId))).write(
        const SocietyMembersCompanion(
          fullName: drift.Value('Updated Full Name'),
          rollNo: drift.Value('SP22-BCS-099'),
          cnic: drift.Value('13101-9999999-9'),
          department: drift.Value('Software Engineering'),
          semester: drift.Value(4),
        ),
      );

      final updated = await (db.select(db.societyMembers)..where((t) => t.id.equals(memberId))).getSingle();
      expect(updated.fullName, equals('Updated Full Name'));
      expect(updated.rollNo, equals('SP22-BCS-099'));
      expect(updated.cnic, equals('13101-9999999-9'));
      expect(updated.department, equals('Software Engineering'));
      expect(updated.semester, equals(4));

      await db.close();
    });

    test('Can update cabinet member office, name, cnic, department, semester', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const societyId = 'soc-cab-edit';
      const cabId = 'cab-1';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: societyId,
          name: 'Leadership Society',
          pillar: 'Engagement',
          facultyAdvisor: 'Prof. Tariq',
        ),
      );

      await db.into(db.cabinetMembers).insert(
        CabinetMembersCompanion.insert(
          id: cabId,
          societyId: societyId,
          tenureSession: '2025-2026',
          role: 'Coordinator',
          fullName: 'John Doe',
          cnic: '13101-1234567-0',
          email: 'johndoe@aust.edu.pk',
          phone: '0300-1234567',
          department: 'CS',
          semester: 2,
        ),
      );

      // Perform update
      await (db.update(db.cabinetMembers)..where((t) => t.id.equals(cabId))).write(
        const CabinetMembersCompanion(
          role: drift.Value('Vice President'),
          fullName: drift.Value('Johnathan Doe'),
          cnic: drift.Value('13101-7654321-0'),
          department: drift.Value('Management Sciences'),
          semester: drift.Value(5),
        ),
      );

      final updated = await (db.select(db.cabinetMembers)..where((t) => t.id.equals(cabId))).getSingle();
      expect(updated.role, equals('Vice President'));
      expect(updated.fullName, equals('Johnathan Doe'));
      expect(updated.cnic, equals('13101-7654321-0'));
      expect(updated.department, equals('Management Sciences'));
      expect(updated.semester, equals(5));

      await db.close();
    });
  });

  group('Workflow Feature 3: Society-Specific Dossier Generation Tests', () {
    test('generateSocietyDossier compiles valid A4 PDF with metadata, cabinet, and student roster', () async {
      final dossierData = PdfSocietyDossierData(
        societyName: 'Computer Science Guild',
        acronym: 'CSG',
        pillar: 'Education',
        facultyAdvisor: 'Dr. Muhammad Asif',
        monthYear: 'September 2026',
        cabinet: [
          PdfCabinetMemberItem(
            role: 'President',
            fullName: 'Ahmad Khan',
            cnic: '13101-1122334-5',
            department: 'Computer Science',
            semester: 7,
            phone: '0300-1122334',
          ),
          PdfCabinetMemberItem(
            role: 'General Secretary',
            fullName: 'Zainab Bibi',
            cnic: '13101-5566778-9',
            department: 'Software Engineering',
            semester: 5,
            phone: '0312-5566778',
          ),
        ],
        members: [
          PdfSocietyMemberItem(
            fullName: 'Ali Hassan',
            rollNo: 'FA22-BCS-010',
            cnic: '13101-9988776-1',
            department: 'Computer Science',
            semester: 4,
          ),
          PdfSocietyMemberItem(
            fullName: 'Maryam Tariq',
            rollNo: 'SP23-SE-042',
            cnic: '13101-4433221-8',
            department: 'Software Engineering',
            semester: 3,
          ),
        ],
        totalEvents: 3,
      );

      final pdfBytes = await PdfDossierService.generateSocietyDossier(dossierData);
      expect(pdfBytes, isNotEmpty);
      final magicHeader = String.fromCharCodes(pdfBytes.take(4));
      expect(magicHeader, equals('%PDF'));
    });
  });

  group('Workflow Feature 4: Society Event Posting, Relational Querying & Dashboard Integration Tests', () {
    test('Posting event links contextually to host society and persists to central database', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const societyId = 'soc-sports-club';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: societyId,
          name: 'AUST Sports Club',
          pillar: 'Engagement',
          facultyAdvisor: 'Coach Farhan',
        ),
      );

      final eventId = const Uuid().v4();
      final eventDate = DateTime.now().add(const Duration(days: 5));

      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: eventId,
          title: 'Annual Inter-Department Futsal Tournament',
          description: 'University championship tournament across 8 departments.',
          eventDate: eventDate,
          societyId: const drift.Value(societyId),
          isCollaboration: const drift.Value(false),
          venue: const drift.Value('University Sports Ground'),
          allocatedBudget: const drift.Value(75000.0),
          actualExpense: const drift.Value(63750.0),
          attendeesCount: const drift.Value(300),
          positiveImpactSummary: const drift.Value('Physical fitness and student engagement'),
        ),
      );

      // Verify central events table contains the record
      final allEvents = await db.select(db.events).get();
      expect(allEvents.length, equals(1));
      expect(allEvents.first.id, equals(eventId));
      expect(allEvents.first.title, equals('Annual Inter-Department Futsal Tournament'));
      expect(allEvents.first.societyId, equals(societyId));
      expect(allEvents.first.attendeesCount, equals(300));

      await db.close();
    });

    test('Relational querying retrieves both upcoming and past events for a specific society', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const soc1 = 'soc-tech';
      const soc2 = 'soc-arts';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: soc1,
          name: 'Tech Society',
          pillar: 'Education',
          facultyAdvisor: 'Dr. Tariq',
        ),
      );
      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: soc2,
          name: 'Arts Society',
          pillar: 'Engagement',
          facultyAdvisor: 'Ms. Hira',
        ),
      );

      final now = DateTime.now();

      // Insert Upcoming event for soc1
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-upcoming-1',
          title: 'AI & Robotics Bootcamp',
          description: 'Upcoming hands-on workshop.',
          eventDate: now.add(const Duration(days: 14)),
          societyId: const drift.Value(soc1),
        ),
      );

      // Insert Past event for soc1
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-past-1',
          title: 'Web Dev 101 Seminar',
          description: 'Past orientation session.',
          eventDate: now.subtract(const Duration(days: 30)),
          societyId: const drift.Value(soc1),
        ),
      );

      // Insert Event for soc2 (should not appear in soc1 queries)
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-other-soc',
          title: 'Spring Art Exhibition',
          description: 'Exhibition hosted by Arts Society.',
          eventDate: now.add(const Duration(days: 7)),
          societyId: const drift.Value(soc2),
        ),
      );

      // Relational Query for soc1
      final soc1Events = await (db.select(db.events)
            ..where((tbl) => tbl.societyId.equals(soc1))
            ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.eventDate)]))
          .get();

      expect(soc1Events.length, equals(2));
      expect(soc1Events[0].id, equals('evt-upcoming-1'));
      expect(soc1Events[0].eventDate.isAfter(now), isTrue); // Upcoming

      expect(soc1Events[1].id, equals('evt-past-1'));
      expect(soc1Events[1].eventDate.isBefore(now), isTrue); // Past

      // Relational Query for soc2
      final soc2Events = await (db.select(db.events)
            ..where((tbl) => tbl.societyId.equals(soc2)))
          .get();
      expect(soc2Events.length, equals(1));
      expect(soc2Events.first.title, equals('Spring Art Exhibition'));

      await db.close();
    });

    test('Deleting an event safely cascades speaker removal and updates relational state', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const societyId = 'soc-green';
      const eventId = 'evt-plant-drive';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: societyId,
          name: 'Green Earth Society',
          pillar: 'Environment',
          facultyAdvisor: 'Dr. Maria',
        ),
      );

      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: eventId,
          title: 'Campus Plantation Drive',
          description: 'Planting 1000 saplings.',
          eventDate: DateTime.now().add(const Duration(days: 3)),
          societyId: const drift.Value(societyId),
        ),
      );

      await db.into(db.eventSpeakers).insert(
        EventSpeakersCompanion.insert(
          id: 'speaker-1',
          eventId: eventId,
          name: 'Environmental Expert',
          organization: 'WWF Pakistan',
        ),
      );

      // Verify event and speaker exist
      expect((await db.select(db.events).get()).length, equals(1));
      expect((await db.select(db.eventSpeakers).get()).length, equals(1));

      // Perform deletion
      await (db.delete(db.eventSpeakers)..where((tbl) => tbl.eventId.equals(eventId))).go();
      await (db.delete(db.events)..where((tbl) => tbl.id.equals(eventId))).go();

      // Relational query returns empty
      final remainingSocEvents = await (db.select(db.events)
            ..where((tbl) => tbl.societyId.equals(societyId)))
          .get();
      expect(remainingSocEvents, isEmpty);
      expect(await db.select(db.eventSpeakers).get(), isEmpty);

      await db.close();
    });

    test('Can register multiple keynote speakers for an event and retrieve them', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const societyId = 'soc-ai-symposium';
      const eventId = 'evt-ai-summit-2026';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: societyId,
          name: 'AI Research Society',
          pillar: 'Education',
          facultyAdvisor: 'Dr. Usman',
        ),
      );

      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: eventId,
          title: 'National AI & Cloud Summit 2026',
          description: 'Industry keynote presentations and panel discussions.',
          eventDate: DateTime.now().add(const Duration(days: 10)),
          societyId: const drift.Value(societyId),
        ),
      );

      final speakers = [
        const SpeakerEntry(name: 'Dr. Johnathan Smith', organization: 'DeepMind UK'),
        const SpeakerEntry(name: 'Dr. Ayesha Malik', organization: 'NUST AI Lab'),
        const SpeakerEntry(name: 'Engr. Bilal Khan', organization: 'Google Cloud EMEA'),
      ];

      for (final spk in speakers) {
        await db.into(db.eventSpeakers).insert(
          EventSpeakersCompanion.insert(
            id: const Uuid().v4(),
            eventId: eventId,
            name: spk.name,
            organization: spk.organization,
          ),
        );
      }

      final savedSpeakers = await (db.select(db.eventSpeakers)
            ..where((tbl) => tbl.eventId.equals(eventId)))
          .get();

      expect(savedSpeakers.length, equals(3));
      expect(savedSpeakers.map((s) => s.name).toList(), containsAll([
        'Dr. Johnathan Smith',
        'Dr. Ayesha Malik',
        'Engr. Bilal Khan',
      ]));
      expect(savedSpeakers.map((s) => s.organization).toList(), containsAll([
        'DeepMind UK',
        'NUST AI Lab',
        'Google Cloud EMEA',
      ]));

      await db.close();
    });
  });

  group('Workflow Feature 5: Concluded Events Querying & Custom Cabinet Roles', () {
    test('getConcludedEventsForMonth correctly queries concluded events within target month and ignores future events', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const socId = 'soc-concluded-test';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'Innovation & Research Society',
          pillar: 'Education',
          facultyAdvisor: 'Dr. Zulfiqar',
        ),
      );

      final now = DateTime.now();
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      final futureDays = (lastDayOfMonth - now.day) >= 2 ? 2 : 1;
      final futureDate = (now.day < lastDayOfMonth) 
          ? now.add(Duration(days: futureDays))
          : DateTime(now.year, now.month, now.day, 23, 59, 0);

      // Past event in current month (executed/concluded)
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-past-concluded',
          title: 'Concluded Workshop',
          description: 'Executed workshop',
          eventDate: now.subtract(const Duration(days: 2)),
          societyId: const drift.Value(socId),
          allocatedBudget: const drift.Value(50000.0),
          actualExpense: const drift.Value(45000.0),
          attendeesCount: const drift.Value(120),
        ),
      );

      // Future event in current month (not concluded yet)
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-future-upcoming',
          title: 'Upcoming Hackathon',
          description: 'Upcoming hackathon',
          eventDate: futureDate,
          societyId: const drift.Value(socId),
          allocatedBudget: const drift.Value(80000.0),
          actualExpense: const drift.Value(0.0),
          attendeesCount: const drift.Value(200),
        ),
      );

      // Event in a different month
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-other-month',
          title: 'Last Year Conference',
          description: 'Past conference',
          eventDate: DateTime(now.year - 1, 1, 15),
          societyId: const drift.Value(socId),
          allocatedBudget: const drift.Value(100000.0),
          actualExpense: const drift.Value(90000.0),
          attendeesCount: const drift.Value(500),
        ),
      );

      // Query only concluded events for this month
      final concluded = await db.getConcludedEventsForMonth(targetMonth: now);
      expect(concluded.length, equals(1));
      expect(concluded.first.id, equals('evt-past-concluded'));
      expect(concluded.first.title, equals('Concluded Workshop'));
      expect(concluded.first.actualExpense, equals(45000.0));

      // Query all events for this month (including upcoming)
      final allThisMonth = await db.getConcludedEventsForMonth(targetMonth: now, includeOnlyConcluded: false);
      expect(allThisMonth.length, equals(2));
      expect(allThisMonth.map((e) => e.id), containsAll(['evt-past-concluded', 'evt-future-upcoming']));

      await db.close();
    });

    test('Cabinet members table accepts, stores, and updates arbitrary custom roles', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const socId = 'soc-custom-roles';
      const cabId = 'cab-custom-1';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'Aerospace & Robotics Society',
          pillar: 'Education',
          facultyAdvisor: 'Dr. Tariq',
        ),
      );

      // Insert custom role
      await db.into(db.cabinetMembers).insert(
        CabinetMembersCompanion.insert(
          id: cabId,
          societyId: socId,
          tenureSession: '2025-2026',
          role: 'Chief Avionics Engineer',
          fullName: 'Ali Raza',
          cnic: '13101-1122334-5',
          email: 'ali.raza@aust.edu.pk',
          phone: '0300-9876543',
          department: 'Electrical Engineering',
          semester: 6,
        ),
      );

      final inserted = await (db.select(db.cabinetMembers)..where((t) => t.id.equals(cabId))).getSingle();
      expect(inserted.role, equals('Chief Avionics Engineer'));
      expect(inserted.fullName, equals('Ali Raza'));

      // Update to another custom role
      await (db.update(db.cabinetMembers)..where((t) => t.id.equals(cabId))).write(
        const CabinetMembersCompanion(
          role: drift.Value('Director of UAV Operations'),
        ),
      );

      final updated = await (db.select(db.cabinetMembers)..where((t) => t.id.equals(cabId))).getSingle();
      expect(updated.role, equals('Director of UAV Operations'));

      await db.close();
    });

    testWidgets('Add Cabinet Member modal displays Custom Role Title field when Other option is selected', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = AppDatabase(NativeDatabase.memory());
      const socId = 'soc-modal-test';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'Robotics & Automation Society',
          pillar: 'Education',
          facultyAdvisor: 'Dr. Tariq',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocietiesScreen(
              database: db,
              onTriggerIngestion: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Add Cabinet Member dialog via empty state button
      final addCabBtn = find.text('Assign Cabinet Office');
      expect(addCabBtn, findsOneWidget);
      await tester.tap(addCabBtn);
      await tester.pumpAndSettle();

      // Dialog is open: verify initial standard role dropdown is present
      expect(find.text('Add Cabinet Member — Robotics & Automation Society'), findsOneWidget);
      expect(find.text('Custom Role Title'), findsNothing);

      // Select 'Other (Specify Custom Role)'
      final dropdown = find.byType(DropdownButtonFormField<String>).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final otherOption = find.text('Other (Specify Custom Role)').last;
      await tester.tap(otherOption);
      await tester.pumpAndSettle();

      // Verify "Custom Role Title" field is now rendered
      expect(find.text('Custom Role Title'), findsOneWidget);

      await db.close();
    });
  });

  group('Workflow Feature 6: Event Image Attachments, Unified Roster & Master Dossier PDF', () {
    test('Database UNION ALL query getUnifiedInstitutionalRoster retrieves both students and cabinet members', () async {
      final db = AppDatabase(NativeDatabase.memory());
      const socId = 'soc-unified-test';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'Cyber Security Society',
          pillar: 'Education',
          facultyAdvisor: 'Dr. Zulfiqar',
        ),
      );

      // Insert standard student
      await db.into(db.societyMembers).insert(
        SocietyMembersCompanion.insert(
          id: 'stu-1',
          societyId: socId,
          fullName: 'Daniyal Ahmed',
          rollNo: 'FA22-BCS-055',
          cnic: '13101-1111111-1',
          department: 'Computer Science',
          semester: 4,
        ),
      );

      // Insert cabinet officer
      await db.into(db.cabinetMembers).insert(
        CabinetMembersCompanion.insert(
          id: 'cab-1',
          societyId: socId,
          tenureSession: '2025-2026',
          role: 'President',
          fullName: 'Mariam Tariq',
          cnic: '13101-2222222-2',
          email: 'mariam@aust.edu.pk',
          phone: '0300-2222222',
          department: 'Computer Science',
          semester: 6,
        ),
      );

      final unifiedRoster = await db.getUnifiedInstitutionalRoster();
      expect(unifiedRoster.length, equals(2));

      final studentRec = unifiedRoster.firstWhere((r) => !r.isExecutive);
      expect(studentRec.fullName, equals('Daniyal Ahmed'));
      expect(studentRec.role, equals('Student'));
      expect(studentRec.identifier, equals('FA22-BCS-055'));
      expect(studentRec.isExecutive, isFalse);

      final cabRec = unifiedRoster.firstWhere((r) => r.isExecutive);
      expect(cabRec.fullName, equals('Mariam Tariq'));
      expect(cabRec.role, equals('President'));
      expect(cabRec.isExecutive, isTrue);

      await db.close();
    });

    testWidgets('RecordsScreen displays unified records with Role badges distinguishing Student vs Cabinet', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = AppDatabase(NativeDatabase.memory());
      const socId = 'soc-ui-test';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'Green Society',
          pillar: 'Environment',
          facultyAdvisor: 'Dr. Naeem',
        ),
      );

      await db.into(db.societyMembers).insert(
        SocietyMembersCompanion.insert(
          id: 'stu-ui-1',
          societyId: socId,
          fullName: 'Ahsan Khan',
          rollNo: 'FA23-ENV-010',
          cnic: '13101-3333333-3',
          department: 'Environmental Sciences',
          semester: 2,
        ),
      );

      await db.into(db.cabinetMembers).insert(
        CabinetMembersCompanion.insert(
          id: 'cab-ui-1',
          societyId: socId,
          tenureSession: '2025-2026',
          role: 'General Secretary',
          fullName: 'Kiran Shah',
          cnic: '13101-4444444-4',
          email: 'kiran@aust.edu.pk',
          phone: '0300-4444444',
          department: 'Environmental Sciences',
          semester: 6,
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

      // Verify header reflects both students and cabinet
      expect(find.text('2 institutional members (1 enrolled students, 1 cabinet officers) across 1 societies.'), findsOneWidget);

      // Verify table rows
      expect(find.text('Ahsan Khan'), findsOneWidget);
      expect(find.text('Kiran Shah'), findsOneWidget);

      // Verify Role badges
      expect(find.text('General Secretary'), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);

      await db.close();
    });

    test('PdfDossierService compiles master monthly dossier including financial ledger, concluded events, and unified roster', () async {
      final dossierData = PdfDossierData(
        monthYear: 'October 2026',
        totalSocieties: 4,
        totalMembers: 45,
        totalEvents: 6,
        totalAttendees: 350,
        totalBudgetSpent: 120000,
        totalSponsorships: 180000,
        pillarDistribution: {
          'Education': 2,
          'Employment': 1,
          'Engagement': 1,
          'Environment': 0,
        },
        achievements: [
          {'title': 'National AI Hackathon Top 3', 'description': 'Students achieved national recognition.'},
        ],
        financialItems: [
          {
            'title': 'Hackathon Venue & Cloud Server Costs',
            'amount': 45000.0,
            'type': 'Expense',
            'sponsorName': 'Tech Grant',
            'notes': 'AWS credits included',
          },
          {
            'title': 'Corporate Seed Sponsorship',
            'amount': 100000.0,
            'type': 'Sponsorship',
            'sponsorName': 'HBL Tech Fund',
            'notes': 'Disbursed',
          },
        ],
        concludedEvents: [
          PdfConcludedEventItem(
            title: 'Annual Tech Symposium',
            date: DateTime(2026, 10, 15),
            hostSociety: 'Tech & AI Guild (Education)',
            attendeesCount: 200,
            allocatedBudget: 50000,
            actualExpense: 48000,
          ),
        ],
        unifiedRoster: [
          PdfUnifiedRosterItem(
            fullName: 'Zainab Bibi',
            role: 'President',
            identifier: 'Executive',
            societyName: 'Tech & AI Guild',
            pillar: 'Education',
            department: 'Computer Science',
            semester: 7,
            isExecutive: true,
          ),
          PdfUnifiedRosterItem(
            fullName: 'Farhan Akhtar',
            role: 'Student',
            identifier: 'FA23-BCS-101',
            societyName: 'Tech & AI Guild',
            pillar: 'Education',
            department: 'Computer Science',
            semester: 3,
            isExecutive: false,
          ),
        ],
      );

      final pdfBytes = await PdfDossierService.generateMonthlyDossier(dossierData);
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(1000));
    });

    testWidgets('RegisterEventDialog renders dashed border image upload widget and allows selecting image', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = AppDatabase(NativeDatabase.memory());
      const socId = 'soc-img-test';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'Media Club',
          pillar: 'Engagement',
          facultyAdvisor: 'Dr. Waqas',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ProviderScope(
                        child: RegisterEventDialog(
                          database: db,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Event Dialog'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Event Dialog'));
      await tester.pumpAndSettle();

      // Verify image attachment widget is present
      expect(find.text('Attach Cover Image or Promotional Banner'), findsOneWidget);
      expect(find.text('PNG, JPG, WEBP • Click to browse local desktop files'), findsOneWidget);

      await db.close();
    });
  });

  group('Workflow Feature 7: Multi-Image Event Galleries & Interactive Detail Views', () {
    test('Event entity decodes multi-image JSON array and gracefully falls back to bannerImagePath', () {
      final now = DateTime.now();

      // Case 1: JSON array with 3 images
      final eventWithThree = Event(
        id: 'evt-gallery-3',
        title: 'Tech Fest 2026',
        description: 'Multi-image event',
        eventDate: now,
        isCollaboration: false,
        allocatedBudget: 50000,
        actualExpense: 48000,
        attendeesCount: 200,
        createdAt: now,
        imagePaths: jsonEncode(['banner1.png', 'banner2.png', 'banner3.png']),
        bannerImagePath: 'banner1.png',
      );
      expect(eventWithThree.galleryImages.length, equals(3));
      expect(eventWithThree.galleryImages, equals(['banner1.png', 'banner2.png', 'banner3.png']));
      expect(eventWithThree.primaryImage, equals('banner1.png'));
      expect(eventWithThree.hasMultipleImages, isTrue);

      // Case 2: Legacy single bannerImagePath fallback
      final legacyEvent = Event(
        id: 'evt-legacy',
        title: 'Legacy Event',
        description: 'Single image event',
        eventDate: now,
        isCollaboration: false,
        allocatedBudget: 20000,
        actualExpense: 15000,
        attendeesCount: 100,
        createdAt: now,
        bannerImagePath: 'legacy_single.jpg',
      );
      expect(legacyEvent.galleryImages.length, equals(1));
      expect(legacyEvent.galleryImages, equals(['legacy_single.jpg']));
      expect(legacyEvent.primaryImage, equals('legacy_single.jpg'));
      expect(legacyEvent.hasMultipleImages, isFalse);

      // Case 3: Empty images
      final noImageEvent = Event(
        id: 'evt-no-img',
        title: 'No Image Event',
        description: 'No media attached',
        eventDate: now,
        isCollaboration: false,
        allocatedBudget: 10000,
        actualExpense: 8000,
        attendeesCount: 50,
        createdAt: now,
      );
      expect(noImageEvent.galleryImages, isEmpty);
      expect(noImageEvent.primaryImage, isNull);
      expect(noImageEvent.hasMultipleImages, isFalse);
    });

    test('SQLite Events table successfully stores and retrieves JSON-encoded image_paths', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.now();
      const socId = 'soc-media-gallery';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'Photography Club',
          pillar: 'Engagement',
          facultyAdvisor: 'Prof. Tariq',
        ),
      );

      final images = ['C:/photos/gallery_1.jpg', 'C:/photos/gallery_2.jpg', 'C:/photos/gallery_3.jpg'];
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-sqlite-gallery',
          title: 'Annual Photo Exhibition',
          description: 'Showcasing campus student photography',
          eventDate: now,
          societyId: const drift.Value(socId),
          bannerImagePath: drift.Value(images.first),
          imagePaths: drift.Value(jsonEncode(images)),
          allocatedBudget: const drift.Value(60000.0),
          actualExpense: const drift.Value(55000.0),
          attendeesCount: const drift.Value(320),
        ),
      );

      final queried = await (db.select(db.events)..where((t) => t.id.equals('evt-sqlite-gallery'))).getSingle();
      expect(queried.imagePaths, equals(jsonEncode(images)));
      expect(queried.galleryImages, equals(images));
      expect(queried.primaryImage, equals('C:/photos/gallery_1.jpg'));
      expect(queried.hasMultipleImages, isTrue);

      await db.close();
    });

    test('EventImageAttachmentNotifier caps selection at 3 images and manages removal', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(eventImageAttachmentProvider.notifier);
      final initial = container.read(eventImageAttachmentProvider);
      expect(initial.imagePaths, isEmpty);
      expect(initial.canAddMore, isTrue);

      // Use backward compatibility helper
      notifier.setImagePath('test_img_1.png');
      expect(container.read(eventImageAttachmentProvider).imagePaths, equals(['test_img_1.png']));
      expect(container.read(eventImageAttachmentProvider).imagePath, equals('test_img_1.png'));

      // Remove at index
      notifier.removeImageAt(0);
      expect(container.read(eventImageAttachmentProvider).imagePaths, isEmpty);
      expect(container.read(eventImageAttachmentProvider).imagePath, isNull);

      // Clear all
      notifier.setImagePath('img_a.png');
      notifier.clearImages();
      expect(container.read(eventImageAttachmentProvider).imagePaths, isEmpty);
    });

    testWidgets('EventDetailDialog displays PageView gallery, metrics grid, and detailed narrative', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final now = DateTime.now();
      final mockEvent = Event(
        id: 'evt-detail-test',
        title: 'Autonomous AI Workshop',
        description: 'A deep-dive workshop on generative AI agents and stateful LLM systems for enterprise applications.',
        eventDate: now,
        isCollaboration: false,
        venue: 'Main Seminar Hall 3',
        allocatedBudget: 120000,
        actualExpense: 110000,
        attendeesCount: 185,
        positiveImpactSummary: 'Students built live interactive autonomous agents.',
        imagePaths: jsonEncode(['assets/images/banner1.png', 'assets/images/banner2.png']),
        bannerImagePath: 'assets/images/banner1.png',
        createdAt: now,
      );

      final mockSociety = Society(
        id: 'soc-ai',
        name: 'AI & Data Science Society',
        pillar: 'Education',
        facultyAdvisor: 'Dr. Zulfiqar',
        isActive: true,
        createdAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  EventDetailDialog.show(
                    context,
                    event: mockEvent,
                    society: mockSociety,
                    speakers: [
                      EventSpeaker(
                        id: 'spk-1',
                        eventId: mockEvent.id,
                        name: 'Dr. Jane Doe',
                        designation: 'Staff Research Scientist',
                        organization: 'Google DeepMind',
                      ),
                    ],
                  );
                },
                child: const Text('Open Event Detail'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Event Detail'));
      await tester.pumpAndSettle();

      // Verify Event details
      expect(find.text('Autonomous AI Workshop'), findsOneWidget);
      expect(find.text('AI & Data Science Society (Education)'), findsOneWidget);
      expect(find.text('Main Seminar Hall 3'), findsOneWidget);
      expect(find.text('A deep-dive workshop on generative AI agents and stateful LLM systems for enterprise applications.'), findsOneWidget);
      expect(find.text('Students built live interactive autonomous agents.'), findsOneWidget);

      // Verify Metrics grid
      expect(find.text('Allocated Budget'), findsOneWidget);
      expect(find.text('Actual Expenditure'), findsOneWidget);
      expect(find.text('Attendees'), findsOneWidget);
      expect(find.text('Fiscal Variance'), findsOneWidget);

      // Verify Guest Speaker
      expect(find.text('Dr. Jane Doe'), findsOneWidget);
      expect(find.text('Staff Research Scientist • Google DeepMind'), findsOneWidget);

      // Verify PageView Gallery counter
      expect(find.text('1 / 2'), findsOneWidget);
    });

    testWidgets('EventsScreen card is fully clickable and opens EventDetailDialog', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = AppDatabase(NativeDatabase.memory());
      const socId = 'soc-events-card-test';
      final now = DateTime.now();

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'Robotics Society',
          pillar: 'Employment',
          facultyAdvisor: 'Dr. Farooq',
        ),
      );

      final imgs = ['assets/banner_a.jpg', 'assets/banner_b.jpg'];
      await db.into(db.events).insert(
        EventsCompanion.insert(
          id: 'evt-card-click-test',
          title: 'RoboWars Championship',
          description: 'Annual competitive robotics championship.',
          eventDate: now,
          venue: const drift.Value('Robotics Arena'),
          societyId: const drift.Value(socId),
          allocatedBudget: const drift.Value(75000.0),
          actualExpense: const drift.Value(70000.0),
          attendeesCount: const drift.Value(300),
          imagePaths: drift.Value(jsonEncode(imgs)),
          bannerImagePath: drift.Value(imgs.first),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EventsScreen(database: db),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify event title is displayed in card
      expect(find.text('RoboWars Championship'), findsOneWidget);
      expect(find.text('2 Photos'), findsOneWidget);

      // Tap on the card
      await tester.tap(find.text('RoboWars Championship'));
      await tester.pumpAndSettle();

      // Verify EventDetailDialog has opened
      expect(find.byType(EventDetailDialog), findsOneWidget);
      expect(find.text('Executive & Financial Audit Metrics'), findsOneWidget);

      await db.close();
    });
  });

  group('Workflow Feature 8: Dynamic Vault Categories & Automated Archiving Tests', () {
    test('VaultFilterState dynamicCategories appends active societies and isolates digital workspaces', () async {
      final db = AppDatabase(NativeDatabase.memory());

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: 'soc-ydc-vault',
          name: 'Youth Development Club',
          acronym: const drift.Value('YDC'),
          pillar: 'Leadership',
          facultyAdvisor: 'Dr. Ahmad',
        ),
      );

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: 'soc-robotics-vault',
          name: 'Robotics Society',
          pillar: 'Employment',
          facultyAdvisor: 'Dr. Farooq',
        ),
      );

      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await container.read(vaultProvider(db).notifier).loadSocieties();
      final state = container.read(vaultProvider(db));

      expect(state.dynamicCategories, containsAll(['All', 'MOU', 'Contract', 'PMYP', 'Internee_Record', 'Audit', 'YDC', 'Robotics Society']));

      // Ingest 2 vault records: one for YDC society and one general MOU
      await db.into(db.confidentialVault).insert(
        ConfidentialVaultCompanion.insert(
          id: 'doc-ydc-1',
          societyId: const drift.Value('soc-ydc-vault'),
          category: 'YDC',
          title: 'YDC Constitution & Charter 2026',
          encryptedFilePath: 'dummy_ydc.enc',
          fileChecksum: 'abc123ydc',
        ),
      );

      await db.into(db.confidentialVault).insert(
        ConfidentialVaultCompanion.insert(
          id: 'doc-mou-1',
          category: 'MOU',
          title: 'Institutional Partnership MoU',
          encryptedFilePath: 'dummy_mou.enc',
          fileChecksum: 'abc123mou',
        ),
      );

      // Unlock vault to query and filter records
      container.read(vaultProvider(db).notifier).unlock('1234');
      await container.read(vaultProvider(db).notifier).loadVaultRecords();

      // All category returns both
      expect(container.read(vaultProvider(db)).filteredDocs.length, equals(2));

      // Filter by YDC society workspace
      container.read(vaultProvider(db).notifier).setCategory('YDC');
      final ydcFiltered = container.read(vaultProvider(db)).filteredDocs;
      expect(ydcFiltered.length, equals(1));
      expect(ydcFiltered.first.title, equals('YDC Constitution & Charter 2026'));
      expect(ydcFiltered.first.societyId, equals('soc-ydc-vault'));

      // Filter by MOU
      container.read(vaultProvider(db).notifier).setCategory('MOU');
      final mouFiltered = container.read(vaultProvider(db)).filteredDocs;
      expect(mouFiltered.length, equals(1));
      expect(mouFiltered.first.title, equals('Institutional Partnership MoU'));
      expect(mouFiltered.first.societyId, isNull);

      // Search query filtering
      container.read(vaultProvider(db).notifier).setCategory('All');
      container.read(vaultProvider(db).notifier).setSearchQuery('Constitution');
      final searchFiltered = container.read(vaultProvider(db)).filteredDocs;
      expect(searchFiltered.length, equals(1));
      expect(searchFiltered.first.title, contains('Constitution'));

      await db.close();
    });

    test('Automated Event Archiving creates AES-256 encrypted PDF and seals record in vault', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.now();

      final society = Society(
        id: 'soc-cyber-vault',
        name: 'Cyber Security Society',
        acronym: 'CSS',
        pillar: 'Education',
        facultyAdvisor: 'Engr. Tariq',
        isActive: true,
        createdAt: now,
      );

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: society.id,
          name: society.name,
          acronym: drift.Value(society.acronym),
          pillar: society.pillar,
          facultyAdvisor: society.facultyAdvisor,
        ),
      );

      final event = Event(
        id: 'evt-cyber-01',
        title: 'Network Defense & Ethical Hacking Bootcamp',
        description: 'Hands-on training on network vulnerability assessments and ethical intrusion counter-measures.',
        eventDate: now,
        isCollaboration: false,
        venue: 'CS Lab 4',
        allocatedBudget: 50000,
        actualExpense: 48000,
        attendeesCount: 95,
        positiveImpactSummary: '95 undergraduate engineers mastered packet sniffing and firewall configuration.',
        createdAt: now,
      );

      final speaker = EventSpeaker(
        id: 'spk-cyber-01',
        eventId: event.id,
        name: 'Col. Farhan Asif',
        designation: 'Cyber Defense Consultant',
        organization: 'National CERT',
      );

      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final record = await container.read(vaultProvider(db).notifier).archiveEvent(
        event: event,
        society: society,
        speakers: [speaker],
      );

      // Verify vault metadata
      expect(record.societyId, equals(society.id));
      expect(record.category, equals('CSS'));
      expect(record.title, contains('Network Defense & Ethical Hacking Bootcamp'));
      expect(record.originalFileName, contains('Network_Defense'));
      expect(record.fileChecksum, isNotEmpty);
      expect(record.encryptedFilePath.endsWith('.enc'), isTrue);

      // Verify file was written to disk and is encrypted
      final encFile = File(record.encryptedFilePath);
      expect(encFile.existsSync(), isTrue);

      // Decrypt in-memory and confirm valid PDF header (%PDF)
      final decryptedBytes = await EncryptionService.decryptFileInMemory(
        encryptedFilePath: record.encryptedFilePath,
        masterPassword: '1234',
      );
      expect(decryptedBytes, isNotEmpty);
      final pdfHeader = String.fromCharCodes(decryptedBytes.take(4));
      expect(pdfHeader, equals('%PDF'));

      // Verify row exists in SQLite table
      final storedDocs = await (db.select(db.confidentialVault)..where((tbl) => tbl.id.equals(record.id))).get();
      expect(storedDocs.length, equals(1));
      expect(storedDocs.first.societyId, equals(society.id));
      expect(storedDocs.first.category, equals('CSS'));

      // Clean up physical file
      if (encFile.existsSync()) {
        encFile.deleteSync();
      }

      await db.close();
    });

    test('Automated Roster Archiving stores sealed dossier PDF in society vault category', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.now();

      final society = Society(
        id: 'soc-lit-vault',
        name: 'Literary & Debating Club',
        acronym: 'LDC',
        pillar: 'Leadership',
        facultyAdvisor: 'Prof. Maryam',
        isActive: true,
        createdAt: now,
      );

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: society.id,
          name: society.name,
          acronym: drift.Value(society.acronym),
          pillar: society.pillar,
          facultyAdvisor: society.facultyAdvisor,
        ),
      );

      final dummyDossierBytes = Uint8List.fromList(utf8.encode('%PDF-1.4 Official Finalized Cabinet & Member Roster for LDC'));

      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final record = await container.read(vaultProvider(db).notifier).archiveFinalizedRoster(
        society: society,
        pdfBytes: dummyDossierBytes,
        sessionYear: '2026',
      );

      expect(record.societyId, equals(society.id));
      expect(record.category, equals('LDC'));
      expect(record.title, contains('Finalized Cabinet & Member Roster'));
      expect(record.title, contains('Literary & Debating Club'));
      expect(record.fileSizeBytes, equals(dummyDossierBytes.length));

      // Decrypt in-memory to confirm payload integrity
      final decrypted = await EncryptionService.decryptFileInMemory(
        encryptedFilePath: record.encryptedFilePath,
        masterPassword: '1234',
      );
      expect(utf8.decode(decrypted), equals('%PDF-1.4 Official Finalized Cabinet & Member Roster for LDC'));

      // Clean up physical file
      final encFile = File(record.encryptedFilePath);
      if (encFile.existsSync()) {
        encFile.deleteSync();
      }

      await db.close();
    });

    testWidgets('VaultScreen widget renders dynamic society filter chips and unlocks with master PIN', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = AppDatabase(NativeDatabase.memory());
      const socId = 'soc-ieee-vault';

      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: socId,
          name: 'IEEE Student Branch',
          acronym: const drift.Value('IEEE'),
          pillar: 'Technology',
          facultyAdvisor: 'Dr. Shah',
        ),
      );

      await db.into(db.confidentialVault).insert(
        ConfidentialVaultCompanion.insert(
          id: 'doc-ieee-bylaws',
          societyId: const drift.Value(socId),
          category: 'IEEE',
          title: 'IEEE Chapter Operating Bylaws',
          encryptedFilePath: 'dummy_ieee.enc',
          fileChecksum: 'sha256_ieee',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VaultScreen(database: db),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check PIN lock screen UI
      expect(find.text('CONFIDENTIAL INSTITUTIONAL VAULT'), findsOneWidget);
      expect(find.text('Unlock Institutional Vault'), findsOneWidget);

      // Enter Master PIN '1234'
      final pinField = find.byType(TextField);
      expect(pinField, findsOneWidget);
      await tester.enterText(pinField, '1234');
      await tester.pumpAndSettle();

      // Tap Unlock button
      await tester.tap(find.text('Unlock Institutional Vault'));
      await tester.pumpAndSettle();

      // Verify Vault screen unlocked
      expect(find.text('Confidential Institutional Vault'), findsOneWidget);
      expect(find.text('IEEE Chapter Operating Bylaws'), findsOneWidget);

      // Verify dynamic society category chip 'IEEE' is present
      expect(find.text('IEEE'), findsWidgets);

      // Verify society indicator badge in the document card
      expect(find.text('IEEE Chapter Operating Bylaws'), findsOneWidget);

      // Tap Lock Vault to test locking
      await tester.tap(find.text('Lock Vault'));
      await tester.pumpAndSettle();

      // Verify returned to PIN screen
      expect(find.text('CONFIDENTIAL INSTITUTIONAL VAULT'), findsOneWidget);

      await db.close();
    });
  });
}
