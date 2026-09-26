import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/ui_state_widgets.dart';

class DashboardEventItem {
  final String title;
  final String hostSociety;
  final String meta;
  final Color pillarColor;

  const DashboardEventItem({
    required this.title,
    required this.hostSociety,
    required this.meta,
    required this.pillarColor,
  });
}

class DashboardStats {
  final int totalSocieties;
  final int totalMembers;
  final int totalEvents;
  final int vaultDocsCount;
  final double totalBudgetSpent;
  final Map<String, int> pillarSocieties;
  final Map<String, int> pillarMembers;
  final List<DashboardEventItem> recentEvents;

  DashboardStats({
    required this.totalSocieties,
    required this.totalMembers,
    required this.totalEvents,
    required this.vaultDocsCount,
    required this.totalBudgetSpent,
    required this.pillarSocieties,
    required this.pillarMembers,
    this.recentEvents = const [],
  });
}

class DashboardScreen extends StatefulWidget {
  final DashboardStats stats;
  final VoidCallback onNavigateToSocieties;
  final VoidCallback onNavigateToEvents;
  final VoidCallback onNavigateToIngestion;
  final VoidCallback onNavigateToRecords;
  final VoidCallback onNavigateToVault;

  const DashboardScreen({
    super.key,
    required this.stats,
    required this.onNavigateToSocieties,
    required this.onNavigateToEvents,
    required this.onNavigateToIngestion,
    required this.onNavigateToRecords,
    required this.onNavigateToVault,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title & Quick Metric Sub-Header
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 680;
                const titleWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Executive Operational Dashboard',
                      style: AppTypography.heading1,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Centralized institutional governance across the 4 Strategic YDC Pillars.',
                      style: AppTypography.subHeader,
                    ),
                  ],
                );

                final exportButton = OutlinedButton.icon(
                  onPressed: widget.onNavigateToRecords,
                  icon: const Icon(LucideIcons.fileText, size: 16),
                  label: const Text('Export Monthly Dossier'),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleWidget,
                      const SizedBox(height: 12),
                      exportButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    const Expanded(child: titleWidget),
                    const SizedBox(width: 12),
                    exportButton,
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Top Hero Row: [ Dark Hero Analytical Card ] + [ Pillar Matrix Card ]
            // Responsive: Adapts to vertical stacking on narrow/zoomed displays
            LayoutBuilder(
              builder: (context, constraints) {
                final isStacked = constraints.maxWidth < 960;

                if (isStacked) {
                  return Column(
                    children: [
                      _buildDarkHeroCard(),
                      const SizedBox(height: 20),
                      _buildOperationalMatrixCard(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildDarkHeroCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 6, child: _buildOperationalMatrixCard()),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Middle Shelf: 5 Modular KPI Indicator Cards
            _buildKpiShelf(),

            const SizedBox(height: 20),

            // Lower Row: Recent Activity & Quick Action Launcher
            // Responsive: Stacks vertically on narrow widths to prevent horizontal overflow
            LayoutBuilder(
              builder: (context, constraints) {
                final isStacked = constraints.maxWidth < 960;

                if (isStacked) {
                  return Column(
                    children: [
                      _buildRecentEventsCard(),
                      const SizedBox(height: 20),
                      _buildIngestionPillarsCard(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildRecentEventsCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: _buildIngestionPillarsCard()),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkHero,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pillarEnvironment.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'INSTITUTIONAL METRIC RATIO',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pillarEnvironment,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(LucideIcons.activity, color: Colors.white60, size: 18),
            ],
          ),

          const SizedBox(height: 16),

          // Total Enrolled Large Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                widget.stats.totalMembers.toString(),
                style: AppTypography.heroMetric,
              ),
              const SizedBox(width: 10),
              const Text(
                'Total Active Students',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Donut Chart & Pillar Legends
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedPieIndex = -1;
                              return;
                            }
                            _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 3,
                      centerSpaceRadius: 42,
                      sections: _generatePieChartSections(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legendItem('Education', AppColors.pillarEducation, '${widget.stats.pillarSocieties['Education'] ?? 0} Chapters'),
                      const SizedBox(height: 6),
                      _legendItem('Employment', AppColors.pillarEmployment, '${widget.stats.pillarSocieties['Employment'] ?? 0} Chapters'),
                      const SizedBox(height: 6),
                      _legendItem('Engagement', AppColors.pillarEngagement, '${widget.stats.pillarSocieties['Engagement'] ?? 0} Chapters'),
                      const SizedBox(height: 6),
                      _legendItem('Environment', AppColors.pillarEnvironment, '${widget.stats.pillarSocieties['Environment'] ?? 0} Chapters'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections() {
    final pillars = [
      {'name': 'Education', 'color': AppColors.pillarEducation, 'val': widget.stats.pillarMembers['Education'] ?? 1},
      {'name': 'Employment', 'color': AppColors.pillarEmployment, 'val': widget.stats.pillarMembers['Employment'] ?? 1},
      {'name': 'Engagement', 'color': AppColors.pillarEngagement, 'val': widget.stats.pillarMembers['Engagement'] ?? 1},
      {'name': 'Environment', 'color': AppColors.pillarEnvironment, 'val': widget.stats.pillarMembers['Environment'] ?? 1},
    ];

    return List.generate(pillars.length, (i) {
      final isTouched = i == _touchedPieIndex;
      final radius = isTouched ? 34.0 : 28.0;
      final val = (pillars[i]['val'] as int).toDouble();

      return PieChartSectionData(
        color: pillars[i]['color'] as Color,
        value: val > 0 ? val : 1.0,
        title: '',
        radius: radius,
      );
    });
  }

  Widget _legendItem(String title, Color color, String sub) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          sub,
          style: const TextStyle(fontSize: 11, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildOperationalMatrixCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Pillar Operational Matrix',
                style: AppTypography.cardHeading,
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onNavigateToSocieties,
                child: const Row(
                  children: [
                    Text('Manage Chapters', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(LucideIcons.arrowRight, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Operational Matrix Table
          Table(
            border: TableBorder.all(color: AppColors.borderSubtle, borderRadius: BorderRadius.circular(8)),
            columnWidths: const {
              0: FlexColumnWidth(4),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(3),
              3: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  _tableHeader('Strategic Pillar'),
                  _tableHeader('Societies'),
                  _tableHeader('Enrollments'),
                  _tableHeader('Health Status'),
                ],
              ),
              _matrixRow('Education', AppColors.pillarEducation, widget.stats.pillarSocieties['Education'] ?? 0, widget.stats.pillarMembers['Education'] ?? 0),
              _matrixRow('Employment', AppColors.pillarEmployment, widget.stats.pillarSocieties['Employment'] ?? 0, widget.stats.pillarMembers['Employment'] ?? 0),
              _matrixRow('Engagement', AppColors.pillarEngagement, widget.stats.pillarSocieties['Engagement'] ?? 0, widget.stats.pillarMembers['Engagement'] ?? 0),
              _matrixRow('Environment', AppColors.pillarEnvironment, widget.stats.pillarSocieties['Environment'] ?? 0, widget.stats.pillarMembers['Environment'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _matrixRow(String pillar, Color color, int societies, int members) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  pillar,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Text('$societies Chapters', style: AppTypography.body, overflow: TextOverflow.ellipsis),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Text('$members Students', style: AppTypography.body, overflow: TextOverflow.ellipsis),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.checkCircle2, size: 14, color: AppColors.pillarEnvironment),
                SizedBox(width: 4),
                Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.pillarEnvironment)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildKpiShelf() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _kpiCard(
            title: 'Total Societies',
            value: widget.stats.totalSocieties.toString(),
            sub: 'Across 4 Pillars',
            icon: LucideIcons.building2,
            color: AppColors.pillarEducation,
            onTap: widget.onNavigateToSocieties,
          ),
          const SizedBox(width: 14),
          _kpiCard(
            title: 'Total Events Hosted',
            value: widget.stats.totalEvents.toString(),
            sub: 'Institutional & Co-Host',
            icon: LucideIcons.calendar,
            color: AppColors.pillarEngagement,
            onTap: widget.onNavigateToEvents,
          ),
          const SizedBox(width: 14),
          _kpiCard(
            title: 'Omni Ingestions',
            value: '3 Pipelines',
            sub: 'Manual, CSV & OCR',
            icon: LucideIcons.scanLine,
            color: AppColors.brandPurple,
            onTap: widget.onNavigateToIngestion,
          ),
          const SizedBox(width: 14),
          _kpiCard(
            title: 'Encrypted Vault',
            value: '${widget.stats.vaultDocsCount} Docs',
            sub: 'AES-256 Protected',
            icon: LucideIcons.shieldCheck,
            color: AppColors.pillarEnvironment,
            onTap: widget.onNavigateToVault,
          ),
          const SizedBox(width: 14),
          _kpiCard(
            title: 'Budget Deployed',
            value: widget.stats.totalBudgetSpent > 0
                ? NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0).format(widget.stats.totalBudgetSpent)
                : 'Rs. 0',
            sub: widget.stats.totalBudgetSpent > 0 ? 'Monthly Fiscal Log' : 'No Expenses Logged',
            icon: LucideIcons.wallet,
            color: AppColors.pillarEmployment,
            onTap: widget.onNavigateToRecords,
          ),
        ];

        if (constraints.maxWidth < 950) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1050,
              child: Row(children: cards),
            ),
          );
        }

        return Row(children: cards);
      },
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.subHeader,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(icon, size: 16, color: color),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: AppTypography.bodyMuted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentEventsCard() {
    final events = widget.stats.recentEvents;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Upcoming & Recent Institutional Events',
                  style: AppTypography.cardHeading,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: widget.onNavigateToEvents,
                child: const Text('View All Events', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (events.isEmpty)
            UiEmptyState(
              icon: LucideIcons.calendar,
              iconSize: 28,
              title: 'No Events Scheduled',
              message: 'Campus events registered by societies will display here in real time.',
              actionLabel: 'Schedule Event',
              actionIcon: LucideIcons.calendarPlus,
              onAction: widget.onNavigateToEvents,
            )
          else
            ...List.generate(events.length, (i) {
              final evt = events[i];
              return Column(
                children: [
                  if (i > 0) const Divider(height: 16),
                  _eventListItem(evt.title, evt.hostSociety, evt.meta, evt.pillarColor),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _eventListItem(String title, String host, String meta, Color pillarColor) {
    return InkWell(
      onTap: widget.onNavigateToEvents,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(color: pillarColor, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$host • $meta',
                    style: AppTypography.bodyMuted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildIngestionPillarsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Omni-Channel Ingestion Pipeline', style: AppTypography.cardHeading),
          const SizedBox(height: 4),
          const Text('Rapidly onboard student rosters via 3 native channels.', style: AppTypography.bodyMuted),
          const SizedBox(height: 16),
          _pipelineTile(
            title: 'Physical Sheet / OCR Vision',
            desc: 'Snap or upload attendance sheet. Pre-process offline and review in split-pane.',
            icon: LucideIcons.scanLine,
            color: AppColors.brandPurple,
            onTap: widget.onNavigateToIngestion,
          ),
          const SizedBox(height: 10),
          _pipelineTile(
            title: 'Spreadsheet Batch Ingest (.xlsx / .csv)',
            desc: 'Auto-map column headers (CNIC, Roll No, Dept) and import hundreds in seconds.',
            icon: LucideIcons.fileSpreadsheet,
            color: AppColors.pillarEmployment,
            onTap: widget.onNavigateToIngestion,
          ),
          const SizedBox(height: 10),
          _pipelineTile(
            title: 'Direct Form Entry',
            desc: 'Instant field validation with CNIC and phone mask formatting.',
            icon: LucideIcons.userPlus,
            color: AppColors.pillarEnvironment,
            onTap: widget.onNavigateToSocieties,
          ),
        ],
      ),
    );
  }

  Widget _pipelineTile({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
            Icon(LucideIcons.arrowRight, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
