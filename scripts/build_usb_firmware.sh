#!/usr/bin/env bash
# Use a private SDK checkout: this script never modifies SDK or toolchain sources.
set -euo pipefail
: "${BL_SDK_BASE:?Set BL_SDK_BASE to Bouffalo SDK commit 7f44f9ea6b4ccf96db8c5236c8024b68e2a76df7}"
: "${CROSS_COMPILE:?Set CROSS_COMPILE to the BL616 GCC toolchain prefix}"
root="$(cd "$(dirname "$0")/.." && pwd)"
build="${NANOBLAST_BUILD_DIR:-$root/firmware/build}"
cmake -S "$root/firmware" -B "$build" -G Ninja \
  -DCHIP=bl616 -DBOARD=bl616dk -DTANG_BOARD=nano20k \
  -DCROSS_COMPILE="$CROSS_COMPILE" "$@"
cmake --build "$build" --parallel 3
python3 "$root/scripts/package_usb_firmware.py" "$build/build_out/tangcore_bl616.bin"
