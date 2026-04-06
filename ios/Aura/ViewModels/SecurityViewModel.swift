import Foundation
import Combine

/// Controls the app-level lock screen.
/// When security is enabled in Settings the app locks whenever it enters the background.
@MainActor
final class SecurityViewModel: ObservableObject {
    @Published var isLocked: Bool = false
    @Published var isAuthenticating: Bool = false
    @Published var authError: String?

    private let securityService = SecurityService()

    init() {
        lockIfNeeded()
    }

    // MARK: - Public API

    /// Triggers Face ID / Touch ID / passcode authentication.
    func authenticate() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        authError = nil

        do {
            let success = try await securityService.authenticate()
            isLocked = !success
        } catch {
            authError = error.localizedDescription
        }

        isAuthenticating = false
    }

    /// Locks the app if the user has security enabled.
    func lockIfNeeded() {
        if UserDefaults.standard.bool(forKey: "securityEnabled") {
            isLocked = true
        }
    }
}

