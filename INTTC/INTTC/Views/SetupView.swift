import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: INTTCViewModel

    @State private var permissionTimer: Timer?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("\u{1F441}\u{FE0F}")
                .font(.system(size: 36))

            Text("Welcome to INTTC")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(INTTCTheme.text)

            Text("INTTC needs Accessibility permission\nto hide and restore terminal windows.")
                .font(.system(size: 12))
                .foregroundColor(INTTCTheme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button(action: {
                viewModel.requestAccessibility()
                startPolling()
            }) {
                Text("Grant Permission")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(INTTCTheme.exposed)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)

            Text("This opens System Settings \u{2192} Privacy\n\u{2192} Accessibility. Add INTTC to the list.")
                .font(.system(size: 10))
                .foregroundColor(INTTCTheme.textFaint)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(width: 320)
        .background(INTTCTheme.surface)
        .onDisappear { permissionTimer?.invalidate() }
    }

    private func startPolling() {
        permissionTimer?.invalidate()
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if viewModel.checkAccessibility() {
                permissionTimer?.invalidate()
            }
        }
    }
}
