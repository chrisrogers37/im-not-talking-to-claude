import SwiftUI

struct FooterView: View {
    @Binding var launchAtLogin: Bool
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Launch at Login")
                    .font(.system(size: 10))
                    .foregroundColor(INTTCTheme.textMuted)

                Spacer()

                Toggle("", isOn: $launchAtLogin)
                    .toggleStyle(.switch)
                    .scaleEffect(0.6)
                    .frame(width: 36)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            HStack {
                Text("v0.1.0")
                    .font(.system(size: 10))
                    .foregroundColor(INTTCTheme.textFaint)

                Spacer()

                Button("Quit") { onQuit() }
                    .font(.system(size: 10))
                    .foregroundColor(INTTCTheme.textMuted)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
}
