#!/usr/bin/env python3
import os
import pexpect

os.makedirs('output/tests', exist_ok=True)
vm_log = open('output/tests/qemu.log', 'w')
cmd = 'board/qemu/run.sh'
vm = pexpect.spawn(cmd, encoding='utf-8', logfile=vm_log)

vm.expect('Booting Trusted Firmware')
vm.expect('U-Boot')
vm.expect('Hit any key to stop autoboot:')
vm.expect('efi/boot/bootarm.efi')
vm.expect('Welcome to GRUB')
vm.expect("Booting `Buildroot'")
vm.expect('Linux version')
vm.expect('Mounted root')
vm.expect('as init process')
vm.expect('login:')
vm.sendline('root')
vm.expect('#')

vm.sendline('reboot')
vm.expect('The system is going down')
