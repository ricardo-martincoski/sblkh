#!/usr/bin/env python3
from vm import VM


def test_grub_commands(request):
    vm = VM(request)
    vm.grub_boot()

    vm.grub_command('set', ['grub_cpu=arm', 'grub_platform=efi'])

    vm.stop()
