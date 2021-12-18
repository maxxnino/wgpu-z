const std = @import("std");

pub fn FlagsMixin(comptime FlagsType: type, comptime Int: type) type {
    return struct {
        pub const IntType = Int;
        pub fn toInt(self: FlagsType) IntType {
            return @bitCast(IntType, self);
        }
        pub fn fromInt(flags: IntType) FlagsType {
            return @bitCast(FlagsType, flags);
        }
        pub fn merge(lhs: FlagsType, rhs: FlagsType) FlagsType {
            return fromInt(toInt(lhs) | toInt(rhs));
        }
        pub fn intersect(lhs: FlagsType, rhs: FlagsType) FlagsType {
            return fromInt(toInt(lhs) & toInt(rhs));
        }
        pub fn complement(self: FlagsType) FlagsType {
            return fromInt(~toInt(self));
        }
        pub fn subtract(lhs: FlagsType, rhs: FlagsType) FlagsType {
            return fromInt(toInt(lhs) & toInt(rhs.complement()));
        }
        pub fn contains(lhs: FlagsType, rhs: FlagsType) bool {
            return toInt(intersect(lhs, rhs)) == toInt(rhs);
        }
    };
}

pub fn toChainedStruct(ptr: anytype) *const WGPUChainedStruct {
    const Ptr = @TypeOf(ptr);
    // if (!std.meta.trait.isSingleItemPtr(Ptr)) @compileError("given ptr is not single item pointer");
    const PtrType = std.meta.Child(Ptr);
    return @ptrCast(*const WGPUChainedStruct, @alignCast(@alignOf(PtrType), ptr));
}
pub const WGPUFlags = u32;
pub const WGPUAdapter = enum(usize) { null_handle = 0, _ };
pub const WGPUBindGroup = enum(usize) { null_handle = 0, _ };
pub const WGPUBindGroupLayout = enum(usize) { null_handle = 0, _ };
pub const WGPUBuffer = enum(usize) { null_handle = 0, _ };
pub const WGPUCommandBuffer = enum(usize) { null_handle = 0, _ };
pub const WGPUCommandEncoder = enum(usize) { null_handle = 0, _ };
pub const WGPUComputePassEncoder = enum(usize) { null_handle = 0, _ };
pub const WGPUComputePipeline = enum(usize) { null_handle = 0, _ };
pub const WGPUDevice = enum(usize) { null_handle = 0, _ };
pub const WGPUInstance = enum(usize) { null_handle = 0, _ };
pub const WGPUPipelineLayout = enum(usize) { null_handle = 0, _ };
pub const WGPUQuerySet = enum(usize) { null_handle = 0, _ };
pub const WGPUQueue = enum(usize) { null_handle = 0, _ };
pub const WGPURenderBundle = enum(usize) { null_handle = 0, _ };
pub const WGPURenderBundleEncoder = enum(usize) { null_handle = 0, _ };
pub const WGPURenderPassEncoder = enum(usize) { null_handle = 0, _ };
pub const WGPURenderPipeline = enum(usize) { null_handle = 0, _ };
pub const WGPUSampler = enum(usize) { null_handle = 0, _ };
pub const WGPUShaderModule = enum(usize) { null_handle = 0, _ };
pub const WGPUSurface = enum(usize) { null_handle = 0, _ };
pub const WGPUSwapChain = enum(usize) { null_handle = 0, _ };
pub const WGPUTexture = enum(usize) { null_handle = 0, _ };
pub const WGPUTextureView = enum(usize) { null_handle = 0, _ };

pub const WGPUAdapterType = enum(i32) {
    DiscreteGpu = 0,
    IntegratedGpu = 1,
    Cpu = 2,
    Unknown = 3,
};
pub const WGPUAddressMode = enum(i32) {
    Repeat = 0,
    MirrorRepeat = 1,
    ClampToEdge = 2,
};
pub const WGPUBackendType = enum(i32) {
    Null = 0,
    WebGPU = 1,
    D3D11 = 2,
    D3D12 = 3,
    Metal = 4,
    Vulkan = 5,
    OpenGL = 6,
    OpenGLES = 7,
};
pub const WGPUBlendFactor = enum(i32) {
    Zero = 0,
    One = 1,
    Src = 2,
    OneMinusSrc = 3,
    SrcAlpha = 4,
    OneMinusSrcAlpha = 5,
    Dst = 6,
    OneMinusDst = 7,
    DstAlpha = 8,
    OneMinusDstAlpha = 9,
    SrcAlphaSaturated = 10,
    Constant = 11,
    OneMinusConstant = 12,
};

pub const WGPUBlendOperation = enum(i32) {
    Add = 0,
    Subtract = 1,
    ReverseSubtract = 2,
    Min = 3,
    Max = 4,
};
pub const WGPUBufferBindingType = enum(i32) {
    Undefined = 0,
    Uniform = 1,
    Storage = 2,
    ReadOnlyStorage = 3,
};
pub const WGPUBufferMapAsyncStatus = enum(i32) {
    Success = 0,
    Error = 1,
    Unknown = 2,
    DeviceLost = 3,
    DestroyedBeforeCallback = 4,
    UnmappedBeforeCallback = 5,
};
pub const WGPUCompareFunction = enum(i32) {
    Undefined = 0,
    Never = 1,
    Less = 2,
    LessEqual = 3,
    Greater = 4,
    GreaterEqual = 5,
    Equal = 6,
    NotEqual = 7,
    Always = 8,
};
pub const WGPUCompilationMessageType = enum(i32) {
    Error = 0,
    Warning = 1,
    Info = 2,
};
pub const WGPUCreatePipelineAsyncStatus = enum(i32) {
    Success = 0,
    Error = 1,
    DeviceLost = 2,
    DeviceDestroyed = 3,
    Unknown = 4,
};
pub const WGPUCullMode = enum(i32) {
    None = 0,
    Front = 1,
    Back = 2,
};
pub const WGPUDeviceLostReason = enum(i32) {
    Undefined = 0,
    Destroyed = 1,
};
pub const WGPUErrorFilter = enum(i32) {
    None = 0,
    Validation = 1,
    OutOfMemory = 2,
};
pub const WGPUErrorType = enum(i32) {
    NoError = 0,
    Validation = 1,
    OutOfMemory = 2,
    Unknown = 3,
    DeviceLost = 4,
};
pub const WGPUFeatureName = enum(i32) {
    Undefined = 0,
    DepthClamping = 1,
    Depth24UnormStencil8 = 2,
    Depth32FloatStencil8 = 3,
    TimestampQuery = 4,
    PipelineStatisticsQuery = 5,
    TextureCompressionBC = 6,
};
pub const WGPUFilterMode = enum(i32) {
    Nearest = 0,
    Linear = 1,
};
pub const WGPUFrontFace = enum(i32) {
    CCW = 0,
    CW = 1,
};
pub const WGPUIndexFormat = enum(i32) {
    Undefined = 0,
    Uint16 = 1,
    Uint32 = 2,
};
pub const WGPULoadOp = enum(i32) {
    Clear = 0,
    Load = 1,
};
pub const WGPUPipelineStatisticName = enum(i32) {
    VertexShaderInvocations = 0,
    ClipperInvocations = 1,
    ClipperPrimitivesOut = 2,
    FragmentShaderInvocations = 3,
    ComputeShaderInvocations = 4,
};
pub const WGPUPowerPreference = enum(i32) {
    LowPower = 0,
    HighPerformance = 1,
};
pub const WGPUPresentMode = enum(i32) {
    Immediate = 0,
    Mailbox = 1,
    Fifo = 2,
};
pub const WGPUPrimitiveTopology = enum(i32) {
    PointList = 0,
    LineList = 1,
    LineStrip = 2,
    TriangleList = 3,
    TriangleStrip = 4,
};
pub const WGPUQueryType = enum(i32) {
    Occlusion = 0,
    PipelineStatistics = 1,
    Timestamp = 2,
};
pub const WGPUQueueWorkDoneStatus = enum(i32) {
    Success = 0,
    Error = 1,
    Unknown = 2,
    DeviceLost = 3,
};
pub const WGPURequestAdapterStatus = enum(i32) {
    Success = 0,
    Unavailable = 1,
    Error = 2,
    Unknown = 3,
};
pub const WGPURequestDeviceStatus = enum(i32) {
    Success = 0,
    Error = 1,
    Unknown = 2,
};
pub const WGPUSType = enum(i32) {
    Invalid = 0,
    SurfaceDescriptorFromMetalLayer = 1,
    SurfaceDescriptorFromWindowsHWND = 2,
    SurfaceDescriptorFromXlib = 3,
    SurfaceDescriptorFromCanvasHTMLSelector = 4,
    ShaderModuleSPIRVDescriptor = 5,
    ShaderModuleWGSLDescriptor = 6,
    PrimitiveDepthClampingState = 7,

    //wgpu-native Start at 6 to prevent collisions with webgpu STypes
    DeviceExtras = 1610612737,
    AdapterExtras = 1610612738,
};
pub const WGPUSamplerBindingType = enum(i32) {
    Undefined = 0,
    Filtering = 1,
    NonFiltering = 2,
    Comparison = 3,
};
pub const WGPUStencilOperation = enum(i32) {
    Keep = 0,
    Zero = 1,
    Replace = 2,
    Invert = 3,
    IncrementClamp = 4,
    DecrementClamp = 5,
    IncrementWrap = 6,
    DecrementWrap = 7,
};
pub const WGPUStorageTextureAccess = enum(i32) {
    Undefined = 0,
    WriteOnly = 1,
};
pub const WGPUStoreOp = enum(i32) {
    Store = 0,
    Discard = 1,
};
pub const WGPUTextureAspect = enum(i32) {
    All = 0,
    StencilOnly = 1,
    DepthOnly = 2,
};
pub const WGPUTextureComponentType = enum(i32) {
    Float = 0,
    Sint = 1,
    Uint = 2,
    DepthComparison = 3,
};
pub const WGPUTextureDimension = enum(i32) {
    @"1D" = 0,
    @"2D" = 1,
    @"3D" = 2,
};
pub const WGPUTextureFormat = enum(i32) {
    Undefined = 0,
    R8Unorm = 1,
    R8Snorm = 2,
    R8Uint = 3,
    R8Sint = 4,
    R16Uint = 5,
    R16Sint = 6,
    R16Float = 7,
    RG8Unorm = 8,
    RG8Snorm = 9,
    RG8Uint = 10,
    RG8Sint = 11,
    R32Float = 12,
    R32Uint = 13,
    R32Sint = 14,
    RG16Uint = 15,
    RG16Sint = 16,
    RG16Float = 17,
    RGBA8Unorm = 18,
    RGBA8UnormSrgb = 19,
    RGBA8Snorm = 20,
    RGBA8Uint = 21,
    RGBA8Sint = 22,
    BGRA8Unorm = 23,
    BGRA8UnormSrgb = 24,
    RGB10A2Unorm = 25,
    RG11B10Ufloat = 26,
    RGB9E5Ufloat = 27,
    RG32Float = 28,
    RG32Uint = 29,
    RG32Sint = 30,
    RGBA16Uint = 31,
    RGBA16Sint = 32,
    RGBA16Float = 33,
    RGBA32Float = 34,
    RGBA32Uint = 35,
    RGBA32Sint = 36,
    Stencil8 = 37,
    Depth16Unorm = 38,
    Depth24Plus = 39,
    Depth24PlusStencil8 = 40,
    Depth32Float = 41,
    BC1RGBAUnorm = 42,
    BC1RGBAUnormSrgb = 43,
    BC2RGBAUnorm = 44,
    BC2RGBAUnormSrgb = 45,
    BC3RGBAUnorm = 46,
    BC3RGBAUnormSrgb = 47,
    BC4RUnorm = 48,
    BC4RSnorm = 49,
    BC5RGUnorm = 50,
    BC5RGSnorm = 51,
    BC6HRGBUfloat = 52,
    BC6HRGBFloat = 53,
    BC7RGBAUnorm = 54,
    BC7RGBAUnormSrgb = 55,
};
pub const WGPUTextureSampleType = enum(i32) {
    Undefined = 0,
    Float = 1,
    UnfilterableFloat = 2,
    Depth = 3,
    Sint = 4,
    Uint = 5,
};
pub const WGPUTextureViewDimension = enum(i32) {
    Undefined = 0,
    @"1D" = 1,
    @"2D" = 2,
    @"2DArray" = 3,
    Cube = 4,
    CubeArray = 5,
    @"3D" = 6,
};
pub const WGPUVertexFormat = enum(i32) {
    Undefined = 0,
    Uint8x2 = 1,
    Uint8x4 = 2,
    Sint8x2 = 3,
    Sint8x4 = 4,
    Unorm8x2 = 5,
    Unorm8x4 = 6,
    Snorm8x2 = 7,
    Snorm8x4 = 8,
    Uint16x2 = 9,
    Uint16x4 = 10,
    Sint16x2 = 11,
    Sint16x4 = 12,
    Unorm16x2 = 13,
    Unorm16x4 = 14,
    Snorm16x2 = 15,
    Snorm16x4 = 16,
    Float16x2 = 17,
    Float16x4 = 18,
    Float32 = 19,
    Float32x2 = 20,
    Float32x3 = 21,
    Float32x4 = 22,
    Uint32 = 23,
    Uint32x2 = 24,
    Uint32x3 = 25,
    Uint32x4 = 26,
    Sint32 = 27,
    Sint32x2 = 28,
    Sint32x3 = 29,
    Sint32x4 = 30,
};
pub const WGPUVertexStepMode = enum(i32) {
    Vertex = 0,
    Instance = 1,
};
pub const WGPUBufferUsage = enum(i32) {
    None = 0,
    MapRead = 1,
    MapWrite = 2,
    CopySrc = 4,
    CopyDst = 8,
    Index = 16,
    Vertex = 32,
    Uniform = 64,
    Storage = 128,
    Indirect = 256,
    QueryResolve = 512,
};
pub const WGPUColorWriteMask = enum(i32) {
    None = 0,
    Red = 1,
    Green = 2,
    Blue = 4,
    Alpha = 8,
    All = 15,
};
pub const WGPUMapMode = enum(i32) {
    None = 0,
    Read = 1,
    Write = 2,
};
pub const WGPUShaderStage = enum(i32) {
    None = 0,
    Vertex = 1,
    Fragment = 2,
    Compute = 4,
};
pub const WGPUTextureUsage = enum(i32) {
    None = 0,
    CopySrc = 1,
    CopyDst = 2,
    TextureBinding = 4,
    StorageBinding = 8,
    RenderAttachment = 16,
};

pub const WGPUBufferUsageFlags = WGPUFlags;
pub const WGPUColorWriteMaskFlags = WGPUFlags;
pub const WGPUMapModeFlags = WGPUFlags;
pub const WGPUShaderStageFlags = WGPUFlags;
pub const WGPUTextureUsageFlags = WGPUFlags;

pub const WGPUChainedStruct = extern struct {
    next: ?*const WGPUChainedStruct,
    sType: WGPUSType,
};
pub const WGPUChainedStructOut = extern struct {
    next: [*c]WGPUChainedStructOut,
    sType: WGPUSType,
};
pub const WGPUAdapterProperties = extern struct {
    nextInChain: [*c]WGPUChainedStructOut,
    vendorID: u32,
    deviceID: u32,
    name: [*c]const u8,
    driverDescription: [*c]const u8,
    adapterType: WGPUAdapterType,
    backendType: WGPUBackendType,
};
pub const WGPUBindGroupEntry = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    binding: u32,
    buffer: WGPUBuffer,
    offset: u64,
    size: u64,
    sampler: WGPUSampler,
    textureView: WGPUTextureView,
};
pub const WGPUBlendComponent = extern struct {
    operation: WGPUBlendOperation,
    srcFactor: WGPUBlendFactor,
    dstFactor: WGPUBlendFactor,
};
pub const WGPUBufferBindingLayout = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    type: WGPUBufferBindingType,
    hasDynamicOffset: bool,
    minBindingSize: u64,
};
pub const WGPUBufferDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    usage: WGPUBufferUsageFlags,
    size: u64,
    mappedAtCreation: bool,
};
pub const WGPUColor = extern struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64,
};
pub const WGPUCommandBufferDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
};
pub const WGPUCommandEncoderDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
};
pub const WGPUCompilationMessage = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    message: [*c]const u8,
    type: WGPUCompilationMessageType,
    lineNum: u64,
    linePos: u64,
    offset: u64,
    length: u64,
};
pub const WGPUComputePassDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
};
pub const WGPUConstantEntry = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    key: [*c]const u8,
    value: f64,
};
pub const WGPUExtent3D = extern struct {
    width: u32,
    height: u32,
    depthOrArrayLayers: u32,
};
pub const WGPUInstanceDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
};
pub const WGPULimits = extern struct {
    maxTextureDimension1D: u32 = undefined,
    maxTextureDimension2D: u32 = undefined,
    maxTextureDimension3D: u32 = undefined,
    maxTextureArrayLayers: u32 = undefined,
    maxBindGroups: u32 = undefined,
    maxDynamicUniformBuffersPerPipelineLayout: u32 = undefined,
    maxDynamicStorageBuffersPerPipelineLayout: u32 = undefined,
    maxSampledTexturesPerShaderStage: u32 = undefined,
    maxSamplersPerShaderStage: u32 = undefined,
    maxStorageBuffersPerShaderStage: u32 = undefined,
    maxStorageTexturesPerShaderStage: u32 = undefined,
    maxUniformBuffersPerShaderStage: u32 = undefined,
    maxUniformBufferBindingSize: u64 = undefined,
    maxStorageBufferBindingSize: u64 = undefined,
    minUniformBufferOffsetAlignment: u32 = undefined,
    minStorageBufferOffsetAlignment: u32 = undefined,
    maxVertexBuffers: u32 = undefined,
    maxVertexAttributes: u32 = undefined,
    maxVertexBufferArrayStride: u32 = undefined,
    maxInterStageShaderComponents: u32 = undefined,
    maxComputeWorkgroupStorageSize: u32 = undefined,
    maxComputeInvocationsPerWorkgroup: u32 = undefined,
    maxComputeWorkgroupSizeX: u32 = undefined,
    maxComputeWorkgroupSizeY: u32 = undefined,
    maxComputeWorkgroupSizeZ: u32 = undefined,
    maxComputeWorkgroupsPerDimension: u32 = undefined,
};
pub const WGPUMultisampleState = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    count: u32,
    mask: u32,
    alphaToCoverageEnabled: bool,
};
pub const WGPUOrigin3D = extern struct {
    x: u32,
    y: u32,
    z: u32,
};
pub const WGPUPipelineLayoutDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    bindGroupLayoutCount: u32,
    bindGroupLayouts: [*c]const WGPUBindGroupLayout,
};
pub const WGPUPrimitiveDepthClampingState = extern struct {
    chain: WGPUChainedStruct,
    clampDepth: bool,
};
pub const WGPUPrimitiveState = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    topology: WGPUPrimitiveTopology,
    stripIndexFormat: WGPUIndexFormat,
    frontFace: WGPUFrontFace,
    cullMode: WGPUCullMode,
};
pub const WGPUQuerySetDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    type: WGPUQueryType,
    count: u32,
    pipelineStatistics: [*c]const WGPUPipelineStatisticName,
    pipelineStatisticsCount: u32,
};
pub const WGPURenderBundleDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
};
pub const WGPURenderBundleEncoderDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    colorFormatsCount: u32,
    colorFormats: [*c]const WGPUTextureFormat,
    depthStencilFormat: WGPUTextureFormat,
    sampleCount: u32,
};
pub const WGPURenderPassDepthStencilAttachment = extern struct {
    view: WGPUTextureView,
    depthLoadOp: WGPULoadOp,
    depthStoreOp: WGPUStoreOp,
    clearDepth: f32,
    depthReadOnly: bool,
    stencilLoadOp: WGPULoadOp,
    stencilStoreOp: WGPUStoreOp,
    clearStencil: u32,
    stencilReadOnly: bool,
};
pub const WGPURequestAdapterOptions = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    compatibleSurface: WGPUSurface,
    powerPreference: WGPUPowerPreference,
    forceFallbackAdapter: bool,
};
pub const WGPUSamplerBindingLayout = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    type: WGPUSamplerBindingType,
};
pub const WGPUSamplerDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    addressModeU: WGPUAddressMode,
    addressModeV: WGPUAddressMode,
    addressModeW: WGPUAddressMode,
    magFilter: WGPUFilterMode,
    minFilter: WGPUFilterMode,
    mipmapFilter: WGPUFilterMode,
    lodMinClamp: f32,
    lodMaxClamp: f32,
    compare: WGPUCompareFunction,
    maxAnisotropy: u16,
};
pub const WGPUShaderModuleDescriptor = extern struct {
    nextInChain: *const WGPUChainedStruct,
    label: ?[*:0]const u8,
};
pub const WGPUShaderModuleSPIRVDescriptor = extern struct {
    chain: WGPUChainedStruct,
    codeSize: u32,
    code: [*c]const u32,
};
pub const WGPUShaderModuleWGSLDescriptor = extern struct {
    chain: WGPUChainedStruct,
    source: [*]const u8,
};
pub const WGPUStencilFaceState = extern struct {
    compare: WGPUCompareFunction,
    failOp: WGPUStencilOperation,
    depthFailOp: WGPUStencilOperation,
    passOp: WGPUStencilOperation,
};
pub const WGPUStorageTextureBindingLayout = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    access: WGPUStorageTextureAccess,
    format: WGPUTextureFormat,
    viewDimension: WGPUTextureViewDimension,
};
pub const WGPUSurfaceDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
};
pub const WGPUSurfaceDescriptorFromCanvasHTMLSelector = extern struct {
    chain: WGPUChainedStruct,
    selector: [*c]const u8,
};
pub const WGPUSurfaceDescriptorFromMetalLayer = extern struct {
    chain: WGPUChainedStruct,
    layer: ?*c_void,
};
pub const WGPUSurfaceDescriptorFromWindowsHWND = extern struct {
    chain: WGPUChainedStruct,
    hinstance: ?*c_void,
    hwnd: ?*c_void,
};
pub const WGPUSurfaceDescriptorFromXlib = extern struct {
    chain: WGPUChainedStruct,
    display: ?*c_void,
    window: u32,
};
pub const WGPUSwapChainDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    usage: WGPUTextureUsageFlags,
    format: WGPUTextureFormat,
    width: u32,
    height: u32,
    presentMode: WGPUPresentMode,
};
pub const WGPUTextureBindingLayout = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    sampleType: WGPUTextureSampleType,
    viewDimension: WGPUTextureViewDimension,
    multisampled: bool,
};
pub const WGPUTextureDataLayout = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    offset: u64,
    bytesPerRow: u32,
    rowsPerImage: u32,
};
pub const WGPUTextureViewDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    format: WGPUTextureFormat,
    dimension: WGPUTextureViewDimension,
    baseMipLevel: u32,
    mipLevelCount: u32,
    baseArrayLayer: u32,
    arrayLayerCount: u32,
    aspect: WGPUTextureAspect,
};
pub const WGPUVertexAttribute = extern struct {
    format: WGPUVertexFormat,
    offset: u64,
    shaderLocation: u32,
};
pub const WGPUBindGroupDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    layout: WGPUBindGroupLayout,
    entryCount: u32,
    entries: [*c]const WGPUBindGroupEntry,
};
pub const WGPUBindGroupLayoutEntry = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    binding: u32,
    visibility: WGPUShaderStageFlags,
    buffer: WGPUBufferBindingLayout,
    sampler: WGPUSamplerBindingLayout,
    texture: WGPUTextureBindingLayout,
    storageTexture: WGPUStorageTextureBindingLayout,
};
pub const WGPUBlendState = extern struct {
    color: WGPUBlendComponent,
    alpha: WGPUBlendComponent,
};
pub const WGPUCompilationInfo = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    messageCount: u32,
    messages: [*c]const WGPUCompilationMessage,
};
pub const WGPUDepthStencilState = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    format: WGPUTextureFormat,
    depthWriteEnabled: bool,
    depthCompare: WGPUCompareFunction,
    stencilFront: WGPUStencilFaceState,
    stencilBack: WGPUStencilFaceState,
    stencilReadMask: u32,
    stencilWriteMask: u32,
    depthBias: i32,
    depthBiasSlopeScale: f32,
    depthBiasClamp: f32,
};
pub const WGPUImageCopyBuffer = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    layout: WGPUTextureDataLayout,
    buffer: WGPUBuffer,
};
pub const WGPUImageCopyTexture = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    texture: WGPUTexture,
    mipLevel: u32,
    origin: WGPUOrigin3D,
    aspect: WGPUTextureAspect,
};
pub const WGPUProgrammableStageDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    module: WGPUShaderModule,
    entryPoint: [*c]const u8,
    constantCount: u32,
    constants: [*c]const WGPUConstantEntry,
};
pub const WGPURenderPassColorAttachment = extern struct {
    view: WGPUTextureView,
    resolveTarget: WGPUTextureView,
    loadOp: WGPULoadOp,
    storeOp: WGPUStoreOp,
    clearColor: WGPUColor,
};
pub const WGPURequiredLimits = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    limits: WGPULimits,
};
pub const WGPUSupportedLimits = extern struct {
    nextInChain: [*c]WGPUChainedStructOut,
    limits: WGPULimits,
};
pub const WGPUTextureDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    usage: WGPUTextureUsageFlags,
    dimension: WGPUTextureDimension,
    size: WGPUExtent3D,
    format: WGPUTextureFormat,
    mipLevelCount: u32,
    sampleCount: u32,
};
pub const WGPUVertexBufferLayout = extern struct {
    arrayStride: u64,
    stepMode: WGPUVertexStepMode,
    attributeCount: u32,
    attributes: [*c]const WGPUVertexAttribute,
};
pub const WGPUBindGroupLayoutDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    entryCount: u32,
    entries: [*c]const WGPUBindGroupLayoutEntry,
};
pub const WGPUColorTargetState = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    format: WGPUTextureFormat,
    blend: [*c]const WGPUBlendState,
    writeMask: WGPUColorWriteMaskFlags,
};
pub const WGPUComputePipelineDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    layout: WGPUPipelineLayout,
    compute: WGPUProgrammableStageDescriptor,
};
pub const WGPUDeviceDescriptor = extern struct {
    nextInChain: *const WGPUChainedStruct,
    requiredFeaturesCount: u32,
    requiredFeatures: [*]const WGPUFeatureName,
    requiredLimits: [*c]const WGPURequiredLimits,
};
pub const WGPURenderPassDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    colorAttachmentCount: u32,
    colorAttachments: [*c]const WGPURenderPassColorAttachment,
    depthStencilAttachment: [*c]const WGPURenderPassDepthStencilAttachment,
    occlusionQuerySet: WGPUQuerySet,
};
pub const WGPUVertexState = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    module: WGPUShaderModule,
    entryPoint: [*c]const u8,
    constantCount: u32,
    constants: [*c]const WGPUConstantEntry,
    bufferCount: u32,
    buffers: [*c]const WGPUVertexBufferLayout,
};
pub const WGPUFragmentState = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    module: WGPUShaderModule,
    entryPoint: [*c]const u8,
    constantCount: u32,
    constants: [*c]const WGPUConstantEntry,
    targetCount: u32,
    targets: [*c]const WGPUColorTargetState,
};
pub const WGPURenderPipelineDescriptor = extern struct {
    nextInChain: [*c]const WGPUChainedStruct,
    label: [*c]const u8,
    layout: WGPUPipelineLayout,
    vertex: WGPUVertexState,
    primitive: WGPUPrimitiveState,
    depthStencil: [*c]const WGPUDepthStencilState,
    multisample: WGPUMultisampleState,
    fragment: [*c]const WGPUFragmentState,
};

pub const WGPUBufferMapCallback = ?fn (WGPUBufferMapAsyncStatus, ?*c_void) callconv(.C) void;
pub const WGPUCreateComputePipelineAsyncCallback = ?fn (WGPUCreatePipelineAsyncStatus, WGPUComputePipeline, [*c]const u8, ?*c_void) callconv(.C) void;
pub const WGPUCreateRenderPipelineAsyncCallback = ?fn (WGPUCreatePipelineAsyncStatus, WGPURenderPipeline, [*c]const u8, ?*c_void) callconv(.C) void;
pub const WGPUDeviceLostCallback = ?fn (WGPUDeviceLostReason, [*c]const u8, ?*c_void) callconv(.C) void;
pub const WGPUErrorCallback = ?fn (WGPUErrorType, [*c]const u8, ?*c_void) callconv(.C) void;
pub const WGPUQueueWorkDoneCallback = ?fn (WGPUQueueWorkDoneStatus, ?*c_void) callconv(.C) void;
pub const WGPURequestAdapterCallback = fn (WGPURequestAdapterStatus, WGPUAdapter, [*:0]const u8, *c_void) callconv(.C) void;
pub const WGPURequestDeviceCallback = fn (WGPURequestDeviceStatus, WGPUDevice, [*:0]const u8, *c_void) callconv(.C) void;
pub const WGPUProc = ?fn () callconv(.C) void;
pub const WGPUProcCreateInstance = ?fn ([*c]const WGPUInstanceDescriptor) callconv(.C) WGPUInstance;
pub const WGPUProcGetProcAddress = ?fn (WGPUDevice, [*c]const u8) callconv(.C) WGPUProc;
pub const WGPUProcAdapterGetLimits = ?fn (WGPUAdapter, [*c]WGPUSupportedLimits) callconv(.C) bool;
pub const WGPUProcAdapterGetProperties = ?fn (WGPUAdapter, [*c]WGPUAdapterProperties) callconv(.C) void;
pub const WGPUProcAdapterHasFeature = ?fn (WGPUAdapter, WGPUFeatureName) callconv(.C) bool;
pub const WGPUProcAdapterRequestDevice = ?fn (WGPUAdapter, [*c]const WGPUDeviceDescriptor, WGPURequestDeviceCallback, ?*c_void) callconv(.C) void;
pub const WGPUProcBufferDestroy = ?fn (WGPUBuffer) callconv(.C) void;
pub const WGPUProcBufferGetConstMappedRange = ?fn (WGPUBuffer, usize, usize) callconv(.C) ?*const c_void;
pub const WGPUProcBufferGetMappedRange = ?fn (WGPUBuffer, usize, usize) callconv(.C) ?*c_void;
pub const WGPUProcBufferMapAsync = ?fn (WGPUBuffer, WGPUMapModeFlags, usize, usize, WGPUBufferMapCallback, ?*c_void) callconv(.C) void;
pub const WGPUProcBufferUnmap = ?fn (WGPUBuffer) callconv(.C) void;
pub const WGPUProcCommandEncoderBeginComputePass = ?fn (WGPUCommandEncoder, [*c]const WGPUComputePassDescriptor) callconv(.C) WGPUComputePassEncoder;
pub const WGPUProcCommandEncoderBeginRenderPass = ?fn (WGPUCommandEncoder, [*c]const WGPURenderPassDescriptor) callconv(.C) WGPURenderPassEncoder;
pub const WGPUProcCommandEncoderCopyBufferToBuffer = ?fn (WGPUCommandEncoder, WGPUBuffer, u64, WGPUBuffer, u64, u64) callconv(.C) void;
pub const WGPUProcCommandEncoderCopyBufferToTexture = ?fn (WGPUCommandEncoder, [*c]const WGPUImageCopyBuffer, [*c]const WGPUImageCopyTexture, [*c]const WGPUExtent3D) callconv(.C) void;
pub const WGPUProcCommandEncoderCopyTextureToBuffer = ?fn (WGPUCommandEncoder, [*c]const WGPUImageCopyTexture, [*c]const WGPUImageCopyBuffer, [*c]const WGPUExtent3D) callconv(.C) void;
pub const WGPUProcCommandEncoderCopyTextureToTexture = ?fn (WGPUCommandEncoder, [*c]const WGPUImageCopyTexture, [*c]const WGPUImageCopyTexture, [*c]const WGPUExtent3D) callconv(.C) void;
pub const WGPUProcCommandEncoderFinish = ?fn (WGPUCommandEncoder, [*c]const WGPUCommandBufferDescriptor) callconv(.C) WGPUCommandBuffer;
pub const WGPUProcCommandEncoderInsertDebugMarker = ?fn (WGPUCommandEncoder, [*c]const u8) callconv(.C) void;
pub const WGPUProcCommandEncoderPopDebugGroup = ?fn (WGPUCommandEncoder) callconv(.C) void;
pub const WGPUProcCommandEncoderPushDebugGroup = ?fn (WGPUCommandEncoder, [*c]const u8) callconv(.C) void;
pub const WGPUProcCommandEncoderResolveQuerySet = ?fn (WGPUCommandEncoder, WGPUQuerySet, u32, u32, WGPUBuffer, u64) callconv(.C) void;
pub const WGPUProcCommandEncoderWriteTimestamp = ?fn (WGPUCommandEncoder, WGPUQuerySet, u32) callconv(.C) void;
pub const WGPUProcComputePassEncoderBeginPipelineStatisticsQuery = ?fn (WGPUComputePassEncoder, WGPUQuerySet, u32) callconv(.C) void;
pub const WGPUProcComputePassEncoderDispatch = ?fn (WGPUComputePassEncoder, u32, u32, u32) callconv(.C) void;
pub const WGPUProcComputePassEncoderDispatchIndirect = ?fn (WGPUComputePassEncoder, WGPUBuffer, u64) callconv(.C) void;
pub const WGPUProcComputePassEncoderEndPass = ?fn (WGPUComputePassEncoder) callconv(.C) void;
pub const WGPUProcComputePassEncoderEndPipelineStatisticsQuery = ?fn (WGPUComputePassEncoder) callconv(.C) void;
pub const WGPUProcComputePassEncoderInsertDebugMarker = ?fn (WGPUComputePassEncoder, [*c]const u8) callconv(.C) void;
pub const WGPUProcComputePassEncoderPopDebugGroup = ?fn (WGPUComputePassEncoder) callconv(.C) void;
pub const WGPUProcComputePassEncoderPushDebugGroup = ?fn (WGPUComputePassEncoder, [*c]const u8) callconv(.C) void;
pub const WGPUProcComputePassEncoderSetBindGroup = ?fn (WGPUComputePassEncoder, u32, WGPUBindGroup, u32, [*c]const u32) callconv(.C) void;
pub const WGPUProcComputePassEncoderSetPipeline = ?fn (WGPUComputePassEncoder, WGPUComputePipeline) callconv(.C) void;
pub const WGPUProcComputePassEncoderWriteTimestamp = ?fn (WGPUComputePassEncoder, WGPUQuerySet, u32) callconv(.C) void;
pub const WGPUProcComputePipelineGetBindGroupLayout = ?fn (WGPUComputePipeline, u32) callconv(.C) WGPUBindGroupLayout;
pub const WGPUProcComputePipelineSetLabel = ?fn (WGPUComputePipeline, [*c]const u8) callconv(.C) void;
pub const WGPUProcDeviceCreateBindGroup = ?fn (WGPUDevice, [*c]const WGPUBindGroupDescriptor) callconv(.C) WGPUBindGroup;
pub const WGPUProcDeviceCreateBindGroupLayout = ?fn (WGPUDevice, [*c]const WGPUBindGroupLayoutDescriptor) callconv(.C) WGPUBindGroupLayout;
pub const WGPUProcDeviceCreateBuffer = ?fn (WGPUDevice, [*c]const WGPUBufferDescriptor) callconv(.C) WGPUBuffer;
pub const WGPUProcDeviceCreateCommandEncoder = ?fn (WGPUDevice, [*c]const WGPUCommandEncoderDescriptor) callconv(.C) WGPUCommandEncoder;
pub const WGPUProcDeviceCreateComputePipeline = ?fn (WGPUDevice, [*c]const WGPUComputePipelineDescriptor) callconv(.C) WGPUComputePipeline;
pub const WGPUProcDeviceCreateComputePipelineAsync = ?fn (WGPUDevice, [*c]const WGPUComputePipelineDescriptor, WGPUCreateComputePipelineAsyncCallback, ?*c_void) callconv(.C) void;
pub const WGPUProcDeviceCreatePipelineLayout = ?fn (WGPUDevice, [*c]const WGPUPipelineLayoutDescriptor) callconv(.C) WGPUPipelineLayout;
pub const WGPUProcDeviceCreateQuerySet = ?fn (WGPUDevice, [*c]const WGPUQuerySetDescriptor) callconv(.C) WGPUQuerySet;
pub const WGPUProcDeviceCreateRenderBundleEncoder = ?fn (WGPUDevice, [*c]const WGPURenderBundleEncoderDescriptor) callconv(.C) WGPURenderBundleEncoder;
pub const WGPUProcDeviceCreateRenderPipeline = ?fn (WGPUDevice, [*c]const WGPURenderPipelineDescriptor) callconv(.C) WGPURenderPipeline;
pub const WGPUProcDeviceCreateRenderPipelineAsync = ?fn (WGPUDevice, [*c]const WGPURenderPipelineDescriptor, WGPUCreateRenderPipelineAsyncCallback, ?*c_void) callconv(.C) void;
pub const WGPUProcDeviceCreateSampler = ?fn (WGPUDevice, [*c]const WGPUSamplerDescriptor) callconv(.C) WGPUSampler;
pub const WGPUProcDeviceCreateShaderModule = ?fn (WGPUDevice, [*c]const WGPUShaderModuleDescriptor) callconv(.C) WGPUShaderModule;
pub const WGPUProcDeviceCreateSwapChain = ?fn (WGPUDevice, WGPUSurface, [*c]const WGPUSwapChainDescriptor) callconv(.C) WGPUSwapChain;
pub const WGPUProcDeviceCreateTexture = ?fn (WGPUDevice, [*c]const WGPUTextureDescriptor) callconv(.C) WGPUTexture;
pub const WGPUProcDeviceDestroy = ?fn (WGPUDevice) callconv(.C) void;
pub const WGPUProcDeviceGetLimits = ?fn (WGPUDevice, [*c]WGPUSupportedLimits) callconv(.C) bool;
pub const WGPUProcDeviceGetQueue = ?fn (WGPUDevice) callconv(.C) WGPUQueue;
pub const WGPUProcDevicePopErrorScope = ?fn (WGPUDevice, WGPUErrorCallback, ?*c_void) callconv(.C) bool;
pub const WGPUProcDevicePushErrorScope = ?fn (WGPUDevice, WGPUErrorFilter) callconv(.C) void;
pub const WGPUProcDeviceSetDeviceLostCallback = ?fn (WGPUDevice, WGPUDeviceLostCallback, ?*c_void) callconv(.C) void;
pub const WGPUProcDeviceSetUncapturedErrorCallback = ?fn (WGPUDevice, WGPUErrorCallback, ?*c_void) callconv(.C) void;
pub const WGPUProcInstanceCreateSurface = ?fn (WGPUInstance, [*c]const WGPUSurfaceDescriptor) callconv(.C) WGPUSurface;
pub const WGPUProcInstanceProcessEvents = ?fn (WGPUInstance) callconv(.C) void;
pub const WGPUProcInstanceRequestAdapter = ?fn (WGPUInstance, [*c]const WGPURequestAdapterOptions, WGPURequestAdapterCallback, ?*c_void) callconv(.C) void;
pub const WGPUProcQuerySetDestroy = ?fn (WGPUQuerySet) callconv(.C) void;
pub const WGPUProcQueueOnSubmittedWorkDone = ?fn (WGPUQueue, u64, WGPUQueueWorkDoneCallback, ?*c_void) callconv(.C) void;
pub const WGPUProcQueueSubmit = ?fn (WGPUQueue, u32, [*c]const WGPUCommandBuffer) callconv(.C) void;
pub const WGPUProcQueueWriteBuffer = ?fn (WGPUQueue, WGPUBuffer, u64, ?*const c_void, usize) callconv(.C) void;
pub const WGPUProcQueueWriteTexture = ?fn (WGPUQueue, [*c]const WGPUImageCopyTexture, ?*const c_void, usize, [*c]const WGPUTextureDataLayout, [*c]const WGPUExtent3D) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderDraw = ?fn (WGPURenderBundleEncoder, u32, u32, u32, u32) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderDrawIndexed = ?fn (WGPURenderBundleEncoder, u32, u32, u32, i32, u32) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderDrawIndexedIndirect = ?fn (WGPURenderBundleEncoder, WGPUBuffer, u64) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderDrawIndirect = ?fn (WGPURenderBundleEncoder, WGPUBuffer, u64) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderFinish = ?fn (WGPURenderBundleEncoder, [*c]const WGPURenderBundleDescriptor) callconv(.C) WGPURenderBundle;
pub const WGPUProcRenderBundleEncoderInsertDebugMarker = ?fn (WGPURenderBundleEncoder, [*c]const u8) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderPopDebugGroup = ?fn (WGPURenderBundleEncoder) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderPushDebugGroup = ?fn (WGPURenderBundleEncoder, [*c]const u8) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderSetBindGroup = ?fn (WGPURenderBundleEncoder, u32, WGPUBindGroup, u32, [*c]const u32) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderSetIndexBuffer = ?fn (WGPURenderBundleEncoder, WGPUBuffer, WGPUIndexFormat, u64, u64) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderSetPipeline = ?fn (WGPURenderBundleEncoder, WGPURenderPipeline) callconv(.C) void;
pub const WGPUProcRenderBundleEncoderSetVertexBuffer = ?fn (WGPURenderBundleEncoder, u32, WGPUBuffer, u64, u64) callconv(.C) void;
pub const WGPUProcRenderPassEncoderBeginOcclusionQuery = ?fn (WGPURenderPassEncoder, u32) callconv(.C) void;
pub const WGPUProcRenderPassEncoderBeginPipelineStatisticsQuery = ?fn (WGPURenderPassEncoder, WGPUQuerySet, u32) callconv(.C) void;
pub const WGPUProcRenderPassEncoderDraw = ?fn (WGPURenderPassEncoder, u32, u32, u32, u32) callconv(.C) void;
pub const WGPUProcRenderPassEncoderDrawIndexed = ?fn (WGPURenderPassEncoder, u32, u32, u32, i32, u32) callconv(.C) void;
pub const WGPUProcRenderPassEncoderDrawIndexedIndirect = ?fn (WGPURenderPassEncoder, WGPUBuffer, u64) callconv(.C) void;
pub const WGPUProcRenderPassEncoderDrawIndirect = ?fn (WGPURenderPassEncoder, WGPUBuffer, u64) callconv(.C) void;
pub const WGPUProcRenderPassEncoderEndOcclusionQuery = ?fn (WGPURenderPassEncoder) callconv(.C) void;
pub const WGPUProcRenderPassEncoderEndPass = ?fn (WGPURenderPassEncoder) callconv(.C) void;
pub const WGPUProcRenderPassEncoderEndPipelineStatisticsQuery = ?fn (WGPURenderPassEncoder) callconv(.C) void;
pub const WGPUProcRenderPassEncoderExecuteBundles = ?fn (WGPURenderPassEncoder, u32, [*c]const WGPURenderBundle) callconv(.C) void;
pub const WGPUProcRenderPassEncoderInsertDebugMarker = ?fn (WGPURenderPassEncoder, [*c]const u8) callconv(.C) void;
pub const WGPUProcRenderPassEncoderPopDebugGroup = ?fn (WGPURenderPassEncoder) callconv(.C) void;
pub const WGPUProcRenderPassEncoderPushDebugGroup = ?fn (WGPURenderPassEncoder, [*c]const u8) callconv(.C) void;
pub const WGPUProcRenderPassEncoderSetBindGroup = ?fn (WGPURenderPassEncoder, u32, WGPUBindGroup, u32, [*c]const u32) callconv(.C) void;
pub const WGPUProcRenderPassEncoderSetBlendConstant = ?fn (WGPURenderPassEncoder, [*c]const WGPUColor) callconv(.C) void;
pub const WGPUProcRenderPassEncoderSetIndexBuffer = ?fn (WGPURenderPassEncoder, WGPUBuffer, WGPUIndexFormat, u64, u64) callconv(.C) void;
pub const WGPUProcRenderPassEncoderSetPipeline = ?fn (WGPURenderPassEncoder, WGPURenderPipeline) callconv(.C) void;
pub const WGPUProcRenderPassEncoderSetScissorRect = ?fn (WGPURenderPassEncoder, u32, u32, u32, u32) callconv(.C) void;
pub const WGPUProcRenderPassEncoderSetStencilReference = ?fn (WGPURenderPassEncoder, u32) callconv(.C) void;
pub const WGPUProcRenderPassEncoderSetVertexBuffer = ?fn (WGPURenderPassEncoder, u32, WGPUBuffer, u64, u64) callconv(.C) void;
pub const WGPUProcRenderPassEncoderSetViewport = ?fn (WGPURenderPassEncoder, f32, f32, f32, f32, f32, f32) callconv(.C) void;
pub const WGPUProcRenderPassEncoderWriteTimestamp = ?fn (WGPURenderPassEncoder, WGPUQuerySet, u32) callconv(.C) void;
pub const WGPUProcRenderPipelineGetBindGroupLayout = ?fn (WGPURenderPipeline, u32) callconv(.C) WGPUBindGroupLayout;
pub const WGPUProcRenderPipelineSetLabel = ?fn (WGPURenderPipeline, [*c]const u8) callconv(.C) void;
pub const WGPUProcShaderModuleSetLabel = ?fn (WGPUShaderModule, [*c]const u8) callconv(.C) void;
pub const WGPUProcSurfaceGetPreferredFormat = ?fn (WGPUSurface, WGPUAdapter) callconv(.C) WGPUTextureFormat;
pub const WGPUProcSwapChainGetCurrentTextureView = ?fn (WGPUSwapChain) callconv(.C) WGPUTextureView;
pub const WGPUProcSwapChainPresent = ?fn (WGPUSwapChain) callconv(.C) void;
pub const WGPUProcTextureCreateView = ?fn (WGPUTexture, [*c]const WGPUTextureViewDescriptor) callconv(.C) WGPUTextureView;
pub const WGPUProcTextureDestroy = ?fn (WGPUTexture) callconv(.C) void;
pub extern fn wgpuCreateInstance(descriptor: [*c]const WGPUInstanceDescriptor) WGPUInstance;
pub extern fn wgpuGetProcAddress(device: WGPUDevice, procName: [*c]const u8) WGPUProc;
pub extern fn wgpuAdapterGetLimits(adapter: WGPUAdapter, limits: [*c]WGPUSupportedLimits) bool;
pub extern fn wgpuAdapterGetProperties(adapter: WGPUAdapter, properties: [*c]WGPUAdapterProperties) void;
pub extern fn wgpuAdapterHasFeature(adapter: WGPUAdapter, feature: WGPUFeatureName) bool;
pub extern fn wgpuAdapterRequestDevice(adapter: WGPUAdapter, descriptor: *const WGPUDeviceDescriptor, callback: WGPURequestDeviceCallback, userdata: *c_void) void;
pub extern fn wgpuBufferDestroy(buffer: WGPUBuffer) void;
pub extern fn wgpuBufferGetConstMappedRange(buffer: WGPUBuffer, offset: usize, size: usize) ?*const c_void;
pub extern fn wgpuBufferGetMappedRange(buffer: WGPUBuffer, offset: usize, size: usize) ?*c_void;
pub extern fn wgpuBufferMapAsync(buffer: WGPUBuffer, mode: WGPUMapModeFlags, offset: usize, size: usize, callback: WGPUBufferMapCallback, userdata: ?*c_void) void;
pub extern fn wgpuBufferUnmap(buffer: WGPUBuffer) void;
pub extern fn wgpuCommandEncoderBeginComputePass(commandEncoder: WGPUCommandEncoder, descriptor: [*c]const WGPUComputePassDescriptor) WGPUComputePassEncoder;
pub extern fn wgpuCommandEncoderBeginRenderPass(commandEncoder: WGPUCommandEncoder, descriptor: [*c]const WGPURenderPassDescriptor) WGPURenderPassEncoder;
pub extern fn wgpuCommandEncoderCopyBufferToBuffer(commandEncoder: WGPUCommandEncoder, source: WGPUBuffer, sourceOffset: u64, destination: WGPUBuffer, destinationOffset: u64, size: u64) void;
pub extern fn wgpuCommandEncoderCopyBufferToTexture(commandEncoder: WGPUCommandEncoder, source: [*c]const WGPUImageCopyBuffer, destination: [*c]const WGPUImageCopyTexture, copySize: [*c]const WGPUExtent3D) void;
pub extern fn wgpuCommandEncoderCopyTextureToBuffer(commandEncoder: WGPUCommandEncoder, source: [*c]const WGPUImageCopyTexture, destination: [*c]const WGPUImageCopyBuffer, copySize: [*c]const WGPUExtent3D) void;
pub extern fn wgpuCommandEncoderCopyTextureToTexture(commandEncoder: WGPUCommandEncoder, source: [*c]const WGPUImageCopyTexture, destination: [*c]const WGPUImageCopyTexture, copySize: [*c]const WGPUExtent3D) void;
pub extern fn wgpuCommandEncoderFinish(commandEncoder: WGPUCommandEncoder, descriptor: [*c]const WGPUCommandBufferDescriptor) WGPUCommandBuffer;
pub extern fn wgpuCommandEncoderInsertDebugMarker(commandEncoder: WGPUCommandEncoder, markerLabel: [*c]const u8) void;
pub extern fn wgpuCommandEncoderPopDebugGroup(commandEncoder: WGPUCommandEncoder) void;
pub extern fn wgpuCommandEncoderPushDebugGroup(commandEncoder: WGPUCommandEncoder, groupLabel: [*c]const u8) void;
pub extern fn wgpuCommandEncoderResolveQuerySet(commandEncoder: WGPUCommandEncoder, querySet: WGPUQuerySet, firstQuery: u32, queryCount: u32, destination: WGPUBuffer, destinationOffset: u64) void;
pub extern fn wgpuCommandEncoderWriteTimestamp(commandEncoder: WGPUCommandEncoder, querySet: WGPUQuerySet, queryIndex: u32) void;
pub extern fn wgpuComputePassEncoderBeginPipelineStatisticsQuery(computePassEncoder: WGPUComputePassEncoder, querySet: WGPUQuerySet, queryIndex: u32) void;
pub extern fn wgpuComputePassEncoderDispatch(computePassEncoder: WGPUComputePassEncoder, x: u32, y: u32, z: u32) void;
pub extern fn wgpuComputePassEncoderDispatchIndirect(computePassEncoder: WGPUComputePassEncoder, indirectBuffer: WGPUBuffer, indirectOffset: u64) void;
pub extern fn wgpuComputePassEncoderEndPass(computePassEncoder: WGPUComputePassEncoder) void;
pub extern fn wgpuComputePassEncoderEndPipelineStatisticsQuery(computePassEncoder: WGPUComputePassEncoder) void;
pub extern fn wgpuComputePassEncoderInsertDebugMarker(computePassEncoder: WGPUComputePassEncoder, markerLabel: [*c]const u8) void;
pub extern fn wgpuComputePassEncoderPopDebugGroup(computePassEncoder: WGPUComputePassEncoder) void;
pub extern fn wgpuComputePassEncoderPushDebugGroup(computePassEncoder: WGPUComputePassEncoder, groupLabel: [*c]const u8) void;
pub extern fn wgpuComputePassEncoderSetBindGroup(computePassEncoder: WGPUComputePassEncoder, groupIndex: u32, group: WGPUBindGroup, dynamicOffsetCount: u32, dynamicOffsets: [*c]const u32) void;
pub extern fn wgpuComputePassEncoderSetPipeline(computePassEncoder: WGPUComputePassEncoder, pipeline: WGPUComputePipeline) void;
pub extern fn wgpuComputePassEncoderWriteTimestamp(computePassEncoder: WGPUComputePassEncoder, querySet: WGPUQuerySet, queryIndex: u32) void;
pub extern fn wgpuComputePipelineGetBindGroupLayout(computePipeline: WGPUComputePipeline, groupIndex: u32) WGPUBindGroupLayout;
pub extern fn wgpuComputePipelineSetLabel(computePipeline: WGPUComputePipeline, label: [*c]const u8) void;
pub extern fn wgpuDeviceCreateBindGroup(device: WGPUDevice, descriptor: [*c]const WGPUBindGroupDescriptor) WGPUBindGroup;
pub extern fn wgpuDeviceCreateBindGroupLayout(device: WGPUDevice, descriptor: [*c]const WGPUBindGroupLayoutDescriptor) WGPUBindGroupLayout;
pub extern fn wgpuDeviceCreateBuffer(device: WGPUDevice, descriptor: [*c]const WGPUBufferDescriptor) WGPUBuffer;
pub extern fn wgpuDeviceCreateCommandEncoder(device: WGPUDevice, descriptor: [*c]const WGPUCommandEncoderDescriptor) WGPUCommandEncoder;
pub extern fn wgpuDeviceCreateComputePipeline(device: WGPUDevice, descriptor: [*c]const WGPUComputePipelineDescriptor) WGPUComputePipeline;
pub extern fn wgpuDeviceCreateComputePipelineAsync(device: WGPUDevice, descriptor: [*c]const WGPUComputePipelineDescriptor, callback: WGPUCreateComputePipelineAsyncCallback, userdata: ?*c_void) void;
pub extern fn wgpuDeviceCreatePipelineLayout(device: WGPUDevice, descriptor: [*c]const WGPUPipelineLayoutDescriptor) WGPUPipelineLayout;
pub extern fn wgpuDeviceCreateQuerySet(device: WGPUDevice, descriptor: [*c]const WGPUQuerySetDescriptor) WGPUQuerySet;
pub extern fn wgpuDeviceCreateRenderBundleEncoder(device: WGPUDevice, descriptor: [*c]const WGPURenderBundleEncoderDescriptor) WGPURenderBundleEncoder;
pub extern fn wgpuDeviceCreateRenderPipeline(device: WGPUDevice, descriptor: [*c]const WGPURenderPipelineDescriptor) WGPURenderPipeline;
pub extern fn wgpuDeviceCreateRenderPipelineAsync(device: WGPUDevice, descriptor: [*c]const WGPURenderPipelineDescriptor, callback: WGPUCreateRenderPipelineAsyncCallback, userdata: ?*c_void) void;
pub extern fn wgpuDeviceCreateSampler(device: WGPUDevice, descriptor: [*c]const WGPUSamplerDescriptor) WGPUSampler;
pub extern fn wgpuDeviceCreateShaderModule(device: WGPUDevice, descriptor: *const WGPUShaderModuleDescriptor) WGPUShaderModule;
pub extern fn wgpuDeviceCreateSwapChain(device: WGPUDevice, surface: WGPUSurface, descriptor: [*c]const WGPUSwapChainDescriptor) WGPUSwapChain;
pub extern fn wgpuDeviceCreateTexture(device: WGPUDevice, descriptor: [*c]const WGPUTextureDescriptor) WGPUTexture;
pub extern fn wgpuDeviceDestroy(device: WGPUDevice) void;
pub extern fn wgpuDeviceGetLimits(device: WGPUDevice, limits: [*c]WGPUSupportedLimits) bool;
pub extern fn wgpuDeviceGetQueue(device: WGPUDevice) WGPUQueue;
pub extern fn wgpuDevicePopErrorScope(device: WGPUDevice, callback: WGPUErrorCallback, userdata: ?*c_void) bool;
pub extern fn wgpuDevicePushErrorScope(device: WGPUDevice, filter: WGPUErrorFilter) void;
pub extern fn wgpuDeviceSetDeviceLostCallback(device: WGPUDevice, callback: WGPUDeviceLostCallback, userdata: ?*c_void) void;
pub extern fn wgpuDeviceSetUncapturedErrorCallback(device: WGPUDevice, callback: WGPUErrorCallback, userdata: ?*c_void) void;
pub extern fn wgpuInstanceCreateSurface(instance: WGPUInstance, descriptor: *const WGPUSurfaceDescriptor) WGPUSurface;
pub extern fn wgpuInstanceProcessEvents(instance: WGPUInstance) void;
pub extern fn wgpuInstanceRequestAdapter(instance: WGPUInstance, options: ?*const WGPURequestAdapterOptions, callback: WGPURequestAdapterCallback, userdata: ?*c_void) void;
pub extern fn wgpuQuerySetDestroy(querySet: WGPUQuerySet) void;
pub extern fn wgpuQueueOnSubmittedWorkDone(queue: WGPUQueue, signalValue: u64, callback: WGPUQueueWorkDoneCallback, userdata: ?*c_void) void;
pub extern fn wgpuQueueSubmit(queue: WGPUQueue, commandCount: u32, commands: [*c]const WGPUCommandBuffer) void;
pub extern fn wgpuQueueWriteBuffer(queue: WGPUQueue, buffer: WGPUBuffer, bufferOffset: u64, data: ?*const c_void, size: usize) void;
pub extern fn wgpuQueueWriteTexture(queue: WGPUQueue, destination: [*c]const WGPUImageCopyTexture, data: ?*const c_void, dataSize: usize, dataLayout: [*c]const WGPUTextureDataLayout, writeSize: [*c]const WGPUExtent3D) void;
pub extern fn wgpuRenderBundleEncoderDraw(renderBundleEncoder: WGPURenderBundleEncoder, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32) void;
pub extern fn wgpuRenderBundleEncoderDrawIndexed(renderBundleEncoder: WGPURenderBundleEncoder, indexCount: u32, instanceCount: u32, firstIndex: u32, baseVertex: i32, firstInstance: u32) void;
pub extern fn wgpuRenderBundleEncoderDrawIndexedIndirect(renderBundleEncoder: WGPURenderBundleEncoder, indirectBuffer: WGPUBuffer, indirectOffset: u64) void;
pub extern fn wgpuRenderBundleEncoderDrawIndirect(renderBundleEncoder: WGPURenderBundleEncoder, indirectBuffer: WGPUBuffer, indirectOffset: u64) void;
pub extern fn wgpuRenderBundleEncoderFinish(renderBundleEncoder: WGPURenderBundleEncoder, descriptor: [*c]const WGPURenderBundleDescriptor) WGPURenderBundle;
pub extern fn wgpuRenderBundleEncoderInsertDebugMarker(renderBundleEncoder: WGPURenderBundleEncoder, markerLabel: [*c]const u8) void;
pub extern fn wgpuRenderBundleEncoderPopDebugGroup(renderBundleEncoder: WGPURenderBundleEncoder) void;
pub extern fn wgpuRenderBundleEncoderPushDebugGroup(renderBundleEncoder: WGPURenderBundleEncoder, groupLabel: [*c]const u8) void;
pub extern fn wgpuRenderBundleEncoderSetBindGroup(renderBundleEncoder: WGPURenderBundleEncoder, groupIndex: u32, group: WGPUBindGroup, dynamicOffsetCount: u32, dynamicOffsets: [*c]const u32) void;
pub extern fn wgpuRenderBundleEncoderSetIndexBuffer(renderBundleEncoder: WGPURenderBundleEncoder, buffer: WGPUBuffer, format: WGPUIndexFormat, offset: u64, size: u64) void;
pub extern fn wgpuRenderBundleEncoderSetPipeline(renderBundleEncoder: WGPURenderBundleEncoder, pipeline: WGPURenderPipeline) void;
pub extern fn wgpuRenderBundleEncoderSetVertexBuffer(renderBundleEncoder: WGPURenderBundleEncoder, slot: u32, buffer: WGPUBuffer, offset: u64, size: u64) void;
pub extern fn wgpuRenderPassEncoderBeginOcclusionQuery(renderPassEncoder: WGPURenderPassEncoder, queryIndex: u32) void;
pub extern fn wgpuRenderPassEncoderBeginPipelineStatisticsQuery(renderPassEncoder: WGPURenderPassEncoder, querySet: WGPUQuerySet, queryIndex: u32) void;
pub extern fn wgpuRenderPassEncoderDraw(renderPassEncoder: WGPURenderPassEncoder, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32) void;
pub extern fn wgpuRenderPassEncoderDrawIndexed(renderPassEncoder: WGPURenderPassEncoder, indexCount: u32, instanceCount: u32, firstIndex: u32, baseVertex: i32, firstInstance: u32) void;
pub extern fn wgpuRenderPassEncoderDrawIndexedIndirect(renderPassEncoder: WGPURenderPassEncoder, indirectBuffer: WGPUBuffer, indirectOffset: u64) void;
pub extern fn wgpuRenderPassEncoderDrawIndirect(renderPassEncoder: WGPURenderPassEncoder, indirectBuffer: WGPUBuffer, indirectOffset: u64) void;
pub extern fn wgpuRenderPassEncoderEndOcclusionQuery(renderPassEncoder: WGPURenderPassEncoder) void;
pub extern fn wgpuRenderPassEncoderEndPass(renderPassEncoder: WGPURenderPassEncoder) void;
pub extern fn wgpuRenderPassEncoderEndPipelineStatisticsQuery(renderPassEncoder: WGPURenderPassEncoder) void;
pub extern fn wgpuRenderPassEncoderExecuteBundles(renderPassEncoder: WGPURenderPassEncoder, bundlesCount: u32, bundles: [*c]const WGPURenderBundle) void;
pub extern fn wgpuRenderPassEncoderInsertDebugMarker(renderPassEncoder: WGPURenderPassEncoder, markerLabel: [*c]const u8) void;
pub extern fn wgpuRenderPassEncoderPopDebugGroup(renderPassEncoder: WGPURenderPassEncoder) void;
pub extern fn wgpuRenderPassEncoderPushDebugGroup(renderPassEncoder: WGPURenderPassEncoder, groupLabel: [*c]const u8) void;
pub extern fn wgpuRenderPassEncoderSetBindGroup(renderPassEncoder: WGPURenderPassEncoder, groupIndex: u32, group: WGPUBindGroup, dynamicOffsetCount: u32, dynamicOffsets: [*c]const u32) void;
pub extern fn wgpuRenderPassEncoderSetBlendConstant(renderPassEncoder: WGPURenderPassEncoder, color: [*c]const WGPUColor) void;
pub extern fn wgpuRenderPassEncoderSetIndexBuffer(renderPassEncoder: WGPURenderPassEncoder, buffer: WGPUBuffer, format: WGPUIndexFormat, offset: u64, size: u64) void;
pub extern fn wgpuRenderPassEncoderSetPipeline(renderPassEncoder: WGPURenderPassEncoder, pipeline: WGPURenderPipeline) void;
pub extern fn wgpuRenderPassEncoderSetScissorRect(renderPassEncoder: WGPURenderPassEncoder, x: u32, y: u32, width: u32, height: u32) void;
pub extern fn wgpuRenderPassEncoderSetStencilReference(renderPassEncoder: WGPURenderPassEncoder, reference: u32) void;
pub extern fn wgpuRenderPassEncoderSetVertexBuffer(renderPassEncoder: WGPURenderPassEncoder, slot: u32, buffer: WGPUBuffer, offset: u64, size: u64) void;
pub extern fn wgpuRenderPassEncoderSetViewport(renderPassEncoder: WGPURenderPassEncoder, x: f32, y: f32, width: f32, height: f32, minDepth: f32, maxDepth: f32) void;
pub extern fn wgpuRenderPassEncoderWriteTimestamp(renderPassEncoder: WGPURenderPassEncoder, querySet: WGPUQuerySet, queryIndex: u32) void;
pub extern fn wgpuRenderPipelineGetBindGroupLayout(renderPipeline: WGPURenderPipeline, groupIndex: u32) WGPUBindGroupLayout;
pub extern fn wgpuRenderPipelineSetLabel(renderPipeline: WGPURenderPipeline, label: [*c]const u8) void;
pub extern fn wgpuShaderModuleSetLabel(shaderModule: WGPUShaderModule, label: [*c]const u8) void;
pub extern fn wgpuSurfaceGetPreferredFormat(surface: WGPUSurface, adapter: WGPUAdapter) WGPUTextureFormat;
pub extern fn wgpuSwapChainGetCurrentTextureView(swapChain: WGPUSwapChain) WGPUTextureView;
pub extern fn wgpuSwapChainPresent(swapChain: WGPUSwapChain) void;
pub extern fn wgpuTextureCreateView(texture: WGPUTexture, descriptor: [*c]const WGPUTextureViewDescriptor) WGPUTextureView;
pub extern fn wgpuTextureDestroy(texture: WGPUTexture) void;
pub const WGPUSType_DeviceExtras: c_int = 1610612737;
pub const WGPUSType_AdapterExtras: c_int = 1610612738;
pub const WGPUNativeSType_Force32: c_int = 2147483647;
pub const enum_WGPUNativeSType = c_uint;
pub const WGPUNativeSType = enum_WGPUNativeSType;
pub const WGPUNativeFeature_TEXTURE_ADAPTER_SPECIFIC_FORMAT_FEATURES: c_int = 268435456;
pub const enum_WGPUNativeFeature = c_uint;
pub const WGPUNativeFeature = enum_WGPUNativeFeature;
pub const WGPULogLevel_Off: c_int = 0;
pub const WGPULogLevel_Error: c_int = 1;
pub const WGPULogLevel_Warn: c_int = 2;
pub const WGPULogLevel_Info: c_int = 3;
pub const WGPULogLevel_Debug: c_int = 4;
pub const WGPULogLevel_Trace: c_int = 5;
pub const WGPULogLevel_Force32: c_int = 2147483647;
pub const enum_WGPULogLevel = c_uint;
pub const WGPULogLevel = enum_WGPULogLevel;
pub const WGPUAdapterExtras = extern struct {
    chain: WGPUChainedStruct,
    backend: WGPUBackendType,
};
pub const WGPUDeviceExtras = extern struct {
    chain: WGPUChainedStruct,
    nativeFeatures: WGPUNativeFeature,
    label: [*:0]const u8,
    tracePath: ?[*:0]const u8,
};
pub const WGPULogCallback = ?fn (WGPULogLevel, [*c]const u8) callconv(.C) void;
pub extern fn wgpuDevicePoll(device: WGPUDevice, force_wait: bool) void;
pub extern fn wgpuSetLogCallback(callback: WGPULogCallback) void;
pub extern fn wgpuSetLogLevel(level: WGPULogLevel) void;
pub extern fn wgpuGetVersion() u32;
pub extern fn wgpuRenderPassEncoderSetPushConstants(encoder: WGPURenderPassEncoder, stages: WGPUShaderStage, offset: u32, sizeBytes: u32, data: ?*c_void) void;
pub extern fn wgpuBufferDrop(buffer: WGPUBuffer) void;
pub extern fn wgpuCommandEncoderDrop(commandEncoder: WGPUCommandEncoder) void;
pub extern fn wgpuDeviceDrop(device: WGPUDevice) void;
pub extern fn wgpuQuerySetDrop(querySet: WGPUQuerySet) void;
pub extern fn wgpuRenderPipelineDrop(renderPipeline: WGPURenderPipeline) void;
pub extern fn wgpuTextureDrop(texture: WGPUTexture) void;
pub extern fn wgpuTextureViewDrop(textureView: WGPUTextureView) void;
pub extern fn wgpuSamplerDrop(sampler: WGPUSampler) void;
pub extern fn wgpuBindGroupLayoutDrop(bindGroupLayout: WGPUBindGroupLayout) void;
pub extern fn wgpuPipelineLayoutDrop(pipelineLayout: WGPUPipelineLayout) void;
pub extern fn wgpuBindGroupDrop(bindGroup: WGPUBindGroup) void;
pub extern fn wgpuShaderModuleDrop(shaderModule: WGPUShaderModule) void;
pub extern fn wgpuCommandBufferDrop(commandBuffer: WGPUCommandBuffer) void;
pub extern fn wgpuRenderBundleDrop(renderBundle: WGPURenderBundle) void;
pub extern fn wgpuComputePipelineDrop(computePipeline: WGPUComputePipeline) void;
pub const WGPU_WHOLE_SIZE = @as(c_ulonglong, 0xffffffffffffffff);
pub const WGPU_COPY_STRIDE_UNDEFINED = @as(c_ulong, 0xffffffff);
pub const WGPU_LIMIT_U32_UNDEFINED = @as(c_ulong, 0xffffffff);
pub const WGPU_LIMIT_U64_UNDEFINED = @as(c_ulonglong, 0xffffffffffffffff);
pub const WGPU_ARRAY_LAYER_COUNT_UNDEFINED = @as(c_ulong, 0xffffffff);
pub const WGPU_MIP_LEVEL_COUNT_UNDEFINED = @as(c_ulong, 0xffffffff);
// pub const WGPUAdapterImpl = struct_WGPUAdapterImpl;
// pub const WGPUBindGroupImpl = struct_WGPUBindGroupImpl;
// pub const WGPUBindGroupLayoutImpl = struct_WGPUBindGroupLayoutImpl;
// pub const WGPUBufferImpl = struct_WGPUBufferImpl;
// pub const WGPUCommandBufferImpl = struct_WGPUCommandBufferImpl;
// pub const WGPUCommandEncoderImpl = struct_WGPUCommandEncoderImpl;
// pub const WGPUComputePassEncoderImpl = struct_WGPUComputePassEncoderImpl;
// pub const WGPUComputePipelineImpl = struct_WGPUComputePipelineImpl;
// pub const WGPUDeviceImpl = struct_WGPUDeviceImpl;
// pub const WGPUInstanceImpl = struct_WGPUInstanceImpl;
// pub const WGPUPipelineLayoutImpl = struct_WGPUPipelineLayoutImpl;
// pub const WGPUQuerySetImpl = struct_WGPUQuerySetImpl;
// pub const WGPUQueueImpl = struct_WGPUQueueImpl;
// pub const WGPURenderBundleImpl = struct_WGPURenderBundleImpl;
// pub const WGPURenderBundleEncoderImpl = struct_WGPURenderBundleEncoderImpl;
// pub const WGPURenderPassEncoderImpl = struct_WGPURenderPassEncoderImpl;
// pub const WGPURenderPipelineImpl = struct_WGPURenderPipelineImpl;
// pub const WGPUSamplerImpl = struct_WGPUSamplerImpl;
// pub const WGPUShaderModuleImpl = struct_WGPUShaderModuleImpl;
// pub const WGPUSurfaceImpl = struct_WGPUSurfaceImpl;
// pub const WGPUSwapChainImpl = struct_WGPUSwapChainImpl;
// pub const WGPUTextureImpl = struct_WGPUTextureImpl;
// pub const WGPUTextureViewImpl = struct_WGPUTextureViewImpl;
