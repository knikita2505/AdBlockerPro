import SwiftUI

struct SafariSetupGuideView: View {

    @Environment(\.dismiss) private var dismiss

    private let appName = "AdBlocker Pro"

    private var steps: [(icon: String, title: String, detail: String)] {
        [
            (
                "gear",
                String(localized: "Open Settings"),
                String(localized: "Open the Settings app on your iPhone.")
            ),
            (
                "square.grid.2x2",
                String(localized: "Open Apps"),
                String(localized: "Scroll to Apps, then tap Safari.")
            ),
            (
                "puzzlepiece.extension",
                String(localized: "Open Extensions"),
                String(localized: "In Safari settings, tap Extensions.")
            ),
            (
                "switch.2",
                String(localized: "Turn on \(appName)"),
                String(localized: "Find “\(appName)” in the list and turn the switch on. This is the content blocker for this app — not a different Safari extension.")
            ),
            (
                "arrow.uturn.backward",
                String(localized: "Return here"),
                String(localized: "Come back to \(appName) and tap the shield to start protection.")
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                    header
                    stepsCard
                    openSettingsButton
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.top, AppTheme.spacingM)
                .padding(.bottom, AppTheme.spacingXL)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(String(localized: "Enable Extension"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Close")) { dismiss() }
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: AppTheme.spacingM) {
            Image(systemName: "puzzlepiece.extension.fill")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(AppTheme.destructive)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(String(localized: "Enable \(appName) Extension"))
                .font(AppTheme.titleSmall)
                .foregroundStyle(AppTheme.primaryText)
                .multilineTextAlignment(.center)

            Text(String(localized: "Safari can block ads only after you turn on this app’s extension. Follow the steps below."))
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, AppTheme.spacingXS)
    }

    private var stepsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: AppTheme.spacingM) {
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.accent)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(AppTheme.bodyMedium)
                            .foregroundStyle(AppTheme.primaryText)

                        Text(step.detail)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, 14)

                if index < steps.count - 1 {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
        .cardStyle(padding: 0)
    }

    private var openSettingsButton: some View {
        Button {
            HapticManager.impact(.medium)
            openSafariExtensionsSettings()
        } label: {
            Text(String(localized: "Open Safari Settings"))
                .font(AppTheme.bodyMedium)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
        }
        .pressable()
    }

    private func openSafariExtensionsSettings() {
        #if os(iOS)
        if let url = URL(string: "App-prefs:SAFARI&path=WEB_EXTENSIONS") {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

#Preview {
    SafariSetupGuideView()
}
