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
    var isUsingVPN = false

    var checks: [PrivacyCheck] = []

    // MARK: - Scan

    func startScan() {
        isScanning = true
        scanComplete = false
        scanProgress = 0
        checks = []

        Task {
            detectConnectionType()
            scanProgress = 0.15

            isUsingVPN = checkVPNActive()
            scanProgress = 0.30

            let httpsOK = await testHTTPSConnection()
            scanProgress = 0.50

            let dnsEncrypted = checkDNSEncryption()
            scanProgress = 0.65

            let proxyConfigured = checkProxySettings()
            scanProgress = 0.80

            let ipv6Available = await checkIPv6Support()
            scanProgress = 0.90

            let externalIP = await fetchExternalIP()
            scanProgress = 1.0

            buildChecks(
                httpsOK: httpsOK,
                dnsEncrypted: dnsEncrypted,
                proxyConfigured: proxyConfigured,
                ipv6Available: ipv6Available,
                externalIP: externalIP
            )

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

    // MARK: - Connection Type

    private func detectConnectionType() {
        let monitor = NWPathMonitor()
        let path = monitor.currentPath

        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }

    // MARK: - VPN Detection

    private func checkVPNActive() -> Bool {
        #if os(iOS)
        guard let cfDict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
              let scoped = cfDict["__SCOPED__"] as? [String: Any] else {
            return false
        }
        let vpnInterfaces = ["tap", "tun", "ppp", "ipsec", "utun"]
        return scoped.keys.contains { key in
            vpnInterfaces.contains { key.contains($0) }
        }
        #else
        return false
        #endif
    }

    // MARK: - HTTPS Test

    private func testHTTPSConnection() async -> Bool {
        guard let url = URL(string: "https://www.apple.com") else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return (200...399).contains(httpResponse.statusCode)
            }
            return false
        } catch {
            return false
        }
    }

    // MARK: - DNS Resolution Check

    private func checkDNSEncryption() -> Bool {
        let hostname = "dns-check.apple.com"
        var hints = addrinfo()
        hints.ai_family = AF_UNSPEC
        hints.ai_socktype = SOCK_STREAM

        var result: UnsafeMutablePointer<addrinfo>?
        let status = getaddrinfo(hostname, nil, &hints, &result)
        if let result { freeaddrinfo(result) }

        return status == 0
    }

    // MARK: - Proxy Settings

    private func checkProxySettings() -> Bool {
        #if os(iOS)
        guard let cfDict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return false
        }

        if let httpProxy = cfDict["HTTPProxy"] as? String, !httpProxy.isEmpty {
            return true
        }
        if let httpsProxy = cfDict["HTTPSProxy"] as? String, !httpsProxy.isEmpty {
            return true
        }
        if let httpEnable = cfDict["HTTPEnable"] as? Int, httpEnable == 1 {
            return true
        }
        if let httpsEnable = cfDict["HTTPSEnable"] as? Int, httpsEnable == 1 {
            return true
        }

        return false
        #else
        return false
        #endif
    }

    // MARK: - IPv6 Support

    private func checkIPv6Support() async -> Bool {
        let monitor = NWPathMonitor()
        let path = monitor.currentPath

        if path.supportsIPv6 {
            return true
        }

        guard let url = URL(string: "https://ipv6.google.com") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return (200...399).contains(httpResponse.statusCode)
            }
            return false
        } catch {
            return false
        }
    }

    // MARK: - External IP

    private func fetchExternalIP() async -> String? {
        guard let url = URL(string: "https://api.ipify.org") else { return nil }

        var request = URLRequest(url: url)
        request.timeoutInterval = 8

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return ip
        } catch {
            return nil
        }
    }

    // MARK: - Build Checks

    private func buildChecks(
        httpsOK: Bool,
        dnsEncrypted: Bool,
        proxyConfigured: Bool,
        ipv6Available: Bool,
        externalIP: String?
    ) {
        var results: [PrivacyCheck] = []

        switch connectionType {
        case .wifi:
            results.append(PrivacyCheck(
                title: String(localized: "Wi-Fi Connection"),
                subtitle: String(localized: "Connected to Wi-Fi network"),
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
                subtitle: connectionType == .wifi
                    ? String(localized: "Consider using a VPN on public Wi-Fi")
                    : String(localized: "VPN adds an extra layer of privacy"),
                icon: "shield.slash",
                status: connectionType == .wifi ? .warning : .info
            ))
        }

        results.append(PrivacyCheck(
            title: String(localized: "HTTPS Connection"),
            subtitle: httpsOK
                ? String(localized: "Secure connections are working properly")
                : String(localized: "HTTPS connections may be blocked or intercepted"),
            icon: httpsOK ? "lock.fill" : "lock.open.fill",
            status: httpsOK ? .good : .warning
        ))

        results.append(PrivacyCheck(
            title: String(localized: "DNS Resolution"),
            subtitle: dnsEncrypted
                ? String(localized: "DNS is resolving correctly")
                : String(localized: "DNS resolution failed — check your network settings"),
            icon: "server.rack",
            status: dnsEncrypted ? .good : .warning
        ))

        results.append(PrivacyCheck(
            title: String(localized: "Proxy Settings"),
            subtitle: proxyConfigured
                ? String(localized: "A proxy is configured on this network")
                : String(localized: "No proxy detected"),
            icon: proxyConfigured ? "arrow.triangle.branch" : "checkmark.circle",
            status: proxyConfigured ? .info : .good
        ))

        results.append(PrivacyCheck(
            title: String(localized: "IPv6 Support"),
            subtitle: ipv6Available
                ? String(localized: "Your network supports the modern IPv6 protocol")
                : String(localized: "IPv6 is not available on this network"),
            icon: "network",
            status: ipv6Available ? .good : .info
        ))

        if let ip = externalIP {
            results.append(PrivacyCheck(
                title: String(localized: "External IP Address"),
                subtitle: isUsingVPN
                    ? String(localized: "\(ip) (routed through VPN)")
                    : ip,
                icon: "globe",
                status: .info
            ))
        }

        results.append(PrivacyCheck(
            title: String(localized: "Safari Protection"),
            subtitle: ContentBlockerManager.shared.isProtectionActive
                ? String(localized: "\(ContentBlockerManager.shared.enabledFilters.count) filters active")
                : String(localized: "Enable content blocking for safer browsing"),
            icon: "shield.checkered",
            status: ContentBlockerManager.shared.isProtectionActive ? .good : .warning
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
