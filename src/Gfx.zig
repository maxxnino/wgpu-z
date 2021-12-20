const std = @import("std");
const windows = std.os.windows;
const glfw = @import("glfw");
const triangle_shader = @embedFile("shader/triangle.wgsl");
const Wgpu = @import("Wgpu.zig");
const Gfx = @This();

device: Wgpu.Device,
surface: Wgpu.Surface,
adapter: Wgpu.Adapter,
queue: Wgpu.Queue,

swapchain: Wgpu.SwapChain,
frame_buffer: Wgpu.TextureView,
swapchain_des: Wgpu.SwapChainDescriptor,

window: glfw.Window,
wb: Wgpu,
encoder: Wgpu.CommandEncoder,
render_pass: Wgpu.RenderPassEncoder,
pipeline: Wgpu.RenderPipeline,

pub fn init(wb: Wgpu, window: glfw.Window) !Gfx {
    const use_discrete_gpu = true;
    var gfx: Gfx = undefined;

    gfx.window = window;
    gfx.wb = wb;
    gfx.encoder = .null_handle;
    gfx.render_pass = .null_handle;
    gfx.pipeline = .null_handle;

    const hwnd = window.getNativeWindow32();
    const hinstance = windows.kernel32.GetModuleHandleW(null);
    gfx.surface = wb.instanceCreateSurface(.null_handle, &.{
        .label = null,
        .nextInChain = Wgpu.toChainedStruct(&Wgpu.SurfaceDescriptorFromWindowsHWND{
            .chain = .{
                .next = null,
                .sType = .SurfaceDescriptorFromWindowsHWND,
            },
            .hinstance = hinstance,
            .hwnd = hwnd,
        }),
    });
    wb.instanceRequestAdapter(.null_handle, &.{
        .nextInChain = null,
        .compatibleSurface = gfx.surface,
        .powerPreference = if (use_discrete_gpu) .HighPerformance else .LowPower,
        .forceFallbackAdapter = undefined,
    }, requestAdapterCallback, @ptrCast(*anyopaque, &gfx));

    var properties: Wgpu.AdapterProperties = undefined;
    wb.adapterGetProperties(gfx.adapter, &properties);
    std.log.info("Backend {s} on {s}", .{
        @tagName(properties.backendType),
        @tagName(properties.adapterType),
    });

    wb.adapterRequestDevice(gfx.adapter, &.{
        .nextInChain = Wgpu.toChainedStruct(
            &Wgpu.DeviceExtras{ .chain = .{
                .next = null,
                .sType = .DeviceExtras,
            }, .nativeFeatures = undefined, .label = "Device", .tracePath = null },
        ),
        .requiredLimits = @ptrCast([*]const Wgpu.RequiredLimits, &Wgpu.RequiredLimits{
            .nextInChain = null,
            .limits = .{
                .maxBindGroups = 1,
            },
        }),
        .requiredFeaturesCount = 0,
        .requiredFeatures = undefined,
    }, requestDeviceCallback, @ptrCast(*anyopaque, &gfx));

    const size = try window.getSize();
    gfx.swapchain_des = Wgpu.SwapChainDescriptor{
        .usage = Wgpu.TextureUsage{ .RenderAttachment = true },
        .format = wb.surfaceGetPreferredFormat(gfx.surface, gfx.adapter),
        .width = size.width,
        .height = size.height,
        .presentMode = .Fifo,
    };
    gfx.swapchain = wb.deviceCreateSwapChain(gfx.device, gfx.surface, &gfx.swapchain_des);
    gfx.queue = wb.deviceGetQueue(gfx.device);

    return gfx;
}

pub fn beginFrame(gfx: *Gfx) !void {
    try gfx.aquireFrameBuffer();
    gfx.encoder = gfx.wb.deviceCreateCommandEncoder(gfx.device, &.{ .label = "Command Encoder" });
    gfx.render_pass = gfx.wb.commandEncoderBeginRenderPass(gfx.encoder, &.{
        .colorAttachments = @ptrCast([*]const Wgpu.RenderPassColorAttachment, &Wgpu.RenderPassColorAttachment{
            .view = gfx.frame_buffer,
            .resolveTarget = .null_handle,
            .loadOp = .Clear,
            .storeOp = .Store,
            .clearColor = .{
                .r = 0.0,
                .g = 0.0,
                .b = 0.0,
                .a = 1.0,
            },
        }),
        .colorAttachmentCount = 1,
        .depthStencilAttachment = null,
        .occlusionQuerySet = undefined,
    });
    gfx.wb.renderPassEncoderSetPipeline(gfx.render_pass, gfx.pipeline);
}

pub fn draw(gfx: Gfx, vertex_buffer: Wgpu.Buffer, index_buffer: Wgpu.Buffer, indices_count: u32) void {
    // gfx.wb.renderPassEncoderDraw(gfx.render_pass, 3, 1, 0, 0);

    // Bind triangle vertex buffer (contains position and colors)
    // wgpuRenderPassEncoderSetVertexBuffer(wgpu_context->rpass_enc, 0,
    //                                      vertices.buffer, 0, WGPU_WHOLE_SIZE);
    gfx.wb.renderPassEncoderSetVertexBuffer(gfx.render_pass, 0, vertex_buffer, 0, Wgpu.WHOLE_SIZE);

    // Bind triangle index buffer
    // wgpuRenderPassEncoderSetIndexBuffer(wgpu_context->rpass_enc, indices.buffer,
    //                                     WGPUIndexFormat_Uint16, 0,
    //                                     WGPU_WHOLE_SIZE);
    gfx.wb.renderPassEncoderSetIndexBuffer(gfx.render_pass, index_buffer, .Uint16, 0, Wgpu.WHOLE_SIZE);

    // Draw indexed triangle
    // wgpuRenderPassEncoderDrawIndexed(wgpu_context->rpass_enc, indices.count, 1, 0,
    //                                  0, 0);
    gfx.wb.renderPassEncoderDrawIndexed(gfx.render_pass, indices_count, 1, 0, 0, 0);
}

pub fn endFrame(gfx: *Gfx) void {
    gfx.wb.renderPassEncoderEndPass(gfx.render_pass);
    const cmd_buffer = gfx.wb.commandEncoderFinish(gfx.encoder, &.{ .label = null });
    gfx.wb.queueSubmit(gfx.queue, 1, @ptrCast([*]const Wgpu.CommandBuffer, &cmd_buffer));
    gfx.wb.swapChainPresent(gfx.swapchain);
    gfx.render_pass = .null_handle;
    gfx.encoder = .null_handle;
}

/// Note: remeber change this with buffer layout
pub fn createPipeline(gfx: *Gfx, vertex_layout: *const Wgpu.VertexBufferLayout) void {
    const shader = gfx.wb.deviceCreateShaderModule(gfx.device, &.{
        .nextInChain = Wgpu.toChainedStruct(&Wgpu.ShaderModuleWGSLDescriptor{
            .chain = .{
                .next = null,
                .sType = .ShaderModuleWGSLDescriptor,
            },
            .source = triangle_shader,
        }),
        .label = null,
    });
    const piptline_layout = gfx.wb.deviceCreatePipelineLayout(gfx.device, &.{
        .bindGroupLayoutCount = 0,
        .bindGroupLayouts = null,
    });

    gfx.pipeline = gfx.wb.deviceCreateRenderPipeline(gfx.device, &(Wgpu.RenderPipelineDescriptor){
        .label = "Render pipeline",
        .layout = piptline_layout,
        .vertex = .{
            .module = shader,
            .entryPoint = "vertex_main",
            .constantCount = 0,
            .constants = undefined,
            // Note: remeber change this with buffer layout
            .bufferCount = 1,
            .buffers = @ptrCast([*]const Wgpu.VertexBufferLayout, vertex_layout),
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
            .entryPoint = "fragment_main",
            .targetCount = 1,
            .targets = @ptrCast([*]const Wgpu.ColorTargetState, &Wgpu.ColorTargetState{
                .format = gfx.swapchain_des.format,
                .blend = &.{
                    .color = .{ .srcFactor = .One, .dstFactor = .Zero, .operation = .Add },
                    .alpha = .{ .srcFactor = .One, .dstFactor = .Zero, .operation = .Add },
                },
                .writeMask = Wgpu.ColorWriteMask.all,
            }),
            .constantCount = 0,
            .constants = undefined,
        },
        .depthStencil = null,
    });
}

pub fn aquireFrameBuffer(gfx: *Gfx) !void {
    const size = try gfx.window.getSize();
    if (gfx.swapchain_des.width != size.width or gfx.swapchain_des.height != size.height) {
        gfx.recreateSwapChain(size.width, size.height, .Fifo);
    }
    gfx.frame_buffer = gfx.wb.swapChainGetCurrentTextureView(gfx.swapchain);
    if (gfx.frame_buffer == .null_handle) return error.CannotAquireNextImage;
}

pub fn recreateSwapChain(gfx: *Gfx, width: u32, height: u32, present_mode: Wgpu.PresentMode) void {
    gfx.swapchain_des.width = width;
    gfx.swapchain_des.height = height;
    gfx.swapchain_des.presentMode = present_mode;
    gfx.swapchain = gfx.wb.deviceCreateSwapChain(gfx.device, gfx.surface, &gfx.swapchain_des);
}

pub fn createBufferFromData(gfx: Gfx, data: anytype, usage: Wgpu.BufferUsage, size: usize) Wgpu.Buffer {
    const usage_flag = usage.merge(.{ .CopyDst = true });
    const buffer = gfx.wb.deviceCreateBuffer(gfx.device, &.{
        .usage = usage_flag,
        .size = size,
        .mappedAtCreation = false,
    });
    gfx.queueWriteBuffer(buffer, 0, data, size);
    return buffer;
}

pub fn queueWriteBuffer(gfx: Gfx, buffer: Wgpu.Buffer, offset: usize, data: anytype, size: usize) void {
    gfx.wb.queueWriteBuffer(gfx.queue, buffer, offset, @ptrCast(*const anyopaque, data), size);
}

fn requestAdapterCallback(
    status: Wgpu.RequestAdapterStatus,
    received: Wgpu.Adapter,
    message: [*:0]const u8,
    userdata: *anyopaque,
) callconv(.C) void {
    _ = status;
    _ = message;
    var gfx = @ptrCast(*Gfx, @alignCast(@alignOf(Gfx), userdata));
    gfx.adapter = received;
}

fn requestDeviceCallback(
    status: Wgpu.RequestDeviceStatus,
    received: Wgpu.Device,
    message: [*:0]const u8,
    userdata: *anyopaque,
) callconv(.C) void {
    _ = status;
    _ = message;
    var gfx = @ptrCast(*Gfx, @alignCast(@alignOf(Gfx), userdata));
    gfx.device = received;
}
