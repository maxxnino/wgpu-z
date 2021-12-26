const std = @import("std");
const windows = std.os.windows;
const glfw = @import("glfw");
const triangle_shader = @embedFile("shader/triangle.wgsl");
const Wgpu = @import("Wgpu.zig");
const Gfx = @This();

device: Wgpu.Device,
is_device: bool = false,
surface: Wgpu.Surface,
adapter: Wgpu.Adapter,
is_adapter: bool = false,
queue: Wgpu.Queue,

swapchain: Wgpu.SwapChain,
frame_buffer: Wgpu.TextureView,
swapchain_des: Wgpu.SwapChainDescriptor,
depth_stencil: Depthstencil,

window: glfw.Window,
wb: Wgpu,
encoder: Wgpu.CommandEncoder,
render_pass: Wgpu.RenderPassEncoder,

const ShaderType = enum {
    spirv,
    wgsl,
};
const Depthstencil = struct {
    texture: Wgpu.Texture,
    view: Wgpu.TextureView,
    att_desc: Wgpu.RenderPassDepthStencilAttachment,
};

pub fn init(wb: Wgpu, window: glfw.Window) !Gfx {
    const use_discrete_gpu = true;
    var gfx: Gfx = undefined;

    gfx.window = window;
    gfx.wb = wb;
    gfx.encoder = .null_handle;
    gfx.render_pass = .null_handle;

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
        // selectable backend,
        // .nextInChain = Wgpu.toChainedStruct(&Wgpu.AdapterExtras{
        //     .chain = .{ .next = null, .sType = .AdapterExtras },
        //     .backend = .Vulkan,
        // }),
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
            &Wgpu.DeviceExtras{
                .chain = .{ .next = null, .sType = .DeviceExtras },
                .nativeFeatures = undefined,
                .label = "Device",
                .tracePath = null,
            },
        ),
        .label = null,
        .requiredLimits = &.{
            .nextInChain = null,
            .limits = undefined,
        },
        .requiredFeaturesCount = 1,
        .requiredFeatures = @ptrCast([*]const Wgpu.FeatureName, &Wgpu.FeatureName.Undefined),
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
    gfx.createDepthStencil();

    return gfx;
}

pub fn createDepthStencil(gfx: *Gfx) void {
    const depth_texture_desc = Wgpu.TextureDescriptor{
        .usage = .{ .RenderAttachment = true},
        .format = .Depth24PlusStencil8,
        .dimension = .@"2D",
        .mipLevelCount = 1,
        .sampleCount = 1,
        .size = .{
            .width = gfx.swapchain_des.width,
            .height = gfx.swapchain_des.height,
            .depthOrArrayLayers = 1,
        },
    };
    gfx.depth_stencil.texture = gfx.wb.deviceCreateTexture(gfx.device, &depth_texture_desc);

    const depth_texture_view_dec = Wgpu.TextureViewDescriptor{
        .format = depth_texture_desc.format,
        .dimension = .@"2D",
        .baseMipLevel = 0,
        .mipLevelCount = 1,
        .baseArrayLayer = 0,
        .arrayLayerCount = 1,
        .aspect = .All,
    };
    gfx.depth_stencil.view = gfx.wb.textureCreateView(gfx.depth_stencil.texture, &depth_texture_view_dec);

    gfx.depth_stencil.att_desc = Wgpu.RenderPassDepthStencilAttachment{
        .view = gfx.depth_stencil.view,
        .depthLoadOp = .Clear,
        .depthStoreOp = .Store,
        .clearDepth = 1.0,
        .depthReadOnly = false,
        .stencilLoadOp = .Clear,
        .stencilStoreOp = .Store,
        .clearStencil = 0,
        .stencilReadOnly = false,
    };
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
        .depthStencilAttachment = &gfx.depth_stencil.att_desc,
        .occlusionQuerySet = undefined,
    });
}

pub fn bindPipeline(gfx: Gfx, pipeline: Wgpu.RenderPipeline) void {
    gfx.wb.renderPassEncoderSetPipeline(gfx.render_pass, pipeline);
}

pub fn draw(gfx: Gfx, vertex_buffer: Wgpu.Buffer, index_buffer: Wgpu.Buffer, indices_count: u32) void {
    gfx.wb.renderPassEncoderSetVertexBuffer(gfx.render_pass, 0, vertex_buffer, 0, Wgpu.WHOLE_SIZE);
    gfx.wb.renderPassEncoderSetIndexBuffer(gfx.render_pass, index_buffer, .Uint16, 0, Wgpu.WHOLE_SIZE);
    gfx.wb.renderPassEncoderDrawIndexed(gfx.render_pass, indices_count, 1, 0, 0, 0);
}

pub fn endFrame(gfx: *Gfx) void {
    gfx.wb.renderPassEncoderEndPass(gfx.render_pass);
    const cmd_buffer = gfx.wb.commandEncoderFinish(gfx.encoder, &.{ .label = null });
    gfx.wb.queueSubmit(gfx.queue, 1, @ptrCast([*]const Wgpu.CommandBuffer, &cmd_buffer));
    gfx.wb.swapChainPresent(gfx.swapchain);

    gfx.wb.textureViewDrop(gfx.frame_buffer);
}

/// Note: remeber change this with buffer layout
pub fn getSwapchainFormat(gfx: Gfx) Wgpu.TextureFormat {
    return gfx.swapchain_des.format;
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

pub fn createUniformBuffer(gfx: Gfx, usage: Wgpu.BufferUsage, size: usize, label: [*:0]const u8) Wgpu.Buffer {
    const usage_flag = usage.merge(.{ .CopyDst = true, .Uniform = true });
    const buffer = gfx.wb.deviceCreateBuffer(gfx.device, &.{
        .label = label,
        .usage = usage_flag,
        .size = size,
        .mappedAtCreation = false,
    });
    return buffer;
}
pub fn queueWriteBuffer(gfx: Gfx, buffer: Wgpu.Buffer, offset: usize, data: anytype, size: usize) void {
    gfx.wb.queueWriteBuffer(gfx.queue, buffer, offset, @ptrCast(*const anyopaque, data), size);
}

pub fn createShader(gfx: Gfx, shader_type: ShaderType, data: []const u8) Wgpu.ShaderModule {
    const shader_des: Wgpu.ShaderModuleDescriptor = switch (shader_type) {
        .spirv => .{
            .nextInChain = Wgpu.toChainedStruct(&Wgpu.ShaderModuleSPIRVDescriptor{
                .chain = .{
                    .next = null,
                    .sType = .ShaderModuleSPIRVDescriptor,
                },
                .codeSize = @truncate(u32, data.len) / @sizeOf(u32),
                .code = @ptrCast([*]const u32, @alignCast(@alignOf(u32), data.ptr)),
            }),
            .label = null,
        },
        .wgsl => .{
            .nextInChain = Wgpu.toChainedStruct(&Wgpu.ShaderModuleWGSLDescriptor{
                .chain = .{
                    .next = null,
                    .sType = .ShaderModuleWGSLDescriptor,
                },
                .code = data.ptr,
            }),
            .label = null,
        },
    };
    return gfx.wb.deviceCreateShaderModule(gfx.device, &shader_des);
}

pub fn getAspecRatio(gfx: Gfx) f32 {
    return gfx.swapchain_des.width / gfx.swapchain_des.height;
}

export fn requestAdapterCallback(
    status: Wgpu.RequestAdapterStatus,
    received: Wgpu.Adapter,
    message: [*:0]const u8,
    userdata: *anyopaque,
) void {
    _ = message;
    switch (status) {
        .Success => {
            var gfx = @ptrCast(*Gfx, @alignCast(@alignOf(Gfx), userdata));
            gfx.adapter = received;
            gfx.is_adapter = true;
        },
        .Unavailable, .Error, .Unknown => std.log.err("Can't aquire adapter {s}", .{@tagName(status)}),
        else => unreachable,
    }
}

export fn requestDeviceCallback(
    status: Wgpu.RequestDeviceStatus,
    received: Wgpu.Device,
    message: [*:0]const u8,
    userdata: *anyopaque,
) void {
    _ = message;
    switch (status) {
        .Success => {
            var gfx = @ptrCast(*Gfx, @alignCast(@alignOf(Gfx), userdata));
            gfx.device = received;
            gfx.is_device = true;
        },
        .Error, .Unknown => std.log.err("Can't aquire device {s}", .{@tagName(status)}),
        else => unreachable,
    }
}

export fn logCallback(level: Wgpu.LogLevel, msg: [*:0]const u8) void {
    std.log.info("[{s}] {s}", .{ @tagName(level), msg });
}

pub fn initializeLog(gfx: Gfx) void {
    gfx.wb.setLogCallback(logCallback);
    // gfx.wb.setLogLevel(.Debug);
    gfx.wb.setLogLevel(.Info);
}
