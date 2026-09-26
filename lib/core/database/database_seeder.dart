import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../security/encryption_service.dart';
import 'app_database.dart';

class DatabaseSeeder {
  DatabaseSeeder._();

  static Future<void> seedIfEmpty(AppDatabase db) async {
    final existingSocieties = await db.select(db.societies).get();
    if (existingSocieties.isNotEmpty) {
      return; // Already initialized
    }

    const uuid = Uuid();

    // 1. Seed Societies across 4 Pillars
    final societiesData = [
      {
        'id': 'soc-env-1',
        'name': 'Green Campus & Eco-Protection Society',
        'acronym': 'GCEPS',
        'pillar': 'Environment',
        'advisor': 'Dr. Muhammad Asif (Earth Sciences)',
      },
      {
        'id': 'soc-edu-1',
        'name': 'Computer Science & Tech Innovation Guild',
        'acronym': 'CSTIG',
        'pillar': 'Education',
        'advisor': 'Dr. Tariq Shah (Computer Science)',
      },
      {
        'id': 'soc-emp-1',
        'name': 'Youth Career Linkages & PMYP Fellowship Club',
        'acronym': 'YCL-PMYP',
        'pillar': 'Employment',
        'advisor': 'Prof. Noman Qureshi (Management Sciences)',
      },
      {
        'id': 'soc-eng-1',
        'name': 'AUST Sports & Campus Engagement Guild',
        'acronym': 'ASAG',
        'pillar': 'Engagement',
        'advisor': 'Mr. Waqas Khan (Physical Education)',
      },
      {
        'id': 'soc-edu-2',
        'name': 'Literary, Debating & Public Speaking Forum',
        'acronym': 'LDPSF',
        'pillar': 'Education',
        'advisor': 'Dr. Saima Bibi (English Dept)',
      },
      {
        'id': 'soc-eng-2',
        'name': 'Media, Photography & Digital Arts Society',
        'acronym': 'MPDAS',
        'pillar': 'Engagement',
        'advisor': 'Mr. Bilal Raza (Media Directorate)',
      },
    ];

    for (final s in societiesData) {
      await db.into(db.societies).insert(
        SocietiesCompanion.insert(
          id: s['id']!,
          name: s['name']!,
          acronym: Value(s['acronym']),
          pillar: s['pillar']!,
          facultyAdvisor: s['advisor']!,
          isActive: const Value(true),
          createdAt: Value(DateTime.now().subtract(const Duration(days: 120))),
        ),
      );
    }

    // 2. Seed Cabinet Members (Active Tenure 2025-2026)
    final cabinetRoles = [
      {
        'socId': 'soc-env-1',
        'role': 'President',
        'name': 'Zainab Bibi',
        'cnic': '13101-1456782-4',
        'email': 'zainab.env@aust.edu.pk',
        'phone': '0301-4455667',
        'dept': 'Earth & Environmental Sciences',
        'sem': 7,
      },
      {
        'socId': 'soc-env-1',
        'role': 'General Secretary',
        'name': 'Hamza Tanveer',
        'cnic': '13101-9874561-3',
        'email': 'hamza.tanveer@aust.edu.pk',
        'phone': '0312-3344556',
        'dept': 'Civil Engineering',
        'sem': 5,
      },
      {
        'socId': 'soc-edu-1',
        'role': 'President',
        'name': 'Muhammad Awais',
        'cnic': '13101-5566778-1',
        'email': 'awais.cs@aust.edu.pk',
        'phone': '0333-8899001',
        'dept': 'Computer Science',
        'sem': 7,
      },
      {
        'socId': 'soc-edu-1',
        'role': 'Vice President',
        'name': 'Areeba Noor',
        'cnic': '13101-2233445-6',
        'email': 'areeba.se@aust.edu.pk',
        'phone': '0345-1122334',
        'dept': 'Software Engineering',
        'sem': 5,
      },
      {
        'socId': 'soc-emp-1',
        'role': 'President',
        'name': 'Shahzeb Malik',
        'cnic': '13101-7788990-2',
        'email': 'shahzeb.mgmt@aust.edu.pk',
        'phone': '0321-9988776',
        'dept': 'Management Sciences',
        'sem': 8,
      },
      {
        'socId': 'soc-eng-1',
        'role': 'President',
        'name': 'Danyal Abbasi',
        'cnic': '13101-3322110-9',
        'email': 'danyal.sports@aust.edu.pk',
        'phone': '0315-7766554',
        'dept': 'Electrical Engineering',
        'sem': 6,
      },
    ];

    for (final c in cabinetRoles) {
      await db.into(db.cabinetMembers).insert(
        CabinetMembersCompanion.insert(
          id: uuid.v4(),
          societyId: c['socId'] as String,
          tenureSession: '2025-2026',
          role: c['role'] as String,
          fullName: c['name'] as String,
          cnic: c['cnic'] as String,
          email: c['email'] as String,
          phone: c['phone'] as String,
          department: c['dept'] as String,
          semester: c['sem'] as int,
          isActive: const Value(true),
        ),
      );
    }

    // 3. Seed Sample Society Members
    final sampleMembers = [
      {'socId': 'soc-env-1', 'name': 'Adnan Tariq', 'roll': 'FA21-ENV-012', 'cnic': '13101-4433221-5', 'dept': 'Earth Sciences'},
      {'socId': 'soc-env-1', 'name': 'Sara Jadoon', 'roll': 'SP22-ENV-008', 'cnic': '13101-7766554-2', 'dept': 'Earth Sciences'},
      {'socId': 'soc-edu-1', 'name': 'Kashif Mehmood', 'roll': 'FA21-BCS-089', 'cnic': '13101-9988112-7', 'dept': 'Computer Science'},
      {'socId': 'soc-edu-1', 'name': 'Hafsa Rehman', 'roll': 'SP23-BSE-024', 'cnic': '13101-3344110-8', 'dept': 'Software Engineering'},
      {'socId': 'soc-emp-1', 'name': 'Usama Qazi', 'roll': 'FA22-BBA-055', 'cnic': '13101-6655443-9', 'dept': 'Management Sciences'},
      {'socId': 'soc-eng-1', 'name': 'Haris Khan', 'roll': 'FA21-BEE-034', 'cnic': '13101-1122998-3', 'dept': 'Electrical Engineering'},
    ];

    for (final m in sampleMembers) {
      await db.into(db.societyMembers).insert(
        SocietyMembersCompanion.insert(
          id: uuid.v4(),
          societyId: m['socId']!,
          fullName: m['name']!,
          rollNo: m['roll']!,
          cnic: m['cnic']!,
          department: m['dept']!,
          semester: 4,
          joinedDate: Value(DateTime.now().subtract(const Duration(days: 60))),
          isActive: const Value(true),
        ),
      );
    }

    // 4. Seed Events & Speakers
    const event1Id = 'evt-1';
    await db.into(db.events).insert(
      EventsCompanion.insert(
        id: event1Id,
        title: 'AUST Green Campus Cleanliness & Plantation Drive 2026',
        description: 'Large-scale environmental drive planting 500 saplings across academic blocks and main campus grounds.',
        eventDate: DateTime.now().subtract(const Duration(days: 14)),
        societyId: const Value('soc-env-1'),
        isCollaboration: const Value(false),
        venue: const Value('Campus Main Lawns & Forestry Area'),
        allocatedBudget: const Value(75000.0),
        actualExpense: const Value(0.0),
        positiveImpactSummary: const Value('500 saplings planted; waste segregation bins deployed in 4 blocks.'),
        attendeesCount: const Value(380),
      ),
    );

    const event2Id = 'evt-2';
    await db.into(db.events).insert(
      EventsCompanion.insert(
        id: event2Id,
        title: 'PMYP Tech Skills & AI Fellowship Workshop',
        description: 'Intensive 2-day hands-on boot camp covering modern AI, machine learning and cloud development linkages.',
        eventDate: DateTime.now().add(const Duration(days: 7)),
        societyId: const Value('soc-edu-1'),
        isCollaboration: const Value(true),
        collaboratorNames: const Value('Prime Minister Youth Programme & ALLDOTDEV'),
        venue: const Value('Main University Auditorium'),
        allocatedBudget: const Value(120000.0),
        actualExpense: const Value(0.0),
        positiveImpactSummary: const Value('Direct exposure to top industrial technologies for 420 students.'),
        attendeesCount: const Value(420),
      ),
    );

    await db.into(db.eventSpeakers).insert(
      EventSpeakersCompanion.insert(
        id: uuid.v4(),
        eventId: event2Id,
        name: 'Engr. Zakir Khan',
        organization: 'ALLDOTDEV Technologies',
        designation: const Value('Principal Solutions Architect'),
        contactPhone: const Value('0300-1122334'),
        contactEmail: const Value('zakir@alldotdev.com'),
      ),
    );

    // 5. Seed Financial Records
    await db.into(db.financialRecords).insert(
      FinancialRecordsCompanion.insert(
        id: uuid.v4(),
        monthYear: '09-2026',
        type: 'Grant',
        title: 'University Annual Society Allocation Q3',
        amount: 350000.0,
        notes: const Value('Allocated by Treasurer Office for Student Affairs'),
      ),
    );

    await db.into(db.financialRecords).insert(
      FinancialRecordsCompanion.insert(
        id: uuid.v4(),
        monthYear: '09-2026',
        type: 'Sponsorship',
        title: 'PMYP Industry Partnership Grant',
        amount: 150000.0,
        sponsorName: const Value('Prime Minister Youth Programme (PMYP)'),
        notes: const Value('Direct fellowship sponsorship support'),
      ),
    );

    // 6. Seed Confidential Vault sample metadata with real encrypted asset
    String encryptedPath = 'AppData/Roaming/YDC_AUST/Vault/MOU_PMYP_AUST_2025.enc';
    String checksum = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
    int fileSizeBytes = 1850;

    try {
      const sampleMemoText = '''
========================================================================
MEMORANDUM OF UNDERSTANDING (MoU) — OFFICIAL INSTITUTIONAL COPY
========================================================================
PARTIES:
1. Youth Development Center (YDC), Abbottabad University of Science & Technology (AUST)
2. Prime Minister's Youth Programme (PMYP) Directorate

SUBJECT: Strategic Partnership for Youth Empowerment, Skill Development & Fellowships
DATE OF EXECUTION: 01 September 2025
VALIDITY: 01 September 2025 to 31 August 2027
REFERENCE NO: AUST/YDC/MOU/2025/08

TERMS OF ENGAGEMENT:
1. Allocation of annual fellowship quota for 200 AUST undergraduates in high-growth digital tracks.
2. Provision of specialized technical mentors from industry leaders for university hackathons.
3. Establishing campus innovation labs and co-funding youth entrepreneurship summits.
4. Mutual sharing of quarterly impact metrics and audited student attendance logs.

SIGNED BY:
Director, YDC AUST                National Coordinator, PMYP
------------------                --------------------------
CONFIDENTIALITY ENVELOPE: AES-256-GCM Military Grade Sealed
========================================================================
''';
      final sampleBytes = Uint8List.fromList(utf8.encode(sampleMemoText));
      encryptedPath = await EncryptionService.encryptAndStoreFile(
        rawBytes: sampleBytes,
        originalFileName: 'MOU_PMYP_AUST_Official.txt',
        masterPassword: '1234',
      );
      checksum = await EncryptionService.calculateChecksum(sampleBytes);
      fileSizeBytes = sampleBytes.length;
    } catch (_) {}

    await db.into(db.confidentialVault).insert(
      ConfidentialVaultCompanion.insert(
        id: uuid.v4(),
        category: 'MOU',
        title: 'Institutional Strategic Partnership MoU — PMYP & YDC AUST',
        referenceNumber: const Value('AUST/YDC/MOU/2025/08'),
        effectiveDate: Value(DateTime(2025, 9, 1)),
        expiryDate: Value(DateTime(2027, 8, 31)),
        encryptedFilePath: encryptedPath,
        fileChecksum: checksum,
        fileSizeBytes: Value(fileSizeBytes),
        originalFileName: const Value('MOU_PMYP_AUST_Official.txt'),
        metadataNotes: const Value('Confidential agreement covering fellowship quotas, trainer visits and equipment.'),
      ),
    );
  }
}
