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

date := $(shell date +%Y%m%d.%H%M --utc)

.PHONY: default
default: test

.PHONY: test
test:
	$(Q)echo "=== $@ ==="
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
	$(Q)echo "=== $@ ==="
	$(Q)board/qemu/run.sh

.PHONY: clean
clean:
	$(Q)echo "=== $@ ==="
	$(Q)rm -rf $(OUTPUT_DIR)

.PHONY: distclean
distclean: clean
	$(Q)echo "=== $@ ==="
	$(Q)rm -rf $(CACHE_COMPILER_DIR)
	$(Q)rm -rf $(CACHE_DOWNLOAD_DIR)

.PHONY: docker-image
docker-image:
	$(Q)echo "=== $@ ==="
	$(Q)docker build -t registry.gitlab.com/$(URL_DOCKER_IMAGE):$(date) support/docker
	$(Q)sed -e 's,^image:.*,image: $$CI_REGISTRY/$(URL_DOCKER_IMAGE):$(date),g' -i .gitlab-ci.yml
	$(Q)echo And now do:
	$(Q)echo docker push registry.gitlab.com/$(URL_DOCKER_IMAGE):$(date)
