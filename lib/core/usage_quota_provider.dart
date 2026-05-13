import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How many PDF reports a free user can share in a single calendar day
/// (device local time). Pro users bypass the cap entirely.
const int kDailyFreeReportCap = 3;

class UsageQuotaState {
  const UsageQuotaState({
    required this.date,
    required this.reportsToday,
  });

  /// ISO date string (YYYY-MM-DD) for the day this count applies to.
  final String date;

  /// Number of PDF reports the user has shared today.
  final int reportsToday;

  bool freeUserCanShareMore() => reportsToday < kDailyFreeReportCap;
}

/// Tracks daily PDF report usage in SharedPreferences.
///
/// The stored payload is a small JSON object:
///   { "date": "2026-05-13", "count": 2 }
/// Reads resync the date on every call so the count rolls over at
/// local midnight without an app restart.
class UsageQuotaNotifier extends AsyncNotifier<UsageQuotaState> {
  static const _key = 'usage.daily-reports.v1';

  @override
  Future<UsageQuotaState> build() async {
    return _readForToday();
  }

  Future<UsageQuotaState> _readForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return UsageQuotaState(date: today, reportsToday: 0);
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final storedDate = decoded['date'] as String?;
      final count = (decoded['count'] as num?)?.toInt() ?? 0;
      if (storedDate == today) {
        return UsageQuotaState(date: today, reportsToday: count);
      }
    } catch (_) {
      // Fall through to fresh state on parse errors.
    }
    return UsageQuotaState(date: today, reportsToday: 0);
  }

  /// Records a PDF share. Always succeeds — caller is responsible for
  /// gating with [canShareReport] before invoking.
  Future<void> recordReportShared() async {
    final current = await _readForToday();
    final next = UsageQuotaState(
      date: current.date,
      reportsToday: current.reportsToday + 1,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({'date': next.date, 'count': next.reportsToday}),
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
