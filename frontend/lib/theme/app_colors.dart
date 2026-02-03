import 'package:flutter/material.dart';

/// Car dashboard-inspired color scheme for premium dark theme
class AppColors {
  AppColors._();

  // Base colors
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color surfaceColor = Color(0xFF151B2D);
  static const Color surfaceLightColor = Color(0xFF1F2937);
  
  // Accent colors
  static const Color electricBlue = Color(0xFF00D9FF);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color warningOrange = Color(0xFFFF6B35);
  static const Color softPurple = Color(0xFF9D4EDD);
  
  // Status colors
  static const Color statusDetected = Color(0xFF00D9FF); // Blue
  static const Color statusRepaired = Color(0xFF00FF88); // Green
  static const Color statusClaimed = Color(0xFFFF6B35);  // Orange
  
  // Severity colors
  static const Color severityMinor = Color(0xFF00FF88);    // Green
  static const Color severityModerate = Color(0xFFFBBD08); // Yellow
  static const Color severitySevere = Color(0xFFFF6B35);   // Orange
  static const Color severityCritical = Color(0xFFFF006E); // Red
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8C1D9);
  static const Color textTertiary = Color(0xFF6B7280);
  
  // Functional colors
  static const Color success = Color(0xFF00FF88);
  static const Color error = Color(0xFFFF006E);
  static const Color warning = Color(0xFFFF6B35);
  static const Color info = Color(0xFF00D9FF);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [electricBlue, softPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [neonGreen, Color(0xFF00C896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warningOrange, Color(0xFFFF8555)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Glassmorphism overlay
  static const Color glassOverlay = Color(0x1AFFFFFF);
  static const Color glassStroke = Color(0x33FFFFFF);
}
