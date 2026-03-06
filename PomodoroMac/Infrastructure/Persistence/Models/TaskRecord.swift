import Foundation
import SwiftData

@Model
final class TaskRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String
    var priorityRawValue: String
    var prioritySortOrder: Int
    var createdAt: Date
    var isCompleted: Bool
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String,
        priorityRawValue: String,
        prioritySortOrder: Int? = nil,
        createdAt: Date = .now,
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.priorityRawValue = priorityRawValue
        self.prioritySortOrder = prioritySortOrder ?? TaskPriority(rawValue: priorityRawValue)?.sortOrder ?? TaskPriority.medium.sortOrder
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}
