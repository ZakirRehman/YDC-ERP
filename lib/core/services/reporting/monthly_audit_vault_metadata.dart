import 'dart:convert';
import 'package:intl/intl.dart';

/// Structured metadata representing a specific student society covered in the Master Monthly Audit Dossier
class AuditCoveredSociety {
  final String id;
  final String name;
  final String? acronym;
  final String pillar;
  final int cabinetCount;
  final int enrolledCount;

  const AuditCoveredSociety({
    required this.id,
    required this.name,
    this.acronym,
    required this.pillar,
    this.cabinetCount = 0,
    this.enrolledCount = 0,
  });

  String get displayName => (acronym != null && acronym!.trim().isNotEmpty)
      ? '$name (${acronym!.trim()})'
      : name;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (acronym != null) 'acronym': acronym,
        'pillar': pillar,
        'cabinetCount': cabinetCount,
        'enrolledCount': enrolledCount,
      };

  factory AuditCoveredSociety.fromJson(Map<String, dynamic> json) =>
      AuditCoveredSociety(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'General Society',
        acronym: json['acronym'] as String?,
        pillar: json['pillar'] as String? ?? 'Education',
        cabinetCount: (json['cabinetCount'] as num?)?.toInt() ?? 0,
        enrolledCount: (json['enrolledCount'] as num?)?.toInt() ?? 0,
      );
}

/// Structured metadata representing a concluded event covered in the Master Monthly Audit Dossier
class AuditCoveredEvent {
  final String id;
  final String title;
  final DateTime eventDate;
  final String hostSociety;
  final String pillar;
  final int attendeesCount;
  final double allocatedBudget;
  final double actualExpense;

  const AuditCoveredEvent({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.hostSociety,
    required this.pillar,
    this.attendeesCount = 0,
    this.allocatedBudget = 0.0,
    this.actualExpense = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': eventDate.toIso8601String(),
        'hostSociety': hostSociety,
        'pillar': pillar,
        'attendeesCount': attendeesCount,
        'allocatedBudget': allocatedBudget,
        'actualExpense': actualExpense,
      };

  factory AuditCoveredEvent.fromJson(Map<String, dynamic> json) =>
      AuditCoveredEvent(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Event',
        eventDate: json['date'] != null
            ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
            : DateTime.now(),
        hostSociety: json['hostSociety'] as String? ?? 'Directorate',
        pillar: json['pillar'] as String? ?? 'Engagement',
        attendeesCount: (json['attendeesCount'] as num?)?.toInt() ?? 0,
        allocatedBudget: (json['allocatedBudget'] as num?)?.toDouble() ?? 0.0,
        actualExpense: (json['actualExpense'] as num?)?.toDouble() ?? 0.0,
      );
}

/// Comprehensive vault metadata model for Monthly Audit Dossiers
/// Persisted in the SQLite `confidential_vault.metadata_notes` column
class MonthlyAuditVaultMetadata {
  static const String jsonPrefix = '--- JSON_METADATA ---';

  final String monthYear; // e.g. "September 2026"
  final String periodCode; // e.g. "2026-09"
  final DateTime effectiveDate;
  final int totalSocieties;
  final int totalEvents;
  final int totalMembers;
  final int totalCabinet;
  final int totalAttendees;
  final double totalBudgetSpent;
  final double totalSponsorships;
  final List<AuditCoveredSociety> coveredSocieties;
  final List<AuditCoveredEvent> coveredEvents;

  const MonthlyAuditVaultMetadata({
    required this.monthYear,
    required this.periodCode,
    required this.effectiveDate,
    required this.totalSocieties,
    required this.totalEvents,
    required this.totalMembers,
    required this.totalCabinet,
    required this.totalAttendees,
    required this.totalBudgetSpent,
    required this.totalSponsorships,
    this.coveredSocieties = const [],
    this.coveredEvents = const [],
  });

  Map<String, dynamic> toJson() => {
        'monthYear': monthYear,
        'periodCode': periodCode,
        'effectiveDate': effectiveDate.toIso8601String(),
        'totalSocieties': totalSocieties,
        'totalEvents': totalEvents,
        'totalMembers': totalMembers,
        'totalCabinet': totalCabinet,
        'totalAttendees': totalAttendees,
        'totalBudgetSpent': totalBudgetSpent,
        'totalSponsorships': totalSponsorships,
        'coveredSocieties': coveredSocieties.map((s) => s.toJson()).toList(),
        'coveredEvents': coveredEvents.map((e) => e.toJson()).toList(),
      };

  factory MonthlyAuditVaultMetadata.fromJson(Map<String, dynamic> json) =>
      MonthlyAuditVaultMetadata(
        monthYear: json['monthYear'] as String? ?? '',
        periodCode: json['periodCode'] as String? ?? '',
        effectiveDate: json['effectiveDate'] != null
            ? DateTime.tryParse(json['effectiveDate'] as String) ?? DateTime.now()
            : DateTime.now(),
        totalSocieties: (json['totalSocieties'] as num?)?.toInt() ?? 0,
        totalEvents: (json['totalEvents'] as num?)?.toInt() ?? 0,
        totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
        totalCabinet: (json['totalCabinet'] as num?)?.toInt() ?? 0,
        totalAttendees: (json['totalAttendees'] as num?)?.toInt() ?? 0,
        totalBudgetSpent: (json['totalBudgetSpent'] as num?)?.toDouble() ?? 0.0,
        totalSponsorships: (json['totalSponsorships'] as num?)?.toDouble() ?? 0.0,
        coveredSocieties: (json['coveredSocieties'] as List?)
                ?.map((s) => AuditCoveredSociety.fromJson(Map<String, dynamic>.from(s as Map)))
                .toList() ??
            const [],
        coveredEvents: (json['coveredEvents'] as List?)
                ?.map((e) => AuditCoveredEvent.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const [],
      );

  /// Generates a hybrid human-readable string and JSON payload for the vault `metadata_notes` field.
  /// This ensures both keyword searchability in the Vault UI and programmatic deserialization.
  String toVaultMetadataNotes() {
    final socNames = coveredSocieties.map((s) => s.displayName).join(', ');
    final eventTitles = coveredEvents.isNotEmpty
        ? coveredEvents.map((e) => e.title).join(', ')
        : 'None (Zero events concluded)';

    final humanReadable = '''
Master Monthly Audit Dossier | Month: $monthYear ($periodCode)
Societies Covered (${coveredSocieties.length}): ${socNames.isNotEmpty ? socNames : "None"}
Concluded Events (${coveredEvents.length}): $eventTitles
Metrics: $totalSocieties Societies | $totalMembers Members ($totalCabinet Cabinet) | $totalEvents Events | $totalAttendees Attendees | Rs. ${NumberFormat.decimalPattern().format(totalBudgetSpent)} Spent | Rs. ${NumberFormat.decimalPattern().format(totalSponsorships)} Grants''';

    final jsonPayload = jsonEncode(toJson());
    return '$humanReadable\n$jsonPrefix\n$jsonPayload';
  }

  /// Extracts structured [MonthlyAuditVaultMetadata] from vault `metadata_notes` if present
  static MonthlyAuditVaultMetadata? parseFromNotes(String? notes) {
    if (notes == null || !notes.contains(jsonPrefix)) return null;
    try {
      final parts = notes.split(jsonPrefix);
      if (parts.length < 2) return null;
      final jsonStr = parts[1].trim();
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return MonthlyAuditVaultMetadata.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
