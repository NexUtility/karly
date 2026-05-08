import 'package:flutter/material.dart';

/// NexUtility brand color tokens.
///
/// These mirror the tokens used on nexutility.com — single accent
/// (lime) on a near-black neutral palette in dark mode, near-white
/// neutral in light mode.
class BrandColors {
  const BrandColors._();

  static const Color accent = Color(0xFFC5FA1F);
  static const Color accentHover = Color(0xFFB9F015);
  static const Color accentForeground = Color(0xFF0A0A0A);

  // Dark
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color darkElev = Color(0xFF111111);
  static const Color darkElev2 = Color(0xFF161616);
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkBorderStrong = Color(0xFF3F3F46);
  static const Color darkFg = Color(0xFFFAFAFA);
  static const Color darkFgMuted = Color(0xFFA1A1AA);
  static const Color darkFgSubtle = Color(0xFF71717A);

  // Light
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightElev = Color(0xFFFFFFFF);
  static const Color lightElev2 = Color(0xFFF4F4F5);
  static const Color lightBorder = Color(0xFFE4E4E7);
  static const Color lightBorderStrong = Color(0xFFD4D4D8);
  static const Color lightFg = Color(0xFF09090B);
  static const Color lightFgMuted = Color(0xFF52525B);
  static const Color lightFgSubtle = Color(0xFF71717A);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
}
