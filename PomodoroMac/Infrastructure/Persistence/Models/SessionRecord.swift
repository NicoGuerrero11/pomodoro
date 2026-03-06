import Foundation
import SwiftData

@Model
final class SessionRecord {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date
    var kindRawValue: String
    var durationSeconds: Int

    init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date,
        kindRawValue: String,
        durationSeconds: Int
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.kindRawValue = kindRawValue
        self.durationSeconds = durationSeconds
    }
}
