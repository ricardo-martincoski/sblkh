#!/usr/bin/env python3
from vm import VM


def test_uboot_commands(request):
    vm = VM(request)
    vm.uboot_boot()

    vm.uboot_command('version', ['U-Boot'])
    vm.uboot_command('printenv', ['board=qemu-arm', 'Environment size:'])

    vm.uboot_command('true')
    vm.uboot_command('false', result=1)

    vm.stop()
