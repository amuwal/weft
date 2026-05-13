# Open questions

Things to resolve before kicking off v1 development.

## Strategic

1. **Solo build vs. small team?** This spec assumes solo. If we bring in a designer it could ship faster but at the cost of vision purity.
2. **Marketing plan?** Build-in-public on X is the obvious path for indie iOS apps in 2026. Need a posting cadence and a few hero shots ready by week 3.
3. **TestFlight invite list.** Who are our 50 closest beta testers? Should be people who would actually use Linger, not just devs.
4. **Founder identity.** Do we publish the dev's name publicly (build trust) or stay behind a brand? Recommend named — trust matters in privacy-positioned apps.

## Product

1. **Birthday handling — opt-in pull from Contacts, or manual entry only?** Pull is convenient but feels invasive to the privacy positioning. Lean: manual entry in v1, optional pull as a setting in v1.1.
2. **What happens to a person when you delete them?** Hard delete or archive? Lean: 30-day soft delete with undo. Lets users course-correct.
3. **How does iCloud sync handle conflicts?** Multi-device editing of the same note — last-write-wins or merge? Lean: last-write-wins for v1, add merge in v1.2.
4. **Lock screen widget tap → which screen?** Today, or the surfaced person's detail? Lean: surfaced person's detail.
5. **Export format details.** PDF and Markdown both? Per-person or whole-archive? Lean: both, both granularities.

## Design

1. **Final app icon.** The "low arc connecting dots" direction needs an illustrator. Or hand-draw it. Brief is in `design-language.md`.
2. **Dark mode accent color.** Sage tone works in light mode; in dark mode it needs lifting. Spec says `#7FA48A` — needs eyeballing on real devices.
3. **Empty state copy.** "Who matters to you?" is in spec; might be too direct. Consider softer alternatives: "Start with one name" / "Begin small".

## Technical

1. **SwiftData maturity.** As of iOS 26 SwiftData is reliable but has known edge cases. If we hit walls, fall back to Core Data with NSPersistentCloudKitContainer.
2. **StoreKit 2 vs. RevenueCat.** Native StoreKit 2 is fine for iOS-only. RevenueCat costs money and adds a dependency. Lean: native.
3. **Analytics.** Privacy-positioned app — no Firebase, no Mixpanel. Use Apple's privacy-friendly App Store analytics + TelemetryDeck (privacy-respecting, paid) for product insight.
4. **Crash reporting.** Apple's built-in crash reporting + Bugsnag's free tier. No Sentry (heavyweight).

## Open until validated with real users

1. **Is the rhythm-based "Today" surfacing the right primary screen?** Maybe a "recent notes" view would feel more honest. Test with beta users.
2. **Do users actually want Threads as a separate tab, or do they just want notes with dates?** Could collapse Notes + Threads into one stream.
3. **Will the 7-person free tier feel restrictive enough to convert, or punitive?** Could try 5 or 10 in A/B if we get to that scale.
