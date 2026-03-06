import SwiftUI

struct SectionPlaceholderView: View {
    let section: AppSection

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: section.systemImage)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.secondary)

            Text(section.placeholderTitle)
                .font(.system(size: 26, weight: .semibold))

            Text(section.placeholderMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 520, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(32)
        .navigationTitle(section.title)
    }
}

#Preview {
    SectionPlaceholderView(section: .tasks)
}
