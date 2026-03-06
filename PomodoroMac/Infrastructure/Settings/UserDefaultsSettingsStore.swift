import Foundation

struct UserDefaultsSettingsStore: AppSettingsStore {
    private enum Keys {
        static let workDurationMinutes = "settings.workDurationMinutes"
        static let shortBreakMinutes = "settings.shortBreakMinutes"
        static let longBreakMinutes = "settings.longBreakMinutes"
        static let autoStartBreaks = "settings.autoStartBreaks"
        static let autoStartFocus = "settings.autoStartFocus"
        static let dashboardChecklistDismissed = "settings.dashboardChecklistDismissed"
    }

    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func registerDefaults() {
        userDefaults.register(defaults: [
            Keys.workDurationMinutes: AppSettings.default.workDurationMinutes,
            Keys.shortBreakMinutes: AppSettings.default.shortBreakMinutes,
            Keys.longBreakMinutes: AppSettings.default.longBreakMinutes,
            Keys.autoStartBreaks: AppSettings.default.autoStartBreaks,
            Keys.autoStartFocus: AppSettings.default.autoStartFocus,
            Keys.dashboardChecklistDismissed: AppSettings.default.dashboardChecklistDismissed
        ])
    }

    func load() -> AppSettings {
        AppSettings(
            workDurationMinutes: userDefaults.integer(forKey: Keys.workDurationMinutes),
            shortBreakMinutes: userDefaults.integer(forKey: Keys.shortBreakMinutes),
            longBreakMinutes: userDefaults.integer(forKey: Keys.longBreakMinutes),
            autoStartBreaks: userDefaults.bool(forKey: Keys.autoStartBreaks),
            autoStartFocus: userDefaults.bool(forKey: Keys.autoStartFocus),
            dashboardChecklistDismissed: userDefaults.bool(forKey: Keys.dashboardChecklistDismissed)
        )
    }

    func save(_ settings: AppSettings) {
        userDefaults.set(settings.workDurationMinutes, forKey: Keys.workDurationMinutes)
        userDefaults.set(settings.shortBreakMinutes, forKey: Keys.shortBreakMinutes)
        userDefaults.set(settings.longBreakMinutes, forKey: Keys.longBreakMinutes)
        userDefaults.set(settings.autoStartBreaks, forKey: Keys.autoStartBreaks)
        userDefaults.set(settings.autoStartFocus, forKey: Keys.autoStartFocus)
        userDefaults.set(settings.dashboardChecklistDismissed, forKey: Keys.dashboardChecklistDismissed)
    }
}
