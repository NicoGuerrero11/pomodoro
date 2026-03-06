import SwiftUI

struct AppShellView: View {
    @Bindable var router: AppRouter
    var environment: AppEnvironment? = nil
    @State private var tasksFeatureModel: TasksFeatureModel?

    init(router: AppRouter, environment: AppEnvironment? = nil) {
        self.router = router
        self.environment = environment
        _tasksFeatureModel = State(
            initialValue: environment.map { TasksFeatureModel(taskRepository: $0.taskRepository) }
        )
    }

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $router.selectedSection) { section in
                SidebarRowLabel(section: section)
                    .tag(section)
            }
            .navigationTitle("Pomodoro")
            .listStyle(.sidebar)
        } detail: {
            detailView(for: router.selectedSection)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
        }
    }

    @ViewBuilder
    private func detailView(for section: AppSection) -> some View {
        switch section {
        case .dashboard:
            DashboardView(
                snapshot: dashboardSnapshot,
                activeSessionSnapshot: environment?.activeSessionSnapshot,
                onCreateFirstTask: beginDashboardTaskCreation
            )
        case .tasks:
            if let tasksFeatureModel {
                TasksWorkspaceView(model: tasksFeatureModel)
            } else {
                SectionPlaceholderView(section: section)
            }
        case .timer, .statistics, .history, .settings:
            SectionPlaceholderView(section: section)
        }
    }

    private var dashboardSnapshot: DashboardSnapshot {
        guard
            let environment,
            let tasksFeatureModel
        else {
            return environment?.initialDashboardSnapshot ?? .empty
        }

        return tasksFeatureModel.dashboardSnapshot(from: environment.initialDashboardSnapshot)
    }

    private func beginDashboardTaskCreation() {
        guard let tasksFeatureModel else {
            router.selectedSection = .tasks
            return
        }

        tasksFeatureModel.beginDashboardTaskCreation(using: router)
    }
}

#Preview {
    AppShellView(router: AppRouter(), environment: nil)
}
