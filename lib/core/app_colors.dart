import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Modern Light Theme for Government App (Soft & Clean)
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF475569);
  
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color softGreen = Color(0xFF10B981);
  static const Color accentYellow = Color(0xFFF59E0B);
  static const Color accentOrange = Color(0xFFF97316);
  
  // Dark Theme Colors (Existing)
  static const Color background = Color(0xFF2C2F33); 
  static const Color surface = Color(0xFF383C45); 
  static const Color surfaceVariant = Color(0xFF424752); 
  static const Color textPrimary = Color(0xFFF8FAFC); 
  static const Color textSecondary = Color(0xFFCBD5E1); 
  static const Color textHint = Color(0xFF94A3B8); 

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFB3E5FC); // Colors.lightBlue[100]
  static const Color surfaceLight = Colors.white;
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textHintLight = Color(0xFF64748B);
  static const Color dividerLight = Color(0xFFE2E8F0);
  
  static const Color error = Color(0xFFEF4444);

  // Role / Feature Accent Colors
  static const Color emergencyRed = Color(0xFFEF4444);
  static const Color softBlue = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color doctorGreen = Color(0xFF10B981);
  static const Color panchayatPurple = Color(0xFFA855F7);
  static const Color tealAccent = Color(0xFF14B8A6);

  // Additional role / status colors
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
  static const Color ashaWorkerPink = Color(0xFFF472B6);

  static const Color patientBlue = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient doctorGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ashaGradient = LinearGradient(
    colors: [Color(0xFFF472B6), Color(0xFFF9A8D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient panchayatGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFFC084FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );



  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Adaptive helpers (auto light/dark) ──
  static Color adaptiveTextPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimary : textPrimaryLight;

  static Color adaptiveTextSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondary : textSecondaryLight;

  static Color adaptiveTextHint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textHint : textHintLight;

  static Color adaptiveBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color adaptiveSurface(BuildContext context) =>
      Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? surface : surfaceLight);

  static Color adaptiveSurfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceVariant : surfaceVariantLight;

  static Color adaptiveBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(20);
}
