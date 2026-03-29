import AppKit
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var mainWindow: NSWindow?
    private var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupMainWindow()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "airplane", accessibilityDescription: "Wade")
            button.image?.isTemplate = true
            button.action = #selector(toggleMainWindow)
            button.target = self
        }
    }

    private func setupMainWindow() {
        let contentView = ContentView()
            .injectTheme()
            .environmentObject(AppState())

        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 640),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        mainWindow?.title = "Wade"
        mainWindow?.center()
        mainWindow?.contentView = NSHostingView(rootView: contentView)
        mainWindow?.titlebarAppearsTransparent = false
        mainWindow?.isReleasedWhenClosed = false
        mainWindow?.backgroundColor = NSColor(Theme.surfaceLight)
    }

    @objc private func toggleMainWindow() {
        guard let window = mainWindow else { return }

        if window.isVisible {
            window.orderOut(nil)
        } else {
            if let button = statusItem.button {
                let buttonFrame = button.window?.frame ?? .zero
                let x = buttonFrame.origin.x + buttonFrame.width / 2 - window.frame.width / 2
                let y = buttonFrame.origin.y - window.frame.height - 10
                window.setFrameOrigin(NSPoint(x: x, y: y))
            }
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
