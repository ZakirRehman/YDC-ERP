import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/societies_table.dart';
import 'tables/cabinet_members_table.dart';
import 'tables/society_members_table.dart';
import 'tables/events_table.dart';
import 'tables/event_speakers_table.dart';
import 'tables/achievements_table.dart';
import 'tables/financial_records_table.dart';
import 'tables/confidential_vault_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Societies,
  CabinetMembers,
  SocietyMembers,
  Events,
  EventSpeakers,
  Achievements,
  FinancialRecords,
  ConfidentialVault,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'ydc_master');
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(events, events.imagePaths);
        }
        if (from < 3) {
          await m.addColumn(confidentialVault, confidentialVault.societyId);
        }
      },
      beforeOpen: (details) async {
        // Enable foreign key constraints in SQLite
        await customStatement('PRAGMA foreign_keys = ON');
        // Purge legacy dummy expense transaction and reset mock event expenses
        await customStatement(
          "DELETE FROM financial_records WHERE title = 'Campus Plantation Saplings & Logistics' AND type = 'Expense'",
        );
        await customStatement(
          "UPDATE events SET actual_expense = 0.0 WHERE id IN ('evt-1', 'evt-2') AND actual_expense > 0",
        );
      },
    );
  }

  /// Queries all events executed or concluded within the target month.
  /// If [targetMonth] is omitted, defaults to the current calendar month.
  Future<List<Event>> getConcludedEventsForMonth({
    DateTime? targetMonth,
    bool includeOnlyConcluded = true,
  }) async {
    final target = targetMonth ?? DateTime.now();
    final startOfMonth = DateTime(target.year, target.month, 1);
    final endOfMonth = DateTime(target.year, target.month + 1, 0, 23, 59, 59, 999);
    final now = DateTime.now();
    final endLimit = includeOnlyConcluded
        ? (endOfMonth.isBefore(now)
            ? endOfMonth
            : DateTime(now.year, now.month, now.day, 23, 59, 59, 999))
        : endOfMonth;

    return (select(events)
          ..where((tbl) =>
              tbl.eventDate.isBiggerOrEqualValue(startOfMonth) &
              tbl.eventDate.isSmallerOrEqualValue(endLimit))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.eventDate)]))
        .get();
  }

  /// Queries all events for the given calendar month, explicitly joining events that have a society_id
  /// or are hosted by specific student societies.
  Future<List<EventWithSociety>> getMonthlyEventsWithSocieties({
    DateTime? targetMonth,
    bool includeOnlyConcluded = false,
  }) async {
    final target = targetMonth ?? DateTime.now();
    final startOfMonth = DateTime(target.year, target.month, 1);
    final endOfMonth = DateTime(target.year, target.month + 1, 0, 23, 59, 59, 999);
    final now = DateTime.now();
    final endLimit = includeOnlyConcluded
        ? (endOfMonth.isBefore(now)
            ? endOfMonth
            : DateTime(now.year, now.month, now.day, 23, 59, 59, 999))
        : endOfMonth;

    final query = select(events).join([
      leftOuterJoin(societies, societies.id.equalsExp(events.societyId)),
    ])
      ..where(events.eventDate.isBiggerOrEqualValue(startOfMonth) &
          events.eventDate.isSmallerOrEqualValue(endLimit))
      ..orderBy([OrderingTerm.asc(events.eventDate)]);

    final rows = await query.get();
    return rows.map((row) {
      return EventWithSociety(
        event: row.readTable(events),
        society: row.readTableOrNull(societies),
      );
    }).toList();
  }

  /// Performs a combined UNION query retrieving both Enrolled Students and Executive Cabinet Members across active societies
  Future<List<UnifiedInstitutionalRecord>> getUnifiedInstitutionalRoster() async {
    final rows = await customSelect(
      '''
      SELECT 
        sm.id AS id, 
        sm.society_id AS society_id, 
        sm.full_name AS full_name, 
        sm.roll_no AS identifier, 
        sm.cnic AS cnic, 
        sm.department AS department, 
        sm.semester AS semester, 
        'Student' AS role, 
        0 AS is_executive, 
        sm.phone AS phone
      FROM society_members sm
      LEFT JOIN societies s ON sm.society_id = s.id
      WHERE s.is_active = 1 OR s.is_active IS NULL OR s.id IS NULL

      UNION ALL

      SELECT 
        cm.id AS id, 
        cm.society_id AS society_id, 
        cm.full_name AS full_name, 
        'Executive' AS identifier, 
        cm.cnic AS cnic, 
        cm.department AS department, 
        cm.semester AS semester, 
        cm.role AS role, 
        1 AS is_executive, 
        cm.phone AS phone
      FROM cabinet_members cm
      LEFT JOIN societies s ON cm.society_id = s.id
      WHERE s.is_active = 1 OR s.is_active IS NULL OR s.id IS NULL
      ORDER BY is_executive DESC, full_name ASC
      ''',
      readsFrom: {societyMembers, cabinetMembers, societies},
    ).get();

    return rows.map((row) {
      return UnifiedInstitutionalRecord(
        id: row.read<String>('id'),
        societyId: row.read<String>('society_id'),
        fullName: row.read<String>('full_name'),
        identifier: row.read<String>('identifier'),
        cnic: row.read<String>('cnic'),
        department: row.read<String>('department'),
        semester: row.read<int>('semester'),
        role: row.read<String>('role'),
        isExecutive: row.read<int>('is_executive') == 1,
        phone: row.readNullable<String>('phone'),
      );
    }).toList();
  }
}

/// Unified institutional record combining standard enrolled student rosters and executive cabinet office bearers
class UnifiedInstitutionalRecord {
  final String id;
  final String societyId;
  final String fullName;
  final String identifier; // Roll number for students, 'Executive' for cabinet officers
  final String cnic;
  final String department;
  final int semester;
  final String role; // 'Student' or specific office like 'President', 'General Secretary', etc.
  final bool isExecutive;
  final String? phone;
  final bool isActive;

  const UnifiedInstitutionalRecord({
    required this.id,
    required this.societyId,
    required this.fullName,
    required this.identifier,
    required this.cnic,
    required this.department,
    required this.semester,
    required this.role,
    required this.isExecutive,
    this.phone,
    this.isActive = true,
  });
}

/// Extension on [Event] providing parsed multi-image gallery support with backward compatibility
extension EventImageGalleryExtension on Event {
  /// Returns up to 3 image paths from [imagePaths] (JSON array), falling back to [bannerImagePath]
  List<String> get galleryImages {
    if (imagePaths != null && imagePaths!.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(imagePaths!);
        if (decoded is List) {
          final list = decoded
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty)
              .take(3)
              .toList();
          if (list.isNotEmpty) return list;
        }
      } catch (_) {}
    }
    if (bannerImagePath != null && bannerImagePath!.trim().isNotEmpty) {
      return [bannerImagePath!.trim()];
    }
    return const [];
  }

  /// Primary banner or cover image for cards and summaries
  String? get primaryImage => galleryImages.isNotEmpty ? galleryImages.first : null;

  /// Returns true if this event has multiple promotional images attached
  bool get hasMultipleImages => galleryImages.length > 1;
}

/// Represents an event explicitly joined with its host student society
class EventWithSociety {
  final Event event;
  final Society? society;

  const EventWithSociety({
    required this.event,
    this.society,
  });

  String get hostSocietyName {
    if (society != null) {
      if (society!.acronym != null && society!.acronym!.trim().isNotEmpty) {
        return '${society!.name} (${society!.acronym!.trim()})';
      }
      return society!.name;
    }
    if (event.collaboratorNames != null && event.collaboratorNames!.trim().isNotEmpty) {
      return event.collaboratorNames!;
    }
    return 'Directorate of Youth Development Centre';
  }

  String get pillar => society?.pillar ?? 'Institutional Development';
}
