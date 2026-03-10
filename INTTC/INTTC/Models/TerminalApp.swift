import Foundation

enum TerminalApp: String, CaseIterable, Identifiable {
    case terminal = "com.apple.Terminal"
    case iterm2 = "com.googlecode.iterm2"
    case warp = "dev.warp.Warp-Stable"
    case kitty = "net.kovidgoyal.kitty"
    case alacritty = "org.alacritty"
    case ghostty = "com.mitchellh.ghostty"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .terminal: return "Terminal"
        case .iterm2: return "iTerm2"
        case .warp: return "Warp"
        case .kitty: return "Kitty"
        case .alacritty: return "Alacritty"
        case .ghostty: return "Ghostty"
        }
    }
}
