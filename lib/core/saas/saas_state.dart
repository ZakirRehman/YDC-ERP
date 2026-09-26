import 'package:flutter/foundation.dart';
import 'saas_models.dart';

class SaasState extends ChangeNotifier {
  static final List<SaasTenant> defaultTenants = [
    const SaasTenant(
      id: 'aust_main',
      name: 'ABBOTTABAD UNIVERSITY OF SCIENCE & TECHNOLOGY',
      shortName: 'AUST Abbottabad',
      subdomain: 'aust.ydcerp.cloud',
      tier: 'Enterprise Tier',
      session: 'Session 2025–2026',
      campusLocation: 'Havelian Campus, Abbottabad, KP',
      adminName: 'YDC Directorate',
      adminRole: 'Institutional SuperAdmin',
      adminEmail: 'ydc.directorate@aust.edu.pk',
      licenseKey: 'YDC-ENT-2026-AUST-8821-PRO',
      validUntil: '31 December 2027',
      logoAsset: 'assets/YDC_AUST.jpg',
    ),
    const SaasTenant(
      id: 'uoh_campus',
      name: 'UNIVERSITY OF HARIPUR',
      shortName: 'UoH Haripur',
      subdomain: 'uoh.ydcerp.cloud',
      tier: 'Campus Pro Tier',
      session: 'Session 2025–2026',
      campusLocation: 'Main Campus, Haripur, KP',
      adminName: 'Office of Student Affairs',
      adminRole: 'Campus Administrator',
      adminEmail: 'studentaffairs@uoh.edu.pk',
      licenseKey: 'YDC-PRO-2026-UOH-4412-REG',
      validUntil: '30 June 2027',
      logoAsset: 'assets/YDC_AUST.jpg',
    ),
    const SaasTenant(
      id: 'hu_campus',
      name: 'HAZARA UNIVERSITY MANSEHRA',
      shortName: 'HU Mansehra',
      subdomain: 'hu.ydcerp.cloud',
      tier: 'Campus Pro Tier',
      session: 'Session 2025–2026',
      campusLocation: 'Dhodial Campus, Mansehra, KP',
      adminName: 'Youth Directorate',
      adminRole: 'Tenant Admin',
      adminEmail: 'ydc@hu.edu.pk',
      licenseKey: 'YDC-PRO-2026-HU-9011-LIC',
      validUntil: '15 August 2027',
      logoAsset: 'assets/YDC_AUST.jpg',
    ),
    const SaasTenant(
      id: 'cui_atd',
      name: 'COMSATS UNIVERSITY ISLAMABAD — ABBOTTABAD',
      shortName: 'CUI Abbottabad',
      subdomain: 'cui-atd.ydcerp.cloud',
      tier: 'Starter Campus Tier',
      session: 'Session 2025–2026',
      campusLocation: 'University Road, Abbottabad, KP',
      adminName: 'Student Development Center',
      adminRole: 'Associate Coordinator',
      adminEmail: 'sdc@cuiatd.edu.pk',
      licenseKey: 'YDC-STR-2026-CUI-1029-STD',
      validUntil: '31 January 2027',
      logoAsset: 'assets/YDC_AUST.jpg',
    ),
  ];

  final List<SaasTenant> _tenants = List.from(defaultTenants);
  int _currentTenantIndex = 0;

  List<SaasTenant> get tenants => _tenants;
  SaasTenant get currentTenant => _tenants[_currentTenantIndex];
  int get currentTenantIndex => _currentTenantIndex;

  void switchTenant(String tenantId) {
    final idx = _tenants.indexWhere((t) => t.id == tenantId);
    if (idx != -1 && idx != _currentTenantIndex) {
      _currentTenantIndex = idx;
      notifyListeners();
    }
  }

  void addTenant(SaasTenant newTenant) {
    _tenants.add(newTenant);
    _currentTenantIndex = _tenants.length - 1;
    notifyListeners();
  }

  bool deleteTenant(String tenantId) {
    if (_tenants.length <= 1) {
      return false; // Preserve at least one active tenant
    }
    final idx = _tenants.indexWhere((t) => t.id == tenantId);
    if (idx == -1) return false;

    _tenants.removeAt(idx);
    if (_currentTenantIndex >= _tenants.length) {
      _currentTenantIndex = _tenants.length - 1;
    } else if (idx < _currentTenantIndex) {
      _currentTenantIndex--;
    }
    notifyListeners();
    return true;
  }

  void addFeatureToTenant(String tenantId, String feature) {
    final idx = _tenants.indexWhere((t) => t.id == tenantId);
    if (idx == -1) return;
    final tenant = _tenants[idx];
    if (!tenant.enabledFeatures.contains(feature)) {
      final updatedList = List<String>.from(tenant.enabledFeatures)..add(feature);
      _tenants[idx] = tenant.copyWith(enabledFeatures: updatedList);
      notifyListeners();
    }
  }

  void removeFeatureFromTenant(String tenantId, String feature) {
    final idx = _tenants.indexWhere((t) => t.id == tenantId);
    if (idx == -1) return;
    final tenant = _tenants[idx];
    if (tenant.enabledFeatures.contains(feature)) {
      final updatedList = List<String>.from(tenant.enabledFeatures)..remove(feature);
      _tenants[idx] = tenant.copyWith(enabledFeatures: updatedList);
      notifyListeners();
    }
  }

  void updateCurrentTenant(SaasTenant updated) {
    _tenants[_currentTenantIndex] = updated;
    notifyListeners();
  }
}

// Global singleton instance for easy cross-widget access
final saasState = SaasState();
