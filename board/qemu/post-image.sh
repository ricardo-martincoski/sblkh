#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# copied from Buildroot 2023.02-rc3
# (original file buildroot/board/qemu/arm-ebbr/post-image.sh)
# and then updated:
# - to contain this license header

set -eu

BOARD_DIR=$(dirname "$0")

# Create flash.bin TF-A FIP image from bl1.bin and fip.bin
dd if="${BINARIES_DIR}/bl1.bin" of="${BINARIES_DIR}/flash.bin" bs=1M
dd if="${BINARIES_DIR}/fip.bin" of="${BINARIES_DIR}/flash.bin" seek=64 bs=4096 conv=notrunc

# Override the default GRUB configuration file with our own.
cp -f "${BOARD_DIR}/grub.cfg" "${BINARIES_DIR}/efi-part/EFI/BOOT/grub.cfg"
