import SwiftUI

struct TaskEditorPaneView: View {
    @Bindable var model: TasksFeatureModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if let errorMessage = model.errorMessage {
                    messageCard(
                        errorMessage,
                        tint: Color.red.opacity(0.14),
                        foregroundStyle: .red
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Title")
                        .font(.headline)
                    TextField("Task title", text: titleBinding)
                        .textFieldStyle(.roundedBorder)
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
                        .frame(minHeight: 220)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(nsColor: .controlBackgroundColor))
                        )
                }

                if let validationMessage = model.validationMessage {
                    messageCard(
                        validationMessage,
                        tint: Color.red.opacity(0.14),
                        foregroundStyle: .red
                    )
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
            .padding(28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(model.editorTitle)
                .font(.system(size: 28, weight: .semibold))

            Text(headerDetail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var headerDetail: String {
        if model.isCreatingTask {
            return "Save when the task is ready. Cancel discards this blank draft."
        }

        return "Edit the task directly here, then save or cancel explicitly."
    }

    private func messageCard(
        _ message: String,
        tint: Color,
        foregroundStyle: Color
    ) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(foregroundStyle)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint)
            )
    }
}

private extension TaskEditorPaneView {
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
