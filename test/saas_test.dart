import 'package:flutter_test/flutter_test.dart';
import 'package:ydc_aust/core/saas/saas_models.dart';
import 'package:ydc_aust/core/saas/saas_state.dart';

void main() {
  group('SaaS Multi-Tenancy & Licensing Unit Tests', () {
    test('Default SaaS state has pre-configured institutional tenants', () {
      final state = SaasState();
      expect(state.tenants.length, greaterThanOrEqualTo(4));
      expect(state.currentTenant.id, 'aust_main');
      expect(state.currentTenant.tier, 'Enterprise Tier');
      expect(state.currentTenant.shortName, 'AUST Abbottabad');
    });

    test('Can switch active SaaS tenant seamlessly', () {
      final state = SaasState();
      state.switchTenant('uoh_campus');
      expect(state.currentTenant.id, 'uoh_campus');
      expect(state.currentTenant.shortName, 'UoH Haripur');

      state.switchTenant('aust_main');
      expect(state.currentTenant.id, 'aust_main');
    });

    test('Can provision, register, and delete an institutional tenant', () {
      final state = SaasState();
      final initialCount = state.tenants.length;

      const newTenant = SaasTenant(
        id: 'uop_main',
        name: 'UNIVERSITY OF PESHAWAR',
        shortName: 'UoP Peshawar',
        subdomain: 'uop.ydcerp.cloud',
        tier: 'Enterprise Tier',
        session: 'Session 2025–2026',
        campusLocation: 'University Road, Peshawar, KP',
        adminName: 'Directorate of Student Affairs',
        adminRole: 'Tenant Admin',
        adminEmail: 'registrar@uop.edu.pk',
        licenseKey: 'YDC-ENT-2026-UOP-9901',
        validUntil: '31 December 2028',
      );

      state.addTenant(newTenant);
      expect(state.tenants.length, initialCount + 1);
      expect(state.currentTenant.id, 'uop_main');
      expect(state.currentTenant.name, 'UNIVERSITY OF PESHAWAR');

      // Test delete tenant
      final deleteSuccess = state.deleteTenant('uop_main');
      expect(deleteSuccess, isTrue);
      expect(state.tenants.length, initialCount);
      expect(state.tenants.any((t) => t.id == 'uop_main'), isFalse);
    });

    test('Can dynamically add and remove SaaS feature entitlements', () {
      final state = SaasState();
      const customFeature = 'Biometric RFID Access Control';

      expect(state.currentTenant.enabledFeatures.contains(customFeature), isFalse);

      // Add feature
      state.addFeatureToTenant('aust_main', customFeature);
      expect(state.currentTenant.enabledFeatures.contains(customFeature), isTrue);

      // Remove feature
      state.removeFeatureFromTenant('aust_main', customFeature);
      expect(state.currentTenant.enabledFeatures.contains(customFeature), isFalse);
    });
  });
}
