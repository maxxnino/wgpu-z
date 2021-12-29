const std = @import("std");
const glfw = @import("glfw");
const kn = std.os.windows.kernel32;
const builtin = @import("builtin");
const c = @import("c.zig");
const spv_vert = @embedFile("../assets/shaders/glsl/pbribl/genbrdflut.vert.spv");
const spv_frag = @embedFile("../assets/shaders/glsl/pbribl/genbrdflut.frag.spv");
const assert = std.debug.assert;
const Wgpu = @import("Wgpu.zig");
const Gfx = @import("Gfx.zig");


pub fn createPipeline(gfx: Gfx) Wgpu.RenderPipeline {
    const vertex_module = gfx.createShader(.spirv, spv_vert);
    defer gfx.wb.shaderModuleDrop(vertex_module);
    const fragment_module = gfx.createShader(.spirv, spv_frag);
    defer gfx.wb.shaderModuleDrop(fragment_module);

    const pipeline_layout = gfx.wb.deviceCreatePipelineLayout(gfx.device, &.{
        .bindGroupLayoutCount = 0,
        .bindGroupLayouts = null,
    });

    defer gfx.wb.pipelineLayoutDrop(pipeline_layout);

    const stencil_face = Wgpu.StencilFaceState{
        .compare = .Always,
        .failOp = .Keep,
        .depthFailOp = .Keep,
        .passOp = .Keep,
    };

    return gfx.wb.deviceCreateRenderPipeline(gfx.device, &Wgpu.RenderPipelineDescriptor{
        .label = "Two Cube Render Pipeline",
        .layout = pipeline_layout,
        .vertex = .{
            .module = vertex_module,
            .entryPoint = "main",
            .constantCount = 0,
            .constants = undefined,
            // Note: remeber change this with buffer layout
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
            .module = fragment_module,
            .entryPoint = "main",
            .targetCount = 1,
            .targets = @ptrCast([*]const Wgpu.ColorTargetState, &Wgpu.ColorTargetState{
                .format = gfx.getSwapchainFormat(),
                .blend = &.{
                    .color = .{ .srcFactor = .One, .dstFactor = .Zero, .operation = .Add },
                    .alpha = .{ .srcFactor = .One, .dstFactor = .Zero, .operation = .Add },
                },
                .writeMask = Wgpu.ColorWriteMask.all,
            }),
            .constantCount = 0,
            .constants = undefined,
        },
        .depthStencil = &.{
            .nextInChain = null,
            .format = .Depth24PlusStencil8,
            .depthWriteEnabled = true,
            .depthCompare = .Less,
            .stencilFront = stencil_face,
            .stencilBack = stencil_face,
            .stencilReadMask = 0xffffffff,
            .stencilWriteMask = 0xffffffff,
            .depthBias = 0,
            .depthBiasSlopeScale = 0,
            .depthBiasClamp = 0,
        },
    });
}

pub fn main() anyerror!void {
    const lib_path = if (builtin.mode == .Debug) "libs/libwgpu-debug.dll" else "libs/libwgpu-release.dll";
    var lib = try std.DynLib.open(lib_path);
    defer lib.close();
    // dynamic load fn pointer
    const wb = try Wgpu.loadAllFromDynLib(&lib);

    try glfw.init(.{});
    defer glfw.terminate();

    var width: u32 = 800;
    var height: u32 = 600;
    const window = try glfw.Window.create(width, height, "webgpu", null, null, .{
        .client_api = .no_api,
    });
    var gfx = try Gfx.init(wb, window);
    gfx.initializeLog();

    const pipeline = createPipeline(gfx);
    defer gfx.wb.renderPipelineDrop(pipeline);


    while (!window.shouldClose()) {

        try gfx.beginFrame();
        gfx.bindPipeline(pipeline);

        gfx.wb.renderPassEncoderDraw(gfx.render_pass, 3, 1, 0, 0);

        gfx.endFrame();
        try glfw.pollEvents();
    }
}
