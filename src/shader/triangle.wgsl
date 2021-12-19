type float3 = vec3<f32>;
type float4 = vec4<f32>;

struct VertexInput {
    [[location(0)]] position: float3;
    [[location(1)]] color: float3;
};

struct VertexOutput {
    // This is the equivalent of gl_Position in GLSL

    [[builtin(position)]] position: float4;
    [[location(0)]] color: float4;
};

[[stage(vertex)]]
fn vertex_main(vert: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    out.color = float4(vert.color, 1.0);
    out.position = float4(vert.position, 1.0);
    return out;
};

[[stage(fragment)]]
fn fragment_main(in: VertexOutput) -> [[location(0)]] float4 {
    return float4(in.color);
}
