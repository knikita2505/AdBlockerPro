import SwiftUI
import AppTrackingTransparency

struct LaunchOfferView: View {

    var onFinished: () -> Void

    @State private var vm = PaywallViewModel(placement: .launch)
    @State private var showsPaywall = false
    @State private var progress: CGFloat = 0.08
    @State private var isReady = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            if showsPaywall {
                PaywallView(viewModel: vm, onDismissed: onFinished)
                    .transition(.opacity)
            } else {
                preparation
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: showsPaywall)
        .task { await run() }
    }

    private var preparation: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 40)
                    .padding(.top, 8)

                VStack(spacing: 20) {
                    Image("AppShield")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 148, height: 148)
                        .padding(.top, 4)

                    Text(isReady
                         ? String(localized: "Blocker is ready")
                         : String(localized: "Preparing the blocker"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .contentTransition(.opacity)
                }

                Spacer(minLength: 8)

                statusOrb
                    .padding(.bottom, 4)

                Color.clear
                    .frame(height: 56)
            }
        }
    }

    private var statusOrb: some View {
        ZStack {
            Circle()
                .fill(AppTheme.accent.opacity(0.12))
                .frame(width: 188, height: 188)
                .scaleEffect(pulse ? 1.08 : 1.0)
            Circle()
                .fill(AppTheme.accent.opacity(0.18))
                .frame(width: 156, height: 156)
                .scaleEffect(pulse ? 1.05 : 1.0)

            Circle()
                .fill(AppTheme.accent)
                .frame(width: 124, height: 124)
                .shadow(color: AppTheme.accent.opacity(0.35), radius: 16, y: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 148, height: 148)
                .rotationEffect(.degrees(-90))

            if isReady {
                Image(systemName: "checkmark")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private func run() async {
        let load = Task { await vm.preload() }

        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            try? await Task.sleep(for: .milliseconds(350))
            _ = await AppsFlyerService.shared.requestATTPermission()
        }

        withAnimation(.easeInOut(duration: 1.35)) {
            progress = 0.9
        }

        let minimum = Date().addingTimeInterval(1.35)
        let deadline = Date().addingTimeInterval(8)
        while Date() < deadline {
            if Date() >= minimum, vm.didFinishLoading { break }
            try? await Task.sleep(for: .milliseconds(50))
        }

        withAnimation(.easeOut(duration: 0.3)) {
            progress = 1
        }
        try? await Task.sleep(for: .milliseconds(240))
        HapticManager.notification(.success)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
            isReady = true
        }
        try? await Task.sleep(for: .milliseconds(720))
        showsPaywall = true
        await load.value
    }
}

#Preview {
    LaunchOfferView {}
}
