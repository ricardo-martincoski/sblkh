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

phony_targets_outside_docker := \
	clean \
	distclean \
	docker-image \

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

.PHONY: default $(phony_targets_inside_docker) $(phony_targets_outside_docker)
default: rootfs

ifeq ($(check_inside_docker),n) ########################################

$(phony_targets_inside_docker):
	$(print_target_name_outsize_docker)
	$(Q)utils/docker-run $(MAKE) V=$(V) $@

else # ($(check_inside_docker),n) ########################################

configure:
	$(print_target_name)
	$(Q)$(MAKE) \
		BR2_EXTERNAL=$(SRC_BR2_EXTERNAL_DIR) \
		O=$(OUTPUT_DIR) \
		-C $(SRC_BUILDROOT_DIR) \
		qemu_defconfig

source: configure
	$(print_target_name)
	$(Q)$(BR_MAKE) source

toolchain: source
	$(print_target_name)
	$(Q)$(BR_MAKE) toolchain

uboot: toolchain
	$(print_target_name)
	$(Q)$(BR_MAKE) uboot

arm-trusted-firmware: uboot
	$(print_target_name)
	$(Q)$(BR_MAKE) arm-trusted-firmware

grub2: arm-trusted-firmware
	$(print_target_name)
	$(Q)$(BR_MAKE) grub2

linux-depends: grub2
	$(print_target_name)
	$(Q)$(BR_MAKE) linux-depends

linux: linux-depends
	$(print_target_name)
	$(Q)$(BR_MAKE) linux

rootfs: linux
	$(print_target_name)
	$(Q)$(BR_MAKE) all

run: rootfs
	$(print_target_name)
	$(Q)board/qemu/run.sh

endif # ($(check_inside_docker),n) ########################################

clean:
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
