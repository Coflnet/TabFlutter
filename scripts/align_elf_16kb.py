#!/usr/bin/env python3
"""
Patch ELF binaries to use 16KB (0x4000) alignment for all LOAD segments.
This is required for Android 15+ with 16KB page size support.
"""

import struct
import sys
import os
from pathlib import Path

def align_to(value, alignment):
    """Round up value to next alignment boundary"""
    return (value + alignment - 1) & ~(alignment - 1)

def patch_elf_alignment(input_path, output_path, new_alignment=0x4000):
    """
    Patch an ELF file to use specified alignment for all LOAD segments.
    
    Args:
        input_path: Path to input ELF file
        output_path: Path to output patched ELF file
        new_alignment: New alignment value (default 0x4000 = 16KB)
    """
    with open(input_path, 'rb') as f:
        data = bytearray(f.read())
    
    # Check ELF magic
    if data[:4] != b'\x7fELF':
        raise ValueError(f"Not an ELF file: {input_path}")
    
    # Get ELF class (32-bit or 64-bit)
    elf_class = data[4]
    if elf_class == 1:  # 32-bit
        is_64bit = False
        phoff_offset = 0x1c
        phentsize_offset = 0x2a
        phnum_offset = 0x2c
        struct_fmt = '<'  # Assume little-endian
    elif elf_class == 2:  # 64-bit
        is_64bit = True
        phoff_offset = 0x20
        phentsize_offset = 0x36
        phnum_offset = 0x38
        struct_fmt = '<'  # Assume little-endian
    else:
        raise ValueError(f"Unknown ELF class: {elf_class}")
    
    # Read program header info
    if is_64bit:
        phoff = struct.unpack_from('<Q', data, phoff_offset)[0]
    else:
        phoff = struct.unpack_from('<I', data, phoff_offset)[0]
    
    phentsize = struct.unpack_from('<H', data, phentsize_offset)[0]
    phnum = struct.unpack_from('<H', data, phnum_offset)[0]
    
    print(f"ELF {64 if is_64bit else 32}-bit, {phnum} program headers at offset 0x{phoff:x}")
    
    # Process each program header
    patched_count = 0
    for i in range(phnum):
        ph_offset = phoff + i * phentsize
        
        # Read segment type (first 4 bytes of program header)
        p_type = struct.unpack_from('<I', data, ph_offset)[0]
        
        # Only process PT_LOAD segments (type = 1)
        if p_type != 1:
            continue
        
        if is_64bit:
            # 64-bit program header layout:
            # p_type (4), p_flags (4), p_offset (8), p_vaddr (8), p_paddr (8),
            # p_filesz (8), p_memsz (8), p_align (8)
            p_offset_off = ph_offset + 8
            p_vaddr_off = ph_offset + 16
            p_paddr_off = ph_offset + 24
            p_filesz_off = ph_offset + 32
            p_memsz_off = ph_offset + 40
            p_align_off = ph_offset + 48
            
            p_offset = struct.unpack_from('<Q', data, p_offset_off)[0]
            p_vaddr = struct.unpack_from('<Q', data, p_vaddr_off)[0]
            p_paddr = struct.unpack_from('<Q', data, p_paddr_off)[0]
            p_filesz = struct.unpack_from('<Q', data, p_filesz_off)[0]
            p_memsz = struct.unpack_from('<Q', data, p_memsz_off)[0]
            old_align = struct.unpack_from('<Q', data, p_align_off)[0]
            
            # Patch alignment
            struct.pack_into('<Q', data, p_align_off, new_alignment)
            
        else:
            # 32-bit program header layout:
            # p_type (4), p_offset (4), p_vaddr (4), p_paddr (4),
            # p_filesz (4), p_memsz (4), p_flags (4), p_align (4)
            p_offset_off = ph_offset + 4
            p_vaddr_off = ph_offset + 8
            p_paddr_off = ph_offset + 12
            p_filesz_off = ph_offset + 16
            p_memsz_off = ph_offset + 20
            p_align_off = ph_offset + 28
            
            p_offset = struct.unpack_from('<I', data, p_offset_off)[0]
            p_vaddr = struct.unpack_from('<I', data, p_vaddr_off)[0]
            p_paddr = struct.unpack_from('<I', data, p_paddr_off)[0]
            p_filesz = struct.unpack_from('<I', data, p_filesz_off)[0]
            p_memsz = struct.unpack_from('<I', data, p_memsz_off)[0]
            old_align = struct.unpack_from('<I', data, p_align_off)[0]
            
            # Patch alignment
            struct.pack_into('<I', data, p_align_off, new_alignment)
        
        print(f"  LOAD segment {patched_count}: vaddr=0x{p_vaddr:x}, "
              f"offset=0x{p_offset:x}, size=0x{p_filesz:x}, "
              f"align: 0x{old_align:x} -> 0x{new_alignment:x}")
        
        patched_count += 1
    
    # Write patched file
    with open(output_path, 'wb') as f:
        f.write(data)
    
    # Preserve permissions
    os.chmod(output_path, os.stat(input_path).st_mode)
    
    print(f"✅ Patched {patched_count} LOAD segments")
    return patched_count

def main():
    if len(sys.argv) < 2:
        print("Usage: align_elf_16kb.py <input.so> [output.so]")
        print("  If output not specified, will overwrite input file")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else input_file
    
    if not os.path.exists(input_file):
        print(f"ERROR: File not found: {input_file}")
        sys.exit(1)
    
    print(f"Patching: {input_file}")
    if input_file != output_file:
        print(f"Output:   {output_file}")
    else:
        print(f"Output:   (in-place)")
    print()
    
    try:
        patch_elf_alignment(input_file, output_file)
        print(f"\n✅ Successfully patched {output_file}")
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
