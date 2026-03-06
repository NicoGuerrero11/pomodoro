import Foundation
import XCTest
@testable import PomodoroMac

@MainActor
final class TaskRepositoryTests: XCTestCase {
    func testCreateTaskPersistsNormalizedFields() throws {
        let repository = try makeRepository()

        let created = try repository.createTask(
            from: TaskDraft(
                title: "  Write Phase 2 plan  ",
                notes: "  Capture repository rules  ",
                priority: .high
            )
        )

        let pendingTasks = try repository.fetchPending()

        XCTAssertEqual(created.title, "Write Phase 2 plan")
        XCTAssertEqual(created.notes, "Capture repository rules")
        XCTAssertEqual(created.priority, .high)
        XCTAssertEqual(pendingTasks.count, 1)
        XCTAssertEqual(pendingTasks.first?.id, created.id)
        XCTAssertEqual(pendingTasks.first?.title, "Write Phase 2 plan")
        XCTAssertEqual(pendingTasks.first?.notes, "Capture repository rules")
    }

    func testUpdateTaskMutatesExistingRecordWithoutCreatingDuplicate() throws {
        let repository = try makeRepository()
        let created = try repository.createTask(
            from: TaskDraft(
                title: "Draft workspace",
                notes: "Initial notes",
                priority: .medium
            )
        )

        let updated = try repository.updateTask(
            id: created.id,
            with: TaskDraft(
                title: "Ship workspace",
                notes: "Polish list and editor",
                priority: .high
            )
        )

        let allTasks = try repository.fetchAll()

        XCTAssertEqual(allTasks.count, 1)
        XCTAssertEqual(updated.id, created.id)
        XCTAssertEqual(updated.createdAt, created.createdAt)
        XCTAssertEqual(updated.title, "Ship workspace")
        XCTAssertEqual(updated.notes, "Polish list and editor")
        XCTAssertEqual(updated.priority, .high)
        XCTAssertEqual(allTasks.first, updated)
    }

    func testCreateTaskRejectsBlankTitle() throws {
        let repository = try makeRepository()

        XCTAssertThrowsError(
            try repository.createTask(
                from: TaskDraft(
                    title: " \n ",
                    notes: "Still invalid",
                    priority: .low
                )
            )
        ) { error in
            XCTAssertEqual(error as? TaskValidationError, .blankTitle)
        }

        XCTAssertTrue(try repository.fetchAll().isEmpty)
    }

    func testFetchPendingReturnsPriorityFirstOrderWithStableSecondarySort() throws {
        let repository = try makeRepository()
        let sharedCreatedAt = Date(timeIntervalSinceReferenceDate: 10_000)
        let olderHighID = UUID(uuidString: "00000000-0000-4000-8000-000000000001")!
        let newerHighID = UUID(uuidString: "00000000-0000-4000-8000-000000000002")!
        let mediumID = UUID(uuidString: "00000000-0000-4000-8000-000000000003")!
        let lowID = UUID(uuidString: "00000000-0000-4000-8000-000000000004")!
        let completedHighID = UUID(uuidString: "00000000-0000-4000-8000-000000000005")!

        try repository.save(
            TaskItem(
                id: newerHighID,
                title: "Newer high",
                notes: "",
                priority: .high,
                isCompleted: false,
                createdAt: sharedCreatedAt,
                completedAt: nil
            )
        )
        try repository.save(
            TaskItem(
                id: olderHighID,
                title: "Older high",
                notes: "",
                priority: .high,
                isCompleted: false,
                createdAt: sharedCreatedAt,
                completedAt: nil
            )
        )
        try repository.save(
            TaskItem(
                id: mediumID,
                title: "Medium",
                notes: "",
                priority: .medium,
                isCompleted: false,
                createdAt: sharedCreatedAt.addingTimeInterval(-60),
                completedAt: nil
            )
        )
        try repository.save(
            TaskItem(
                id: lowID,
                title: "Low",
                notes: "",
                priority: .low,
                isCompleted: false,
                createdAt: sharedCreatedAt.addingTimeInterval(-120),
                completedAt: nil
            )
        )
        try repository.save(
            TaskItem(
                id: completedHighID,
                title: "Completed high",
                notes: "",
                priority: .high,
                isCompleted: false,
                createdAt: sharedCreatedAt.addingTimeInterval(-180),
                completedAt: nil
            )
        )
        try repository.markCompleted(
            taskID: completedHighID,
            completedAt: sharedCreatedAt.addingTimeInterval(300)
        )

        let pendingTasks = try repository.fetchPending()

        XCTAssertEqual(
            pendingTasks.map(\.id),
            [olderHighID, newerHighID, mediumID, lowID]
        )
    }

    private func makeRepository() throws -> TaskRepository {
        TaskRepository(container: try ModelContainerFactory.makeContainer(inMemory: true))
    }
}
