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
                VStack(spacing: AppTheme.spacingXL) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.12))
                            .frame(width: 100, height: 100)
                        Image(systemName: step.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.accent)
                    }

                    Text(step.title)
                        .font(AppTheme.titleFont)

                    Text(step.subtitle)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)

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
            .animation(.easeInOut, value: step)
            .navigationTitle("Passwords")
            .alert("Codes Don't Match", isPresented: $showMismatchError) {
                Button("Try Again", role: .cancel) {
                    firstCode = ""
                    confirmCode = ""
                    step = .create
                }
            } message: {
                Text("Please try creating your passcode again.")
            }
        }
    }

    private var currentCode: String {
        step == .create ? firstCode : confirmCode
    }

    private var passcodeDotsView: some View {
        HStack(spacing: 16) {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(index < currentCode.count ? AppTheme.accent : AppTheme.accent.opacity(0.2))
                    .frame(width: 16, height: 16)
            }
        }
    }

    private var numberPad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
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
                    .font(.title2)
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
                .font(.title.bold())
                .foregroundStyle(AppTheme.primaryText)
                .frame(width: 60, height: 60)
                .background(AppTheme.secondaryBackground)
                .clipShape(Circle())
        }
    }

    // MARK: - Biometrics

    private var biometricsView: some View {
        VStack(spacing: AppTheme.spacingL) {
            Spacer()

            Image(systemName: passcodeService.biometricType == .faceID ? "faceid" : "touchid")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.accent)

            Text("Enable \(passcodeService.biometricName)?")
                .font(AppTheme.titleFont)

            Text("Use \(passcodeService.biometricName) for quick access to your passwords")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacingL)

            Spacer()

            Button {
                passcodeService.isBiometricsEnabled = true
                passcodeService.setPasscode(confirmCode)
                HapticManager.notification(.success)
            } label: {
                Text("Enable \(passcodeService.biometricName)")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            }

            Button {
                passcodeService.setPasscode(confirmCode)
                HapticManager.notification(.success)
            } label: {
                Text("Skip")
                    .font(AppTheme.footnoteFont)
                    .foregroundStyle(AppTheme.secondaryText)
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
