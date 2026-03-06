import Foundation

struct CompletedTask: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let title: String
    let completedAt: Date
}
