#!/bin/sh
# Create the lean 700 MB raw hard-disk image for the Nightmare Ned VM.
# Size is chosen to match the CHS geometry in 86box.cfg (63 spt x 16 hpc x 1422 cyl).
#   1422 * 16 * 63 * 512 = 733,888,512 bytes (~700 MiB)
# Actual usage after a Compact Win98 SE + game install is ~332 MB, leaving
# headroom for the Windows swap file. Run from the VM directory.
#
# Usage: sh create-disk.sh [output-file]   (default: ./win98)
OUT="${1:-win98}"
dd if=/dev/zero of="$OUT" bs=512 count=$((1422 * 16 * 63)) status=none
echo "Created $OUT ($(du -h "$OUT" | cut -f1)). Win98 Setup will partition/format it (FAT32)."
