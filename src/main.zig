const std = @import("std");
const glfw = @import("glfw");
const kn = std.os.windows.kernel32;
const builtin = @import("builtin");
const Wgpu = @import("Wgpu.zig");
const Gfx = @import("Gfx.zig");

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
    gfx.createPipeline();


    while (!window.shouldClose()) {
        try gfx.beginFrame();
        defer gfx.endFrame();
        gfx.draw();

        try glfw.pollEvents();
    }
}
