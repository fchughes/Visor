import SwiftUI

struct ContentView: View {
    @StateObject var screenRecorder = ScreenRecorder()

    var body: some View {
        ConfigurationView(screenRecorder: screenRecorder)
            .frame(minWidth: 0,
                   maxWidth: 200,
                   minHeight: 0,
                   maxHeight: 200,
                   alignment: .topLeading)
    }
}
