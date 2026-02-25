#!/usr/bin/env python3
"""Generate legacy AssetManifest.json required by flutter_translate 4.x.

Newer Flutter versions only generate AssetManifest.bin, but flutter_translate
expects the legacy JSON format. This script creates it from the built assets.
"""
import json
import os

assets_dir = 'build/web/assets'
manifest = {}

for root, dirs, files in os.walk(assets_dir):
    for f in files:
        full = os.path.join(root, f)
        rel = os.path.relpath(full, 'build/web')
        manifest[rel] = [rel]

with open(os.path.join(assets_dir, 'AssetManifest.json'), 'w') as fh:
    json.dump(manifest, fh)

print(f"Generated AssetManifest.json with {len(manifest)} entries")
