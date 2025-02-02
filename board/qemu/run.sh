#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# copied from Buildroot 2023.02-rc3
# (original file buildroot/board/qemu/arm-ebbr/readme.txt)
# and then updated:
# - to contain this license header
# - to change the original txt file into an executable script
# - to execute in read-only mode, in order to avoid the need for a write lock
#   between runtime tests
# - to change the directory from which the images are read

set -e -x

qemu-system-arm \
      -snapshot \
      -M virt,secure=on \
      -bios output/needed-images/flash.bin \
      -cpu cortex-a15 \
      -device virtio-blk-device,drive=hd0 \
      -device virtio-net-device,netdev=eth0 \
      -device virtio-rng-device,rng=rng0 \
      -drive file=output/needed-images/disk.img,if=none,format=raw,id=hd0 \
      -m 1024 \
      -netdev user,id=eth0 \
      -no-acpi \
      -nographic \
      -object rng-random,filename=/dev/urandom,id=rng0 \
      -rtc base=utc,clock=host \
      -smp 2 # qemu_arm_ebbr_defconfig
