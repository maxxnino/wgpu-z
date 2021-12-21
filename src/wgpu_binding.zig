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

pub const Flags = u32;
pub const Adapter = enum(usize) { null_handle = 0, _ };
pub const BindGroup = enum(usize) { null_handle = 0, _ };
pub const BindGroupLayout = enum(usize) { null_handle = 0, _ };
pub const Buffer = enum(usize) { null_handle = 0, _ };
pub const CommandBuffer = enum(usize) { null_handle = 0, _ };
pub const CommandEncoder = enum(usize) { null_handle = 0, _ };
pub const ComputePassEncoder = enum(usize) { null_handle = 0, _ };
pub const ComputePipeline = enum(usize) { null_handle = 0, _ };
pub const Device = enum(usize) { null_handle = 0, _ };
pub const Instance = enum(usize) { null_handle = 0, _ };
pub const PipelineLayout = enum(usize) { null_handle = 0, _ };
pub const QuerySet = enum(usize) { null_handle = 0, _ };
pub const Queue = enum(usize) { null_handle = 0, _ };
pub const RenderBundle = enum(usize) { null_handle = 0, _ };
pub const RenderBundleEncoder = enum(usize) { null_handle = 0, _ };
pub const RenderPassEncoder = enum(usize) { null_handle = 0, _ };
pub const RenderPipeline = enum(usize) { null_handle = 0, _ };
pub const Sampler = enum(usize) { null_handle = 0, _ };
pub const ShaderModule = enum(usize) { null_handle = 0, _ };
pub const Surface = enum(usize) { null_handle = 0, _ };
pub const SwapChain = enum(usize) { null_handle = 0, _ };
pub const Texture = enum(usize) { null_handle = 0, _ };
pub const TextureView = enum(usize) { null_handle = 0, _ };

pub const AdapterType = enum(i32) {
    DiscreteGpu = 0,
    IntegratedGpu = 1,
    Cpu = 2,
    Unknown = 3,
    _,
};
pub const AddressMode = enum(i32) {
    Repeat = 0,
    MirrorRepeat = 1,
    ClampToEdge = 2,
    _,
};
pub const BackendType = enum(i32) {
    Null = 0,
    WebGPU = 1,
    D3D11 = 2,
    D3D12 = 3,
    Metal = 4,
    Vulkan = 5,
    OpenGL = 6,
    OpenGLES = 7,
    _,
};
pub const BlendFactor = enum(i32) {
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
    _,
};

pub const BlendOperation = enum(i32) {
    Add = 0,
    Subtract = 1,
    ReverseSubtract = 2,
    Min = 3,
    Max = 4,
    _,
};
pub const BufferBindingType = enum(i32) {
    Undefined = 0,
    Uniform = 1,
    Storage = 2,
    ReadOnlyStorage = 3,
    _,
};
pub const BufferMapAsyncStatus = enum(i32) {
    Success = 0,
    Error = 1,
    Unknown = 2,
    DeviceLost = 3,
    DestroyedBeforeCallback = 4,
    UnmappedBeforeCallback = 5,
    _,
};
pub const CompilationInfoRequestStatus = enum(i32) {
    Success = 0,
    Error = 1,
    DeviceLost = 2,
    Unknown = 3,
    _,
};
pub const CompareFunction = enum(i32) {
    Undefined = 0,
    Never = 1,
    Less = 2,
    LessEqual = 3,
    Greater = 4,
    GreaterEqual = 5,
    Equal = 6,
    NotEqual = 7,
    Always = 8,
    _,
};

pub const ComputePassTimestampLocation = enum(i32) {
    Beginning = 0,
    End = 1,
    _,
};

pub const CompilationMessageType = enum(i32) {
    Error = 0,
    Warning = 1,
    Info = 2,
    _,
};
pub const CreatePipelineAsyncStatus = enum(i32) {
    Success = 0,
    Error = 1,
    DeviceLost = 2,
    DeviceDestroyed = 3,
    Unknown = 4,
    _,
};
pub const CullMode = enum(i32) {
    None = 0,
    Front = 1,
    Back = 2,
    _,
};
pub const DeviceLostReason = enum(i32) {
    Undefined = 0,
    Destroyed = 1,
    _,
};
pub const ErrorFilter = enum(i32) {
    None = 0,
    Validation = 1,
    OutOfMemory = 2,
    _,
};
pub const ErrorType = enum(i32) {
    NoError = 0,
    Validation = 1,
    OutOfMemory = 2,
    Unknown = 3,
    DeviceLost = 4,
    _,
};
pub const FeatureName = enum(i32) {
    Undefined = 0,
    DepthClipControl = 1,
    Depth24UnormStencil8 = 2,
    Depth32FloatStencil8 = 3,
    TimestampQuery = 4,
    PipelineStatisticsQuery = 5,
    TextureCompressionBC = 6,
    TextureCompressionETC2 = 7,
    TextureCompressionASTC = 8,
    IndirectFirstInstance = 9,
    _,
};
pub const FilterMode = enum(i32) {
    Nearest = 0,
    Linear = 1,
    _,
};
pub const FrontFace = enum(i32) {
    CCW = 0,
    CW = 1,
    _,
};
pub const IndexFormat = enum(i32) {
    Undefined = 0,
    Uint16 = 1,
    Uint32 = 2,
    _,
};
pub const LoadOp = enum(i32) {
    Clear = 0,
    Load = 1,
    _,
};
pub const PipelineStatisticName = enum(i32) {
    VertexShaderInvocations = 0,
    ClipperInvocations = 1,
    ClipperPrimitivesOut = 2,
    FragmentShaderInvocations = 3,
    ComputeShaderInvocations = 4,
    _,
};
pub const PowerPreference = enum(i32) {
    Undefined = 0,
    LowPower = 1,
    HighPerformance = 2,
    _,
};
pub const PresentMode = enum(i32) {
    Immediate = 0,
    Mailbox = 1,
    Fifo = 2,
    _,
};
pub const PrimitiveTopology = enum(i32) {
    PointList = 0,
    LineList = 1,
    LineStrip = 2,
    TriangleList = 3,
    TriangleStrip = 4,
    _,
};
pub const QueryType = enum(i32) {
    Occlusion = 0,
    PipelineStatistics = 1,
    Timestamp = 2,
    _,
};
pub const QueueWorkDoneStatus = enum(i32) {
    Success = 0,
    Error = 1,
    Unknown = 2,
    DeviceLost = 3,
    _,
};
pub const RenderPassTimestampLocation = enum(i32) {
    Beginning = 0,
    End = 1,
    _,
};

pub const RequestAdapterStatus = enum(i32) {
    Success = 0,
    Unavailable = 1,
    Error = 2,
    Unknown = 3,
    _,
};
pub const RequestDeviceStatus = enum(i32) {
    Success = 0,
    Error = 1,
    Unknown = 2,
    _,
};
pub const SType = enum(i32) {
    Invalid = 0,
    SurfaceDescriptorFromMetalLayer = 1,
    SurfaceDescriptorFromWindowsHWND = 2,
    SurfaceDescriptorFromXlib = 3,
    SurfaceDescriptorFromCanvasHTMLSelector = 4,
    ShaderModuleSPIRVDescriptor = 5,
    ShaderModuleWGSLDescriptor = 6,
    PrimitiveDepthClipControl = 7,

    //wgpu-native Start at 6 to prevent collisions with webgpu STypes
    DeviceExtras = 1610612737,
    AdapterExtras = 1610612738,
    _,
};
pub const SamplerBindingType = enum(i32) {
    Undefined = 0,
    Filtering = 1,
    NonFiltering = 2,
    Comparison = 3,
    _,
};
pub const StencilOperation = enum(i32) {
    Keep = 0,
    Zero = 1,
    Replace = 2,
    Invert = 3,
    IncrementClamp = 4,
    DecrementClamp = 5,
    IncrementWrap = 6,
    DecrementWrap = 7,
    _,
};
pub const StorageTextureAccess = enum(i32) {
    Undefined = 0,
    WriteOnly = 1,
    _,
};
pub const StoreOp = enum(i32) {
    Store = 0,
    Discard = 1,
    _,
};
pub const TextureAspect = enum(i32) {
    All = 0,
    StencilOnly = 1,
    DepthOnly = 2,
    _,
};
pub const TextureComponentType = enum(i32) {
    Float = 0,
    Sint = 1,
    Uint = 2,
    DepthComparison = 3,
    _,
};
pub const TextureDimension = enum(i32) {
    @"1D" = 0,
    @"2D" = 1,
    @"3D" = 2,
    _,
};
pub const TextureFormat = enum(i32) {
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
    Depth24UnormStencil8 = 41,
    Depth32Float = 42,
    Depth32FloatStencil8 = 43,
    BC1RGBAUnorm = 44,
    BC1RGBAUnormSrgb = 45,
    BC2RGBAUnorm = 46,
    BC2RGBAUnormSrgb = 47,
    BC3RGBAUnorm = 48,
    BC3RGBAUnormSrgb = 49,
    BC4RUnorm = 50,
    BC4RSnorm = 51,
    BC5RGUnorm = 52,
    BC5RGSnorm = 53,
    BC6HRGBUfloat = 54,
    BC6HRGBFloat = 55,
    BC7RGBAUnorm = 56,
    BC7RGBAUnormSrgb = 57,
    ETC2RGB8Unorm = 58,
    ETC2RGB8UnormSrgb = 59,
    ETC2RGB8A1Unorm = 60,
    ETC2RGB8A1UnormSrgb = 61,
    ETC2RGBA8Unorm = 62,
    ETC2RGBA8UnormSrgb = 63,
    EACR11Unorm = 64,
    EACR11Snorm = 65,
    EACRG11Unorm = 66,
    EACRG11Snorm = 67,
    ASTC4x4Unorm = 68,
    ASTC4x4UnormSrgb = 69,
    ASTC5x4Unorm = 70,
    ASTC5x4UnormSrgb = 71,
    ASTC5x5Unorm = 72,
    ASTC5x5UnormSrgb = 73,
    ASTC6x5Unorm = 74,
    ASTC6x5UnormSrgb = 75,
    ASTC6x6Unorm = 76,
    ASTC6x6UnormSrgb = 77,
    ASTC8x5Unorm = 78,
    ASTC8x5UnormSrgb = 79,
    ASTC8x6Unorm = 80,
    ASTC8x6UnormSrgb = 81,
    ASTC8x8Unorm = 82,
    ASTC8x8UnormSrgb = 83,
    ASTC10x5Unorm = 84,
    ASTC10x5UnormSrgb = 85,
    ASTC10x6Unorm = 86,
    ASTC10x6UnormSrgb = 87,
    ASTC10x8Unorm = 88,
    ASTC10x8UnormSrgb = 89,
    ASTC10x10Unorm = 90,
    ASTC10x10UnormSrgb = 91,
    ASTC12x10Unorm = 92,
    ASTC12x10UnormSrgb = 93,
    ASTC12x12Unorm = 94,
    ASTC12x12UnormSrgb = 95,
    _,
};
pub const TextureSampleType = enum(i32) {
    Undefined = 0,
    Float = 1,
    UnfilterableFloat = 2,
    Depth = 3,
    Sint = 4,
    Uint = 5,
    _,
};
pub const TextureViewDimension = enum(i32) {
    Undefined = 0,
    @"1D" = 1,
    @"2D" = 2,
    @"2DArray" = 3,
    Cube = 4,
    CubeArray = 5,
    @"3D" = 6,
    _,
};
pub const VertexFormat = enum(i32) {
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
    _,
};
pub const VertexStepMode = enum(i32) {
    Vertex = 0,
    Instance = 1,
    _,
};

pub const BufferUsage = packed struct {
    MapRead: bool align(@alignOf(Flags)) = false,
    MapWrite: bool = false,
    CopySrc: bool = false,
    CopyDst: bool = false,
    Index: bool = false,
    Vertex: bool = false,
    Uniform: bool = false,
    Storage: bool = false,
    Indirect: bool = false,
    QueryResolve: bool = false,
    _reserved_bit_10: bool = false,
    _reserved_bit_11: bool = false,
    _reserved_bit_12: bool = false,
    _reserved_bit_13: bool = false,
    _reserved_bit_14: bool = false,
    _reserved_bit_15: bool = false,
    _reserved_bit_16: bool = false,
    _reserved_bit_17: bool = false,
    _reserved_bit_18: bool = false,
    _reserved_bit_19: bool = false,
    _reserved_bit_20: bool = false,
    _reserved_bit_21: bool = false,
    _reserved_bit_22: bool = false,
    _reserved_bit_23: bool = false,
    _reserved_bit_24: bool = false,
    _reserved_bit_25: bool = false,
    _reserved_bit_26: bool = false,
    _reserved_bit_27: bool = false,
    _reserved_bit_28: bool = false,
    _reserved_bit_29: bool = false,
    _reserved_bit_30: bool = false,
    _reserved_bit_31: bool = false,

    const Self = @This();
    comptime {
        std.debug.assert(@sizeOf(Self) == @sizeOf(Flags));
    }
    pub usingnamespace FlagsMixin(Self, Flags);
};

pub const ColorWriteMask = packed struct {
    Red: bool = false,
    Green: bool = false,
    Blue: bool = false,
    Alpha: bool = false,
    _reserved_04_31: u28 = 0,
    pub const all = Self{ .Red = true, .Green = true, .Blue = true, .Alpha = true };

    const Self = @This();
    comptime {
        std.debug.assert(@sizeOf(Self) == @sizeOf(Flags));
    }
    pub usingnamespace FlagsMixin(Self, Flags);
};
pub const MapMode = enum(i32) {
    None = 0,
    Read = 1,
    Write = 2,
    _,
};
pub const ShaderStage = enum(i32) {
    None = 0,
    Vertex = 1,
    Fragment = 2,
    Compute = 4,
    _,
};
pub const TextureUsage = packed struct {
    CopySrc: bool = false,
    CopyDst: bool = false,
    TextureBinding: bool = false,
    StorageBinding: bool = false,
    RenderAttachment: bool = false,
    _reserved_05_31: u27 = 0,

    const Self = @This();
    comptime {
        std.debug.assert(@sizeOf(Self) == @sizeOf(Flags));
    }
    pub usingnamespace FlagsMixin(Self, Flags);
};

pub const MapModeFlags = Flags;
pub const ShaderStageFlags = Flags;
pub const TextureUsageFlags = Flags;

pub const ChainedStruct = extern struct {
    next: ?*const ChainedStruct,
    sType: SType,
};
pub const ChainedStructOut = extern struct {
    next: ?*ChainedStructOut,
    sType: SType,
};
pub const AdapterProperties = extern struct {
    nextInChain: ?*ChainedStructOut = null,
    vendorID: u32,
    deviceID: u32,
    name: ?[*:0]const u8,
    driverDescription: [*:0]const u8,
    adapterType: AdapterType,
    backendType: BackendType,
};
pub const BindGroupEntry = extern struct {
    nextInChain: ?*const ChainedStruct,
    binding: u32,
    buffer: Buffer,
    offset: u64,
    size: u64,
    sampler: Sampler,
    textureView: TextureView,
};
pub const BlendComponent = extern struct {
    operation: BlendOperation,
    srcFactor: BlendFactor,
    dstFactor: BlendFactor,
};
pub const BufferBindingLayout = extern struct {
    nextInChain: ?*const ChainedStruct,
    type: BufferBindingType,
    hasDynamicOffset: bool,
    minBindingSize: u64,
};
pub const BufferDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    usage: BufferUsage,
    size: u64,
    mappedAtCreation: bool,
};
pub const Color = extern struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64,
};
pub const CommandBufferDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8,
};
pub const CommandEncoderDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    label: [*:0]const u8,
};
pub const CompilationMessage = extern struct {
    nextInChain: ?*const ChainedStruct,
    message: ?[*:0]const u8,
    type: CompilationMessageType,
    lineNum: u64,
    linePos: u64,
    offset: u64,
    length: u64,
};
pub const ComputePassTimestampWrite = extern struct {
    querySet: QuerySet,
    queryIndex: u32,
    location: ComputePassTimestampLocation,
};
pub const ConstantEntry = extern struct {
    nextInChain: ?*const ChainedStruct,
    key: ?[*:0]const u8,
    value: f64,
};
pub const Extent3D = extern struct {
    width: u32,
    height: u32,
    depthOrArrayLayers: u32,
};
pub const InstanceDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
};
pub const Limits = extern struct {
    maxTextureDimension1D: u32 = 8192,
    maxTextureDimension2D: u32 = 8192,
    maxTextureDimension3D: u32 = 2048,
    maxTextureArrayLayers: u32 = 256,
    maxBindGroups: u32 = 4,
    maxDynamicUniformBuffersPerPipelineLayout: u32 = 8,
    maxDynamicStorageBuffersPerPipelineLayout: u32 = 4,
    maxSampledTexturesPerShaderStage: u32 = 16,
    maxSamplersPerShaderStage: u32 = 16,
    maxStorageBuffersPerShaderStage: u32 = 4,
    maxStorageTexturesPerShaderStage: u32 = 4,
    maxUniformBuffersPerShaderStage: u32 = 12,
    maxUniformBufferBindingSize: usize = 16384,
    maxStorageBufferBindingSize: usize = 134217728, //128mb
    minUniformBufferOffsetAlignment: u32 = 256,
    minStorageBufferOffsetAlignment: u32 = 256,
    maxVertexBuffers: u32 = 8,
    maxVertexAttributes: u32 = 16,
    maxVertexBufferArrayStride: u32 = 2048,
    maxInterStageShaderComponents: u32 = 60,
    maxComputeWorkgroupStorageSize: u32 = 16352,
    maxComputeInvocationsPerWorkgroup: u32 = 256,
    maxComputeWorkgroupSizeX: u32 = 256,
    maxComputeWorkgroupSizeY: u32 = 256,
    maxComputeWorkgroupSizeZ: u32 = 64,
    maxComputeWorkgroupsPerDimension: u32 = 65535,
};
pub const MultisampleState = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    count: u32,
    mask: u32,
    alphaToCoverageEnabled: bool,
};
pub const Origin3D = extern struct {
    x: u32,
    y: u32,
    z: u32,
};
pub const PipelineLayoutDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    bindGroupLayoutCount: u32,
    bindGroupLayouts: ?[*]const BindGroupLayout,
};
pub const PrimitiveDepthClipControl = extern struct {
    chain: ChainedStruct,
    unclippedDepth: bool,
};
pub const PrimitiveState = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    topology: PrimitiveTopology,
    stripIndexFormat: IndexFormat,
    frontFace: FrontFace,
    cullMode: CullMode,
};
pub const QuerySetDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: ?[*:0]const u8,
    type: QueryType,
    count: u32,
    pipelineStatistics: [*c]const PipelineStatisticName,
    pipelineStatisticsCount: u32,
};
pub const RenderBundleDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: ?[*:0]const u8,
};
pub const RenderBundleEncoderDescriptor = extern struct {
    nextInChain: *const ChainedStruct,
    label: [*:0]const u8,
    colorFormatsCount: u32,
    colorFormats: [*]const TextureFormat,
    depthStencilFormat: TextureFormat,
    sampleCount: u32,
    depthReadOnly: bool,
    stencilReadOnly: bool,
};
pub const RenderPassDepthStencilAttachment = extern struct {
    view: TextureView,
    depthLoadOp: LoadOp,
    depthStoreOp: StoreOp,
    clearDepth: f32,
    depthReadOnly: bool,
    stencilLoadOp: LoadOp,
    stencilStoreOp: StoreOp,
    clearStencil: u32,
    stencilReadOnly: bool,
};
pub const RenderPassTimestampWrite = extern struct {
    querySet: QuerySet,
    queryIndex: u32,
    location: RenderPassTimestampLocation,
};
pub const RequestAdapterOptions = extern struct {
    nextInChain: ?*const ChainedStruct,
    compatibleSurface: Surface,
    powerPreference: PowerPreference,
    forceFallbackAdapter: bool,
};
pub const SamplerBindingLayout = extern struct {
    nextInChain: ?*const ChainedStruct,
    type: SamplerBindingType,
};
pub const SamplerDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: ?[*:0]const u8,
    addressModeU: AddressMode,
    addressModeV: AddressMode,
    addressModeW: AddressMode,
    magFilter: FilterMode,
    minFilter: FilterMode,
    mipmapFilter: FilterMode,
    lodMinClamp: f32,
    lodMaxClamp: f32,
    compare: CompareFunction,
    maxAnisotropy: u16,
};
pub const ShaderModuleDescriptor = extern struct {
    nextInChain: *const ChainedStruct,
    label: ?[*:0]const u8,
};
pub const ShaderModuleSPIRVDescriptor = extern struct {
    chain: ChainedStruct,
    codeSize: u32,
    code: [*]const u32,
};
pub const ShaderModuleWGSLDescriptor = extern struct {
    chain: ChainedStruct,
    code: [*]const u8,
};
pub const StencilFaceState = extern struct {
    compare: CompareFunction,
    failOp: StencilOperation,
    depthFailOp: StencilOperation,
    passOp: StencilOperation,
};
pub const StorageTextureBindingLayout = extern struct {
    nextInChain: ?*const ChainedStruct,
    access: StorageTextureAccess,
    format: TextureFormat,
    viewDimension: TextureViewDimension,
};
pub const SurfaceDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: ?[*:0]const u8,
};
pub const SurfaceDescriptorFromCanvasHTMLSelector = extern struct {
    chain: ChainedStruct,
    selector: ?[*:0]const u8,
};
pub const SurfaceDescriptorFromMetalLayer = extern struct {
    chain: ChainedStruct,
    layer: ?*anyopaque,
};
pub const SurfaceDescriptorFromWindowsHWND = extern struct {
    chain: ChainedStruct,
    hinstance: ?*anyopaque,
    hwnd: ?*anyopaque,
};
pub const SurfaceDescriptorFromXlib = extern struct {
    chain: ChainedStruct,
    display: ?*anyopaque,
    window: u32,
};
pub const SwapChainDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    usage: TextureUsage,
    format: TextureFormat,
    width: u32,
    height: u32,
    presentMode: PresentMode,
};
pub const TextureBindingLayout = extern struct {
    nextInChain: ?*const ChainedStruct,
    sampleType: TextureSampleType,
    viewDimension: TextureViewDimension,
    multisampled: bool,
};
pub const TextureDataLayout = extern struct {
    nextInChain: ?*const ChainedStruct,
    offset: u64,
    bytesPerRow: u32,
    rowsPerImage: u32,
};
pub const TextureViewDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: ?[*:0]const u8,
    format: TextureFormat,
    dimension: TextureViewDimension,
    baseMipLevel: u32,
    mipLevelCount: u32,
    baseArrayLayer: u32,
    arrayLayerCount: u32,
    aspect: TextureAspect,
};
pub const VertexAttribute = extern struct {
    format: VertexFormat,
    offset: u64,
    shaderLocation: u32,
};
pub const BindGroupDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: ?[*:0]const u8,
    layout: BindGroupLayout,
    entryCount: u32,
    entries: [*c]const BindGroupEntry,
};
pub const BindGroupLayoutEntry = extern struct {
    nextInChain: ?*const ChainedStruct,
    binding: u32,
    visibility: ShaderStageFlags,
    buffer: BufferBindingLayout,
    sampler: SamplerBindingLayout,
    texture: TextureBindingLayout,
    storageTexture: StorageTextureBindingLayout,
};
pub const BlendState = extern struct {
    color: BlendComponent,
    alpha: BlendComponent,
};
pub const CompilationInfo = extern struct {
    nextInChain: ?*const ChainedStruct,
    messageCount: u32,
    messages: [*c]const CompilationMessage,
};
pub const ComputePassDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: [*:0]const u8,
    timestampWriteCount: u32,
    timestampWrites: [*]const ComputePassTimestampWrite,
};
pub const DepthStencilState = extern struct {
    nextInChain: ?*const ChainedStruct,
    format: TextureFormat,
    depthWriteEnabled: bool,
    depthCompare: CompareFunction,
    stencilFront: StencilFaceState,
    stencilBack: StencilFaceState,
    stencilReadMask: u32,
    stencilWriteMask: u32,
    depthBias: i32,
    depthBiasSlopeScale: f32,
    depthBiasClamp: f32,
};
pub const ImageCopyBuffer = extern struct {
    nextInChain: ?*const ChainedStruct,
    layout: TextureDataLayout,
    buffer: Buffer,
};
pub const ImageCopyTexture = extern struct {
    nextInChain: ?*const ChainedStruct,
    texture: Texture,
    mipLevel: u32,
    origin: Origin3D,
    aspect: TextureAspect,
};
pub const ProgrammableStageDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    module: ShaderModule,
    entryPoint: ?[*:0]const u8,
    constantCount: u32,
    constants: [*c]const ConstantEntry,
};
pub const RenderPassColorAttachment = extern struct {
    view: TextureView,
    resolveTarget: TextureView,
    loadOp: LoadOp,
    storeOp: StoreOp,
    clearColor: Color,
};
pub const RequiredLimits = extern struct {
    nextInChain: ?*const ChainedStruct,
    limits: Limits,
};
pub const SupportedLimits = extern struct {
    nextInChain: [*c]ChainedStructOut,
    limits: Limits,
};
pub const TextureDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: ?[*:0]const u8,
    usage: TextureUsageFlags,
    dimension: TextureDimension,
    size: Extent3D,
    format: TextureFormat,
    mipLevelCount: u32,
    sampleCount: u32,
};
pub const VertexBufferLayout = extern struct {
    arrayStride: u64,
    stepMode: VertexStepMode,
    attributeCount: u32,
    attributes: [*]const VertexAttribute,
};
pub const BindGroupLayoutDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: ?[*:0]const u8,
    entryCount: u32,
    entries: [*c]const BindGroupLayoutEntry,
};
pub const ColorTargetState = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    format: TextureFormat,
    blend: ?*const BlendState,
    writeMask: ColorWriteMask,
};
pub const ColorWriteMaskFlags = Flags;
pub const ComputePipelineDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: ?[*:0]const u8,
    layout: PipelineLayout,
    compute: ProgrammableStageDescriptor,
};
pub const DeviceDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct,
    label: ?[*:0]const u8,
    requiredFeaturesCount: u32,
    requiredFeatures: [*]const FeatureName,
    requiredLimits: *const RequiredLimits,
};
pub const RenderPassDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    colorAttachmentCount: u32,
    colorAttachments: [*]const RenderPassColorAttachment,
    depthStencilAttachment: ?*const RenderPassDepthStencilAttachment,
    occlusionQuerySet: QuerySet,
};
pub const VertexState = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    module: ShaderModule,
    entryPoint: [*:0]const u8,
    constantCount: u32,
    constants: [*]const ConstantEntry,
    bufferCount: u32,
    buffers: [*]const VertexBufferLayout,
};
pub const FragmentState = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    module: ShaderModule,
    entryPoint: [*:0]const u8,
    constantCount: u32,
    constants: [*]const ConstantEntry,
    targetCount: u32,
    targets: [*]const ColorTargetState,
};
pub const RenderPipelineDescriptor = extern struct {
    nextInChain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8,
    layout: PipelineLayout,
    vertex: VertexState,
    primitive: PrimitiveState,
    depthStencil: ?*const DepthStencilState,
    multisample: MultisampleState,
    fragment: ?*const FragmentState,
};

pub const BufferMapCallback = ?fn (BufferMapAsyncStatus, ?*anyopaque) callconv(.C) void;
pub const CreateComputePipelineAsyncCallback = ?fn (CreatePipelineAsyncStatus, ComputePipeline, [*c]const u8, ?*anyopaque) callconv(.C) void;
pub const CreateRenderPipelineAsyncCallback = ?fn (CreatePipelineAsyncStatus, RenderPipeline, [*c]const u8, ?*anyopaque) callconv(.C) void;
pub const DeviceLostCallback = ?fn (DeviceLostReason, [*c]const u8, ?*anyopaque) callconv(.C) void;
pub const ErrorCallback = ?fn (ErrorType, [*c]const u8, ?*anyopaque) callconv(.C) void;
pub const CompilationInfoCallback = ?fn (CompilationInfoRequestStatus, [*c]const CompilationInfo, ?*anyopaque) callconv(.C) void;
pub const QueueWorkDoneCallback = ?fn (QueueWorkDoneStatus, ?*anyopaque) callconv(.C) void;
pub const RequestAdapterCallback = fn (RequestAdapterStatus, Adapter, [*:0]const u8, *anyopaque) callconv(.C) void;
pub const RequestDeviceCallback = fn (RequestDeviceStatus, Device, [*:0]const u8, *anyopaque) callconv(.C) void;
pub const Proc = ?fn () callconv(.C) void;
pub const ProcCreateInstance = ?fn ([*c]const InstanceDescriptor) callconv(.C) Instance;
pub const ProcGetProcAddress = ?fn (Device, [*c]const u8) callconv(.C) Proc;
pub const ProcAdapterEnumerateFeatures = ?fn (Adapter, [*c]FeatureName) callconv(.C) u32;
pub const ProcAdapterGetLimits = ?fn (Adapter, [*c]SupportedLimits) callconv(.C) bool;
pub const ProcAdapterGetProperties = ?fn (Adapter, [*c]AdapterProperties) callconv(.C) void;
pub const ProcAdapterHasFeature = ?fn (Adapter, FeatureName) callconv(.C) bool;
pub const ProcAdapterRequestDevice = ?fn (Adapter, [*c]const DeviceDescriptor, RequestDeviceCallback, ?*anyopaque) callconv(.C) void;
pub const ProcBufferDestroy = ?fn (Buffer) callconv(.C) void;
pub const ProcBufferGetConstMappedRange = ?fn (Buffer, usize, usize) callconv(.C) ?*const anyopaque;
pub const ProcBufferGetMappedRange = ?fn (Buffer, usize, usize) callconv(.C) ?*anyopaque;
pub const ProcBufferMapAsync = ?fn (Buffer, MapModeFlags, usize, usize, BufferMapCallback, ?*anyopaque) callconv(.C) void;
pub const ProcBufferUnmap = ?fn (Buffer) callconv(.C) void;
pub const ProcCommandEncoderBeginComputePass = ?fn (CommandEncoder, [*c]const ComputePassDescriptor) callconv(.C) ComputePassEncoder;
pub const ProcCommandEncoderBeginRenderPass = ?fn (CommandEncoder, [*c]const RenderPassDescriptor) callconv(.C) RenderPassEncoder;
pub const ProcCommandEncoderCopyBufferToBuffer = ?fn (CommandEncoder, Buffer, u64, Buffer, u64, u64) callconv(.C) void;
pub const ProcCommandEncoderCopyBufferToTexture = ?fn (CommandEncoder, [*c]const ImageCopyBuffer, [*c]const ImageCopyTexture, [*c]const Extent3D) callconv(.C) void;
pub const ProcCommandEncoderCopyTextureToBuffer = ?fn (CommandEncoder, [*c]const ImageCopyTexture, [*c]const ImageCopyBuffer, [*c]const Extent3D) callconv(.C) void;
pub const ProcCommandEncoderCopyTextureToTexture = ?fn (CommandEncoder, [*c]const ImageCopyTexture, [*c]const ImageCopyTexture, [*c]const Extent3D) callconv(.C) void;
pub const ProcCommandEncoderFillBuffer = ?fn (CommandEncoder, Buffer, u64, u64, u8) callconv(.C) void;
pub const ProcCommandEncoderFinish = ?fn (CommandEncoder, [*c]const CommandBufferDescriptor) callconv(.C) CommandBuffer;
pub const ProcCommandEncoderInsertDebugMarker = ?fn (CommandEncoder, [*c]const u8) callconv(.C) void;
pub const ProcCommandEncoderPopDebugGroup = ?fn (CommandEncoder) callconv(.C) void;
pub const ProcCommandEncoderPushDebugGroup = ?fn (CommandEncoder, [*c]const u8) callconv(.C) void;
pub const ProcCommandEncoderResolveQuerySet = ?fn (CommandEncoder, QuerySet, u32, u32, Buffer, u64) callconv(.C) void;
pub const ProcComputePassEncoderBeginPipelineStatisticsQuery = ?fn (ComputePassEncoder, QuerySet, u32) callconv(.C) void;
pub const ProcComputePassEncoderDispatch = ?fn (ComputePassEncoder, u32, u32, u32) callconv(.C) void;
pub const ProcComputePassEncoderDispatchIndirect = ?fn (ComputePassEncoder, Buffer, u64) callconv(.C) void;
pub const ProcComputePassEncoderEndPass = ?fn (ComputePassEncoder) callconv(.C) void;
pub const ProcComputePassEncoderEndPipelineStatisticsQuery = ?fn (ComputePassEncoder) callconv(.C) void;
pub const ProcComputePassEncoderInsertDebugMarker = ?fn (ComputePassEncoder, [*c]const u8) callconv(.C) void;
pub const ProcComputePassEncoderPopDebugGroup = ?fn (ComputePassEncoder) callconv(.C) void;
pub const ProcComputePassEncoderPushDebugGroup = ?fn (ComputePassEncoder, [*c]const u8) callconv(.C) void;
pub const ProcComputePassEncoderSetBindGroup = ?fn (ComputePassEncoder, u32, BindGroup, u32, [*c]const u32) callconv(.C) void;
pub const ProcComputePassEncoderSetPipeline = ?fn (ComputePassEncoder, ComputePipeline) callconv(.C) void;
pub const ProcComputePassEncoderWriteTimestamp = ?fn (ComputePassEncoder, QuerySet, u32) callconv(.C) void;
pub const ProcComputePipelineGetBindGroupLayout = ?fn (ComputePipeline, u32) callconv(.C) BindGroupLayout;
pub const ProcComputePipelineSetLabel = ?fn (ComputePipeline, [*c]const u8) callconv(.C) void;
pub const ProcDeviceCreateBindGroup = ?fn (Device, [*c]const BindGroupDescriptor) callconv(.C) BindGroup;
pub const ProcDeviceCreateBindGroupLayout = ?fn (Device, [*c]const BindGroupLayoutDescriptor) callconv(.C) BindGroupLayout;
pub const ProcDeviceCreateBuffer = ?fn (Device, [*c]const BufferDescriptor) callconv(.C) Buffer;
pub const ProcDeviceCreateCommandEncoder = ?fn (Device, [*c]const CommandEncoderDescriptor) callconv(.C) CommandEncoder;
pub const ProcDeviceCreateComputePipeline = ?fn (Device, [*c]const ComputePipelineDescriptor) callconv(.C) ComputePipeline;
pub const ProcDeviceCreateComputePipelineAsync = ?fn (Device, [*c]const ComputePipelineDescriptor, CreateComputePipelineAsyncCallback, ?*anyopaque) callconv(.C) void;
pub const ProcDeviceCreatePipelineLayout = ?fn (Device, [*c]const PipelineLayoutDescriptor) callconv(.C) PipelineLayout;
pub const ProcDeviceCreateQuerySet = ?fn (Device, [*c]const QuerySetDescriptor) callconv(.C) QuerySet;
pub const ProcDeviceCreateRenderBundleEncoder = ?fn (Device, [*c]const RenderBundleEncoderDescriptor) callconv(.C) RenderBundleEncoder;
pub const ProcDeviceCreateRenderPipeline = ?fn (Device, [*c]const RenderPipelineDescriptor) callconv(.C) RenderPipeline;
pub const ProcDeviceCreateRenderPipelineAsync = ?fn (Device, [*c]const RenderPipelineDescriptor, CreateRenderPipelineAsyncCallback, ?*anyopaque) callconv(.C) void;
pub const ProcDeviceCreateSampler = ?fn (Device, [*c]const SamplerDescriptor) callconv(.C) Sampler;
pub const ProcDeviceCreateShaderModule = ?fn (Device, [*c]const ShaderModuleDescriptor) callconv(.C) ShaderModule;
pub const ProcDeviceCreateSwapChain = ?fn (Device, Surface, [*c]const SwapChainDescriptor) callconv(.C) SwapChain;
pub const ProcDeviceCreateTexture = ?fn (Device, [*c]const TextureDescriptor) callconv(.C) Texture;
pub const ProcDeviceDestroy = ?fn (Device) callconv(.C) void;
pub const ProcDeviceEnumerateFeatures = ?fn (Device, [*c]FeatureName) callconv(.C) u32;
pub const ProcDeviceGetLimits = ?fn (Device, [*c]SupportedLimits) callconv(.C) bool;
pub const ProcDeviceGetQueue = ?fn (Device) callconv(.C) Queue;
pub const ProcDeviceHasFeature = ?fn (Device, FeatureName) callconv(.C) bool;
pub const ProcDevicePopErrorScope = ?fn (Device, ErrorCallback, ?*anyopaque) callconv(.C) bool;
pub const ProcDevicePushErrorScope = ?fn (Device, ErrorFilter) callconv(.C) void;
pub const ProcDeviceSetDeviceLostCallback = ?fn (Device, DeviceLostCallback, ?*anyopaque) callconv(.C) void;
pub const ProcDeviceSetUncapturedErrorCallback = ?fn (Device, ErrorCallback, ?*anyopaque) callconv(.C) void;
pub const ProcInstanceCreateSurface = ?fn (Instance, [*c]const SurfaceDescriptor) callconv(.C) Surface;
pub const ProcInstanceProcessEvents = ?fn (Instance) callconv(.C) void;
pub const ProcInstanceRequestAdapter = ?fn (Instance, [*c]const RequestAdapterOptions, RequestAdapterCallback, ?*anyopaque) callconv(.C) void;
pub const ProcQuerySetDestroy = ?fn (QuerySet) callconv(.C) void;
pub const ProcQueueOnSubmittedWorkDone = ?fn (Queue, u64, QueueWorkDoneCallback, ?*anyopaque) callconv(.C) void;
pub const ProcQueueSubmit = ?fn (Queue, u32, [*c]const CommandBuffer) callconv(.C) void;
pub const ProcQueueWriteBuffer = ?fn (Queue, Buffer, u64, ?*const anyopaque, usize) callconv(.C) void;
pub const ProcQueueWriteTexture = ?fn (Queue, [*c]const ImageCopyTexture, ?*const anyopaque, usize, [*c]const TextureDataLayout, [*c]const Extent3D) callconv(.C) void;
pub const ProcRenderBundleEncoderDraw = ?fn (RenderBundleEncoder, u32, u32, u32, u32) callconv(.C) void;
pub const ProcRenderBundleEncoderDrawIndexed = ?fn (RenderBundleEncoder, u32, u32, u32, i32, u32) callconv(.C) void;
pub const ProcRenderBundleEncoderDrawIndexedIndirect = ?fn (RenderBundleEncoder, Buffer, u64) callconv(.C) void;
pub const ProcRenderBundleEncoderDrawIndirect = ?fn (RenderBundleEncoder, Buffer, u64) callconv(.C) void;
pub const ProcRenderBundleEncoderFinish = ?fn (RenderBundleEncoder, [*c]const RenderBundleDescriptor) callconv(.C) RenderBundle;
pub const ProcRenderBundleEncoderInsertDebugMarker = ?fn (RenderBundleEncoder, [*c]const u8) callconv(.C) void;
pub const ProcRenderBundleEncoderPopDebugGroup = ?fn (RenderBundleEncoder) callconv(.C) void;
pub const ProcRenderBundleEncoderPushDebugGroup = ?fn (RenderBundleEncoder, [*c]const u8) callconv(.C) void;
pub const ProcRenderBundleEncoderSetBindGroup = ?fn (RenderBundleEncoder, u32, BindGroup, u32, [*c]const u32) callconv(.C) void;
pub const ProcRenderBundleEncoderSetIndexBuffer = ?fn (RenderBundleEncoder, Buffer, IndexFormat, u64, u64) callconv(.C) void;
pub const ProcRenderBundleEncoderSetPipeline = ?fn (RenderBundleEncoder, RenderPipeline) callconv(.C) void;
pub const ProcRenderBundleEncoderSetVertexBuffer = ?fn (RenderBundleEncoder, u32, Buffer, u64, u64) callconv(.C) void;
pub const ProcRenderPassEncoderBeginOcclusionQuery = ?fn (RenderPassEncoder, u32) callconv(.C) void;
pub const ProcRenderPassEncoderBeginPipelineStatisticsQuery = ?fn (RenderPassEncoder, QuerySet, u32) callconv(.C) void;
pub const ProcRenderPassEncoderDraw = ?fn (RenderPassEncoder, u32, u32, u32, u32) callconv(.C) void;
pub const ProcRenderPassEncoderDrawIndexed = ?fn (RenderPassEncoder, u32, u32, u32, i32, u32) callconv(.C) void;
pub const ProcRenderPassEncoderDrawIndexedIndirect = ?fn (RenderPassEncoder, Buffer, u64) callconv(.C) void;
pub const ProcRenderPassEncoderDrawIndirect = ?fn (RenderPassEncoder, Buffer, u64) callconv(.C) void;
pub const ProcRenderPassEncoderEndOcclusionQuery = ?fn (RenderPassEncoder) callconv(.C) void;
pub const ProcRenderPassEncoderEndPass = ?fn (RenderPassEncoder) callconv(.C) void;
pub const ProcRenderPassEncoderEndPipelineStatisticsQuery = ?fn (RenderPassEncoder) callconv(.C) void;
pub const ProcRenderPassEncoderExecuteBundles = ?fn (RenderPassEncoder, u32, [*c]const RenderBundle) callconv(.C) void;
pub const ProcRenderPassEncoderInsertDebugMarker = ?fn (RenderPassEncoder, [*c]const u8) callconv(.C) void;
pub const ProcRenderPassEncoderPopDebugGroup = ?fn (RenderPassEncoder) callconv(.C) void;
pub const ProcRenderPassEncoderPushDebugGroup = ?fn (RenderPassEncoder, [*c]const u8) callconv(.C) void;
pub const ProcRenderPassEncoderSetBindGroup = ?fn (RenderPassEncoder, u32, BindGroup, u32, [*c]const u32) callconv(.C) void;
pub const ProcRenderPassEncoderSetBlendConstant = ?fn (RenderPassEncoder, [*c]const Color) callconv(.C) void;
pub const ProcRenderPassEncoderSetIndexBuffer = ?fn (RenderPassEncoder, Buffer, IndexFormat, u64, u64) callconv(.C) void;
pub const ProcRenderPassEncoderSetPipeline = ?fn (RenderPassEncoder, RenderPipeline) callconv(.C) void;
pub const ProcRenderPassEncoderSetScissorRect = ?fn (RenderPassEncoder, u32, u32, u32, u32) callconv(.C) void;
pub const ProcRenderPassEncoderSetStencilReference = ?fn (RenderPassEncoder, u32) callconv(.C) void;
pub const ProcRenderPassEncoderSetVertexBuffer = ?fn (RenderPassEncoder, u32, Buffer, u64, u64) callconv(.C) void;
pub const ProcRenderPassEncoderSetViewport = ?fn (RenderPassEncoder, f32, f32, f32, f32, f32, f32) callconv(.C) void;
pub const ProcRenderPipelineGetBindGroupLayout = ?fn (RenderPipeline, u32) callconv(.C) BindGroupLayout;
pub const ProcRenderPipelineSetLabel = ?fn (RenderPipeline, [*c]const u8) callconv(.C) void;
pub const ProcShaderModuleSetLabel = ?fn (ShaderModule, [*c]const u8) callconv(.C) void;
pub const ProcShaderModuleGetCompilationInfo = ?fn (ShaderModule, CompilationInfoCallback, ?*anyopaque) callconv(.C) void;
pub const ProcSurfaceGetPreferredFormat = ?fn (Surface, Adapter) callconv(.C) TextureFormat;
pub const ProcSwapChainGetCurrentTextureView = ?fn (SwapChain) callconv(.C) TextureView;
pub const ProcSwapChainPresent = ?fn (SwapChain) callconv(.C) void;
pub const ProcTextureCreateView = ?fn (Texture, [*c]const TextureViewDescriptor) callconv(.C) TextureView;
pub const ProcTextureDestroy = ?fn (Texture) callconv(.C) void;
pub extern fn wgpuCreateInstance(descriptor: [*c]const InstanceDescriptor) Instance;
pub extern fn wgpuGetProcAddress(device: Device, procName: [*c]const u8) Proc;
pub extern fn wgpuAdapterEnumerateFeatures(adapter: Adapter, features: [*]FeatureName) u32;
pub extern fn wgpuAdapterGetLimits(adapter: Adapter, limits: *SupportedLimits) bool;
pub extern fn wgpuAdapterGetProperties(adapter: Adapter, properties: *AdapterProperties) void;
pub extern fn wgpuAdapterHasFeature(adapter: Adapter, feature: FeatureName) bool;
pub extern fn wgpuAdapterRequestDevice(adapter: Adapter, descriptor: *const DeviceDescriptor, callback: RequestDeviceCallback, userdata: *anyopaque) void;
pub extern fn wgpuBufferDestroy(buffer: Buffer) void;
pub extern fn wgpuBufferGetConstMappedRange(buffer: Buffer, offset: usize, size: usize) ?*const anyopaque;
pub extern fn wgpuBufferGetMappedRange(buffer: Buffer, offset: usize, size: usize) ?*anyopaque;
pub extern fn wgpuBufferMapAsync(buffer: Buffer, mode: MapModeFlags, offset: usize, size: usize, callback: BufferMapCallback, userdata: ?*anyopaque) void;
pub extern fn wgpuBufferUnmap(buffer: Buffer) void;
pub extern fn wgpuCommandEncoderBeginComputePass(commandEncoder: CommandEncoder, descriptor: [*c]const ComputePassDescriptor) ComputePassEncoder;
pub extern fn wgpuCommandEncoderBeginRenderPass(commandEncoder: CommandEncoder, descriptor: *const RenderPassDescriptor) RenderPassEncoder;
pub extern fn wgpuCommandEncoderCopyBufferToBuffer(commandEncoder: CommandEncoder, source: Buffer, sourceOffset: u64, destination: Buffer, destinationOffset: u64, size: u64) void;
pub extern fn wgpuCommandEncoderCopyBufferToTexture(commandEncoder: CommandEncoder, source: [*c]const ImageCopyBuffer, destination: [*c]const ImageCopyTexture, copySize: [*c]const Extent3D) void;
pub extern fn wgpuCommandEncoderCopyTextureToBuffer(commandEncoder: CommandEncoder, source: [*c]const ImageCopyTexture, destination: [*c]const ImageCopyBuffer, copySize: [*c]const Extent3D) void;
pub extern fn wgpuCommandEncoderCopyTextureToTexture(commandEncoder: CommandEncoder, source: [*c]const ImageCopyTexture, destination: [*c]const ImageCopyTexture, copySize: [*c]const Extent3D) void;
pub extern fn wgpuCommandEncoderFillBuffer(commandEncoder: CommandEncoder, destination: Buffer, destinationOffset: u64, size: u64, value: u8) void;
pub extern fn wgpuCommandEncoderFinish(commandEncoder: CommandEncoder, descriptor: *const CommandBufferDescriptor) CommandBuffer;
pub extern fn wgpuCommandEncoderInsertDebugMarker(commandEncoder: CommandEncoder, markerLabel: [*c]const u8) void;
pub extern fn wgpuCommandEncoderPopDebugGroup(commandEncoder: CommandEncoder) void;
pub extern fn wgpuCommandEncoderPushDebugGroup(commandEncoder: CommandEncoder, groupLabel: [*c]const u8) void;
pub extern fn wgpuCommandEncoderResolveQuerySet(commandEncoder: CommandEncoder, querySet: QuerySet, firstQuery: u32, queryCount: u32, destination: Buffer, destinationOffset: u64) void;
pub extern fn wgpuComputePassEncoderBeginPipelineStatisticsQuery(computePassEncoder: ComputePassEncoder, querySet: QuerySet, queryIndex: u32) void;
pub extern fn wgpuComputePassEncoderDispatch(computePassEncoder: ComputePassEncoder, x: u32, y: u32, z: u32) void;
pub extern fn wgpuComputePassEncoderDispatchIndirect(computePassEncoder: ComputePassEncoder, indirectBuffer: Buffer, indirectOffset: u64) void;
pub extern fn wgpuComputePassEncoderEndPass(computePassEncoder: ComputePassEncoder) void;
pub extern fn wgpuComputePassEncoderEndPipelineStatisticsQuery(computePassEncoder: ComputePassEncoder) void;
pub extern fn wgpuComputePassEncoderInsertDebugMarker(computePassEncoder: ComputePassEncoder, markerLabel: [*c]const u8) void;
pub extern fn wgpuComputePassEncoderPopDebugGroup(computePassEncoder: ComputePassEncoder) void;
pub extern fn wgpuComputePassEncoderPushDebugGroup(computePassEncoder: ComputePassEncoder, groupLabel: [*c]const u8) void;
pub extern fn wgpuComputePassEncoderSetBindGroup(computePassEncoder: ComputePassEncoder, groupIndex: u32, group: BindGroup, dynamicOffsetCount: u32, dynamicOffsets: [*c]const u32) void;
pub extern fn wgpuComputePassEncoderSetPipeline(computePassEncoder: ComputePassEncoder, pipeline: ComputePipeline) void;
pub extern fn wgpuComputePassEncoderWriteTimestamp(computePassEncoder: ComputePassEncoder, querySet: QuerySet, queryIndex: u32) void;
pub extern fn wgpuComputePipelineGetBindGroupLayout(computePipeline: ComputePipeline, groupIndex: u32) BindGroupLayout;
pub extern fn wgpuComputePipelineSetLabel(computePipeline: ComputePipeline, label: [*c]const u8) void;
pub extern fn wgpuDeviceCreateBindGroup(device: Device, descriptor: [*c]const BindGroupDescriptor) BindGroup;
pub extern fn wgpuDeviceCreateBindGroupLayout(device: Device, descriptor: [*c]const BindGroupLayoutDescriptor) BindGroupLayout;
pub extern fn wgpuDeviceCreateBuffer(device: Device, descriptor: *const BufferDescriptor) Buffer;
pub extern fn wgpuDeviceCreateCommandEncoder(device: Device, descriptor: *const CommandEncoderDescriptor) CommandEncoder;
pub extern fn wgpuDeviceCreateComputePipeline(device: Device, descriptor: [*c]const ComputePipelineDescriptor) ComputePipeline;
pub extern fn wgpuDeviceCreateComputePipelineAsync(device: Device, descriptor: [*c]const ComputePipelineDescriptor, callback: CreateComputePipelineAsyncCallback, userdata: ?*anyopaque) void;
pub extern fn wgpuDeviceCreatePipelineLayout(device: Device, descriptor: *const PipelineLayoutDescriptor) PipelineLayout;
pub extern fn wgpuDeviceCreateQuerySet(device: Device, descriptor: [*c]const QuerySetDescriptor) QuerySet;
pub extern fn wgpuDeviceCreateRenderBundleEncoder(device: Device, descriptor: [*c]const RenderBundleEncoderDescriptor) RenderBundleEncoder;
pub extern fn wgpuDeviceCreateRenderPipeline(device: Device, descriptor: *const RenderPipelineDescriptor) RenderPipeline;
pub extern fn wgpuDeviceCreateRenderPipelineAsync(device: Device, descriptor: [*c]const RenderPipelineDescriptor, callback: CreateRenderPipelineAsyncCallback, userdata: ?*anyopaque) void;
pub extern fn wgpuDeviceCreateSampler(device: Device, descriptor: [*c]const SamplerDescriptor) Sampler;
pub extern fn wgpuDeviceCreateShaderModule(device: Device, descriptor: *const ShaderModuleDescriptor) ShaderModule;
pub extern fn wgpuDeviceCreateSwapChain(device: Device, surface: Surface, descriptor: *const SwapChainDescriptor) SwapChain;
pub extern fn wgpuDeviceCreateTexture(device: Device, descriptor: [*c]const TextureDescriptor) Texture;
pub extern fn wgpuDeviceDestroy(device: Device) void;
pub extern fn wgpuDeviceEnumerateFeatures(device: Device, features: [*]FeatureName) u32;
pub extern fn wgpuDeviceGetLimits(device: Device, limits: *SupportedLimits) bool;
pub extern fn wgpuDeviceGetQueue(device: Device) Queue;
pub extern fn wgpuDeviceHasFeature(device: Device, feature: FeatureName) bool;
pub extern fn wgpuDevicePopErrorScope(device: Device, callback: ErrorCallback, userdata: ?*anyopaque) bool;
pub extern fn wgpuDevicePushErrorScope(device: Device, filter: ErrorFilter) void;
pub extern fn wgpuDeviceSetDeviceLostCallback(device: Device, callback: DeviceLostCallback, userdata: ?*anyopaque) void;
pub extern fn wgpuDeviceSetUncapturedErrorCallback(device: Device, callback: ErrorCallback, userdata: ?*anyopaque) void;
pub extern fn wgpuInstanceCreateSurface(instance: Instance, descriptor: *const SurfaceDescriptor) Surface;
pub extern fn wgpuInstanceProcessEvents(instance: Instance) void;
pub extern fn wgpuInstanceRequestAdapter(instance: Instance, options: ?*const RequestAdapterOptions, callback: RequestAdapterCallback, userdata: ?*anyopaque) void;
pub extern fn wgpuQuerySetDestroy(querySet: QuerySet) void;
pub extern fn wgpuQueueOnSubmittedWorkDone(queue: Queue, signalValue: u64, callback: QueueWorkDoneCallback, userdata: ?*anyopaque) void;
pub extern fn wgpuQueueSubmit(queue: Queue, commandCount: u32, commands: [*]const CommandBuffer) void;
pub extern fn wgpuQueueWriteBuffer(queue: Queue, buffer: Buffer, bufferOffset: u64, data: *const anyopaque, size: usize) void;
pub extern fn wgpuQueueWriteTexture(queue: Queue, destination: [*c]const ImageCopyTexture, data: ?*const anyopaque, dataSize: usize, dataLayout: [*c]const TextureDataLayout, writeSize: [*c]const Extent3D) void;
pub extern fn wgpuRenderBundleEncoderDraw(renderBundleEncoder: RenderBundleEncoder, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32) void;
pub extern fn wgpuRenderBundleEncoderDrawIndexed(renderBundleEncoder: RenderBundleEncoder, indexCount: u32, instanceCount: u32, firstIndex: u32, baseVertex: i32, firstInstance: u32) void;
pub extern fn wgpuRenderBundleEncoderDrawIndexedIndirect(renderBundleEncoder: RenderBundleEncoder, indirectBuffer: Buffer, indirectOffset: u64) void;
pub extern fn wgpuRenderBundleEncoderDrawIndirect(renderBundleEncoder: RenderBundleEncoder, indirectBuffer: Buffer, indirectOffset: u64) void;
pub extern fn wgpuRenderBundleEncoderFinish(renderBundleEncoder: RenderBundleEncoder, descriptor: [*c]const RenderBundleDescriptor) RenderBundle;
pub extern fn wgpuRenderBundleEncoderInsertDebugMarker(renderBundleEncoder: RenderBundleEncoder, markerLabel: [*c]const u8) void;
pub extern fn wgpuRenderBundleEncoderPopDebugGroup(renderBundleEncoder: RenderBundleEncoder) void;
pub extern fn wgpuRenderBundleEncoderPushDebugGroup(renderBundleEncoder: RenderBundleEncoder, groupLabel: [*c]const u8) void;
pub extern fn wgpuRenderBundleEncoderSetBindGroup(renderBundleEncoder: RenderBundleEncoder, groupIndex: u32, group: BindGroup, dynamicOffsetCount: u32, dynamicOffsets: [*c]const u32) void;
pub extern fn wgpuRenderBundleEncoderSetIndexBuffer(renderBundleEncoder: RenderBundleEncoder, buffer: Buffer, format: IndexFormat, offset: u64, size: u64) void;
pub extern fn wgpuRenderBundleEncoderSetPipeline(renderBundleEncoder: RenderBundleEncoder, pipeline: RenderPipeline) void;
pub extern fn wgpuRenderBundleEncoderSetVertexBuffer(renderBundleEncoder: RenderBundleEncoder, slot: u32, buffer: Buffer, offset: u64, size: u64) void;
pub extern fn wgpuRenderPassEncoderBeginOcclusionQuery(renderPassEncoder: RenderPassEncoder, queryIndex: u32) void;
pub extern fn wgpuRenderPassEncoderBeginPipelineStatisticsQuery(renderPassEncoder: RenderPassEncoder, querySet: QuerySet, queryIndex: u32) void;
pub extern fn wgpuRenderPassEncoderDraw(renderPassEncoder: RenderPassEncoder, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32) void;
pub extern fn wgpuRenderPassEncoderDrawIndexed(renderPassEncoder: RenderPassEncoder, indexCount: u32, instanceCount: u32, firstIndex: u32, baseVertex: i32, firstInstance: u32) void;
pub extern fn wgpuRenderPassEncoderDrawIndexedIndirect(renderPassEncoder: RenderPassEncoder, indirectBuffer: Buffer, indirectOffset: u64) void;
pub extern fn wgpuRenderPassEncoderDrawIndirect(renderPassEncoder: RenderPassEncoder, indirectBuffer: Buffer, indirectOffset: u64) void;
pub extern fn wgpuRenderPassEncoderEndOcclusionQuery(renderPassEncoder: RenderPassEncoder) void;
pub extern fn wgpuRenderPassEncoderEndPass(renderPassEncoder: RenderPassEncoder) void;
pub extern fn wgpuRenderPassEncoderEndPipelineStatisticsQuery(renderPassEncoder: RenderPassEncoder) void;
pub extern fn wgpuRenderPassEncoderExecuteBundles(renderPassEncoder: RenderPassEncoder, bundlesCount: u32, bundles: [*c]const RenderBundle) void;
pub extern fn wgpuRenderPassEncoderInsertDebugMarker(renderPassEncoder: RenderPassEncoder, markerLabel: [*c]const u8) void;
pub extern fn wgpuRenderPassEncoderPopDebugGroup(renderPassEncoder: RenderPassEncoder) void;
pub extern fn wgpuRenderPassEncoderPushDebugGroup(renderPassEncoder: RenderPassEncoder, groupLabel: [*c]const u8) void;
pub extern fn wgpuRenderPassEncoderSetBindGroup(renderPassEncoder: RenderPassEncoder, groupIndex: u32, group: BindGroup, dynamicOffsetCount: u32, dynamicOffsets: [*c]const u32) void;
pub extern fn wgpuRenderPassEncoderSetBlendConstant(renderPassEncoder: RenderPassEncoder, color: [*c]const Color) void;
pub extern fn wgpuRenderPassEncoderSetIndexBuffer(renderPassEncoder: RenderPassEncoder, buffer: Buffer, format: IndexFormat, offset: u64, size: u64) void;
pub extern fn wgpuRenderPassEncoderSetPipeline(renderPassEncoder: RenderPassEncoder, pipeline: RenderPipeline) void;
pub extern fn wgpuRenderPassEncoderSetScissorRect(renderPassEncoder: RenderPassEncoder, x: u32, y: u32, width: u32, height: u32) void;
pub extern fn wgpuRenderPassEncoderSetStencilReference(renderPassEncoder: RenderPassEncoder, reference: u32) void;
pub extern fn wgpuRenderPassEncoderSetVertexBuffer(renderPassEncoder: RenderPassEncoder, slot: u32, buffer: Buffer, offset: u64, size: u64) void;
pub extern fn wgpuRenderPassEncoderSetViewport(renderPassEncoder: RenderPassEncoder, x: f32, y: f32, width: f32, height: f32, minDepth: f32, maxDepth: f32) void;
pub extern fn wgpuRenderPipelineGetBindGroupLayout(renderPipeline: RenderPipeline, groupIndex: u32) BindGroupLayout;
pub extern fn wgpuRenderPipelineSetLabel(renderPipeline: RenderPipeline, label: [*c]const u8) void;
pub extern fn wgpuShaderModuleSetLabel(shaderModule: ShaderModule, label: [*c]const u8) void;
pub extern fn wgpuShaderModuleGetCompilationInfo(shaderModule: ShaderModule, callback: CompilationInfoCallback, userdata: ?*anyopaque) void;
pub extern fn wgpuSurfaceGetPreferredFormat(surface: Surface, adapter: Adapter) TextureFormat;
pub extern fn wgpuSwapChainGetCurrentTextureView(swapChain: SwapChain) TextureView;
pub extern fn wgpuSwapChainPresent(swapChain: SwapChain) void;
pub extern fn wgpuTextureCreateView(texture: Texture, descriptor: [*c]const TextureViewDescriptor) TextureView;
pub extern fn wgpuTextureDestroy(texture: Texture) void;

// wgpu-native
pub const NativeFeature = enum(i32) {
    texture_adapter_specific_format_features = 268435456,
};

// wgpu-native
pub const LogLevel = enum(i32) {
    Off = 0,
    Error = 1,
    Warn = 2,
    Info = 3,
    Debug = 4,
    Trace = 5,
    _,
};

pub const AdapterExtras = extern struct {
    chain: ChainedStruct,
    backend: BackendType,
};
pub const DeviceExtras = extern struct {
    chain: ChainedStruct,
    nativeFeatures: NativeFeature,
    label: [*:0]const u8,
    tracePath: ?[*:0]const u8,
};
pub const LogCallback = fn (LogLevel, [*:0]const u8) callconv(.C) void;
pub extern fn wgpuDevicePoll(device: Device, force_wait: bool) void;
pub extern fn wgpuSetLogCallback(callback: LogCallback) void;
pub extern fn wgpuSetLogLevel(level: LogLevel) void;
pub extern fn wgpuGetVersion() u32;
pub extern fn wgpuRenderPassEncoderSetPushConstants(encoder: RenderPassEncoder, stages: ShaderStage, offset: u32, sizeBytes: u32, data: ?*anyopaque) void;
pub extern fn wgpuBufferDrop(buffer: Buffer) void;
pub extern fn wgpuCommandEncoderDrop(commandEncoder: CommandEncoder) void;
pub extern fn wgpuDeviceDrop(device: Device) void;
pub extern fn wgpuQuerySetDrop(querySet: QuerySet) void;
pub extern fn wgpuRenderPipelineDrop(renderPipeline: RenderPipeline) void;
pub extern fn wgpuTextureDrop(texture: Texture) void;
pub extern fn wgpuTextureViewDrop(textureView: TextureView) void;
pub extern fn wgpuSamplerDrop(sampler: Sampler) void;
pub extern fn wgpuBindGroupLayoutDrop(bindGroupLayout: BindGroupLayout) void;
pub extern fn wgpuPipelineLayoutDrop(pipelineLayout: PipelineLayout) void;
pub extern fn wgpuBindGroupDrop(bindGroup: BindGroup) void;
pub extern fn wgpuShaderModuleDrop(shaderModule: ShaderModule) void;
pub extern fn wgpuCommandBufferDrop(commandBuffer: CommandBuffer) void;
pub extern fn wgpuRenderBundleDrop(renderBundle: RenderBundle) void;
pub extern fn wgpuComputePipelineDrop(computePipeline: ComputePipeline) void;
pub const WHOLE_SIZE = @as(c_ulonglong, 0xffffffffffffffff);
pub const WHOLE_MAP_SIZE = @as(c_ulonglong, 18446744073709551615);
pub const COPY_STRIDE_UNDEFINED = @as(c_ulong, 0xffffffff);
pub const LIMIT_U32_UNDEFINED = @as(c_ulong, 0xffffffff);
pub const LIMIT_U64_UNDEFINED = @as(c_ulonglong, 0xffffffffffffffff);
pub const ARRAY_LAYER_COUNT_UNDEFINED = @as(c_ulong, 0xffffffff);
pub const MIP_LEVEL_COUNT_UNDEFINED = @as(c_ulong, 0xffffffff);
// pub const AdapterImpl = struct_AdapterImpl;
// pub const BindGroupImpl = struct_BindGroupImpl;
// pub const BindGroupLayoutImpl = struct_BindGroupLayoutImpl;
// pub const BufferImpl = struct_BufferImpl;
// pub const CommandBufferImpl = struct_CommandBufferImpl;
// pub const CommandEncoderImpl = struct_CommandEncoderImpl;
// pub const ComputePassEncoderImpl = struct_ComputePassEncoderImpl;
// pub const ComputePipelineImpl = struct_ComputePipelineImpl;
// pub const DeviceImpl = struct_DeviceImpl;
// pub const InstanceImpl = struct_InstanceImpl;
// pub const PipelineLayoutImpl = struct_PipelineLayoutImpl;
// pub const QuerySetImpl = struct_QuerySetImpl;
// pub const QueueImpl = struct_QueueImpl;
// pub const RenderBundleImpl = struct_RenderBundleImpl;
// pub const RenderBundleEncoderImpl = struct_RenderBundleEncoderImpl;
// pub const RenderPassEncoderImpl = struct_RenderPassEncoderImpl;
// pub const RenderPipelineImpl = struct_RenderPipelineImpl;
// pub const SamplerImpl = struct_SamplerImpl;
// pub const ShaderModuleImpl = struct_ShaderModuleImpl;
// pub const SurfaceImpl = struct_SurfaceImpl;
// pub const SwapChainImpl = struct_SwapChainImpl;
// pub const TextureImpl = struct_TextureImpl;
// pub const TextureViewImpl = struct_TextureViewImpl;
