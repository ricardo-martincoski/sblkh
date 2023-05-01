// SPDX-License-Identifier: GPL-2.0-only
/*
 * Example driver
 *
 * Copyright (C) 2023  Ricardo Martincoski  <ricardo.martincoski@gmail.com>
 */

#include <linux/module.h>

static int __init example_init(void)
{
    // https://www.kernel.org/doc/html/latest/kernel-hacking/hacking.html#printk
	// printk(KERN_INFO "Loading example\n");
    // but checkpatch.pl warns:
    // |WARNING: Prefer [subsystem eg: netdev]_info([subsystem]dev, ... then
    // |dev_info(dev, ... then pr_info(...  to printk(KERN_INFO ...
    // so:
    // https://www.kernel.org/doc/html/latest/core-api/printk-basics.html#c.pr_info
	pr_info("Loading example\n");

	return 0;
}

static void __exit example_exit(void)
{
	pr_info("Unloading example\n");
}

// https://www.kernel.org/doc/html/latest/kernel-hacking/hacking.html#initcall-module-init
// https://www.kernel.org/doc/html/latest/driver-api/basics.html#c.module_init
module_init(example_init);
// https://www.kernel.org/doc/html/latest/kernel-hacking/hacking.html#module-exit
// https://www.kernel.org/doc/html/latest/driver-api/basics.html#c.module_exit
module_exit(example_exit);

// https://www.kernel.org/doc/html/latest/process/license-rules.html?highlight=module_license#id1
MODULE_LICENSE("GPL v2");
