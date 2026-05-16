import SwiftUI
import LocalAuthentication

struct PasswordManagerView: View {

    var passcodeService = PasscodeService.shared

    var body: some View {
        Group {
            if !passcodeService.hasPasscode {
                PasscodeSetupView()
            } else if !passcodeService.isUnlocked {
                PasscodeUnlockView()
            } else {
                PasswordManagerHomeView()
            }
        }
    }
}

// MARK: - Unlock View

struct PasscodeUnlockView: View {

    var passcodeService = PasscodeService.shared
    @State private var enteredCode = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                VStack(spacing: AppTheme.spacingXL) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 38, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.accent)
                    }

                    VStack(spacing: AppTheme.spacingS) {
                        Text(String(localized: "Enter Passcode"))
                            .font(AppTheme.titleMedium)
                            .foregroundStyle(AppTheme.primaryText)
                        Text(String(localized: "Enter your 4-digit passcode"))
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    passcodeDotsView

                    numberPad

                    if passcodeService.canUseBiometrics && passcodeService.isBiometricsEnabled {
                        Button {
                            HapticManager.impact(.light)
                            Task { await passcodeService.authenticateWithBiometrics() }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: biometricIcon)
                                Text("Use \(passcodeService.biometricName)")
                            }
                            .font(AppTheme.bodyMedium)
                            .foregroundStyle(AppTheme.accent)
                            .padding(.horizontal, AppTheme.spacingL)
                            .padding(.vertical, 12)
                            .background(AppTheme.accentSoft)
                            .clipShape(Capsule())
                        }
                        .pressable()
                    }

                    Spacer()
                }
                .padding(AppTheme.spacingL)
            }
            .navigationTitle(String(localized: "Passwords"))
            .navigationBarTitleDisplayMode(.inline)
            .alert("Incorrect Passcode", isPresented: $showError) {
                Button("Try Again", role: .cancel) { enteredCode = "" }
            }
            .onAppear {
                if passcodeService.canUseBiometrics && passcodeService.isBiometricsEnabled {
                    Task { await passcodeService.authenticateWithBiometrics() }
                }
            }
        }
    }

    private var passcodeDotsView: some View {
        HStack(spacing: AppTheme.spacingM) {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(index < enteredCode.count ? AppTheme.accent : AppTheme.accent.opacity(0.2))
                    .frame(width: 14, height: 14)
                    .animation(.spring(response: 0.3), value: enteredCode.count)
            }
        }
    }

    private var numberPad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 14) {
            ForEach(1...9, id: \.self) { num in
                numberButton(String(num))
            }
            Color.clear.frame(height: 56)
            numberButton("0")
            Button {
                if !enteredCode.isEmpty { enteredCode.removeLast() }
            } label: {
                Image(systemName: "delete.backward")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .frame(width: 56, height: 56)
            }
        }
        .padding(.horizontal, AppTheme.spacingXL)
    }

    private func numberButton(_ num: String) -> some View {
        Button {
            guard enteredCode.count < 4 else { return }
            enteredCode += num
            if enteredCode.count == 4 {
                if passcodeService.verifyPasscode(enteredCode) {
                    HapticManager.notification(.success)
                } else {
                    HapticManager.notification(.error)
                    showError = true
                }
            } else {
                HapticManager.impact(.light)
            }
        } label: {
            Text(num)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .frame(width: 56, height: 56)
                .background(AppTheme.surface)
                .clipShape(Circle())
                .shadow(color: AppTheme.shadowSoft, radius: 4, x: 0, y: 2)
        }
    }

    private var biometricIcon: String {
        switch passcodeService.biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "person.fill.viewfinder"
        }
    }
}

// MARK: - Home (after unlock)

struct PasswordManagerHomeView: View {

    @State private var selectedSection: PasswordSection = .generator

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: AppTheme.spacingS) {
                    ForEach(PasswordSection.allCases, id: \.self) { section in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSection = section
                            }
                            HapticManager.impact(.light)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: section.icon)
                                    .font(.system(size: 13, weight: .semibold))
                                Text(section.title)
                                    .font(AppTheme.bodyMedium)
                            }
                            .foregroundStyle(selectedSection == section ? .white : AppTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selectedSection == section
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                : AnyShapeStyle(AppTheme.surface)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
                            .shadow(color: selectedSection == section ? AppTheme.accent.opacity(0.3) : .clear, radius: 8, y: 2)
                        }
                        .pressable()
                    }
                }
                .padding(AppTheme.spacingXS)
                .background(AppTheme.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingS)

                ScrollView {
                    VStack(spacing: AppTheme.spacingM) {
                        switch selectedSection {
                        case .generator:
                            PasswordGeneratorSection()
                        case .saved:
                            SavedPasswordsSection()
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, AppTheme.spacingM)
                    .padding(.top, AppTheme.spacingS)
                }
            }
            .background(GradientBackground())
            .navigationTitle(String(localized: "Passwords"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

enum PasswordSection: String, CaseIterable {
    case generator
    case saved

    var title: String {
        switch self {
        case .generator: return String(localized: "Generator")
        case .saved: return String(localized: "Saved")
        }
    }

    var icon: String {
        switch self {
        case .generator: return "wand.and.stars"
        case .saved: return "key.fill"
        }
    }
}

#Preview {
    PasswordManagerView()
}
