import SwiftUI
import LocalAuthentication

struct PasscodeSetupView: View {

    var passcodeService = PasscodeService.shared

    @State private var step: SetupStep = .create
    @State private var firstCode = ""
    @State private var confirmCode = ""
    @State private var showMismatchError = false

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                VStack(spacing: AppTheme.spacingXL) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.10))
                            .frame(width: 110, height: 110)
                        Circle()
                            .fill(AppTheme.accent.opacity(0.20))
                            .frame(width: 85, height: 85)
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                            Image(systemName: step.icon)
                                .font(.system(size: 26, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 12, y: 4)
                    }

                    VStack(spacing: AppTheme.spacingS) {
                        Text(step.title)
                            .font(AppTheme.titleMedium)
                            .foregroundStyle(AppTheme.primaryText)

                        Text(step.subtitle)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.spacingL)
                    }

                    if step != .biometrics {
                        passcodeDotsView
                        numberPad
                    }

                    Spacer()
                }
                .padding(AppTheme.spacingL)
                .opacity(step == .biometrics ? 0 : 1)

                if step == .biometrics {
                    biometricsView
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: step)
            .navigationTitle(String(localized: "Passwords"))
            .navigationBarTitleDisplayMode(.inline)
            .alert(String(localized: "Codes Don't Match"), isPresented: $showMismatchError) {
                Button(String(localized: "Try Again"), role: .cancel) {
                    firstCode = ""
                    confirmCode = ""
                    step = .create
                }
            } message: {
                Text(String(localized: "Please try creating your passcode again."))
            }
        }
    }

    private var currentCode: String {
        step == .create ? firstCode : confirmCode
    }

    // MARK: - Dots

    private var passcodeDotsView: some View {
        HStack(spacing: AppTheme.spacingM) {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(index < currentCode.count ? AppTheme.accent : AppTheme.accent.opacity(0.2))
                    .frame(width: 16, height: 16)
                    .scaleEffect(index < currentCode.count ? 1.15 : 1.0)
                    .animation(.spring(response: 0.25), value: currentCode.count)
            }
        }
    }

    // MARK: - Number Pad

    private var numberPad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 14) {
            ForEach(1...9, id: \.self) { num in
                numberButton(String(num))
            }
            Color.clear.frame(height: 60)
            numberButton("0")
            Button {
                switch step {
                case .create:
                    if !firstCode.isEmpty { firstCode.removeLast() }
                case .confirm:
                    if !confirmCode.isEmpty { confirmCode.removeLast() }
                case .biometrics:
                    break
                }
            } label: {
                Image(systemName: "delete.backward")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .frame(width: 60, height: 60)
            }
        }
        .padding(.horizontal, AppTheme.spacingXL)
    }

    private func numberButton(_ num: String) -> some View {
        Button {
            HapticManager.impact(.light)
            switch step {
            case .create:
                guard firstCode.count < 4 else { return }
                firstCode += num
                if firstCode.count == 4 {
                    withAnimation { step = .confirm }
                }
            case .confirm:
                guard confirmCode.count < 4 else { return }
                confirmCode += num
                if confirmCode.count == 4 {
                    if confirmCode == firstCode {
                        if passcodeService.canUseBiometrics {
                            withAnimation { step = .biometrics }
                        } else {
                            passcodeService.setPasscode(confirmCode)
                            HapticManager.notification(.success)
                        }
                    } else {
                        HapticManager.notification(.error)
                        showMismatchError = true
                    }
                }
            case .biometrics:
                break
            }
        } label: {
            Text(num)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .frame(width: 60, height: 60)
                .background(AppTheme.surface)
                .clipShape(Circle())
                .shadow(color: AppTheme.shadowSoft, radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Biometrics

    private var biometricsView: some View {
        VStack(spacing: AppTheme.spacingL) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.10))
                    .frame(width: 130, height: 130)
                Circle()
                    .fill(AppTheme.accent.opacity(0.20))
                    .frame(width: 100, height: 100)
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                    Image(systemName: passcodeService.biometricType == .faceID ? "faceid" : "touchid")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(.white)
                }
                .shadow(color: AppTheme.accent.opacity(0.3), radius: 12, y: 4)
            }

            VStack(spacing: AppTheme.spacingS) {
                Text("Enable \(passcodeService.biometricName)?")
                    .font(AppTheme.titleMedium)
                    .foregroundStyle(AppTheme.primaryText)

                Text("Use \(passcodeService.biometricName) for quick access to your passwords")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingL)
            }

            Spacer()

            VStack(spacing: AppTheme.spacingM) {
                Button {
                    passcodeService.isBiometricsEnabled = true
                    passcodeService.setPasscode(confirmCode)
                    HapticManager.notification(.success)
                } label: {
                    Text("Enable \(passcodeService.biometricName)")
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 12, y: 4)
                }
                .pressable()

                Button {
                    passcodeService.setPasscode(confirmCode)
                    HapticManager.notification(.success)
                } label: {
                    Text(String(localized: "Skip"))
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
                }
                .pressable()
            }
        }
        .padding(AppTheme.spacingL)
        .padding(.bottom, AppTheme.spacingXL)
    }
}

// MARK: - Setup Step

private enum SetupStep: Equatable {
    case create
    case confirm
    case biometrics

    var title: String {
        switch self {
        case .create: return String(localized: "Create Passcode")
        case .confirm: return String(localized: "Confirm Passcode")
        case .biometrics: return String(localized: "Enable Biometrics")
        }
    }

    var subtitle: String {
        switch self {
        case .create: return String(localized: "Set a 4-digit passcode to protect your saved passwords")
        case .confirm: return String(localized: "Enter the same passcode again to confirm")
        case .biometrics: return String(localized: "Use biometrics for quick access")
        }
    }

    var icon: String {
        switch self {
        case .create: return "lock.fill"
        case .confirm: return "lock.rotation"
        case .biometrics: return "faceid"
        }
    }
}

#Preview {
    PasscodeSetupView()
}
