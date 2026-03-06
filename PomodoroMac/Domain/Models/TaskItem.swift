import Foundation

enum TaskPriority: String, Codable, CaseIterable, Sendable {
    case low
    case medium
    case high

    var sortOrder: Int {
        switch self {
        case .low:
            return 0
        case .medium:
            return 1
        case .high:
            return 2
        }
    }
}

enum TaskValidationError: LocalizedError, Equatable, Sendable {
    case blankTitle

    var errorDescription: String? {
        switch self {
        case .blankTitle:
            return "Task title cannot be blank."
        }
    }
}

struct TaskDraft: Equatable, Sendable {
    var title: String
    var notes: String
    var priority: TaskPriority

    init(
        title: String = "",
        notes: String = "",
        priority: TaskPriority = .medium
    ) {
        self.title = title
        self.notes = notes
        self.priority = priority
    }

    init(task: TaskItem) {
        self.init(title: task.title, notes: task.notes, priority: task.priority)
    }

    func validated() throws -> ValidatedTaskDraft {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedTitle.isEmpty == false else {
            throw TaskValidationError.blankTitle
        }

        let normalizedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return ValidatedTaskDraft(
            title: normalizedTitle,
            notes: normalizedNotes,
            priority: priority
        )
    }
}

struct ValidatedTaskDraft: Equatable, Sendable {
    let title: String
    let notes: String
    let priority: TaskPriority
}

struct TaskItem: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var notes: String
    var priority: TaskPriority
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?

    init(
        id: UUID,
        title: String,
        notes: String,
        priority: TaskPriority,
        isCompleted: Bool,
        createdAt: Date,
        completedAt: Date?
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.priority = priority
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
    }

    init(
        id: UUID = UUID(),
        draft: TaskDraft,
        isCompleted: Bool = false,
        createdAt: Date = .now,
        completedAt: Date? = nil
    ) throws {
        let validatedDraft = try draft.validated()
        self.init(
            id: id,
            title: validatedDraft.title,
            notes: validatedDraft.notes,
            priority: validatedDraft.priority,
            isCompleted: isCompleted,
            createdAt: createdAt,
            completedAt: completedAt
        )
    }

    var draft: TaskDraft {
        TaskDraft(task: self)
    }

    func validated() throws -> TaskItem {
        let validatedDraft = try draft.validated()
        return TaskItem(
            id: id,
            title: validatedDraft.title,
            notes: validatedDraft.notes,
            priority: validatedDraft.priority,
            isCompleted: isCompleted,
            createdAt: createdAt,
            completedAt: completedAt
        )
    }

    func updating(with draft: TaskDraft) throws -> TaskItem {
        let validatedDraft = try draft.validated()
        return TaskItem(
            id: id,
            title: validatedDraft.title,
            notes: validatedDraft.notes,
            priority: validatedDraft.priority,
            isCompleted: isCompleted,
            createdAt: createdAt,
            completedAt: completedAt
        )
    }
}
