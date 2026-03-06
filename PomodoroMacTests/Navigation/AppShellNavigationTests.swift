import XCTest
@testable import PomodoroMac

final class AppShellNavigationTests: XCTestCase {
    func testDashboardIsTheDefaultRoute() {
        let router = AppRouter()

        XCTAssertEqual(router.selectedSection, .dashboard)
    }

    func testSidebarContainsAllRequiredSectionsInRoadmapOrder() {
        XCTAssertEqual(
            AppSection.allCases,
            [.dashboard, .timer, .tasks, .statistics, .history, .settings]
        )
    }

    func testNonDashboardSectionsExposeRealPlaceholderCopy() {
        for section in AppSection.allCases where section != .dashboard {
            XCTAssertFalse(section.placeholderTitle.isEmpty)
            XCTAssertFalse(section.placeholderMessage.isEmpty)
        }
    }
}
