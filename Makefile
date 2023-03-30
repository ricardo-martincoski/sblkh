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

date := $(shell date +%Y%m%d.%H%M --utc)
define print_target_name
	@echo "=== $@ ==="
endef

.PHONY: default
default: test

.PHONY: test
test:
	$(print_target_name)
	$(Q)$(MAKE) \
		BR2_EXTERNAL=$(SRC_BR2_EXTERNAL_DIR) \
		O=$(OUTPUT_DIR) \
		-C $(SRC_BUILDROOT_DIR) \
		qemu_defconfig
	$(Q)$(BR_MAKE) source
	$(Q)$(BR_MAKE) toolchain
	$(Q)$(BR_MAKE) uboot
	$(Q)$(BR_MAKE) arm-trusted-firmware
	$(Q)$(BR_MAKE) grub2
	$(Q)$(BR_MAKE) linux-depends
	$(Q)$(BR_MAKE) linux
	$(Q)$(BR_MAKE) all

.PHONY: run
run: test
	$(print_target_name)
	$(Q)board/qemu/run.sh

.PHONY: clean
clean:
	$(print_target_name)
	$(Q)rm -rf $(OUTPUT_DIR)

.PHONY: distclean
distclean: clean
	$(print_target_name)
	$(Q)rm -rf $(CACHE_COMPILER_DIR)
	$(Q)rm -rf $(CACHE_DOWNLOAD_DIR)

.PHONY: docker-image
docker-image:
	$(print_target_name)
	$(Q)docker build -t registry.gitlab.com/$(URL_DOCKER_IMAGE):$(date) support/docker
	$(Q)sed -e 's,^image:.*,image: $$CI_REGISTRY/$(URL_DOCKER_IMAGE):$(date),g' -i .gitlab-ci.yml
	@echo And now do:
	@echo docker push registry.gitlab.com/$(URL_DOCKER_IMAGE):$(date)
