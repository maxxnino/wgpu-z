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
        ) orelse return error.FunctionNotFound;
    }
    return wgpu;
}

pub fn toChainedStruct(ptr: anytype) *const Wgpu.ChainedStruct {
    const Ptr = @TypeOf(ptr);
    // if (!std.meta.trait.isSingleItemPtr(Ptr)) @compileError("given ptr is not single item pointer");
    const PtrType = std.meta.Child(Ptr);
    return @ptrCast(*const Wgpu.ChainedStruct, @alignCast(@alignOf(PtrType), ptr));
}
