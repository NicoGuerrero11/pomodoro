import Foundation
import SwiftData

enum TaskRepositoryError: Error, Equatable, Sendable {
    case taskNotFound(UUID)
}

@MainActor
protocol TaskRepositoryType: Sendable {
    func makeDraft() -> TaskDraft
    func createTask(from draft: TaskDraft) throws -> TaskItem
    func updateTask(id: UUID, with draft: TaskDraft) throws -> TaskItem
    func save(_ task: TaskItem) throws
    func fetchAll() throws -> [TaskItem]
    func fetchPending() throws -> [TaskItem]
    func fetchCompleted() throws -> [CompletedTask]
    func markCompleted(taskID: UUID, completedAt: Date) throws
}

@MainActor
final class TaskRepository: TaskRepositoryType {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func makeDraft() -> TaskDraft {
        TaskDraft()
    }

    func createTask(from draft: TaskDraft) throws -> TaskItem {
        let task = try TaskItem(draft: draft)
        try save(task)
        return task
    }

    func updateTask(id: UUID, with draft: TaskDraft) throws -> TaskItem {
        let context = ModelContext(container)
        guard let existing = try fetchTaskRecord(id: id, in: context) else {
            throw TaskRepositoryError.taskNotFound(id)
        }

        let updatedTask = try Self.mapTask(existing).updating(with: draft)
        Self.apply(updatedTask, to: existing)
        try context.save()
        return updatedTask
    }

    func save(_ task: TaskItem) throws {
        let validatedTask = try task.validated()
        let context = ModelContext(container)
        if let existing = try fetchTaskRecord(id: validatedTask.id, in: context) {
            Self.apply(validatedTask, to: existing)
        } else {
            let record = TaskRecord(
                id: validatedTask.id,
                title: validatedTask.title,
                notes: validatedTask.notes,
                priorityRawValue: validatedTask.priority.rawValue,
                createdAt: validatedTask.createdAt,
                isCompleted: validatedTask.isCompleted,
                completedAt: validatedTask.completedAt
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

    func fetchPending() throws -> [TaskItem] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TaskRecord>(
            predicate: #Predicate<TaskRecord> { $0.isCompleted == false },
            sortBy: [
                SortDescriptor(\TaskRecord.prioritySortOrder, order: .reverse),
                SortDescriptor(\TaskRecord.createdAt),
                SortDescriptor(\TaskRecord.id)
            ]
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

    private static func apply(_ task: TaskItem, to record: TaskRecord) {
        record.title = task.title
        record.notes = task.notes
        record.priorityRawValue = task.priority.rawValue
        record.prioritySortOrder = task.priority.sortOrder
        record.createdAt = task.createdAt
        record.isCompleted = task.isCompleted
        record.completedAt = task.completedAt
    }
}
