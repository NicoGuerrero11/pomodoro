import SwiftUI

struct AppShellView: View {
    @Bindable var router: AppRouter

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
            DashboardView()
        case .timer, .tasks, .statistics, .history, .settings:
            SectionPlaceholderView(section: section)
        }
    }
}

#Preview {
    AppShellView(router: AppRouter())
}
