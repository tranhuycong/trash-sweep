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
    let updaterController = SPUStandardUpdaterController(
        startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "arrow.up.trash.fill", accessibilityDescription: "Trash Sweep")
            button.action = #selector(statusBarButtonClicked)
        }
    }

    @objc func statusBarButtonClicked() {
        let contentView = ContentView()
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 500, height: 250)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.show(
            relativeTo: statusItem!.button!.bounds, of: statusItem!.button!,
            preferredEdge: NSRectEdge.minY)

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
