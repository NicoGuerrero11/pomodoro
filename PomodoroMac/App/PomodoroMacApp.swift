import SwiftUI

@main
struct PomodoroMacApp: App {
    var body: some Scene {
        WindowGroup {
            BootstrapRootView(bootstrapper: AppBootstrapper())
                .frame(minWidth: 980, minHeight: 640)
        }
        .defaultSize(width: 1180, height: 760)
    }
}
