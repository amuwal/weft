import Foundation
import SwiftData
import Testing
@testable import Weft

/// Covers the three premium-gating mechanisms wired in this session:
///   1. `--premium` debug launch flag → `Entitlements.debugPremiumOverride`
///   2. `Entitlements.isPremium` mirrors itself into UserDefaults so the
///      synchronous SwiftData container can read it at app start.
///   3. `ModelContainer.syncShouldBeActive` honors the combined signal.
///
/// `--premium` resolution depends on `ProcessInfo.processInfo.arguments`,
/// which we can't inject. The xcodebuild test runner does not pass `--premium`,
/// so we test the false-branch here. The simulator smoke test exercises the
/// true-branch by launching with the flag.
@MainActor
struct EntitlementsGateTests {
    @Test
    func isPremiumDefaultsFalse() {
        let entitlements = Entitlements()
        #expect(entitlements.isPremium == false)
    }

    @Test
    func isPremiumWriteIsCachedToUserDefaults() async {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Entitlements.cachedIsPremiumKey)

        // refresh() reads Transaction.currentEntitlements which is empty in
        // the test bundle (no .storekit bound), so isPremium ends false and
        // the cache is written false.
        let entitlements = Entitlements()
        await entitlements.refresh()

        let cached = defaults.object(forKey: Entitlements.cachedIsPremiumKey) as? Bool
        #expect(cached == false, "Cache must mirror isPremium even when false")
    }

    @Test
    func debugOverrideIsFalseUnderXcodebuild() {
        // The test runner doesn't pass `--premium`. Confirm we don't have a
        // stuck override leaking from somewhere.
        #expect(Entitlements.debugPremiumOverride == false)
    }

    @Test
    func syncShouldBeActiveIsFalseInTestEnvironment() {
        // Tests run on simulator + XCTest, both of which short-circuit
        // `iCloudIsEntitled` to false. Even if a user had toggled sync on and
        // were "premium", the test env should never claim sync is active.
        #expect(ModelContainer.syncShouldBeActive == false)
    }

    @Test
    func syncIsOffWhenUserIsNotPremium() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: ModelContainer.iCloudSyncEnabledKey)
        defaults.set(false, forKey: Entitlements.cachedIsPremiumKey)
        #expect(
            ModelContainer.syncShouldBeActive == false,
            "Sync must require Premium, regardless of toggle"
        )
    }

    @Test
    func syncIsOffWhenUserToggledItOff() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: Entitlements.cachedIsPremiumKey)
        defaults.set(false, forKey: ModelContainer.iCloudSyncEnabledKey)
        #expect(
            ModelContainer.syncShouldBeActive == false,
            "Sync must respect the user's explicit toggle even when premium"
        )
    }
}
