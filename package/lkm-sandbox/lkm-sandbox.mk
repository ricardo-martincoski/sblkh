################################################################################
#
# lkm-sandbox
#
################################################################################

# do not use newer commits due to licencing inconsistences (GPL v2 or v3?)
LKM_SANDBOX_VERSION = 401414003889b43d41e355ef241599eaddc1e2eb
LKM_SANDBOX_SITE = $(call github,tpiekarski,lkm-sandbox,$(LKM_SANDBOX_VERSION))
LKM_SANDBOX_LICENSE = GPL-2.0+
LKM_SANDBOX_LICENSE_FILES = COPYING

$(eval $(kernel-module))
$(eval $(generic-package))
