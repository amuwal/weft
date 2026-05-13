import Foundation
import StoreKit

@MainActor
@Observable
final class Entitlements {
    enum ProductID: String, CaseIterable {
        case monthly = "linger_premium_monthly"
        case yearly = "linger_premium_yearly"
    }

    static let subscriptionGroup = "linger_premium"

    private(set) var isPremium = false
    private(set) var renewalDate: Date?
    private(set) var trialUsed = false

    func bootstrap() async {
        await refresh()
        Task { await listenForUpdates() }
    }

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

    private func listenForUpdates() async {
        for await update in Transaction.updates {
            if case .verified = update {
                await refresh()
            }
        }
    }
}
