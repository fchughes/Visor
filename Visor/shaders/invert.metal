/*
  invert.metal
  Visor

  Created by Forest Hughes on 6/30/23.
  Copyright © 2023 Apple. All rights reserved.
*/

#include <metal_stdlib>
using namespace metal;


half4 invertColor(half4 color) {
    return half4((1.0 - color.rgb), color.a);
}

kernel void computeShader(texture2d<half, access::read> inTexture [[ texture (0) ]],
                               texture2d<half, access::read_write> outTexture [[ texture (1) ]],
                               uint2 gid [[ thread_position_in_grid ]]) {
    half4 color = inTexture.read(gid).rgba;
    outTexture.write(invertColor(color), gid);
}
