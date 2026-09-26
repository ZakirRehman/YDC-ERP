import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import 'saas_models.dart';
import 'saas_state.dart';

class SaasManagementDialog extends StatefulWidget {
  const SaasManagementDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const SaasManagementDialog(),
    );
  }

  @override
  State<SaasManagementDialog> createState() => _SaasManagementDialogState();
}

class _SaasManagementDialogState extends State<SaasManagementDialog> {
  int _selectedTab = 0; // 0: Tenant Overview, 1: Switch Tenant, 2: Register New Tenant

  // New Tenant Form Controllers
  final _nameCtrl = TextEditingController();
  final _shortNameCtrl = TextEditingController();
  final _subdomainCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _adminNameCtrl = TextEditingController();
  final _adminEmailCtrl = TextEditingController();
  final _newFeatureCtrl = TextEditingController();
  String _selectedTier = 'Enterprise Tier';
  late List<String> _registerFeatures;

  @override
  void initState() {
    super.initState();
    _registerFeatures = [
      'Multi-Pillar Institutional Governance',
      'AI-Powered OCR Sheet Ingestion',
      'AES-256-GCM Military Grade Vault',
      'Automated Executive PDF Dossiers',
      'Multi-Campus Tenant Synchronization',
    ];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortNameCtrl.dispose();
    _subdomainCtrl.dispose();
    _locationCtrl.dispose();
    _adminNameCtrl.dispose();
    _adminEmailCtrl.dispose();
    _newFeatureCtrl.dispose();
    super.dispose();
  }

  void _handleCreateTenant() {
    if (_nameCtrl.text.trim().isEmpty) return;

    final id = 'tenant_${const Uuid().v4().substring(0, 8)}';
    final newTenant = SaasTenant(
      id: id,
      name: _nameCtrl.text.trim().toUpperCase(),
      shortName: _shortNameCtrl.text.trim().isNotEmpty ? _shortNameCtrl.text.trim() : _nameCtrl.text.trim(),
      subdomain: '${_subdomainCtrl.text.trim().toLowerCase().replaceAll(' ', '')}.ydcerp.cloud',
      tier: _selectedTier,
      session: 'Session 2025–2026',
      campusLocation: _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : 'Pakistan Campus',
      adminName: _adminNameCtrl.text.trim().isNotEmpty ? _adminNameCtrl.text.trim() : 'Campus Admin',
      adminRole: 'Tenant Administrator',
      adminEmail: _adminEmailCtrl.text.trim().isNotEmpty ? _adminEmailCtrl.text.trim() : 'admin@campus.edu.pk',
      licenseKey: 'YDC-${_selectedTier.substring(0, 3).toUpperCase()}-2026-${id.toUpperCase()}',
      validUntil: '31 December 2028',
      enabledFeatures: List<String>.from(_registerFeatures),
    );

    saasState.addTenant(newTenant);
    setState(() => _selectedTab = 0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Institutional Tenant "${newTenant.shortName}" registered & activated!'),
        backgroundColor: AppColors.statusSuccess,
      ),
    );
  }

  void _confirmDeleteTenant(SaasTenant tenant) {
    if (saasState.tenants.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete the last remaining tenant.'),
          backgroundColor: AppColors.statusDanger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: AppColors.statusDanger, size: 22),
            SizedBox(width: 10),
            Text('Decommission SaaS Tenant', style: AppTypography.cardHeading),
          ],
        ),
        content: Text('Are you sure you want to delete "${tenant.name}" (${tenant.shortName})? This tenant profile and cloud license routing will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDanger, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              final success = saasState.deleteTenant(tenant.id);
              if (success) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tenant "${tenant.shortName}" has been deleted.'),
                    backgroundColor: AppColors.statusSuccess,
                  ),
                );
              }
            },
            child: const Text('Delete Tenant'),
          ),
        ],
      ),
    );
  }

  void _showAddFeatureDialog(SaasTenant tenant) {
    final featureCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.sparkles, color: AppColors.pillarEnvironment, size: 20),
            SizedBox(width: 10),
            Text('Add SaaS Feature Entitlement', style: AppTypography.cardHeading),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Provision a new feature capability for ${tenant.shortName}:', style: AppTypography.bodyMuted),
              const SizedBox(height: 12),
              TextField(
                controller: featureCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Feature Name / Module',
                  hintText: 'e.g. Biometric RFID Check-in',
                ),
              ),
              const SizedBox(height: 12),
              const Text('Suggested Presets:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  'Biometric Gate Access',
                  'HEC ERP API Bridge',
                  'SMS Broadcast Gateway',
                  'Alumni Portal Sync',
                  'Automated Audit Trail',
                ].map((preset) => ActionChip(
                  label: Text(preset, style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    featureCtrl.text = preset;
                  },
                )).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = featureCtrl.text.trim();
              if (val.isNotEmpty) {
                saasState.addFeatureToTenant(tenant.id, val);
                Navigator.of(ctx).pop();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Feature "$val" added to ${tenant.shortName}!'),
                    backgroundColor: AppColors.statusSuccess,
                  ),
                );
              }
            },
            child: const Text('Add Entitlement'),
          ),
        ],
      ),
    ).whenComplete(() => featureCtrl.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final current = saasState.currentTenant;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 780,
        height: 600,
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.pillarEnvironment.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.cloud, color: AppColors.pillarEnvironment, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'YDC Multi-Tenant SaaS Portal',
                            style: AppTypography.heading1,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.pillarEnvironment.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              current.tier,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pillarEnvironment,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Cloud-native university governance, institutional licensing & tenant routing.',
                        style: AppTypography.bodyMuted,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tab Navigation Bar
            Row(
              children: [
                _tabButton(0, 'Tenant Overview & License', LucideIcons.building2),
                const SizedBox(width: 8),
                _tabButton(1, 'Switch Campus / Tenant (${saasState.tenants.length})', LucideIcons.repeat),
                const SizedBox(width: 8),
                _tabButton(2, 'Register New Institutional Tenant', LucideIcons.plusCircle),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildTabBody(current),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pillarEnvironment.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.pillarEnvironment : AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.pillarEnvironment : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.pillarEnvironment : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(SaasTenant current) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(current);
      case 1:
        return _buildSwitchTenantTab();
      case 2:
        return _buildRegisterTenantTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewTab(SaasTenant current) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Institutional Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.pillarEnvironment.withOpacity(0.15),
                  child: Text(
                    current.shortName.substring(0, 2).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.pillarEnvironment),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(current.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text('${current.campusLocation} • ${current.session}', style: AppTypography.bodyMuted),
                      const SizedBox(height: 4),
                      Text('Subdomain Routing: https://${current.subdomain}', style: AppTypography.mono),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.checkCircle2, size: 14, color: AppColors.statusSuccess),
                      SizedBox(width: 6),
                      Text('Tenant Active', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.statusSuccess)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // License & SLA Details
          Row(
            children: [
              Expanded(
                child: _metaBox('Enterprise License Key', current.licenseKey, LucideIcons.keyRound, AppTypography.mono),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _metaBox('Valid Through', current.validUntil, LucideIcons.calendarCheck2, AppTypography.body),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _metaBox('Tenant Administrator', '${current.adminName} (${current.adminEmail})', LucideIcons.userCheck, AppTypography.body),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _metaBox('Hybrid Cloud Sync', 'Status: Synced (Zero Data Leak)', LucideIcons.cloud, AppTypography.body),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Text('Active SaaS Feature Entitlements:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddFeatureDialog(current),
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add Entitlement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: current.enabledFeatures.map((feat) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.check, size: 12, color: AppColors.pillarEnvironment),
                    const SizedBox(width: 6),
                    Text(feat, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        saasState.removeFeatureFromTenant(current.id, feat);
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Tooltip(
                        message: 'Remove feature entitlement',
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(LucideIcons.x, size: 12, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _metaBox(String title, String value, IconData icon, TextStyle textStyle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(title, style: AppTypography.subHeader),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: textStyle, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSwitchTenantTab() {
    final list = saasState.tenants;

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final t = list[i];
        final isSelected = t.id == saasState.currentTenant.id;

        return InkWell(
          onTap: () {
            saasState.switchTenant(t.id);
            setState(() {});
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.pillarEnvironment.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.pillarEnvironment : AppColors.borderSubtle,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isSelected ? AppColors.pillarEnvironment : AppColors.surfaceBg,
                  child: Text(
                    t.shortName.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.pillarEnvironment.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(t.tier, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.pillarEnvironment)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${t.campusLocation} • Domain: ${t.subdomain} • (${t.enabledFeatures.length} features)', style: AppTypography.bodyMuted),
                    ],
                  ),
                ),
                if (isSelected)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.checkCircle2, color: AppColors.pillarEnvironment, size: 18),
                      const SizedBox(width: 6),
                      const Text('Active Session', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.pillarEnvironment)),
                      if (list.length > 1) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.statusDanger),
                          tooltip: 'Delete Tenant',
                          onPressed: () => _confirmDeleteTenant(t),
                        ),
                      ],
                    ],
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          saasState.switchTenant(t.id);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Switch Tenant'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.statusDanger),
                        tooltip: 'Delete Tenant',
                        onPressed: () => _confirmDeleteTenant(t),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterTenantTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Institutional Multi-Tenant Registration', style: AppTypography.cardHeading),
          const SizedBox(height: 4),
          const Text('Provision a new university or college tenant with isolated governance and branding.', style: AppTypography.bodyMuted),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Institution Full Legal Name',
              hintText: 'e.g. UNIVERSITY OF PESHAWAR',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _shortNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Acronym / Short Name',
                    hintText: 'e.g. UoP',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _subdomainCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subdomain Prefix',
                    hintText: 'e.g. uop (for uop.ydcerp.cloud)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Campus Location / City',
                    hintText: 'e.g. Peshawar, KP',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedTier,
                  decoration: const InputDecoration(labelText: 'SaaS Subscription Tier'),
                  items: ['Enterprise Tier', 'Campus Pro Tier', 'Starter Campus Tier']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedTier = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _adminNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tenant Administrator Name',
                    hintText: 'e.g. Director Student Affairs',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _adminEmailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Institutional Admin Email',
                    hintText: 'e.g. registrar@uop.edu.pk',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Assigned Feature Entitlements:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _registerFeatures.map((f) {
              return Chip(
                label: Text(f, style: const TextStyle(fontSize: 11)),
                deleteIcon: const Icon(LucideIcons.x, size: 12),
                onDeleted: () {
                  setState(() {
                    _registerFeatures.remove(f);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newFeatureCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Add Custom Feature / Entitlement',
                    hintText: 'e.g. Biometric Turnstile API',
                    isDense: true,
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty && !_registerFeatures.contains(val.trim())) {
                      setState(() {
                        _registerFeatures.add(val.trim());
                        _newFeatureCtrl.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  final val = _newFeatureCtrl.text.trim();
                  if (val.isNotEmpty && !_registerFeatures.contains(val)) {
                    setState(() {
                      _registerFeatures.add(val);
                      _newFeatureCtrl.clear();
                    });
                  }
                },
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleCreateTenant,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pillarEnvironment,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Provision & Deploy Campus Tenant'),
            ),
          ),
        ],
      ),
    );
  }
}
