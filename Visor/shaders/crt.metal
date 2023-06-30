/*
  crt.metal
  Visor

  Created by Forest Hughes on 6/27/23.
  Copyright © 2023 Apple. All rights reserved.
*/

#include <metal_stdlib>
using namespace metal;


kernel void computeShader(texture2d<float, access::read> input [[texture(0)]],
                      texture2d<float, access::write> output [[texture(1)]],
                      uint2 gid [[thread_position_in_grid]])
{
    float2 imageSize = float2(input.get_width(), input.get_height());
    float2 uv = (float2(gid) + 0.5) / imageSize;
    uv = uv * 2.0 - 1.0;  // Remap UV coordinates from [0, 1] to [-1, 1]

    // Barrel distortion
    float distortionStrength = 0.0;  // Change this value to adjust the strength of the distortion
    float2 distortedUV = uv * (1.0 + distortionStrength * length(uv));
    distortedUV = distortedUV * 0.5 + 0.5;  // Remap UV coordinates from [-1, 1] back to [0, 1]

    uint2 distortedGid = uint2(distortedUV * imageSize);

    if (distortedGid.x < input.get_width() && distortedGid.y < input.get_height()) {
        float4 color = input.read(distortedGid).rgba;

        // Aperture grille effect
        //float grillePeriod = 3.0;  // Adjust this value to change the scale of the grille effect
        //float grille = fmod(gid.x, grillePeriod) / grillePeriod;
        //color.rgb *= float3(grille, 1.0 - abs(grille - 0.5), 1.0 - grille);

        // Scanline effect
        float scanlineStrength = 0;  // Adjust this value to change the strength of the scanline effect
        float scanlineScale = 1.0;  // Adjust this value to change the scale of the scanline effect
        float scanline = 1.0 - scanlineStrength * fmod(gid.y * scanlineScale, 1.0);
        color.rgb *= scanline;
        color.rgb -= 0.5 * color.rgb * clamp(2.0 * cos(3.14 * (uv.y * 240.0)), 0.0, 1.0);

        output.write(color, gid);
    }
}
