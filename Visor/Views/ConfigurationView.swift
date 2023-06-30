import ScreenCaptureKit
import SwiftUI
import UniformTypeIdentifiers

/// The app's configuration user interface.
struct ConfigurationView: View {
    private let alignmentOffset: CGFloat = 10

    @ObservedObject var screenRecorder: ScreenRecorder
    @State var shaderPath: String = "../shaders/invert.metal"
    @State private var showingSettings = false

    var body: some View {
        Button("Settings") { showSettings() }
            .disabled(screenRecorder.isRunning)
        Button("Select Shader") { selectShader() }
            .disabled(screenRecorder.isRunning)
        Button("Visor Down") {
            Task {
                screenRecorder.panelManager.presentPanel(content: { screenRecorder.capturePreview }, contentRect: CGRect(x: 0, y: screenRecorder.topSpace, width: 1512, height: 982 - screenRecorder.topSpace))
                await screenRecorder.start()
            }
        }
        .disabled(screenRecorder.isRunning)

        Button {
            Task { await screenRecorder.stop()
                screenRecorder.panelManager.dismissPanel()
            }

        } label: {
            Text("Visor Up")
        }
        .disabled(!screenRecorder.isRunning)
        Button("Quit") { NSApplication.shared.terminate(nil) }
    }

    func selectShader() {
        let dialog = NSOpenPanel()

        dialog.title = "Choose a shader file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        NSApplication.shared.activate(ignoringOtherApps: true)
        dialog.makeKey()
        dialog.allowedContentTypes = [UTType(filenameExtension: "metal")!]

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            guard let result = dialog.url else { return }
            shaderPath = result.path
            screenRecorder.capturePreview.metalView.updateShader(shaderPath: shaderPath)
        } else {
            return
        }
    }

    func showSettings() {
        let settingsView = SettingsView(inputNumber: $screenRecorder.topSpace)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 100),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.level = .floating
        window.isReleasedWhenClosed = false

        NSApplication.shared.activate(ignoringOtherApps: true)
        window.contentView = NSHostingView(rootView: settingsView)
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}

struct SettingsView: View {
    @Binding var inputNumber: Int
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        VStack {
            HStack {
                Text("Top Spacing:")
                TextField("Number", value: $inputNumber, formatter: formatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            Button("Save") {
                NSApplication.shared.windows.last?.close()
            }
            .padding()
        }
        .padding()
    }
}
