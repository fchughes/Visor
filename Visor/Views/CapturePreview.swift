import MetalKit
import SwiftUI

let shaderSource = """
#include <metal_stdlib>
using namespace metal;

kernel void computeShader(texture2d<half, access::read> inTexture [[ texture (0) ]],
                               texture2d<half, access::read_write> outTexture [[ texture (1) ]],
                               uint2 gid [[ thread_position_in_grid ]]) {
    outTexture.write(inTexture.read(gid).rgba * 2, gid);
}
"""

struct CapturePreview: NSViewRepresentable {
    var metalView: MetalView

    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Device not created. Run on a physical device.")
        }
        metalView = MetalView(frame: .zero, device: device)
    }

    func makeNSView(context: Context) -> NSView {
        return metalView
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    func updateFrame(_ frame: CapturedFrame) {
        metalView.updateTexture(with: frame.surface!)
        metalView.setNeedsDisplay(metalView.visibleRect)
    }
}

class MetalView: MTKView {
    private var commandQueue: MTLCommandQueue!
    private var shaderLibrary: MTLLibrary!
    private var texture: MTLTexture!
    private var pipelineState: MTLComputePipelineState!

    required init(coder: NSCoder) {
        super.init(coder: coder)
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Device not created. Run on a physical device.")
        }
        self.device = device
    }

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        guard let device = device else {
            fatalError("Device not created. Run on a physical device.")
        }
        self.device = device
        clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        colorPixelFormat = .bgra8Unorm
        framebufferOnly = false

        do {
            commandQueue = device.makeCommandQueue()

            shaderLibrary = try device.makeLibrary(source: shaderSource, options: nil)
            let computeFunction = shaderLibrary?.makeFunction(name: "computeShader")
            pipelineState = try device.makeComputePipelineState(function: computeFunction!)
        } catch {
            print("Failed to create pipeline: \(error)")
        }
    }

    func updateShader(shaderPath: String) {
        guard let device = device else {
            return
        }
        do {
            let shaderSrc = try String(contentsOfFile: shaderPath)
            shaderLibrary = try device.makeLibrary(source: shaderSrc, options: nil)
            let computeFunction = shaderLibrary?.makeFunction(name: "computeShader")
            pipelineState = try device.makeComputePipelineState(function: computeFunction!)
        } catch {
            print("Failed to create pipeline: \(error)")
        }
    }

    func updateTexture(with surface: IOSurface) {
        guard let device = device else {
            return
        }
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm, width: IOSurfaceGetWidth(surface),
            height: IOSurfaceGetHeight(surface), mipmapped: false)
        drawableSize = CGSize(width: descriptor.width, height: descriptor.height)

        descriptor.usage = [.shaderRead, .shaderWrite]

        guard let texture = device.makeTexture(descriptor: descriptor, iosurface: surface, plane: 0) else {
            print("Could not create texture from IOSurface.")
            return
        }
        self.texture = texture
    }

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)

        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let currentDrawable = currentDrawable,
              let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        else {
            return
        }

        computeEncoder.setComputePipelineState(pipelineState)
        computeEncoder.setTexture(texture, index: 0)
        computeEncoder.setTexture(currentDrawable.texture, index: 1)

        let threadGroupCount = MTLSizeMake(16, 16, 1)
        let w = ((texture?.width ?? 1) + threadGroupCount.width - 1) / threadGroupCount.width
        let h = ((texture?.height ?? 1) + threadGroupCount.height - 1) / threadGroupCount.height
        let threadGroups = MTLSizeMake(w, h, 1)

        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        computeEncoder.endEncoding()

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}
