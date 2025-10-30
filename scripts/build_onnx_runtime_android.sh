#!/usr/bin/env bash
set -euo pipefail

# Build ONNX Runtime for Android ABIs and optionally replace the resulting
# libonnxruntime.so files inside an AAB using scripts/replace_libs_in_aab.py.
#
# Notes / requirements:
# - Requires: git, cmake, ninja or make, python3, Android NDK (r21+ recommended), JDK
# - Building ONNX Runtime can be slow and may require additional system deps
#   (protobuf, absl, etc). This script tries a pure CMake build which works on
#   many systems but may need adaptation depending on the onnxruntime version.
# - Use --ndk to point to an NDK, or set ANDROID_NDK_HOME environment variable,
#   or provide android/local.properties with ndk.dir entry.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="$SCRIPT_DIR/onnx-src"
BUILD_DIR_BASE="$SCRIPT_DIR/onnx-build"
INSTALL_DIR_BASE="$SCRIPT_DIR/onnx-install"

NDK=""
AAB=""
OUT_AAB=""
ABIS=("arm64-v8a" "armeabi-v7a" "x86_64")
JOBS="$(nproc || echo 4)"
ONNXR_TAG="v1.15.1" # fallback tag; you can change this if needed

usage() {
  cat <<-USAGE
Usage: $0 [--ndk /path/to/ndk] [--aab path/to/app.aab --out path/to/out.aab] [--abis abi1,abi2] [--tag <onnxruntime-tag>] [--jobs N]

This will clone ONNX Runtime (if needed), build libonnxruntime.so for each ABI,
install them under scripts/onnx-install/<abi>/lib/libonnxruntime.so and optionally
replace the libs inside an AAB using scripts/replace_libs_in_aab.py.
USAGE
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ndk) NDK="$2"; shift 2;;
    --aab) AAB="$2"; shift 2;;
    --out) OUT_AAB="$2"; shift 2;;
    --abis) IFS=',' read -r -a ABIS <<< "$2"; shift 2;;
    --tag) ONNXR_TAG="$2"; shift 2;;
    --jobs) JOBS="$2"; shift 2;;
    -h|--help) usage;;
    *) echo "Unknown arg: $1"; usage;;
  esac
done

# Resolve NDK
if [[ -z "$NDK" ]]; then
  if [[ -n "${ANDROID_NDK_HOME:-}" ]]; then
    NDK="$ANDROID_NDK_HOME"
  elif [[ -f android/local.properties ]]; then
    line=$(grep -E '^ndk.dir=' android/local.properties || true)
    if [[ -n "$line" ]]; then
      NDK="${line#ndk.dir=}"
    fi
  fi
fi

# Additional fallback: common system-wide SDK install path used on some machines/CI
if [[ -z "$NDK" ]]; then
  if [[ -d "/opt/android-sdk/ndk" ]]; then
    # pick the newest installed NDK under /opt/android-sdk/ndk
    ndk_found=$(ls -1d /opt/android-sdk/ndk/* 2>/dev/null | sort -V | tail -n1 || true)
    if [[ -n "$ndk_found" && -d "$ndk_found" ]]; then
      NDK="$ndk_found"
    fi
  fi
fi

if [[ -z "$NDK" ]]; then
  echo "ERROR: Android NDK not found. Set --ndk or ANDROID_NDK_HOME or add ndk.dir to android/local.properties." >&2
  exit 2
fi

echo "Using NDK: $NDK"
echo "ABIs: ${ABIS[*]}"

mkdir -p "$REPOS_DIR" "$BUILD_DIR_BASE" "$INSTALL_DIR_BASE"

if [[ ! -d "$REPOS_DIR/.git" ]]; then
  echo "Cloning ONNX Runtime into $REPOS_DIR (tag: $ONNXR_TAG)"
  git clone --depth 1 --branch "$ONNXR_TAG" https://github.com/microsoft/onnxruntime.git "$REPOS_DIR"
else
  echo "ONNX Runtime source already present in $REPOS_DIR"
  pushd "$REPOS_DIR" > /dev/null
  git fetch --depth 1 origin "$ONNXR_TAG" || true
  git checkout "$ONNXR_TAG" || true
  popd > /dev/null
fi

# Patch cmake files to add 16KB page size alignment for Android (Play Store requirement)
# Reference: https://github.com/microsoft/onnxruntime/issues/21837
CMAKE_FILE="$REPOS_DIR/cmake/adjust_global_compile_flags.cmake"
if [[ -f "$CMAKE_FILE" ]]; then
  if ! grep -q "max-page-size=16384" "$CMAKE_FILE"; then
    echo "Patching $CMAKE_FILE to add 16KB page size alignment for Android..."
    
    # Find the line containing "if(ANDROID)" and add linker flags after it
    # If no such block exists, create one at the end
    if grep -q "if(ANDROID)" "$CMAKE_FILE"; then
      # Add the linker flag right after the if(ANDROID) line
      sed -i '/if(ANDROID)/a \  # Support for Android 16KB page size requirement (Play Store)\n  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,max-page-size=16384")' "$CMAKE_FILE"
    else
      # No Android block exists, add one at the end of the file
      cat >> "$CMAKE_FILE" <<'PATCH_EOF'

# Support for Android 16KB page size requirement (Play Store)
# Reference: https://github.com/microsoft/onnxruntime/issues/21837
if(ANDROID)
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,max-page-size=16384")
endif()
PATCH_EOF
    fi
    echo "Patch applied successfully."
  else
    echo "16KB alignment patch already present in $CMAKE_FILE, skipping."
  fi
else
  echo "WARNING: $CMAKE_FILE not found. Linker flags may not be set correctly." >&2
fi

for ABI in "${ABIS[@]}"; do
  INSTALL_DIR="$INSTALL_DIR_BASE/$ABI"
  mkdir -p "$INSTALL_DIR/lib"

  echo ""
  echo "==================================================================="
  echo "Building ONNX Runtime for ABI: $ABI"
  echo "==================================================================="

  # Use the official build.sh script which handles all the build complexity
  pushd "$REPOS_DIR" > /dev/null
  
  # Build in Release mode with optimizations for size
  ./build.sh \
    --android \
    --android_abi "$ABI" \
    --android_api 24 \
    --android_ndk_path "$NDK" \
    --parallel "$JOBS" \
    --config Release \
    --update \
    --build \
    --skip_tests \
    --build_dir "build/Android_$ABI" \
    --build_shared_lib \
    --cmake_extra_defines CMAKE_BUILD_TYPE=Release \
    --cmake_extra_defines CMAKE_POLICY_VERSION_MINIMUM=3.5 || {
      echo "ERROR: Build failed for ABI $ABI" >&2
      popd > /dev/null
      continue
    }
  
  popd > /dev/null

  # Locate the built libonnxruntime.so
  # The official build.sh typically outputs to build/Android_<ABI>/Debug or Release
  found=""
  search_paths=(
    "$REPOS_DIR/build/Android_$ABI/Release"
    "$REPOS_DIR/build/Android_$ABI/Debug"
    "$REPOS_DIR/build/Android_$ABI"
  )
  
  for p in "${search_paths[@]}"; do
    if [[ -f "$p/libonnxruntime.so" ]]; then
      cp "$p/libonnxruntime.so" "$INSTALL_DIR/lib/libonnxruntime.so"
      found=1
      echo "Copied: $p/libonnxruntime.so -> $INSTALL_DIR/lib/libonnxruntime.so"
      break
    fi
  done

  if [[ -z "$found" ]]; then
    echo "WARNING: Could not find libonnxruntime.so for $ABI. Checking build output..." >&2
    candidate=$(find "$REPOS_DIR/build/Android_$ABI" -type f -name "libonnxruntime.so" -print -quit 2>/dev/null || true)
    if [[ -n "$candidate" ]]; then
      cp "$candidate" "$INSTALL_DIR/lib/libonnxruntime.so"
      echo "Found and copied: $candidate -> $INSTALL_DIR/lib/libonnxruntime.so"
      found=1
    else
      echo "ERROR: libonnxruntime.so not found for $ABI!" >&2
      continue
    fi
  fi

  # Strip debug symbols to reduce size
  if [[ -n "$found" ]]; then
    ORIGINAL_SIZE=$(du -h "$INSTALL_DIR/lib/libonnxruntime.so" | cut -f1)
    if [[ -f "$NDK/toolchains/llvm/prebuilt/"*/bin/llvm-strip ]]; then
      STRIP_TOOL=$(find "$NDK/toolchains/llvm/prebuilt" -name "llvm-strip" -type f | head -n1)
      "$STRIP_TOOL" --strip-debug --strip-unneeded "$INSTALL_DIR/lib/libonnxruntime.so" 2>/dev/null || true
      STRIPPED_SIZE=$(du -h "$INSTALL_DIR/lib/libonnxruntime.so" | cut -f1)
      echo "Stripped library: $ORIGINAL_SIZE -> $STRIPPED_SIZE"
    fi
  fi

  # Verify 16KB alignment using readelf
  if command -v readelf &> /dev/null; then
    echo ""
    echo "Verifying ELF alignment for $ABI:"
    readelf -lW "$INSTALL_DIR/lib/libonnxruntime.so" | grep -A1 "Program Headers" || true
    readelf -lW "$INSTALL_DIR/lib/libonnxruntime.so" | grep "LOAD" || true
    
    # Check if we have 16KB (0x4000) alignment
    if readelf -lW "$INSTALL_DIR/lib/libonnxruntime.so" | grep "LOAD" | grep -q "0x4000"; then
      echo "✓ SUCCESS: 16KB alignment detected for $ABI"
    else
      echo "⚠ WARNING: 16KB alignment NOT detected for $ABI. Check the readelf output above."
      echo "  Expected: Align = 0x4000 (16384 bytes)"
    fi
  else
    echo "readelf not available, skipping alignment verification"
  fi
  echo ""

done

if [[ -n "$AAB" ]]; then
  if [[ -z "$OUT_AAB" ]]; then
    OUT_AAB="${AAB%.aab}-onnx-fixed.aab"
  fi
  echo "Replacing onnx runtime libs inside AAB: $AAB -> $OUT_AAB"
  # Build replacement args for replace_libs_in_aab.py
  REPLACE_ARGS=()
  for ABI in "${ABIS[@]}"; do
    localpath="$INSTALL_DIR_BASE/$ABI/lib/libonnxruntime.so"
    zipentry="base/lib/$ABI/libonnxruntime.so"
    if [[ -f "$localpath" ]]; then
      REPLACE_ARGS+=("$zipentry=$localpath")
    else
      echo "Skipping $ABI: built library not found at $localpath"
    fi
  done

  if [[ ${#REPLACE_ARGS[@]} -eq 0 ]]; then
    echo "No replacement libs found; skipping AAB repack.";
    exit 0
  fi

  python3 "$SCRIPT_DIR/replace_libs_in_aab.py" --aab "$AAB" --out "$OUT_AAB" $(printf '%s ' "${REPLACE_ARGS[@]}")
  echo "Done. New AAB: $OUT_AAB"
fi

echo "All done. Built artifacts (if any) are under: $INSTALL_DIR_BASE"
