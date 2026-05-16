import SwiftUI

struct PasswordGeneratorSection: View {

    @State private var generatedPassword = ""
    @State private var passwordLength: Double = 16
    @State private var includeUppercase = true
    @State private var includeLowercase = true
    @State private var includeNumbers = true
    @State private var includeSpecialChars = true
    @State private var showCopiedToast = false

    var body: some View {
        VStack(spacing: AppTheme.spacingM) {
            passwordDisplayCard
            optionsCard
            copiedToast
        }
    }

    // MARK: - Password Display

    private var passwordDisplayCard: some View {
        VStack(spacing: AppTheme.spacingM) {
            Text(generatedPassword.isEmpty
                 ? String(localized: "Tap Generate")
                 : generatedPassword)
                .font(.system(size: 17, weight: .medium, design: .monospaced))
                .foregroundStyle(generatedPassword.isEmpty ? AppTheme.tertiaryText : AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(AppTheme.spacingM)
                .background(AppTheme.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
                .textSelection(.enabled)

            strengthIndicator

            HStack(spacing: AppTheme.spacingS) {
                Button {
                    generatePassword()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text(String(localized: "Generate"))
                            .font(AppTheme.bodyMedium)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
                    .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, y: 4)
                }
                .pressable()

                Button {
                    copyPassword()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14, weight: .semibold))
                        Text(String(localized: "Copy"))
                            .font(AppTheme.bodyMedium)
                    }
                    .foregroundStyle(AppTheme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(AppTheme.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
                }
                .pressable()
                .disabled(generatedPassword.isEmpty)
                .opacity(generatedPassword.isEmpty ? 0.5 : 1)
            }
        }
        .cardStyle()
    }

    // MARK: - Strength Indicator

    @ViewBuilder
    private var strengthIndicator: some View {
        if !generatedPassword.isEmpty {
            let strength = passwordStrength
            HStack(spacing: AppTheme.spacingS) {
                HStack(spacing: 3) {
                    ForEach(0..<4, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i < strength.level ? strength.color : AppTheme.surfaceSecondary)
                            .frame(height: 4)
                    }
                }

                Text(strength.label)
                    .font(AppTheme.captionMedium)
                    .foregroundStyle(strength.color)
            }
        }
    }

    private var passwordStrength: (level: Int, label: String, color: Color) {
        let len = generatedPassword.count
        var typesCount = 0
        if includeUppercase { typesCount += 1 }
        if includeLowercase { typesCount += 1 }
        if includeNumbers { typesCount += 1 }
        if includeSpecialChars { typesCount += 1 }

        if len >= 20 && typesCount >= 3 {
            return (4, String(localized: "Very Strong"), AppTheme.accent)
        } else if len >= 14 && typesCount >= 2 {
            return (3, String(localized: "Strong"), AppTheme.accent)
        } else if len >= 10 {
            return (2, String(localized: "Medium"), AppTheme.warning)
        } else {
            return (1, String(localized: "Weak"), AppTheme.destructive)
        }
    }

    // MARK: - Options

    private var optionsCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                HStack {
                    Text(String(localized: "Length"))
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Text("\(Int(passwordLength))")
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(AppTheme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.accentSoft)
                        .clipShape(Capsule())
                }
                Slider(value: $passwordLength, in: 8...40, step: 1)
                    .tint(AppTheme.accent)
            }
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.vertical, 14)

            Divider().padding(.leading, AppTheme.spacingM)

            toggleRow(
                String(localized: "Uppercase (A-Z)"),
                icon: "textformat.abc",
                isOn: $includeUppercase
            )
            Divider().padding(.leading, AppTheme.spacingM)
            toggleRow(
                String(localized: "Lowercase (a-z)"),
                icon: "textformat.abc",
                isOn: $includeLowercase
            )
            Divider().padding(.leading, AppTheme.spacingM)
            toggleRow(
                String(localized: "Numbers (0-9)"),
                icon: "number",
                isOn: $includeNumbers
            )
            Divider().padding(.leading, AppTheme.spacingM)
            toggleRow(
                String(localized: "Special (!@#$%)"),
                icon: "asterisk",
                isOn: $includeSpecialChars
            )
        }
        .cardStyle(padding: 0)
    }

    private func toggleRow(_ title: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.radiusS, style: .continuous)
                    .fill(AppTheme.accent.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
            }

            Text(title)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.primaryText)

            Spacer()

            Toggle("", isOn: isOn)
                .tint(AppTheme.accent)
                .labelsHidden()
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, 10)
    }

    // MARK: - Copied Toast

    @ViewBuilder
    private var copiedToast: some View {
        if showCopiedToast {
            HStack(spacing: AppTheme.spacingS) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.accent)
                Text(String(localized: "Password copied to clipboard"))
                    .font(AppTheme.captionMedium)
                    .foregroundStyle(AppTheme.accent)
            }
            .padding(AppTheme.spacingM)
            .frame(maxWidth: .infinity)
            .background(AppTheme.accentSoft)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Logic

    private func generatePassword() {
        var chars = ""
        if includeUppercase { chars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
        if includeLowercase { chars += "abcdefghijklmnopqrstuvwxyz" }
        if includeNumbers { chars += "0123456789" }
        if includeSpecialChars { chars += "!@#$%^&*()_+-=[]{}|;:,.<>?" }

        guard !chars.isEmpty else {
            includeLowercase = true
            chars = "abcdefghijklmnopqrstuvwxyz"
            return
        }

        generatedPassword = String((0..<Int(passwordLength)).map { _ in
            chars.randomElement()!
        })

        HapticManager.impact(.light)
    }

    private func copyPassword() {
        #if os(iOS)
        UIPasteboard.general.string = generatedPassword
        #endif
        HapticManager.notification(.success)
        withAnimation(.spring(response: 0.3)) { showCopiedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 0.3)) { showCopiedToast = false }
        }
    }
}

#Preview {
    ScrollView {
        PasswordGeneratorSection()
            .padding()
    }
    .background(GradientBackground())
}
