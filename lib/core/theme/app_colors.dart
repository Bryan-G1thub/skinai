import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand — Deep Royal Purple
  static const Color primary = Color(0xFF3E1A7F);
  static const Color primaryLight = Color(0xFF7B56C8);
  static const Color primaryDark = Color(0xFF1E0C52);

  // Accent — Warm Champagne Gold
  static const Color accent = Color(0xFFC9A060);
  static const Color accentLight = Color(0xFFE8D5B2);

  // Secondary — Dusty Rose
  static const Color rose = Color(0xFFD4879E);
  static const Color roseLight = Color(0xFFF5CBDA);

  // Backgrounds
  static const Color background = Color(0xFFF8F6FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEFEBFC);
  static const Color surfaceElevated = Color(0xFFF3F0FB);

  // Text
  static const Color textPrimary = Color(0xFF160E2A);
  static const Color textSecondary = Color(0xFF5C5270);
  static const Color textTertiary = Color(0xFF9890A8);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xB3FFFFFF); // 70% white

  // Semantic
  static const Color success = Color(0xFF2A7D5A);
  static const Color successLight = Color(0xFFD4EFDF);
  static const Color warning = Color(0xFFB77C2A);
  static const Color warningLight = Color(0xFFF5E6CB);
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF2E7DAE);
  static const Color infoLight = Color(0xFFCBE3F5);

  // Intent card tints
  static const Color tintSage = Color(0xFFD4EFDF);
  static const Color tintGold = Color(0xFFF5E6CB);
  static const Color tintBlue = Color(0xFFCBE3F5);
  static const Color tintRose = Color(0xFFF5CBDA);

  // Borders & Dividers
  static const Color border = Color(0xFFD5CEEB);
  static const Color divider = Color(0xFFE4DFF5);

  // Shadow
  static const Color shadow = Color(0x14160E2A); // 8% textPrimary
  static const Color shadowMedium = Color(0x1E160E2A); // 12%
  static const Color shadowStrong = Color(0x33160E2A); // 20%
}
