#!/usr/bin/env python3
import os
import pexpect

os.makedirs('output/tests', exist_ok=True)
vm_log = open('output/tests/qemu.log', 'w')
cmd = 'board/qemu/run.sh'
vm = pexpect.spawn(cmd, encoding='utf-8', logfile=vm_log)


def wait_prompt():
    vm.expect('#0# ')


vm.wait_prompt = wait_prompt

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
vm.wait_prompt()

vm.sendline('modprobe lkm_sandbox')
vm.expect('Initializing and entering the sandbox')
vm.wait_prompt()
vm.sendline('lsmod')
vm.expect('lkm_sandbox')
vm.wait_prompt()
vm.sendline('modprobe -r lkm_sandbox')
vm.expect('Exiting the sandbox')
vm.wait_prompt()

vm.sendline('modprobe lkm_skeleton')
vm.wait_prompt()
vm.sendline('lsmod')
vm.expect('lkm_skeleton')
vm.wait_prompt()
vm.sendline('modprobe -r lkm_skeleton')
vm.wait_prompt()

vm.sendline('modprobe lkm_device')
vm.expect('Registered sandbox device with major number')
vm.wait_prompt()
vm.sendline('lsmod')
vm.expect('lkm_device')
vm.wait_prompt()
vm.sendline('modprobe -r lkm_device')
vm.expect('Exiting Sandbox Device Module')
vm.wait_prompt()

vm.sendline('reboot')
vm.expect('The system is going down')
