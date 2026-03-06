import Foundation
import Observation

@MainActor
@Observable
final class TasksFeatureModel {
    enum EditorState: Equatable {
        case empty
        case creating(previousSelection: UUID?)
        case editing(UUID)
    }

    private let taskRepository: any TaskRepositoryType

    private(set) var tasks: [TaskItem] = []
    private(set) var totalTaskCount = 0
    private(set) var selectedTaskID: UUID?
    private(set) var editorState: EditorState = .empty
    private(set) var errorMessage: String?
    private(set) var validationMessage: String?
    var draft: TaskDraft

    init(taskRepository: any TaskRepositoryType) {
        self.taskRepository = taskRepository
        self.draft = taskRepository.makeDraft()
        reloadTasks()
    }

    var hasTasks: Bool {
        tasks.isEmpty == false
    }

    var isCreatingTask: Bool {
        if case .creating = editorState {
            return true
        }

        return false
    }

    var isEditingTask: Bool {
        if case .editing = editorState {
            return true
        }

        return false
    }

    var selectedTask: TaskItem? {
        guard let selectedTaskID else {
            return nil
        }

        return tasks.first(where: { $0.id == selectedTaskID })
    }

    var showsFocusedEmptyState: Bool {
        tasks.isEmpty && editorState == .empty
    }

    var editorTitle: String {
        if isCreatingTask {
            return "New Task"
        }

        return "Task Details"
    }

    var saveButtonTitle: String {
        isCreatingTask ? "Save Task" : "Save Changes"
    }

    func refresh() {
        reloadTasks(preferredSelection: selectedTaskID)
    }

    func beginDashboardTaskCreation(using router: AppRouter) {
        router.selectedSection = .tasks
        beginCreatingTask()
    }

    func beginCreatingTask() {
        clearMessages()
        let previousSelection = selectedTaskID ?? tasks.first?.id
        draft = taskRepository.makeDraft()
        selectedTaskID = nil
        editorState = .creating(previousSelection: previousSelection)
    }

    func selectTask(id: UUID) {
        guard let task = tasks.first(where: { $0.id == id }) else {
            return
        }

        clearMessages()
        selectedTaskID = id
        draft = task.draft
        editorState = .editing(id)
    }

    func updateTitle(_ title: String) {
        draft.title = title
        validationMessage = nil
    }

    func updateNotes(_ notes: String) {
        draft.notes = notes
        validationMessage = nil
    }

    func updatePriority(_ priority: TaskPriority) {
        draft.priority = priority
        validationMessage = nil
    }

    @discardableResult
    func saveCurrentTask() -> Bool {
        clearMessages()

        do {
            switch editorState {
            case .creating:
                let createdTask = try taskRepository.createTask(from: draft)
                reloadTasks(preferredSelection: createdTask.id)
                return true
            case .editing(let taskID):
                let updatedTask = try taskRepository.updateTask(id: taskID, with: draft)
                reloadTasks(preferredSelection: updatedTask.id)
                return true
            case .empty:
                return false
            }
        } catch let error as TaskValidationError {
            validationMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = "Couldn't save your task."
            return false
        }
    }

    func cancelEditing() {
        clearMessages()

        switch editorState {
        case .creating(let previousSelection):
            if let previousSelection, tasks.contains(where: { $0.id == previousSelection }) {
                selectTask(id: previousSelection)
            } else if let firstTaskID = tasks.first?.id {
                selectTask(id: firstTaskID)
            } else {
                selectedTaskID = nil
                draft = taskRepository.makeDraft()
                editorState = .empty
            }
        case .editing(let taskID):
            if let task = tasks.first(where: { $0.id == taskID }) {
                selectedTaskID = taskID
                draft = task.draft
            } else {
                reloadTasks()
            }
        case .empty:
            return
        }
    }

    func dashboardSnapshot(from snapshot: DashboardSnapshot) -> DashboardSnapshot {
        var updatedSnapshot = snapshot
        updatedSnapshot.taskCount = totalTaskCount
        return updatedSnapshot
    }

    private func reloadTasks(preferredSelection: UUID? = nil) {
        do {
            tasks = try taskRepository.fetchPending()
            totalTaskCount = try taskRepository.fetchAll().count
            errorMessage = nil
            restoreEditorState(preferredSelection: preferredSelection)
        } catch {
            tasks = []
            totalTaskCount = 0
            selectedTaskID = nil
            editorState = .empty
            draft = taskRepository.makeDraft()
            errorMessage = "Couldn't load your tasks."
        }
    }

    private func restoreEditorState(preferredSelection: UUID?) {
        if let preferredSelection, tasks.contains(where: { $0.id == preferredSelection }) {
            selectTask(id: preferredSelection)
            return
        }

        switch editorState {
        case .creating:
            return
        case .editing(let taskID):
            if tasks.contains(where: { $0.id == taskID }) {
                selectTask(id: taskID)
            } else if let firstTaskID = tasks.first?.id {
                selectTask(id: firstTaskID)
            } else {
                selectedTaskID = nil
                editorState = .empty
                draft = taskRepository.makeDraft()
            }
        case .empty:
            if let firstTaskID = tasks.first?.id {
                selectTask(id: firstTaskID)
            } else {
                selectedTaskID = nil
                draft = taskRepository.makeDraft()
            }
        }
    }

    private func clearMessages() {
        errorMessage = nil
        validationMessage = nil
    }
}
