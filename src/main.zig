const std = @import("std");
const glfw = @import("glfw");
const kn = std.os.windows.kernel32;
const builtin = @import("builtin");
const Wgpu = @import("Wgpu.zig");
const Gfx = @import("Gfx.zig");

const Vertex = struct {
    position: [3]f32,
    color: [3]f32,

    const stride = @sizeOf(Vertex);
    const vertex_attributes = [_]Wgpu.VertexAttribute{
        .{
            .format = .Float32x3,
            .offset = @offsetOf(Vertex, "position"),
            .shaderLocation = 0,
        },
        .{
            .format = .Float32x3,
            .offset = @offsetOf(Vertex, "color"),
            .shaderLocation = 1,
        },
    };
};
const Index = u16;

const vertices = [_]Vertex{
    .{
        .position = .{ 1.0, -1.0, 0.0 },
        .color = .{ 1.0, 0.0, 0.0 },
    },
    .{
        .position = .{ -1.0, -1.0, 0.0 },
        .color = .{ 0.0, 1.0, 0.0 },
    },
    .{
        .position = .{ 0.0, 1.0, 0.0 },
        .color = .{ 0.0, 0.0, 1.0 },
    },
};
const indices = [_]Index{
    0, 1, 2,
    0, // padding
};
pub fn main() anyerror!void {
    const lib_path = if (builtin.mode == .Debug) "libs/libwgpu-debug.dll" else "libs/libwgpu-release.dll";
    var lib = try std.DynLib.open(lib_path);
    defer lib.close();
    // dynamic load fn pointer
    const wb = try Wgpu.loadAllFromDynLib(&lib);

    try glfw.init(.{});
    defer glfw.terminate();

    const width = 800;
    const height = 600;
    const window = try glfw.Window.create(width, height, "webgpu", null, null, .{
        .client_api = .no_api,
    });

    var gfx = try Gfx.init(wb, window);

    const vertex_buffer = gfx.createBufferFromData(&vertices, .{ .Vertex = true }, @sizeOf(@TypeOf(vertices)));
    defer gfx.wb.bufferDestroy(vertex_buffer);
    const index_buffer = gfx.createBufferFromData(&indices, .{ .Index = true }, @sizeOf(@TypeOf(indices)));
    defer gfx.wb.bufferDestroy(index_buffer);
    const vsl = Wgpu.VertexBufferLayout{
        .arrayStride = Vertex.stride,
        .stepMode = .Vertex,
        .attributeCount = @truncate(u32, Vertex.vertex_attributes.len),
        .attributes = @ptrCast([*]const Wgpu.VertexAttribute, &Vertex.vertex_attributes),
    };

    gfx.createPipeline(&vsl);
    while (!window.shouldClose()) {
        try gfx.beginFrame();

        gfx.draw(vertex_buffer, index_buffer, @truncate(u32, indices.len));

        gfx.endFrame();
        try glfw.pollEvents();
    }
}
