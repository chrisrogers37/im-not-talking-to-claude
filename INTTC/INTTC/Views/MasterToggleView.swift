import SwiftUI

struct MasterToggleView: View {
    let isHidden: Bool
    let sessionCount: Int
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 0) {
                    Text("Babe, ")
                        .italic()
                        .foregroundColor(INTTCTheme.textMuted)
                    Text(isHidden ? "Not Talking To Claude" : "Talking To Claude")
                        .foregroundColor(INTTCTheme.text)
                }
                .font(.system(size: 13, weight: .semibold))

                Text(isHidden
                    ? "Nothing to see here."
                    : "\(sessionCount) session\(sessionCount == 1 ? "" : "s") exposed.")
                    .font(.system(size: 11))
                    .foregroundColor(INTTCTheme.textFaint)
            }

            Spacer()

            StatusToggle(isHidden: isHidden, action: onToggle)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

struct StatusToggle: View {
    let isHidden: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: isHidden ? .trailing : .leading) {
                Capsule()
                    .fill(isHidden ? INTTCTheme.hidden : INTTCTheme.exposed)
                    .frame(width: 44, height: 26)
                    .shadow(
                        color: (isHidden ? INTTCTheme.hidden : INTTCTheme.exposed).opacity(0.3),
                        radius: 8, y: 2
                    )

                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
                    .padding(3)
            }
            .animation(.easeInOut(duration: 0.2), value: isHidden)
        }
        .buttonStyle(.plain)
    }
}
