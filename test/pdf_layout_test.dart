import 'package:flutter_test/flutter_test.dart';
import 'package:ydc_aust/core/services/reporting/pdf_dossier_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PdfDossierService compiles with short and long month names', () async {
    for (final month in ['May 2026', 'September 2026', 'November 2026', 'September 2024']) {
      final data = PdfDossierData(
        monthYear: month,
        totalSocieties: 6,
        totalMembers: 42,
        totalEvents: 2,
        totalAttendees: 800,
        totalBudgetSpent: 113000,
        totalSponsorships: 500000,
        pillarDistribution: {
          'Education': 2,
          'Employment': 1,
          'Engagement': 2,
          'Environment': 1,
        },
        achievements: [
          {'title': 'Green Campus Drive', 'description': '500 trees planted.'},
        ],
        financialItems: [
          {'title': 'HEC Grant', 'amount': 350000.0, 'type': 'Grant'},
        ],
      );

      final pdfBytes = await PdfDossierService.generateMonthlyDossier(data);
      expect(pdfBytes, isNotEmpty);
    }
  });

  test('PdfDossierService compiles Monthly Dossier with Section 4 Concluded Events Summary', () async {
    final concludedEvents = [
      PdfConcludedEventItem(
        title: 'AUST Tech Olympiad 2026',
        date: DateTime(2026, 9, 10),
        hostSociety: 'Computer Science Guild (Education)',
        attendeesCount: 450,
        allocatedBudget: 120000.0,
        actualExpense: 95000.0,
      ),
      PdfConcludedEventItem(
        title: 'Green Campus Eco Drive',
        date: DateTime(2026, 9, 18),
        hostSociety: 'Eco Protection Society (Environment)',
        attendeesCount: 300,
        allocatedBudget: 50000.0,
        actualExpense: 48000.0,
      ),
    ];

    final data = PdfDossierData(
      monthYear: 'September 2026',
      totalSocieties: 6,
      totalMembers: 120,
      totalEvents: 4,
      totalAttendees: 750,
      totalBudgetSpent: 143000,
      totalSponsorships: 300000,
      pillarDistribution: {
        'Education': 2,
        'Employment': 1,
        'Engagement': 2,
        'Environment': 1,
      },
      achievements: [
        {'title': 'Olympiad Success', 'description': '12 universities attended'},
      ],
      financialItems: [
        {'title': 'Sponsorship Inflow', 'amount': 300000.0, 'type': 'Sponsorship'},
      ],
      concludedEvents: concludedEvents,
    );

    final pdfBytes = await PdfDossierService.generateMonthlyDossier(data);
    expect(pdfBytes, isNotEmpty);
    final header = String.fromCharCodes(pdfBytes.take(4));
    expect(header, equals('%PDF'));
  });

  test('PdfDossierService compiles Monthly Dossier with empty concluded events fallback', () async {
    final data = PdfDossierData(
      monthYear: 'September 2026',
      totalSocieties: 6,
      totalMembers: 120,
      totalEvents: 0,
      totalAttendees: 0,
      totalBudgetSpent: 0,
      totalSponsorships: 0,
      pillarDistribution: {
        'Education': 2,
        'Employment': 1,
        'Engagement': 2,
        'Environment': 1,
      },
      achievements: [],
      financialItems: [],
      concludedEvents: [],
    );

    final pdfBytes = await PdfDossierService.generateMonthlyDossier(data);
    expect(pdfBytes, isNotEmpty);
    final header = String.fromCharCodes(pdfBytes.take(4));
    expect(header, equals('%PDF'));
  });
}
