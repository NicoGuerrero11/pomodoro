import Foundation
import XCTest
@testable import PomodoroMac

@MainActor
final class RelaunchRecoveryTests: XCTestCase {
    func testBootstrapLoadsPersistedActiveSessionSnapshot() throws {
        let storeURL = temporaryStoreURL()
        let suiteName = temporarySuiteName()
        resetDefaultsSuite(named: suiteName)
        let bootstrapper = makeBootstrapper(storeURL: storeURL, suiteName: suiteName)

        guard case .ready(let environment) = bootstrapper.bootstrap() else {
            return XCTFail("Expected initial bootstrap to succeed")
        }

        let snapshot = ActiveSessionSnapshot(
            snapshotID: UUID(),
            phase: .focus,
            startedAt: .now.addingTimeInterval(-600),
            remainingSeconds: 900,
            linkedTaskIDs: [UUID()]
        )
        try environment.sessionRepository.saveSnapshot(snapshot)

        let relaunchedBootstrapper = makeBootstrapper(storeURL: storeURL, suiteName: suiteName)
        guard case .ready(let relaunchedEnvironment) = relaunchedBootstrapper.bootstrap() else {
            return XCTFail("Expected relaunch bootstrap to succeed")
        }

        XCTAssertEqual(relaunchedEnvironment.activeSessionSnapshot, snapshot)
    }

    func testRepresentativeUserDataSurvivesFullBootstrapRecreation() throws {
        let storeURL = temporaryStoreURL()
        let suiteName = temporarySuiteName()
        resetDefaultsSuite(named: suiteName)
        let bootstrapper = makeBootstrapper(storeURL: storeURL, suiteName: suiteName)

        guard case .ready(let environment) = bootstrapper.bootstrap() else {
            return XCTFail("Expected initial bootstrap to succeed")
        }

        let taskID = UUID()
        let sessionID = UUID()
        try environment.taskRepository.save(
            TaskItem(
                id: taskID,
                title: "Ship Phase 1",
                notes: "Finish the bootstrap pipeline",
                priority: .high,
                isCompleted: false,
                createdAt: .now,
                completedAt: nil
            )
        )
        try environment.taskRepository.markCompleted(taskID: taskID, completedAt: .now)
        try environment.sessionRepository.save(
            SessionHistoryEntry(
                id: sessionID,
                startedAt: .now.addingTimeInterval(-1500),
                endedAt: .now,
                kind: .focus,
                durationSeconds: 1500,
                linkedTaskIDs: [taskID]
            )
        )

        var updatedSettings = environment.settingsStore.load()
        updatedSettings.workDurationMinutes = 45
        updatedSettings.autoStartFocus = true
        environment.settingsStore.save(updatedSettings)

        let snapshot = ActiveSessionSnapshot(
            snapshotID: UUID(),
            phase: .shortBreak,
            startedAt: .now.addingTimeInterval(-120),
            remainingSeconds: 180,
            linkedTaskIDs: [taskID]
        )
        try environment.sessionRepository.saveSnapshot(snapshot)

        let relaunchedBootstrapper = makeBootstrapper(storeURL: storeURL, suiteName: suiteName)
        guard case .ready(let relaunchedEnvironment) = relaunchedBootstrapper.bootstrap() else {
            return XCTFail("Expected relaunch bootstrap to succeed")
        }

        XCTAssertEqual(relaunchedEnvironment.settingsStore.load(), updatedSettings)
        XCTAssertEqual(relaunchedEnvironment.initialDashboardSnapshot.taskCount, 1)
        XCTAssertEqual(relaunchedEnvironment.initialDashboardSnapshot.completedTaskCount, 1)
        XCTAssertEqual(relaunchedEnvironment.initialDashboardSnapshot.sessionCount, 1)
        XCTAssertEqual(relaunchedEnvironment.activeSessionSnapshot, snapshot)
    }

    private func makeBootstrapper(storeURL: URL, suiteName: String) -> AppBootstrapper {
        AppBootstrapper(
            storeURLProvider: { storeURL },
            containerBuilder: { try ModelContainerFactory.makeContainer(storeURL: $0) },
            settingsStoreBuilder: {
                let defaults = UserDefaults(suiteName: suiteName)!
                return UserDefaultsSettingsStore(userDefaults: defaults)
            }
        )
    }

    private func temporaryStoreURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("store")
    }

    private func temporarySuiteName() -> String {
        "PomodoroMacTests.Relaunch.\(UUID().uuidString)"
    }

    private func resetDefaultsSuite(named suiteName: String) {
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
    }
}
