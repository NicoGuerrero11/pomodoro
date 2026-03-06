import SwiftUI

struct TasksWorkspaceView: View {
    @Bindable var model: TasksFeatureModel

    var body: some View {
        Group {
            if model.showsFocusedEmptyState {
                emptyState
            } else {
                editorSurface
            }
        }
        .navigationTitle("Tasks")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("No tasks yet")
                .font(.system(size: 28, weight: .semibold))

            Text("Start with one task. Title, notes, and priority stay editable here.")
                .font(.body)
                .foregroundStyle(.secondary)

            Button("Create Task") {
                model.beginCreatingTask()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(32)
    }

    private var editorSurface: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(model.editorTitle)
                .font(.title2.weight(.semibold))

            if let errorMessage = model.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Title")
                    .font(.headline)
                TextField("Task title", text: titleBinding)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Priority")
                    .font(.headline)
                Picker("Priority", selection: priorityBinding) {
                    Text("Low").tag(TaskPriority.low)
                    Text("Medium").tag(TaskPriority.medium)
                    Text("High").tag(TaskPriority.high)
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Description")
                    .font(.headline)
                TextEditor(text: notesBinding)
                    .frame(minHeight: 180)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
            }

            if let validationMessage = model.validationMessage {
                Text(validationMessage)
                    .foregroundStyle(.red)
            }

            HStack {
                Spacer()

                Button("Cancel") {
                    model.cancelEditing()
                }

                Button(model.saveButtonTitle) {
                    model.saveCurrentTask()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
    }
}

private extension TasksWorkspaceView {
    var titleBinding: Binding<String> {
        Binding(
            get: { model.draft.title },
            set: { model.updateTitle($0) }
        )
    }

    var notesBinding: Binding<String> {
        Binding(
            get: { model.draft.notes },
            set: { model.updateNotes($0) }
        )
    }

    var priorityBinding: Binding<TaskPriority> {
        Binding(
            get: { model.draft.priority },
            set: { model.updatePriority($0) }
        )
    }
}
