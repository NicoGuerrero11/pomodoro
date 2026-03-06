import Foundation
import SwiftData
import XCTest
@testable import PomodoroMac

final class ModelContainerFactoryTests: XCTestCase {
    func testDefaultStoreURLUsesApplicationSupportDirectory() throws {
        let fileManager = FileManager.default

        let url = try ModelContainerFactory.defaultStoreURL(fileManager: fileManager)

        XCTAssertTrue(url.path.contains("Application Support"))
        XCTAssertTrue(url.lastPathComponent.contains("PomodoroMac.store"))
    }

    func testCanCreateInMemoryContainer() throws {
        let container = try ModelContainerFactory.makeContainer(inMemory: true)
        let context = ModelContext(container)
        context.insert(TaskRecord(title: "Task", notes: "", priorityRawValue: TaskPriority.medium.rawValue))

        XCTAssertNoThrow(try context.save())
    }
}
