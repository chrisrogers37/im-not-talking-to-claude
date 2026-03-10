import SwiftUI

struct SessionCatalogView: View {
    let sessions: [ClaudeSession]
    let isHidden: Bool

    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Sessions")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(INTTCTheme.textMuted)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(INTTCTheme.textFaint)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .onTapGesture { isExpanded.toggle() }

            if isExpanded {
                if sessions.isEmpty {
                    Text("No Claude sessions detected")
                        .font(.system(size: 11))
                        .foregroundColor(INTTCTheme.textFaint)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                } else {
                    ForEach(sessions) { session in
                        SessionRow(session: session, isHidden: isHidden)
                    }
                }
            }
        }
    }
}

struct SessionRow: View {
    let session: ClaudeSession
    let isHidden: Bool

    @State private var isHovered = false

    var body: some View {
        HStack {
            Text(session.displayPath)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(INTTCTheme.text)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            Text(session.terminalApp.displayName)
                .font(.system(size: 10))
                .foregroundColor(INTTCTheme.textFaint)

            Circle()
                .fill(isHidden ? INTTCTheme.hidden : INTTCTheme.exposed)
                .frame(width: 6, height: 6)
                .shadow(
                    color: (isHidden ? INTTCTheme.hidden : INTTCTheme.exposed).opacity(0.4),
                    radius: 3
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 7)
        .background(isHovered ? INTTCTheme.surfaceHover : Color.clear)
        .onHover { isHovered = $0 }
    }
}
