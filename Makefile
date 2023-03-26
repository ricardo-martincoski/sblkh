BASE_DIR := $(shell readlink -f .)
SRC_BUILDROOT_DIR := $(BASE_DIR)/buildroot
OUTPUT_DIR := $(BASE_DIR)/output
URL_DOCKER_IMAGE := ricardomartincoski_opensource/sblkh/sblkh

date := $(shell date +%Y%m%d.%H%M --utc)

.PHONY: default
default: test

.PHONY: test
test:
	$(Q)echo "=== $@ ==="
	$(Q)$(MAKE) \
		O=$(OUTPUT_DIR) \
		-C $(SRC_BUILDROOT_DIR) \
		qemu_arm_ebbr_defconfig

.PHONY: clean
clean:
	$(Q)echo "=== $@ ==="
	$(Q)rm -rf $(OUTPUT_DIR)

.PHONY: docker-image
docker-image:
	$(Q)echo "=== $@ ==="
	$(Q)docker build -t registry.gitlab.com/$(URL_DOCKER_IMAGE):$(date) support/docker
	$(Q)sed -e 's,^image:.*,image: $$CI_REGISTRY/$(URL_DOCKER_IMAGE):$(date),g' -i .gitlab-ci.yml
	$(Q)echo And now do:
	$(Q)echo docker push registry.gitlab.com/$(URL_DOCKER_IMAGE):$(date)
