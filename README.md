[TOC]

# sblkh

**sblkh** stands for *sandbox for Linux Kernel hacking*.

Its main purpose is to provide a reproducible environment to test tools and
techniques related to debugging or hacking the Linux Kernel, for my own
educational purposes.

------

## License

SPDX-License-Identifier: GPL-2.0-only

    sblkh
    Copyright (C) 2023  Ricardo Martincoski  <ricardo.martincoski@gmail.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; version 2.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

------

There are some files in the tree copied from other projects.
All of such files were originally licensed using a license that allows them to
be redistributed following GPL-2.0.
They have the license stated in the header of the file. For instance:

    SPDX-License-Identifier: GPL-2.0-or-later
    copied from <Project name> <version>
    and then updated:
    - to do <something nice>

------

## The target system

The target system has this configuration:

| Hardware   | Type and size           |
|:-----------|:------------------------|
| Processor  | ARM cortex-a15 2 cores  |
| RAM        | 1 GiB                   |
| Disk       | VirtIO, 329 MiB         |

The software image is generated using Buildroot and the hardware is emulated by
QEMU.

| Disk         | Partition    | Size     | Contents                             |
|:-------------|:-------------|---------:|:-------------------------------------|
| flash.bin    | -            | 1427 KiB | Arm Trusted Firmware + U-Boot        |
| disk.img     | GPT          | 329 MiB  | partition table + partitions below   |
| disk.img     | boot / fat16 | 128 MiB  | GRUB 2 + Linux Kernel                |
| disk.img     | root / ext4  | 200 MiB  | root file system, including BusyBox  |

| Software                    | Version      | Purpose                  |
|:----------------------------|:------------:|:-------------------------|
| Buildroot                   | 2023.02-rc3  | build system             |
| Arm Trusted Firmware (ATF)  | v2.7         | initial boot stage       |
| U-Boot                      | 2022.10      | bootloader               |
| GRUB 2                      | 2.06         | boot manager             |
| Linux Kernel                | 6.0.9        | operating system         |
| BusyBox                     | v1.36.0      | user space applications  |
| lkm-sandbox                 | 40141400388  | out-of-tree driver       |
| QEMU                        | 7.2.0        | system emulator          |

------

## How to run the tests

Assumption: using a computer with `Ubuntu 22.04.2`.

### Install `docker` and add your user to its group

    $ sudo apt install docker.io
    $ sudo groupadd docker
    $ sudo usermod -aG docker $USER # NOTE: logout/login after this
    $ docker run hello-world

### Install `git` and `make`

    $ sudo apt install git make

### Download the repo

    $ git clone --depth 1 --recurse-submodules \
      https://gitlab.com/RicardoMartincoski_opensource/sblkh.git
    $ cd sblkh

### Generate the image

In the very first call this command takes a couple of hours to run.

    $ make images

### Run runtime tests

    $ make test

### Run the image

    $ make run

User `root` password `root`.

Ctrl+A,C opens the console in which one can use `quit` to abruptly stop QEMU.

    (qemu) quit

### Run static analysis tools, generate the image, run runtime tests, and run post-build tools

    $ make all

### More use cases

    $ make help
