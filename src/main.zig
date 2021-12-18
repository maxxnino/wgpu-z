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

    const shader = wgpu.wgpuDeviceCreateShaderModule(device, &.{
        .nextInChain = wb.toChainedStruct(&wb.WGPUShaderModuleWGSLDescriptor{
            .chain = .{
                .next = null,
                .sType = .ShaderModuleWGSLDescriptor,
            },
            .source = triangle_shader,
        }),
        .label = null,
    });
    const piptline_layout = wgpu.wgpuDeviceCreatePipelineLayout(device, &.{
        .bindGroupLayoutCount = 0,
        .bindGroupLayouts = null,
    });
    const swap_chain_format = wgpu.wgpuSurfaceGetPreferredFormat(surface, adapter);

    const pipeline = wgpu.wgpuDeviceCreateRenderPipeline(device, &(wb.WGPURenderPipelineDescriptor){
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
            .targets = @ptrCast([*]wb.WGPUColorTargetState, &wb.WGPUColorTargetState{
                .format = swap_chain_format,
                .blend = &.{
                    .color = .{ .srcFactor = .One, .dstFactor = .Zero, .operation = .Add },
                    .alpha = .{ .srcFactor = .One, .dstFactor = .Zero, .operation = .Add },
                },
                .writeMask = wb.WGPUColorWriteMask.all,
            }),
            .constantCount = 0,
            .constants = undefined,
        },
        .depthStencil = null,
    });

    var prev_size = try window.getSize();
    var swap_chain = wgpu.wgpuDeviceCreateSwapChain(device, surface, &.{
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

            swap_chain = wgpu.wgpuDeviceCreateSwapChain(device, surface, &.{
                .usage = .{ .RenderAttachment = true },
                .format = swap_chain_format,
                .width = size.width,
                .height = size.height,
                .presentMode = .Fifo,
            });
        }

        const next_texture = wgpu.wgpuSwapChainGetCurrentTextureView(swap_chain);
        std.debug.assert(next_texture != .null_handle);

        const encoder = wgpu.wgpuDeviceCreateCommandEncoder(device, &.{ .label = "Command Encoder" });

        const render_pass = wgpu.wgpuCommandEncoderBeginRenderPass(encoder, &.{
            .colorAttachments = @ptrCast([*]const wb.WGPURenderPassColorAttachment, &wb.WGPURenderPassColorAttachment{
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
        wgpu.wgpuRenderPassEncoderSetPipeline(render_pass, pipeline);
        wgpu.wgpuRenderPassEncoderDraw(render_pass, 3, 1, 0, 0);
        wgpu.wgpuRenderPassEncoderEndPass(render_pass);

        const queue = wgpu.wgpuDeviceGetQueue(device);
        const cmd_buffer = wgpu.wgpuCommandEncoderFinish(encoder, &.{ .label = null });
        wgpu.wgpuQueueSubmit(queue, 1, @ptrCast([*]const wb.WGPUCommandBuffer, &cmd_buffer));
        wgpu.wgpuSwapChainPresent(swap_chain);

        try glfw.pollEvents();
    }
}
