// Calm UI atoms — Flutter ports of the components in
// `prototype-calm/ui.jsx`. Keep these widgets cosmetic-only: they
// don't reach into providers; presentation layers pass values in.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

/// A tabular-figures numeric span. Use it for currency, percentages,
/// and counts so columns stay aligned.
class CalmNum extends StatelessWidget {
  const CalmNum(
    this.text, {
    super.key,
    this.size = 14,
    this.weight = FontWeight.w500,
    this.color,
    this.letterSpacing,
  });

  final String text;
  final double size;
  final FontWeight weight;
  final Color? color;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color ?? CalmPalette.of(context).fg,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: letterSpacing ?? -size * 0.005,
        height: 1.1,
      ),
    );
  }
}

enum CalmTone { neutral, positive, negative, warning, accent }

/// Soft pill chip — small, tinted background pulled from the tone color.
class CalmPill extends StatelessWidget {
  const CalmPill({
    super.key,
    required this.label,
    this.tone = CalmTone.neutral,
    this.large = false,
  });

  final String label;
  final CalmTone tone;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    final Color color = switch (tone) {
      CalmTone.positive => p.pos,
      CalmTone.negative => p.neg,
      CalmTone.warning => p.warn,
      CalmTone.accent => p.accent,
      CalmTone.neutral => p.muted,
    };
    final double hpad = large ? 10 : 9;
    final double vpad = large ? 5 : 3.5;
    final double fs = large ? 12 : 11;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hpad, vertical: vpad),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fs,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: -0.05,
          height: 1.1,
        ),
      ),
    );
  }
}

enum CalmBtnVariant { primary, accent, ghost, quiet, panel, danger }

enum CalmBtnSize { sm, md, lg }

/// Stadium-shaped button matching the prototype's `Btn` atom.
class CalmButton extends StatelessWidget {
  const CalmButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = CalmBtnVariant.primary,
    this.size = CalmBtnSize.md,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final CalmBtnVariant variant;
  final CalmBtnSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    final double h = switch (size) {
      CalmBtnSize.lg => 54,
      CalmBtnSize.sm => 40,
      CalmBtnSize.md => 50,
    };
    late final Color bg;
    late final Color fg;
    late final Color border;
    switch (variant) {
      case CalmBtnVariant.primary:
        bg = p.fg;
        fg = p.bg;
        border = Colors.transparent;
        break;
      case CalmBtnVariant.accent:
        bg = p.accent;
        fg = p.accentFg;
        border = Colors.transparent;
        break;
      case CalmBtnVariant.ghost:
        bg = Colors.transparent;
        fg = p.fg;
        border = p.border;
        break;
      case CalmBtnVariant.quiet:
        bg = Colors.transparent;
        fg = p.muted;
        border = Colors.transparent;
        break;
      case CalmBtnVariant.panel:
        bg = p.panel;
        fg = p.fg;
        border = p.border;
        break;
      case CalmBtnVariant.danger:
        bg = Colors.transparent;
        fg = p.neg;
        border = p.border;
        break;
    }

    final disabled = onPressed == null;
    final btn = Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: SizedBox(
          height: h,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: fg, size: 16),
                    child: icon!,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final sized = fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
    return Opacity(opacity: disabled ? 0.45 : 1, child: sized);
  }
}

/// Underline-only input field — small muted label above, optional
/// prefix/suffix flanks. Matches `Field` from `ui.jsx`.
class CalmField extends StatefulWidget {
  const CalmField({
    super.key,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    required this.controller,
    this.placeholder,
    this.keyboardType,
    this.inputFormatters,
    this.large = false,
    this.error,
    this.onChanged,
    this.autoFocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String? label;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final TextEditingController controller;
  final String? placeholder;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool large;
  final String? error;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;
  final TextCapitalization textCapitalization;

  @override
  State<CalmField> createState() => _CalmFieldState();
}

class _CalmFieldState extends State<CalmField> {
  late final FocusNode _focus = FocusNode()..addListener(_handle);

  void _handle() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_handle)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    final focused = _focus.hasFocus;
    final Color line = widget.error != null
        ? p.neg
        : focused
            ? p.fg
            : p.borderHi;
    final double inputSize = widget.large ? 26 : 17;
    final flankColor = focused ? p.fg : p.subtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    widget.label!,
                    style: TextStyle(
                      color: p.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.065,
                    ),
                  ),
                ),
                if (widget.hint != null)
                  Text(
                    widget.hint!,
                    style: TextStyle(
                      color: p.subtle,
                      fontSize: 12,
                      letterSpacing: -0.06,
                    ),
                  ),
              ],
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: line, width: 1.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (widget.prefix != null) ...[
                Text(
                  widget.prefix!,
                  style: TextStyle(
                    color: flankColor,
                    fontSize: widget.large ? 22 : 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  autofocus: widget.autoFocus,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  textCapitalization: widget.textCapitalization,
                  cursorColor: p.accent,
                  style: TextStyle(
                    color: p.fg,
                    fontSize: inputSize,
                    fontWeight: widget.large ? FontWeight.w500 : FontWeight.w400,
                    letterSpacing: widget.large ? -0.65 : -0.17,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: widget.placeholder ?? '—',
                    hintStyle: TextStyle(
                      color: p.subtle.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (widget.suffix != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.suffix!,
                  style: TextStyle(
                    color: flankColor,
                    fontSize: widget.large ? 22 : 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Soft section heading — optional muted eyebrow, big subtle-letter-spaced
/// title, optional muted subtitle.
class CalmSectionTitle extends StatelessWidget {
  const CalmSectionTitle({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                eyebrow!,
                style: TextStyle(
                  color: p.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.06,
                ),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              color: p.fg,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.98,
              height: 1.1,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                subtitle!,
                style: TextStyle(
                  color: p.muted,
                  fontSize: 14,
                  height: 1.5,
                  letterSpacing: -0.07,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Brand "K" mark + wordmark used in the top bar.
class CalmBrandTitle extends StatelessWidget {
  const CalmBrandTitle({super.key, this.title = 'Kârly'});

  final String title;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: p.fg,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            'K',
            style: TextStyle(
              color: p.bg,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1,
              letterSpacing: -0.48,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: p.fg,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.45,
          ),
        ),
      ],
    );
  }
}
