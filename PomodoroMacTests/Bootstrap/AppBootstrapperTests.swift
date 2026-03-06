import Foundation
import SwiftData
import XCTest
@testable import PomodoroMac

@MainActor
final class AppBootstrapperTests: XCTestCase {
    func testBootstrapBuildsEnvironmentFromProvidedLocalStores() {
        let storeURL = temporaryStoreURL()
        let suiteName = temporarySuiteName()
        resetDefaultsSuite(named: suiteName)
        let bootstrapper = makeBootstrapper(storeURL: storeURL, suiteName: suiteName)

        let state = bootstrapper.bootstrap()

        guard case .ready(let environment) = state else {
            return XCTFail("Expected bootstrap to succeed")
        }

        XCTAssertEqual(environment.storeURL, storeURL)
        XCTAssertEqual(environment.router.selectedSection, .dashboard)
        XCTAssertEqual(environment.settingsStore.load(), .default)
        XCTAssertEqual(environment.initialDashboardSnapshot, .empty)
        XCTAssertNil(environment.activeSessionSnapshot)
    }

    func testBootstrapFailureReturnsRecoverableState() {
        enum FixtureError: LocalizedError {
            case unreadableStore

            var errorDescription: String? {
                "Unreadable store"
            }
        }

        let bootstrapper = AppBootstrapper(
            storeURLProvider: { self.temporaryStoreURL() },
            containerBuilder: { _ in throw FixtureError.unreadableStore },
            settingsStoreBuilder: { UserDefaultsSettingsStore(userDefaults: self.makeDefaults()) }
        )

        let state = bootstrapper.bootstrap()

        guard case .failed(let failure) = state else {
            return XCTFail("Expected bootstrap to surface a recoverable failure")
        }

        XCTAssertEqual(failure.title, "Couldn't open local data")
        XCTAssertTrue(failure.message.contains("local bootstrap failed"))
        XCTAssertTrue(failure.recoverySuggestion.contains("Try again"))
        XCTAssertEqual(failure.technicalDetails, "Unreadable store")
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

    private func makeDefaults() -> UserDefaults {
        let suiteName = temporarySuiteName()
        resetDefaultsSuite(named: suiteName)
        let defaults = UserDefaults(suiteName: suiteName)!
        return defaults
    }

    private func resetDefaultsSuite(named suiteName: String) {
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
    }

    private func temporaryStoreURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("store")
    }

    private func temporarySuiteName() -> String {
        "PomodoroMacTests.Bootstrap.\(UUID().uuidString)"
    }
}
