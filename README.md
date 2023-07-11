# Visor

Visor is a macOS application that allows users to apply a Metal shader to their entire screen. Here's how it works -- 
1. Capture the screen contents except for the Visor application.
2. Apply a `.metal` compute shader to the captured contents.
3. Render the shader output to a full screen overlay window which is invisible to mouse and keyboard events.


## Prerequisites
- macOS 12.3 or later

## Installation
1. Clone the repository `git clone https://github.com/fchughes/Visor.git`.
2. Open `Visor.xcodeproj` in Xcode.
3. Build and run the application.

## Usage
Start the app and you will see a square icon in the menu bar. Click the menu item and press "Visor Down" to apply a shader, "Visor Up" to unapply a shader, and "Select Shader" to choose a `.metal` shader file to apply to the screen. There are two shaders under `Visor/shaders` which you can use to test. If you don't select a shader a default brightness increasing effect will be applied so you can verify the application is working. To apply your own shaders, you must name the compute pass function `computeShader`.

The first time you run the app, you will be prompted to grant screen share access which is required to run the app.

Depending on your OS version and screen resolution, you may need to modify the "top spacing" in the settings to account for differences in the height of the menu bar, since we aren't able to draw to that region of the screen. 


https://github.com/fchughes/Visor/assets/129426794/ff63682d-06c4-48b4-a993-537cb3e72e59

## License
This project is open-sourced under the MIT license. See [LICENSE](LICENSE) for more information.
