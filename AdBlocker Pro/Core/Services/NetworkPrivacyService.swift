import Foundation
import Network
import SwiftUI
import Observation
#if os(iOS)
import SystemConfiguration.CaptiveNetwork
#endif

@Observable
final class NetworkPrivacyService {

    var isScanning = false
    var scanComplete = false
    var scanProgress: Double = 0

    var connectionType: ConnectionType = .unknown
    var ssidName: String?
    var isUsingVPN = false
    var dnsInfo: String = "Standard"

    var checks: [PrivacyCheck] = []

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "network.monitor")

    func startScan() {
        isScanning = true
        scanComplete = false
        scanProgress = 0
        checks = []

        detectConnectionType()

        Task {
            for step in 1...5 {
                try? await Task.sleep(for: .milliseconds(600))
                scanProgress = Double(step) / 5.0
            }

            buildChecks()
            isScanning = false
            scanComplete = true
            HapticManager.notification(.success)
        }
    }

    func reset() {
        isScanning = false
        scanComplete = false
        scanProgress = 0
        checks = []
    }

    // MARK: - Detection

    private func detectConnectionType() {
        let path = NWPathMonitor().currentPath

        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }

        isUsingVPN = checkVPNActive()
    }

    private func checkVPNActive() -> Bool {
        #if os(iOS)
        guard let cfDict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
              let scoped = cfDict["__SCOPED__"] as? [String: Any] else {
            return false
        }
        return scoped.keys.contains { $0.contains("tap") || $0.contains("tun") || $0.contains("ppp") || $0.contains("ipsec") || $0.contains("utun") }
        #else
        return false
        #endif
    }

    // MARK: - Build Checks

    private func buildChecks() {
        var results: [PrivacyCheck] = []

        switch connectionType {
        case .wifi:
            results.append(PrivacyCheck(
                title: String(localized: "Wi-Fi Connection"),
                subtitle: ssidName ?? String(localized: "Connected"),
                icon: "wifi",
                status: .info
            ))
        case .cellular:
            results.append(PrivacyCheck(
                title: String(localized: "Cellular Connection"),
                subtitle: String(localized: "Using mobile data"),
                icon: "antenna.radiowaves.left.and.right",
                status: .good
            ))
        case .ethernet:
            results.append(PrivacyCheck(
                title: String(localized: "Wired Connection"),
                subtitle: String(localized: "Connected via Ethernet"),
                icon: "cable.connector",
                status: .good
            ))
        case .unknown:
            results.append(PrivacyCheck(
                title: String(localized: "No Connection"),
                subtitle: String(localized: "Not connected to any network"),
                icon: "wifi.slash",
                status: .warning
            ))
        }

        if isUsingVPN {
            results.append(PrivacyCheck(
                title: String(localized: "VPN Active"),
                subtitle: String(localized: "Your traffic is encrypted via VPN"),
                icon: "lock.shield.fill",
                status: .good
            ))
        } else {
            results.append(PrivacyCheck(
                title: String(localized: "No VPN Detected"),
                subtitle: String(localized: "Consider using a VPN on public networks"),
                icon: "shield.slash",
                status: .warning
            ))
        }

        results.append(PrivacyCheck(
            title: String(localized: "DNS Configuration"),
            subtitle: String(localized: "Using default DNS settings"),
            icon: "server.rack",
            status: .info
        ))

        if connectionType == .wifi && !isUsingVPN {
            results.append(PrivacyCheck(
                title: String(localized: "Public Wi-Fi Risk"),
                subtitle: String(localized: "Use VPN when connected to public Wi-Fi networks"),
                icon: "exclamationmark.triangle.fill",
                status: .warning
            ))
        }

        results.append(PrivacyCheck(
            title: String(localized: "Safari Protection"),
            subtitle: ContentBlockerManager.shared.enabledFilters.isEmpty
                ? String(localized: "Enable content blocking for safer browsing")
                : String(localized: "\(ContentBlockerManager.shared.enabledFilters.count) filters active"),
            icon: "shield.checkered",
            status: ContentBlockerManager.shared.enabledFilters.isEmpty ? .warning : .good
        ))

        checks = results
    }
}

// MARK: - Models

enum ConnectionType {
    case wifi, cellular, ethernet, unknown

    var displayName: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .cellular: return "Cellular"
        case .ethernet: return "Ethernet"
        case .unknown: return "Unknown"
        }
    }
}

struct PrivacyCheck: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let status: CheckStatus
}

enum CheckStatus {
    case good, warning, info

    var color: Color {
        switch self {
        case .good: return .green
        case .warning: return .orange
        case .info: return .blue
        }
    }

    var iconName: String {
        switch self {
        case .good: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
}
