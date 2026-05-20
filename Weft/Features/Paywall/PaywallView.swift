import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(Entitlements.self) private var entitlements
    @State private var selected: Entitlements.ProductID = .lifetime
    @State private var statusMessage: StatusMessage?
    @State private var welcomeMode: PremiumWelcomeView.Mode? = Self.debugWelcomeMode

    /// DEBUG-only: `--celebrate` / `--celebrate-restore` boot the paywall into
    /// the post-purchase welcome state so we can iterate on motion + copy
    /// without going through a real StoreKit transaction. Never true in
    /// release.
    private static var debugWelcomeMode: PremiumWelcomeView.Mode? {
        #if DEBUG
            let args = ProcessInfo.processInfo.arguments
            if args.contains("--celebrate-restore") { return .restored }
            if args.contains("--celebrate") { return .freshPurchase }
            return nil
        #else
            return nil
        #endif
    }

    private var isPurchasing: Bool {
        entitlements.purchasingProductID != nil
    }

    private static let termsURL: URL = {
        guard let url = URL(string: "https://getweft.xyz/terms") else {
            fatalError("Programmer error: hard-coded termsURL is invalid")
        }
        return url
    }()

    private static let privacyURL: URL = {
        guard let url = URL(string: "https://getweft.xyz/privacy") else {
            fatalError("Programmer error: hard-coded privacyURL is invalid")
        }
        return url
    }()

    var body: some View {
        Group {
            if let mode = welcomeMode {
                PremiumWelcomeView(mode: mode, onContinue: { dismiss() })
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                paywallBody
                    .transition(.opacity)
            }
        }
        .background(Color.bg)
        .toolbar {
            if welcomeMode == nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .interactiveDismissDisabled(welcomeMode != nil)
        .alert(item: $statusMessage) { msg in
            Alert(title: Text(msg.title), message: Text(msg.body), dismissButton: .default(Text("OK")))
        }
    }

    private var paywallBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                hero
                features
                plans
                Button(action: startPurchase) {
                    if isPurchasing {
                        ProgressView().tint(Color.bg)
                    } else {
                        Text(ctaTitle)
                    }
                }
                .buttonStyle(WeftPrimaryButtonStyle())
                .frame(maxWidth: .infinity)
                .disabled(isPurchasing)
                SubscriptionTerms(selected: selected)
                redeemButton
                links
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.huge)
        }
    }

    private var hero: some View {
        VStack(alignment: .center, spacing: Spacing.m) {
            Text("Weft Premium")
                .font(.system(size: 34, design: .serif).weight(.medium))
                .foregroundStyle(Color.ink)
            Text("The free version is for \(Entitlements.freePeopleLimit) people. " +
                "Premium is for everyone you care about.")
                .font(WeftFont.serifBody)
                .foregroundStyle(Color.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.l)
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            ForEach(featureLines, id: \.self) { line in
                HStack(spacing: 14) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.sageInk)
                        .frame(width: 28, height: 28)
                        .background(Color.sageWash, in: Circle())
                    Text(line)
                        .font(WeftFont.serifBody)
                        .foregroundStyle(Color.ink)
                }
            }
        }
    }

    private var plans: some View {
        VStack(spacing: Spacing.m) {
            planRow(
                id: .lifetime,
                title: "Lifetime",
                fallbackSubtitle: "Pay once · yours forever",
                fallbackPrice: "$39.99",
                badge: "Best value"
            )
            planRow(
                id: .yearly,
                title: "Yearly",
                fallbackSubtitle: "$18.99 / year · 7-day free trial",
                fallbackPrice: "$18.99",
                badge: nil
            )
            planRow(
                id: .monthly,
                title: "Monthly",
                fallbackSubtitle: "$2.99 / month · cancel anytime",
                fallbackPrice: "$2.99",
                badge: nil
            )
        }
    }

    private var ctaTitle: String {
        switch selected {
        case .lifetime: "Get Weft for life"
        case .yearly: "Start free trial"
        case .monthly: "Subscribe"
        }
    }

    private func planRow(
        id: Entitlements.ProductID,
        title: String,
        fallbackSubtitle: String,
        fallbackPrice: String,
        badge: String?
    ) -> some View {
        let product = entitlements.product(for: id)
        let priceLabel = product?.displayPrice ?? fallbackPrice
        let subtitle: String = {
            guard let product else { return fallbackSubtitle }
            if id == .yearly, let intro = product.subscription?.introductoryOffer {
                return introCopy(intro)
            }
            if id == .yearly {
                let perMonthCents = (NSDecimalNumber(decimal: product.price).doubleValue / 12) * 100
                let perMonth = String(format: "$%.2f/mo", perMonthCents / 100)
                return "\(product.displayPrice) / year · \(perMonth)"
            }
            if id == .monthly {
                return "\(product.displayPrice) / month · cancel anytime"
            }
            return fallbackSubtitle
        }()
        return PlanRow(
            title: title,
            subtitle: subtitle,
            price: priceLabel,
            isSelected: selected == id,
            badge: badge
        )
        .contentShape(Rectangle())
        .onTapGesture {
            Haptic.soft.play()
            selected = id
        }
    }

    private func introCopy(_ offer: Product.SubscriptionOffer) -> String {
        if offer.paymentMode == .freeTrial {
            let n = offer.periodCount
            let unit: String = switch offer.period.unit {
            case .day: n == 1 ? "day" : "days"
            case .week: n == 1 ? "week" : "weeks"
            case .month: n == 1 ? "month" : "months"
            case .year: n == 1 ? "year" : "years"
            @unknown default: "period"
            }
            return "\(n)-\(unit) free trial · billed yearly"
        }
        return "Intro offer · billed yearly"
    }

    private var redeemButton: some View {
        Button(action: presentRedeem) {
            Text("Have a code? Redeem")
                .font(WeftFont.body)
                .foregroundStyle(Color.sage)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.s)
    }

    private func presentRedeem() {
        Haptic.soft.play()
        Task { await entitlements.presentRedeemSheet() }
    }

    private var links: some View {
        HStack(spacing: Spacing.l) {
            Button("Restore", action: restore)
            Button("Terms") { openURL(Self.termsURL) }
            Button("Privacy") { openURL(Self.privacyURL) }
        }
        .font(WeftFont.caption)
        .foregroundStyle(Color.whisper)
        .frame(maxWidth: .infinity)
    }

    private func startPurchase() {
        Haptic.soft.play()
        guard let product = entitlements.product(for: selected) else {
            statusMessage = StatusMessage(
                title: "Products loading",
                body: "Hang tight — the App Store catalog hasn't loaded yet. Try again in a moment."
            )
            return
        }
        Task {
            let entitled = await entitlements.purchase(product)
            if entitled {
                // PremiumWelcomeView handles its own success haptic at the
                // start of the celebration sequence — don't double-fire.
                withAnimation(.weftCalm) {
                    welcomeMode = .freshPurchase
                }
            }
        }
    }

    private func restore() {
        Haptic.soft.play()
        // Snapshot pre-state so we can distinguish three outcomes after sync:
        //   • was free → now Premium  ⇒  genuine restore, fire .restored welcome
        //   • was Premium → still Premium ⇒ no transition, quiet acknowledgement
        //   • still free  ⇒  nothing on this Apple ID
        let wasPremium = entitlements.isPremium
        Task {
            await entitlements.restore()
            switch (wasPremium, entitlements.isPremium) {
            case (false, true):
                withAnimation(.weftCalm) {
                    welcomeMode = .restored
                }
            case (true, true):
                statusMessage = StatusMessage(
                    title: "Already on Premium",
                    body: "Your purchase is already active on this device."
                )
            default:
                statusMessage = StatusMessage(
                    title: "Nothing to restore",
                    body: "No active Weft Premium subscription found on this Apple ID."
                )
            }
        }
    }

    private let featureLines = [
        "Unlimited people",
        "iCloud sync across devices",
        "Lock-screen & home-screen widgets",
        "PDF & Markdown export",
        "Photo memories"
    ]
}

private struct StatusMessage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

/// Subscription-terms disclosure block. Required by Apple's Guideline 3.1.2(c)
/// (auto-renewing subscriptions): the in-app must show, before purchase, the
/// subscription title, length, price (and price-per-unit if not trivial), plus
/// the cancellation path. Lifetime is non-renewing so its copy differs. We name
/// the full product ("Weft Premium Monthly", etc.) rather than just the tier
/// label so the reviewer can match it 1:1 with the IAP record.
private struct SubscriptionTerms: View {
    let selected: Entitlements.ProductID

    var body: some View {
        Group {
            switch selected {
            case .lifetime:
                Text(
                    "Weft Premium Lifetime · $39.99 one-time purchase. " +
                        "No subscription, no renewals."
                )
            case .yearly:
                Text(
                    "Weft Premium Yearly · $18.99 per year (≈ $1.58 / month). " +
                        "7-day free trial, then auto-renews yearly until cancelled. " +
                        "Manage in iOS Settings → your name → Subscriptions."
                )
            case .monthly:
                Text(
                    "Weft Premium Monthly · $2.99 per month. " +
                        "Auto-renews monthly until cancelled. " +
                        "Manage in iOS Settings → your name → Subscriptions."
                )
            }
        }
        .font(WeftFont.mini)
        .foregroundStyle(Color.muted)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.m)
    }
}

private struct PlanRow: View {
    let title: String
    let subtitle: String
    let price: String
    let isSelected: Bool
    let badge: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(WeftFont.body.weight(.semibold)).foregroundStyle(Color.ink)
                Text(subtitle).font(WeftFont.caption).foregroundStyle(Color.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(price)
                    .font(.system(.title2, design: .serif).weight(.medium))
                    .foregroundStyle(Color.ink)
                if let badge {
                    Text(badge)
                        .font(WeftFont.mini)
                        .foregroundStyle(Color.sage)
                }
            }
        }
        .padding(Spacing.l)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(
                    isSelected ? Color.sage : Color.ink.opacity(0.1),
                    lineWidth: isSelected ? 1.5 : 0.5
                )
        )
    }
}

struct WeftPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WeftFont.body.weight(.semibold))
            .foregroundStyle(Color.bg)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(Color.ink, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.weftPress, value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack { PaywallView() }
        .environment(Entitlements())
}
