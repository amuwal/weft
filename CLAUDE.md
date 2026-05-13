# CLAUDE.md — agent rules for Linger

> Read this before editing any Swift file. These rules exist because Linger's brand promise depends on a level of restraint that AI-generated code violates by default.

## What Linger is

A calm, on-device, journal-like memory tool for 5–25 close people. iOS-only, iOS 26 native. Single-developer codebase.

Full positioning: `README.md`. Hard constraints: `HANDOFF.md`. **What not to build:** `spec/non-goals.md` — read before adding any new feature.

## Project layout

```
Linger/                source code (App, Model, Features, Components, Design, Services)
LingerWidget/          WidgetKit extension
LingerWatch/           Watch app + companion
LingerTests/           Swift Testing — `#expect`, not XCTest
LingerUITests/         XCUITest happy paths
web/                   HTML/CSS/JSX mockup framework — design reference only, not shipped
design/                design language docs
spec/                  features, monetization, stack, non-goals
research/              competitor + UI inspiration notes
memory/                session decisions log
```

When you change a behavior, update the matching `spec/` or `design/` file in the same commit. The docs are the contract, not an afterthought.

## Stack

SwiftUI · SwiftData · CloudKit private DB · StoreKit 2 · WidgetKit · App Intents · iOS 26 SDK · Swift 6 strict concurrency.

Full reasoning in `spec/stack.md`. Do not add a cross-platform shell, Firebase/Supabase SDK, or RevenueCat without re-reading that file.

## Comment style — non-negotiable

**Default: write no comment.** Then ask "would a smart engineer reading this in six months be confused without it?" If yes, write one. Otherwise delete.

**Allowed:**
- A comment that explains *why* a choice was made when the reason is not visible in the code (a workaround for a known iOS bug, a constraint from `non-goals.md`, a deliberate deviation from a documented spec).
- A doc comment on a public API that explains the contract — parameters, edge cases, error conditions. Skip the obvious; document only what callers would otherwise have to guess.
- A `TODO(#nnn):` referencing an open GitHub issue, with one sentence of context.

**Banned:**
- "What" comments. `// Save the note` above `try context.save()` is noise. SwiftLint will reject this.
- Decorative dividers (`// ─────`, `// ===== Models =====`). Group with extensions or files.
- Emoji-decorated headers (`// ✨ Pretty function`). SwiftLint will reject this.
- `/// Initializes a new instance` doc comments. The compiler already says so.
- "Section" comments that just restate the type name (`// MARK: - PersonCard`). Use `// MARK:` only for non-obvious grouping inside a long file.
- TODOs without an issue link. If it isn't worth filing, it isn't worth writing.

SwiftLint's `custom_rules` block enforces most of these as errors. Don't disable a rule line-by-line to avoid fixing the real problem — fix the problem.

## Banned vocabulary in user-facing strings

Never use these words in any string the user can see (UI label, App Store description, accessibility label, error message):

> *track · manage · ping · engagement · streak · level up · optimize · nudge (as a verb)*

Reason in `design/design-language.md`. SwiftLint will warn on these in `.swift` and `.xcstrings`.

## Design language — the load-bearing rules

These are the *small set* of rules that make Linger feel like Linger. Violating them is worse than missing a feature.

1. **System controls only.** No custom buttons that re-implement system buttons. iOS 26 Liquid Glass is the default — `Button`, `TabView`, `NavigationStack`, `.sheet`, `Toggle` already render it. If you find yourself reaching for a custom UI library, stop.
2. **Spring physics, never linear.** Use the named springs in `Design/Animation+Linger.swift`:
   - `.lingerSpring` — default transitions and opens.
   - `.lingerPress` — tap/press feedback (scale 0.97).
   - `.lingerCalm` — sheet dismiss and "today's calm empty state."
3. **Typography hierarchy:** New York serif (`Font.system(.title, design: .serif)`) for hero / person names. SF Pro for body. SF Pro Rounded for timestamps and pill metadata.
4. **Color is sage on cream.** Background `Color("bg")` (#F8F5EF light, #161410 dark). Accent `Color("sage")` (#5C7A66). Warm `Color("warm")` (#C68A3A) is used **only** to mark "today" items — nowhere else.
5. **No illustrations on empty states.** A line of serif copy + a single subtle button. No mascots, no icons that drift toward "fun."
6. **Haptics are intentional.** Read `design/motion-and-haptics.md` — every haptic maps to a specific event class. No haptic on scroll, ever.

## Code style — Swift specifics

- **Swift 6 strict concurrency on.** Mark UI types `@MainActor`. Mark observable state `@Observable`. Use `@Sendable` closures across actor hops.
- **Prefer `let`** until you provably need mutation.
- **Avoid singletons** that aren't system-wired (`UIApplication.shared` is fine; an `AppManager.shared` is a code smell).
- **One type per file** for primary public types. Small private helpers can share the file.
- **No force-unwraps** outside test fixtures. SwiftLint errors on `!`.
- **No `fatalError` without a message** explaining the invariant.
- **Use `Logger`** (`os.Logger`), not `print`. `print` is allowed in `LingerTests` only.
- **SwiftData models** live in `Model/`. Migrations go in `Model/Migrations/`. Update `spec/features-v1.md`'s data model section in the same commit.

## Folder rules

- `Features/<FeatureName>/` — one folder per feature; views and feature-local types stay together.
- `Components/` — shared, reusable views (PersonCard, DotIndicator, SegmentedControl). Must have a SwiftUI preview.
- `Design/` — tokens, animations, haptics. No view code.
- `Services/` — domain logic. No view code, no SwiftUI imports.
- `Resources/` — assets and `Localizable.xcstrings`. Strings file is the source of truth; never hard-code a user-facing string in Swift.

## Tests

- **Swift Testing** (`import Testing`, `#expect(...)`) by default.
- One test file per source file: `Model/Person.swift` → `LingerTests/Model/PersonTests.swift`.
- **Use a real SwiftData container** in tests (`ModelConfiguration(isStoredInMemoryOnly: true)`), not a mock. The data layer is too thin to mock usefully.
- **UI tests** stay in `LingerUITests/` and cover only the golden paths: onboard → add person → log note → see card → mark caught up.

## Process

- **One concept per commit.** Refactors don't ride along with features.
- **Don't update the spec silently.** If you contradict `spec/` or `design/`, update the doc in the *same* commit and explain why in `memory/decisions.md`.
- **`web/` is design reference**, not generated. Don't try to "sync" the SwiftUI with the HTML — implement what `design/screens.md` says.
- **Run `swiftlint && swiftformat --lint .` before every commit.** Both must exit 0.

## When in doubt

1. Re-read `spec/non-goals.md`.
2. Look at the named reference apps (Day One, Things 3, Bear, Linear, Tiimo).
3. Ask: "does this make Linger calmer or busier?" Pick calmer.
