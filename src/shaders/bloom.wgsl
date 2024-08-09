struct VertexOutput {
    @builtin(position) position: vec4f,
    @location(0) fragUV: vec2f,
}

// Fullscreen triangle
@vertex
fn vs_main(
  @builtin(vertex_index) VertexIndex: u32
) -> VertexOutput {
    var pos = array<vec2<f32>, 3>(
        vec2(-1, 3),
        vec2(3, -1),
        vec2(-1, -1)
    );
    var uv = array<vec2<f32>, 3>(
        vec2(0, -1),
        vec2(2, 1),
        vec2(0, 1)
    );

    var output : VertexOutput;
    output.position = vec4<f32>(pos[VertexIndex], 0.0, 1.0);
    output.fragUV = uv[VertexIndex];

    return output;
}

@group(0) @binding(0) var texture: texture_2d<f32>;
@group(0) @binding(1) var samp: sampler;

@fragment
fn fs_main(
    @location(0) fragUV: vec2f,
) -> @location(0) vec4<f32> {
    var color = textureSample(texture, samp, fragUV.xy);
    return vec4<f32>(color.xyz, 1.0);
}