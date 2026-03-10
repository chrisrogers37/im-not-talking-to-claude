import SwiftUI

struct SettingsView: View {
    @Binding var suspendProcesses: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Suspend processes when hidden")
                    .font(.system(size: 11))
                    .foregroundColor(INTTCTheme.textMuted)

                Spacer()

                Toggle("", isOn: $suspendProcesses)
                    .toggleStyle(.switch)
                    .scaleEffect(0.6)
                    .frame(width: 36)
            }

            HStack {
                Text("⌘⇧H")
                    .font(.system(size: 10, weight: .medium))
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
