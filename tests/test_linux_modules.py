#!/usr/bin/env python3
from vm import VM


def test_linux_module_insert_remove(request):
    vm = VM(request)
    vm.linux_boot()

    vm.linux_command('lsmod', fail_patterns=['lkm_sandbox'])
    vm.linux_command('modprobe lkm_sandbox', ['Initializing and entering the sandbox'])
    vm.linux_command('lsmod', ['lkm_sandbox'])
    vm.linux_command('modprobe -r lkm_sandbox', ['Exiting the sandbox'])
    vm.linux_command('lsmod', fail_patterns=['lkm_sandbox'])

    vm.linux_command('lsmod', fail_patterns=['lkm_skeleton'])
    vm.linux_command('modprobe lkm_skeleton')
    vm.linux_command('lsmod', ['lkm_skeleton'])
    vm.linux_command('modprobe -r lkm_skeleton')
    vm.linux_command('lsmod', fail_patterns=['lkm_skeleton'])

    vm.linux_command('lsmod', fail_patterns=['lkm_device'])
    vm.linux_command('modprobe lkm_device', ['Registered sandbox device with major number'])
    vm.linux_command('lsmod', ['lkm_device'])
    vm.linux_command('modprobe -r lkm_device', ['Exiting Sandbox Device Module'])
    vm.linux_command('lsmod', fail_patterns=['lkm_device'])

    vm.stop()
