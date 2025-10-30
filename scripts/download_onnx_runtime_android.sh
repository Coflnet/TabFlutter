#!/bin/bash
# Download prebuilt ONNX Runtime AAR and extract 16KB-aligned native libraries
# This is much faster and more reliable than building from source

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ONNXR_VERSION="1.19.2"  # Latest version with guaranteed Android support
DOWNLOAD_DIR="${SCRIPT_DIR}/onnx-download"
EXTRACT_DIR="${SCRIPT_DIR}/onnx-extract"
INSTALL_DIR="${SCRIPT_DIR}/onnx-install"

usage() {
    cat << EOF
Download prebuilt ONNX Runtime AAR and extract native libraries

Usage: $0 [OPTIONS]

Options:
    --version VERSION    ONNX Runtime version (default: ${ONNXR_VERSION})
    --clean              Remove existing downloads and start fresh
    -h, --help           Show this help message

Examples:
    $0
    $0 --version 1.19.2
    $0 --clean
EOF
}

# Parse arguments
CLEAN_BUILD=0
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            ONNXR_VERSION="$2"
            shift 2
            ;;
        --clean)
            CLEAN_BUILD=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Clean if requested
if [ "$CLEAN_BUILD" -eq 1 ]; then
    echo "Cleaning existing downloads..."
    rm -rf "$DOWNLOAD_DIR" "$EXTRACT_DIR" "$INSTALL_DIR"
fi

# Create directories
mkdir -p "$DOWNLOAD_DIR" "$EXTRACT_DIR" "$INSTALL_DIR"

# Download AAR from Maven Central
AAR_FILE="${DOWNLOAD_DIR}/onnxruntime-android-${ONNXR_VERSION}.aar"
if [ ! -f "$AAR_FILE" ]; then
    echo "Downloading ONNX Runtime ${ONNXR_VERSION} AAR from Maven Central..."
    MAVEN_URL="https://repo1.maven.org/maven2/com/microsoft/onnxruntime/onnxruntime-android/${ONNXR_VERSION}/onnxruntime-android-${ONNXR_VERSION}.aar"
    
    if ! curl -L -o "$AAR_FILE" "$MAVEN_URL"; then
        echo "ERROR: Failed to download AAR from Maven Central"
        echo "Tried: $MAVEN_URL"
        exit 1
    fi
    echo "Downloaded: $AAR_FILE"
else
    echo "Using existing AAR: $AAR_FILE"
fi

# Extract AAR (it's a zip file)
echo "Extracting AAR..."
unzip -q -o "$AAR_FILE" -d "$EXTRACT_DIR"

# Copy native libraries to install directory structure
echo "Organizing native libraries..."
for ABI in arm64-v8a x86_64; do
    SRC_DIR="${EXTRACT_DIR}/jni/${ABI}"
    DST_DIR="${INSTALL_DIR}/${ABI}"
    
    if [ -d "$SRC_DIR" ]; then
        mkdir -p "$DST_DIR"
        cp -v "$SRC_DIR"/*.so "$DST_DIR/"
        
        # Check alignment
        echo "Checking alignment for ${ABI}..."
        for lib in "$DST_DIR"/*.so; do
            if [ -f "$lib" ]; then
                ALIGN=$(readelf -lW "$lib" | grep 'LOAD' | head -1 | awk '{print $NF}')
                echo "  $(basename "$lib"): Align=$ALIGN"
                
                # If alignment is not 16KB (0x4000), we need to rebuild with patching
                if [ "$ALIGN" != "0x4000" ]; then
                    echo "  ⚠️  WARNING: Not 16KB aligned! Will need manual patching."
                fi
            fi
        done
    else
        echo "WARNING: No libraries found for ${ABI}"
    fi
done

echo ""
echo "✅ ONNX Runtime libraries downloaded and extracted to: ${INSTALL_DIR}"
echo ""
echo "Libraries installed:"
find "$INSTALL_DIR" -name "*.so" -exec ls -lh {} \;
echo ""
echo "Note: If libraries are not 16KB aligned (0x4000), you'll need to:"
echo "1. Build from source with custom linker flags, OR"
echo "2. Use a binary patcher like 'align_elf_segments' tool"
echo ""
echo "To use these in Flutter, copy to:"
echo "  android/app/src/main/jniLibs/<ABI>/"
