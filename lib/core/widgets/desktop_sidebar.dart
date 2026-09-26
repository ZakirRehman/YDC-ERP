import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../saas/saas_management_dialog.dart';

enum NavSection {
  dashboard,
  societies,
  events,
  ingestion,
  records,
  vault,
}

class DesktopSidebar extends StatelessWidget {
  final NavSection currentSection;
  final ValueChanged<NavSection> onSectionSelected;

  const DesktopSidebar({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // YDC Emblem / Top Brand Icon
          _buildBrandEmblem(),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.borderSubtle, indent: 16, endIndent: 16),
          const SizedBox(height: 16),

          // Primary Navigation Dock
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _navItem(
                  icon: LucideIcons.layoutDashboard,
                  tooltip: 'Dashboard Overview',
                  section: NavSection.dashboard,
                  accentColor: AppColors.pillarEnvironment,
                ),
                const SizedBox(height: 12),
                _navItem(
                  icon: LucideIcons.users,
                  tooltip: 'Societies & Cabinets',
                  section: NavSection.societies,
                  accentColor: AppColors.pillarEducation,
                ),
                const SizedBox(height: 12),
                _navItem(
                  icon: LucideIcons.calendarDays,
                  tooltip: 'Events & Speeches',
                  section: NavSection.events,
                  accentColor: AppColors.pillarEngagement,
                ),
                const SizedBox(height: 12),
                _navItem(
                  icon: LucideIcons.scanLine,
                  tooltip: 'Omni-Channel Ingestion (OCR / Excel)',
                  section: NavSection.ingestion,
                  accentColor: AppColors.brandPurple,
                ),
                const SizedBox(height: 12),
                _navItem(
                  icon: LucideIcons.fileSpreadsheet,
                  tooltip: 'Master Records & Monthly Dossier',
                  section: NavSection.records,
                  accentColor: AppColors.pillarEmployment,
                ),
                const SizedBox(height: 12),
                _navItem(
                  icon: LucideIcons.shieldCheck,
                  tooltip: 'Confidential Vault (AES-256)',
                  section: NavSection.vault,
                  accentColor: AppColors.pillarEnvironment,
                ),
              ],
            ),
          ),

          // SaaS Multi-Tenant Cloud Portal Button
          Tooltip(
            message: 'Multi-Tenant SaaS Portal & Licensing',
            preferBelow: false,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => SaasManagementDialog.show(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.pillarEnvironment.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.pillarEnvironment.withValues(alpha: 0.3)),
                ),
                child: const Icon(LucideIcons.cloud, size: 20, color: AppColors.pillarEnvironment),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bottom: ALLDOTDEV Brand Badge
          _buildFooterBadge(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBrandEmblem() {
    return Tooltip(
      message: 'Youth Development Center\nAbbottabad University of Science & Technology',
      preferBelow: false,
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/YDC_AUST.jpg',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/YDC_Aust.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String tooltip,
    required NavSection section,
    required Color accentColor,
  }) {
    final bool isSelected = currentSection == section;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSectionSelected(section),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accentColor.withOpacity(0.3) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Positioned(
                    left: 0,
                    top: 12,
                    bottom: 12,
                    width: 3.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? accentColor : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterBadge() {
    return Tooltip(
      message: 'Architected & Engineered by ALLDOTDEV',
      child: Container(
        width: 54,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/Alldotdev.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
