//
//  ContentView.swift
//  TrashSweep
//
//  Created by Tran Cong on 28/9/24.
//

import Foundation
import Sparkle
import SwiftUI

struct ContentView: View {
    @AppStorage("trashSize") public var trashSize = 0.0
    @AppStorage("keepTrashSizeMin") private var keepTrashSizeMin = 2.0
    @AppStorage("keepTrashSizeMax") public var keepTrashSizeMax = 5.0
    @AppStorage("isAutoSweepTrash") public var isAutoSweepTrash = false
    @AppStorage("isHavePermissionTrash") private var isHavePermissionTrash = false
    private var trashMonitor: TrashMonitor?
    let updateController = SPUStandardUpdaterController(
        startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

    @State private var shouldShowMenu = true

    init() {
        trashMonitor = TrashMonitor(contentView: self)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("TrashSweep")
                    .font(.headline)
                Spacer()
                Menu {
                    Button("About") {
                        print("About")
                    }
                    Button("Check for Updates") {
                        updateController.checkForUpdates(self)
                    }
                    Button("Quit") {
                        NSApplication.shared.terminate(self)
                    }
                } label: {
                    Image(systemName: "gearshape")
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .menuIndicator(.hidden)
                .fixedSize()
            }
            if !isHavePermissionTrash {
                Text(
                    "Please grant Full Disk Access to the app in System Preferences under Security & Privacy > Privacy > Full Disk Access."
                )
                .foregroundColor(.red)
                Button("Open permissions") {
                    NSWorkspace.shared.open(
                        URL(
                            string:
                                "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
                        )!)
                }
            }
            Divider()
            HStack {
                Text("Delete oldest files until trash size is under")
                TextField(
                    "", value: $keepTrashSizeMin, format: .number.precision(.fractionLength(1))
                )
                .frame(width: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("GB.")
            }
            HStack {
                Toggle(isOn: $isAutoSweepTrash) {
                    Text("Automatically sweep trash when the trash size exceeds")
                }
                TextField(
                    "", value: $keepTrashSizeMax, format: .number.precision(.fractionLength(1))
                )
                .frame(width: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("GB")
            }
            Divider()
            Text("Trash size: \(trashSize, specifier: "%.3f") GB")
            HStack {
                Button("Sweep Trash Now") {
                    print("Sweep Trash")
                    sweepTrash()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(
            minWidth: 300, idealWidth: 350, maxWidth: .infinity,
            minHeight: 200, idealHeight: 200, maxHeight: .infinity,
            alignment: .top
        )
        .onAppear {
            if !isHavePermissionTrash {
                permissionRequestAlert()
            }

            updateTrashSize()
            trashMonitor!.startMonitoring()
            if isAutoSweepTrash {
                sweepTrash()
            }
        }
    }

    func sweepTrash() {
        deleteOldestFilesInTrash()
        updateTrashSize()
    }

    func permissionRequestAlert() {
        let fileManager = FileManager.default
        let trashURL: URL

        do {
            trashURL = try fileManager.url(
                for: .trashDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            print("Failed to get Trash directory URL: \(error)")
            return
        }

        let keys: [URLResourceKey] = [.isReadableKey, .isWritableKey]
        let resourceValues: URLResourceValues

        do {
            resourceValues = try trashURL.resourceValues(forKeys: Set(keys))
        } catch {
            print("Failed to get resource values: \(error)")
            return
        }

        let isReadable = resourceValues.isReadable ?? false
        let isWritable = resourceValues.isWritable ?? false

        if !isReadable || !isWritable {
            let alert = NSAlert()
            alert.messageText = "Permission Required"
            alert.informativeText =
                "Please grant Full Disk Access to the app in System Preferences under Security & Privacy > Privacy > Full Disk Access."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } else {
            isHavePermissionTrash = true
        }
    }

    func getTrashSize() -> Double? {
        let fileManager = FileManager.default
        do {
            let trashURL = try fileManager.url(
                for: .trashDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

            let contents = try FileManager.default.contentsOfDirectory(
                at: trashURL, includingPropertiesForKeys: nil, options: []
            )
            let totalSize = contents.reduce(0) { (size, url) -> Int64 in
                let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                return size + Int64(fileSize)
            }
            return Double(totalSize)
        } catch {
            print("Failed to get contents of Trash directory: \(error)")
            return nil
        }
    }

    func convertInt64ToGB(_ size: Int64) -> Double {
        return Double(size) / 1_000_000_000
    }

    func convertGBToInt64(_ size: Double) -> Int64 {
        return Int64(size * 1_000_000_000)
    }

    func deleteOldestFilesInTrash() {
        if trashSize <= keepTrashSizeMin {
            return
        }

        let sizeLimit = convertGBToInt64(trashSize - keepTrashSizeMin)
        let fileManager = FileManager.default

        do {
            let trashURL = try fileManager.url(
                for: .trashDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

            let files = try FileManager.default.contentsOfDirectory(
                at: trashURL, includingPropertiesForKeys: nil, options: []
            )

            let sortedFiles = files.sorted {
                let date1 = try? $0.resourceValues(forKeys: [.addedToDirectoryDateKey])
                    .addedToDirectoryDate
                let date2 = try? $1.resourceValues(forKeys: [.addedToDirectoryDateKey])
                    .addedToDirectoryDate
                return date1 ?? Date.distantPast < date2 ?? Date.distantPast
            }

            var totalDeletedSize: Int64 = 0

            for file in sortedFiles {
                let fileSize = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                try fileManager.removeItem(at: file)
                print("Deleted \(file.lastPathComponent) (\(fileSize) bytes)")
                totalDeletedSize += Int64(fileSize)

                if totalDeletedSize >= sizeLimit {
                    break
                }
            }

            print("Deleted \(totalDeletedSize) bytes of data from trash.")
        } catch {
            print("Error processing files in trash: \(error)")
        }
    }

    func updateTrashSize() {
        let size = getTrashSize()
        trashSize = convertInt64ToGB(Int64(size ?? 0))
        print("Trash size: \(size ?? 0)")
    }

}

class TrashMonitor {
    private var trashFolderMonitor: DispatchSourceFileSystemObject?
    private let trashURL: URL
    private var contentView: ContentView?

    init(contentView: ContentView) {
        self.contentView = contentView
        let fileManager = FileManager.default
        do {
            trashURL = try fileManager.url(
                for: .trashDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            fatalError("Failed to get Trash directory URL: \(error)")
        }
    }

    func startMonitoring() {
        let fileDescriptor = open(trashURL.path, O_EVTONLY)
        if fileDescriptor == -1 {
            print("Failed to open trash folder")
            return
        }

        trashFolderMonitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor, eventMask: .write, queue: DispatchQueue.global())

        trashFolderMonitor?.setEventHandler { [weak self] in
            self?.handleTrashFolderChange()
        }

        trashFolderMonitor?.setCancelHandler {
            close(fileDescriptor)
        }

        trashFolderMonitor?.resume()
    }

    private func handleTrashFolderChange() {
        DispatchQueue.main.async {
            guard let contentView = self.contentView else { return }
            if contentView.isAutoSweepTrash && contentView.trashSize > contentView.keepTrashSizeMax
            {
                contentView.sweepTrash()
            } else {
                contentView.updateTrashSize()
            }
        }
    }

    func stopMonitoring() {
        trashFolderMonitor?.cancel()
        trashFolderMonitor = nil
    }

}

#Preview {
    ContentView()
}
