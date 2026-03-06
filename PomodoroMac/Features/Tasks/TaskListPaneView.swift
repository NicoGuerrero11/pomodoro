import SwiftUI

struct TaskListPaneView: View {
    @Bindable var model: TasksFeatureModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pending Tasks")
                        .font(.title3.weight(.semibold))
                    Text("\(model.tasks.count) task\(model.tasks.count == 1 ? "" : "s") in priority order")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)

            Divider()

            List(selection: selectionBinding) {
                ForEach(model.tasks) { task in
                    TaskRowView(
                        task: task,
                        isSelected: model.selectedTaskID == task.id
                    )
                    .tag(task.id)
                }
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))
        }
        .frame(minWidth: 280, idealWidth: 320)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

private extension TaskListPaneView {
    var selectionBinding: Binding<UUID?> {
        Binding(
            get: { model.selectedTaskID },
            set: { newValue in
                guard let newValue else {
                    return
                }

                model.selectTask(id: newValue)
            }
        )
    }
}

private struct TaskRowView: View {
    let task: TaskItem
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(task.title)
                    .font(.headline)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text(task.priority.badgeLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(task.priority.badgeColor.opacity(isSelected ? 0.3 : 0.16))
                    .clipShape(Capsule())
            }

            Text(task.notesPreview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 6)
    }
}

private extension TaskItem {
    var notesPreview: String {
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedNotes.isEmpty {
            return "No description yet."
        }

        return trimmedNotes
    }
}

private extension TaskPriority {
    var badgeLabel: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }

    var badgeColor: Color {
        switch self {
        case .low:
            return Color.blue
        case .medium:
            return Color.orange
        case .high:
            return Color.red
        }
    }
}
