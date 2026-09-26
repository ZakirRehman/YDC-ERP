import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../saas/saas_state.dart';
import '../saas/saas_management_dialog.dart';
import '../ui/ui_scale_state.dart';

class CustomTopBar extends StatefulWidget {
  final VoidCallback onQuickIngestion;

  const CustomTopBar({
    super.key,
    required this.onQuickIngestion,
  });

  @override
  State<CustomTopBar> createState() => _CustomTopBarState();
}

class _CustomTopBarState extends State<CustomTopBar> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return ListenableBuilder(
      listenable: saasState,
      builder: (context, _) {
        final tenant = saasState.currentTenant;

        return Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final showClock = maxWidth >= 880;
              final showProfileText = maxWidth >= 760;
              final showFullButton = maxWidth >= 620;

              return Row(
                children: [
                  // Institutional Crest / Logo
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.asset(
                        tenant.logoAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/YDC_AUST.jpg',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(LucideIcons.building, size: 20, color: AppColors.pillarEnvironment),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Institutional Heading & Multi-Tenant Identity (Flexible to avoid overflow)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                tenant.name,
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pillarEnvironment,
                                  letterSpacing: 0.4,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.pillarEducation.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tenant.session,
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pillarEducation,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'Youth Development Center (YDC) — ${tenant.shortName}',
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // SaaS Multi-Tenant Switcher Button & Cloud Pill
                  InkWell(
                    onTap: () => SaasManagementDialog.show(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.pillarEnvironment.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.pillarEnvironment.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.cloud, size: 14, color: AppColors.pillarEnvironment),
                          const SizedBox(width: 6),
                          Text(
                            maxWidth >= 550 ? 'SaaS: ${tenant.tier}' : tenant.tier.split(' ').first,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.pillarEnvironment,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.chevronDown, size: 12, color: AppColors.pillarEnvironment),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // UI Scaling & Screen Fit Control
                  _buildZoomControl(maxWidth),

                  if (showClock) ...[
                    const SizedBox(width: 8),
                    // Local Time in Pakistan
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.clock, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            timeFormat.format(_currentTime),
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(width: 8),

                  // Primary Quick Action CTA
                  showFullButton
                      ? ElevatedButton.icon(
                          onPressed: widget.onQuickIngestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pillarEnvironment,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          icon: const Icon(LucideIcons.userPlus, size: 15),
                          label: const Text('New Ingestion'),
                        )
                      : IconButton(
                          onPressed: widget.onQuickIngestion,
                          tooltip: 'New Ingestion',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.pillarEnvironment,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(8),
                          ),
                          icon: const Icon(LucideIcons.userPlus, size: 16),
                        ),

                  const SizedBox(width: 8),

                  // Administrator Profile Chip with SaaS tenant details
                  InkWell(
                    onTap: () => SaasManagementDialog.show(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: AppColors.pillarEnvironment.withValues(alpha: 0.15),
                            child: Text(
                              tenant.shortName.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pillarEnvironment,
                              ),
                            ),
                          ),
                          if (showProfileText) ...[
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tenant.adminName,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  tenant.adminRole,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 9,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildZoomControl(double maxWidth) {
    return ListenableBuilder(
      listenable: uiScaleState,
      builder: (context, _) {
        final currentMode = uiScaleState.mode;
        final currentScale = uiScaleState.effectiveScale;
        final percentText = '${(currentScale * 100).round()}%';
        final isAuto = currentMode == UiScaleMode.auto;
        final isCompact = maxWidth < 950;

        return PopupMenuButton<UiScaleMode>(
          tooltip: 'UI Scaling & Display Fit (Ctrl + / -)',
          offset: const Offset(0, 42),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (mode) => uiScaleState.setMode(mode),
          itemBuilder: (ctx) => [
            const PopupMenuItem<UiScaleMode>(
              enabled: false,
              child: Text(
                'DISPLAY SCALE & SCREEN FIT',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted),
              ),
            ),
            ...UiScaleMode.values.map((m) {
              final isSelected = m == currentMode;
              return PopupMenuItem<UiScaleMode>(
                value: m,
                child: Row(
                  children: [
                    Icon(
                      isSelected ? LucideIcons.check : LucideIcons.circle,
                      size: 14,
                      color: isSelected ? AppColors.pillarEnvironment : Colors.transparent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      m.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.pillarEnvironment : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const PopupMenuDivider(),
            PopupMenuItem<UiScaleMode>(
              enabled: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      uiScaleState.zoomOut();
                    },
                    icon: const Icon(LucideIcons.minus, size: 12),
                    label: const Text('Zoom Out', style: TextStyle(fontSize: 11)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      uiScaleState.zoomIn();
                    },
                    icon: const Icon(LucideIcons.plus, size: 12),
                    label: const Text('Zoom In', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isAuto ? AppColors.surfaceBg : AppColors.pillarEducation.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAuto ? AppColors.borderSubtle : AppColors.pillarEducation.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.scaling,
                  size: 13,
                  color: isAuto ? AppColors.textMuted : AppColors.pillarEducation,
                ),
                const SizedBox(width: 5),
                Text(
                  isCompact ? percentText : (isAuto ? '$percentText (Auto)' : percentText),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isAuto ? AppColors.textDark : AppColors.pillarEducation,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  LucideIcons.chevronDown,
                  size: 11,
                  color: isAuto ? AppColors.textMuted : AppColors.pillarEducation,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
