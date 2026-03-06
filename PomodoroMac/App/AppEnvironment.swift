import Foundation

@MainActor
final class AppEnvironment {
    let router: AppRouter
    let taskRepository: any TaskRepositoryType
    let sessionRepository: any SessionRepositoryType
    let productivityRepository: any ProductivityRepositoryType
    let settingsStore: any AppSettingsStore
    let activeSessionSnapshot: ActiveSessionSnapshot?
    let initialDashboardSnapshot: DashboardSnapshot
    let storeURL: URL

    init(
        router: AppRouter,
        taskRepository: any TaskRepositoryType,
        sessionRepository: any SessionRepositoryType,
        productivityRepository: any ProductivityRepositoryType,
        settingsStore: any AppSettingsStore,
        activeSessionSnapshot: ActiveSessionSnapshot?,
        initialDashboardSnapshot: DashboardSnapshot,
        storeURL: URL
    ) {
        self.router = router
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
        self.productivityRepository = productivityRepository
        self.settingsStore = settingsStore
        self.activeSessionSnapshot = activeSessionSnapshot
        self.initialDashboardSnapshot = initialDashboardSnapshot
        self.storeURL = storeURL
    }
}
