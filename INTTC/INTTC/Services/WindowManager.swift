import AppKit
import ApplicationServices

final class WindowManager {

    static func checkAccessibilityPermission() -> Bool {
        AXIsProcessTrusted()
    }

    static func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    // MARK: - Window Enumeration

    static func windowsForApp(pid: pid_t) -> [AXUIElement] {
        let appElement = AXUIElementCreateApplication(pid)
        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            appElement,
            kAXWindowsAttribute as CFString,
            &windowsRef
        )

        guard result == .success, let windows = windowsRef as? [AXUIElement] else {
            return []
        }

        return windows
    }

    // MARK: - Snapshot & Restore

    static func snapshotWindow(_ window: AXUIElement, bundleID: String) -> WindowSnapshot? {
        guard let position = getWindowPosition(window),
              let size = getWindowSize(window) else { return nil }

        let title = getWindowTitle(window) ?? "Untitled"

        return WindowSnapshot(
            bundleID: bundleID,
            windowTitle: title,
            position: position,
            size: size
        )
    }

    static func hideWindow(_ window: AXUIElement) {
        setWindowPosition(window, position: CGPoint(x: -32000, y: -32000))
    }

    static func restoreWindow(_ window: AXUIElement, to snapshot: WindowSnapshot) {
        setWindowPosition(window, position: snapshot.position)
        setWindowSize(window, size: snapshot.size)
    }

    // MARK: - Accessors

    static func getWindowPosition(_ window: AXUIElement) -> CGPoint? {
        var positionRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            window, kAXPositionAttribute as CFString, &positionRef
        ) == .success else { return nil }

        var point = CGPoint.zero
        guard AXValueGetValue(positionRef as! AXValue, .cgPoint, &point) else { return nil }
        return point
    }

    static func getWindowTitle(_ window: AXUIElement) -> String? {
        var titleRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            window, kAXTitleAttribute as CFString, &titleRef
        ) == .success else { return nil }
        return titleRef as? String
    }

    // MARK: - Private

    private static func getWindowSize(_ window: AXUIElement) -> CGSize? {
        var sizeRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            window, kAXSizeAttribute as CFString, &sizeRef
        ) == .success else { return nil }

        var size = CGSize.zero
        guard AXValueGetValue(sizeRef as! AXValue, .cgSize, &size) else { return nil }
        return size
    }

    private static func setWindowPosition(_ window: AXUIElement, position: CGPoint) {
        var point = position
        guard let axValue = AXValueCreate(.cgPoint, &point) else { return }
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, axValue)
    }

    private static func setWindowSize(_ window: AXUIElement, size: CGSize) {
        var sz = size
        guard let axValue = AXValueCreate(.cgSize, &sz) else { return }
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, axValue)
    }
}
