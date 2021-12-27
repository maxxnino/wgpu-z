const std = @import("std");
const glfw = @import("libs/mach-glfw/build.zig");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("wgpu", "src/main.zig");

    exe.addPackagePath("glfw", "libs/mach-glfw/src/main.zig");
    exe.addIncludeDir("libs");
    glfw.link(b, exe, .{});

    const zalg_pkg = std.build.Pkg{ .name = "zalgebra", .path = .{ .path = "libs/zalgebra/src/main.zig" } };
    exe.addPackage(zalg_pkg);
    exe.addIncludeDir("libs");
    exe.addCSourceFile("libs/cgltf.c", &.{"-std=c99"});


    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
