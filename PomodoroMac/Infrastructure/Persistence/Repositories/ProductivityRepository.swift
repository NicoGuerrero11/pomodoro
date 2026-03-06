import Foundation
import SwiftData

struct DashboardSnapshot: Equatable, Sendable {
    var taskCount: Int
    var completedTaskCount: Int
    var sessionCount: Int

    static let empty = DashboardSnapshot(
        taskCount: 0,
        completedTaskCount: 0,
        sessionCount: 0
    )
}

@MainActor
protocol ProductivityRepositoryType: Sendable {
    func fetchDashboardSnapshot() throws -> DashboardSnapshot
}

@MainActor
final class ProductivityRepository: ProductivityRepositoryType {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func fetchDashboardSnapshot() throws -> DashboardSnapshot {
        let context = ModelContext(container)
        let tasks = try context.fetch(FetchDescriptor<TaskRecord>())
        let sessions = try context.fetch(FetchDescriptor<SessionRecord>())

        return DashboardSnapshot(
            taskCount: tasks.count,
            completedTaskCount: tasks.filter(\.isCompleted).count,
            sessionCount: sessions.count
        )
    }
}
