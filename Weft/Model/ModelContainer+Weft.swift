import CloudKit
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

    /// App Group identifier shared between the main app and `WeftWidget`. The
    /// SwiftData store path lives inside this group so the widget extension
    /// reads the same data the app writes.
    static let appGroupID = "group.com.amuwal.weft"

    /// The app's private CloudKit container identifier. Used both to attach the
    /// store to CloudKit and to query account availability for the Settings UI.
    static let cloudKitContainerID = "iCloud.com.amuwal.weft"

    /// Production container — backed by the user's private CloudKit DB when
    /// **both** signals agree:
    ///   • Premium entitled (cached in UserDefaults from `Entitlements`)
    ///   • User has the sync toggle on in Settings
    /// Otherwise we open a local-only store. We do *not* gate on iCloud account
    /// availability here: CloudKit operates locally when signed out and starts
    /// syncing once an account appears, so a missing account is a UI concern
    /// (see `refreshICloudAccountStatus`), not a reason to drop CloudKit.
    /// Toggling Premium or the switch requires an app relaunch to take effect —
    /// Settings surfaces this hint.
    ///
    /// The store URL is forced into the App Group container so `WeftWidget`
    /// can open the same `default.store` file.
    static func weft() throws -> ModelContainer {
        let url = sharedStoreURL()
        var active = syncShouldBeActive
        #if DEBUG
            // Force the local-only path even while Premium, to exercise the
            // "Relaunch to sync your data" hint without a fresh install.
            if ProcessInfo.processInfo.arguments.contains("--sync-stale") { active = false }
        #endif
        cloudKitAttachedAtLaunch = active
        let config = if active {
            ModelConfiguration(
                "Weft",
                schema: weftSchema,
                url: url,
                cloudKitDatabase: .private(cloudKitContainerID)
            )
        } else {
            ModelConfiguration(
                "Weft",
                schema: weftSchema,
                url: url,
                cloudKitDatabase: .none
            )
        }
        return try ModelContainer(for: weftSchema, configurations: [config])
    }

    /// Whether the launch-time container attached CloudKit. Compared against the
    /// live "sync should be active" signal so Settings can prompt a relaunch when
    /// Premium was detected *after* launch — e.g. a fresh install that StoreKit
    /// auto-restored, where the store opened local-only because the cached
    /// Premium flag hadn't been written yet.
    /// Written exactly once during synchronous launch (`weft()`), read on the
    /// main actor thereafter — so `nonisolated(unsafe)` is sound here.
    nonisolated(unsafe) static var cloudKitAttachedAtLaunch = false

    /// Path inside the App Group's shared container that both the app and
    /// the widget extension can reach. Falls back to a per-process URL when
    /// the group container isn't available (tests, previews) so the call
    /// never throws.
    private static func sharedStoreURL() -> URL {
        if let group = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            return group.appending(path: "Weft.store")
        }
        return URL.applicationSupportDirectory.appending(path: "Weft.store")
    }

    /// Whether the store should attach CloudKit. Two gates, both read at launch.
    /// Tests always stay local — CloudKit can't init without an account or
    /// entitlement in CI.
    static var syncShouldBeActive: Bool {
        let isTesting = NSClassFromString("XCTest") != nil
        guard !isTesting else { return false }
        guard userToggledSyncOn else { return false }
        return userIsPremium
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

    /// UserDefaults cache of the last-known CloudKit account availability, so
    /// the Settings status row has something to show before the async check
    /// returns.
    static let cloudKitAccountAvailableKey = "cloudKitAccountAvailable"

    /// Last-known CloudKit account availability. A synchronous seed for the
    /// Settings UI; `refreshICloudAccountStatus()` keeps it current.
    static var hasICloudAccount: Bool {
        UserDefaults.standard.bool(forKey: cloudKitAccountAvailableKey)
    }

    /// Asks CloudKit whether the private database is usable, caches the answer,
    /// and returns it. This is the correct signal for sync availability:
    /// `CKContainer.accountStatus()` reports `.available` whenever the user is
    /// signed into iCloud, independent of the iCloud *Drive* toggle. (We used
    /// to read `FileManager.ubiquityIdentityToken`, which only reflects iCloud
    /// Documents/Drive and is `nil` when Drive is off even though CloudKit
    /// works fine — that produced a false "needs sign-in" status.)
    @discardableResult
    static func refreshICloudAccountStatus() async -> Bool {
        let available: Bool
        do {
            let status = try await CKContainer(identifier: cloudKitContainerID).accountStatus()
            available = status == .available
        } catch {
            available = false
        }
        UserDefaults.standard.set(available, forKey: cloudKitAccountAvailableKey)
        return available
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
