################################################################################
#
# example-driver
#
################################################################################

# source included in sblkh
EXAMPLE_DRIVER_LICENSE = GPL-2.0
EXAMPLE_DRIVER_LICENSE_FILES = LICENSE
EXAMPLE_SOURCES = $(EXAMPLE_DRIVER_PKGDIR)/*.c $(EXAMPLE_DRIVER_PKGDIR)/Kbuild

define EXAMPLE_DRIVER_EXTRACT_CMDS
	cp $(EXAMPLE_SOURCES) $(@D)
endef

.PHONY: example-driver-checkpatch.pl
example-driver-checkpatch.pl: linux-extract
	$(LINUX_DIR)/scripts/checkpatch.pl --no-tree -f $(EXAMPLE_SOURCES)

$(eval $(kernel-module))
$(eval $(generic-package))
