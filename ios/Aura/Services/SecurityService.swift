import LocalAuthentication
import Foundation

/// Wraps `LAContext` to perform biometric / passcode authentication.
final class SecurityService {

    func authenticate() async throws -> Bool {
        let context = LAContext()
        var nsError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &nsError) else {
            if let err = nsError {
                throw SecurityError.evaluationFailed(err)
            }
            throw SecurityError.notAvailable
        }

        return try await context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Unlock Aura to access your journal"
        )
    }

    // MARK: - Errors

    enum SecurityError: LocalizedError {
        case notAvailable
        case evaluationFailed(NSError)

        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Biometric authentication is not available on this device."
            case .evaluationFailed(let error):
                return error.localizedDescription
            }
        }
    }
}
