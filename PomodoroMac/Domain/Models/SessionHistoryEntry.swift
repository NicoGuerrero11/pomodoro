import Foundation

enum SessionKind: String, Codable, CaseIterable, Sendable {
    case focus
    case shortBreak
    case longBreak
}

struct SessionHistoryEntry: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date
    let kind: SessionKind
    let durationSeconds: Int
    let linkedTaskIDs: [UUID]
}
