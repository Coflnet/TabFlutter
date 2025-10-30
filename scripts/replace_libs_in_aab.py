#!/usr/bin/env python3
import argparse, zipfile, os, subprocess, tempfile, shutil

parser = argparse.ArgumentParser()
parser.add_argument('--aab', required=True)
parser.add_argument('--out', required=True)
parser.add_argument('--replace', action='append', help='format: zip/path=local/path')
args = parser.parse_args()

replacements = {}
for r in args.replace or []:
    if '=' not in r:
        print('Invalid replace:', r); exit(1)
    k,v = r.split('=',1)
    replacements[k] = v

if not os.path.exists(args.aab):
    print('AAB not found:', args.aab); exit(1)

print('Replacing entries in', args.aab)

tempdir = tempfile.mkdtemp(prefix='replace_aab_')
with zipfile.ZipFile(args.aab,'r') as zin:
    with zipfile.ZipFile(args.out,'w', compression=zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            if item.filename in replacements:
                local = replacements[item.filename]
                print('Replacing', item.filename, 'with', local)
                zout.writestr(item, open(local,'rb').read())
            else:
                zout.writestr(item, zin.read(item.filename))

print('Wrote new AAB:', args.out)

# Verify with readelf
for k in replacements:
    with zipfile.ZipFile(args.out,'r') as z:
        if k in z.namelist():
            tmp = os.path.join(tempdir, os.path.basename(k))
            with open(tmp,'wb') as f:
                f.write(z.read(k))
            print('\nVerification for', k)
            try:
                out = subprocess.check_output(['readelf','-lW',tmp], stderr=subprocess.STDOUT, universal_newlines=True)
                for line in out.splitlines():
                    if 'LOAD' in line and 'Align' in line:
                        print(' ', line)
            except Exception as e:
                print(' readelf failed:', e)
        else:
            print(' Not found in new AAB:', k)

print('\nDone')

# keep tempdir for inspection
print('Tempdir left at', tempdir)
