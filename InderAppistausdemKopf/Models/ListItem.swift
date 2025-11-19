import Foundation
import SwiftData

@Model
final class ListItem {
    @Attribute(.unique) var uuid: UUID
    var title: String
    var note: String?
    var category: Category
    var priority: Priority
    var dueDate: Date?
    var isDone: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        uuid: UUID = .init(),
        title: String,
        note: String? = nil,
        category: Category = .personal,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.uuid = uuid
        self.title = title
        self.note = note
        self.category = category
        self.priority = priority
        self.dueDate = dueDate
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum Category: String, Codable, CaseIterable, Identifiable {
    case work = "Arbeit"
    case personal = "Privat"
    case shopping = "Einkauf"
    case household = "Haushalt"
    case appointments = "Termine"
    case other = "Sonstiges"

    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .work: return "💼"
        case .personal: return "🏠"
        case .shopping: return "🛒"
        case .household: return "🏡"
        case .appointments: return "📅"
        case .other: return "📝"
        }
    }
    
    var displayName: String {
        return "\(emoji) \(rawValue)"
    }
}

enum Priority: String, Codable, CaseIterable, Identifiable {
    case low = "Niedrig"
    case medium = "Mittel"
    case high = "Hoch"

    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .low: return "🟢 Niedrig"
        case .medium: return "🟡 Mittel"
        case .high: return "🔴 Hoch"
        }
    }

    var sortIndex: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
    
    var emoji: String {
        switch self {
        case .low: return "🟢"
        case .medium: return "🟡"
        case .high: return "🔴"
        }
    }
}

