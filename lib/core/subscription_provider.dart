import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Subscription tiers offered by Kârly Pro.
enum SubscriptionTier { free, proMonthly, proAnnual }

@immutable
class SubscriptionState {
  const SubscriptionState({this.tier = SubscriptionTier.free});

  final SubscriptionTier tier;

  bool get isPro => tier != SubscriptionTier.free;
}

/// Stub subscription state for v0.1.
///
/// In v0.2 this gets swapped for a `purchases_flutter` (RevenueCat)-backed
/// implementation that:
///   - listens to entitlement changes from the SDK
///   - calls `Purchases.purchasePackage` on tap
///   - calls `Purchases.restorePurchases` on restore
///
/// The rest of the app reads `subscriptionProvider` and shouldn't care
/// which implementation is wired underneath.
class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => const SubscriptionState();

  /// v0.1 stub — flips local state without billing.
  /// Used for previewing the Pro experience while RevenueCat isn't wired.
  void debugSetTier(SubscriptionTier tier) {
    state = SubscriptionState(tier: tier);
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
      SubscriptionNotifier.new,
    );
