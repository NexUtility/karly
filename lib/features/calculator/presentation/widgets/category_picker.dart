import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../theme/colors.dart';
import '../../data/category.dart';

/// Calm category picker. The trigger sits inline beneath the item-name
/// field — a thin outlined pill showing either the selected category or
/// the "Pick a category" hint. Tapping it opens a searchable bottom
/// sheet whose row style mirrors `prototype-calm/pickers.jsx`.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Category? selected;
  final ValueChanged<Category> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final label = selected?.displayName(l10n) ?? l10n.categoryPickHint;

    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: p.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 13,
                color: p.muted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: p.muted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.06,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: CalmPalette.of(context).sheetScrim,
      builder: (ctx) => _CategorySheet(selected: selected),
    );
    if (picked != null) onChanged(picked);
  }
}

class _CategorySheet extends StatefulWidget {
  const _CategorySheet({required this.selected});

  final Category? selected;

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final media = MediaQuery.of(context);

    final all = Category.values;
    final filtered = _query.isEmpty
        ? all
        : all
            .where((c) => c.displayName(l10n).toLowerCase().contains(_query))
            .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
        child: Container(
          decoration: BoxDecoration(
            color: p.bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(p: p),
              _SheetHeader(
                p: p,
                eyebrow: l10n.categoryLabel,
                title: l10n.categoryPickHint,
                onClose: () => Navigator.of(context).maybePop(),
              ),
              // Search pill
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 14),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: p.panel,
                    border: Border.all(color: p.border),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 15, color: p.muted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          autofocus: false,
                          cursorColor: p.accent,
                          style: TextStyle(
                            color: p.fg,
                            fontSize: 15,
                            letterSpacing: -0.06,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: l10n.categorySearchHint,
                            hintStyle: TextStyle(
                              color: p.muted.withValues(alpha: 0.7),
                            ),
                          ),
                          onChanged: (v) => setState(
                            () => _query = v.trim().toLowerCase(),
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: p.muted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No matches for "$_query".',
                            style: TextStyle(
                              color: p.muted,
                              fontSize: 14,
                              letterSpacing: -0.07,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          bottom: 18 + media.padding.bottom,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final c = filtered[i];
                          final sel = c == widget.selected;
                          return InkWell(
                            onTap: () => Navigator.of(context).pop(c),
                            child: Container(
                              color: sel ? p.accentSoft : Colors.transparent,
                              padding: const EdgeInsets.fromLTRB(
                                22,
                                14,
                                22,
                                14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      c.displayName(l10n),
                                      style: TextStyle(
                                        color: sel ? p.accent : p.fg,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.15,
                                      ),
                                    ),
                                  ),
                                  if (sel)
                                    Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: p.accent,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.p});

  final CalmPalette p;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: p.borderHi,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.p,
    required this.eyebrow,
    required this.title,
    required this.onClose,
  });

  final CalmPalette p;
  final String eyebrow;
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  eyebrow,
                  style: TextStyle(
                    color: p.subtle,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.06,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: p.fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            shape: CircleBorder(side: BorderSide(color: p.border)),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onClose,
              child: SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.close_rounded, size: 14, color: p.fg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
