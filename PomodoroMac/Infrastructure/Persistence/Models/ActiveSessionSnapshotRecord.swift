import Foundation
import SwiftData

@Model
final class ActiveSessionSnapshotRecord {
    @Attribute(.unique) var snapshotID: UUID
    var phaseRawValue: String
    var startedAt: Date
    var remainingSeconds: Int
    var linkedTaskIDsData: Data

    init(
        snapshotID: UUID,
        phaseRawValue: String,
        startedAt: Date,
        remainingSeconds: Int,
        linkedTaskIDsData: Data
    ) {
        self.snapshotID = snapshotID
        self.phaseRawValue = phaseRawValue
        self.startedAt = startedAt
        self.remainingSeconds = remainingSeconds
        self.linkedTaskIDsData = linkedTaskIDsData
    }
}
