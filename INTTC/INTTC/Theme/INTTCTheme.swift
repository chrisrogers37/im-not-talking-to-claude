import SwiftUI

enum INTTCTheme {
    static let background = Color(hex: "0d1117")
    static let surface = Color(hex: "161b22")
    static let surfaceHover = Color(hex: "1c2129")
    static let exposed = Color(hex: "f85149")
    static let exposedSoft = Color(hex: "f85149").opacity(0.08)
    static let hidden = Color(hex: "3fb950")
    static let hiddenSoft = Color(hex: "3fb950").opacity(0.08)
    static let text = Color(hex: "e6edf3")
    static let textMuted = Color(hex: "8b949e")
    static let textFaint = Color(hex: "484f58")
    static let border = Color.white.opacity(0.06)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
