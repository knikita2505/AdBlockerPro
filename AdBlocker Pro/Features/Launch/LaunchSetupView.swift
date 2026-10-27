import SwiftUI

struct LaunchSetupView: View {

    var onFinished: () -> Void

    @State private var activeIndex = 0
    @State private var completedCount = 0
    @State private var didFinish = false

    private var steps: [(title: String, subtitle: String)] {
        [
            (
                String(localized: "Phishing filters"),
                String(localized: "Protects your smartphone from theft of your banking and personal data")
            ),
            (
                String(localized: "Ad Filter"),
                String(localized: "Protects your smartphone from annoying ads")
            ),
            (
                String(localized: "Spam filters"),
                String(localized: "Protects your smartphone from spam ads")
            ),
            (
                String(localized: "Tracking ID"),
                String(localized: "Stop thousands of corporations from tracking your personal data")
            )
        ]
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer(minLength: 24)

                Image("AppShield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 168, height: 168)

                Text(String(localized: "Checking the database"))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 22) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        stepRow(index: index, title: step.title, subtitle: step.subtitle)
                    }
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .task {
            await run()
        }
    }

    private func stepRow(index: Int, title: String, subtitle: String) -> some View {
        let isComplete = index < completedCount
        let isActive = index == activeIndex && !isComplete

        return HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            ZStack {
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppTheme.accent)
                } else if isActive {
                    ProgressView()
                        .controlSize(.small)
                        .tint(AppTheme.accent)
                }
            }
            .frame(width: 22, height: 22)
        }
        .animation(.easeOut(duration: 0.25), value: completedCount)
    }

    private func run() async {
        async let tracking: Void = prepareTracking()

        for index in steps.indices {
            if Task.isCancelled { return }
            activeIndex = index
            try? await Task.sleep(for: .milliseconds(1600))
            if Task.isCancelled { return }
            completedCount = index + 1
            HapticManager.impact(.light)
        }

        try? await Task.sleep(for: .milliseconds(700))
        if Task.isCancelled { return }
        await tracking
        if Task.isCancelled { return }
        finish()
    }

    private func prepareTracking() async {
        try? await Task.sleep(for: .milliseconds(500))
        _ = await AppsFlyerService.shared.requestATTPermission()
        await ConsentService.shared.prepareAdsIfNeeded()
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        onFinished()
    }
}
