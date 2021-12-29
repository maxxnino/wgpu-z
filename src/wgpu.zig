const std = @import("std");
pub usingnamespace @import("wgpu_binding.zig");
const DynLib = std.DynLib;
const Wgpu = @This();

instanceCreateSurface: @TypeOf(Wgpu.wgpuInstanceCreateSurface),
instanceRequestAdapter: @TypeOf(Wgpu.wgpuInstanceRequestAdapter),
deviceCreateShaderModule: @TypeOf(Wgpu.wgpuDeviceCreateShaderModule),
adapterRequestDevice: @TypeOf(Wgpu.wgpuAdapterRequestDevice),
deviceCreatePipelineLayout: @TypeOf(Wgpu.wgpuDeviceCreatePipelineLayout),
surfaceGetPreferredFormat: @TypeOf(Wgpu.wgpuSurfaceGetPreferredFormat),
deviceCreateRenderPipeline: @TypeOf(Wgpu.wgpuDeviceCreateRenderPipeline),
deviceCreateSwapChain: @TypeOf(Wgpu.wgpuDeviceCreateSwapChain),
swapChainGetCurrentTextureView: @TypeOf(Wgpu.wgpuSwapChainGetCurrentTextureView),
deviceCreateCommandEncoder: @TypeOf(Wgpu.wgpuDeviceCreateCommandEncoder),
commandEncoderBeginRenderPass: @TypeOf(Wgpu.wgpuCommandEncoderBeginRenderPass),
renderPassEncoderSetPipeline: @TypeOf(Wgpu.wgpuRenderPassEncoderSetPipeline),
renderPassEncoderDraw: @TypeOf(Wgpu.wgpuRenderPassEncoderDraw),
renderPassEncoderEndPass: @TypeOf(Wgpu.wgpuRenderPassEncoderEndPass),
deviceGetQueue: @TypeOf(Wgpu.wgpuDeviceGetQueue),
commandEncoderFinish: @TypeOf(Wgpu.wgpuCommandEncoderFinish),
queueSubmit: @TypeOf(Wgpu.wgpuQueueSubmit),
swapChainPresent: @TypeOf(Wgpu.wgpuSwapChainPresent),
adapterGetProperties: @TypeOf(Wgpu.wgpuAdapterGetProperties),
queueWriteBuffer: @TypeOf(Wgpu.wgpuQueueWriteBuffer),
deviceCreateBuffer: @TypeOf(Wgpu.wgpuDeviceCreateBuffer),
bufferDestroy: @TypeOf(Wgpu.wgpuBufferDestroy),
renderPassEncoderSetVertexBuffer: @TypeOf(Wgpu.wgpuRenderPassEncoderSetVertexBuffer),
renderPassEncoderSetIndexBuffer: @TypeOf(Wgpu.wgpuRenderPassEncoderSetIndexBuffer),
renderPassEncoderDrawIndexed: @TypeOf(Wgpu.wgpuRenderPassEncoderDrawIndexed),
setLogCallback: @TypeOf(Wgpu.wgpuSetLogCallback),
setLogLevel: @TypeOf(Wgpu.wgpuSetLogLevel),
deviceGetLimits: @TypeOf(Wgpu.wgpuDeviceGetLimits),
deviceCreateBindGroupLayout: @TypeOf(Wgpu.wgpuDeviceCreateBindGroupLayout),
deviceCreateBindGroup: @TypeOf(Wgpu.wgpuDeviceCreateBindGroup),
renderPassEncoderSetBindGroup: @TypeOf(Wgpu.wgpuRenderPassEncoderSetBindGroup),
queueWriteTexture: @TypeOf(Wgpu.wgpuQueueWriteTexture),

deviceCreateTexture: @TypeOf(Wgpu.wgpuDeviceCreateTexture),
textureDrop: @TypeOf(Wgpu.wgpuTextureDrop),
textureCreateView: @TypeOf(Wgpu.wgpuTextureCreateView),
textureViewDrop: @TypeOf(Wgpu.wgpuTextureViewDrop),
deviceCreateSampler: @TypeOf(Wgpu.wgpuDeviceCreateSampler),
samplerDrop: @TypeOf(Wgpu.wgpuSamplerDrop),
bufferGetMappedRange: @TypeOf(Wgpu.wgpuBufferGetMappedRange),
bufferUnmap: @TypeOf(Wgpu.wgpuBufferUnmap),
commandEncoderCopyBufferToTexture: @TypeOf(Wgpu.wgpuCommandEncoderCopyBufferToTexture),

bufferDrop: @TypeOf(Wgpu.wgpuBufferDrop),
deviceDrop: @TypeOf(Wgpu.wgpuDeviceDrop),
querySetDrop: @TypeOf(Wgpu.wgpuQuerySetDrop),
bindGroupLayoutDrop: @TypeOf(Wgpu.wgpuBindGroupLayoutDrop),
pipelineLayoutDrop: @TypeOf(Wgpu.wgpuPipelineLayoutDrop),
bindGroupDrop: @TypeOf(Wgpu.wgpuBindGroupDrop),
shaderModuleDrop: @TypeOf(Wgpu.wgpuShaderModuleDrop),
renderBundleDrop: @TypeOf(Wgpu.wgpuRenderBundleDrop),
renderPipelineDrop: @TypeOf(Wgpu.wgpuRenderPipelineDrop),
computePipelineDrop: @TypeOf(Wgpu.wgpuComputePipelineDrop),

commandBufferDrop: @TypeOf(Wgpu.wgpuCommandBufferDrop),
commandEncoderDrop: @TypeOf(Wgpu.wgpuCommandEncoderDrop),


fn symbol(comptime decl_name: []const u8) [:0]const u8 {
    const upper_char = [_]u8{comptime std.ascii.toUpper(decl_name[0])};
    return "wgpu" ++ upper_char ++ decl_name[1..];
}

pub fn loadAllFromDynLib(lib: *DynLib) !Wgpu {
    var wgpu: Wgpu = undefined;
    const fields = std.meta.fields(Wgpu);
    inline for (fields) |field| {
        @field(wgpu, field.name) = lib.lookup(
            field.field_type,
            symbol(field.name),
        ) orelse {
            std.log.err("Function Not Found: {s}", .{field.name});
            return error.FunctionNotFound;
        };

    }
    return wgpu;
}

pub fn toChainedStruct(ptr: anytype) *const Wgpu.ChainedStruct {
    const Ptr = @TypeOf(ptr);
    // if (!std.meta.trait.isSingleItemPtr(Ptr)) @compileError("given ptr is not single item pointer");
    const PtrType = std.meta.Child(Ptr);
    return @ptrCast(*const Wgpu.ChainedStruct, @alignCast(@alignOf(PtrType), ptr));
}
