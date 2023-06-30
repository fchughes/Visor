import Combine
import OSLog
import ScreenCaptureKit
import SwiftUI

struct ContentView: View {
    @State var isUnauthorized = false

    @StateObject var screenRecorder = ScreenRecorder()

    var body: some View {
        if isUnauthorized {
            VStack {
                Spacer()
                VStack {
                    Text("No screen recording permission.")
                        .font(.largeTitle)
                        .padding(.top)
                    Text("Open System Settings and go to Privacy & Security > Screen Recording to grant permission.")
                        .font(.title2)
                        .padding(.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(.red)
            }
            .onAppear {
                Task {
                    if await screenRecorder.canRecord {
                    } else {
                        isUnauthorized = true
                    }
                }
            }
        } else {
            ConfigurationView(screenRecorder: screenRecorder)
                .frame(minWidth: 0,
                       maxWidth: 200,
                       minHeight: 0,
                       maxHeight: 200,
                       alignment: .topLeading)
        }
    }
}
