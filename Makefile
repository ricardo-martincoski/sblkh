BASE_DIR := $(shell readlink -f .)
SRC_BR2_EXTERNAL_DIR := $(BASE_DIR)
SRC_BUILDROOT_DIR := $(BASE_DIR)/buildroot
OUTPUT_DIR := $(BASE_DIR)/output
CACHE_COMPILER_DIR := $(BASE_DIR)/.ccache
CACHE_DOWNLOAD_DIR := $(BASE_DIR)/download
URL_DOCKER_IMAGE := ricardomartincoski_opensource/sblkh/sblkh

BR_MAKE := \
	cd $(OUTPUT_DIR) && \
		$(SRC_BUILDROOT_DIR)/utils/brmake

# make V=1 will enable verbose mode
V ?= 0
ifeq ($(V),0)
Q := @
else
Q :=
endif

check_inside_docker := $(shell if [ "`groups`" = 'br-user' ]; then echo y; else echo n; fi)
date := $(shell date +%Y%m%d.%H%M --utc)
define print_target_name
	@echo "=== $@ ==="
endef
define print_target_name_outsize_docker
	@echo "====== $@ ======"
endef
define create_stamp_file
	$(Q)touch $@
endef

real_targets_inside_docker := \
	.stamp_configure \
	.stamp_source \
	.stamp_toolchain \
	.stamp_uboot \
	.stamp_arm_trusted_firmware \
	.stamp_grub2 \
	.stamp_linux_depends \
	.stamp_linux \
	.stamp_rootfs \

phony_targets_outside_docker := \
	clean \
	distclean \
	docker-image \
	help \

phony_targets_inside_docker := \
	configure \
	source \
	toolchain \
	uboot \
	arm-trusted-firmware \
	grub2 \
	linux-depends \
	linux \
	rootfs \
	run \
	test \
	static-analysis \
	check-package \
	check-flake8 \
	linux-menuconfig \

.PHONY: default $(phony_targets_inside_docker) $(phony_targets_outside_docker)
default: rootfs

ifeq ($(check_inside_docker),n) ########################################

$(real_targets_inside_docker) $(phony_targets_inside_docker):
	$(print_target_name_outsize_docker)
	$(Q)utils/docker-run $(MAKE) V=$(V) $@

else # ($(check_inside_docker),n) ########################################

configure: .stamp_configure
	$(print_target_name)
.stamp_configure:
	$(print_target_name)
	$(Q)$(MAKE) \
		BR2_EXTERNAL=$(SRC_BR2_EXTERNAL_DIR) \
		O=$(OUTPUT_DIR) \
		-C $(SRC_BUILDROOT_DIR) \
		qemu_defconfig
	$(create_stamp_file)

source: .stamp_source
	$(print_target_name)
.stamp_source: .stamp_configure
	$(print_target_name)
	$(Q)$(BR_MAKE) source
	$(create_stamp_file)

toolchain: .stamp_toolchain
	$(print_target_name)
.stamp_toolchain: .stamp_source
	$(print_target_name)
	$(Q)$(BR_MAKE) toolchain
	$(create_stamp_file)

uboot: .stamp_uboot
	$(print_target_name)
.stamp_uboot: .stamp_toolchain
	$(print_target_name)
	$(Q)$(BR_MAKE) uboot
	$(create_stamp_file)

arm-trusted-firmware: .stamp_arm_trusted_firmware
	$(print_target_name)
.stamp_arm_trusted_firmware: .stamp_uboot
	$(print_target_name)
	$(Q)$(BR_MAKE) arm-trusted-firmware
	$(create_stamp_file)

grub2: .stamp_grub2
	$(print_target_name)
.stamp_grub2: .stamp_arm_trusted_firmware
	$(print_target_name)
	$(Q)$(BR_MAKE) grub2
	$(create_stamp_file)

linux-depends: .stamp_linux_depends
	$(print_target_name)
.stamp_linux_depends: .stamp_grub2
	$(print_target_name)
	$(Q)$(BR_MAKE) linux-depends
	$(create_stamp_file)

linux: .stamp_linux
	$(print_target_name)
.stamp_linux: .stamp_linux_depends
	$(print_target_name)
	$(Q)$(BR_MAKE) linux
	$(create_stamp_file)

rootfs: .stamp_rootfs
	$(print_target_name)
.stamp_rootfs: .stamp_linux
	$(print_target_name)
	$(Q)$(BR_MAKE) all
	$(create_stamp_file)

run: .stamp_rootfs
	$(print_target_name)
	$(Q)board/qemu/run.sh

test: .stamp_rootfs
	$(print_target_name)
	$(Q)python3 -m pytest tests/

include Makefile.buildroot
static-analysis:
	$(print_target_name)
	$(Q)$(MAKE) V=$(V) check-package
	$(Q)$(MAKE) V=$(V) check-flake8

linux-menuconfig: .stamp_linux_depends
	$(print_target_name)
	$(Q)$(MAKE) -C $(OUTPUT_DIR) linux-menuconfig
	$(Q)$(MAKE) -C $(OUTPUT_DIR) linux-update-defconfig

endif # ($(check_inside_docker),n) ########################################

clean-stamps:
	$(print_target_name)
	$(Q)rm -rf .stamp_*

clean: clean-stamps
	$(print_target_name)
	$(Q)rm -rf $(OUTPUT_DIR)

distclean: clean
	$(print_target_name)
	$(Q)rm -rf $(CACHE_COMPILER_DIR)
	$(Q)rm -rf $(CACHE_DOWNLOAD_DIR)

docker-image:
	$(print_target_name)
	$(Q)docker build -t registry.gitlab.com/$(URL_DOCKER_IMAGE):$(date) support/docker
	$(Q)sed -e 's,^image:.*,image: $$CI_REGISTRY/$(URL_DOCKER_IMAGE):$(date),g' -i .gitlab-ci.yml
	@echo And now do:
	@echo docker push registry.gitlab.com/$(URL_DOCKER_IMAGE):$(date)

help:
	@echo "sblkh version $$(git describe --always), Copyright (C) 2023  Ricardo Martincoski"
	@echo "  sblkh comes with ABSOLUTELY NO WARRANTY; for details see file LICENSE."
	@echo "  **sblkh** stands for *sandbox for Linux Kernel hacking*."
	@echo "  SPDX-License-Identifier: GPL-2.0-only"
	@echo
	@echo "Usage:"
	@echo "  make - build the image"
	@echo "  make V=1 <target> - calls the target enabling verbose output"
	@echo "  make test - run runtime tests in the image"
	@echo "  make run - run the image for manual testing (use ctrl+a,x to close qemu)"
	@echo "  make clean - clean the build"
	@echo "  make distclean - 'clean' + clean the caches (download and compile)"
	@echo "  make docker-image - generate a new docker image to be uploaded"
	@echo "  make static-analysis - run all static analysis tools"
	@echo "  make linux-menuconfig - reconfigure the kernel and save the new defconfig"
	@echo
	@echo "Main dependency chain:"
	@echo "  configure -> source -> toolchain -> uboot -> arm-trusted-firmware -> grub2 ->"
	@echo "  -> linux-depends -> linux -> rootfs -> test"
	@echo ""
