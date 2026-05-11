import Foundation
import LocalAuthentication
import SwiftUI
import Observation

@Observable
final class PasscodeService {

    static let shared = PasscodeService()

    var isUnlocked = false
    var hasPasscode: Bool
    var isBiometricsEnabled: Bool {
        didSet { UserDefaults.standard.set(isBiometricsEnabled, forKey: passcodeKeys.biometrics) }
    }

    private let passcodeKeys = (
        code: "passcode_code",
        biometrics: "passcode_biometrics_enabled",
        hasPasscode: "passcode_has_passcode"
    )

    private init() {
        self.hasPasscode = UserDefaults.standard.bool(forKey: passcodeKeys.hasPasscode)
        self.isBiometricsEnabled = UserDefaults.standard.bool(forKey: passcodeKeys.biometrics)
    }

    var biometricType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }

    var biometricName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometrics"
        }
    }

    var canUseBiometrics: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    // MARK: - Passcode Management

    func setPasscode(_ code: String) {
        _ = KeychainService.save(string: code, forKey: passcodeKeys.code)
        hasPasscode = true
        isUnlocked = true
        UserDefaults.standard.set(true, forKey: passcodeKeys.hasPasscode)
    }

    func verifyPasscode(_ code: String) -> Bool {
        guard let stored = KeychainService.loadString(forKey: passcodeKeys.code) else { return false }
        let match = stored == code
        if match { isUnlocked = true }
        return match
    }

    func removePasscode() {
        KeychainService.delete(forKey: passcodeKeys.code)
        hasPasscode = false
        isBiometricsEnabled = false
        isUnlocked = false
        UserDefaults.standard.set(false, forKey: passcodeKeys.hasPasscode)
    }

    func lock() {
        isUnlocked = false
    }

    // MARK: - Biometrics

    func authenticateWithBiometrics() async -> Bool {
        guard canUseBiometrics, isBiometricsEnabled else { return false }

        let context = LAContext()
        context.localizedFallbackTitle = "Enter Passcode"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: String(localized: "Unlock Password Manager")
            )
            if success {
                await MainActor.run { isUnlocked = true }
            }
            return success
        } catch {
            return false
        }
    }
}
