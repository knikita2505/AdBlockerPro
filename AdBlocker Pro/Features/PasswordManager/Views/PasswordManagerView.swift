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
            VStack(spacing: AppTheme.spacingXL) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.10))
                        .frame(width: 100, height: 100)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(AppTheme.accent)
                }

                Text(String(localized: "Enter Passcode"))
                    .font(.system(size: 20, weight: .semibold))

                passcodeDotsView

                numberPad

                if passcodeService.canUseBiometrics && passcodeService.isBiometricsEnabled {
                    Button {
                        Task { await passcodeService.authenticateWithBiometrics() }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: biometricIcon)
                            Text("Use \(passcodeService.biometricName)")
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.accent)
                    }
                }

                Spacer()
            }
            .padding(AppTheme.spacingL)
            .background(AppTheme.background)
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
        HStack(spacing: 16) {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(index < enteredCode.count ? AppTheme.accent : AppTheme.accent.opacity(0.2))
                    .frame(width: 14, height: 14)
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
                    .font(.system(size: 20))
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
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(AppTheme.primaryText)
                .frame(width: 56, height: 56)
                .background(AppTheme.groupedBackground)
                .clipShape(Circle())
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
                Picker("Section", selection: $selectedSection) {
                    ForEach(PasswordSection.allCases, id: \.self) { section in
                        Text(section.title).tag(section)
                    }
                }
                .pickerStyle(.segmented)
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
                    }
                    .padding(.horizontal, AppTheme.spacingM)
                    .padding(.top, AppTheme.spacingS)
                }
            }
            .background(AppTheme.groupedBackground)
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
}

#Preview {
    PasswordManagerView()
}
