import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../calculator/domain/calculate.dart';
import '../calculator/domain/inputs.dart';
import 'data/history_repository.dart';
import 'data/saved_calculation.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

/// Loads and exposes the full History list. Newest first.
class HistoryNotifier extends AsyncNotifier<List<SavedCalculation>> {
  late HistoryRepository _repo;

  @override
  Future<List<SavedCalculation>> build() async {
    _repo = ref.read(historyRepositoryProvider);
    return _repo.load();
  }

  Future<SavedCalculation> add({
    required CalcInputs inputs,
    required CalcResult result,
    required String marketplaceId,
  }) async {
    final entry = await _repo.add(
      inputs: inputs,
      result: result,
      marketplaceId: marketplaceId,
    );
    state = AsyncData([entry, ...?state.value]);
    return entry;
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    final current = state.value ?? const [];
    state = AsyncData(current.where((e) => e.id != id).toList());
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<SavedCalculation>>(
  HistoryNotifier.new,
);

/// Filter state for the History screen — independent of the data list
/// so toggling chips doesn't reload from disk.
class HistoryFilter {
  const HistoryFilter({this.categoryId, this.marketplaceId});

  final String? categoryId;
  final String? marketplaceId;

  bool get isActive => categoryId != null || marketplaceId != null;

  HistoryFilter copyWith({String? categoryId, String? marketplaceId}) {
    return HistoryFilter(
      categoryId: categoryId ?? this.categoryId,
      marketplaceId: marketplaceId ?? this.marketplaceId,
    );
  }

  HistoryFilter clearCategory() =>
      HistoryFilter(categoryId: null, marketplaceId: marketplaceId);
  HistoryFilter clearMarketplace() =>
      HistoryFilter(categoryId: categoryId, marketplaceId: null);
  HistoryFilter clearAll() => const HistoryFilter();
}

class HistoryFilterNotifier extends Notifier<HistoryFilter> {
  @override
  HistoryFilter build() => const HistoryFilter();

  void setCategory(String? id) => state = state.copyWith(categoryId: id);
  void setMarketplace(String? id) =>
      state = state.copyWith(marketplaceId: id);
  void clearCategory() => state = state.clearCategory();
  void clearMarketplace() => state = state.clearMarketplace();
  void clearAll() => state = state.clearAll();
}

final historyFilterProvider =
    NotifierProvider<HistoryFilterNotifier, HistoryFilter>(
  HistoryFilterNotifier.new,
);
