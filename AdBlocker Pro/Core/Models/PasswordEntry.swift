import Foundation

struct PasswordEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var website: String
    var username: String
    var password: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String = "",
        website: String = "",
        username: String = "",
        password: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.website = website
        self.username = username
        self.password = password
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
