import Foundation
import SwiftUI

/// Supported in-app languages. `system` defers to the user's iOS language preference.
/// Add a new language: add a case here + a translation column in `Localizable.xcstrings`
/// + an entry in `project.yml > knownRegions` / `CFBundleLocalizations`.
enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case en
    case ja

    var id: String {
        rawValue
    }

    /// Label shown in the Settings picker (always in the user's current UI language).
    var displayName: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .en: "English"
        case .ja: "日本語"
        }
    }

    /// The `.lproj` folder name to look up at runtime. `nil` means "let the OS decide".
    var bundleCode: String? {
        switch self {
        case .system: nil
        case .en: "en"
        case .ja: "ja"
        }
    }

    /// Locale to expose via `\.locale` so date/number formatting matches the chosen language.
    var locale: Locale {
        switch self {
        case .system: .current
        case .en: Locale(identifier: "en")
        case .ja: Locale(identifier: "ja")
        }
    }
}

/// Custom `Bundle` subclass that hijacks `localizedString(forKey:value:table:)` to route
/// every `Text("…")` / `String(localized: "…")` lookup through the user-selected language's
/// `.lproj` instead of the default (system) one.
///
/// Wired up in `WeftApp.init()` via `object_setClass(Bundle.main, LocalizedBundle.self)`.
/// SwiftUI is forced to re-evaluate all Text by adding `.id(preferredLanguage)` on the root view.
final class LocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let pref = UserDefaults.standard.string(forKey: AppLanguageStorage.key) ?? AppLanguage.system.rawValue
        guard pref != AppLanguage.system.rawValue,
              let path = Bundle.main.path(forResource: pref, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

/// Localized string lookup that respects the user's mid-session language
/// choice. Prefer this over `String(localized:)` for any string evaluated
/// outside a SwiftUI view's body — helper functions, computed properties
/// that feed into UI, UIKit representables (`UIViewRepresentable.makeUIView`).
///
/// Why this exists: `String(localized:)` and `LocalizedStringResource`
/// resolve through Foundation's internal bundle cache, which is seeded with
/// the language active at process start (via `AppleLanguages`). Updating
/// `AppleLanguages` mid-run does *not* invalidate that cache, so strings
/// returned from `String(localized:)` stay frozen at the launch-time
/// language until the user kills + reopens the app.
///
/// `loc(_)` goes through `Bundle.main.localizedString(forKey:)` which our
/// `LocalizedBundle` subclass overrides — and that override reads the
/// user's preference from UserDefaults on every call, so the language
/// switch is reflected immediately.
///
/// For interpolated strings, use `loc(_:_:)`: the key is the `%lld`/`%@`
/// format pattern in `Localizable.xcstrings`, the args are substituted
/// after the localized lookup.
@inline(__always)
func loc(_ key: String) -> String {
    Bundle.main.localizedString(forKey: key, value: nil, table: nil)
}

@inline(__always)
func loc(_ key: String, _ args: CVarArg...) -> String {
    let template = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    return String(format: template, locale: Locale.current, arguments: args)
}

/// Single place that knows the UserDefaults keys for the preferred language.
/// `SettingsView` reads/writes the user's choice via `@AppStorage(AppLanguageStorage.key)`.
/// `WeftApp.init` and `SettingsView.onChange` call `apply(_:)` to push the choice into
/// `AppleLanguages` — which is what `String(localized:)` and most Foundation resource
/// lookups consult (not Bundle.main.localizedString, which our LocalizedBundle overrides).
enum AppLanguageStorage {
    static let key = "preferredLanguage"
    static let appleLanguagesKey = "AppleLanguages"

    /// Sync `AppleLanguages` so Foundation-level localization (String(localized:),
    /// LocalizedStringResource, etc.) picks up the user's choice. For `.system`, we
    /// clear the override so iOS falls back to the device language list.
    static func apply(_ language: AppLanguage) {
        if let code = language.bundleCode {
            UserDefaults.standard.set([code], forKey: appleLanguagesKey)
        } else {
            UserDefaults.standard.removeObject(forKey: appleLanguagesKey)
        }
    }

    /// Read the persisted preference at app boot.
    static func current() -> AppLanguage {
        guard let raw = UserDefaults.standard.string(forKey: key),
              let lang = AppLanguage(rawValue: raw)
        else { return .system }
        return lang
    }
}
