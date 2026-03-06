import Foundation
import SwiftData

struct AppBootstrapper {
    typealias StoreURLProvider = () throws -> URL
    typealias ContainerBuilder = (URL) throws -> ModelContainer
    typealias SettingsStoreBuilder = () -> any AppSettingsStore
    typealias RouterBuilder = () -> AppRouter

    private let storeURLProvider: StoreURLProvider
    private let containerBuilder: ContainerBuilder
    private let settingsStoreBuilder: SettingsStoreBuilder
    private let routerBuilder: RouterBuilder
    private let diagnostics: BootstrapDiagnostics

    init(
        storeURLProvider: @escaping StoreURLProvider = { try ModelContainerFactory.defaultStoreURL() },
        containerBuilder: @escaping ContainerBuilder = { try ModelContainerFactory.makeContainer(storeURL: $0) },
        settingsStoreBuilder: @escaping SettingsStoreBuilder = { UserDefaultsSettingsStore() },
        routerBuilder: @escaping RouterBuilder = { AppRouter() },
        diagnostics: BootstrapDiagnostics = BootstrapDiagnostics()
    ) {
        self.storeURLProvider = storeURLProvider
        self.containerBuilder = containerBuilder
        self.settingsStoreBuilder = settingsStoreBuilder
        self.routerBuilder = routerBuilder
        self.diagnostics = diagnostics
    }

    @MainActor
    func bootstrap() -> BootstrapState {
        diagnostics.recordBootstrapStart()

        do {
            return .ready(try makeEnvironment())
        } catch {
            diagnostics.recordBootstrapFailure(error)
            return .failed(
                BootstrapFailure(
                    title: "Couldn't open local data",
                    message: "Pomodoro only starts from files stored on this Mac, and that local bootstrap failed.",
                    recoverySuggestion: "Try again. If the issue continues, relaunch the app after checking disk access for Application Support.",
                    technicalDetails: error.localizedDescription
                )
            )
        }
    }

    @MainActor
    func makeEnvironment() throws -> AppEnvironment {
        let settingsStore = settingsStoreBuilder()
        settingsStore.registerDefaults()

        let storeURL = try storeURLProvider()
        let container = try containerBuilder(storeURL)
        let taskRepository = TaskRepository(container: container)
        let sessionRepository = SessionRepository(container: container)
        let productivityRepository = ProductivityRepository(container: container)
        let activeSessionSnapshot = try sessionRepository.loadSnapshot()
        let dashboardSnapshot = try productivityRepository.fetchDashboardSnapshot()

        diagnostics.recordBootstrapReady(
            storeURL: storeURL,
            restoredSnapshot: activeSessionSnapshot != nil
        )

        return AppEnvironment(
            router: routerBuilder(),
            taskRepository: taskRepository,
            sessionRepository: sessionRepository,
            productivityRepository: productivityRepository,
            settingsStore: settingsStore,
            activeSessionSnapshot: activeSessionSnapshot,
            initialDashboardSnapshot: dashboardSnapshot,
            storeURL: storeURL
        )
    }
}
