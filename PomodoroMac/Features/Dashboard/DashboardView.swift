import SwiftUI

struct DashboardView: View {
    let snapshot: DashboardSnapshot
    let activeSessionSnapshot: ActiveSessionSnapshot?
    var onCreateFirstTask: () -> Void = {}

    private let checklistItems = [
        "Create your first task",
        "Start your first focus session",
        "Come back later to review real progress"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroCard

                if let activeSessionSnapshot {
                    recoveryCard(snapshot: activeSessionSnapshot)
                }

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 220), spacing: 16),
                        GridItem(.flexible(minimum: 220), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    metricCard(
                        title: "Tasks",
                        value: "\(snapshot.taskCount)",
                        detail: snapshot.taskCount == 0
                            ? "No tasks saved yet."
                            : "\(snapshot.taskCount) task\(snapshot.taskCount == 1 ? "" : "s") stored locally."
                    )
                    metricCard(
                        title: "Completed tasks",
                        value: "\(snapshot.completedTaskCount)",
                        detail: snapshot.completedTaskCount == 0
                            ? "Finished work appears here once you complete a task."
                            : "\(snapshot.completedTaskCount) completed task\(snapshot.completedTaskCount == 1 ? "" : "s") are persisted."
                    )
                    metricCard(
                        title: "Sessions logged",
                        value: "\(snapshot.sessionCount)",
                        detail: snapshot.sessionCount == 0
                            ? "No focus sessions recorded yet."
                            : "\(snapshot.sessionCount) session\(snapshot.sessionCount == 1 ? "" : "s") survived the latest launch."
                    )
                    metricCard(
                        title: "Relaunch status",
                        value: activeSessionSnapshot == nil ? "Clean launch" : "Snapshot found",
                        detail: activeSessionSnapshot == nil
                            ? "No unfinished session needed recovery on startup."
                            : "An unfinished session snapshot is ready for a later recovery UI."
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

            Text("Start with one task, then let the app grow into real history and patterns as local data accumulates on this Mac.")
                .font(.body)
                .foregroundStyle(.secondary)

            if snapshot.taskCount == 0 {
                Button("Create First Task", action: onCreateFirstTask)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            } else {
                Label("Local data loaded successfully", systemImage: "externaldrive.badge.checkmark")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

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

    private func recoveryCard(snapshot: ActiveSessionSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Relaunch foundation is active")
                .font(.headline)
            Text("\(phaseLabel(for: snapshot.phase)) session snapshot found")
                .font(.title3.weight(.semibold))
            Text("Recovery UI ships in a later phase, but the unfinished session state is already being preserved across launches.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.95, green: 0.97, blue: 0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private func metricCard(title: String, value: String, detail: String) -> some View {
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

    private func phaseLabel(for phase: ActiveSessionPhase) -> String {
        switch phase {
        case .focus:
            "Focus"
        case .shortBreak:
            "Short break"
        case .longBreak:
            "Long break"
        }
    }
}

#Preview {
    DashboardView(snapshot: .empty, activeSessionSnapshot: nil)
}
