import SwiftUI

struct BootstrapRootView: View {
    let bootstrapper: AppBootstrapper

    @State private var bootstrapState: BootstrapState = .loading
    @State private var reloadToken = 0

    var body: some View {
        Group {
            switch bootstrapState {
            case .loading:
                loadingView
            case .ready(let environment):
                AppShellView(router: environment.router, environment: environment)
            case .failed(let failure):
                failureView(failure)
            }
        }
        .task(id: reloadToken) {
            bootstrapState = .loading
            bootstrapState = await MainActor.run {
                bootstrapper.bootstrap()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 18) {
            ProgressView()
                .controlSize(.large)

            VStack(spacing: 6) {
                Text("Opening your local workspace")
                    .font(.title3.weight(.semibold))
                Text("Pomodoro starts from files stored on this Mac, so no network setup is required.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    private func failureView(_ failure: BootstrapFailure) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(failure.title)
                .font(.title2.weight(.semibold))

            Text(failure.message)
                .foregroundStyle(.secondary)

            Text(failure.recoverySuggestion)
                .font(.subheadline)

            if failure.technicalDetails.isEmpty == false {
                Text(failure.technicalDetails)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            Button("Try Again") {
                reloadToken += 1
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(32)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    BootstrapRootView(bootstrapper: AppBootstrapper())
}
