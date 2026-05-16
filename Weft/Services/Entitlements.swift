import Foundation
import OSLog
import StoreKit
import UIKit

@MainActor
@Observable
final class Entitlements {
    enum ProductID: String, CaseIterable {
        case monthly = "weft_premium_monthly"
        case yearly = "weft_premium_yearly"
        case lifetime = "weft_premium_lifetime"

        var isSubscription: Bool {
            self != .lifetime
        }
    }

    static let subscriptionGroup = "weft_premium"
    static let freePeopleLimit = 7
    /// Mirrors `isPremium` into UserDefaults so non-Observable code (notably
    /// `ModelContainer.weft()`, which runs synchronously at app launch before
    /// SwiftUI environment objects exist) can consult entitlement state.
    /// `nonisolated` so the model container — running outside the main actor
    /// at boot — can read it without an actor hop.
    nonisolated static let cachedIsPremiumKey = "weft.cachedIsPremium"

    private(set) var isPremium = false {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: Self.cachedIsPremiumKey)
        }
    }

    private(set) var renewalDate: Date?
    private(set) var products: [Product] = []
    private(set) var productsLoaded = false
    private(set) var purchasingProductID: String?

    private let logger = Logger(subsystem: "com.amuwal.weft", category: "Entitlements")
    private var transactionListener: Task<Void, Never>?

    /// DEBUG-only override: `--premium` at launch flips entitlement on without
    /// going through StoreKit. Lets us iterate on Premium-gated UI in seconds.
    /// Never shipped to App Store — guarded by `#if DEBUG`.
    /// `nonisolated` so `ModelContainer.weft()` (called from `WeftApp.init`
    /// before any actor exists) can read it.
    nonisolated static var debugPremiumOverride: Bool {
        #if DEBUG
            return ProcessInfo.processInfo.arguments.contains("--premium")
        #else
            return false
        #endif
    }

    /// Call once at app launch. Loads products from StoreKit (which the
    /// scheme's local .storekit file backs in development), then starts
    /// listening for transaction updates and refreshes entitlements.
    func bootstrap() async {
        await loadProducts()
        await refresh()
        transactionListener = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified = update {
                    await self?.refresh()
                }
            }
        }
    }

    func loadProducts() async {
        do {
            let ids = ProductID.allCases.map(\.rawValue)
            let fetched = try await Product.products(for: ids)
            // Sort: lifetime first (top of paywall), then yearly, then monthly.
            products = fetched.sorted { lhs, rhs in
                sortRank(lhs.id) < sortRank(rhs.id)
            }
            productsLoaded = !products.isEmpty
            let loadedCount = products.count
            logger.info("Loaded \(loadedCount) products")
        } catch {
            productsLoaded = false
            logger.error("Product load failed: \(error.localizedDescription)")
        }
    }

    /// Re-derive `isPremium` from local Transaction history. A user is Premium
    /// if either (a) they own the non-consumable lifetime product, or
    /// (b) they have an unexpired auto-renewing subscription in the group.
    func refresh() async {
        if Self.debugPremiumOverride {
            isPremium = true
            renewalDate = nil
            return
        }
        var premium = false
        var renewal: Date?
        for await result in Transaction.currentEntitlements {
            guard case .verified(let txn) = result else { continue }
            guard txn.revocationDate == nil else { continue }
            if txn.productID == ProductID.lifetime.rawValue {
                premium = true
                // Lifetime has no renewal date.
                renewal = nil
                continue
            }
            if txn.subscriptionGroupID == Self.subscriptionGroup {
                premium = true
                renewal = txn.expirationDate
            }
        }
        isPremium = premium
        renewalDate = renewal
    }

    /// Returns true if the purchase resulted in entitlement.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        purchasingProductID = product.id
        defer { purchasingProductID = nil }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let txn) = verification {
                    await txn.finish()
                    await refresh()
                    return isPremium
                }
                return false
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            logger.error("Purchase failed: \(error.localizedDescription)")
            return false
        }
    }

    /// Forces App Store to re-sync transactions, then refreshes.
    func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            logger.error("Restore sync failed: \(error.localizedDescription)")
        }
        await refresh()
    }

    func product(for id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }

    #if !WIDGET_EXTENSION
        /// Presents Apple's native code-redemption sheet. Used for gift codes generated
        /// in App Store Connect (e.g. influencer/friend Lifetime gifts). Apple owns the
        /// input + validation; we just present the sheet. Successful redemptions arrive
        /// through `Transaction.updates`, which `bootstrap()` is already listening to.
        ///
        /// Compiled out of the widget extension target — `UIApplication.shared` is
        /// unavailable there. Entitlements is otherwise shared between targets so the
        /// widget can read `cachedIsPremiumKey` and `debugPremiumOverride`.
        func presentRedeemSheet() async {
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })
                ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
            else {
                logger.error("Redeem sheet: no active window scene")
                return
            }
            do {
                try await AppStore.presentOfferCodeRedeemSheet(in: scene)
            } catch {
                logger.error("Redeem sheet failed: \(error.localizedDescription)")
            }
        }
    #endif

    private func sortRank(_ id: String) -> Int {
        switch id {
        case ProductID.lifetime.rawValue: 0
        case ProductID.yearly.rawValue: 1
        case ProductID.monthly.rawValue: 2
        default: 3
        }
    }
}
