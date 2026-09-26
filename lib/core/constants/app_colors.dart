import 'package:flutter/material.dart';

/// Design tokens respecting the 70/30 distribution rule
/// 70% Neutral Canvas / 30% Semantic Pillar Accents
class AppColors {
  AppColors._();

  // 70% Foundation & Canvas
  static const Color surfaceBg = Color(0xFFF4F6F9);       // Primary desktop backdrop
  static const Color surfacePanel = Color(0xFFFFFFFF);    // Elevated cards & containers
  static const Color surfaceDarkHero = Color(0xFF1F242D); // SYQOR-style high-contrast hero card
  static const Color borderSubtle = Color(0xFFE4E7EC);    // 1px border lines, dividers
  static const Color textDark = Color(0xFF111827);        // Primary typography
  static const Color textMuted = Color(0xFF717D96);       // Secondary / helper labels
  static const Color textSubtle = Color(0xFF94A3B8);      // De-emphasized notes

  // 30% Strategic Brand Accents (YDC 4 Strategic Pillars)
  static const Color pillarEnvironment = Color(0xFF198754); // Green: Eco-sustainability / Primary CTA
  static const Color pillarEducation = Color(0xFF0D6EFD);   // Blue: Academic societies & verify badges
  static const Color pillarEmployment = Color(0xFFE65100);  // Orange: PMYP, internships & warning review
  static const Color pillarEngagement = Color(0xFFFFB300);  // Gold/Yellow: Campus events & notifications

  // Attribution & Secondary Accents
  static const Color brandPurple = Color(0xFF7A1CAC);       // ALLDOTDEV brand identity & OCR indicator
  static const Color statusSuccess = Color(0xFF198754);     // Confirmed / active record
  static const Color statusWarning = Color(0xFFE65100);     // Low OCR confidence / Needs manual review
  static const Color statusDanger = Color(0xFFDC3545);      // Deletions / Errors
  static const Color statusInfo = Color(0xFF0D6EFD);        // Information banners

  // Helper method to retrieve pillar color
  static Color getPillarColor(String pillar) {
    switch (pillar.toLowerCase()) {
      case 'environment':
        return pillarEnvironment;
      case 'education':
        return pillarEducation;
      case 'employment':
        return pillarEmployment;
      case 'engagement':
        return pillarEngagement;
      default:
        return pillarEnvironment;
    }
  }
}
