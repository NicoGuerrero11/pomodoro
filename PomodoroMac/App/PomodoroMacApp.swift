import SwiftUI

@main
struct PomodoroMacApp: App {
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            AppShellView(router: router)
                .frame(minWidth: 980, minHeight: 640)
        }
        .defaultSize(width: 1180, height: 760)
    }
}
