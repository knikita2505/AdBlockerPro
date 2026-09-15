import Foundation
import Observation

@Observable
final class GuideProgressStore {

    static let shared = GuideProgressStore()

    private let prefix = "privacyGuide."
    private var completedByGuide: [String: Set<Int>] = [:]
    private var pageByGuide: [String: Int] = [:]

    private init() {}

    func completedSteps(for guideId: String) -> Set<Int> {
        if let cached = completedByGuide[guideId] {
            return cached
        }
        let loaded = Set(UserDefaults.standard.array(forKey: stepsKey(guideId)) as? [Int] ?? [])
        completedByGuide[guideId] = loaded
        return loaded
    }

    func completedCount(for guideId: String) -> Int {
        completedSteps(for: guideId).count
    }

    func isComplete(guideId: String, total: Int) -> Bool {
        total > 0 && completedCount(for: guideId) >= total
    }

    func currentPage(for guideId: String) -> Int {
        if let cached = pageByGuide[guideId] {
            return cached
        }
        let page = UserDefaults.standard.integer(forKey: pageKey(guideId))
        pageByGuide[guideId] = page
        return page
    }

    func setPage(_ page: Int, guideId: String) {
        pageByGuide[guideId] = page
        UserDefaults.standard.set(page, forKey: pageKey(guideId))
    }

    func markStep(_ index: Int, completed: Bool = true, guideId: String) {
        var set = completedSteps(for: guideId)
        if completed {
            set.insert(index)
        } else {
            set.remove(index)
        }
        completedByGuide[guideId] = set
        UserDefaults.standard.set(Array(set).sorted(), forKey: stepsKey(guideId))
    }

    func markCompleted(upTo index: Int, guideId: String) {
        guard index >= 0 else { return }
        var set = completedSteps(for: guideId)
        for step in 0...index {
            set.insert(step)
        }
        completedByGuide[guideId] = set
        UserDefaults.standard.set(Array(set).sorted(), forKey: stepsKey(guideId))
    }

    private func stepsKey(_ id: String) -> String { prefix + id + ".steps" }
    private func pageKey(_ id: String) -> String { prefix + id + ".page" }
}
