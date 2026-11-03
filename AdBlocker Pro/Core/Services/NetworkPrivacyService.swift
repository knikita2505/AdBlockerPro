import Foundation
import Network
import SwiftUI
import Observation

@Observable
final class NetworkPrivacyService {

    var isScanning = false
    var scanComplete = false
    var scanProgress: Double = 0

    var connectionType: ConnectionType = .unknown
    var isUsingVPN = false

    var checks: [PrivacyCheck] = []

    private let pathMonitor = NWPathMonitor()
    private var cachedPath: PathSnapshot?

    init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            let snapshot = PathSnapshot(path: path)
            Task { @MainActor in
                self?.cachedPath = snapshot
            }
        }
        pathMonitor.start(queue: DispatchQueue(label: "network.path.monitor"))
    }

    deinit {
        pathMonitor.cancel()
    }

    // MARK: - Scan

    func startScan() {
        isScanning = true
        scanComplete = false
        scanProgress = 0
        checks = []

        Task {
            let path = await pathForScan()
            detectConnectionType(from: path)
            scanProgress = 0.18

            isUsingVPN = checkVPNActive()
            scanProgress = 0.32

            let internetOK = await testInternetAccess()
            scanProgress = 0.52

            let dnsOK = await checkDNSResolution()
            scanProgress = 0.68

            let proxyConfigured = checkProxySettings()
            scanProgress = 0.80

            let ipv6Available = path?.supportsIPv6 ?? false
            scanProgress = 0.90

            let externalIP = await fetchExternalIP()
            scanProgress = 1.0

            buildChecks(
                internetOK: internetOK,
                dnsOK: dnsOK,
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

    // MARK: - Path

    private func pathForScan() async -> PathSnapshot? {
        if let cachedPath {
            return cachedPath
        }
        for _ in 0..<12 {
            try? await Task.sleep(for: .milliseconds(100))
            if let cachedPath {
                return cachedPath
            }
        }
        return cachedPath
    }

    private func detectConnectionType(from path: PathSnapshot?) {
        guard let path, path.isSatisfied else {
            connectionType = .unknown
            return
        }

        if path.isWiFi {
            connectionType = .wifi
        } else if path.isCellular {
            connectionType = .cellular
        } else if path.isEthernet {
            connectionType = .ethernet
        } else {
            connectionType = .other
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

    // MARK: - Internet Access

    private func testInternetAccess() async -> Bool {
        let candidates = [
            "https://www.apple.com/library/test/success.html",
            "https://captive.apple.com/hotspot-detect.html"
        ]

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 8
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        defer { session.finishTasksAndInvalidate() }

        for candidate in candidates {
            guard let url = URL(string: candidate) else { continue }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 8
            do {
                let (_, response) = try await session.data(for: request)
                if let httpResponse = response as? HTTPURLResponse,
                   (200...399).contains(httpResponse.statusCode) {
                    return true
                }
            } catch {
                continue
            }
        }
        return false
    }

    // MARK: - DNS Resolution

    private func checkDNSResolution() async -> Bool {
        await Task.detached(priority: .userInitiated) {
            Self.resolveHostname("apple.com") || Self.resolveHostname("one.one.one.one")
        }.value
    }

    nonisolated private static func resolveHostname(_ hostname: String) -> Bool {
        var hints = addrinfo()
        hints.ai_family = AF_UNSPEC
        hints.ai_socktype = SOCK_STREAM

        var result: UnsafeMutablePointer<addrinfo>?
        let status = getaddrinfo(hostname, "443", &hints, &result)
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

    // MARK: - External IP

    private func fetchExternalIP() async -> String? {
        guard let url = URL(string: "https://api.ipify.org") else { return nil }

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 8
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        defer { session.finishTasksAndInvalidate() }

        var request = URLRequest(url: url)
        request.timeoutInterval = 8

        do {
            let (data, _) = try await session.data(for: request)
            let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return ip?.isEmpty == false ? ip : nil
        } catch {
            return nil
        }
    }

    // MARK: - Build Checks

    private func buildChecks(
        internetOK: Bool,
        dnsOK: Bool,
        proxyConfigured: Bool,
        ipv6Available: Bool,
        externalIP: String?
    ) {
        var results: [PrivacyCheck] = []

        switch connectionType {
        case .wifi:
            results.append(PrivacyCheck(
                title: String(localized: "Wi-Fi Connection"),
                subtitle: String(localized: "Connected to a Wi-Fi network"),
                icon: "wifi",
                status: .good,
                tooltip: String(localized: "Shows the type of network your iPhone is using right now. This check reads the system network path, so it should match the Wi-Fi icon in Control Center.")
            ))
        case .cellular:
            results.append(PrivacyCheck(
                title: String(localized: "Cellular Connection"),
                subtitle: String(localized: "Using mobile data"),
                icon: "antenna.radiowaves.left.and.right",
                status: .good,
                tooltip: String(localized: "Your device is using cellular data instead of Wi-Fi. Privacy risks are usually lower than on public hotspots, but a VPN still hides your traffic from the carrier.")
            ))
        case .ethernet:
            results.append(PrivacyCheck(
                title: String(localized: "Wired Connection"),
                subtitle: String(localized: "Connected via Ethernet"),
                icon: "cable.connector",
                status: .good,
                tooltip: String(localized: "The device is online over a wired Ethernet adapter rather than Wi-Fi or cellular.")
            ))
        case .other:
            results.append(PrivacyCheck(
                title: String(localized: "Network Connected"),
                subtitle: String(localized: "An active connection was found"),
                icon: "network",
                status: .good,
                tooltip: String(localized: "The system reports an active connection, but iOS did not label it as Wi-Fi or cellular. This is common when a VPN is on and hides the underlying interface.")
            ))
        case .unknown:
            results.append(PrivacyCheck(
                title: String(localized: "No Connection"),
                subtitle: String(localized: "Not connected to any network"),
                icon: "wifi.slash",
                status: .warning,
                tooltip: String(localized: "iOS reports that there is no satisfied network path. Turn on Wi-Fi or cellular data and scan again. Airplane Mode will also cause this result.")
            ))
        }

        if isUsingVPN {
            results.append(PrivacyCheck(
                title: String(localized: "VPN Active"),
                subtitle: String(localized: "Your traffic is encrypted via VPN"),
                icon: "lock.shield.fill",
                status: .good,
                tooltip: String(localized: "A VPN interface (such as utun or ipsec) is active. Your traffic is likely tunneled, which hides it from the local Wi-Fi operator. This app cannot see which VPN provider you use.")
            ))
        } else {
            results.append(PrivacyCheck(
                title: String(localized: "No VPN Detected"),
                subtitle: connectionType == .wifi
                    ? String(localized: "Consider using a VPN on public Wi-Fi")
                    : String(localized: "VPN adds an extra layer of privacy"),
                icon: "shield.slash",
                status: connectionType == .wifi ? .warning : .info,
                tooltip: String(localized: "No VPN tunnel was found. On public Wi-Fi, a VPN helps keep the cafe or hotel network from seeing the sites you visit. This is a recommendation, not a device error.")
            ))
        }

        results.append(PrivacyCheck(
            title: String(localized: "Internet Access"),
            subtitle: internetOK
                ? String(localized: "This network can reach the internet")
                : String(localized: "No internet — captive portal or offline"),
            icon: internetOK ? "globe" : "wifi.exclamationmark",
            status: internetOK ? .good : .warning,
            tooltip: String(localized: "Checks whether this network actually has internet, not just a Wi-Fi association. We send a short HTTPS request to Apple. If it fails, you may be on a hotel/airport login page, or the network has no internet.")
        ))

        results.append(PrivacyCheck(
            title: String(localized: "DNS Lookup"),
            subtitle: dnsOK
                ? String(localized: "Site names resolve correctly")
                : String(localized: "Could not resolve domain names"),
            icon: "server.rack",
            status: dnsOK ? .good : .warning,
            tooltip: String(localized: "DNS turns names like apple.com into IP addresses. This check only verifies that lookup works on the current network. iOS does not let apps see whether DNS is encrypted (iCloud Private Relay or DNS over HTTPS).")
        ))

        results.append(PrivacyCheck(
            title: String(localized: "Proxy Settings"),
            subtitle: proxyConfigured
                ? String(localized: "A proxy is configured on this network")
                : String(localized: "No proxy detected"),
            icon: proxyConfigured ? "arrow.triangle.branch" : "checkmark.circle",
            status: proxyConfigured ? .info : .good,
            tooltip: String(localized: "A proxy can reroute your traffic through another server. On school or corporate Wi-Fi this is normal. On an unknown network it may mean traffic is being inspected. This check reads system proxy settings only.")
        ))

        results.append(PrivacyCheck(
            title: String(localized: "IPv6 Support"),
            subtitle: ipv6Available
                ? String(localized: "This network supports IPv6")
                : String(localized: "IPv6 is not available on this network"),
            icon: "network",
            status: .info,
            tooltip: String(localized: "IPv6 is the newer internet address format. Many home networks still work fine on IPv4 only. This is informational and does not mean your connection is unsafe.")
        ))

        if let ip = externalIP {
            results.append(PrivacyCheck(
                title: String(localized: "Public IP Address"),
                subtitle: isUsingVPN
                    ? String(localized: "\(ip) (via VPN)")
                    : ip,
                icon: "globe",
                status: .info,
                tooltip: String(localized: "This is the address websites see for your connection. On Wi-Fi without a VPN it usually belongs to your ISP. With a VPN it belongs to the VPN server instead of your home or cafe network.")
            ))
        }

        results.append(PrivacyCheck(
            title: String(localized: "Safari Protection"),
            subtitle: ContentBlockerManager.shared.isProtectionActive
                ? String(localized: "\(ContentBlockerManager.shared.enabledFilters.count) filters active")
                : String(localized: "Enable content blocking for safer browsing"),
            icon: "shield.checkered",
            status: ContentBlockerManager.shared.isProtectionActive ? .good : .warning,
            tooltip: String(localized: "This is the AdBlocker Pro Safari content blocker — the same protection as on the main tab. It is listed here because it also reduces tracking while you browse on this network.")
        ))

        checks = results
    }
}

private struct PathSnapshot: Sendable {
    let isSatisfied: Bool
    let isWiFi: Bool
    let isCellular: Bool
    let isEthernet: Bool
    let supportsIPv6: Bool

    init(path: NWPath) {
        isSatisfied = path.status == .satisfied
        isWiFi = path.usesInterfaceType(.wifi) || path.availableInterfaces.contains { $0.type == .wifi }
        isCellular = path.usesInterfaceType(.cellular) || path.availableInterfaces.contains { $0.type == .cellular }
        isEthernet = path.usesInterfaceType(.wiredEthernet) || path.availableInterfaces.contains { $0.type == .wiredEthernet }
        supportsIPv6 = path.supportsIPv6
    }
}

// MARK: - Models

enum ConnectionType {
    case wifi, cellular, ethernet, other, unknown

    var displayName: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .cellular: return "Cellular"
        case .ethernet: return "Ethernet"
        case .other: return "Connected"
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
    let tooltip: String
}

enum CheckStatus {
    case good, warning, info

    var color: Color {
        switch self {
        case .good: return AppTheme.success
        case .warning: return AppTheme.warning
        case .info: return Color(hex: "3B82F6")
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
