import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How many calculations a free user can run in a single calendar day
/// (device local time). Pro users bypass the cap entirely.
///
/// PDFs are not capped — once a calculation has been run, the resulting
/// report can be shared as many times as the user wants.
const int kDailyFreeCalcCap = 3;

class UsageQuotaState {
  const UsageQuotaState({
    required this.date,
    required this.calculationsToday,
  });

  /// ISO date string (YYYY-MM-DD) for the day this count applies to.
  final String date;

  /// Number of calculations the free user has run today.
  final int calculationsToday;

  bool freeUserCanCalculateMore() => calculationsToday < kDailyFreeCalcCap;
}

/// Tracks the daily calculation quota in SharedPreferences.
///
/// The stored payload is a small JSON object:
///   { "date": "2026-05-13", "count": 2 }
/// Reads resync the date on every call so the count rolls over at
/// local midnight without an app restart.
class UsageQuotaNotifier extends AsyncNotifier<UsageQuotaState> {
  static const _key = 'usage.daily-calcs.v1';

  @override
  Future<UsageQuotaState> build() async {
    return _readForToday();
  }

  Future<UsageQuotaState> _readForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return UsageQuotaState(date: today, calculationsToday: 0);
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final storedDate = decoded['date'] as String?;
      final count = (decoded['count'] as num?)?.toInt() ?? 0;
      if (storedDate == today) {
        return UsageQuotaState(date: today, calculationsToday: count);
      }
    } catch (_) {
      // Fall through to fresh state on parse errors.
    }
    return UsageQuotaState(date: today, calculationsToday: 0);
  }

  /// Records one calculation. Always succeeds — caller is responsible
  /// for gating with [UsageQuotaState.freeUserCanCalculateMore] before
  /// invoking on free-tier users.
  Future<void> recordCalculation() async {
    final current = await _readForToday();
    final next = UsageQuotaState(
      date: current.date,
      calculationsToday: current.calculationsToday + 1,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({'date': next.date, 'count': next.calculationsToday}),
    );
    state = AsyncData(next);
  }

  /// Refreshes the cached state from disk + today's clock. Useful when
  /// returning to the calculator screen so a midnight rollover is
  /// reflected without restarting.
  Future<void> refresh() async {
    state = AsyncData(await _readForToday());
  }

  String _todayKey() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

final usageQuotaProvider =
    AsyncNotifierProvider<UsageQuotaNotifier, UsageQuotaState>(
  UsageQuotaNotifier.new,
);
