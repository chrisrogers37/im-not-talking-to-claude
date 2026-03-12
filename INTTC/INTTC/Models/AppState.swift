import Foundation

struct HiddenState: Codable {
    let claudePIDs: [Int32]
    let terminalBundleIDs: [String]
    let hiddenAt: Date
}
