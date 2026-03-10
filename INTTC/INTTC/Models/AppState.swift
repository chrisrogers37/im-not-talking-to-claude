import Foundation

struct WindowSnapshot: Codable, Identifiable {
    let id: UUID
    let bundleID: String
    let windowTitle: String
    let positionX: Double
    let positionY: Double
    let width: Double
    let height: Double

    var position: CGPoint {
        CGPoint(x: positionX, y: positionY)
    }

    var size: CGSize {
        CGSize(width: width, height: height)
    }

    init(bundleID: String, windowTitle: String, position: CGPoint, size: CGSize) {
        self.id = UUID()
        self.bundleID = bundleID
        self.windowTitle = windowTitle
        self.positionX = position.x
        self.positionY = position.y
        self.width = size.width
        self.height = size.height
    }
}

struct HiddenWindowsState: Codable {
    let snapshots: [WindowSnapshot]
    let hiddenAt: Date
}
