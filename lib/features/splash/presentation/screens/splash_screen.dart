import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function() onInitialize;
  final VoidCallback onInitComplete;

  const SplashScreen({
    super.key,
    required this.onInitialize,
    required this.onInitComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  String _bootStatus = 'Initializing local database and security vault...';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
    _runBootSequence();
  }

  Future<void> _runBootSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _bootStatus = 'Verifying SQLite integrity and schema...');
    }

    try {
      await widget.onInitialize();
    } catch (e) {
      debugPrint('[BootSequence] Init notice: $e');
    }

    if (mounted) {
      setState(() => _bootStatus = 'Preparing desktop viewport...');
    }
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      widget.onInitComplete();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Center Hero Emblem & Progress
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // YDC 4-Pillar Graphic Emblem
                    _buildPillarEmblem(),
                    const SizedBox(height: 28),

                    // Institution Name
                    const Text(
                      'ABBOTTABAD UNIVERSITY OF SCIENCE & TECHNOLOGY',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pillarEnvironment,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // App Title
                    const Text(
                      'Youth Development Center (YDC)',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    const Text(
                      'Institutional Desktop ERP System • Native Windows Runner',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Loading Progress Indicator
                    SizedBox(
                      width: 260,
                      child: Column(
                        children: [
                          const LinearProgressIndicator(
                            color: AppColors.pillarEnvironment,
                            backgroundColor: Color(0xFFE2E8F0),
                            minHeight: 4,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _bootStatus,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Power-by Anchor
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ARCHITECTED & ENGINEERED BY',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSubtle,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/Alldotdev.png',
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarEmblem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderSubtle, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
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
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pillarBadge(AppColors.pillarEducation, 'Education'),
            const SizedBox(width: 6),
            _pillarBadge(AppColors.pillarEmployment, 'Employment'),
            const SizedBox(width: 6),
            _pillarBadge(AppColors.pillarEngagement, 'Engagement'),
            const SizedBox(width: 6),
            _pillarBadge(AppColors.pillarEnvironment, 'Environment'),
          ],
        ),
      ],
    );
  }

  Widget _pillarBadge(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
