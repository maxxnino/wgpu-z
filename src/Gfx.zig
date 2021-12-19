const std = @import("std");
const windows = std.os.windows;
const glfw = @import("glfw");
const triangle_shader = @embedFile("shader/triangle.wgsl");
const Wgpu = @import("Wgpu.zig");
const Gfx = @This();

device: Wgpu.Device,
surface: Wgpu.Surface,
adapter: Wgpu.Adapter,

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
    }, requestAdapterCallback, @ptrCast(*c_void, &gfx));

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
    }, requestDeviceCallback, @ptrCast(*c_void, &gfx));

    const size = try window.getSize();
    gfx.swapchain_des = Wgpu.SwapChainDescriptor{
        .usage = Wgpu.TextureUsage{ .RenderAttachment = true },
        .format = wb.surfaceGetPreferredFormat(gfx.surface, gfx.adapter),
        .width = size.width,
        .height = size.height,
        .presentMode = .Fifo,
    };
    gfx.swapchain = wb.deviceCreateSwapChain(gfx.device, gfx.surface, &gfx.swapchain_des);

    return gfx;
}

pub fn beginFrame(self: *Gfx) !void {
    try self.aquireFrameBuffer();
    self.encoder = self.wb.deviceCreateCommandEncoder(self.device, &.{ .label = "Command Encoder" });
    self.render_pass = self.wb.commandEncoderBeginRenderPass(self.encoder, &.{
        .colorAttachments = @ptrCast([*]const Wgpu.RenderPassColorAttachment, &Wgpu.RenderPassColorAttachment{
            .view = self.frame_buffer,
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
    self.wb.renderPassEncoderSetPipeline(self.render_pass, self.pipeline);
}

pub fn draw(self: Gfx) void {
    self.wb.renderPassEncoderDraw(self.render_pass, 3, 1, 0, 0);
}

pub fn endFrame(self: *Gfx) void {
    self.wb.renderPassEncoderEndPass(self.render_pass);
    const queue = self.wb.deviceGetQueue(self.device);
    const cmd_buffer = self.wb.commandEncoderFinish(self.encoder, &.{ .label = null });
    self.wb.queueSubmit(queue, 1, @ptrCast([*]const Wgpu.CommandBuffer, &cmd_buffer));
    self.wb.swapChainPresent(self.swapchain);
    self.render_pass = .null_handle;
    self.encoder = .null_handle;
}

pub fn createPipeline(self: *Gfx) void {
    const shader = self.wb.deviceCreateShaderModule(self.device, &.{
        .nextInChain = Wgpu.toChainedStruct(&Wgpu.ShaderModuleWGSLDescriptor{
            .chain = .{
                .next = null,
                .sType = .ShaderModuleWGSLDescriptor,
            },
            .source = triangle_shader,
        }),
        .label = null,
    });
    const piptline_layout = self.wb.deviceCreatePipelineLayout(self.device, &.{
        .bindGroupLayoutCount = 0,
        .bindGroupLayouts = null,
    });

    self.pipeline = self.wb.deviceCreateRenderPipeline(self.device, &(Wgpu.RenderPipelineDescriptor){
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
            .targets = @ptrCast([*]const Wgpu.ColorTargetState, &Wgpu.ColorTargetState{
                .format = self.swapchain_des.format,
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

pub fn aquireFrameBuffer(self: *Gfx) !void {
    const size = try self.window.getSize();
    if (self.swapchain_des.width != size.width or self.swapchain_des.height != size.height) {
        self.recreateSwapChain(size.width, size.height, .Fifo);
    }
    self.frame_buffer = self.wb.swapChainGetCurrentTextureView(self.swapchain);
    if (self.frame_buffer == .null_handle) return error.CannotAquireNextImage;
}

pub fn recreateSwapChain(self: *Gfx, width: u32, height: u32, present_mode: Wgpu.PresentMode) void {
    self.swapchain_des.width = width;
    self.swapchain_des.height = height;
    self.swapchain_des.presentMode = present_mode;
    self.swapchain = self.wb.deviceCreateSwapChain(self.device, self.surface, &self.swapchain_des);
}

fn requestAdapterCallback(
    status: Wgpu.RequestAdapterStatus,
    received: Wgpu.Adapter,
    message: [*:0]const u8,
    userdata: *c_void,
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
    userdata: *c_void,
) callconv(.C) void {
    _ = status;
    _ = message;
    var gfx = @ptrCast(*Gfx, @alignCast(@alignOf(Gfx), userdata));
    gfx.device = received;
}
