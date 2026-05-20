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
    /// The product the user is currently entitled to, if any. Lifetime wins if
    /// they somehow hold both. Drives the member status screen's plan label.
    private(set) var activeProductID: ProductID?
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
            let args = ProcessInfo.processInfo.arguments
            return args.contains("--premium")
                || args.contains("--premium-monthly")
                || args.contains("--premium-yearly")
        #else
            return false
        #endif
    }

    #if DEBUG
        /// The plan the debug override should pretend the user holds, so both
        /// member-status variants can be exercised in the simulator:
        /// `--premium` / `--premium-monthly` / `--premium-yearly`.
        nonisolated static var debugSimulatedPlan: (id: ProductID, renewal: Date?) {
            let args = ProcessInfo.processInfo.arguments
            if args.contains("--premium-monthly") {
                return (.monthly, Calendar.current.date(byAdding: .month, value: 1, to: .now))
            }
            if args.contains("--premium-yearly") {
                return (.yearly, Calendar.current.date(byAdding: .year, value: 1, to: .now))
            }
            return (.lifetime, nil)
        }
    #endif

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
    /// if they hold a verified, unrevoked entitlement to any product in
    /// `ProductID` — lifetime non-consumable or an active subscription.
    ///
    /// We match strictly by `productID` rather than `subscriptionGroupID` for
    /// subscriptions: `Transaction.subscriptionGroupID` returns the numeric
    /// group ID App Store Connect generates (e.g. "21342156"), not the human
    /// reference name ("weft_premium") — so the old `== subscriptionGroup`
    /// check silently failed in production for monthly/yearly buyers.
    func refresh() async {
        #if DEBUG
            if Self.debugPremiumOverride {
                let plan = Self.debugSimulatedPlan
                activeProductID = plan.id
                renewalDate = plan.renewal
                isPremium = true
                return
            }
        #endif
        var premium = false
        var renewal: Date?
        var active: ProductID?
        for await result in Transaction.currentEntitlements {
            guard case .verified(let txn) = result,
                  txn.revocationDate == nil,
                  let pid = ProductID(rawValue: txn.productID)
            else { continue }
            premium = true
            // Lifetime wins if the user somehow holds both a sub and lifetime.
            if active == nil || pid == .lifetime {
                active = pid
                renewal = pid.isSubscription ? txn.expirationDate : nil
            }
        }
        isPremium = premium
        renewalDate = renewal
        activeProductID = active
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
            guard let scene = activeWindowScene else {
                logger.error("Redeem sheet: no active window scene")
                return
            }
            do {
                try await AppStore.presentOfferCodeRedeemSheet(in: scene)
            } catch {
                logger.error("Redeem sheet failed: \(error.localizedDescription)")
            }
        }

        /// Presents Apple's native subscription-management sheet (cancel, change
        /// plan, see renewal). Only meaningful for auto-renewing subscriptions;
        /// the status screen hides the entry for Lifetime owners.
        func presentManageSubscriptions() async {
            guard let scene = activeWindowScene else {
                logger.error("Manage subscriptions: no active window scene")
                return
            }
            do {
                try await AppStore.showManageSubscriptions(in: scene)
            } catch {
                logger.error("Manage subscriptions failed: \(error.localizedDescription)")
            }
        }

        private var activeWindowScene: UIWindowScene? {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
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
