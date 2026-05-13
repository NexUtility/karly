import 'package:flutter/foundation.dart';

import '../../calculator/domain/calculate.dart';
import '../../calculator/domain/inputs.dart';

/// A persisted calculation in the user's History.
///
/// Carries the full inputs and computed result so the entry can be
/// re-shared as a PDF later without re-entering anything, and stores
/// the marketplace + category as filter keys.
@immutable
class SavedCalculation {
  const SavedCalculation({
    required this.id,
    required this.savedAt,
    required this.marketplaceId,
    required this.inputs,
    required this.result,
  });

  /// Stable id. Generated from `microsecondsSinceEpoch` at save time.
  final String id;

  final DateTime savedAt;
  final String marketplaceId;
  final CalcInputs inputs;
  final CalcResult result;

  /// Convenience accessor — category lives on the inputs.
  String? get categoryId => inputs.categoryId;

  /// Convenience accessor — item name lives on the inputs.
  String? get itemName => inputs.itemName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'savedAt': savedAt.toIso8601String(),
        'marketplaceId': marketplaceId,
        'inputs': inputs.toJson(),
        'result': result.toJson(),
      };

  factory SavedCalculation.fromJson(Map<String, dynamic> json) => SavedCalculation(
        id: json['id'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
        marketplaceId: json['marketplaceId'] as String,
        inputs: CalcInputs.fromJson(json['inputs'] as Map<String, dynamic>),
        result: CalcResult.fromJson(json['result'] as Map<String, dynamic>),
      );
}
