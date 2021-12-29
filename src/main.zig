const std = @import("std");
const glfw = @import("glfw");
const kn = std.os.windows.kernel32;
const builtin = @import("builtin");
const c = @import("c.zig");
const spv_vert = @embedFile("../assets/shaders/skybox/shader.vert.spv");
const spv_frag = @embedFile("../assets/shaders/skybox/shader.frag.spv");
const z = @import("zalgebra");
const assert = std.debug.assert;
const Mat4 = z.Mat4;
const Vec3 = z.Vec3;
const Vec2 = z.Vec2;
const Wgpu = @import("Wgpu.zig");
const Gfx = @import("Gfx.zig");

const Texture = struct {
    texture: Wgpu.Texture,
    view: Wgpu.TextureView,
    sampler: Wgpu.Sampler,
    des: Wgpu.TextureDescriptor,

    pub fn loadCubeMapFromFile(gfx: Gfx, paths: []const []const u8, label: ?[*:0]const u8) Texture {
        const face = 6;
        assert(paths.len == face);
        var tex_width: i32 = 0;
        var tex_height: i32 = 0;
        var tex_channels: i32 = 0;
        var byte_per_image: usize = 0;
        var pixels_array: [face][*c]u8 = undefined;
        for (paths) |path, i| {
            const prev_width = tex_width;
            const prev_height = tex_height;
            const prev_chan = tex_channels;
            pixels_array[i] = c.stbi_load(@ptrCast([*c]const u8, path), &tex_width, &tex_height, &tex_channels, c.STBI_rgb_alpha);
            if (i > 1) {
                assert(prev_width == tex_width and prev_height == tex_height and prev_chan == tex_channels);
            }
            byte_per_image = @intCast(usize, tex_width) * @intCast(usize, tex_height) * @intCast(usize, tex_channels);
            std.log.info("{}-{}-{}", .{ tex_width, tex_height, tex_channels });
            // assert(byte_per_image == 2048 * 2048 * 4);
            assert(pixels_array[i] != null);
        }

        defer {
            var i: u32 = 0;
            while (i < face) : (i += 1) {
                c.stbi_image_free(pixels_array[i]);
            }
        }
        // Stage buffer
        const total_size = byte_per_image * face;
        const staging_buffer_desc = Wgpu.BufferDescriptor{
            .usage = .{ .CopySrc = true, .MapWrite = true },
            .size = total_size,
            .mappedAtCreation = true,
        };
        const staging_buffer = gfx.wb.deviceCreateBuffer(gfx.device, &staging_buffer_desc);
        defer gfx.wb.bufferDrop(staging_buffer);

        // Copy texture data into staging buffer
        {
            var gpu_mem = @ptrCast([*]u8, @alignCast(
                @alignOf(u8),
                gfx.wb.bufferGetMappedRange(staging_buffer, 0, total_size).?,
            ));
            defer gfx.wb.bufferUnmap(staging_buffer);
            var i: u32 = 0;
            while (i < face) : (i += 1) {
                const start_byte = i * byte_per_image;
                const end_byte = start_byte + byte_per_image;
                std.mem.copy(u8, gpu_mem[start_byte..end_byte], pixels_array[i][0..byte_per_image]);
            }
        }

        const td = Wgpu.TextureDescriptor{
            .label = label,
            .usage = .{ .CopyDst = true, .TextureBinding = true },
            .dimension = .@"2D",
            .size = .{
                .width = @intCast(u32, tex_width),
                .height = @intCast(u32, tex_height),
                .depthOrArrayLayers = face,
            },
            .format = .RGBA8Unorm,
            .mipLevelCount = 1,
            .sampleCount = 1,
        };

        const texture = gfx.wb.deviceCreateTexture(gfx.device, &td);
        {
            const cmd_encoder = gfx.wb.deviceCreateCommandEncoder(gfx.device, &.{});
            var source = Wgpu.ImageCopyBuffer{
                .buffer = staging_buffer,
                .layout = .{
                    .offset = 0,
                    .bytesPerRow = td.size.width * @intCast(u32, tex_channels),
                    .rowsPerImage = td.size.height,
                },
            };
            var destination = Wgpu.ImageCopyTexture{
                .texture = texture,
                .mipLevel = 0,
                .origin = .{
                    .x = 0,
                    .y = 0,
                    .z = 0,
                },
                .aspect = .All,
            };
            const copy_size = Wgpu.Extent3D{
                .width = td.size.width,
                .height = td.size.height,
                .depthOrArrayLayers = 1,
            };
            var i: u32 = 0;
            while (i < face) : (i += 1) {
                source.layout.offset = i * byte_per_image;
                destination.origin.z = i;
                gfx.wb.commandEncoderCopyBufferToTexture(cmd_encoder, &source, &destination, &copy_size);
            }
            const command_buffer = gfx.wb.commandEncoderFinish(cmd_encoder, &.{});
            // Submit to the queue
            gfx.wb.queueSubmit(gfx.queue, 1, @ptrCast([*]const Wgpu.CommandBuffer, &command_buffer));
        }
        const tvd = Wgpu.TextureViewDescriptor{
            .format = td.format,
            .dimension = .Cube,
            .baseMipLevel = 0,
            .mipLevelCount = 1,
            .baseArrayLayer = 0,
            .arrayLayerCount = face,
            .aspect = .All,
        };
        const sd = Wgpu.SamplerDescriptor{
            .addressModeU = .ClampToEdge,
            .addressModeV = .ClampToEdge,
            .addressModeW = .ClampToEdge,
            .magFilter = .Linear,
            .minFilter = .Linear,
            .mipmapFilter = .Nearest,
            .lodMinClamp = 0,
            .lodMaxClamp = 1,
            .compare = .Undefined,
            .maxAnisotropy = 1,
        };
        return .{
            .texture = texture,
            .view = gfx.wb.textureCreateView(texture, &tvd),
            .sampler = gfx.wb.deviceCreateSampler(gfx.device, &sd),
            .des = td,
        };
    }

    pub fn deinit(t: Texture, gfx: Gfx) void {
        gfx.wb.textureDrop(t.texture);
        gfx.wb.textureViewDrop(t.view);
        gfx.wb.samplerDrop(t.sampler);
    }
};

const CameraUniform = struct {
    projection: Mat4,
    view: Mat4,
};

const Camera = struct {
    pitch: f32,
    yaw: f32,
    pos: Vec3,
    quat: z.Quat = z.Quat.zero(),
    z_near: f32 = 0.1,
    z_far: f32 = 100,
    fov_in_degrees: f32 = 60,
    const rotate_speed: f32 = 85;
    const move_speed: f32 = 12;

    pub fn getViewMatrix(self: Camera) Mat4 {
        const target = self.quat.rotateVec(Vec3.forward());
        return z.lookAt(self.pos, self.pos.add(target), Vec3.up());
    }

    pub fn getProjMatrix(self: Camera, width: u32, height: u32) Mat4 {
        return z.perspective(
            self.fov_in_degrees,
            @intToFloat(f32, width) / @intToFloat(f32, height),
            self.z_near,
            self.z_far,
        );
    }

    fn moveCamera(self: *Camera, window: glfw.Window, dt: f32) void {
        var x_dir: f32 = 0;
        var y_dir: f32 = 0;
        if (window.getKey(.j) == .press) y_dir += dt;
        if (window.getKey(.k) == .press) y_dir -= dt;
        if (window.getKey(.h) == .press) x_dir += dt;
        if (window.getKey(.l) == .press) x_dir -= dt;

        // limit pitch values between about +/- 85ish degrees
        self.yaw += x_dir * rotate_speed;
        self.pitch += y_dir * rotate_speed;
        self.pitch = std.math.clamp(self.pitch, -85, 85);
        self.yaw = std.math.mod(f32, self.yaw, 360) catch unreachable;

        var move_dir = Vec3.zero();
        if (window.getKey(.w) == .press) move_dir.z += dt;
        if (window.getKey(.s) == .press) move_dir.z -= dt;
        if (window.getKey(.a) == .press) move_dir.x += dt;
        if (window.getKey(.d) == .press) move_dir.x -= dt;
        if (window.getKey(.space) == .press) move_dir.y += dt;
        if (window.getKey(.left_control) == .press) move_dir.y -= dt;

        self.quat = z.Quat.fromEulerAngle(Vec3.new(self.pitch, self.yaw, 0));
        const translation = self.quat.rotateVec(move_dir.scale(move_speed));
        self.pos = self.pos.add(translation);
    }
};

pub fn createPipeline(gfx: Gfx, bind_group_layouts: *const Wgpu.BindGroupLayout) Wgpu.RenderPipeline {
    const vertex_module = gfx.createShader(.spirv, spv_vert);
    defer gfx.wb.shaderModuleDrop(vertex_module);
    const fragment_module = gfx.createShader(.spirv, spv_frag);
    defer gfx.wb.shaderModuleDrop(fragment_module);

    const pipeline_layout = gfx.wb.deviceCreatePipelineLayout(gfx.device, &.{
        .bindGroupLayoutCount = 1,
        .bindGroupLayouts = @ptrCast([*]const Wgpu.BindGroupLayout, bind_group_layouts),
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

    var camera = Camera{
        .pitch = 0,
        .yaw = 0,
        .pos = z.Vec3.new(0, 0, -2),
    };

    //Camera
    const camera_buffer_size = @sizeOf(CameraUniform);
    const camera_buffer = gfx.createUniformBuffer(.{}, camera_buffer_size, "cam");
    var camera_ubo = CameraUniform{
        .projection = camera.getProjMatrix(width, height),
        .view = camera.getViewMatrix(),
    };

    gfx.queueWriteBuffer(
        camera_buffer,
        0,
        &camera_ubo,
        camera_buffer_size,
    );

    const bgl_entries = [_]Wgpu.BindGroupLayoutEntry{
        .{
            //Camara binding 0: vertex and fragment
            .binding = 0,
            .visibility = .{ .Vertex = true, .Fragment = true },
            .buffer = .{
                .type = .Uniform,
                .hasDynamicOffset = false,
                .minBindingSize = camera_buffer_size,
            },
            .sampler = undefined,
            .texture = undefined,
            .storageTexture = undefined,
        },
        .{
            // Texture View binding 1: Fragment
            .binding = 1,
            .visibility = .{ .Fragment = true },
            .texture = .{
                .sampleType = .Float,
                .viewDimension = .Cube,
                .multisampled = false,
            },
            .buffer = undefined,
            .sampler = undefined,
            .storageTexture = undefined,
        },
        .{
            // sampler binding 2: Fragment
            .binding = 2,
            .visibility = .{ .Fragment = true },
            .sampler = .{ .type = .Filtering },
            .buffer = undefined,
            .texture = undefined,
            .storageTexture = undefined,
        },
    };
    const bind_group_layout = gfx.wb.deviceCreateBindGroupLayout(gfx.device, &.{
        .entryCount = @truncate(u32, bgl_entries.len),
        .entries = @ptrCast([*]const Wgpu.BindGroupLayoutEntry, &bgl_entries),
    });
    std.debug.assert(bind_group_layout != .null_handle);
    const pipeline = createPipeline(gfx, &bind_group_layout);
    defer gfx.wb.renderPipelineDrop(pipeline);

    const skybox_texture = Texture.loadCubeMapFromFile(gfx, &.{
        "assets/textures/cubemap/px.png",
        "assets/textures/cubemap/nx.png",
        "assets/textures/cubemap/py.png",
        "assets/textures/cubemap/ny.png",
        "assets/textures/cubemap/pz.png",
        "assets/textures/cubemap/nz.png",
    }, "Sky Box");
    defer skybox_texture.deinit(gfx);

    //Bind Group
    const bg_entries = [_]Wgpu.BindGroupEntry{
        .{
            // Binding 0: Camera Uniform buffer (Vertex shader & Fragment shader)
            .binding = 0,
            .buffer = camera_buffer,
            .offset = 0,
            .size = camera_buffer_size,
            .sampler = .null_handle,
            .textureView = .null_handle,
        },
        .{
            // Binding 1: Light Uniform buffer (Fragment shader)
            .binding = 1,
            .buffer = .null_handle,
            .offset = undefined,
            .size = undefined,
            .sampler = .null_handle,
            .textureView = skybox_texture.view,
        },
        .{
            // Binding 2: Material Dynamic uniform buffer (Fragment shader)
            .binding = 2,
            .buffer = .null_handle,
            .offset = undefined,
            .size = undefined,
            .sampler = skybox_texture.sampler,
            .textureView = .null_handle,
        },
    };

    const bind_group = gfx.wb.deviceCreateBindGroup(gfx.device, &.{
        .layout = bind_group_layout,
        .entryCount = @truncate(u32, bg_entries.len),
        .entries = &bg_entries,
    });
    assert(bind_group != .null_handle);

    //Timer
    var update_timer = try std.time.Timer.start();
    var total: f32 = 0;

    while (!window.shouldClose()) {
        width = gfx.swapchain_des.width;
        height = gfx.swapchain_des.height;
        const dt = @intToFloat(f32, update_timer.lap()) / @intToFloat(f32, std.time.ns_per_s);
        total += dt;
        camera.moveCamera(window, dt);
        camera_ubo = CameraUniform{
            .projection = camera.getProjMatrix(width, height),
            .view = camera.getViewMatrix(),
        };

        gfx.queueWriteBuffer(
            camera_buffer,
            0,
            &camera_ubo,
            camera_buffer_size,
        );

        try gfx.beginFrame();
        gfx.bindPipeline(pipeline);

        gfx.wb.renderPassEncoderSetBindGroup(gfx.render_pass, 0, bind_group, 0, null);
        gfx.wb.renderPassEncoderDraw(gfx.render_pass, 3, 1, 0, 0);

        gfx.endFrame();
        try glfw.pollEvents();
    }
}
