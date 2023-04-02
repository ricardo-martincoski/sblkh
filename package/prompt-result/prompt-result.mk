################################################################################
#
# prompt-result
#
################################################################################

define PROMPT_RESULT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(PROMPT_RESULT_PKGDIR)/prompt-result.sh \
		$(TARGET_DIR)/etc/profile.d/prompt-result.sh
endef

$(eval $(generic-package))
