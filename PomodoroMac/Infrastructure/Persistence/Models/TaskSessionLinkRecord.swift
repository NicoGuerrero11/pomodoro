import Foundation
import SwiftData

@Model
final class TaskSessionLinkRecord {
    @Attribute(.unique) var id: UUID
    var taskID: UUID
    var sessionID: UUID

    init(id: UUID = UUID(), taskID: UUID, sessionID: UUID) {
        self.id = id
        self.taskID = taskID
        self.sessionID = sessionID
    }
}
