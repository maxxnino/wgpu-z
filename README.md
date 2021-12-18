# Wgpu-Zig

This is a Wgpu example in Zig, based on [wgpu-native](https://github.com/gfx-rs/wgpu-native) release [0.10.4.1](https://github.com/gfx-rs/wgpu-native/releases/tag/v0.10.4.1).
Currently, only working on windows.

# Binding
Done all binding for enum, some struct/function needed for triangle example,

# Usage
  - Using Pre-built binaries in form of dynamic library, and dynamic load required functions at runtime
  - Clone the repo with [mach-glfw](https://github.com/hexops/mach-glfw) as dependency
  ```
  git clone --recurse-submodules https://github.com/maxxnino/wgpu-z
  ```
  - Build and run with zig
  ```
  zig build run
  ```
