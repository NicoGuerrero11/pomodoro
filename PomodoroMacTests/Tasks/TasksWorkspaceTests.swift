import XCTest
@testable import PomodoroMac

@MainActor
final class TasksWorkspaceTests: XCTestCase {
    func testEmptyStateCreationFlowStartsBlankDraft() throws {
        let repository = try makeRepository()
        let model = TasksFeatureModel(taskRepository: repository)

        XCTAssertTrue(model.showsFocusedEmptyState)

        model.beginCreatingTask()

        XCTAssertTrue(model.isCreatingTask)
        XCTAssertFalse(model.showsFocusedEmptyState)
        XCTAssertNil(model.selectedTaskID)
        XCTAssertEqual(model.draft, TaskDraft())
    }

    func testDashboardHandoffRoutesToTasksAndStartsBlankDraft() throws {
        let repository = try makeRepository()
        let model = TasksFeatureModel(taskRepository: repository)
        let router = AppRouter()

        model.beginDashboardTaskCreation(using: router)

        XCTAssertEqual(router.selectedSection, .tasks)
        XCTAssertTrue(model.isCreatingTask)
        XCTAssertEqual(model.draft, TaskDraft())
    }

    func testSelectingExistingTaskLoadsEditableDraftFromPriorityOrderedTasks() throws {
        let repository = try makeRepository()
        let lowTask = try repository.createTask(
            from: TaskDraft(
                title: "Inbox cleanup",
                notes: "Trim older backlog items",
                priority: .low
            )
        )
        let highTask = try repository.createTask(
            from: TaskDraft(
                title: "Ship task workspace",
                notes: "Keep the first-task flow tight",
                priority: .high
            )
        )

        let model = TasksFeatureModel(taskRepository: repository)

        XCTAssertEqual(model.tasks.map(\.id), [highTask.id, lowTask.id])

        model.selectTask(id: lowTask.id)

        XCTAssertTrue(model.isEditingTask)
        XCTAssertEqual(model.selectedTaskID, lowTask.id)
        XCTAssertEqual(model.draft, lowTask.draft)
    }

    func testCancellingNewTaskDiscardsDraftWithoutPersisting() throws {
        let repository = try makeRepository()
        let model = TasksFeatureModel(taskRepository: repository)

        model.beginCreatingTask()
        model.updateTitle("Write release notes")
        model.updateNotes("Summarize the Tasks rollout")
        model.updatePriority(.high)

        model.cancelEditing()

        XCTAssertTrue(model.showsFocusedEmptyState)
        XCTAssertTrue(try repository.fetchAll().isEmpty)
    }

    func testEditingRequiresExplicitSaveBeforeRepositoryChanges() throws {
        let repository = try makeRepository()
        let createdTask = try repository.createTask(
            from: TaskDraft(
                title: "Draft workspace",
                notes: "Initial notes",
                priority: .medium
            )
        )
        let model = TasksFeatureModel(taskRepository: repository)

        model.selectTask(id: createdTask.id)
        model.updateTitle("Unsaved title")
        model.updateNotes("Unsaved notes")
        model.updatePriority(.high)
        model.cancelEditing()

        var persistedTask = try XCTUnwrap(repository.fetchPending().first)
        XCTAssertEqual(persistedTask.title, "Draft workspace")
        XCTAssertEqual(persistedTask.notes, "Initial notes")
        XCTAssertEqual(persistedTask.priority, .medium)
        XCTAssertEqual(model.draft, createdTask.draft)

        model.updateTitle("Saved title")
        model.updateNotes("Saved notes")
        model.updatePriority(.high)

        XCTAssertTrue(model.saveCurrentTask())

        persistedTask = try XCTUnwrap(repository.fetchPending().first)
        XCTAssertEqual(persistedTask.title, "Saved title")
        XCTAssertEqual(persistedTask.notes, "Saved notes")
        XCTAssertEqual(persistedTask.priority, .high)
        XCTAssertEqual(model.selectedTaskID, createdTask.id)
        XCTAssertEqual(model.draft, persistedTask.draft)
    }

    private func makeRepository() throws -> TaskRepository {
        TaskRepository(container: try ModelContainerFactory.makeContainer(inMemory: true))
    }
}
