import Foundation

enum ActiveSessionPhase: String, Codable, CaseIterable, Sendable {
    case focus
    case shortBreak
    case longBreak
}

struct ActiveSessionSnapshot: Codable, Equatable, Sendable {
    var snapshotID: UUID
    var phase: ActiveSessionPhase
    var startedAt: Date
    var remainingSeconds: Int
    var linkedTaskIDs: [UUID]
}
