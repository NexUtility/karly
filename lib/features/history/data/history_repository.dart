import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../calculator/domain/calculate.dart';
import '../../calculator/domain/inputs.dart';
import 'saved_calculation.dart';

/// Reads and writes the user's History to SharedPreferences.
///
/// History lives under a single JSON key as a list of entries — fine
/// up to ~1k entries; if it grows beyond that we'll migrate to drift
/// or isar without changing this interface.
class HistoryRepository {
  static const _key = 'history.entries.v1';

  Future<List<SavedCalculation>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final entries = <SavedCalculation>[];
      for (final e in decoded) {
        try {
          entries.add(SavedCalculation.fromJson(e as Map<String, dynamic>));
        } catch (_) {
          // Skip entries we can't decode rather than fail the whole load.
        }
      }
      // Newest first.
      entries.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return entries;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<SavedCalculation> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  /// Adds a new entry to the front of the list. Returns the entry that
  /// was written (with its assigned id).
  Future<SavedCalculation> add({
    required CalcInputs inputs,
    required CalcResult result,
    required String marketplaceId,
  }) async {
    final now = DateTime.now();
    final entry = SavedCalculation(
      id: now.microsecondsSinceEpoch.toString(),
      savedAt: now,
      marketplaceId: marketplaceId,
      inputs: inputs,
      result: result,
    );
    final existing = await load();
    await save([entry, ...existing]);
    return entry;
  }

  Future<void> delete(String id) async {
    final existing = await load();
    existing.removeWhere((e) => e.id == id);
    await save(existing);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
