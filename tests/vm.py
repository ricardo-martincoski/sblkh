#!/usr/bin/env python3
import os
import pexpect


class VM():
    def __init__(self, request):
        os.makedirs('output/tests', exist_ok=True)
        testname = \
            str(request.module.__name__) + '__' + \
            str(request.function.__name__)
        self.log = open('output/tests/{}.log'.format(testname), 'w')
        self.command = 'board/qemu/run.sh'

    def uboot_prompt(self):
        return '=> '

    def uboot_boot(self):
        self.vm = pexpect.spawn(self.command, encoding='utf-8', logfile=self.log)
        self.vm.expect('Booting Trusted Firmware')
        self.vm.expect('U-Boot')
        self.vm.expect('Hit any key to stop autoboot:')
        self.vm.sendline()
        self.vm.expect(self.uboot_prompt())

    def uboot_command(self, command, ok_patterns=[], fail_patterns=[], result=0, timeout=-1):
        self.vm.sendline(command)
        self.vm.expect(command)
        still_expecting = fail_patterns + ok_patterns
        while len(still_expecting) > len(fail_patterns):
            i = self.vm.expect(still_expecting, timeout=timeout)
            if i < len(fail_patterns):
                raise RuntimeError('Command "{}" echoed unexpected "{}"'
                                   .format(command, still_expecting[i]))
            elif i == len(fail_patterns):
                still_expecting.pop(i)
            else:
                raise RuntimeError(
                    'Command "{}" missed to echo "{}" before "{}"'
                    .format(command, still_expecting[len(fail_patterns)], still_expecting[i]))
        still_expecting = fail_patterns + [self.uboot_prompt()]
        while len(still_expecting) > len(fail_patterns):
            i = self.vm.expect(still_expecting, timeout=timeout)
            if i < len(fail_patterns):
                raise RuntimeError('Command "{}" echoed unexpected "{}"'
                                   .format(command, still_expecting[i]))
            else:
                still_expecting.pop(i)
        self.vm.sendline('echo "#$?#"')
        self.vm.expect('echo ')
        self.vm.expect('#{}#'.format(result))
        self.vm.expect(self.uboot_prompt())

    def linux_prompt(self, result=0):
        return '#{}# '.format(result)

    def linux_boot(self):
        self.vm = pexpect.spawn(self.command, encoding='utf-8', logfile=self.log)
        self.vm.expect('Booting Trusted Firmware')
        self.vm.expect('U-Boot')
        self.vm.expect('Hit any key to stop autoboot:')
        self.vm.expect('efi/boot/bootarm.efi')
        self.vm.expect('Welcome to GRUB')
        self.vm.expect("Booting `Buildroot'")
        self.vm.expect('Linux version')
        self.vm.expect('Mounted root')
        self.vm.expect('as init process')
        self.vm.expect('login:')
        self.vm.sendline('root')
        self.vm.expect(self.linux_prompt())

    def linux_command(self, command, ok_patterns=[], fail_patterns=[], result=0, timeout=-1):
        self.vm.sendline(command)
        self.vm.expect(command)
        still_expecting = fail_patterns + ok_patterns
        while len(still_expecting) > len(fail_patterns):
            i = self.vm.expect(still_expecting, timeout=timeout)
            if i < len(fail_patterns):
                raise RuntimeError('Command "{}" echoed unexpected "{}"'
                                   .format(command, still_expecting[i]))
            elif i == len(fail_patterns):
                still_expecting.pop(i)
            else:
                raise RuntimeError(
                    'Command "{}" missed to echo "{}" before "{}"'
                    .format(command, still_expecting[len(fail_patterns)], still_expecting[i]))
        still_expecting = fail_patterns + [self.linux_prompt(result)]
        while len(still_expecting) > len(fail_patterns):
            i = self.vm.expect(still_expecting, timeout=timeout)
            if i < len(fail_patterns):
                raise RuntimeError('Command "{}" echoed unexpected "{}"'
                                   .format(command, still_expecting[i]))
            else:
                still_expecting.pop(i)

    def stop(self):
        self.vm.sendcontrol('a')
        self.vm.send('c')
        self.vm.expect('QEMU')
        self.vm.expect('(qemu)')
        self.vm.sendline('quit')
        self.vm.wait()
