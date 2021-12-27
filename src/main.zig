const std = @import("std");
const glfw = @import("glfw");
const kn = std.os.windows.kernel32;
const builtin = @import("builtin");
const c = @import("c.zig");
const spv_vert = @embedFile("../assets/shaders/pbr_basic/pbr.vert.spv");
const spv_frag = @embedFile("../assets/shaders/pbr_basic/pbr.frag.spv");
const z = @import("zalgebra");
const assert = std.debug.assert;
const Mat4 = z.Mat4;
const Vec3 = z.Vec3;
const Vec2 = z.Vec2;
const Wgpu = @import("Wgpu.zig");
const Gfx = @import("Gfx.zig");
const Allocator = std.mem.Allocator;
const alignment = 256;

const Material = struct {
    roughness: f32,
    metalic: f32,
    color: z.Vec3,
    name: []const u8,

    pub fn new(name: []const u8, roughness: f32, metalic: f32, color: z.Vec3) Material {
        return .{
            .roughness = roughness,
            .metalic = metalic,
            .color = color,
            .name = name,
        };
    }
};

const materials = [_]Material{
    Material.new("Gold", 0.1, 1.0, z.Vec3.new(1.0, 0.765557, 0.336057)),
    Material.new("Copper", 0.1, 1.0, z.Vec3.new(0.955008, 0.637427, 0.538163)),
    Material.new("Chromium", 0.1, 1.0, z.Vec3.new(0.549585, 0.556114, 0.554256)),
    Material.new("Nickel", 0.1, 1.0, z.Vec3.new(0.659777, 0.608679, 0.525649)),
    Material.new("Titanium", 0.1, 1.0, z.Vec3.new(0.541931, 0.496791, 0.449419)),
    Material.new("Cobalt", 0.1, 1.0, z.Vec3.new(0.662124, 0.654864, 0.633732)),
    Material.new("Platinum", 0.1, 1.0, z.Vec3.new(0.672411, 0.637331, 0.585456)),
    Material.new("White", 0.1, 1.0, z.Vec3.new(1.0, 1.0, 1.0)),
    Material.new("Red", 0.1, 1.0, z.Vec3.new(1.0, 0.0, 0.0)),
    Material.new("Blue", 0.1, 1.0, z.Vec3.new(0.0, 0.0, 1.0)),
    Material.new("Black", 0.1, 1.0, z.Vec3.new(0.0, 0.0, 0.0)),
};

const models = .{
    .{ .name = "Sphere", .path = "assets/models/sphere.gltf" },
    .{ .name = "Teapot", .path = "assets/models/teapot.gltf" },
    .{ .name = "Torusknot", .path = "assets/models/torusknot.gltf" },
    .{ .name = "Venus", .path = "assets/models/venus.gltf" },
};

const grid_dim = 7;
const cells = grid_dim * grid_dim;

const Mesh = struct {
    index_offset: u32,
    vertex_offset: u32,
    num_indices: u32,
    num_vertices: u32,
};

const Vertex = struct {
    pos: Vec3,
    normal: Vec3,

    const stride = @sizeOf(Vertex);
    const vertex_attributes = [_]Wgpu.VertexAttribute{
        .{
            .format = .Float32x3,
            .offset = @offsetOf(Vertex, "pos"),
            .shaderLocation = 0,
        },
        .{
            .format = .Float32x3,
            .offset = @offsetOf(Vertex, "normal"),
            .shaderLocation = 1,
        },
    };
};

const UniformBufferObject = struct {
    projection: Mat4,
    model: Mat4,
    view: Mat4,
    cam_pos: z.Vec3,
    padding: f32 = 0,
};

const DynamicMaterial = struct {
    roughness: f32 = 0,
    metalic: f32 = 0,
    color: Vec3 = Vec3.zero(),
    padding: [alignment - 5 * @sizeOf(f32)]u8,
};

const DynamicPos = struct {
    position: Vec3 = Vec3.zero(),
    padding: [alignment - @sizeOf(Vec3)]u8,
};

const Light = packed struct {
    pos: [4]z.Vec4,

    pub fn new() Light {
        const p = 15;
        return .{ .pos = [_]z.Vec4{
            z.Vec4.new(-p, -p * 0.5, -p, 1.0),
            z.Vec4.new(-p, -p * 0.5, p, 1.0),
            z.Vec4.new(p, -p * 0.5, p, 1.0),
            z.Vec4.new(p, -p * 0.5, -p, 1.0),
        } };
    }

    pub fn update(l: *Light, dt: f32) void {
        const rad = std.math.mod(f32, dt, std.math.pi * 2.0) catch unreachable;
        l.pos[0].x = std.math.sin(rad) * 20.0;
        l.pos[0].z = std.math.cos(rad) * 20.0;
        l.pos[1].x = std.math.cos(rad) * 20.0;
        l.pos[1].y = std.math.sin(rad) * 20.0;
    }
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
    const vertex_layout = Wgpu.VertexBufferLayout{
        .arrayStride = Vertex.stride,
        .stepMode = .Vertex,
        .attributeCount = @truncate(u32, Vertex.vertex_attributes.len),
        .attributes = @ptrCast([*]const Wgpu.VertexAttribute, &Vertex.vertex_attributes),
    };

    return gfx.wb.deviceCreateRenderPipeline(gfx.device, &(Wgpu.RenderPipelineDescriptor){
        .label = "Two Cube Render Pipeline",
        .layout = pipeline_layout,
        .vertex = .{
            .module = vertex_module,
            .entryPoint = "main",
            .constantCount = 0,
            .constants = undefined,
            // Note: remeber change this with buffer layout
            .bufferCount = 1,
            .buffers = @ptrCast([*]const Wgpu.VertexBufferLayout, &vertex_layout),
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

const UboDynamic = struct {
    const M = [cells]DynamicMaterial;
    const P = [cells]DynamicPos;
    const materials_size = @sizeOf(DynamicMaterial) * cells;
    const object_size = @sizeOf(DynamicPos) * cells;

    material_params_dynamic: M,
    object_params_dynamic: P,
    click: bool,

    pub fn new() UboDynamic {
        return .{
            .material_params_dynamic = std.mem.zeroes(M),
            .object_params_dynamic = std.mem.zeroes(P),
            .click = true,
        };
    }
    pub fn updatePos(self: *UboDynamic, gfx: Gfx, buffer: Wgpu.Buffer) void {
        var y: u32 = 0;
        var i: u32 = 0;
        while (y < grid_dim) : (y += 1) {
            var x: u32 = 0;
            while (x < grid_dim) : (x += 1) {
                self.object_params_dynamic[i].position = z.Vec3.new(
                    (@intToFloat(f32, x) - 2) * 8,
                    0,
                    (@intToFloat(f32, y) - 2) * 8,
                );

                i += 1;
            }
        }
        gfx.queueWriteBuffer(buffer, 0, &self.object_params_dynamic, object_size);
    }

    pub fn update(self: *UboDynamic, window: glfw.Window) bool {
        if (!self.click and window.getKey(.n) == .press) {
            self.click = true;
            return true;
        }

        if (self.click and window.getKey(.n) == .release) self.click = false;
        return false;
    }

    pub fn updateMat(self: *UboDynamic, gfx: Gfx, buffer: Wgpu.Buffer, current_material: u32) void {
        var y: u32 = 0;
        var i: u32 = 0;
        const grid_size: f32 = @intToFloat(f32, grid_dim);
        while (y < grid_dim) : (y += 1) {
            var x: u32 = 0;
            while (x < grid_dim) : (x += 1) {
                self.material_params_dynamic[i].roughness =
                    std.math.clamp(@intToFloat(f32, x) / (grid_size - 1), 0.1, 1);
                self.material_params_dynamic[i].metalic =
                    std.math.clamp(@intToFloat(f32, x) / (grid_size - 1), 0.05, 1);
                self.material_params_dynamic[i].color = materials[current_material].color;
                i += 1;
            }
        }
        gfx.queueWriteBuffer(buffer, 0, &self.material_params_dynamic, materials_size);
    }
};

pub fn main() anyerror!void {
    const lib_path = if (builtin.mode == .Debug) "libs/libwgpu-debug.dll" else "libs/libwgpu-release.dll";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
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
    var indices = std.ArrayList(u32).init(allocator);
    defer indices.deinit();
    var vertices = std.ArrayList(Vertex).init(allocator);
    defer vertices.deinit();
    var meshs = std.ArrayList(Mesh).init(allocator);
    defer meshs.deinit();
    var arena = std.heap.ArenaAllocator.init(allocator);
    appendGltfModel(arena.allocator(), &meshs, &vertices, &indices, models[1].path);
    arena.deinit();
    const vertex_buffer = gfx.createBufferFromData(
        vertices.items.ptr,
        .{ .Vertex = true },
        vertices.items.len * @sizeOf(Vertex),
    );
    defer gfx.wb.bufferDestroy(vertex_buffer);
    const index_buffer = gfx.createBufferFromData(
        indices.items.ptr,
        .{ .Index = true },
        indices.items.len * @sizeOf(u32),
    );
    defer gfx.wb.bufferDestroy(index_buffer);

    //Camera
    const camera_buffer_size = @sizeOf(UniformBufferObject);
    const camera_buffer = gfx.createUniformBuffer(.{}, camera_buffer_size, "cam");
    var camera_ubo = UniformBufferObject{
        .projection = camera.getProjMatrix(width, height),
        .view = camera.getViewMatrix(),
        .model = Mat4.identity(),
        .cam_pos = camera.pos,
    };

    gfx.queueWriteBuffer(
        camera_buffer,
        0,
        &camera_ubo,
        camera_buffer_size,
    );

    //light
    var lights = Light.new();
    lights.update(0);
    const lights_size = @sizeOf(Light);
    const light_buffer = gfx.createUniformBuffer(.{}, lights_size, "light");
    gfx.queueWriteBuffer(light_buffer, 0, &lights, lights_size);

    //Material and object position
    var ubo = UboDynamic.new();
    const object_buffer = gfx.createUniformBuffer(.{}, UboDynamic.object_size, "obj_pos");
    const materials_buffer = gfx.createUniformBuffer(.{}, UboDynamic.materials_size, "mat");
    ubo.updatePos(gfx, object_buffer);
    var current_material: u32 = 0;
    ubo.updateMat(gfx, materials_buffer, current_material);

    const bgl_entries = [4]Wgpu.BindGroupLayoutEntry{
        .{
            //Camara binding 0: vertex and fragment
            .binding = 0,
            .visibility = .{ .Vertex = true, .Fragment = true },
            .buffer = .{
                .type = .Uniform,
                .hasDynamicOffset = false,
                .minBindingSize = camera_buffer_size,
            },
            .sampler = std.mem.zeroes(Wgpu.SamplerBindingLayout),
            .texture = std.mem.zeroes(Wgpu.TextureBindingLayout),
            .storageTexture = std.mem.zeroes(Wgpu.StorageTextureBindingLayout),
        },
        .{
            // Light binding 1: Fragment
            .binding = 1,
            .visibility = .{ .Fragment = true },
            .buffer = .{
                .type = .Uniform,
                .hasDynamicOffset = false,
                .minBindingSize = lights_size,
            },
            .sampler = std.mem.zeroes(Wgpu.SamplerBindingLayout),
            .texture = std.mem.zeroes(Wgpu.TextureBindingLayout),
            .storageTexture = std.mem.zeroes(Wgpu.StorageTextureBindingLayout),
        },
        .{
            // Material binding 2: Fragment
            .binding = 2,
            .visibility = .{ .Fragment = true },
            .buffer = .{
                .type = .Uniform,
                .hasDynamicOffset = true,
                .minBindingSize = @sizeOf(DynamicMaterial),
            },
            .sampler = std.mem.zeroes(Wgpu.SamplerBindingLayout),
            .texture = std.mem.zeroes(Wgpu.TextureBindingLayout),
            .storageTexture = std.mem.zeroes(Wgpu.StorageTextureBindingLayout),
        },
        .{
            // Object location binding 3: Vertex
            .binding = 3,
            .visibility = .{ .Vertex = true },
            .buffer = .{
                .type = .Uniform,
                .hasDynamicOffset = true,
                .minBindingSize = @sizeOf(DynamicPos),
            },
            .sampler = std.mem.zeroes(Wgpu.SamplerBindingLayout),
            .texture = std.mem.zeroes(Wgpu.TextureBindingLayout),
            .storageTexture = std.mem.zeroes(Wgpu.StorageTextureBindingLayout),
        },
    };
    const bind_group_layout = gfx.wb.deviceCreateBindGroupLayout(gfx.device, &.{
        .entryCount = @truncate(u32, bgl_entries.len),
        .entries = @ptrCast([*]const Wgpu.BindGroupLayoutEntry, &bgl_entries),
    });
    std.debug.assert(bind_group_layout != .null_handle);
    const pipeline = createPipeline(gfx, &bind_group_layout);
    defer gfx.wb.renderPipelineDrop(pipeline);

    // Bind Group
    const bg_entries = [4]Wgpu.BindGroupEntry{
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
            .buffer = light_buffer,
            .offset = 0,
            .size = lights_size,
            .sampler = .null_handle,
            .textureView = .null_handle,
        },
        .{
            // Binding 2: Material Dynamic uniform buffer (Fragment shader)
            .binding = 2,
            .buffer = materials_buffer,
            .offset = 0,
            .size = @sizeOf(DynamicMaterial),
            .sampler = .null_handle,
            .textureView = .null_handle,
        },
        .{
            // Binding 3: Object location Dynamic uniform buffer (Vertex shader)
            .binding = 3,
            .buffer = object_buffer,
            .offset = 0,
            .size = @sizeOf(DynamicPos),
            .sampler = .null_handle,
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
        const dt = @intToFloat(f32, update_timer.lap()) / @intToFloat(f32, std.time.ns_per_s);
        total += dt;
        camera.moveCamera(window, dt);
        if (ubo.update(window)) {
            current_material = (current_material + 1) % @truncate(u32, materials.len);
            ubo.updateMat(gfx, materials_buffer, current_material);
        }
        camera_ubo = UniformBufferObject{
            .projection = camera.getProjMatrix(width, height),
            .view = camera.getViewMatrix(),
            .model = Mat4.identity(),
            .cam_pos = camera.pos,
        };

        gfx.queueWriteBuffer(
            camera_buffer,
            0,
            &camera_ubo,
            camera_buffer_size,
        );

        width = gfx.swapchain_des.width;
        height = gfx.swapchain_des.height;
        lights.update(total);
        gfx.queueWriteBuffer(light_buffer, 0, &lights, lights_size);
        try gfx.beginFrame();
        gfx.bindPipeline(pipeline);

        gfx.wb.renderPassEncoderSetVertexBuffer(gfx.render_pass, 0, vertex_buffer, 0, Wgpu.WHOLE_SIZE);
        gfx.wb.renderPassEncoderSetIndexBuffer(gfx.render_pass, index_buffer, .Uint32, 0, Wgpu.WHOLE_SIZE);

        var i: u32 = 0;
        while (i < cells) : (i += 1) {
            const dynamic_offset = i * alignment;
            const dynamic_offsets = [_]u32{ dynamic_offset, dynamic_offset };

            gfx.wb.renderPassEncoderSetBindGroup(
                gfx.render_pass,
                0,
                bind_group,
                2,
                &dynamic_offsets,
            );
            // Draw object
            for (meshs.items) |mesh| {
                gfx.wb.renderPassEncoderDrawIndexed(
                    gfx.render_pass,
                    mesh.num_indices,
                    1,
                    mesh.index_offset,
                    @intCast(i32, mesh.vertex_offset),
                    0,
                );
            }
        }
        gfx.endFrame();
        try glfw.pollEvents();
    }
}

fn calcConstantBufferByteSize(byte_size: usize) usize {
    return (byte_size + alignment) & ~@as(usize, alignment);
}

pub fn appendGltfModel(
    arena: Allocator,
    all_meshes: *std.ArrayList(Mesh),
    all_vertices: *std.ArrayList(Vertex),
    all_indices: *std.ArrayList(u32),
    path: []const u8,
) void {
    var indices = std.ArrayList(u32).init(arena);
    var positions = std.ArrayList(Vec3).init(arena);
    var normals = std.ArrayList(Vec3).init(arena);
    // var texcoords0 = std.ArrayList(Vec2).init(arena);
    // var tangents = std.ArrayList(Vec4).init(arena);

    const data = parseAndLoadGltfFile(path);
    defer c.cgltf_free(data);

    const num_meshes = @intCast(u32, data.meshes_count);
    var mesh_index: u32 = 0;
    // const base_indices = @truncate(u32, all_indices.items.len);
    // const base_vertices = @truncate(u32, all_vertices.items.len);

    while (mesh_index < num_meshes) : (mesh_index += 1) {
        const num_prims = @intCast(u32, data.meshes[mesh_index].primitives_count);
        var prim_index: u32 = 0;

        while (prim_index < num_prims) : (prim_index += 1) {
            const pre_indices_len = indices.items.len;
            const pre_positions_len = positions.items.len;

            appendMeshPrimitive(data, mesh_index, prim_index, &indices, &positions, &normals, null);

            all_meshes.append(.{
                .index_offset = @intCast(u32, pre_indices_len),
                .vertex_offset = @intCast(u32, pre_positions_len),
                .num_indices = @intCast(u32, indices.items.len - pre_indices_len),
                .num_vertices = @intCast(u32, positions.items.len - pre_positions_len),
            }) catch unreachable;
        }
    }

    all_indices.ensureTotalCapacity(indices.items.len) catch unreachable;
    for (indices.items) |index| {
        all_indices.appendAssumeCapacity(index);
    }

    all_vertices.ensureTotalCapacity(positions.items.len) catch unreachable;
    for (positions.items) |_, index| {
        all_vertices.appendAssumeCapacity(.{
            // .pos = positions.items[index].scale(0.08), // NOTE(mziulek): Sponza requires scaling.
            .pos = positions.items[index],
            .normal = normals.items[index],
            // .tex_coord = texcoords0.items[index],
            // .tangent = tangents.items[index],
        });
    }
}

fn parseAndLoadGltfFile(gltf_path: []const u8) *c.cgltf_data {
    var data: *c.cgltf_data = undefined;
    const options = std.mem.zeroes(c.cgltf_options);
    // Parse.
    {
        const result = c.cgltf_parse_file(&options, gltf_path.ptr, @ptrCast([*c][*c]c.cgltf_data, &data));
        assert(result == c.cgltf_result_success);
    }
    // Load.
    {
        const result = c.cgltf_load_buffers(&options, data, gltf_path.ptr);
        assert(result == c.cgltf_result_success);
    }
    return data;
}
fn appendMeshPrimitive(
    data: *c.cgltf_data,
    mesh_index: u32,
    prim_index: u32,
    indices: *std.ArrayList(u32),
    positions: *std.ArrayList(Vec3),
    normals: ?*std.ArrayList(Vec3),
    texcoords0: ?*std.ArrayList(Vec2),
    // tangents: ?*std.ArrayList(Vec4),
) void {
    assert(mesh_index < data.meshes_count);
    assert(prim_index < data.meshes[mesh_index].primitives_count);
    const num_vertices: u32 = @intCast(u32, data.meshes[mesh_index].primitives[prim_index].attributes[0].data.*.count);
    const num_indices: u32 = @intCast(u32, data.meshes[mesh_index].primitives[prim_index].indices.*.count);

    // Indices.
    {
        indices.ensureTotalCapacity(indices.items.len + num_indices) catch unreachable;

        const accessor = data.meshes[mesh_index].primitives[prim_index].indices;

        assert(accessor.*.buffer_view != null);
        assert(accessor.*.stride == accessor.*.buffer_view.*.stride or accessor.*.buffer_view.*.stride == 0);
        assert((accessor.*.stride * accessor.*.count) == accessor.*.buffer_view.*.size);
        assert(accessor.*.buffer_view.*.buffer.*.data != null);

        const data_addr = @alignCast(4, @ptrCast([*]const u8, accessor.*.buffer_view.*.buffer.*.data) +
            accessor.*.offset + accessor.*.buffer_view.*.offset);

        if (accessor.*.stride == 1) {
            assert(accessor.*.component_type == c.cgltf_component_type_r_8u);
            const src = @ptrCast([*]const u8, data_addr);
            var i: u32 = 0;
            while (i < num_indices) : (i += 1) {
                indices.appendAssumeCapacity(src[i]);
            }
        } else if (accessor.*.stride == 2) {
            assert(accessor.*.component_type == c.cgltf_component_type_r_16u);
            const src = @ptrCast([*]const u16, data_addr);
            var i: u32 = 0;
            while (i < num_indices) : (i += 1) {
                indices.appendAssumeCapacity(src[i]);
            }
        } else if (accessor.*.stride == 4) {
            assert(accessor.*.component_type == c.cgltf_component_type_r_32u);
            const src = @ptrCast([*]const u32, data_addr);
            var i: u32 = 0;
            while (i < num_indices) : (i += 1) {
                indices.appendAssumeCapacity(src[i]);
            }
        } else {
            unreachable;
        }
    }

    // Attributes.
    {
        positions.resize(positions.items.len + num_vertices) catch unreachable;
        if (normals != null) normals.?.resize(normals.?.items.len + num_vertices) catch unreachable;
        if (texcoords0 != null) texcoords0.?.resize(texcoords0.?.items.len + num_vertices) catch unreachable;
        // if (tangents != null) tangents.?.resize(tangents.?.items.len + num_vertices) catch unreachable;

        const num_attribs: u32 = @intCast(u32, data.meshes[mesh_index].primitives[prim_index].attributes_count);

        var attrib_index: u32 = 0;
        while (attrib_index < num_attribs) : (attrib_index += 1) {
            const attrib = &data.meshes[mesh_index].primitives[prim_index].attributes[attrib_index];
            const accessor = attrib.data;

            assert(accessor.*.buffer_view != null);
            assert(accessor.*.stride == accessor.*.buffer_view.*.stride or accessor.*.buffer_view.*.stride == 0);
            assert((accessor.*.stride * accessor.*.count) == accessor.*.buffer_view.*.size);
            assert(accessor.*.buffer_view.*.buffer.*.data != null);

            const data_addr = @ptrCast([*]const u8, accessor.*.buffer_view.*.buffer.*.data) +
                accessor.*.offset + accessor.*.buffer_view.*.offset;

            if (attrib.*.type == c.cgltf_attribute_type_position) {
                assert(accessor.*.type == c.cgltf_type_vec3);
                assert(accessor.*.component_type == c.cgltf_component_type_r_32f);
                @memcpy(
                    @ptrCast([*]u8, &positions.items[positions.items.len - num_vertices]),
                    data_addr,
                    accessor.*.count * accessor.*.stride,
                );
            } else if (attrib.*.type == c.cgltf_attribute_type_normal and normals != null) {
                assert(accessor.*.type == c.cgltf_type_vec3);
                assert(accessor.*.component_type == c.cgltf_component_type_r_32f);
                @memcpy(
                    @ptrCast([*]u8, &normals.?.items[normals.?.items.len - num_vertices]),
                    data_addr,
                    accessor.*.count * accessor.*.stride,
                );
            } else if (attrib.*.type == c.cgltf_attribute_type_texcoord and texcoords0 != null) {
                assert(accessor.*.type == c.cgltf_type_vec2);
                assert(accessor.*.component_type == c.cgltf_component_type_r_32f);
                @memcpy(
                    @ptrCast([*]u8, &texcoords0.?.items[texcoords0.?.items.len - num_vertices]),
                    data_addr,
                    accessor.*.count * accessor.*.stride,
                );
            }
            // else if (attrib.*.type == c.cgltf_attribute_type_tangent and tangents != null) {
            //     assert(accessor.*.type == c.cgltf_type_vec4);
            //     assert(accessor.*.component_type == c.cgltf_component_type_r_32f);
            //     @memcpy(
            //         @ptrCast([*]u8, &tangents.?.items[tangents.?.items.len - num_vertices]),
            //         data_addr,
            //         accessor.*.count * accessor.*.stride,
            //     );
            // }
        }
    }
}
