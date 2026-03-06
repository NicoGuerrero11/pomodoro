import Foundation
import SwiftData

enum ModelContainerFactory {
    static let schema = Schema([
        TaskRecord.self,
        SessionRecord.self,
        TaskSessionLinkRecord.self,
        ActiveSessionSnapshotRecord.self
    ])

    static func defaultStoreURL(fileManager: FileManager = .default) throws -> URL {
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = appSupport.appendingPathComponent("PomodoroMac", isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("PomodoroMac.store")
    }

    static func makeContainer(inMemory: Bool = false, storeURL: URL? = nil) throws -> ModelContainer {
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else if let storeURL {
            configuration = ModelConfiguration(schema: schema, url: storeURL)
        } else {
            configuration = ModelConfiguration(schema: schema)
        }

        return try ModelContainer(for: schema, configurations: configuration)
    }
}
