class SaasTenant {
  final String id;
  final String name;
  final String shortName;
  final String subdomain;
  final String tier; // e.g. Enterprise Tier, Campus Pro, Starter
  final String session;
  final String campusLocation;
  final String adminName;
  final String adminRole;
  final String adminEmail;
  final String licenseKey;
  final String validUntil;
  final String logoAsset;
  final List<String> enabledFeatures;

  const SaasTenant({
    required this.id,
    required this.name,
    required this.shortName,
    required this.subdomain,
    required this.tier,
    required this.session,
    required this.campusLocation,
    required this.adminName,
    required this.adminRole,
    required this.adminEmail,
    required this.licenseKey,
    required this.validUntil,
    this.logoAsset = 'assets/YDC_AUST.jpg',
    this.enabledFeatures = const [
      'Multi-Pillar Institutional Governance',
      'AI-Powered OCR Sheet Ingestion',
      'AES-256-GCM Military Grade Vault',
      'Automated Executive PDF Dossiers',
      'Multi-Campus Tenant Synchronization',
      'White-Label Institutional Customization',
    ],
  });

  SaasTenant copyWith({
    String? id,
    String? name,
    String? shortName,
    String? subdomain,
    String? tier,
    String? session,
    String? campusLocation,
    String? adminName,
    String? adminRole,
    String? adminEmail,
    String? licenseKey,
    String? validUntil,
    String? logoAsset,
    List<String>? enabledFeatures,
  }) {
    return SaasTenant(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      subdomain: subdomain ?? this.subdomain,
      tier: tier ?? this.tier,
      session: session ?? this.session,
      campusLocation: campusLocation ?? this.campusLocation,
      adminName: adminName ?? this.adminName,
      adminRole: adminRole ?? this.adminRole,
      adminEmail: adminEmail ?? this.adminEmail,
      licenseKey: licenseKey ?? this.licenseKey,
      validUntil: validUntil ?? this.validUntil,
      logoAsset: logoAsset ?? this.logoAsset,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
    );
  }
}
