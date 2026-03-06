import SwiftUI

struct DashboardView: View {
    private let checklistItems = [
        "Create your first task",
        "Start your first focus session",
        "Come back later to review real progress"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroCard

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 220), spacing: 16),
                        GridItem(.flexible(minimum: 220), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    emptyMetricCard(
                        title: "Today",
                        value: "0 sessions",
                        detail: "No focus sessions recorded yet."
                    )
                    emptyMetricCard(
                        title: "Focus time",
                        value: "0 min",
                        detail: "Time appears here after your first real session."
                    )
                    emptyMetricCard(
                        title: "Completed tasks",
                        value: "0",
                        detail: "Finished work will show up here once tasks exist."
                    )
                    emptyMetricCard(
                        title: "Recent pattern",
                        value: "No pattern yet",
                        detail: "Productivity trends show up only after real usage."
                    )
                }
            }
            .padding(28)
        }
        .navigationTitle("Dashboard")
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ready for your next focus block")
                .font(.system(size: 28, weight: .semibold))

            Text("Start with one task, then let the app grow into real history and patterns as you use it.")
                .font(.body)
                .foregroundStyle(.secondary)

            Button("Create First Task") {}
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("Start here")
                    .font(.headline)

                ForEach(Array(checklistItems.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1).")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text(item)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.96, green: 0.97, blue: 0.94),
                            Color(red: 0.92, green: 0.95, blue: 0.98)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func emptyMetricCard(title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.system(size: 22, weight: .semibold))
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 148, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    DashboardView()
}
