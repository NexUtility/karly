# Kârly — Product Spec

> **Status:** v0.2 / categories + History + daily PDF cap landed (paywall still stub)
> **Last updated:** 2026-05-13
> **Owner:** NexUtility studio

## Premise

Kârly is a cross-border marketplace seller profit calculator. A small seller
who lists on **Trendyol** can also list on **Etsy** or **Amazon**, and they
need one mobile app that computes net profit consistently across all of those
marketplaces. No competitor on the App Store today serves the
"TR pazaryeri × Android × modern UI" intersection — that is our wedge.

## Target user

- **Primary:** Turkish small sellers expanding from Trendyol / Hepsiburada /
  N11 to Etsy / Amazon / eBay. Bilingual (TR + EN), price-sensitive, mobile-first.
- **Secondary:** Global sellers (Etsy / eBay / Shopify) who want a simple,
  ad-free, modern alternative to spreadsheet calculators.
- **Out of scope (for MVP):** Amazon FBA pros (already served by tool4seller,
  sellerboard, Helium 10), enterprise multi-seat teams.

## Monetization model — ad-free, freemium

Kârly does **not** run ads. We never wired AdMob. Free is genuinely free, just
gated by a daily cap on the highest-value action.

| Tier | Pricing | What you get |
| --- | --- | --- |
| **Free** | $0 | Calculator with all 10 marketplaces, category selector, **3 PDF reports per day** |
| **Pro Monthly** | ₺79 / $2.99 per month | Everything in Free + **unlimited PDF reports** + **History** (save, browse, filter by category & marketplace) |
| **Pro Annual** ⭐ | ₺599 / $19.99 per year | Same as Monthly. Saves ~37%. |

Pricing levers stay simple. No lifetime tier. No ads in any tier — ever.
RevenueCat will manage entitlements and store-side billing once it lands.

## What we actually promise (truth in advertising)

The paywall lists three things. All three are real features the app actually
delivers when the subscription is active (vs. when it isn't):

1. **Save every calculation to History** — Free users can calculate, share a
   PDF, then move on. Pro users save the calculation with its category and
   marketplace.
2. **Filter History by category and marketplace** — Pro-only filter bar above
   the History list.
3. **Unlimited PDF reports** — Free users are capped at 3 PDF reports per
   local day (counter resets at midnight). Pro users have no cap.

Anything else (cross-marketplace SKU compare, multi-currency w/ live FX) is
**deferred until built**. Not promised on the paywall.

## What this app is _not_

- Not an accounting tool.
- Not a bookkeeping ledger.
- Not a marketplace API integration (no live listing sync — manual input only).
- Not a tax filing tool.
- Not ad-supported. We do not run AdMob or any other ad SDK.

## Core flow

1. User opens the app → lands on Calculator screen with the brand AppBar.
2. Picks a **marketplace** (locale-aware section order; defaults to Trendyol
   for TR, Amazon US for EN).
3. Picks a **category** from the searchable bottom sheet (~29 marketplace-agnostic options).
4. Enters optional `item name`, then `item cost`, `sell price`,
   `commission %` (pre-filled), `VAT/KDV %` (pre-filled from marketplace),
   optional `shipping cost`, optional `operational costs` (ads / packaging /
   returns / fulfillment).
5. Taps **Calculate** → result card with:
   - Big headline: **Net profit** (red if loss, brand accent if profit)
   - Pills: margin %, ROI %
   - Breakdown: commission, VAT, breakeven price
6. Taps **Share PDF** → system share sheet. Free users see a counter
   (`Bugün kullandığın ücretsiz rapor: 1 / 3`). On the 4th share, a paywall
   dialog opens.
7. Taps **Save to History** → for Pro users, entry lands at the top of
   History. For Free users, opens the save-pro-gate dialog with an Upgrade CTA.

## Marketplaces (10)

| Region   | Marketplace        | Default commission | Default VAT |
| -------- | ------------------ | ------------------ | ----------- |
| Türkiye  | Trendyol           | 18 %               | 20 %        |
| Türkiye  | Hepsiburada        | 15.5 %             | 20 %        |
| Türkiye  | n11                | 13 %               | 20 %        |
| Türkiye  | Çiçek Sepeti       | 18 %               | 20 %        |
| Türkiye  | Pazarama           | 12 %               | 20 %        |
| Global   | Amazon US          | 15 %               | 0 %         |
| Global   | Etsy               | 6.5 % + $0.20      | 0 %         |
| Global   | eBay               | 13.5 %             | 0 %         |
| Global   | Shopify (own store)| 2.9 % + $0.30      | 0 %         |
| Global   | Custom             | 0 %                | 0 %         |

All values are **defaults** — the user can override on the calculator screen.
Per-category rate tables are out of scope and arrive later if research
validates the need.

## Categories (29)

A flat, marketplace-agnostic list. Stored as string ids (e.g. `fashion`,
`baby-kids`) and rendered with locale-aware names. Currently:

Electronics · Phones & Accessories · Computers & Tablets · TV, Audio & Cameras ·
Fashion & Clothing · Shoes · Bags & Accessories · Jewelry & Watches ·
Beauty & Personal Care · Health & Wellness · Home & Living · Kitchen & Dining ·
Furniture · Garden & Outdoor · Sports & Outdoor · Automotive & Motorcycle ·
Tools & Hardware · Toys & Games · Baby & Kids · Pet Supplies ·
Books, Music & Movies · Stationery & Office · Food & Beverage · Supermarket ·
Hobby & Craft · Handmade · Art & Collectibles · Digital Products · Other.

## Calculation model

Pure function `calculateProfit(CalcInputs) → CalcResult` in
[`lib/features/calculator/domain/calculate.dart`](../lib/features/calculator/domain/calculate.dart).

```
commission   = sellPrice × commissionRate + fixedListingFee
vat          = sellPrice × vatRate
totalCosts   = itemCost + shippingCost + operationalCosts + commission + vat
netProfit    = sellPrice − totalCosts
margin %     = netProfit ÷ sellPrice × 100
ROI %        = netProfit ÷ itemCost × 100
breakeven    = (itemCost + shippingCost + operationalCosts + fixedListingFee)
              ÷ (1 − commissionRate − vatRate)
```

Backed by unit tests at
[`test/calculator/domain/calculate_test.dart`](../test/calculator/domain/calculate_test.dart).

## UX principles

- **Dark default** — financial-tool audiences expect it; matches NexUtility brand.
- **One screen for the whole flow** — no multi-step wizards.
- **Tabular figures everywhere** — numbers must align so visual comparison is easy.
- **Result is one tap away** — minimum friction from "I have a price idea" to "Should I sell?"
- **Failure is loud** — when net profit is negative, the headline turns red and
  a warning chip appears.
- **No dark patterns at the gate** — when a free user hits a Pro feature, the
  dialog includes both *Upgrade* and *Later*. We never block the back gesture.

## Information architecture

```
Bottom nav (3 tabs):
├── /         Calculator   (brand AppBar; marketplace + category + inputs; Calculate / Reset; PDF share + Save buttons after result)
├── /history  History      (Pro: list with filter bar + entry tiles + swipe-to-delete · Free: embedded paywall)
└── /settings Settings     (Subscription tile + reports-today counter, Language, About links)
```

## Persistence

- **SharedPreferences** under `history.entries.v1` — JSON list of saved
  calculations. Acceptable up to ~1k entries; we'll migrate to drift if it
  grows beyond that.
- **SharedPreferences** under `usage.daily-reports.v1` — `{date, count}`
  object refreshed on every read so midnight rollover doesn't require an
  app restart.
- **SharedPreferences** under `app.locale` — language override.

No remote storage. No analytics. No tracking.

## Roadmap

| Version | Scope | Status |
| --- | --- | --- |
| 0.1 | Calculator MVP, marketplaces preset list, Material 3 dark theme, EN + TR i18n with in-app language switcher, brand AppBar, item name input, PDF report + system share | ✅ shipped |
| 0.2 | **Category selector + master list**, **History with category & marketplace filters** (Pro-gated), **daily 3-report cap on free tier**, **honest paywall (3 features only)**, **AdMob removed from scope** | ✅ this commit |
| 0.3 | RevenueCat billing wired to real Play Store subscriptions, restore purchases | next |
| 0.4 | Cross-marketplace SKU comparison (Pro feature 4), multi-currency with live FX (Pro feature 5) — only if validated by user feedback | TBD |
| 0.5 | Per-category commission tables for TR marketplaces, KDV-correct mode | TBD |
| 1.0 | Play Store submission with full localized listings (EN + TR + DE + ES at minimum), screenshots, marketing site presence. App Store deferred. | TBD |

## Constraints

- **Launch platform: Android only.** iOS deferred until Android revenue covers
  the Apple Developer Program fee + a Mac. `ios/` folder stays in the repo.
- **No ads, ever.** AdMob is intentionally out of scope. Free tier is free.
- **Bundle ID / Application ID is permanent:** `com.nexutility.karly`. Never
  changes after first Play Store submission.
- **Display name:** `Kârly` (with circumflex) on the Play Store listing and
  the home screen. `android:label` accepts Unicode.
- **Languages at launch:** English (default fallback) + Turkish.
- **Privacy / Terms / Support URLs:** all served from `nexutility.com/*`.

## Open questions

- App icon: keep the NexUtility "K" mark in lime, or design a Kârly-specific
  icon? Decide before 1.0 store submission.
- Currency conversion source: ECB free feed vs paid (e.g. exchangerate-host).
  Decide when (and if) v0.4 lands.
- Should the daily free cap also throttle Save attempts, or is "Save is
  Pro-only" enough friction on the upgrade path? Currently the latter.

## Dev-only affordances

- Long-press the version label in Settings (debug builds only) to toggle
  `SubscriptionTier.free` ↔ `proAnnual`. Useful for previewing the Pro UX
  before billing is wired.
