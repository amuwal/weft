# Monetization

## Model

Freemium with subscription. No ads. No lifetime deal in v1.

## Pricing

| Plan | Price | Notes |
|---|---|---|
| Free | $0 | Up to 7 people · no iCloud sync · no Watch · no export · no photos |
| Monthly | $3.99 | Standard friction price for premium utility |
| Yearly | $24.99 | $2.08/mo equivalent · 7-day free trial |

Reasoning:
- Below Dex ($10/mo) — we're a calmer, smaller-tier product.
- Above the $1.99 floor — that price band signals "cheap utility," not premium.
- $24.99/yr is the proven sweet spot for personal subscription apps that customers will stick on.

## Free tier rationale

7 people is intentionally generous. Most users will trigger the paywall organically when they hit their 8th person — which happens when they start trusting the app. That's the right moment to convert.

Free tier still gets:
- Full notes/threads/log
- Daily Today screen
- Home widget
- Local-only data

This is enough to be useful and not crippled, but not enough for the "everyone I care about" use case.

## Revenue model implementation

- Use **StoreKit 2** native. RevenueCat optional if multi-platform later.
- Two products in App Store Connect: `linger_premium_monthly`, `linger_premium_yearly`.
- 7-day free trial only on yearly. Monthly is no-trial (reduces churn-from-trial-abuse).
- Family Sharing enabled.

## Year-1 revenue plan (realistic)

Assuming Tier-3 indie outcome (achievable for solo dev with good launch and steady marketing):

- 50K total free downloads in year 1
- 3% conversion to paid → 1,500 paying users
- Mix 70% yearly / 30% monthly → blended ~$22/yr/user
- ARR ~$33K
- Apple takes 15% (small biz program) → ~$28K net

This isn't quit-your-job money. It's "second salary" territory. Standard for category.

Upside path to $100K+ ARR: featured by Apple, viral X moment, PR in a major publication. None guaranteed.

## What NOT to monetize

- No ads ever
- No data sales ever
- No "AI prompts" as a $5/mo add-on (cheap)
- No charging for export (export is dignity, not premium)
- No charging extra for dark mode or themes (basic decency)

## Lifetime / one-time alternative

Some users explicitly distrust subscriptions. Consider adding a $79.99 lifetime tier after 12 months if subscription-only is losing convertible users. Don't ship at launch.
