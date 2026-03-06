import Foundation
import OSLog

struct BootstrapDiagnostics {
    private let logger: Logger

    init(
        subsystem: String = "pomodoro.PomodoroMac",
        category: String = "Bootstrap"
    ) {
        logger = Logger(subsystem: subsystem, category: category)
    }

    func recordBootstrapStart() {
        logger.notice("Starting local bootstrap pipeline.")
    }

    func recordBootstrapReady(storeURL: URL, restoredSnapshot: Bool) {
        logger.notice(
            "Local bootstrap ready. store=\(storeURL.path, privacy: .public) restoredSnapshot=\(restoredSnapshot, privacy: .public)"
        )
    }

    func recordBootstrapFailure(_ error: Error) {
        logger.error("Local bootstrap failed: \(error.localizedDescription, privacy: .public)")
    }
}
