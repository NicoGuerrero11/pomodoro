import Foundation

struct AppSettings: Equatable, Sendable {
    var workDurationMinutes: Int
    var shortBreakMinutes: Int
    var longBreakMinutes: Int
    var autoStartBreaks: Bool
    var autoStartFocus: Bool
    var dashboardChecklistDismissed: Bool

    static let `default` = AppSettings(
        workDurationMinutes: 25,
        shortBreakMinutes: 5,
        longBreakMinutes: 20,
        autoStartBreaks: false,
        autoStartFocus: false,
        dashboardChecklistDismissed: false
    )
}

protocol AppSettingsStore {
    func registerDefaults()
    func load() -> AppSettings
    func save(_ settings: AppSettings)
}
