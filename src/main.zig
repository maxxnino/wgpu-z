const std = @import("std");
const glfw = @import("glfw");
const kn = std.os.windows.kernel32;
const builtin = @import("builtin");
const wgpu = @import("wgpu.zig");
const triangle_shader = @embedFile("shader/triangle.wgsl");
const DynLib = std.DynLib;

fn requestAdapterCallback(
    status: wgpu.RequestAdapterStatus,
    received: wgpu.Adapter,
    message: [*:0]const u8,
    userdata: *c_void,
) callconv(.C) void {
    _ = status;
    _ = message;
    @ptrCast(*wgpu.Adapter, @alignCast(@alignOf(wgpu.Adapter), userdata)).* = received;
}

fn requestDeviceCallback(
    status: wgpu.RequestDeviceStatus,
    received: wgpu.Device,
    message: [*:0]const u8,
    userdata: *c_void,
) callconv(.C) void {
    _ = status;
    _ = message;
    @ptrCast(*wgpu.Device, @alignCast(@alignOf(wgpu.Device), userdata)).* = received;
}
pub fn main() anyerror!void {
    const lib_path = if (builtin.mode == .Debug) "libs/libwgpu-debug.dll" else "libs/libwgpu-release.dll";
    const use_discrete_gpu = true;
    var lib = try DynLib.open(lib_path);
    defer lib.close();

    // dynamic load fn pointer
    const wb = try wgpu.loadAllFromDynLib(&lib);

    try glfw.init(.{});
    defer glfw.terminate();

    const width = 800;
    const height = 600;
    const window = try glfw.Window.create(width, height, "webgpu", null, null, .{
        .client_api = .no_api,
    });
    const hwnd = window.getNativeWindow32();
    var hinstance = kn.GetModuleHandleW(null);
    const surface = wb.instanceCreateSurface(.null_handle, &.{
        .label = null,
        .nextInChain = wgpu.toChainedStruct(&wgpu.SurfaceDescriptorFromWindowsHWND{
            .chain = .{
                .next = null,
                .sType = .SurfaceDescriptorFromWindowsHWND,
            },
            .hinstance = hinstance,
            .hwnd = hwnd,
        }),
    });
    var adapter: wgpu.Adapter = undefined;
    wb.instanceRequestAdapter(.null_handle, &.{
        .nextInChain = null,
        .compatibleSurface = surface,
        .powerPreference = if (use_discrete_gpu) .HighPerformance else .LowPower,
        .forceFallbackAdapter = undefined,
    }, requestAdapterCallback, @ptrCast(*c_void, &adapter));

    var properties: wgpu.AdapterProperties = undefined;
    wb.adapterGetProperties(adapter, &properties);

    std.log.info("Backend {s} on {s}", .{
        @tagName(properties.backendType),
        @tagName(properties.adapterType),
    });

    var device: wgpu.Device = undefined;
    wb.adapterRequestDevice(adapter, &.{
        .nextInChain = wgpu.toChainedStruct(
            &wgpu.DeviceExtras{ .chain = .{
                .next = null,
                .sType = .DeviceExtras,
            }, .nativeFeatures = undefined, .label = "Device", .tracePath = null },
        ),
        .requiredLimits = @ptrCast([*]const wgpu.RequiredLimits, &wgpu.RequiredLimits{
            .nextInChain = null,
            .limits = .{
                .maxBindGroups = 1,
            },
        }),
        .requiredFeaturesCount = 0,
        .requiredFeatures = undefined,
    }, requestDeviceCallback, @ptrCast(*c_void, &device));

    const shader = wb.deviceCreateShaderModule(device, &.{
        .nextInChain = wgpu.toChainedStruct(&wgpu.ShaderModuleWGSLDescriptor{
            .chain = .{
                .next = null,
                .sType = .ShaderModuleWGSLDescriptor,
            },
            .source = triangle_shader,
        }),
        .label = null,
    });
    const piptline_layout = wb.deviceCreatePipelineLayout(device, &.{
        .bindGroupLayoutCount = 0,
        .bindGroupLayouts = null,
    });
    const swap_chain_format = wb.surfaceGetPreferredFormat(surface, adapter);

    const pipeline = wb.deviceCreateRenderPipeline(device, &(wgpu.RenderPipelineDescriptor){
        .label = "Render pipeline",
        .layout = piptline_layout,
        .vertex = .{
            .module = shader,
            .entryPoint = "vs_main",
            .constantCount = 0,
            .constants = undefined,
            .bufferCount = 0,
            .buffers = undefined,
        },
        .primitive = .{
            .topology = .TriangleList,
            .stripIndexFormat = .Undefined,
            .frontFace = .CCW,
            .cullMode = .None,
        },
        .multisample = .{
            .count = 1,
            .mask = ~@as(u32, 0),
            .alphaToCoverageEnabled = false,
        },
        .fragment = &.{
            .module = shader,
            .entryPoint = "fs_main",
            .targetCount = 1,
            .targets = @ptrCast([*]const wgpu.ColorTargetState, &wgpu.ColorTargetState{
                .format = swap_chain_format,
                .blend = &.{
                    .color = .{ .srcFactor = .One, .dstFactor = .Zero, .operation = .Add },
                    .alpha = .{ .srcFactor = .One, .dstFactor = .Zero, .operation = .Add },
                },
                .writeMask = wgpu.ColorWriteMask.all,
            }),
            .constantCount = 0,
            .constants = undefined,
        },
        .depthStencil = null,
    });

    var prev_size = try window.getSize();
    var swap_chain = wb.deviceCreateSwapChain(device, surface, &.{
        .usage = .{ .RenderAttachment = true },
        .format = swap_chain_format,
        .width = prev_size.width,
        .height = prev_size.height,
        .presentMode = .Fifo,
    });

    while (!window.shouldClose()) {
        const size = try window.getSize();
        if (size.width != prev_size.width or size.height != prev_size.height) {
            prev_size = size;

            swap_chain = wb.deviceCreateSwapChain(device, surface, &.{
                .usage = .{ .RenderAttachment = true },
                .format = swap_chain_format,
                .width = size.width,
                .height = size.height,
                .presentMode = .Fifo,
            });
        }

        const next_texture = wb.swapChainGetCurrentTextureView(swap_chain);
        std.debug.assert(next_texture != .null_handle);

        const encoder = wb.deviceCreateCommandEncoder(device, &.{ .label = "Command Encoder" });

        const render_pass = wb.commandEncoderBeginRenderPass(encoder, &.{
            .colorAttachments = @ptrCast([*]const wgpu.RenderPassColorAttachment, &wgpu.RenderPassColorAttachment{
                .view = next_texture,
                .resolveTarget = .null_handle,
                .loadOp = .Clear,
                .storeOp = .Store,
                .clearColor = .{
                    .r = 0.0,
                    .g = 1.0,
                    .b = 0.0,
                    .a = 1.0,
                },
            }),
            .colorAttachmentCount = 1,
            .depthStencilAttachment = null,
            .occlusionQuerySet = undefined,
        });
        wb.renderPassEncoderSetPipeline(render_pass, pipeline);
        wb.renderPassEncoderDraw(render_pass, 3, 1, 0, 0);
        wb.renderPassEncoderEndPass(render_pass);

        const queue = wb.deviceGetQueue(device);
        const cmd_buffer = wb.commandEncoderFinish(encoder, &.{ .label = null });
        wb.queueSubmit(queue, 1, @ptrCast([*]const wgpu.CommandBuffer, &cmd_buffer));
        wb.swapChainPresent(swap_chain);

        try glfw.pollEvents();
    }
}
