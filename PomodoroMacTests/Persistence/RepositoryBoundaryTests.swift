import Foundation
import XCTest
@testable import PomodoroMac

@MainActor
final class RepositoryBoundaryTests: XCTestCase {
    func testTaskAndSessionDataSurviveContainerRecreationAgainstSameStore() throws {
        let storeURL = temporaryStoreURL()
        let container = try ModelContainerFactory.makeContainer(storeURL: storeURL)
        let taskRepository = TaskRepository(container: container)
        let sessionRepository = SessionRepository(container: container)

        let taskID = UUID()
        try taskRepository.save(
            TaskItem(
                id: taskID,
                title: "Write spec",
                notes: "Draft Phase 1",
                priority: .high,
                isCompleted: false,
                createdAt: .now,
                completedAt: nil
            )
        )
        try taskRepository.markCompleted(taskID: taskID, completedAt: .now)
        try sessionRepository.save(
            SessionHistoryEntry(
                id: UUID(),
                startedAt: .now.addingTimeInterval(-1500),
                endedAt: .now,
                kind: .focus,
                durationSeconds: 1500,
                linkedTaskIDs: [taskID]
            )
        )

        let recreatedContainer = try ModelContainerFactory.makeContainer(storeURL: storeURL)
        let recreatedTaskRepository = TaskRepository(container: recreatedContainer)
        let recreatedSessionRepository = SessionRepository(container: recreatedContainer)

        let tasks = try recreatedTaskRepository.fetchAll()
        let completedTasks = try recreatedTaskRepository.fetchCompleted()
        let sessions = try recreatedSessionRepository.fetchAll()

        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Write spec")
        XCTAssertEqual(completedTasks.count, 1)
        XCTAssertEqual(completedTasks.first?.id, taskID)
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.linkedTaskIDs, [taskID])
    }

    func testSettingsDefaultsAreRegisteredAndRoundTrip() {
        let suiteName = "PomodoroMacTests.Settings.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = UserDefaultsSettingsStore(userDefaults: defaults)

        store.registerDefaults()
        XCTAssertEqual(store.load(), .default)

        var updated = AppSettings.default
        updated.workDurationMinutes = 45
        updated.autoStartBreaks = true
        store.save(updated)

        XCTAssertEqual(store.load(), updated)
    }

    private func temporaryStoreURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("store")
    }
}
