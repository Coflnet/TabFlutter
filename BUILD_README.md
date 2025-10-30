# Building Release AAB with 16KB Page Size Support

This project builds native libraries (ONNX Runtime and Opus) with 16KB page alignment, required for Android 15+ devices.

## Quick Start

Run the complete build pipeline:

```bash
./build_release_16kb.sh
```

This script will:
1. Build ONNX Runtime for Android (arm64-v8a, x86_64)
2. Build Opus for Android (arm64-v8a, x86_64)
3. Build Flutter AAB
4. Replace native libraries in the AAB with 16KB-aligned versions
5. Verify alignment using readelf

## Output

The final AAB will be at:
```
build/app/outputs/bundle/release/app-release-16kb.aab
```

**Important**: Libraries are built in **Release mode** and **stripped** to minimize size:
- ONNX Runtime: ~30-50MB per architecture (vs 645MB debug builds)
- Opus: ~500KB per architecture
- Total AAB size should be similar to original build

### Reducing Size Further

If your app doesn't use certain ONNX Runtime features, you can edit `scripts/build_onnx_runtime_android.sh` 
and add these flags to the `./build.sh` command:

```bash
--disable_ml_ops          # Disable ML ops if not needed
--disable_contrib_ops     # Disable contrib ops if not needed
--minimal_build           # Build only ops used by your models
```

See the [ONNX Runtime build docs](https://onnxruntime.ai/docs/build/inferencing.html#reduced-operator-kernel-build) for more options.

## Requirements

- Android NDK (set via `ANDROID_NDK_HOME` or `android/local.properties`)
- Flutter SDK
- Python 3
- readelf (from binutils)
- Standard build tools (make, cmake, git)

## Scripts

- `build_release_16kb.sh` - Main build pipeline
- `scripts/build_onnx_runtime_android.sh` - Builds ONNX Runtime
- `scripts/build_opus_android.sh` - Builds Opus
- `scripts/replace_libs_in_aab.py` - Replaces libraries in AAB and verifies alignment

## Notes

- All build artifacts are excluded from git and built on-demand
- The build script will create `scripts/onnx-install` and `scripts/opus-install` directories
- Libraries are built in Release mode and stripped to minimize size
- The build process adds linker flag `-Wl,-z,max-page-size=16384` to ensure 16KB alignment
- First build takes longer (~30-60 minutes) as it builds ONNX Runtime and Opus from source
- Subsequent builds reuse existing libraries if available
