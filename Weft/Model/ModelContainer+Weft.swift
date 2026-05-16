import Foundation
import SwiftData

extension ModelContainer {
    static let weftSchema = Schema([
        Person.self,
        Note.self,
        Thread.self,
        Touchpoint.self
    ])

    /// UserDefaults key for the user's sync-toggle preference. Read here at
    /// launch and from `SettingsView` for the live toggle.
    static let iCloudSyncEnabledKey = "iCloudSyncEnabled"

    /// Production container — backed by the user's private CloudKit DB when
    /// **all three** signals agree:
    ///   • Premium entitled (cached in UserDefaults from `Entitlements`)
    ///   • User has the sync toggle on in Settings
    ///   • Device has an iCloud account signed in (real device, not simulator)
    /// Otherwise we open a local-only store. Toggling Premium or the switch
    /// requires an app relaunch to take effect — Settings surfaces this hint.
    static func weft() throws -> ModelContainer {
        let config = if syncShouldBeActive {
            ModelConfiguration(
                "Weft",
                schema: weftSchema,
                cloudKitDatabase: .private("iCloud.com.amuwal.weft")
            )
        } else {
            ModelConfiguration("Weft", schema: weftSchema, cloudKitDatabase: .none)
        }
        return try ModelContainer(for: weftSchema, configurations: [config])
    }

    /// All three gates combined.
    static var syncShouldBeActive: Bool {
        guard userToggledSyncOn else { return false }
        guard userIsPremium else { return false }
        return iCloudIsEntitled
    }

    /// Defaults to `true` so existing Premium users get the historic behavior
    /// the first time the toggle is read. The Settings UI writes through this
    /// same key.
    private static var userToggledSyncOn: Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: iCloudSyncEnabledKey) == nil { return true }
        return defaults.bool(forKey: iCloudSyncEnabledKey)
    }

    private static var userIsPremium: Bool {
        UserDefaults.standard.bool(forKey: Entitlements.cachedIsPremiumKey)
            || Entitlements.debugPremiumOverride
    }

    /// Heuristic: only opt into CloudKit on a real device with an iCloud
    /// token. The simulator falls back to a local store — CloudKit there
    /// demands every attribute be optional, which clashes with the models
    /// we ship. Real-device sync is the developer's responsibility to wire.
    private static var iCloudIsEntitled: Bool {
        let isTesting = NSClassFromString("XCTest") != nil
        guard !isTesting else { return false }
        #if targetEnvironment(simulator)
            return false
        #else
            return FileManager.default.ubiquityIdentityToken != nil
        #endif
    }

    /// Used by SwiftUI previews and tests. In-memory, no CloudKit.
    @MainActor
    static var preview: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: weftSchema, configurations: [config])
        SampleData.populate(container.mainContext)
        return container
    }()
}
