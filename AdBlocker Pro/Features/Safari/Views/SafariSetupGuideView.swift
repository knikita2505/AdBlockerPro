import SwiftUI

struct SafariSetupGuideView: View {

    private let steps: [(icon: String, title: String, description: String)] = [
        ("gear", String(localized: "Open Settings"), String(localized: "Open the Settings app on your device")),
        ("safari", String(localized: "Go to Safari"), String(localized: "Scroll down and tap on Safari")),
        ("puzzlepiece.extension", String(localized: "Open Extensions"), String(localized: "Tap on Extensions in the Safari settings")),
        ("checkmark.circle.fill", String(localized: "Enable AdBlocker Pro"), String(localized: "Find AdBlocker Pro in the list and toggle it on")),
        ("arrow.uturn.backward", String(localized: "Return to App"), String(localized: "Come back to AdBlocker Pro and start using protection"))
    ]

    var body: some View {
        List {
            Section {
                VStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "safari")
                        .font(.system(size: 50))
                        .foregroundStyle(AppTheme.accent)

                    Text("Enable Safari Extension")
                        .font(AppTheme.titleFont)

                    Text("Follow these steps to activate content blocking in Safari")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingM)
            }

            Section("Steps") {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: AppTheme.spacingM) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accent)
                                .frame(width: 32, height: 32)
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.title)
                                .font(AppTheme.headlineFont)
                            Text(step.description)
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                    .padding(.vertical, AppTheme.spacingXS)
                }
            }

            Section {
                Button {
                    openAppSettings()
                } label: {
                    HStack {
                        Spacer()
                        Label("Open Settings", systemImage: "gear")
                            .font(AppTheme.headlineFont)
                        Spacer()
                    }
                }
                .tint(AppTheme.accent)
            } footer: {
                Text("This will open the Settings app where you can enable the Safari extension")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Safari Setup")
    }

    private func openAppSettings() {
        #if os(iOS)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        #endif
    }
}

#Preview {
    NavigationStack {
        SafariSetupGuideView()
    }
}
