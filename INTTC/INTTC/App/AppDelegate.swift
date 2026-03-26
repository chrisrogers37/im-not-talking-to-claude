import AppKit
import Carbon
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    fileprivate let viewModel = INTTCViewModel()
    private var eventMonitor: Any?
    private var hotKeyRef: EventHotKeyRef?
    private var sizeObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: 44)

        if let button = statusItem.button {
            updateIcon(isHidden: viewModel.isHidden)
            button.action = #selector(togglePopover)
            button.target = self
        }

        let contentView = PopoverContentView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: contentView)
        hostingController.view.setFrameSize(hostingController.sizeThatFits(in: NSSize(width: 320, height: 10000)))

        popover = NSPopover()
        popover.behavior = .applicationDefined
        popover.delegate = self
        popover.contentViewController = hostingController

        sizeObserver = NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: hostingController.view,
            queue: .main
        ) { [weak self] _ in
            self?.adjustPopoverFrame()
        }
        hostingController.view.postsFrameChangedNotifications = true

        viewModel.onStateChange = { [weak self] isHidden in
            self?.updateIcon(isHidden: isHidden)
        }

        // Global hotkey: Cmd+Shift+H (Carbon API — no Input Monitoring permission required)
        registerGlobalHotkey()

        viewModel.performCrashRecovery()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        viewModel.restoreBeforeQuit()
    }

    private func registerGlobalHotkey() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyHandler,
            1,
            &eventType,
            selfPtr,
            nil
        )

        var hotkeyID = EventHotKeyID(
            signature: OSType(0x494E5454), // 'INTT'
            id: 1
        )

        RegisterEventHotKey(
            UInt32(kVK_ANSI_H),
            UInt32(cmdKey | shiftKey),
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    private func adjustPopoverFrame() {
        guard let window = popover.contentViewController?.view.window else { return }
        let oldFrame = window.frame
        let newContentSize = popover.contentViewController!.view.fittingSize
        let newHeight = newContentSize.height + 20

        if abs(oldFrame.height - newHeight) > 1 {
            let newOrigin = NSPoint(x: oldFrame.origin.x, y: oldFrame.maxY - newHeight)
            let newFrame = NSRect(origin: newOrigin, size: NSSize(width: oldFrame.width, height: newHeight))
            window.setFrame(newFrame, display: true, animate: false)
        }
    }

    private func updateIcon(isHidden: Bool) {
        guard let button = statusItem.button else { return }
        let red = NSColor(red: 248/255, green: 81/255, blue: 73/255, alpha: 1)
        let green = NSColor(red: 63/255, green: 185/255, blue: 80/255, alpha: 1)

        let size = NSSize(width: 28, height: 22)
        let image = NSImage(size: size, flipped: false) { _ in
            let centerX: CGFloat = 14
            let centerY: CGFloat = 11

            if isHidden {
                // Closed eye — green (hidden state)
                green.setStroke()
                let closedEye = NSBezierPath()
                closedEye.move(to: NSPoint(x: 4, y: centerY))
                closedEye.curve(to: NSPoint(x: 24, y: centerY),
                               controlPoint1: NSPoint(x: 10, y: centerY + 6),
                               controlPoint2: NSPoint(x: 18, y: centerY + 6))
                closedEye.lineWidth = 1.5
                closedEye.stroke()

                // Eyelashes
                for x: CGFloat in [9, 14, 19] {
                    let lash = NSBezierPath()
                    lash.move(to: NSPoint(x: x, y: centerY + 3))
                    lash.line(to: NSPoint(x: x, y: centerY + 6))
                    lash.lineWidth = 1.2
                    lash.stroke()
                }
            } else {
                // Open eye — red (exposed state)
                red.setStroke()

                let eyeTop = NSBezierPath()
                eyeTop.move(to: NSPoint(x: 4, y: centerY))
                eyeTop.curve(to: NSPoint(x: 24, y: centerY),
                             controlPoint1: NSPoint(x: 10, y: centerY - 7),
                             controlPoint2: NSPoint(x: 18, y: centerY - 7))

                let eyeBottom = NSBezierPath()
                eyeBottom.move(to: NSPoint(x: 4, y: centerY))
                eyeBottom.curve(to: NSPoint(x: 24, y: centerY),
                                controlPoint1: NSPoint(x: 10, y: centerY + 7),
                                controlPoint2: NSPoint(x: 18, y: centerY + 7))

                eyeTop.lineWidth = 1.5
                eyeBottom.lineWidth = 1.5
                eyeTop.stroke()
                eyeBottom.stroke()

                // Pupil
                red.setFill()
                let pupil = NSBezierPath(ovalIn: NSRect(
                    x: centerX - 2.5, y: centerY - 2.5, width: 5, height: 5))
                pupil.fill()
            }

            return true
        }

        image.isTemplate = false
        button.image = image
    }

    @objc private func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            viewModel.refreshSessions()
            openPopover()
        }
    }

    private func openPopover() {
        guard let button = statusItem.button else { return }
        NSApplication.shared.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover()
        }
    }

    private func closePopover() {
        popover.performClose(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

// Carbon event handler — must be a top-level function (C function pointer requirement)
private func hotKeyHandler(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData = userData else { return OSStatus(eventNotHandledErr) }
    let delegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
    delegate.viewModel.toggleMaster()
    return noErr
}
