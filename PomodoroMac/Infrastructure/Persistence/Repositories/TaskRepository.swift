import Foundation
import SwiftData

@MainActor
protocol TaskRepositoryType: Sendable {
    func save(_ task: TaskItem) throws
    func fetchAll() throws -> [TaskItem]
    func fetchCompleted() throws -> [CompletedTask]
    func markCompleted(taskID: UUID, completedAt: Date) throws
}

@MainActor
final class TaskRepository: TaskRepositoryType {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func save(_ task: TaskItem) throws {
        let context = ModelContext(container)
        if let existing = try fetchTaskRecord(id: task.id, in: context) {
            existing.title = task.title
            existing.notes = task.notes
            existing.priorityRawValue = task.priority.rawValue
            existing.isCompleted = task.isCompleted
            existing.completedAt = task.completedAt
        } else {
            let record = TaskRecord(
                id: task.id,
                title: task.title,
                notes: task.notes,
                priorityRawValue: task.priority.rawValue,
                createdAt: task.createdAt,
                isCompleted: task.isCompleted,
                completedAt: task.completedAt
            )
            context.insert(record)
        }

        try context.save()
    }

    func fetchAll() throws -> [TaskItem] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TaskRecord>(
            sortBy: [SortDescriptor(\TaskRecord.createdAt)]
        )
        return try context.fetch(descriptor).map(Self.mapTask)
    }

    func fetchCompleted() throws -> [CompletedTask] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TaskRecord>(
            predicate: #Predicate<TaskRecord> { $0.isCompleted == true },
            sortBy: [SortDescriptor(\TaskRecord.completedAt, order: .reverse)]
        )

        return try context.fetch(descriptor).compactMap { record in
            guard let completedAt = record.completedAt else { return nil }
            return CompletedTask(id: record.id, title: record.title, completedAt: completedAt)
        }
    }

    func markCompleted(taskID: UUID, completedAt: Date) throws {
        let context = ModelContext(container)
        guard let record = try fetchTaskRecord(id: taskID, in: context) else {
            return
        }

        record.isCompleted = true
        record.completedAt = completedAt
        try context.save()
    }

    private func fetchTaskRecord(id: UUID, in context: ModelContext) throws -> TaskRecord? {
        let descriptor = FetchDescriptor<TaskRecord>(
            predicate: #Predicate<TaskRecord> { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    private static func mapTask(_ record: TaskRecord) -> TaskItem {
        TaskItem(
            id: record.id,
            title: record.title,
            notes: record.notes,
            priority: TaskPriority(rawValue: record.priorityRawValue) ?? .medium,
            isCompleted: record.isCompleted,
            createdAt: record.createdAt,
            completedAt: record.completedAt
        )
    }
}
