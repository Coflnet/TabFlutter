# Rebuild Instructions - Fix AAB Size Issue

## Problem
The ONNX Runtime build failed with v1.15.1 (from 2023) and the current AAB is 398MB due to debug libraries.

## Solution - Updated to Latest ONNX Runtime

The build script has been updated to use **ONNX Runtime v1.23.2** (latest stable, Oct 2025) which:
- Fixes build compatibility issues with newer NDK/toolchains
- Includes performance and size optimizations
- Has better Android 16KB page size support

## Clean Rebuild Steps

Since the old v1.15.1 build failed, you need a clean rebuild:

```bash
# 1. Clean all build artifacts
rm -rf scripts/onnx-src scripts/onnx-build scripts/onnx-install

# 2. Run the updated build (will use v1.23.2)
./build_release_16kb.sh
```

**Or** if you want to build ONNX separately first:

```bash
# Build ONNX Runtime only with the updated script
./scripts/build_onnx_runtime_android.sh \
  --ndk /opt/android-sdk/ndk/25.1.8937393 \
  --abis arm64-v8a,x86_64 \
  --clean

# Then build the full AAB
./build_release_16kb.sh
```

## What Changed

### Updated Files
1. **`scripts/build_onnx_runtime_android.sh`**
   - Tag: `v1.15.1` → `v1.23.2` (latest stable)
   - Added `--clean` flag to force fresh builds
   - Added `/opt/android-sdk/ndk` fallback for NDK detection
   - Better error messages and usage docs

### Build Improvements
- **Release mode**: `--config Release` + `CMAKE_BUILD_TYPE=Release`
- **Stripping**: Automatic `llvm-strip --strip-debug --strip-unneeded`
- **16KB alignment**: Linker flag `-Wl,-z,max-page-size=16384`

## Expected Results

After successful rebuild:

| Component | Before (Debug v1.15.1) | After (Release v1.23.2) |
|-----------|------------------------|-------------------------|
| libonnxruntime.so arm64-v8a | 676 MB | ~30-50 MB |
| libonnxruntime.so x86_64 | 657 MB | ~30-50 MB |
| Total AAB size | 398 MB | ~100-120 MB |
| Alignment | 0x4000 (16KB) | 0x4000 (16KB) |

## Verify After Build

```bash
# Check library sizes and alignment
./check_sizes.sh

# Should show:
# - ONNX libraries: 30-50MB each (not 645MB)
# - All libraries: Align=0x4000
# - AAB size: ~100-120MB
```

## Troubleshooting

### If build still fails

**Error: "make: *** [Makefile:166: all] Fehler 2"**
- Likely cause: Insufficient memory or disk space
- Try: Reduce parallel jobs: `--jobs 4` or `--jobs 2`

**Error: NDK not found**
- Check: `ls -la /opt/android-sdk/ndk/`
- Set: `export ANDROID_NDK_HOME=/opt/android-sdk/ndk/25.1.8937393`

**Build takes too long (>1 hour)**
- Normal for ONNX Runtime first build (30-60 min on modern systems)
- Subsequent builds reuse artifacts (faster)

### Alternative: Minimal Build (Advanced)

If the AAB is still too large, you can build a minimal ONNX Runtime (only ops your models use):

```bash
# Edit scripts/build_onnx_runtime_android.sh and add these flags to ./build.sh:
--minimal_build \
--disable_ml_ops \
--disable_contrib_ops
```

This can reduce library size to ~10-20MB but requires careful testing.

## Quick Size Comparison

Before starting the rebuild, check current size:
```bash
ls -lh build/app/outputs/bundle/release/*.aab
```

After rebuild, compare:
```bash
ls -lh build/app/outputs/bundle/release/app-release-16kb.aab
./check_sizes.sh
```

The size should drop from **398MB to ~100-120MB** (or better).
