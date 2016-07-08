//
//  Shaders.metal
//  LiquidHazard
//
//  Created by adan de la pena on 6/20/16.
//  Copyright © 2016 adan de la pena. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut {
    float4 position [[position]];
    float pointSize [[point_size]];
};

struct Uniforms {
    float4x4 ndcMatrix;
    float ptmRatio;
    float pointSize;
};

vertex VertexOut particle_vertex(const device packed_float2* vertex_array [[buffer(0)]],
                                 const device Uniforms& uniforms [[buffer(1)]],
                                 unsigned int vid [[vertex_id]]) {
    VertexOut vertexOut;
    float2 position = vertex_array[vid];
    vertexOut.position =
    uniforms.ndcMatrix * float4(position.x * uniforms.ptmRatio, position.y * uniforms.ptmRatio, 0, 1);
    vertexOut.pointSize = uniforms.pointSize;
    return vertexOut;
}

fragment half4 basic_fragment() {
    return half4(0.0, 0.0, 1.0, 1.0);
}
vertex float4 basic_vertex(const device packed_float3* vertex_array [[buffer(2)]],
                                 const device Uniforms& uniforms [[buffer(1)]],
                                 unsigned int vid [[vertex_id]]) {
    float3 position = vertex_array[vid];
    float4 ret =
    uniforms.ndcMatrix * float4(position.x, position.y, 0, 1);
    return ret;
}
fragment half4 goal_fragment(){
    return half4(0.0, 1.0, 0.0, .01);
}
fragment half4 wall_fragment(){
    return half4(1.0);
}


