const std = @import("std");
const wb = @import("wgpu_binding.zig");
const DynLib = std.DynLib;
const Wgpu = @This();

wgpuInstanceCreateSurface: @TypeOf(wb.wgpuInstanceCreateSurface),
wgpuInstanceRequestAdapter: @TypeOf(wb.wgpuInstanceRequestAdapter),
wgpuDeviceCreateShaderModule: @TypeOf(wb.wgpuDeviceCreateShaderModule),
wgpuAdapterRequestDevice: @TypeOf(wb.wgpuAdapterRequestDevice),
wgpuDeviceCreatePipelineLayout: @TypeOf(wb.wgpuDeviceCreatePipelineLayout),
wgpuSurfaceGetPreferredFormat: @TypeOf(wb.wgpuSurfaceGetPreferredFormat),
wgpuDeviceCreateRenderPipeline: @TypeOf(wb.wgpuDeviceCreateRenderPipeline),
wgpuDeviceCreateSwapChain: @TypeOf(wb.wgpuDeviceCreateSwapChain),
wgpuSwapChainGetCurrentTextureView: @TypeOf(wb.wgpuSwapChainGetCurrentTextureView),
wgpuDeviceCreateCommandEncoder: @TypeOf(wb.wgpuDeviceCreateCommandEncoder),
wgpuCommandEncoderBeginRenderPass: @TypeOf(wb.wgpuCommandEncoderBeginRenderPass),
wgpuRenderPassEncoderSetPipeline: @TypeOf(wb.wgpuRenderPassEncoderSetPipeline),
wgpuRenderPassEncoderDraw: @TypeOf(wb.wgpuRenderPassEncoderDraw),
wgpuRenderPassEncoderEndPass: @TypeOf(wb.wgpuRenderPassEncoderEndPass),
wgpuDeviceGetQueue: @TypeOf(wb.wgpuDeviceGetQueue),
wgpuCommandEncoderFinish: @TypeOf(wb.wgpuCommandEncoderFinish),
wgpuQueueSubmit: @TypeOf(wb.wgpuQueueSubmit),
wgpuSwapChainPresent: @TypeOf(wb.wgpuSwapChainPresent),

pub fn loadAllFromDynLib(lib: *DynLib) !Wgpu {
    var wgpu: Wgpu = undefined;
    const fields = std.meta.fields(Wgpu);
    inline for (fields) |field| {
        @field(wgpu, field.name) = lib.lookup(
            field.field_type,
            field.name ++ "\x00",
        ) orelse return error.FunctionNotFound;
    }
    return wgpu;
}
