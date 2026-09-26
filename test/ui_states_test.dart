import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ydc_aust/core/constants/app_colors.dart';
import 'package:ydc_aust/core/widgets/ui_state_widgets.dart';
import 'package:ydc_aust/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  group('UI States & Widget Architecture Unit Tests', () {
    testWidgets('UiEmptyState renders title, message, and responds to CTA tap', (tester) async {
      bool actionTapped = false;
      bool secondaryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UiEmptyState(
              icon: LucideIcons.building2,
              title: 'No Societies Found',
              message: 'Register a new society to begin institutional management.',
              actionLabel: 'Create Society',
              actionIcon: LucideIcons.plus,
              onAction: () => actionTapped = true,
              secondaryActionLabel: 'View Archives',
              onSecondaryAction: () => secondaryTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No Societies Found'), findsOneWidget);
      expect(find.text('Register a new society to begin institutional management.'), findsOneWidget);
      expect(find.text('Create Society'), findsOneWidget);
      expect(find.text('View Archives'), findsOneWidget);

      await tester.tap(find.text('Create Society'));
      await tester.pump();
      expect(actionTapped, isTrue);

      await tester.tap(find.text('View Archives'));
      await tester.pump();
      expect(secondaryTapped, isTrue);
    });

    testWidgets('UiLoadingState renders progress indicator and description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UiLoadingState(
              message: 'Encrypting Vault Asset...',
              subMessage: 'Applying AES-256-GCM cipher envelope',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Encrypting Vault Asset...'), findsOneWidget);
      expect(find.text('Applying AES-256-GCM cipher envelope'), findsOneWidget);
    });

    testWidgets('UiErrorState renders error warning and triggers retry', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UiErrorState(
              errorMessage: 'Failed to access encrypted vault file',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('An Error Occurred'), findsOneWidget);
      expect(find.text('Failed to access encrypted vault file'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();
      expect(retryPressed, isTrue);
    });

    testWidgets('UiStatusBadge renders various status states accurately', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                UiStatusBadge.active(),
                UiStatusBadge.warning(),
                UiStatusBadge.danger(),
                UiStatusBadge.info(label: 'Custom Info'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Requires Review'), findsOneWidget);
      expect(find.text('Inactive / Expired'), findsOneWidget);
      expect(find.text('Custom Info'), findsOneWidget);
    });

    test('DashboardStats correctly encapsulates dynamic recent events', () {
      final stats = DashboardStats(
        totalSocieties: 5,
        totalMembers: 120,
        totalEvents: 8,
        vaultDocsCount: 4,
        totalBudgetSpent: 250000,
        pillarSocieties: {'Education': 2, 'Environment': 3},
        pillarMembers: {'Education': 60, 'Environment': 60},
        recentEvents: const [
          DashboardEventItem(
            title: 'Tech Symposium 2026',
            hostSociety: 'Computer Society',
            meta: 'Main Hall • 200 Attendees',
            pillarColor: AppColors.pillarEducation,
          ),
        ],
      );

      expect(stats.totalSocieties, 5);
      expect(stats.totalMembers, 120);
      expect(stats.recentEvents.length, 1);
      expect(stats.recentEvents.first.title, 'Tech Symposium 2026');
      expect(stats.recentEvents.first.hostSociety, 'Computer Society');
    });

    testWidgets('DashboardScreen displays Rs. 0 and No Expenses Logged when budget spent is 0', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final zeroStats = DashboardStats(
        totalSocieties: 4,
        totalMembers: 40,
        totalEvents: 1,
        vaultDocsCount: 1,
        totalBudgetSpent: 0.0,
        pillarSocieties: {'Education': 4},
        pillarMembers: {'Education': 40},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardScreen(
              stats: zeroStats,
              onNavigateToSocieties: () {},
              onNavigateToEvents: () {},
              onNavigateToIngestion: () {},
              onNavigateToRecords: () {},
              onNavigateToVault: () {},
            ),
          ),
        ),
      );

      expect(find.text('Rs. 0'), findsOneWidget);
      expect(find.text('No Expenses Logged'), findsOneWidget);
    });

    testWidgets('DashboardScreen formats non-zero budget deployed accurately', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final expenseStats = DashboardStats(
        totalSocieties: 4,
        totalMembers: 40,
        totalEvents: 1,
        vaultDocsCount: 1,
        totalBudgetSpent: 68000.0,
        pillarSocieties: {'Education': 4},
        pillarMembers: {'Education': 40},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardScreen(
              stats: expenseStats,
              onNavigateToSocieties: () {},
              onNavigateToEvents: () {},
              onNavigateToIngestion: () {},
              onNavigateToRecords: () {},
              onNavigateToVault: () {},
            ),
          ),
        ),
      );

      expect(find.text('Rs. 68,000'), findsOneWidget);
      expect(find.text('Monthly Fiscal Log'), findsOneWidget);
    });

    testWidgets('Dropdown with long text item renders safely within w=166 BoxConstraints without RenderFlex overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 166.0,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: 'Institutional Allocation',
                  items: ['Expense', 'Sponsorship', 'Grant', 'Institutional Allocation']
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      // Verify widget builds without any overflow exception
      expect(tester.takeException(), isNull);
      expect(find.text('Institutional Allocation'), findsOneWidget);
    });

    testWidgets('Corrupted image payload renders graceful UiErrorState via errorBuilder without throwing Invalid image data exception', (tester) async {
      final corruptBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x99, 0x88, 0x77]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Image.memory(
              corruptBytes,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const UiErrorState(
                  errorMessage: 'Failed to display image data. The image payload may be corrupt or formatted improperly.',
                  onRetry: null,
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Ensure no raw unhandled exception is thrown
      expect(tester.takeException(), isNull);
      expect(find.text('An Error Occurred'), findsOneWidget);
      expect(find.text('Failed to display image data. The image payload may be corrupt or formatted improperly.'), findsOneWidget);
    });
  });
}
