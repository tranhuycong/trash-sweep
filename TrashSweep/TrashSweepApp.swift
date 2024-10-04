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
    var window: NSWindow?
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
        // set the window width and height
        let windowWidth: CGFloat = 500
        let windowHeight: CGFloat = 250
        // center the window under the cursor
        let mouseLocation = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let windowX = mouseLocation.x - windowWidth / 2
        let windowY = screenHeight - windowHeight - 32
        // construct the window
        window = getOrBuildWindow(
            size: NSRect(
                x: windowX, y: windowY, width: windowWidth, height: windowHeight)
        )
        // show or hide the window
        toggleWindowVisibility(location: NSPoint(x: windowX, y: windowY))
    }

    @objc func getOrBuildWindow(size: NSRect) -> NSWindow {
        if window != nil {
            return window.unsafelyUnwrapped
        }
        let contentView = ContentView()
        window = NSWindow(
            contentRect: size,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false)
        window?.contentView = NSHostingView(rootView: contentView)
        window?.isReleasedWhenClosed = false
        window?.collectionBehavior = .moveToActiveSpace
        window?.level = .floating
        return window.unsafelyUnwrapped
    }

    func toggleWindowVisibility(location: NSPoint) {
        // window hasn't been built yet, don't do anything
        if window == nil {
            return
        }
        if window!.isVisible {
            // window is visible, hide it
            window?.orderOut(nil)
        } else {
            // window is hidden. Position and show it on top of other windows
            window?.setFrameOrigin(location)
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
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
