import 'package:flutter/material.dart';

/// Centralized color palette for Thovario.
class AppColors {
  AppColors._();

  // Dark Theme Palette (Default & Brand-defining)
  static const Color darkBackground = Color(0xFF101014);
  static const Color darkSurface = Color(0xFF19191F);
  static const Color darkElevatedSurface = Color(0xFF22222A);
  static const Color darkBorder = Color(0xFF2B2A34);
  static const Color darkPrimaryText = Color(0xFFF4F0EB);
  static const Color darkSecondaryText = Color(0xFFA7A3AD);
  static const Color darkAccent = Color(0xFFB9A4F5);
  static const Color darkAccentSubtle = Color(0x26B9A4F5);
  static const Color darkDestructive = Color(0xFFE06D6D);
  static const Color darkDestructiveSubtle = Color(0x26E06D6D);

  // Light Theme Palette (Warm, tranquil, paper-like)
  static const Color lightBackground = Color(0xFFFAF8F5);
  static const Color lightSurface = Color(0xFFF0ECE3);
  static const Color lightElevatedSurface = Color(0xFFE6E1D7);
  static const Color lightBorder = Color(0xFFDDD7CC);
  static const Color lightPrimaryText = Color(0xFF18181C);
  static const Color lightSecondaryText = Color(0xFF6B6775);
  static const Color lightAccent = Color(0xFF7A62B8);
  static const Color lightAccentSubtle = Color(0x207A62B8);
  static const Color lightDestructive = Color(0xFFC74C4C);
  static const Color lightDestructiveSubtle = Color(0x20C74C4C);

  // Universal tones
  static const Color favoriteGold = Color(0xFFE8B65A);
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;
}
