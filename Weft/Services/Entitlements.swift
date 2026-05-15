import Foundation
import OSLog
import StoreKit

@MainActor
@Observable
final class Entitlements {
    enum ProductID: String, CaseIterable {
        case monthly = "weft_premium_monthly"
        case yearly = "weft_premium_yearly"
    }

    static let subscriptionGroup = "weft_premium"
    static let freePeopleLimit = 7

    private(set) var isPremium = false
    private(set) var renewalDate: Date?
    private(set) var products: [Product] = []
    private(set) var productsLoaded = false
    private(set) var purchasingProductID: String?

    private let logger = Logger(subsystem: "com.amuwal.weft", category: "Entitlements")
    private var transactionListener: Task<Void, Never>?

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
            products = fetched.sorted { lhs, _ in lhs.id.contains("yearly") }
            productsLoaded = !products.isEmpty
            let loadedCount = products.count
            logger.info("Loaded \(loadedCount) products")
        } catch {
            productsLoaded = false
            logger.error("Product load failed: \(error.localizedDescription)")
        }
    }

    /// Re-derive `isPremium` from the local Transaction history.
    func refresh() async {
        var premium = false
        var renewal: Date?
        for await result in Transaction.currentEntitlements {
            guard case .verified(let txn) = result else { continue }
            guard txn.subscriptionGroupID == Self.subscriptionGroup else { continue }
            if txn.revocationDate == nil {
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
}
