#!/bin/bash
# Quick script to analyze AAB size differences

echo "=== AAB Size Comparison ==="
echo ""

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    echo "Original AAB:"
    ls -lh build/app/outputs/bundle/release/app-release.aab
    unzip -l build/app/outputs/bundle/release/app-release.aab | grep "base/lib.*\.so" | awk '{printf "  %-50s %10s\n", $4, $1}'
    echo ""
fi

if [ -f "build/app/outputs/bundle/release/app-release-16kb.aab" ]; then
    echo "16KB-aligned AAB:"
    ls -lh build/app/outputs/bundle/release/app-release-16kb.aab
    unzip -l build/app/outputs/bundle/release/app-release-16kb.aab | grep "base/lib.*\.so" | awk '{printf "  %-50s %10s\n", $4, $1}'
    echo ""
fi

echo "=== Prebuilt Library Sizes ==="
echo ""
if [ -d "scripts/onnx-install" ]; then
    echo "ONNX Runtime libraries:"
    find scripts/onnx-install -name "*.so" -exec ls -lh {} \; | awk '{printf "  %-50s %10s\n", $9, $5}'
fi
if [ -d "scripts/opus-install" ]; then
    echo "Opus libraries:"
    find scripts/opus-install -name "*.so" -exec ls -lh {} \; | awk '{printf "  %-50s %10s\n", $9, $5}'
fi

echo ""
echo "=== Library Alignment Check ==="
for lib in scripts/onnx-install/*/lib/*.so scripts/opus-install/*/lib/*.so; do
    if [ -f "$lib" ]; then
        align=$(readelf -lW "$lib" 2>/dev/null | grep LOAD | awk '{print $NF}' | head -1)
        printf "  %-50s Align=%s\n" "$lib" "$align"
    fi
done
