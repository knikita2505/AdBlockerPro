import Foundation
import SwiftUI
import Observation
#if os(iOS)
import SafariServices
#endif

@Observable
final class ContentBlockerManager {

    static let shared = ContentBlockerManager()

    static let appGroupIdentifier = "group.nikita.ka.AdBlocker-Pro"
    static let extensionBundleIdentifier = "nikita.ka.AdBlocker-Pro.ContentBlockerExtension"
    static let rulesFileName = "blockerList.json"

    var enabledFilters: Set<FilterCategory> = [] {
        didSet { saveFilterState() }
    }

    var allowedWebsites: [String] = [] {
        didSet { saveWebsiteLists() }
    }

    var blockedWebsites: [String] = [] {
        didSet { saveWebsiteLists() }
    }

    var isReloading = false

    private let filtersKey = "enabledFilters"
    private let allowedKey = "allowedWebsites"
    private let blockedKey = "blockedWebsites"

    private init() {
        loadState()
    }

    // MARK: - Filter Toggle

    func toggleFilter(_ category: FilterCategory, isOn: Bool) {
        if isOn {
            enabledFilters.insert(category)
        } else {
            enabledFilters.remove(category)
        }
        Task { await rebuildAndReload() }
    }

    func isFilterEnabled(_ category: FilterCategory) -> Bool {
        enabledFilters.contains(category)
    }

    // MARK: - Website Lists

    func addAllowedWebsite(_ domain: String) {
        let normalized = domain.normalizedDomain
        guard normalized.isValidDomain, !allowedWebsites.contains(normalized) else { return }
        allowedWebsites.append(normalized)
        Task { await rebuildAndReload() }
    }

    func removeAllowedWebsite(at offsets: IndexSet) {
        allowedWebsites.remove(atOffsets: offsets)
        Task { await rebuildAndReload() }
    }

    func addBlockedWebsite(_ domain: String) {
        let normalized = domain.normalizedDomain
        guard normalized.isValidDomain, !blockedWebsites.contains(normalized) else { return }
        blockedWebsites.append(normalized)
        Task { await rebuildAndReload() }
    }

    func removeBlockedWebsite(at offsets: IndexSet) {
        blockedWebsites.remove(atOffsets: offsets)
        Task { await rebuildAndReload() }
    }

    // MARK: - Rule Building

    func rebuildAndReload() async {
        isReloading = true
        defer { isReloading = false }

        let rules = buildCombinedRules()
        writeRulesToAppGroup(rules)
        await reloadContentBlocker()
    }

    func resetAllRules() {
        enabledFilters.removeAll()
        allowedWebsites.removeAll()
        blockedWebsites.removeAll()
        Task { await rebuildAndReload() }
    }

    private func buildCombinedRules() -> [[String: Any]] {
        var allRules: [[String: Any]] = []

        for category in enabledFilters {
            let categoryRules = loadRulesFromBundle(category.rulesFileName)
            allRules.append(contentsOf: categoryRules)
        }

        for domain in blockedWebsites {
            let rule: [String: Any] = [
                "trigger": ["url-filter": ".*", "if-domain": ["*\(domain)"]],
                "action": ["type": "block"]
            ]
            allRules.append(rule)
        }

        for domain in allowedWebsites {
            let rule: [String: Any] = [
                "trigger": ["url-filter": ".*", "if-domain": ["*\(domain)"]],
                "action": ["type": "ignore-previous-rules"]
            ]
            allRules.append(rule)
        }

        if allRules.isEmpty {
            let emptyRule: [String: Any] = [
                "trigger": ["url-filter": "^$"],
                "action": ["type": "block"]
            ]
            allRules.append(emptyRule)
        }

        return allRules
    }

    private func loadRulesFromBundle(_ fileName: String) -> [[String: Any]] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return json
    }

    private func writeRulesToAppGroup(_ rules: [[String: Any]]) {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier
        ) else {
            print("[ContentBlocker] App Group container not available")
            return
        }

        let fileURL = containerURL.appendingPathComponent(Self.rulesFileName)

        do {
            let data = try JSONSerialization.data(withJSONObject: rules, options: [])
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[ContentBlocker] Failed to write rules: \(error)")
        }
    }

    private func reloadContentBlocker() async {
        #if os(iOS)
        do {
            try await SFContentBlockerManager.reloadContentBlocker(
                withIdentifier: Self.extensionBundleIdentifier
            )
        } catch {
            print("[ContentBlocker] Reload failed: \(error)")
        }
        #endif
    }

    // MARK: - Persistence

    private func saveFilterState() {
        let rawValues = enabledFilters.map(\.rawValue)
        UserDefaults.standard.set(rawValues, forKey: filtersKey)
    }

    private func saveWebsiteLists() {
        UserDefaults.standard.set(allowedWebsites, forKey: allowedKey)
        UserDefaults.standard.set(blockedWebsites, forKey: blockedKey)
    }

    private func loadState() {
        if let savedFilters = UserDefaults.standard.stringArray(forKey: filtersKey) {
            enabledFilters = Set(savedFilters.compactMap { FilterCategory(rawValue: $0) })
        }
        allowedWebsites = UserDefaults.standard.stringArray(forKey: allowedKey) ?? []
        blockedWebsites = UserDefaults.standard.stringArray(forKey: blockedKey) ?? []
    }
}
