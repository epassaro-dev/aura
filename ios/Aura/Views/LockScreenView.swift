import SwiftUI

struct LockScreenView: View {
    @EnvironmentObject private var securityViewModel: SecurityViewModel

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App icon placeholder
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.indigo, Color.indigo.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: 8) {
                    Text("Aura")
                        .font(.largeTitle.bold())
                    Text("Your migraine journal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Unlock button
                Button {
                    Task { await securityViewModel.authenticate() }
                } label: {
                    HStack {
                        if securityViewModel.isAuthenticating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "faceid")
                                .font(.title3)
                            Text("Unlock with Face ID")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(securityViewModel.isAuthenticating)
                .padding(.horizontal, 32)

                if let error = securityViewModel.authError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
                    .frame(height: 40)
            }
        }
        .task {
            // Attempt authentication automatically on appearance.
            await securityViewModel.authenticate()
        }
    }
}

// MARK: - Preview

#Preview {
    LockScreenView()
        .environmentObject(SecurityViewModel())
}

