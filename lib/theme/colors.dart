import 'package:flutter/material.dart';

/// Kârly "Calm" brand color tokens.
///
/// A warm, coffee-toned palette with a calm sage accent — designed to
/// feel like a competent everyday tool, not a forex terminal. Ported
/// from `prototype-calm/ui.jsx::ledgerPalette`.
class BrandColors {
  const BrandColors._();

  // ── Accent (sage) ───────────────────────────────────────────────
  // Dark canvas uses a brighter sage; light canvas uses a deeper one.
  static const Color accentDark = Color(0xFFC8E085);
  static const Color accentLight = Color(0xFF5C7A1F);
  static const Color accentForegroundDark = Color(0xFF1A1A14);
  static const Color accentForegroundLight = Color(0xFFFFFFFF);

  // Back-compat alias — most existing call-sites just reach for `accent`.
  // We expose the dark-canvas accent here because the app launches dark.
  static const Color accent = accentDark;
  static const Color accentHover = Color(0xFFB8D072);
  static const Color accentForeground = accentForegroundDark;

  // ── Dark canvas (coffee / walnut) ───────────────────────────────
  static const Color darkBg = Color(0xFF16140F);
  static const Color darkElev = Color(0xFF1E1B14);
  static const Color darkElev2 = Color(0xFF26221A);
  static const Color darkBorder = Color(0xFF2A271F);
  static const Color darkBorderStrong = Color(0xFF3A3528);
  static const Color darkFg = Color(0xFFF2EDE0);
  static const Color darkFgMuted = Color(0xFFA8A290);
  static const Color darkFgSubtle = Color(0xFF6E6957);

  // ── Light canvas (warm cream) ───────────────────────────────────
  static const Color lightBg = Color(0xFFF7F3EA);
  static const Color lightElev = Color(0xFFFFFFFF);
  static const Color lightElev2 = Color(0xFFF0EBDF);
  static const Color lightBorder = Color(0xFFE8E0CE);
  static const Color lightBorderStrong = Color(0xFFD6CCB5);
  static const Color lightFg = Color(0xFF1B1916);
  static const Color lightFgMuted = Color(0xFF5E594C);
  static const Color lightFgSubtle = Color(0xFF8E887A);

  // ── Semantic (calmer than full-saturation rgb) ──────────────────
  static const Color posDark = Color(0xFFA8C969);
  static const Color posLight = Color(0xFF3F7000);
  static const Color negDark = Color(0xFFE8A088);
  static const Color negLight = Color(0xFFB85138);
  static const Color warnDark = Color(0xFFE8C078);
  static const Color warnLight = Color(0xFFA56A1A);

  // Brightness-agnostic aliases for older call-sites — pick a sensible
  // mid-tone that reads on both canvases.
  static const Color success = posDark;
  static const Color warning = warnDark;
  static const Color danger = negDark;
}

/// Resolves the Calm palette tokens for a given brightness. Use in
/// presentation widgets that want a struct-like accessor instead of
/// reaching into [BrandColors] and the [ColorScheme] separately.
class CalmPalette {
  const CalmPalette({
    required this.bg,
    required this.panel,
    required this.panelHi,
    required this.border,
    required this.borderHi,
    required this.fg,
    required this.muted,
    required this.subtle,
    required this.accent,
    required this.accentFg,
    required this.accentSoft,
    required this.pos,
    required this.neg,
    required this.warn,
    required this.sheetScrim,
  });

  final Color bg;
  final Color panel;
  final Color panelHi;
  final Color border;
  final Color borderHi;
  final Color fg;
  final Color muted;
  final Color subtle;
  final Color accent;
  final Color accentFg;
  final Color accentSoft;
  final Color pos;
  final Color neg;
  final Color warn;
  final Color sheetScrim;

  static CalmPalette of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? _dark : _light;
  }

  static const _dark = CalmPalette(
    bg: BrandColors.darkBg,
    panel: BrandColors.darkElev,
    panelHi: BrandColors.darkElev2,
    border: BrandColors.darkBorder,
    borderHi: BrandColors.darkBorderStrong,
    fg: BrandColors.darkFg,
    muted: BrandColors.darkFgMuted,
    subtle: BrandColors.darkFgSubtle,
    accent: BrandColors.accentDark,
    accentFg: BrandColors.accentForegroundDark,
    accentSoft: Color(0x22C8E085),
    pos: BrandColors.posDark,
    neg: BrandColors.negDark,
    warn: BrandColors.warnDark,
    sheetScrim: Color(0xA8080704),
  );

  static const _light = CalmPalette(
    bg: BrandColors.lightBg,
    panel: BrandColors.lightElev,
    panelHi: BrandColors.lightElev2,
    border: BrandColors.lightBorder,
    borderHi: BrandColors.lightBorderStrong,
    fg: BrandColors.lightFg,
    muted: BrandColors.lightFgMuted,
    subtle: BrandColors.lightFgSubtle,
    accent: BrandColors.accentLight,
    accentFg: BrandColors.accentForegroundLight,
    accentSoft: Color(0x125C7A1F),
    pos: BrandColors.posLight,
    neg: BrandColors.negLight,
    warn: BrandColors.warnLight,
    sheetScrim: Color(0x57282010),
  );
}
