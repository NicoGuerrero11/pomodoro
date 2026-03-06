import SwiftUI

struct TasksWorkspaceView: View {
    @Bindable var model: TasksFeatureModel

    var body: some View {
        Group {
            if model.showsFocusedEmptyState {
                emptyState
            } else if model.hasTasks {
                workspaceSplitView
            } else {
                TaskEditorPaneView(model: model)
            }
        }
        .navigationTitle("Tasks")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .toolbar {
            if model.hasTasks {
                Button {
                    model.beginCreatingTask()
                } label: {
                    Label("New Task", systemImage: "plus")
                }
            }
        }
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

    private var workspaceSplitView: some View {
        HSplitView {
            TaskListPaneView(model: model)
            TaskEditorPaneView(model: model)
        }
    }
}
