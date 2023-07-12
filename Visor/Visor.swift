import ScreenCaptureKit
import SwiftUI
import UniformTypeIdentifiers

class VisorAppManager: ObservableObject {
    init() {
        checkScreenRecordingPermission()
    }

    func checkScreenRecordingPermission() {
        Task {
            do {
                try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            } catch {}
        }
    }
}

@main
struct VisorApp: App {
    @StateObject private var appManager = VisorAppManager()

    var body: some Scene {
        MenuBarExtra("Visor", systemImage: "squareshape.dashed.squareshape") {
            ContentView()
        }
    }
}
