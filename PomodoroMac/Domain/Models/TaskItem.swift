import Foundation

enum TaskPriority: String, Codable, CaseIterable, Sendable {
    case low
    case medium
    case high
}

struct TaskItem: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var notes: String
    var priority: TaskPriority
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
}
