const std = @import("std");
const glfw = @import("glfw");
const kn = std.os.windows.kernel32;
const c = @cImport({
    @cInclude("wgpu.h");
});
const DynLib = std.DynLib;

//
fn requestAdapterCallback(status: c.WGPURequestAdapterStatus, received: c.WGPUAdapter, message: [*c]const u8, userdata: ?*c_void) callconv(.C) void {
    _ = status;
    _ = message;
    @ptrCast(*c.WGPUAdapter, @alignCast(@alignOf(c.WGPUAdapter), userdata.?)).* = received;
}

//binding
var wgpuInstanceCreateSurface: fn (c.WGPUInstance, *const c.WGPUSurfaceDescriptor) c.WGPUSurface = undefined;
var wgpuInstanceRequestAdapter: fn (
    c.WGPUInstance,
    *const c.WGPURequestAdapterOptions,
    c.WGPURequestAdapterCallback,
    *c_void,
) void = undefined;

pub fn main() anyerror!void {
    var wgpu = try DynLib.open("libs/libwgpu.dll");
    // dynamic load fn pointer
    wgpuInstanceCreateSurface = wgpu.lookup(
        @TypeOf(wgpuInstanceCreateSurface),
        "wgpuInstanceCreateSurface",
    ) orelse unreachable;
    wgpuInstanceRequestAdapter = wgpu.lookup(
        @TypeOf(wgpuInstanceRequestAdapter),
        "wgpuInstanceRequestAdapter",
    ) orelse unreachable;

    try glfw.init(.{});
    defer glfw.terminate();

    const width = 800;
    const height = 600;
    const window = try glfw.Window.create(width, height, "webgpu", null, null, .{
        .client_api = .no_api,
    });
    var hwnd = glfw.c.glfwGetWin32Window(window.handle);
    var hinstance = kn.GetModuleHandleW(null);
    const surface = wgpuInstanceCreateSurface(null, &.{
        .label = null,
        .nextInChain = @ptrCast(*const c.WGPUChainedStruct, &c.WGPUSurfaceDescriptorFromWindowsHWND{
            .chain = .{
                .next = null,
                .sType = c.WGPUSType_SurfaceDescriptorFromWindowsHWND,
            },
            .hinstance = hinstance,
            .hwnd = hwnd,
        }),
    });
    var adapter: c.WGPUAdapter = undefined;
    wgpuInstanceRequestAdapter(null, &.{
        .nextInChain = null,
        .compatibleSurface = surface,
        .powerPreference = undefined,
        .forceFallbackAdapter = undefined,
    }, requestAdapterCallback, @ptrCast(*c_void, &adapter));

    while (!window.shouldClose()) {
        try glfw.pollEvents();
    }
}
