import Foundation

enum BootstrapState {
    case loading
    case ready(AppEnvironment)
    case failed(BootstrapFailure)
}

struct BootstrapFailure: Equatable {
    let title: String
    let message: String
    let recoverySuggestion: String
    let technicalDetails: String
}
