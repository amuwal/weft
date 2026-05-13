import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selected: Entitlements.ProductID = .yearly

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                hero
                features
                plans
                Button("Start free trial", action: {})
                    .buttonStyle(LingerPrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                links
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.huge)
        }
        .background(Color.bg)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .center, spacing: Spacing.m) {
            Text("Linger Premium")
                .font(.system(size: 34, design: .serif).weight(.medium))
                .foregroundStyle(Color.ink)
            Text("The free version is for 7 people. Premium is for everyone you care about.")
                .font(LingerFont.serifBody)
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
                        .font(LingerFont.serifBody)
                        .foregroundStyle(Color.ink)
                }
            }
        }
    }

    private var plans: some View {
        VStack(spacing: Spacing.m) {
            PlanRow(
                title: "Yearly",
                subtitle: "$2.08/mo · 7-day free trial",
                price: "$24.99",
                isSelected: selected == .yearly,
                badge: "Best value"
            )
            .onTapGesture { selected = .yearly
                Haptic.soft.play()
            }
            PlanRow(
                title: "Monthly",
                subtitle: "Cancel anytime",
                price: "$3.99",
                isSelected: selected == .monthly,
                badge: nil
            )
            .onTapGesture { selected = .monthly
                Haptic.soft.play()
            }
        }
    }

    private var links: some View {
        HStack(spacing: Spacing.l) {
            Button("Restore", action: {})
            Button("Terms", action: {})
            Button("Privacy", action: {})
        }
        .font(LingerFont.caption)
        .foregroundStyle(Color.whisper)
        .frame(maxWidth: .infinity)
    }

    private let featureLines = [
        "Unlimited people",
        "iCloud sync across devices",
        "Apple Watch & widgets",
        "PDF & Markdown export",
        "Photo memories"
    ]
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
                Text(title).font(LingerFont.body.weight(.semibold)).foregroundStyle(Color.ink)
                Text(subtitle).font(LingerFont.caption).foregroundStyle(Color.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(price)
                    .font(.system(.title2, design: .serif).weight(.medium))
                    .foregroundStyle(Color.ink)
                if let badge {
                    Text(badge)
                        .font(LingerFont.mini)
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

struct LingerPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LingerFont.body.weight(.semibold))
            .foregroundStyle(Color.bg)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(Color.ink, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.lingerPress, value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack { PaywallView() }
}
