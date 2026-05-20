import StoreKit
import SwiftUI

/// Shown to existing Premium members in place of the paywall (which is only for
/// non-members). Calm and reassuring, never a re-pitch: it confirms the plan,
/// lists what they already have, and offers Apple's subscription sheet + restore.
/// Lifetime owners see no renewal or cancel entry — there is nothing to renew —
/// so the screen reads "yours forever" instead.
struct PremiumStatusView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(Entitlements.self) private var entitlements

    private var isSubscription: Bool {
        entitlements.activeProductID?.isSubscription ?? false
    }

    private var planLabel: LocalizedStringKey {
        switch entitlements.activeProductID {
        case .lifetime: "Lifetime"
        case .yearly: "Yearly"
        case .monthly: "Monthly"
        case nil: "Premium"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                brandMark
                    .frame(width: 132, height: 96)
                    .padding(.top, Spacing.xl)
                header
                perks
                Spacer(minLength: Spacing.l)
                actions
                links
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.huge)
            .frame(maxWidth: .infinity)
        }
        .background(Color.bg)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private var header: some View {
        VStack(spacing: Spacing.s) {
            Text("Weft Premium")
                .font(.system(size: 32, design: .serif).weight(.medium))
                .foregroundStyle(Color.ink)
            Text(planLabel)
                .font(WeftFont.body.weight(.semibold))
                .foregroundStyle(Color.sage)
            statusLine
                .font(WeftFont.serifBody)
                .italic()
                .foregroundStyle(Color.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var statusLine: Text {
        if isSubscription, let renewal = entitlements.renewalDate {
            let date = renewal.formatted(date: .abbreviated, time: .omitted)
            return Text(String(format: loc("Renews %@"), date))
        }
        return Text("Yours forever.")
    }

    private var perks: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            ForEach(Array(perkLines.enumerated()), id: \.offset) { _, line in
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.s)
    }

    private var actions: some View {
        VStack(spacing: Spacing.m) {
            if isSubscription {
                Button {
                    Haptic.soft.play()
                    Task { await entitlements.presentManageSubscriptions() }
                } label: {
                    Text("Cancel or change plan")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(Color.sage)
            }
            Button {
                Haptic.soft.play()
                Task { await entitlements.restore() }
            } label: {
                Text("Restore purchase")
                    .font(WeftFont.body)
                    .foregroundStyle(Color.sage)
            }
        }
    }

    private var links: some View {
        HStack(spacing: Spacing.l) {
            Button("Terms") { open("https://getweft.xyz/terms") }
            Button("Privacy") { open("https://getweft.xyz/privacy") }
        }
        .font(WeftFont.caption)
        .foregroundStyle(Color.whisper)
        .padding(.top, Spacing.s)
    }

    private func open(_ string: String) {
        Haptic.soft.play()
        if let url = URL(string: string) { openURL(url) }
    }

    /// A static, fully-drawn version of the welcome screen's brand mark — two
    /// sage dots joined by the weft curve — so the member screen feels of a
    /// piece with the post-purchase moment. Geometry matches `BrandCurveShape`
    /// (endpoints inset 32, sitting at 72% height).
    private var brandMark: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let w = geo.size.width
            let radius: CGFloat = 9
            let left = CGPoint(x: 32, y: h * 0.72)
            let right = CGPoint(x: w - 32, y: h * 0.72)
            ZStack {
                BrandCurveShape()
                    .stroke(Color.sage, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                Circle().fill(Color.sage).frame(width: radius * 2, height: radius * 2).position(left)
                Circle().fill(Color.sage).frame(width: radius * 2, height: radius * 2).position(right)
            }
        }
    }

    private let perkLines: [LocalizedStringKey] = [
        "Unlimited people",
        "iCloud sync across devices",
        "Lock-screen & home-screen widgets",
        "PDF & Markdown export",
        "Photo memories"
    ]
}

#Preview("Lifetime") {
    NavigationStack { PremiumStatusView() }
        .environment(Entitlements())
}
