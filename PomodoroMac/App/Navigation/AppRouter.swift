import Observation

@Observable
final class AppRouter {
    var selectedSection: AppSection

    init(selectedSection: AppSection = .dashboard) {
        self.selectedSection = selectedSection
    }
}
