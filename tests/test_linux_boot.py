#!/usr/bin/env python3
from vm import VM


def test_linux_commands(request):
    vm = VM(request)
    vm.linux_boot()

    vm.linux_command('uname -a', ['Linux'])
    vm.linux_command('busybox --help', ['BusyBox'])

    vm.linux_command('true')
    vm.linux_command('false', result=1)

    vm.stop()
