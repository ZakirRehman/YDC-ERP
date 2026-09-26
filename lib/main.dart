import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/database/app_database.dart';
import 'core/database/database_seeder.dart';
import 'core/widgets/desktop_sidebar.dart';
import 'core/widgets/custom_top_bar.dart';
import 'core/widgets/ui_state_widgets.dart';
import 'core/services/ocr/sheet_parser.dart';

import 'core/ui/ui_scale_state.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/societies/presentation/screens/societies_screen.dart';
import 'features/events/presentation/screens/events_screen.dart';
import 'features/ingestion/presentation/screens/sheet_scan_screen.dart';
import 'features/records/presentation/screens/records_screen.dart';
import 'features/vault/presentation/screens/vault_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop Shell Configuration with adaptive display bounding
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    try {
      await windowManager.ensureInitialized();

      // Dynamically calculate initial window bounds fitting current display work-area
      final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
      Size initialSize = const Size(1260, 750);
      if (view != null) {
        final screenWidth = view.physicalSize.width / view.devicePixelRatio;
        final screenHeight = view.physicalSize.height / view.devicePixelRatio;
        final w = (screenWidth * 0.92).clamp(860.0, 1340.0);
        final h = (screenHeight * 0.88).clamp(560.0, 820.0);
        initialSize = Size(w, h);
      }

      final windowOptions = WindowOptions(
        size: initialSize,
        minimumSize: const Size(800, 500),
        center: true,
        backgroundColor: AppColors.surfaceBg,
        skipTaskbar: false,
        title: 'Youth Development Center (YDC) — Abbottabad University ERP',
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setBackgroundColor(AppColors.surfaceBg);
        try {
          await windowManager.setIcon('assets/YDC_AUST.jpg');
        } catch (_) {}
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (e) {
      debugPrint('[WindowManager] Initialization notice: $e');
    }
  }

  runApp(const ProviderScope(child: YdcApp()));
}

class YdcApp extends StatelessWidget {
  const YdcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YDC AUST ERP System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Container(
          color: AppColors.surfaceBg,
          width: double.infinity,
          height: double.infinity,
          child: UiScaleWrapper(child: child!),
        );
      },
      home: const AppBootstrapper(),
    );
  }
}

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  bool _isInitialized = false;
  late AppDatabase _database;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  Future<void> _initializeApplication() async {
    // 1. Seed initial data if database is fresh
    await DatabaseSeeder.seedIfEmpty(_database);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return SplashScreen(
        onInitialize: _initializeApplication,
        onInitComplete: () {
          setState(() {
            _isInitialized = true;
          });
        },
      );
    }

    return DesktopMainShell(database: _database);
  }
}

class DesktopMainShell extends StatefulWidget {
  final AppDatabase database;

  const DesktopMainShell({super.key, required this.database});

  @override
  State<DesktopMainShell> createState() => _DesktopMainShellState();
}

class _DesktopMainShellState extends State<DesktopMainShell> {
  NavSection _currentSection = NavSection.dashboard;
  DashboardStats _dashboardStats = DashboardStats(
    totalSocieties: 0,
    totalMembers: 0,
    totalEvents: 0,
    vaultDocsCount: 0,
    totalBudgetSpent: 0.0,
    pillarSocieties: {
      'Education': 0,
      'Employment': 0,
      'Engagement': 0,
      'Environment': 0,
    },
    pillarMembers: {
      'Education': 0,
      'Employment': 0,
      'Engagement': 0,
      'Environment': 0,
    },
  );
  List<Map<String, String>> _societiesMeta = [];

  @override
  void initState() {
    super.initState();
    _refreshAggregates();
  }

  Future<void> _refreshAggregates() async {
    try {
      final socs = await widget.database.select(widget.database.societies).get();
      final mems =
          await widget.database.select(widget.database.societyMembers).get();
      final evts = await widget.database.select(widget.database.events).get();
      final vault =
          await widget.database.select(widget.database.confidentialVault).get();
      final finances =
          await widget.database.select(widget.database.financialRecords).get();

      final Map<String, int> pSocs = {
        'Education': socs.where((s) => s.pillar == 'Education').length,
        'Employment': socs.where((s) => s.pillar == 'Employment').length,
        'Engagement': socs.where((s) => s.pillar == 'Engagement').length,
        'Environment': socs.where((s) => s.pillar == 'Environment').length,
      };

      final Map<String, Society> sMap = {for (var s in socs) s.id: s};
      final Map<String, int> pMems = {
        'Education': 0,
        'Employment': 0,
        'Engagement': 0,
        'Environment': 0
      };
      for (var m in mems) {
        final pillar = sMap[m.societyId]?.pillar ?? 'Education';
        pMems[pillar] = (pMems[pillar] ?? 0) + 1;
      }

      double totalBudget = 0;
      for (var f in finances) {
        if (f.type.toLowerCase() == 'expense') {
          totalBudget += f.amount;
        }
      }

      if (mounted) {
        final Map<String, Map<String, String>> uniqueMeta = {};
        for (final s in socs) {
          uniqueMeta[s.id] = {'id': s.id, 'name': s.name, 'pillar': s.pillar};
        }

        final recentEventItems = evts.take(4).map((e) {
          final soc = sMap[e.societyId];
          final pillar = soc?.pillar ?? 'Engagement';
          return DashboardEventItem(
            title: e.title,
            hostSociety: soc?.name ?? 'YDC Directorate',
            meta: '${e.venue ?? 'Auditorium'} • ${e.attendeesCount} Attendees',
            pillarColor: AppColors.getPillarColor(pillar),
          );
        }).toList();

        setState(() {
          _societiesMeta = uniqueMeta.values.toList();
          _dashboardStats = DashboardStats(
            totalSocieties: uniqueMeta.length,
            totalMembers: mems.length,
            totalEvents: evts.length,
            vaultDocsCount: vault.length,
            totalBudgetSpent: totalBudget,
            pillarSocieties: pSocs,
            pillarMembers: pMems,
            recentEvents: recentEventItems,
          );
        });
      }
    } catch (_) {
      // Fallback silently or preserve existing stats
    }
  }

  Future<void> _handleCommitRoster(
      String societyId, List<ParsedStudentRecord> records) async {
    try {
      const uuid = Uuid();
      await widget.database.batch((batch) {
        for (final r in records) {
          if (r.isExecutive) {
            batch.insert(
              widget.database.cabinetMembers,
              CabinetMembersCompanion.insert(
                id: uuid.v4(),
                societyId: societyId,
                tenureSession: '2025-2026',
                role: r.role.trim().isEmpty ? 'Executive Member' : r.role.trim(),
                fullName: r.name,
                cnic: r.cnic.trim().isEmpty ? '13101-0000000-0' : r.cnic.trim(),
                email: 'student@aust.edu.pk',
                phone: r.phone.trim().isEmpty ? '0300-0000000' : r.phone.trim(),
                department: r.department,
                semester: r.semester,
              ),
            );
          } else {
            batch.insert(
              widget.database.societyMembers,
              SocietyMembersCompanion.insert(
                id: uuid.v4(),
                societyId: societyId,
                fullName: r.name,
                rollNo: r.rollNo,
                cnic: r.cnic.trim().isEmpty ? '13101-0000000-0' : r.cnic.trim(),
                department: r.department,
                semester: r.semester,
                phone: drift.Value(r.phone.isEmpty ? null : r.phone),
              ),
            );
          }
        }
      });
      await _refreshAggregates();
    } catch (e) {
      if (mounted) {
        UiNotification.error(context, 'Failed to save student records: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SizedBox.expand(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left 80px Fixed ERP Navigation Dock
            DesktopSidebar(
              currentSection: _currentSection,
              onSectionSelected: (sec) {
                setState(() => _currentSection = sec);
                _refreshAggregates();
              },
            ),

            // Main Viewport (TopBar + Current Section View)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TopBar with Abbottabad time & Quick Actions
                  CustomTopBar(
                    onQuickIngestion: () {
                      setState(() => _currentSection = NavSection.ingestion);
                    },
                  ),

                  // Active Modular View
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _buildCurrentView(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentSection) {
      case NavSection.dashboard:
        return DashboardScreen(
          key: const ValueKey('dashboard'),
          stats: _dashboardStats,
          onNavigateToSocieties: () =>
              setState(() => _currentSection = NavSection.societies),
          onNavigateToEvents: () =>
              setState(() => _currentSection = NavSection.events),
          onNavigateToIngestion: () =>
              setState(() => _currentSection = NavSection.ingestion),
          onNavigateToRecords: () =>
              setState(() => _currentSection = NavSection.records),
          onNavigateToVault: () =>
              setState(() => _currentSection = NavSection.vault),
        );
      case NavSection.societies:
        return SocietiesScreen(
          key: const ValueKey('societies'),
          database: widget.database,
          onTriggerIngestion: () =>
              setState(() => _currentSection = NavSection.ingestion),
          onEventPosted: _refreshAggregates,
        );
      case NavSection.events:
        return EventsScreen(
          key: const ValueKey('events'),
          database: widget.database,
        );
      case NavSection.ingestion:
        return SheetScanScreen(
          key: const ValueKey('ingestion'),
          societies: _societiesMeta,
          onCommitRoster: _handleCommitRoster,
        );
      case NavSection.records:
        return RecordsScreen(
          key: const ValueKey('records'),
          database: widget.database,
        );
      case NavSection.vault:
        return VaultScreen(
          key: const ValueKey('vault'),
          database: widget.database,
        );
    }
  }
}
