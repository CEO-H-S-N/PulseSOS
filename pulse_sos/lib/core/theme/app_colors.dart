import 'package:flutter/material.dart';

/// PulseSOS Color System - Cyber-security inspired palette
class AppColors {
  AppColors._();

  // Brand Colors
  static const Color electricCyan = Color(0xFF00E5FF);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color emergencyRed = Color(0xFFFF1744);
  static const Color warningAmber = Color(0xFFFFAB00);
  static const Color pulseBlue = Color(0xFF2979FF);

  // Dark Theme
  static const Color deepBlack = Color(0xFF050810);
  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color surfaceDark = Color(0xFF0F1328);
  static const Color cardDark = Color(0xFF141832);
  static const Color inputFillDark = Color(0xFF0D1120);
  static const Color borderDark = Color(0xFF1E2440);
  static const Color textPrimary = Color(0xFFF0F2FF);
  static const Color textSecondary = Color(0xFFB0B8D4);
  static const Color textTertiary = Color(0xFF6B7394);

  // Light Theme
  static const Color electricCyanLight = Color(0xFF0097A7);
  static const Color neonGreenLight = Color(0xFF2E7D32);
  static const Color emergencyRedLight = Color(0xFFD32F2F);
  static const Color warningAmberLight = Color(0xFFF57F17);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inputFillLight = Color(0xFFF0F2F5);
  static const Color borderLight = Color(0xFFE0E3EB);
  static const Color textPrimaryLight = Color(0xFF1A1D2E);
  static const Color textSecondaryLight = Color(0xFF5A5F7A);
  static const Color textTertiaryLight = Color(0xFF9498AD);

  // Incident Type Colors
  static const Color robbery = Color(0xFFFF6D00);
  static const Color medical = Color(0xFFFF1744);
  static const Color fire = Color(0xFFFF3D00);
  static const Color harassment = Color(0xFFAA00FF);
  static const Color accident = Color(0xFFFFAB00);
  static const Color kidnapping = Color(0xFFD50000);
  static const Color other = Color(0xFF651FFF);

  // Status Colors
  static const Color active = Color(0xFFFF1744);
  static const Color acknowledged = Color(0xFFFFAB00);
  static const Color responding = Color(0xFF2979FF);
  static const Color resolved = Color(0xFF00E676);
  static const Color escalated = Color(0xFFD50000);

  // Gradients
  static const LinearGradient sosPulseGradient = LinearGradient(
    colors: [Color(0xFFFF1744), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient safeGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color incidentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'robbery': return robbery;
      case 'medical': return medical;
      case 'fire': return fire;
      case 'harassment': return harassment;
      case 'accident': return accident;
      case 'kidnapping': return kidnapping;
      default: return other;
    }
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'triggered':
      case 'active': return active;
      case 'acknowledged': return acknowledged;
      case 'responders_incoming': return responding;
      case 'resolved': return resolved;
      case 'escalated': return escalated;
      default: return textTertiary;
    }
  }
}
