import SwiftUI

/// Subscription section of Settings, extracted so `SettingsView`'s body stays
/// under the lint cap. Reads entitlement state directly; the parent only hands
/// in the people count, a sheet setter, and the "nothing to restore" binding.
struct SubscriptionSection: View {
    @Environment(Entitlements.self) private var entitlements
    let peopleCount: Int
    let setSheet: (PremiumSheet) -> Void
    @Binding var restoreEmpty: Bool

    var body: some View {
        Section {
            Button {
                Haptic.selection.play()
                setSheet(entitlements.isPremium ? .status : .paywall)
            } label: {
                HStack {
                    Label("Weft Premium", systemImage: "sparkles")
                        .foregroundStyle(Color.ink)
                    Spacer()
                    Text(statusLabel)
                        .foregroundStyle(entitlements.isPremium ? Color.sage : Color.muted)
                        .font(WeftFont.caption)
                    chevron
                }
            }
            .buttonStyle(.plain)

            // A gift code can't add anything for a Lifetime owner, so the entry
            // only shows for free users and subscribers.
            if entitlements.activeProductID != .lifetime {
                Button {
                    Haptic.selection.play()
                    Task { await entitlements.presentRedeemSheet() }
                } label: {
                    HStack {
                        Label("Redeem a gift code", systemImage: "gift")
                            .foregroundStyle(Color.ink)
                        Spacer()
                        chevron
                    }
                }
                .buttonStyle(.plain)
            }

            Button {
                Haptic.selection.play()
                Task {
                    await entitlements.restore()
                    if entitlements.isPremium {
                        Haptic.success.play()
                    } else {
                        restoreEmpty = true
                    }
                }
            } label: {
                HStack {
                    Label("Restore purchase", systemImage: "arrow.clockwise")
                        .foregroundStyle(Color.ink)
                    Spacer()
                    chevron
                }
            }
            .buttonStyle(.plain)
        } header: { Text("Subscription") } footer: {
            Text(entitlements.isPremium
                ? "Thanks for supporting Weft."
                : "Unlock unlimited people, sync, widgets, and exports.")
        }
    }

    private var statusLabel: String {
        if entitlements.isPremium { return "Premium · Active" }
        return "Free · \(peopleCount) / \(Entitlements.freePeopleLimit)"
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.whisper)
    }
}

/// Sync section of Settings. Owns its own UI for the toggle, status badge,
/// paywall nudge and the relaunch hints. State writes flow through the parent's
/// bindings.
struct SyncSection: View {
    @Binding var syncEnabled: Bool
    @Binding var syncRestartHint: Bool
    let onUpgrade: () -> Void
    let isPremium: Bool
    let syncActive: Bool
    let needsRelaunchForData: Bool
    let hasICloudAccount: Bool

    /// The three states the status row can communicate. `needsAccount` is the
    /// one that previously read as a bare, confusing "Off": Premium + toggle
    /// on, but no iCloud account signed in on the device.
    private enum SyncState {
        case active
        case needsAccount
        case off
    }

    private var state: SyncState {
        if syncActive { return .active }
        if isPremium, syncEnabled, !hasICloudAccount { return .needsAccount }
        return .off
    }

    var body: some View {
        Section {
            Toggle("iCloud sync", isOn: $syncEnabled)
                .disabled(!isPremium)
                .onChange(of: syncEnabled) { _, _ in syncRestartHint = true }
            LabeledContent("Status") {
                HStack(spacing: 6) {
                    Image(systemName: statusIcon)
                        .foregroundStyle(statusTint)
                    Text(statusText)
                        .foregroundStyle(Color.muted)
                }
            }
            if state == .needsAccount {
                accountHint
            }
            if !isPremium {
                upgradeRow
            }
            if needsRelaunchForData {
                dataRelaunchHint
            } else if syncRestartHint {
                restartHint
            }
        } header: { Text("Sync") } footer: {
            Text(
                "Your notes live on this device. iCloud sync is a Premium feature and end-to-end encrypted."
            )
        }
    }

    private var statusText: LocalizedStringKey {
        switch state {
        case .active: "On"
        case .needsAccount: "Needs iCloud sign-in"
        case .off: "Off"
        }
    }

    private var statusIcon: String {
        switch state {
        case .active: "checkmark.icloud"
        case .needsAccount: "exclamationmark.icloud"
        case .off: "icloud.slash"
        }
    }

    private var statusTint: Color {
        switch state {
        case .active: .sage
        case .needsAccount: .warm
        case .off: .muted
        }
    }

    private var accountHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .foregroundStyle(Color.muted)
            Text("Sign in to iCloud in the Settings app to sync across your devices.")
                .font(WeftFont.caption)
                .foregroundStyle(Color.muted)
        }
    }

    private var upgradeRow: some View {
        Button {
            Haptic.soft.play()
            onUpgrade()
        } label: {
            HStack {
                Label("Premium required", systemImage: "lock")
                    .foregroundStyle(Color.muted)
                Spacer()
                Text("Upgrade")
                    .font(WeftFont.mini)
                    .foregroundStyle(Color.sage)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.sageWash, in: Capsule())
            }
        }
        .buttonStyle(.plain)
    }

    private var restartHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.clockwise")
                .foregroundStyle(Color.muted)
            Text("Restart Weft for the change to take effect.")
                .font(WeftFont.caption)
                .foregroundStyle(Color.muted)
        }
    }

    private var dataRelaunchHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.clockwise")
                .foregroundStyle(Color.muted)
            Text("Relaunch Weft to sync your data to this device.")
                .font(WeftFont.caption)
                .foregroundStyle(Color.muted)
        }
    }
}
