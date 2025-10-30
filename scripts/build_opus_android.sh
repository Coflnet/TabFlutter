#!/usr/bin/env bash
set -euo pipefail

# Build Opus for Android ABIs and replace libopus.so in the AAB
# Usage: ./scripts/build_opus_android.sh [--ndk /path/to/ndk] [--aab path/to/app-release.aab]

NDK_OVERRIDE=""
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
OUT_AAB="build/app/outputs/bundle/release/app-release-opus-fixed.aab"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ndk) NDK_OVERRIDE="$2"; shift 2;;
    --aab) AAB_PATH="$2"; shift 2;;
    --out) OUT_AAB="$2"; shift 2;;
    *) echo "Unknown arg $1"; exit 1;;
  esac
done

if [ ! -f "$AAB_PATH" ]; then
  echo "AAB not found: $AAB_PATH" >&2
  exit 1
fi

# find NDK
if [ -n "$NDK_OVERRIDE" ]; then
  NDK=$NDK_OVERRIDE
elif [ -n "${ANDROID_NDK_HOME:-}" ]; then
  NDK=$ANDROID_NDK_HOME
elif [ -n "${ANDROID_NDK_ROOT:-}" ]; then
  NDK=$ANDROID_NDK_ROOT
else
  # Try reading android/local.properties
  if [ -f android/local.properties ]; then
    SDKDIR=$(grep "^sdk.dir=" android/local.properties | cut -d'=' -f2-)
    SDKDIR=$(echo "$SDKDIR" | sed 's/\\://g')
    # try ndk under sdk
    if [ -d "$SDKDIR/ndk" ]; then
      # pick newest
      NDK=$(ls -1d "$SDKDIR/ndk"/* | tail -n1)
    fi
  fi
fi

if [ -z "${NDK:-}" ] || [ ! -d "$NDK" ]; then
  echo "Android NDK not found. Set ANDROID_NDK_HOME or pass --ndk" >&2
  exit 1
fi

echo "Using NDK: $NDK"

HOST_PREBUILT_DIR="$(ls -1d $NDK/toolchains/llvm/prebuilt/* | head -n1)"
if [ -z "$HOST_PREBUILT_DIR" ]; then
  echo "Could not find prebuilt toolchain under NDK" >&2
  exit 1
fi

echo "Toolchain prebuilt: $HOST_PREBUILT_DIR"

# Opus source
OPUS_TAG="v1.3.1" # stable known version
SRC_DIR="$(pwd)/scripts/opus-src"
BUILD_DIR="$(pwd)/scripts/opus-build"
INSTALL_DIR="$(pwd)/scripts/opus-install"

mkdir -p "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR"

if [ ! -d "$SRC_DIR/.git" ]; then
  echo "Cloning opus source into $SRC_DIR"
  git clone --depth 1 --branch "$OPUS_TAG" https://github.com/xiph/opus.git "$SRC_DIR"
else
  echo "Opus source already present, pulling latest tag $OPUS_TAG"
  (cd "$SRC_DIR" && git fetch --tags && git checkout "$OPUS_TAG")
fi

# ABIs to build
declare -A ABIS
ABIS[arm64-v8a]=aarch64-linux-android
ABIS[armeabi-v7a]=armv7a-linux-androideabi
ABIS[x86_64]=x86_64-linux-android

API_LEVEL=24

# build per ABI
for ABI in "arm64-v8a" "armeabi-v7a" "x86_64"; do
  TRIPLE=${ABIS[$ABI]}
  echo "\nBuilding Opus for $ABI (triple: $TRIPLE)"
  BUILD_SUB="${BUILD_DIR}/${ABI}"
  INSTALL_SUB="${INSTALL_DIR}/${ABI}"
  mkdir -p "$BUILD_SUB" "$INSTALL_SUB"
  cp -R "$SRC_DIR"/* "$BUILD_SUB/"
  pushd "$BUILD_SUB" >/dev/null
  # prepare autotools
  if [ ! -f configure ]; then
    ./autogen.sh || true
  fi

  case "$ABI" in
    arm64-v8a)
      CLANG_TARGET="aarch64-linux-android${API_LEVEL}"
      ;;
    armeabi-v7a)
      CLANG_TARGET="armv7a-linux-androideabi${API_LEVEL}"
      ;;
    x86_64)
      CLANG_TARGET="x86_64-linux-android${API_LEVEL}"
      ;;
  esac

  CC="$HOST_PREBUILT_DIR/bin/${CLANG_TARGET}-clang"
  CXX="$HOST_PREBUILT_DIR/bin/${CLANG_TARGET}-clang++"
  AR="$HOST_PREBUILT_DIR/bin/llvm-ar"
  RANLIB="$HOST_PREBUILT_DIR/bin/llvm-ranlib"
  STRIP="$HOST_PREBUILT_DIR/bin/llvm-strip"

  SYSROOT="$HOST_PREBUILT_DIR/sysroot"
  export CC CXX AR RANLIB STRIP
  export CFLAGS="-fPIC --sysroot=${SYSROOT} -D__ANDROID_API__=${API_LEVEL} -O3"
  export LDFLAGS="--sysroot=${SYSROOT}"

  echo "CC=$CC"
  echo "CFLAGS=$CFLAGS"

  # Clean previous
  ./configure --host=${TRIPLE} --enable-shared --disable-static --with-pic --prefix="$INSTALL_SUB" || true
  make -j$(nproc) || true
  make install || true

  # Verify output
  if [ -f "$INSTALL_SUB/lib/libopus.so" ]; then
    echo "Built: $INSTALL_SUB/lib/libopus.so"
  else
    # some configs produce .so under .libs
    if [ -f ".libs/libopus.so" ]; then
      mkdir -p "$INSTALL_SUB/lib"
      cp .libs/libopus.so "$INSTALL_SUB/lib/libopus.so"
      echo "Copied .libs/libopus.so -> $INSTALL_SUB/lib/libopus.so"
    else
      echo "Failed to build libopus for $ABI" >&2
      popd >/dev/null
      exit 1
    fi
  fi
  # Post-process: enforce 16KB alignment using llvm-objcopy or objcopy
  OBJCOPY_TOOL=""
  if command -v llvm-objcopy >/dev/null 2>&1; then
    OBJCOPY_TOOL=$(command -v llvm-objcopy)
  elif command -v objcopy >/dev/null 2>&1; then
    OBJCOPY_TOOL=$(command -v objcopy)
  else
    # try under NDK toolchain
    if [ -x "$HOST_PREBUILT_DIR/bin/llvm-objcopy" ]; then
      OBJCOPY_TOOL="$HOST_PREBUILT_DIR/bin/llvm-objcopy"
    elif [ -x "$HOST_PREBUILT_DIR/bin/objcopy" ]; then
      OBJCOPY_TOOL="$HOST_PREBUILT_DIR/bin/objcopy"
    fi
  fi

  if [ -n "$OBJCOPY_TOOL" ]; then
    SRC_LIB="$INSTALL_SUB/lib/libopus.so"
    if [ -f "$SRC_LIB" ]; then
      echo "Running $OBJCOPY_TOOL to set section alignment to 16384 for $SRC_LIB"
      TMP_OUT="$INSTALL_SUB/lib/libopus.aligned.so"
      "$OBJCOPY_TOOL" \
        --set-section-alignment .text=16384 \
        --set-section-alignment .data=16384 \
        --set-section-alignment .rodata=16384 \
        --set-section-alignment .bss=16384 \
        "$SRC_LIB" "$TMP_OUT" || {
          echo "objcopy failed for $SRC_LIB" >&2
          rm -f "$TMP_OUT" || true
        }
      if [ -f "$TMP_OUT" ]; then
        mv "$TMP_OUT" "$SRC_LIB"
        echo "Replaced $SRC_LIB with aligned version"
      fi
    fi
  else
    echo "Warning: llvm-objcopy/objcopy not found; cannot post-align libopus.so"
  fi

  popd >/dev/null
done

# At this point, we have built libopus.so for each ABI under scripts/opus-install/<ABI>/lib/libopus.so
# Use the Python helper to replace these files in the AAB and verify
PY_REPLACE="$(pwd)/scripts/replace_libs_in_aab.py"
if [ ! -f "$PY_REPLACE" ]; then
  echo "Missing helper script: $PY_REPLACE" >&2
  exit 1
fi

python3 "$PY_REPLACE" \
  --aab "$AAB_PATH" \
  --out "$OUT_AAB" \
  --replace "base/lib/arm64-v8a/libopus.so=$(pwd)/scripts/opus-install/arm64-v8a/lib/libopus.so" \
  --replace "base/lib/armeabi-v7a/libopus.so=$(pwd)/scripts/opus-install/armeabi-v7a/lib/libopus.so" \
  --replace "base/lib/x86_64/libopus.so=$(pwd)/scripts/opus-install/x86_64/lib/libopus.so"

echo "Done. New AAB at: $OUT_AAB"

exit 0

