import Foundation
import SwiftUI
import Observation

@Observable
final class PasswordStorageService {

    static let shared = PasswordStorageService()

    var entries: [PasswordEntry] = []

    private let storageKey = "password_entries"

    private init() {
        loadEntries()
    }

    func addEntry(_ entry: PasswordEntry) {
        entries.append(entry)
        saveEntries()
    }

    func updateEntry(_ entry: PasswordEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index] = entry
        saveEntries()
    }

    func deleteEntry(_ entry: PasswordEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }

    // MARK: - Persistence via Keychain

    private func saveEntries() {
        _ = KeychainService.save(entries, forKey: storageKey)
    }

    private func loadEntries() {
        entries = KeychainService.load([PasswordEntry].self, forKey: storageKey) ?? []
    }
}
