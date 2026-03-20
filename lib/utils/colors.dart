import 'package:flutter/material.dart';

class AppColors {
  // Vibrant accents
  static const Color primary = Color(0xFF6C63FF); // Modern Indigo
  static const Color secondary = Color(0xFF00C9A7); // Vibrant Teal / Mint
  static const Color accent = Color(0xFFFF6584); // Coral pink

  // Background and surfaces
  static const Color backgroundDark = Color(0xFF1E1E2C);
  static const Color backgroundLight = Color(0xFFF4F7F6);
  static const Color surfaceDark = Color(0xFF2D2D44);
  
  // Text
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFFF8F9FA);
  static const Color principalBackgroud = backgroundLight; // fallback

  // Gradient
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8A84FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
