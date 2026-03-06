import Foundation

enum AppSection: String, CaseIterable, Identifiable, Codable {
    case dashboard
    case timer
    case tasks
    case statistics
    case history
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .timer: "Timer"
        case .tasks: "Tasks"
        case .statistics: "Statistics"
        case .history: "History"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "gauge.with.dots.needle.50percent"
        case .timer: "timer"
        case .tasks: "checklist"
        case .statistics: "chart.xyaxis.line"
        case .history: "clock.arrow.circlepath"
        case .settings: "slider.horizontal.3"
        }
    }

    var placeholderTitle: String {
        switch self {
        case .dashboard:
            title
        case .timer:
            "Timer is next"
        case .tasks:
            "Tasks are next"
        case .statistics:
            "Statistics will grow here"
        case .history:
            "History will appear here"
        case .settings:
            "Settings will live here"
        }
    }

    var placeholderMessage: String {
        switch self {
        case .dashboard:
            "Dashboard is the home screen."
        case .timer:
            "This section will host the focus timer once the core timer phase is built."
        case .tasks:
            "This section will show your task list, priorities, and task editing flow."
        case .statistics:
            "This section will become the visual productivity view once session data exists."
        case .history:
            "This section will show past focus sessions, breaks, and task outcomes."
        case .settings:
            "This section will hold timer preferences and app behavior controls inside the main shell."
        }
    }
}
