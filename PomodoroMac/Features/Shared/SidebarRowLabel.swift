import SwiftUI

struct SidebarRowLabel: View {
    let section: AppSection

    var body: some View {
        Label(section.title, systemImage: section.systemImage)
    }
}

#Preview {
    SidebarRowLabel(section: .dashboard)
        .padding()
}
