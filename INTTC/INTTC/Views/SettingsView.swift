import SwiftUI

struct SettingsView: View {
    @Binding var killOnHide: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Kill processes on hide")
                    .font(.system(size: 11))
                    .foregroundColor(INTTCTheme.textMuted)

                Spacer()

                Toggle("", isOn: $killOnHide)
                    .toggleStyle(.switch)
                    .scaleEffect(0.6)
                    .frame(width: 36)
            }

            HStack {
                Text("⌘⇧H")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(INTTCTheme.textFaint)
                Text("Toggle shortcut")
                    .font(.system(size: 10))
                    .foregroundColor(INTTCTheme.textFaint)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
