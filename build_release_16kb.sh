#!/bin/bash
set -euo pipefail

# Small, self-contained build+patch pipeline that produces a 16KB-aligned AAB
# Steps
# 1. Clean previous outputs
# 2. flutter build appbundle --release
# 3. Post-process the AAB: inject prebuilt libs, drop 32-bit ABIs, repackage
# 4. Verify libopus.so and libonnxruntime.so are 16KB-aligned (0x4000)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
AAB_DIR="$PROJECT_ROOT/build/app/outputs/bundle/release"
RAW_AAB="$AAB_DIR/app-release.aab"
PATCHED_AAB="$AAB_DIR/app-release-16kb.aab"
PREBUILT_ROOT="$PROJECT_ROOT/scripts"
KEEP_ABIS=("arm64-v8a" "x86_64")
TARGET_LIBS=("libopus.so" "libonnxruntime.so")
declare -A LIB_DIRS=(
    ["libopus.so"]="opus-install"
    ["libonnxruntime.so"]="onnx-install"
)

msg() { printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$1"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "Error: '$1' required" >&2; exit 1; }; }

msg "Checking prerequisites"
for tool in flutter unzip zip python3 readelf; do need "$tool"; done
for abi in "${KEEP_ABIS[@]}"; do
    for lib in "${TARGET_LIBS[@]}"; do
        dir="${LIB_DIRS[$lib]}"
        path="$PREBUILT_ROOT/$dir/$abi/lib/$lib"
        [ -f "$path" ] || { echo "Missing prebuilt $lib for $abi at $path" >&2; exit 1; }
    done
done

# If a prebuilt exists but is misaligned, attempt to (re)build Opus and retry once
check_alignment() {
        local p="$1"
        if [ ! -f "$p" ]; then return 1; fi
        local align
        align=$(readelf -lW "$p" 2>/dev/null | awk '/LOAD/ {print $NF; exit}') || align=""
        if [ "${align,,}" = "0x4000" ]; then
                return 0
        else
                return 2
        fi
}

RETRY_OPUS=0
for abi in "${KEEP_ABIS[@]}"; do
    p="$PREBUILT_ROOT/${LIB_DIRS[libopus.so]}/$abi/lib/libopus.so"
    if [ -f "$p" ]; then
        if ! check_alignment "$p"; then
            echo "Prebuilt libopus.so for $abi exists but is misaligned; will attempt to rebuild Opus now"
            RETRY_OPUS=1
        fi
    fi
done

if [ $RETRY_OPUS -eq 1 ]; then
    msg "Attempting fast auto-align of prebuilts (objcopy) before full rebuild"
    if bash "$PROJECT_ROOT/scripts/align_prebuilts.sh" >/dev/null 2>&1; then
        msg "Auto-align completed; re-checking libraries"
    else
        msg "Auto-align not available or failed; will attempt full Opus rebuild"
        bash "$PROJECT_ROOT/scripts/build_opus_android.sh" --ndk "${ANDROID_NDK_HOME:-}" || true
    fi
    msg "Re-checking prebuilt libraries after Opus rebuild"
    for abi in "${KEEP_ABIS[@]}"; do
        p="$PREBUILT_ROOT/${LIB_DIRS[libopus.so]}/$abi/lib/libopus.so"
        if ! check_alignment "$p"; then
            echo "ERROR: libopus.so for $abi still misaligned after rebuild: $p" >&2
            exit 1
        fi
    done
fi

cd "$PROJECT_ROOT"
msg "Cleaning previous build artifacts"
flutter clean >/dev/null 2>&1 || true
rm -rf "$AAB_DIR"

msg "Building release AAB"
flutter build appbundle --release

[ -f "$RAW_AAB" ] || { echo "AAB not found at $RAW_AAB" >&2; exit 1; }
msg "Built raw AAB: $RAW_AAB"

msg "Patching AAB with prebuilt 16KB-aligned libraries"
python3 - "$RAW_AAB" "$PATCHED_AAB" "$PREBUILT_ROOT" <<'PY'
import sys
import zipfile
from pathlib import Path

raw_aab = Path(sys.argv[1])
patched_aab = Path(sys.argv[2])
prebuilt_root = Path(sys.argv[3])
keep_abis = ["arm64-v8a", "x86_64"]
libs = {
    "libopus.so": {
        abi: prebuilt_root / f"opus-install/{abi}/lib/libopus.so" for abi in keep_abis
    },
    "libonnxruntime.so": {
        abi: prebuilt_root / f"onnx-install/{abi}/lib/libonnxruntime.so" for abi in keep_abis
    },
}

# Build replacement map: AAB internal path -> local file
replacements = {}
for lib_name, per_abi in libs.items():
    for abi, src in per_abi.items():
        if not src.exists():
            raise SystemExit(f"Missing prebuilt library: {src}")
        aab_path = f"base/lib/{abi}/{lib_name}"
        replacements[aab_path] = src

# Repack AAB with replaced libraries
with zipfile.ZipFile(raw_aab, 'r') as zin:
    with zipfile.ZipFile(patched_aab, 'w', compression=zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            if item.filename in replacements:
                local = replacements[item.filename]
                print(f"  Replacing {item.filename} with {local}")
                with open(local, 'rb') as f:
                    zout.writestr(item, f.read())
            elif item.filename.startswith('base/lib/') and '/' in item.filename[9:]:
                # Skip other ABIs we don't want
                abi = item.filename.split('/')[2]
                if abi not in keep_abis:
                    print(f"  Skipping unwanted ABI: {item.filename}")
                    continue
                zout.writestr(item, zin.read(item.filename))
            else:
                # Copy everything else as-is
                zout.writestr(item, zin.read(item.filename))

print(f"Patched AAB written to {patched_aab}")
PY

[ -f "$PATCHED_AAB" ] || { echo "Patched AAB not produced" >&2; exit 1; }
msg "Patched AAB created: $PATCHED_AAB"

msg "Verifying 16KB alignment"
python3 - "$PATCHED_AAB" <<'PY'
import sys
import subprocess
import tempfile
import zipfile
from pathlib import Path

patched_aab = Path(sys.argv[1])
keep_abis = ["arm64-v8a", "x86_64"]
target_libs = ["libopus.so", "libonnxruntime.so"]

with tempfile.TemporaryDirectory() as tmp:
    tmpdir = Path(tmp)
    
    all_ok = True
    with zipfile.ZipFile(patched_aab, 'r') as z:
        for abi in keep_abis:
            for lib in target_libs:
                aab_path = f"base/lib/{abi}/{lib}"
                if aab_path not in z.namelist():
                    print(f"[!] Missing {abi}/{lib}")
                    all_ok = False
                    continue
                
                # Extract to temp file
                lib_file = tmpdir / f"{abi}_{lib}"
                with open(lib_file, 'wb') as f:
                    f.write(z.read(aab_path))
                
                # Check alignment with readelf
                proc = subprocess.run(["readelf", "-lW", str(lib_file)], capture_output=True, text=True)
                align = "?"
                for line in proc.stdout.splitlines():
                    if "LOAD" in line:
                        parts = [p for p in line.split() if p.startswith("0x")]
                        if parts:
                            align = parts[-1]
                        break
                status = "OK" if align.lower() == "0x4000" else "BAD"
                print(f"{abi}/{lib}: {align} [{status}]")
                if status != "OK":
                    all_ok = False

if not all_ok:
    raise SystemExit("Verification failed: some libraries not 16KB aligned")
PY

msg "Build finished successfully. Patched bundle: $PATCHED_AAB"
echo "To inspect contents: unzip -l '$PATCHED_AAB' | head"
