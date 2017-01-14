$(call PKG_INIT_BIN, f2ebdc58bb)
$(PKG)_SOURCE:=tools-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git://github.com/lnslbrty/tools.git
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/tools-$($(PKG)_VERSION)

$(PKG)_BINARIES_ALL := aes asciihexer dummyshell suidcmd
ifeq ($(strip $(FREETZ_PACKAGE_CUSTOM_TOOLS_gol)),y)
$(PKG)_BINARIES_ALL += gol
$(PKG)_DEPENDS_ON += ncurses
endif
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
$(PKG)_SUIDCMDS := $(subst ",,$(FREETZ_PACKAGE_$(PKG)_SUIDCMDS))
$(PKG)_SUIDCMDS_FINAL := $(shell echo '$(CUSTOM_TOOLS_SUIDCMDS)' | sed -n 's|\([^,]*\)*|"\1"|gp')


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)


$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	sed -i 's|\(#define SUIDCMD_CMDS\).*|\1 $(CUSTOM_TOOLS_SUIDCMDS_FINAL)|g' $(CUSTOM_TOOLS_DIR)/config.h
	$(SUBMAKE) -C $(CUSTOM_TOOLS_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="-Wall $(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(CUSTOM_TOOLS_BINARIES)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_DEST_DIR)/usr/bin/suidcmd: $($(PKG)_DIR)/suidcmd
	$(INSTALL_BINARY_STRIP)
	chmod +s $(CUSTOM_TOOLS_DEST_DIR)/usr/bin/suidcmd
	@echo 'Targets: $(CUSTOM_TOOLS_SUIDCMDS)'
	export IFS=',' ; \
	for cmd in `echo '$(CUSTOM_TOOLS_SUIDCMDS)'`; do \
		bname="suid-`basename "$${cmd}"`"; \
		dname="/usr/bin"; \
		mkdir -p "$(CUSTOM_TOOLS_DEST_DIR)/$${dname}"; \
		ln -s "/usr/bin/suidcmd" "$(CUSTOM_TOOLS_DEST_DIR)/$${dname}/$${bname}"; \
	done

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CUSTOM_TOOLS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CUSTOM_TOOLS_BINARIES_ALL:%=$(CUSTOM_TOOLS_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)
