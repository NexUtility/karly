# Kârly

> **Cross-border marketplace seller profit calculator.**
> Trendyol, Hepsiburada, n11, Çiçek Sepeti, Pazarama, Amazon, Etsy, eBay,
> Shopify — one app.

Built with **Flutter 3.41 + Material 3**, distributed on the **App Store** and
**Google Play** by [NexUtility](https://github.com/NexUtility).

Full product spec: [`docs/SPEC.md`](docs/SPEC.md).

## Quick start

```bash
flutter pub get
flutter gen-l10n            # generate AppLocalizations from arb files
flutter run                 # dev run on the connected device / simulator
flutter analyze             # static analysis
flutter test                # unit + widget tests
flutter build apk           # Android release build
flutter build ios            # iOS release build (macOS only)
```

## Project layout

```
lib/
├── main.dart                       # ProviderScope + KarlyApp
├── app.dart                        # MaterialApp.router, theme, l10n delegates
├── app_shell.dart                  # Bottom nav scaffold
├── router.dart                     # go_router config (3 tabs)
├── theme/
│   ├── colors.dart                 # NexUtility brand tokens
│   └── theme.dart                  # Material 3 light + dark themes
├── core/
│   └── format.dart                 # Currency + percent formatters (intl)
├── l10n/
│   ├── app_en.arb                  # English source strings
│   ├── app_tr.arb                  # Turkish translations
│   └── generated/                  # Generated AppLocalizations (gitignored)
└── features/
    ├── calculator/
    │   ├── data/
    │   │   ├── marketplace.dart           # Model
    │   │   └── marketplaces.dart          # 10 default marketplaces
    │   ├── domain/
    │   │   ├── inputs.dart                # CalcInputs
    │   │   └── calculate.dart             # Pure calculateProfit()
    │   └── presentation/
    │       ├── calculator_screen.dart     # Main screen
    │       └── widgets/
    │           ├── marketplace_picker.dart
    │           └── result_card.dart
    ├── history/presentation/history_screen.dart   # Stubbed empty state
    └── settings/presentation/settings_screen.dart # Privacy / Terms / Support links
test/
└── calculator/domain/calculate_test.dart
```

## Brand identity (locked)

| Field             | Value                          |
| ----------------- | ------------------------------ |
| Display name      | **Kârly** (with circumflex)    |
| Bundle ID         | `com.nexutility.karly` ⚠️ permanent |
| Dart package name | `karly`                        |
| GitHub repo       | `NexUtility/karly`             |
| Marketing URL     | `nexutility.com/apps/karly`    |
| Privacy URL       | `nexutility.com/privacy`       |
| Support URL       | `nexutility.com/support`       |
| Terms URL         | `nexutility.com/terms`         |

## Stack

- **Flutter 3.41 stable**, Dart 3.11
- **Riverpod 2** for state management
- **go_router 14** for routing
- **intl** for i18n + number / currency formatting
- **shared_preferences** for settings + future cached calculations
- **decimal** for precise calculation primitives (currency-safe)
- Tests via `flutter_test`

Future deps (added when wired):

- `google_mobile_ads` — AdMob banner + capped interstitial on free tier
- `purchases_flutter` — RevenueCat for subscription entitlements
- `drift` or `isar` — once history + saved calculations grow beyond
  shared_preferences

## i18n

- Source: `lib/l10n/app_en.arb`
- Translation: `lib/l10n/app_tr.arb`
- Generated code: `lib/l10n/generated/app_localizations.dart` (auto)
- `flutter gen-l10n` runs on every `flutter pub get`.

To add a new locale:

1. Copy `app_en.arb` to `app_<code>.arb`, translate values.
2. Run `flutter gen-l10n`.
3. Add to `CFBundleLocalizations` in `ios/Runner/Info.plist`.

## Roadmap

See [`docs/SPEC.md`](docs/SPEC.md) — short version: Calculator MVP shipped,
History + paywall + AdMob next, then multi-currency FX + CSV export, then store
submission with full localized listings.
