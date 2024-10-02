//
//  TrashSweepApp.swift
//  TrashSweep
//
//  Created by Tran Cong on 28/9/24.
//

import Cocoa
import Sparkle
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var windowController: NSWindowController?
    let updaterController = SPUStandardUpdaterController(
        startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "trash", accessibilityDescription: "Trash Sweep")
            button.action = #selector(statusBarButtonClicked)
        }
    }

    @objc func statusBarButtonClicked() {
        if windowController == nil {
            let contentView = ContentView()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 200),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.setFrameAutosaveName("TrashSweep")
            window.contentView = NSHostingView(rootView: contentView)
            windowController = NSWindowController(window: window)
        }

        windowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
@main
struct TrashSweepApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
