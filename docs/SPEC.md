# Kârly — Product Spec

> **Status:** v0.1 / MVP scaffold landed
> **Last updated:** 2026-05-08
> **Owner:** NexUtility studio

## Premise

Kârly is a cross-border marketplace seller profit calculator. A small seller
who lists on **Trendyol** can also list on **Etsy** or **Amazon**, and they
need one mobile app that computes net profit consistently across all of those
marketplaces. No competitor on the App Store today serves the
"TR pazaryeri × iOS × modern UI" intersection — that is our wedge.

## Target user

- **Primary:** Turkish small sellers expanding from Trendyol / Hepsiburada /
  N11 to Etsy / Amazon / eBay. Bilingual (TR + EN), price-sensitive, mobile-first.
- **Secondary:** Global sellers (Etsy / eBay / Shopify) who want a simple,
  ad-free, modern alternative to spreadsheet calculators.
- **Out of scope (for MVP):** Amazon FBA pros (already served by tool4seller,
  sellerboard, Helium 10), enterprise multi-seat teams.

## What this app is _not_

- Not an accounting tool.
- Not a bookkeeping ledger.
- Not a marketplace API integration (no live listing sync — manual input only).
- Not a tax filing tool.
- Not yet a tracker — MVP is calculator-only; tracking arrives in v0.3.

## Core flow (MVP)

1. User opens the app → lands on Calculator screen.
2. Picks a marketplace from the bottom-sheet picker (TR section + Global section).
3. Enters `item cost`, `sell price`, optional `shipping`, `ad spend`,
   `commission %` (pre-filled from preset, editable), `VAT/KDV %`.
4. Taps **Calculate** → sees a result card with:
   - Big headline: **Net profit** (red if loss, brand accent if profit)
   - Pills: margin %, ROI %
   - Breakdown: commission amount, VAT amount, breakeven price
5. Optionally taps **Reset** to clear and start over.
6. (v0.2) **Save** → entry appears on History tab.

## Marketplaces shipped in v0.1

| Region   | Marketplace        | Default commission | Notes                                     |
| -------- | ------------------ | ------------------ | ----------------------------------------- |
| Türkiye  | Trendyol           | 18 %               | Category-specific rates                   |
| Türkiye  | Hepsiburada        | 15.5 %             | Category-specific rates                   |
| Türkiye  | n11                | 13 %               |                                           |
| Türkiye  | Çiçek Sepeti       | 18 %               |                                           |
| Türkiye  | Pazarama           | 12 %               |                                           |
| Global   | Amazon US          | 15 %               | Referral fee — FBA fees not included      |
| Global   | Etsy               | 6.5 % + $0.20      | Plus payment processing                   |
| Global   | eBay               | 13.5 %             | Final value fee — varies by category      |
| Global   | Shopify (own store)| 2.9 % + $0.30      | Shopify Payments rate                     |
| Global   | Custom             | 0 %                | User sets all values manually             |

All rates are **defaults** that the user can override on the calculator
screen. Per-category rate tables are out of scope for MVP and arrive in v0.4.

## Calculation model

Pure function `calculateProfit(CalcInputs) → CalcResult` — see
[`lib/features/calculator/domain/calculate.dart`](../lib/features/calculator/domain/calculate.dart).

```
commission   = sellPrice × commissionRate + fixedListingFee
vat          = sellPrice × vatRate
totalCosts   = itemCost + shippingCost + adSpend + commission + vat
netProfit    = sellPrice − totalCosts
margin %     = netProfit ÷ sellPrice × 100
ROI %        = netProfit ÷ itemCost × 100
breakeven    = (itemCost + shippingCost + adSpend + fixedListingFee)
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

## Information architecture

```
Bottom nav (3 tabs):
├── /         Calculator        (MVP, complete)
├── /history  History           (v0.2 — empty state shipped in v0.1)
└── /settings Settings          (Privacy, Terms, Support links + version)
```

## Monetization (planned for v0.2+)

| Tier                 | Pricing                | What you get                                                                                          |
| -------------------- | ---------------------- | ----------------------------------------------------------------------------------------------------- |
| **Free**             | $0 + AdMob banner / capped interstitial | Calculator with all 10 marketplaces, no save, no history, no export                       |
| **Pro Monthly**      | ₺79 / $2.99 per month  | Unlimited saved calculations, 12-month history, no ads, multi-product compare, CSV export             |
| **Pro Annual** ⭐    | ₺599 / $19.99 per year | Everything in Monthly + cross-marketplace SKU comparison, KDV reports, multi-currency w/ live FX     |

No lifetime tier — annual + monthly converts better and keeps incentives aligned with maintenance.
RevenueCat will manage entitlements and store-side billing.

### Defensible feature gates

Features that no current competitor exposes — these sit behind the Pro paywall
because they are the primary acquisition driver from research:

1. **Cross-marketplace SKU comparison** — same item, side-by-side margin on
   Trendyol vs Etsy vs Amazon vs eBay
2. **KDV-correct mode** — accurate Trendyol "Platform Hizmet Bedeli" handling and
   per-category Turkish VAT rules
3. **Multi-currency with live FX** — the Turkish seller running Etsy in USD
4. **CSV / PDF export** — to forward to muhasebeci (accountant). PDF share
   currently ships unrestricted in v0.1 to maximise word-of-mouth (each
   shared report is a brand impression on WhatsApp / email); the gate
   activates when the paywall lands in v0.2.

## Roadmap

| Version | Scope                                                                                                                               | Target            |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| 0.1     | Calculator MVP, marketplaces preset list, Material 3 dark theme, EN + TR i18n with **in-app language switcher** (locale-aware marketplace order + Trendyol-vs-Amazon defaults + auto KDV/VAT prefill), **brand AppBar**, **item name input**, **PDF report + system share** (free; will be gated to Pro when paywall lands), **History gated behind Kârly Pro paywall** (RevenueCat stub — UI complete, billing wires up in v0.2) | ✅ this commit    |
| 0.2     | Save calculations to local storage (SharedPreferences → drift if growth), History list, RevenueCat paywall, AdMob banner on free    | next 2 weeks      |
| 0.3     | Cross-marketplace SKU compare screen, multi-currency w/ FX rates, CSV export                                                        | +2 weeks          |
| 0.4     | Per-category commission tables for TR marketplaces, KDV mode, PDF export                                                            | +3 weeks          |
| 1.0     | **Play Store** submission with full localized listings (EN + TR + DE + ES at minimum), screenshots, marketing site presence. App Store deferred. | +5 weeks from 0.1 |

## Constraints

- **Launch platform: Android only.** iOS is deferred until Android revenue
  covers the Apple Developer Program fee ($99/yr) and a Mac for the build
  toolchain. The `ios/` folder stays in the repo so we can ship to the App
  Store later without rescaffolding — but every roadmap milestone below is
  scoped to Android until further notice.
- **Bundle ID / Application ID is permanent:** `com.nexutility.karly`. Never
  changes after first Play Store submission.
- **Display name:** `Kârly` (with circumflex) on the Play Store listing and
  the home screen. `android:label` accepts Unicode.
- **Languages at launch:** English (default fallback) + Turkish.
  Add German and Spanish before 1.0 to match the EU expansion path of TR sellers.
- **Privacy / Terms / Support URLs:** all served from `nexutility.com/*`.
  No per-app domain.

## Open questions

- App icon: keep the NexUtility "N" mark in lime, or design a Kârly-specific
  icon? Decide before 1.0 store submission.
- Currency conversion source: ECB free feed vs paid (e.g. exchangerate-host).
  Decide in 0.3.
- AdMob ad unit IDs: provisioned per-app under the NexUtility AdMob account.
  Ship test IDs for development; swap to production IDs in the 1.0 build.
