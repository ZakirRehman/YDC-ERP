import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfConcludedEventItem {
  final String title;
  final DateTime date;
  final String hostSociety;
  final int attendeesCount;
  final double allocatedBudget;
  final double actualExpense;

  PdfConcludedEventItem({
    required this.title,
    required this.date,
    required this.hostSociety,
    required this.attendeesCount,
    required this.allocatedBudget,
    required this.actualExpense,
  });
}

class PdfUnifiedRosterItem {
  final String fullName;
  final String role;
  final String identifier;
  final String societyName;
  final String pillar;
  final String department;
  final int semester;
  final bool isExecutive;

  PdfUnifiedRosterItem({
    required this.fullName,
    required this.role,
    required this.identifier,
    required this.societyName,
    required this.pillar,
    required this.department,
    required this.semester,
    this.isExecutive = false,
  });
}

class PdfSocietyRosterSummary {
  final String societyId;
  final String societyName;
  final String? acronym;
  final String pillar;
  final String facultyAdvisor;
  final int cabinetCount;
  final int enrolledCount;
  final List<PdfCabinetMemberItem> cabinetMembers;
  final List<PdfSocietyMemberItem> enrolledMembers;

  PdfSocietyRosterSummary({
    required this.societyId,
    required this.societyName,
    this.acronym,
    required this.pillar,
    required this.facultyAdvisor,
    required this.cabinetCount,
    required this.enrolledCount,
    this.cabinetMembers = const [],
    this.enrolledMembers = const [],
  });
}

class PdfFinancialLedgerItem {
  final String id;
  final String title;
  final double amount;
  final String type; // 'Expense', 'Sponsorship', 'Grant', 'Allocation'
  final String? sponsorOrPayee;
  final String? notes;
  final DateTime? date;

  PdfFinancialLedgerItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.sponsorOrPayee,
    this.notes,
    this.date,
  });

  bool get isInflow {
    final t = type.toLowerCase();
    return t == 'sponsorship' || t == 'grant' || t == 'inflow' || t == 'allocation';
  }
}

class PdfEventAuditItem {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String societyName;
  final String? societyId;
  final String pillar;
  final String? venue;
  final int attendeesCount;
  final double allocatedBudget;
  final double actualExpense;
  final double fiscalVariance;
  final String? positiveImpactSummary;
  final bool isCollaboration;
  final String? collaboratorNames;
  final List<Map<String, String>> speakers;
  final List<String> imagePaths;
  final List<Uint8List> thumbnailBytes;

  PdfEventAuditItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.societyName,
    this.societyId,
    required this.pillar,
    this.venue,
    required this.attendeesCount,
    required this.allocatedBudget,
    required this.actualExpense,
    required this.fiscalVariance,
    this.positiveImpactSummary,
    this.isCollaboration = false,
    this.collaboratorNames,
    this.speakers = const [],
    this.imagePaths = const [],
    this.thumbnailBytes = const [],
  });
}

class PdfDossierData {
  final String monthYear;
  final int totalSocieties;
  final int totalMembers;
  final int totalCabinet;
  final int totalEvents;
  final int totalAttendees;
  final double totalBudgetSpent;
  final double totalSponsorships;
  final Map<String, int> pillarDistribution;
  final List<Map<String, String>> achievements;
  final List<Map<String, dynamic>> financialItems;
  final List<PdfConcludedEventItem> concludedEvents;
  final List<PdfUnifiedRosterItem> unifiedRoster;
  final List<PdfSocietyRosterSummary> societyRosters;
  final List<PdfFinancialLedgerItem> financialLedger;
  final List<PdfEventAuditItem> eventAudits;

  PdfDossierData({
    required this.monthYear,
    required this.totalSocieties,
    required this.totalMembers,
    this.totalCabinet = 0,
    required this.totalEvents,
    required this.totalAttendees,
    required this.totalBudgetSpent,
    required this.totalSponsorships,
    required this.pillarDistribution,
    required this.achievements,
    required this.financialItems,
    this.concludedEvents = const [],
    this.unifiedRoster = const [],
    this.societyRosters = const [],
    this.financialLedger = const [],
    this.eventAudits = const [],
  });
}

class PdfCabinetMemberItem {
  final String role;
  final String fullName;
  final String cnic;
  final String department;
  final int semester;
  final String phone;

  PdfCabinetMemberItem({
    required this.role,
    required this.fullName,
    required this.cnic,
    required this.department,
    required this.semester,
    this.phone = '',
  });
}

class PdfSocietyMemberItem {
  final String fullName;
  final String rollNo;
  final String cnic;
  final String department;
  final int semester;

  PdfSocietyMemberItem({
    required this.fullName,
    required this.rollNo,
    required this.cnic,
    required this.department,
    required this.semester,
  });
}

class PdfSocietyDossierData {
  final String societyName;
  final String? acronym;
  final String pillar;
  final String facultyAdvisor;
  final String? logoPath;
  final String monthYear;
  final List<PdfCabinetMemberItem> cabinet;
  final List<PdfSocietyMemberItem> members;
  final int totalEvents;

  PdfSocietyDossierData({
    required this.societyName,
    this.acronym,
    required this.pillar,
    required this.facultyAdvisor,
    this.logoPath,
    required this.monthYear,
    required this.cabinet,
    required this.members,
    this.totalEvents = 0,
  });
}

class PdfEventArchiveData {
  final String title;
  final DateTime eventDate;
  final String societyName;
  final String? acronym;
  final String pillar;
  final String? venue;
  final double allocatedBudget;
  final double actualExpense;
  final int attendeesCount;
  final String description;
  final String? positiveImpactSummary;
  final bool isCollaboration;
  final String? collaboratorNames;
  final List<Map<String, String>> speakers;
  final List<String> imagePaths;

  PdfEventArchiveData({
    required this.title,
    required this.eventDate,
    required this.societyName,
    this.acronym,
    required this.pillar,
    this.venue,
    required this.allocatedBudget,
    required this.actualExpense,
    required this.attendeesCount,
    required this.description,
    this.positiveImpactSummary,
    this.isCollaboration = false,
    this.collaboratorNames,
    this.speakers = const [],
    this.imagePaths = const [],
  });
}

class PdfDossierService {
  PdfDossierService._();

  static Future<Uint8List> generateMonthlyDossier(PdfDossierData data) async {
    final pdf = pw.Document();

    pw.Font fontBold;
    pw.Font fontRegular;
    pw.Font fontMedium;
    try {
      fontBold = await PdfGoogleFonts.interBold();
      fontRegular = await PdfGoogleFonts.interRegular();
      fontMedium = await PdfGoogleFonts.interMedium();
    } catch (_) {
      // Safe offline fallback when internet is unavailable or Google Fonts is unreachable
      fontBold = pw.Font.helveticaBold();
      fontRegular = pw.Font.helvetica();
      fontMedium = pw.Font.helvetica();
    }

    pw.MemoryImage? ydcLogo;
    pw.MemoryImage? alldotdevLogo;
    try {
      ByteData ydcData;
      try {
        ydcData = await rootBundle.load('assets/YDC_AUST.jpg');
      } catch (_) {
        ydcData = await rootBundle.load('assets/images/YDC_Aust.jpg');
      }
      ydcLogo = pw.MemoryImage(ydcData.buffer.asUint8List());
    } catch (_) {}

    try {
      final alldotdevData = await rootBundle.load('assets/images/Alldotdev.png');
      alldotdevLogo = pw.MemoryImage(alldotdevData.buffer.asUint8List());
    } catch (_) {}

    final currencyFmt = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    // Adapt data if new domain models were not supplied directly
    final effectiveSocietyRosters = List<PdfSocietyRosterSummary>.from(data.societyRosters);
    if (effectiveSocietyRosters.isEmpty && data.unifiedRoster.isNotEmpty) {
      final grouped = <String, List<PdfUnifiedRosterItem>>{};
      for (final r in data.unifiedRoster) {
        grouped.putIfAbsent(r.societyName, () => []).add(r);
      }
      grouped.forEach((socName, items) {
        final cabItems = items.where((i) => i.isExecutive).map((i) => PdfCabinetMemberItem(
          role: i.role,
          fullName: i.fullName,
          cnic: i.identifier,
          department: i.department,
          semester: i.semester,
        )).toList();
        final memItems = items.where((i) => !i.isExecutive).map((i) => PdfSocietyMemberItem(
          fullName: i.fullName,
          rollNo: i.identifier,
          cnic: '-',
          department: i.department,
          semester: i.semester,
        )).toList();
        effectiveSocietyRosters.add(
          PdfSocietyRosterSummary(
            societyId: socName,
            societyName: socName,
            pillar: items.first.pillar,
            facultyAdvisor: 'Institutional Advisory',
            cabinetCount: cabItems.length,
            enrolledCount: memItems.length,
            cabinetMembers: cabItems,
            enrolledMembers: memItems,
          ),
        );
      });
    }

    final effectiveFinancialLedger = List<PdfFinancialLedgerItem>.from(data.financialLedger);
    if (effectiveFinancialLedger.isEmpty && data.financialItems.isNotEmpty) {
      for (var i = 0; i < data.financialItems.length; i++) {
        final f = data.financialItems[i];
        effectiveFinancialLedger.add(
          PdfFinancialLedgerItem(
            id: 'legacy-$i',
            title: f['title']?.toString() ?? 'Ledger Voucher',
            amount: (f['amount'] as num?)?.toDouble() ?? 0.0,
            type: f['type']?.toString() ?? 'Expense',
            sponsorOrPayee: f['sponsorName']?.toString(),
            notes: f['notes']?.toString(),
          ),
        );
      }
    }

    final effectiveEventAudits = List<PdfEventAuditItem>.from(data.eventAudits);
    if (effectiveEventAudits.isEmpty && data.concludedEvents.isNotEmpty) {
      for (var i = 0; i < data.concludedEvents.length; i++) {
        final e = data.concludedEvents[i];
        final variance = e.allocatedBudget - e.actualExpense;
        effectiveEventAudits.add(
          PdfEventAuditItem(
            id: 'legacy-evt-$i',
            title: e.title,
            description: 'Concluded institutional event under Directorate of Youth Development Centre.',
            date: e.date,
            societyName: e.hostSociety,
            pillar: 'Institutional Development',
            attendeesCount: e.attendeesCount,
            allocatedBudget: e.allocatedBudget,
            actualExpense: e.actualExpense,
            fiscalVariance: variance,
          ),
        );
      }
    }

    // Compute financial aggregates
    double totalInflow = data.totalSponsorships;
    double totalOutflow = data.totalBudgetSpent;
    if (effectiveFinancialLedger.isNotEmpty) {
      totalInflow = effectiveFinancialLedger.where((f) => f.isInflow).fold(0.0, (acc, f) => acc + f.amount);
      totalOutflow = effectiveFinancialLedger.where((f) => !f.isInflow).fold(0.0, (acc, f) => acc + f.amount);
    }
    final netFiscalBalance = totalInflow - totalOutflow;

    int totalCabinetMembers = data.totalCabinet;
    int totalEnrolledStudents = data.totalMembers;
    if (effectiveSocietyRosters.isNotEmpty) {
      totalCabinetMembers = effectiveSocietyRosters.fold(0, (acc, s) => acc + s.cabinetCount);
      totalEnrolledStudents = effectiveSocietyRosters.fold(0, (acc, s) => acc + s.enrolledCount);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (context) => _buildHeader(data, fontBold, fontRegular, ydcLogo),
        footer: (context) => _buildFooter(context, fontRegular, alldotdevLogo),
        build: (context) => [
          pw.SizedBox(height: 12),

          // Executive Summary Banner
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.8),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: _buildMetricBox(
                    'Active Societies',
                    '${effectiveSocietyRosters.isNotEmpty ? effectiveSocietyRosters.length : data.totalSocieties}',
                    PdfColor.fromHex('#0D6EFD'),
                    fontBold,
                    fontRegular,
                  ),
                ),
                pw.Expanded(
                  child: _buildMetricBox(
                    'Enrolled Students',
                    '$totalEnrolledStudents',
                    PdfColor.fromHex('#198754'),
                    fontBold,
                    fontRegular,
                  ),
                ),
                pw.Expanded(
                  child: _buildMetricBox(
                    'Cabinet Officers',
                    '$totalCabinetMembers',
                    PdfColor.fromHex('#4F46E5'),
                    fontBold,
                    fontRegular,
                  ),
                ),
                pw.Expanded(
                  child: _buildMetricBox(
                    'Events Concluded',
                    '${effectiveEventAudits.isNotEmpty ? effectiveEventAudits.length : data.totalEvents}',
                    PdfColor.fromHex('#E65100'),
                    fontBold,
                    fontRegular,
                  ),
                ),
                pw.Expanded(
                  child: _buildMetricBox(
                    'Total Attendees',
                    '${data.totalAttendees}',
                    PdfColor.fromHex('#0F766E'),
                    fontBold,
                    fontRegular,
                  ),
                ),
                pw.Expanded(
                  child: _buildMetricBox(
                    'Net Fiscal Balance',
                    currencyFmt.format(netFiscalBalance),
                    netFiscalBalance >= 0 ? PdfColor.fromHex('#166534') : PdfColor.fromHex('#DC2626'),
                    fontBold,
                    fontRegular,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // =========================================================================
          // SECTION 1: HUMAN RESOURCES (ROSTER)
          // Breakdown of total enrollments vs. active cabinet members, organized by society
          // =========================================================================
          _buildSectionTitle(
            'SECTION 1: HUMAN RESOURCES (ROSTER)',
            'Breakdown of total student enrollments vs. active cabinet members organized by society chapter.',
            fontBold,
            fontRegular,
          ),
          pw.SizedBox(height: 8),

          if (effectiveSocietyRosters.isEmpty)
            _buildEmptySectionBox('No registered society rosters recorded for this operational cycle.', fontRegular)
          else ...[
            // Cross-Society HR Overview Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E4E7EC'), width: 0.8),
              columnWidths: const {
                0: pw.FlexColumnWidth(0.5),
                1: pw.FlexColumnWidth(3.0),
                2: pw.FlexColumnWidth(1.4),
                3: pw.FlexColumnWidth(2.4),
                4: pw.FlexColumnWidth(1.4),
                5: pw.FlexColumnWidth(1.4),
                6: pw.FlexColumnWidth(1.4),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                  children: [
                    _tableHeaderCell('#', fontBold),
                    _tableHeaderCell('Society / Chapter Name', fontBold),
                    _tableHeaderCell('Strategic Pillar', fontBold),
                    _tableHeaderCell('Faculty Advisor', fontBold),
                    _tableHeaderCell('Cabinet Officers', fontBold),
                    _tableHeaderCell('Enrolled Students', fontBold),
                    _tableHeaderCell('Total Strength', fontBold),
                  ],
                ),
                ...effectiveSocietyRosters.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final s = entry.value;
                  final nameDisplay = s.acronym != null && s.acronym!.isNotEmpty
                      ? '${s.societyName} (${s.acronym})'
                      : s.societyName;
                  return pw.TableRow(
                    children: [
                      _tableCell('$idx', fontRegular),
                      _tableCell(nameDisplay, fontMedium),
                      _tableCell(s.pillar, fontRegular),
                      _tableCell(s.facultyAdvisor, fontRegular),
                      _tableCell('${s.cabinetCount}', fontMedium, alignRight: true),
                      _tableCell('${s.enrolledCount}', fontRegular, alignRight: true),
                      _tableCell('${s.cabinetCount + s.enrolledCount}', fontBold, alignRight: true),
                    ],
                  );
                }),
                // Total Summary Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
                  children: [
                    _tableCell('', fontBold),
                    _tableCell('INSTITUTIONAL HUMAN RESOURCE TOTALS', fontBold),
                    _tableCell('-', fontRegular),
                    _tableCell('-', fontRegular),
                    _tableCell('$totalCabinetMembers Officers', fontBold, alignRight: true),
                    _tableCell('$totalEnrolledStudents Enrolled', fontBold, alignRight: true),
                    _tableCell('${totalCabinetMembers + totalEnrolledStudents} Total', fontBold, alignRight: true),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 12),

            // Detailed Society-by-Society Breakdown
            ...effectiveSocietyRosters.map((soc) {
              final socTitle = soc.acronym != null && soc.acronym!.isNotEmpty
                  ? '${soc.societyName} (${soc.acronym})'
                  : soc.societyName;

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('#E4E7EC'), width: 0.8),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            socTitle,
                            style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: PdfColor.fromHex('#111827')),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: _getPillarPdfColor(soc.pillar).shade(0.1),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            soc.pillar.toUpperCase(),
                            style: pw.TextStyle(font: fontBold, fontSize: 8, color: _getPillarPdfColor(soc.pillar)),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Advisor: ${soc.facultyAdvisor} | Active Cabinet: ${soc.cabinetCount} Officers | Enrolled Members: ${soc.enrolledCount} Students',
                      style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColors.grey700),
                    ),
                    if (soc.cabinetMembers.isNotEmpty) ...[
                      pw.SizedBox(height: 6),
                      pw.Text('Executive Cabinet Hierarchy:', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColor.fromHex('#334155'))),
                      pw.SizedBox(height: 4),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColor.fromHex('#E4E7EC'), width: 0.6),
                        columnWidths: const {
                          0: pw.FlexColumnWidth(2.0),
                          1: pw.FlexColumnWidth(2.4),
                          2: pw.FlexColumnWidth(2.0),
                          3: pw.FlexColumnWidth(2.2),
                          4: pw.FlexColumnWidth(1.6),
                        },
                        children: [
                          pw.TableRow(
                            decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                            children: [
                              _tableHeaderCell('Role / Office', fontBold, fontSize: 8),
                              _tableHeaderCell('Full Name', fontBold, fontSize: 8),
                              _tableHeaderCell('CNIC / ID', fontBold, fontSize: 8),
                              _tableHeaderCell('Department & Sem', fontBold, fontSize: 8),
                              _tableHeaderCell('Contact Phone', fontBold, fontSize: 8),
                            ],
                          ),
                          ...soc.cabinetMembers.map((c) {
                            return pw.TableRow(
                              children: [
                                _tableCell(c.role, fontBold, fontSize: 8),
                                _tableCell(c.fullName, fontMedium, fontSize: 8),
                                _tableCell(c.cnic, fontRegular, fontSize: 8),
                                _tableCell('${c.department} (S${c.semester})', fontRegular, fontSize: 8),
                                _tableCell(c.phone.isNotEmpty ? c.phone : 'N/A', fontRegular, fontSize: 8),
                              ],
                            );
                          }),
                        ],
                      ),
                    ],
                    if (soc.enrolledMembers.isNotEmpty) ...[
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Enrolled Student Roster (${soc.enrolledMembers.length} Members):',
                        style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColor.fromHex('#334155')),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColor.fromHex('#E4E7EC'), width: 0.6),
                        columnWidths: const {
                          0: pw.FlexColumnWidth(0.5),
                          1: pw.FlexColumnWidth(2.6),
                          2: pw.FlexColumnWidth(2.0),
                          3: pw.FlexColumnWidth(2.0),
                          4: pw.FlexColumnWidth(2.2),
                        },
                        children: [
                          pw.TableRow(
                            decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                            children: [
                              _tableHeaderCell('#', fontBold, fontSize: 8),
                              _tableHeaderCell('Full Name', fontBold, fontSize: 8),
                              _tableHeaderCell('Roll Number', fontBold, fontSize: 8),
                              _tableHeaderCell('CNIC / B-Form', fontBold, fontSize: 8),
                              _tableHeaderCell('Department & Sem', fontBold, fontSize: 8),
                            ],
                          ),
                          ...soc.enrolledMembers.asMap().entries.map((entry) {
                            final idx = entry.key + 1;
                            final m = entry.value;
                            return pw.TableRow(
                              children: [
                                _tableCell('$idx', fontRegular, fontSize: 8),
                                _tableCell(m.fullName, fontMedium, fontSize: 8),
                                _tableCell(m.rollNo, fontRegular, fontSize: 8),
                                _tableCell(m.cnic, fontRegular, fontSize: 8),
                                _tableCell('${m.department} (S${m.semester})', fontRegular, fontSize: 8),
                              ],
                            );
                          }),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],

          pw.SizedBox(height: 18),

          // =========================================================================
          // SECTION 2: FINANCIAL AUDIT
          // Ledger table showing cash inflow (sponsorships) vs. cash outflow (event expenses)
          // =========================================================================
          _buildSectionTitle(
            'SECTION 2: FINANCIAL AUDIT & RESOURCE LEDGER',
            'Comprehensive ledger table showing cash inflows (sponsorships / grants) vs. cash outflows (expenses & disbursements).',
            fontBold,
            fontRegular,
          ),
          pw.SizedBox(height: 8),

          // Financial Summary Metric Cards
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#E4E7EC'), width: 0.8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    color: PdfColor.fromHex('#F0FDF4'),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Cash Inflow (Sponsorships & Grants)', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColor.fromHex('#166534'))),
                      pw.SizedBox(height: 2),
                      pw.Text(currencyFmt.format(totalInflow), style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColor.fromHex('#166534'))),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#E4E7EC'), width: 0.8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    color: PdfColor.fromHex('#FEF2F2'),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Cash Outflow (Disbursements & Expenses)', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColor.fromHex('#991B1B'))),
                      pw.SizedBox(height: 2),
                      pw.Text(currencyFmt.format(totalOutflow), style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColor.fromHex('#DC2626'))),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#E4E7EC'), width: 0.8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    color: PdfColor.fromHex('#F8FAFC'),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Net Operational Fiscal Balance', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColor.fromHex('#334155'))),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        currencyFmt.format(netFiscalBalance),
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 13,
                          color: netFiscalBalance >= 0 ? PdfColor.fromHex('#166534') : PdfColor.fromHex('#DC2626'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          if (effectiveFinancialLedger.isEmpty)
            _buildEmptySectionBox('No audited financial vouchers or ledger entries recorded for this period.', fontRegular)
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E4E7EC'), width: 0.8),
              columnWidths: const {
                0: pw.FlexColumnWidth(2.8),
                1: pw.FlexColumnWidth(1.4),
                2: pw.FlexColumnWidth(2.2),
                3: pw.FlexColumnWidth(2.2),
                4: pw.FlexColumnWidth(1.6),
                5: pw.FlexColumnWidth(1.6),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                  children: [
                    _tableHeaderCell('Transaction / Voucher Title', fontBold),
                    _tableHeaderCell('Classification', fontBold),
                    _tableHeaderCell('Payee / Sponsor / Source', fontBold),
                    _tableHeaderCell('Notes / Purpose', fontBold),
                    _tableHeaderCell('Cash Inflow (PKR)', fontBold),
                    _tableHeaderCell('Cash Outflow (PKR)', fontBold),
                  ],
                ),
                ...effectiveFinancialLedger.map((f) {
                  final isInflow = f.isInflow;
                  final source = f.sponsorOrPayee ?? (isInflow ? 'Institutional Grant' : 'Institutional Allocation');
                  final notes = f.notes ?? '-';

                  return pw.TableRow(
                    children: [
                      _tableCell(f.title, fontMedium),
                      _tableCell(f.type, fontRegular),
                      _tableCell(source, fontRegular),
                      _tableCell(notes, fontRegular),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          isInflow ? currencyFmt.format(f.amount) : '-',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 8.5,
                            color: isInflow ? PdfColor.fromHex('#166534') : PdfColors.grey500,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          !isInflow ? currencyFmt.format(f.amount) : '-',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 8.5,
                            color: !isInflow ? PdfColor.fromHex('#DC2626') : PdfColors.grey500,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                // Total Summary Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
                  children: [
                    _tableCell('TOTAL AUDITED VOLUME', fontBold),
                    _tableCell('-', fontRegular),
                    _tableCell('-', fontRegular),
                    _tableCell('-', fontRegular),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        currencyFmt.format(totalInflow),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColor.fromHex('#166534')),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        currencyFmt.format(totalOutflow),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColor.fromHex('#DC2626')),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          pw.SizedBox(height: 20),

          // =========================================================================
          // SECTION 3: EVENTS AUDIT
          // Detailed breakdown of every event executed that month
          // For each event: dedicated block showing title, date, impact metrics, attendee count, financial footprint
          // =========================================================================
          _buildSectionTitle(
            'SECTION 3: EVENTS & ACTIVITIES AUDIT',
            'Detailed operational breakdown of every event executed that month, including attendance metrics, financial footprint, and institutional impact.',
            fontBold,
            fontRegular,
          ),
          pw.SizedBox(height: 8),

          if (effectiveEventAudits.isEmpty)
            _buildEmptySectionBox('No institutional events, workshops, or activities were concluded in the audit period.', fontRegular)
          else ...[
            () {
              // Group events by host society
              final Map<String, List<PdfEventAuditItem>> groupedEvents = {};
              for (final evt in effectiveEventAudits) {
                groupedEvents.putIfAbsent(evt.societyName, () => []).add(evt);
              }

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 1. Executive Host Society Performance & Financial Impact Summary Table
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'HOST SOCIETY PERFORMANCE & FISCAL AUDIT SUMMARY',
                              style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColor.fromHex('#0F172A')),
                            ),
                            pw.Text(
                              '${groupedEvents.length} Active Host Societies / Portfolios',
                              style: pw.TextStyle(font: fontMedium, fontSize: 8, color: PdfColors.grey700),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.6),
                          columnWidths: {
                            0: const pw.FlexColumnWidth(3.4),
                            1: const pw.FlexColumnWidth(1.0),
                            2: const pw.FlexColumnWidth(1.4),
                            3: const pw.FlexColumnWidth(1.8),
                            4: const pw.FlexColumnWidth(1.8),
                            5: const pw.FlexColumnWidth(1.8),
                          },
                          children: [
                            pw.TableRow(
                              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
                              children: [
                                _tableHeaderCell('Host Society / Operating Unit', fontBold, fontSize: 7.5),
                                _tableHeaderCell('Events', fontBold, fontSize: 7.5, align: pw.TextAlign.center),
                                _tableHeaderCell('Attendees', fontBold, fontSize: 7.5, align: pw.TextAlign.right),
                                _tableHeaderCell('Allocated', fontBold, fontSize: 7.5, align: pw.TextAlign.right),
                                _tableHeaderCell('Expended', fontBold, fontSize: 7.5, align: pw.TextAlign.right),
                                _tableHeaderCell('Variance', fontBold, fontSize: 7.5, align: pw.TextAlign.right),
                              ],
                            ),
                            ...groupedEvents.entries.map((entry) {
                              final socName = entry.key;
                              final events = entry.value;
                              final pillar = events.first.pillar;
                              final attendees = events.fold(0, (acc, e) => acc + e.attendeesCount);
                              final allocated = events.fold(0.0, (acc, e) => acc + e.allocatedBudget);
                              final spent = events.fold(0.0, (acc, e) => acc + e.actualExpense);
                              final variance = allocated - spent;
                              final isUnder = variance >= 0;

                              return pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          socName,
                                          style: pw.TextStyle(font: fontBold, fontSize: 7.5, color: PdfColor.fromHex('#0F172A')),
                                        ),
                                        pw.Text(
                                          'Pillar: $pillar',
                                          style: pw.TextStyle(font: fontRegular, fontSize: 6.5, color: _getPillarPdfColor(pillar)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: pw.Text(
                                      '${events.length}',
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: pw.Text(
                                      '$attendees',
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(font: fontMedium, fontSize: 7.5),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: pw.Text(
                                      currencyFmt.format(allocated),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(font: fontRegular, fontSize: 7.5),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: pw.Text(
                                      currencyFmt.format(spent),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: pw.Text(
                                      '${isUnder ? "+" : ""}${currencyFmt.format(variance)}',
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: 7.5,
                                        color: isUnder ? PdfColor.fromHex('#166534') : PdfColor.fromHex('#DC2626'),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            if (groupedEvents.length > 1)
                              pw.TableRow(
                                decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                    child: pw.Text(
                                      'CONSOLIDATED IMPACT',
                                      style: pw.TextStyle(font: fontBold, fontSize: 7.5, color: PdfColor.fromHex('#0F172A')),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: pw.Text(
                                      '${effectiveEventAudits.length}',
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: pw.Text(
                                      '${effectiveEventAudits.fold(0, (a, b) => a + b.attendeesCount)}',
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: pw.Text(
                                      currencyFmt.format(effectiveEventAudits.fold(0.0, (a, b) => a + b.allocatedBudget)),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: pw.Text(
                                      currencyFmt.format(effectiveEventAudits.fold(0.0, (a, b) => a + b.actualExpense)),
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: pw.Text(
                                      '${(effectiveEventAudits.fold(0.0, (a, b) => a + b.fiscalVariance)) >= 0 ? "+" : ""}${currencyFmt.format(effectiveEventAudits.fold(0.0, (a, b) => a + b.fiscalVariance))}',
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: 7.5,
                                        color: (effectiveEventAudits.fold(0.0, (a, b) => a + b.fiscalVariance)) >= 0
                                            ? PdfColor.fromHex('#166534')
                                            : PdfColor.fromHex('#DC2626'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 2. Operational Audit Dossiers Grouped by Host Society
                  pw.Text(
                    'OPERATIONAL AUDIT DOSSIERS BY HOST SOCIETY',
                    style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColor.fromHex('#0F172A')),
                  ),
                  pw.SizedBox(height: 6),
                  ...groupedEvents.entries.expand((entry) {
                    final socName = entry.key;
                    final socEvents = entry.value;
                    final socPillar = socEvents.first.pillar;
                    final socSpent = socEvents.fold(0.0, (a, b) => a + b.actualExpense);
                    final socAttendees = socEvents.fold(0, (a, b) => a + b.attendeesCount);

                    return [
                      // Host Society Header Banner
                      pw.Container(
                        margin: const pw.EdgeInsets.only(top: 8, bottom: 8),
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F8FAFC'),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: pw.BoxDecoration(
                                    color: _getPillarPdfColor(socPillar),
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                                  ),
                                  child: pw.Text(
                                    socPillar.toUpperCase(),
                                    style: pw.TextStyle(font: fontBold, fontSize: 7, color: PdfColors.white),
                                  ),
                                ),
                                pw.SizedBox(width: 8),
                                pw.Text(
                                  'Host Society: $socName',
                                  style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColor.fromHex('#0F172A')),
                                ),
                              ],
                            ),
                            pw.Text(
                              '${socEvents.length} Event(s) | Total Expense: ${currencyFmt.format(socSpent)} | $socAttendees Attendees',
                              style: pw.TextStyle(font: fontMedium, fontSize: 8, color: PdfColors.grey700),
                            ),
                          ],
                        ),
                      ),
                      // Individual Event Cards under this host society
                      ...socEvents.map((evt) => _buildEventAuditCard(evt, currencyFmt, fontBold, fontRegular, fontMedium)),
                    ];
                  }),
                ],
              );
            }(),
          ],

          pw.SizedBox(height: 24),

          // Formal Sign-off Section
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSignatureLine('Prepared By:\nGeneral Secretary, YDC', fontRegular),
              _buildSignatureLine('Verified By:\nDirector YDC AUST', fontRegular),
              _buildSignatureLine('Approved By:\nPatron / Vice Chancellor', fontRegular),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(PdfDossierData data, pw.Font bold, pw.Font regular, pw.MemoryImage? logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#198754'), width: 2.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logo != null)
                  pw.Container(
                    width: 44,
                    height: 44,
                    margin: const pw.EdgeInsets.only(right: 12),
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  )
                else
                  pw.Container(
                    width: 44,
                    height: 44,
                    margin: const pw.EdgeInsets.only(right: 12),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#198754'),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'AUST\nYDC',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white, lineSpacing: 1.1),
                      ),
                    ),
                  ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        'ABBOTTABAD UNIVERSITY OF SCIENCE & TECHNOLOGY',
                        style: pw.TextStyle(font: bold, fontSize: 10.5, color: PdfColor.fromHex('#198754')),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Youth Development Centre (YDC) Directorate',
                        style: pw.TextStyle(font: bold, fontSize: 12, color: PdfColor.fromHex('#111827')),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Master Institutional Monthly Audit Dossier',
                        style: pw.TextStyle(font: regular, fontSize: 8.5, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#198754'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('AUDIT PERIOD', style: pw.TextStyle(font: bold, fontSize: 6.5, color: PdfColors.white)),
                pw.SizedBox(height: 1),
                pw.Text(
                  data.monthYear,
                  style: pw.TextStyle(font: bold, fontSize: 10.5, color: PdfColors.white),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font regular, pw.MemoryImage? alldotdevLogo) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColor.fromHex('#E4E7EC'), width: 1))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (alldotdevLogo != null)
                pw.Container(
                  height: 12,
                  margin: const pw.EdgeInsets.only(right: 6),
                  child: pw.Image(alldotdevLogo, fit: pw.BoxFit.contain),
                ),
              pw.Text('YDC AUST ERP System | Architected & Engineered by ALLDOTDEV', style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title, String subtitle, pw.Font bold, pw.Font regular) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 11, color: PdfColor.fromHex('#0F172A'))),
        pw.SizedBox(height: 2),
        pw.Text(subtitle, style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
      ],
    );
  }

  static pw.Widget _buildEmptySectionBox(String message, pw.Font regular) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E4E7EC'), width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        color: PdfColor.fromHex('#F8FAFC'),
      ),
      child: pw.Text(
        message,
        style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey700),
      ),
    );
  }

  static pw.Widget _buildMetricBox(
    String label,
    String value,
    PdfColor color,
    pw.Font bold,
    pw.Font regular, {
    double valueSize = 13,
    double labelSize = 8.5,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            value,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: bold, fontSize: valueSize, color: color),
            maxLines: 2,
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            label,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: regular, fontSize: labelSize, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tableHeaderCell(String text, pw.Font bold, {double fontSize = 9, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: bold, fontSize: fontSize, color: PdfColor.fromHex('#111827')),
      ),
    );
  }

  static pw.Widget _buildEventAuditCard(
    PdfEventAuditItem evt,
    NumberFormat currencyFmt,
    pw.Font fontBold,
    pw.Font fontRegular,
    pw.Font fontMedium,
  ) {
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(evt.date);
    final variance = evt.allocatedBudget - evt.actualExpense;
    final isUnderBudget = variance >= 0;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        color: PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Event Header Row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      evt.title,
                      style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColor.fromHex('#0F172A')),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${evt.societyName} | Strategic Pillar: ${evt.pillar}',
                      style: pw.TextStyle(font: fontMedium, fontSize: 8.5, color: _getPillarPdfColor(evt.pillar)),
                    ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#ECFDF5'),
                      border: pw.Border.all(color: PdfColor.fromHex('#10B981'), width: 0.6),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'CONCLUDED & AUDITED',
                      style: pw.TextStyle(font: fontBold, fontSize: 7, color: PdfColor.fromHex('#047857')),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(dateStr, style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),

          if (evt.venue != null && evt.venue!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Venue: ${evt.venue}',
              style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColors.grey700),
            ),
          ],

          if (evt.isCollaboration) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              'Collaboration: ${evt.collaboratorNames ?? "External Partner Organization"}',
              style: pw.TextStyle(font: fontMedium, fontSize: 8.5, color: PdfColor.fromHex('#2563EB')),
            ),
          ],

          pw.SizedBox(height: 8),

          // Event Financial & Attendance Footprint Row
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: _buildMetricBox(
                    'Allocated Budget',
                    currencyFmt.format(evt.allocatedBudget),
                    PdfColor.fromHex('#0D6EFD'),
                    fontBold,
                    fontRegular,
                    valueSize: 11,
                    labelSize: 7.5,
                  ),
                ),
                pw.Expanded(
                  child: _buildMetricBox(
                    'Actual Expense',
                    currencyFmt.format(evt.actualExpense),
                    PdfColor.fromHex('#198754'),
                    fontBold,
                    fontRegular,
                    valueSize: 11,
                    labelSize: 7.5,
                  ),
                ),
                pw.Expanded(
                  child: _buildMetricBox(
                    'Fiscal Variance',
                    '${isUnderBudget ? "+" : ""}${currencyFmt.format(variance)} (${isUnderBudget ? "Under" : "Over"})',
                    isUnderBudget ? PdfColor.fromHex('#10B981') : PdfColor.fromHex('#EF4444'),
                    fontBold,
                    fontRegular,
                    valueSize: 10,
                    labelSize: 7.5,
                  ),
                ),
                pw.Expanded(
                  child: _buildMetricBox(
                    'Total Attendees',
                    '${evt.attendeesCount} Students',
                    PdfColor.fromHex('#7C3AED'),
                    fontBold,
                    fontRegular,
                    valueSize: 11,
                    labelSize: 7.5,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 8),

          // Executive Narrative & Scope
          pw.Text('Event Scope & Operational Narrative:', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColor.fromHex('#1E293B'))),
          pw.SizedBox(height: 2),
          pw.Text(
            evt.description,
            style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColors.grey800, lineSpacing: 1.5),
          ),

          if (evt.positiveImpactSummary != null && evt.positiveImpactSummary!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F0FDF4'),
                border: pw.Border.all(color: PdfColor.fromHex('#86EFAC'), width: 0.6),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Institutional Impact Assessment:', style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColor.fromHex('#166534'))),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    evt.positiveImpactSummary!,
                    style: pw.TextStyle(font: fontMedium, fontSize: 8, color: PdfColor.fromHex('#14532D')),
                  ),
                ],
              ),
            ),
          ],

          if (evt.speakers.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text('Keynote Speakers & Resource Persons:', style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColor.fromHex('#334155'))),
            pw.SizedBox(height: 3),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E4E7EC'), width: 0.6),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                  children: [
                    _tableHeaderCell('#', fontBold, fontSize: 7.5),
                    _tableHeaderCell('Speaker Name', fontBold, fontSize: 7.5),
                    _tableHeaderCell('Designation', fontBold, fontSize: 7.5),
                    _tableHeaderCell('Affiliation / Entity', fontBold, fontSize: 7.5),
                  ],
                ),
                ...evt.speakers.asMap().entries.map((spkEntry) {
                  final idx = spkEntry.key + 1;
                  final spk = spkEntry.value;
                  return pw.TableRow(
                    children: [
                      _tableCell('$idx', fontRegular, fontSize: 7.5),
                      _tableCell(spk['name'] ?? '', fontBold, fontSize: 7.5),
                      _tableCell(spk['designation'] ?? 'Speaker', fontRegular, fontSize: 7.5),
                      _tableCell(spk['organization'] ?? 'External Entity', fontRegular, fontSize: 7.5),
                    ],
                  );
                }),
              ],
            ),
          ],

          if (evt.thumbnailBytes.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              'Attached Photo Documentation (${evt.thumbnailBytes.length} Assets):',
              style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColor.fromHex('#334155')),
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: evt.thumbnailBytes.take(3).map((bytes) {
                return pw.Container(
                  width: 80,
                  height: 55,
                  margin: const pw.EdgeInsets.only(right: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.6),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
          ],

          if (evt.imagePaths.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.6),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                children: [
                  pw.Text('Media Assets Manifest: ', style: pw.TextStyle(font: fontBold, fontSize: 7.5, color: PdfColor.fromHex('#334155'))),
                  pw.Expanded(
                    child: pw.Text(
                      evt.imagePaths.map((p) => p.split(RegExp(r'[\\/]')).last).join(' / '),
                      style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: PdfColors.grey700),
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font, {double fontSize = 8.5, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(font: font, fontSize: fontSize, color: PdfColors.grey800),
      ),
    );
  }

  static pw.Widget _buildSignatureLine(String roleTitle, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(width: 140, height: 1, color: PdfColors.grey500),
        pw.SizedBox(height: 4),
        pw.Text(roleTitle, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey800)),
      ],
    );
  }

  static Future<Uint8List> generateSocietyDossier(PdfSocietyDossierData data) async {
    final pdf = pw.Document();

    pw.Font fontBold;
    pw.Font fontRegular;
    pw.Font fontMedium;
    try {
      fontBold = await PdfGoogleFonts.interBold();
      fontRegular = await PdfGoogleFonts.interRegular();
      fontMedium = await PdfGoogleFonts.interMedium();
    } catch (_) {
      fontBold = pw.Font.helveticaBold();
      fontRegular = pw.Font.helvetica();
      fontMedium = pw.Font.helvetica();
    }

    pw.MemoryImage? ydcLogo;
    pw.MemoryImage? alldotdevLogo;
    try {
      ByteData ydcData;
      try {
        ydcData = await rootBundle.load('assets/YDC_AUST.jpg');
      } catch (_) {
        ydcData = await rootBundle.load('assets/images/YDC_Aust.jpg');
      }
      ydcLogo = pw.MemoryImage(ydcData.buffer.asUint8List());
    } catch (_) {}

    try {
      final alldotdevData = await rootBundle.load('assets/images/Alldotdev.png');
      alldotdevLogo = pw.MemoryImage(alldotdevData.buffer.asUint8List());
    } catch (_) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (context) => _buildSocietyHeader(data, fontBold, fontRegular, ydcLogo),
        footer: (context) => _buildSocietyFooter(context, fontRegular, alldotdevLogo, data.societyName),
        build: (context) => [
          pw.SizedBox(height: 14),

          // Society Metadata & Metric Summary Banner
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(child: _buildMetricBox('Strategic Pillar', data.pillar, _getPillarPdfColor(data.pillar), fontBold, fontRegular)),
                pw.Expanded(child: _buildMetricBox('Executive Cabinet', '${data.cabinet.length} Officers', PdfColor.fromHex('#0D6EFD'), fontBold, fontRegular)),
                pw.Expanded(child: _buildMetricBox('Enrolled Members', '${data.members.length} Students', PdfColor.fromHex('#198754'), fontBold, fontRegular)),
                pw.Expanded(child: _buildMetricBox('Faculty Advisor', data.facultyAdvisor, PdfColor.fromHex('#111827'), fontBold, fontRegular)),
              ],
            ),
          ),

          pw.SizedBox(height: 18),

          // Section 1: Executive Cabinet Hierarchy
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('1. EXECUTIVE CABINET HIERARCHY (Tenure 2025-2026)', style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColor.fromHex('#111827'))),
              pw.Text('${data.cabinet.length} Officers Assigned', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
          pw.SizedBox(height: 8),
          if (data.cabinet.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
              child: pw.Text('No executive cabinet officers assigned to this society.', style: pw.TextStyle(font: fontRegular, fontSize: 9.5, color: PdfColors.grey700)),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E4E7EC'), width: 1),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                  children: [
                    _tableHeaderCell('Role / Office', fontBold),
                    _tableHeaderCell('Full Name', fontBold),
                    _tableHeaderCell('CNIC / Identification', fontBold),
                    _tableHeaderCell('Department', fontBold),
                    _tableHeaderCell('Semester', fontBold),
                    _tableHeaderCell('Contact Phone', fontBold),
                  ],
                ),
                ...data.cabinet.map((c) {
                  return pw.TableRow(
                    children: [
                      _tableCell(c.role, fontBold),
                      _tableCell(c.fullName, fontMedium),
                      _tableCell(c.cnic, fontRegular),
                      _tableCell(c.department, fontRegular),
                      _tableCell('Sem ${c.semester}', fontRegular),
                      _tableCell(c.phone.isEmpty ? 'N/A' : c.phone, fontRegular),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 20),

          // Section 2: Enrolled Student Members Roster
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('2. ENROLLED STUDENT MEMBERS ROSTER', style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColor.fromHex('#111827'))),
              pw.Text('${data.members.length} Enrolled Members', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
          pw.SizedBox(height: 8),
          if (data.members.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
              child: pw.Text('No student members enrolled in this chapter roster.', style: pw.TextStyle(font: fontRegular, fontSize: 9.5, color: PdfColors.grey700)),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E4E7EC'), width: 1),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                  children: [
                    _tableHeaderCell('#', fontBold),
                    _tableHeaderCell('Student Full Name', fontBold),
                    _tableHeaderCell('Roll Number', fontBold),
                    _tableHeaderCell('CNIC / B-Form', fontBold),
                    _tableHeaderCell('Department', fontBold),
                    _tableHeaderCell('Semester', fontBold),
                  ],
                ),
                ...List.generate(data.members.length, (i) {
                  final m = data.members[i];
                  return pw.TableRow(
                    children: [
                      _tableCell('${i + 1}', fontRegular),
                      _tableCell(m.fullName, fontMedium),
                      _tableCell(m.rollNo, fontRegular),
                      _tableCell(m.cnic, fontRegular),
                      _tableCell(m.department, fontRegular),
                      _tableCell('Sem ${m.semester}', fontRegular),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 36),

          // Formal Sign-off Section
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSignatureLine('Prepared By:\nCabinet President\n${data.societyName}', fontRegular),
              _buildSignatureLine('Verified By:\nPatron / Faculty Advisor\n${data.facultyAdvisor}', fontRegular),
              _buildSignatureLine('Approved By:\nDirector YDC AUST\nAbbottabad', fontRegular),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSocietyHeader(PdfSocietyDossierData data, pw.Font bold, pw.Font regular, pw.MemoryImage? logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#198754'), width: 2.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logo != null)
                  pw.Container(
                    width: 44,
                    height: 44,
                    margin: const pw.EdgeInsets.only(right: 12),
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        'ABBOTTABAD UNIVERSITY OF SCIENCE & TECHNOLOGY',
                        style: pw.TextStyle(font: bold, fontSize: 10.5, color: PdfColor.fromHex('#198754')),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Youth Development Center (YDC) - ${data.societyName}',
                        style: pw.TextStyle(font: bold, fontSize: 12, color: PdfColor.fromHex('#111827')),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${data.pillar.toUpperCase()} PILLAR | OFFICIAL CHAPTER DOSSIER & ROSTER',
                        style: pw.TextStyle(font: regular, fontSize: 8.5, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#198754'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              data.monthYear,
              style: pw.TextStyle(font: bold, fontSize: 11, color: PdfColors.white),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSocietyFooter(pw.Context context, pw.Font regular, pw.MemoryImage? alldotdevLogo, String societyName) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColor.fromHex('#E4E7EC'), width: 1))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (alldotdevLogo != null)
                pw.Container(
                  height: 12,
                  margin: const pw.EdgeInsets.only(right: 6),
                  child: pw.Image(alldotdevLogo, fit: pw.BoxFit.contain),
                ),
              pw.Text('YDC AUST ERP System | Chapter Dossier: $societyName', style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static PdfColor _getPillarPdfColor(String pillar) {
    switch (pillar.toLowerCase()) {
      case 'education': return PdfColor.fromHex('#0D6EFD');
      case 'employment': return PdfColor.fromHex('#198754');
      case 'engagement': return PdfColor.fromHex('#FFB300');
      case 'environment': return PdfColor.fromHex('#2E7D32');
      default: return PdfColor.fromHex('#198754');
    }
  }

  static Future<Uint8List> generateEventArchivePdf(PdfEventArchiveData data) async {
    final pdf = pw.Document();

    pw.Font fontBold;
    pw.Font fontRegular;
    pw.Font fontMedium;
    try {
      fontBold = await PdfGoogleFonts.interBold();
      fontRegular = await PdfGoogleFonts.interRegular();
      fontMedium = await PdfGoogleFonts.interMedium();
    } catch (_) {
      fontBold = pw.Font.helveticaBold();
      fontRegular = pw.Font.helvetica();
      fontMedium = pw.Font.helvetica();
    }

    pw.MemoryImage? ydcLogo;
    pw.MemoryImage? alldotdevLogo;
    try {
      ByteData ydcData;
      try {
        ydcData = await rootBundle.load('assets/YDC_AUST.jpg');
      } catch (_) {
        ydcData = await rootBundle.load('assets/images/YDC_Aust.jpg');
      }
      ydcLogo = pw.MemoryImage(ydcData.buffer.asUint8List());
    } catch (_) {}

    try {
      final alldotdevData = await rootBundle.load('assets/images/Alldotdev.png');
      alldotdevLogo = pw.MemoryImage(alldotdevData.buffer.asUint8List());
    } catch (_) {}

    final dateFmt = DateFormat('EEEE, MMMM d, yyyy');
    final currencyFmt = NumberFormat('#,##0');
    final pillarColor = _getPillarPdfColor(data.pillar);
    final variance = data.allocatedBudget - data.actualExpense;
    final isUnderBudget = variance >= 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#E2E8F0'), width: 1.5)),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (ydcLogo != null)
                pw.Container(
                  width: 44,
                  height: 44,
                  margin: const pw.EdgeInsets.only(right: 12),
                  child: pw.Image(ydcLogo, fit: pw.BoxFit.contain),
                ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ABBOTTABAD UNIVERSITY OF SCIENCE AND TECHNOLOGY',
                      style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColor.fromHex('#475569')),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'DIRECTORATE OF YOUTH DEVELOPMENT CENTRE (YDC)',
                      style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColor.fromHex('#0F172A')),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Official Event Archive & Institutional Audit Record',
                      style: pw.TextStyle(font: fontMedium, fontSize: 9, color: PdfColor.fromHex('#64748B')),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#ECFDF5'),
                  border: pw.Border.all(color: PdfColor.fromHex('#10B981')),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Text(
                  'CONFIDENTIAL VAULT SEALED',
                  style: pw.TextStyle(font: fontBold, fontSize: 7.5, color: PdfColor.fromHex('#047857')),
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 14),
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColor.fromHex('#E2E8F0')))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  if (alldotdevLogo != null)
                    pw.Container(
                      height: 12,
                      margin: const pw.EdgeInsets.only(right: 6),
                      child: pw.Image(alldotdevLogo, fit: pw.BoxFit.contain),
                    ),
                  pw.Text('YDC AUST ERP System | AES-256-GCM Encrypted Vault Record', style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
              pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 14),

          // Event Header Title Banner
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: pillarColor,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        '${data.societyName.toUpperCase()} | ${data.pillar.toUpperCase()}',
                        style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.white),
                      ),
                    ),
                    pw.Text(
                      dateFmt.format(data.eventDate),
                      style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: PdfColor.fromHex('#334155')),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  data.title,
                  style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColor.fromHex('#0F172A')),
                ),
                if (data.venue != null && data.venue!.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Venue: ${data.venue}',
                    style: pw.TextStyle(font: fontRegular, fontSize: 9.5, color: PdfColor.fromHex('#64748B')),
                  ),
                ],
                if (data.isCollaboration) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Institutional Collaboration: ${data.collaboratorNames ?? "External Partner Organizations"}',
                    style: pw.TextStyle(font: fontMedium, fontSize: 9, color: PdfColor.fromHex('#2563EB')),
                  ),
                ],
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Financial & Attendance Audit Metrics
          pw.Text('1. EXECUTIVE & FISCAL AUDIT METRICS', style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: PdfColor.fromHex('#111827'))),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(child: _buildMetricBox('Allocated Budget', 'Rs. ${currencyFmt.format(data.allocatedBudget)}', PdfColor.fromHex('#0D6EFD'), fontBold, fontRegular)),
                pw.Expanded(child: _buildMetricBox('Actual Expenditure', 'Rs. ${currencyFmt.format(data.actualExpense)}', PdfColor.fromHex('#198754'), fontBold, fontRegular)),
                pw.Expanded(child: _buildMetricBox('Fiscal Variance', '${isUnderBudget ? "+" : ""}${currencyFmt.format(variance)} (${isUnderBudget ? "Under" : "Over"})', isUnderBudget ? PdfColor.fromHex('#10B981') : PdfColor.fromHex('#EF4444'), fontBold, fontRegular)),
                pw.Expanded(child: _buildMetricBox('Attendees Registered', '${data.attendeesCount} Students', PdfColor.fromHex('#7C3AED'), fontBold, fontRegular)),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Narrative & Scope
          pw.Text('2. EVENT EXECUTIVE NARRATIVE & SCOPE', style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: PdfColor.fromHex('#111827'))),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
            ),
            child: pw.Text(
              data.description,
              style: pw.TextStyle(font: fontRegular, fontSize: 9.5, color: PdfColor.fromHex('#334155'), lineSpacing: 2),
            ),
          ),

          if (data.positiveImpactSummary != null && data.positiveImpactSummary!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text('3. INSTITUTIONAL IMPACT ASSESSMENT', style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: PdfColor.fromHex('#111827'))),
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F0FDF4'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: PdfColor.fromHex('#86EFAC')),
              ),
              child: pw.Text(
                data.positiveImpactSummary!,
                style: pw.TextStyle(font: fontMedium, fontSize: 9.5, color: PdfColor.fromHex('#166534'), lineSpacing: 1.5),
              ),
            ),
          ],

          if (data.speakers.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text('4. KEYNOTE SPEAKERS & RESOURCE PERSONS ROSTER', style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: PdfColor.fromHex('#111827'))),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('#', style: pw.TextStyle(font: fontBold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Speaker Name', style: pw.TextStyle(font: fontBold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Designation / Office', style: pw.TextStyle(font: fontBold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Organization / Affiliation', style: pw.TextStyle(font: fontBold, fontSize: 9))),
                  ],
                ),
                ...data.speakers.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final spk = entry.value;
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('$idx', style: pw.TextStyle(font: fontRegular, fontSize: 8.5))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(spk['name'] ?? '', style: pw.TextStyle(font: fontBold, fontSize: 8.5))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(spk['designation'] ?? 'Keynote Speaker', style: pw.TextStyle(font: fontRegular, fontSize: 8.5))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(spk['organization'] ?? 'External Entity', style: pw.TextStyle(font: fontRegular, fontSize: 8.5))),
                    ],
                  );
                }),
              ],
            ),
          ],

          if (data.imagePaths.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text('5. ATTACHED PROMOTIONAL MEDIA & GRAPHICS MANIFEST', style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: PdfColor.fromHex('#111827'))),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                color: PdfColor.fromHex('#F8FAFC'),
              ),
              child: pw.Row(
                children: [
                  pw.Text('${data.imagePaths.length} Promotional Graphics Attached to Record: ', style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColor.fromHex('#334155'))),
                  pw.Expanded(
                    child: pw.Text(
                      data.imagePaths.map((p) => p.split(RegExp(r'[\\/]')).last).join(' | '),
                      style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColor.fromHex('#64748B')),
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return pdf.save();
  }
}
