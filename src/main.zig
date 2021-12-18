const std = @import("std");
const glfw = @import("glfw");
const kn = std.os.windows.kernel32;
const wb = @import("wgpu_binding.zig");
const triangle_shader = @embedFile("shader/triangle.wgsl");
const DynLib = std.DynLib;
const loadAllFromDynLib = @import("wgpu.zig").loadAllFromDynLib;

fn requestAdapterCallback(
    status: wb.WGPURequestAdapterStatus,
    received: wb.WGPUAdapter,
    message: [*:0]const u8,
    userdata: *c_void,
) callconv(.C) void {
    _ = status;
    _ = message;
    @ptrCast(*wb.WGPUAdapter, @alignCast(@alignOf(wb.WGPUAdapter), userdata)).* = received;
}

fn requestDeviceCallback(
    status: wb.WGPURequestDeviceStatus,
    received: wb.WGPUDevice,
    message: [*:0]const u8,
    userdata: *c_void,
) callconv(.C) void {
    _ = status;
    _ = message;
    @ptrCast(*wb.WGPUDevice, @alignCast(@alignOf(wb.WGPUDevice), userdata)).* = received;
}
pub fn main() anyerror!void {
    var lib = try DynLib.open("libs/libwgpu.dll");
    defer lib.close();
    // dynamic load fn pointer
    const wgpu = try loadAllFromDynLib(&lib);

    try glfw.init(.{});
    defer glfw.terminate();

    const width = 800;
    const height = 600;
    const window = try glfw.Window.create(width, height, "webgpu", null, null, .{
        .client_api = .no_api,
    });
    var hwnd = glfw.c.glfwGetWin32Window(window.handle);
    var hinstance = kn.GetModuleHandleW(null);
    const surface = wgpu.wgpuInstanceCreateSurface(.null_handle, &.{
        .label = null,
        .nextInChain = wb.toChainedStruct(&wb.WGPUSurfaceDescriptorFromWindowsHWND{
            .chain = .{
                .next = null,
                .sType = .SurfaceDescriptorFromWindowsHWND,
            },
            .hinstance = hinstance,
            .hwnd = hwnd,
        }),
    });
    var adapter: wb.WGPUAdapter = undefined;
    wgpu.wgpuInstanceRequestAdapter(.null_handle, &.{
        .nextInChain = null,
        .compatibleSurface = surface,
        .powerPreference = undefined,
        .forceFallbackAdapter = undefined,
    }, requestAdapterCallback, @ptrCast(*c_void, &adapter));

    var device: wb.WGPUDevice = undefined;
    wgpu.wgpuAdapterRequestDevice(adapter, &.{
        .nextInChain = wb.toChainedStruct(
            &wb.WGPUDeviceExtras{ .chain = .{
                .next = null,
                .sType = .DeviceExtras,
            }, .nativeFeatures = undefined, .label = "Device", .tracePath = null },
        ),
        .requiredLimits = &wb.WGPURequiredLimits{
            .nextInChain = null,
            .limits = .{
                .maxBindGroups = 1,
            },
        },
        .requiredFeaturesCount = 0,
        .requiredFeatures = undefined,
    }, requestDeviceCallback, @ptrCast(*c_void, &device));
    const wgsl_descriptor = wb.WGPUShaderModuleWGSLDescriptor{
        .chain = .{
            .next = null,
            .sType = .ShaderModuleWGSLDescriptor,
        },
        .source = triangle_shader,
    };
    const shader = wgpu.wgpuDeviceCreateShaderModule(device, &.{
        .nextInChain = wb.toChainedStruct(&wgsl_descriptor),
        .label = null,
    });
    while (!window.shouldClose()) {
        try glfw.pollEvents();
    }
}
