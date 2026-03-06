import Foundation
import SwiftData

@MainActor
protocol SessionRepositoryType: Sendable {
    func save(_ session: SessionHistoryEntry) throws
    func fetchAll() throws -> [SessionHistoryEntry]
    func saveSnapshot(_ snapshot: ActiveSessionSnapshot?) throws
    func loadSnapshot() throws -> ActiveSessionSnapshot?
}

@MainActor
final class SessionRepository: SessionRepositoryType {
    private let container: ModelContainer
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(container: ModelContainer) {
        self.container = container
    }

    func save(_ session: SessionHistoryEntry) throws {
        let context = ModelContext(container)

        let existing = try fetchSessionRecord(id: session.id, in: context)
        let record = existing ?? SessionRecord(
            id: session.id,
            startedAt: session.startedAt,
            endedAt: session.endedAt,
            kindRawValue: session.kind.rawValue,
            durationSeconds: session.durationSeconds
        )

        record.startedAt = session.startedAt
        record.endedAt = session.endedAt
        record.kindRawValue = session.kind.rawValue
        record.durationSeconds = session.durationSeconds

        if existing == nil {
            context.insert(record)
        }

        try removeLinks(for: session.id, in: context)
        for taskID in session.linkedTaskIDs {
            context.insert(TaskSessionLinkRecord(taskID: taskID, sessionID: session.id))
        }

        try context.save()
    }

    func fetchAll() throws -> [SessionHistoryEntry] {
        let context = ModelContext(container)
        let sessions = try context.fetch(
            FetchDescriptor<SessionRecord>(sortBy: [SortDescriptor(\SessionRecord.startedAt)])
        )
        let links = try context.fetch(FetchDescriptor<TaskSessionLinkRecord>())
        let groupedLinks = Dictionary(grouping: links, by: \.sessionID)

        return sessions.map { record in
            SessionHistoryEntry(
                id: record.id,
                startedAt: record.startedAt,
                endedAt: record.endedAt,
                kind: SessionKind(rawValue: record.kindRawValue) ?? .focus,
                durationSeconds: record.durationSeconds,
                linkedTaskIDs: groupedLinks[record.id]?.map(\.taskID) ?? []
            )
        }
    }

    func saveSnapshot(_ snapshot: ActiveSessionSnapshot?) throws {
        let context = ModelContext(container)
        let existing = try context.fetch(FetchDescriptor<ActiveSessionSnapshotRecord>())

        for record in existing {
            context.delete(record)
        }

        if let snapshot {
            let payload = try encoder.encode(snapshot.linkedTaskIDs)
            let record = ActiveSessionSnapshotRecord(
                snapshotID: snapshot.snapshotID,
                phaseRawValue: snapshot.phase.rawValue,
                startedAt: snapshot.startedAt,
                remainingSeconds: snapshot.remainingSeconds,
                linkedTaskIDsData: payload
            )
            context.insert(record)
        }

        try context.save()
    }

    func loadSnapshot() throws -> ActiveSessionSnapshot? {
        let context = ModelContext(container)
        guard let record = try context.fetch(FetchDescriptor<ActiveSessionSnapshotRecord>()).first else {
            return nil
        }

        return ActiveSessionSnapshot(
            snapshotID: record.snapshotID,
            phase: ActiveSessionPhase(rawValue: record.phaseRawValue) ?? .focus,
            startedAt: record.startedAt,
            remainingSeconds: record.remainingSeconds,
            linkedTaskIDs: try decoder.decode([UUID].self, from: record.linkedTaskIDsData)
        )
    }

    private func fetchSessionRecord(id: UUID, in context: ModelContext) throws -> SessionRecord? {
        let descriptor = FetchDescriptor<SessionRecord>(
            predicate: #Predicate<SessionRecord> { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    private func removeLinks(for sessionID: UUID, in context: ModelContext) throws {
        let descriptor = FetchDescriptor<TaskSessionLinkRecord>(
            predicate: #Predicate<TaskSessionLinkRecord> { $0.sessionID == sessionID }
        )
        try context.fetch(descriptor).forEach(context.delete)
    }
}
