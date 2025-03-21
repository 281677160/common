include $(TOPDIR)/rules.mk

PKG_NAME:=auto-scripts
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/auto-scripts
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Automatic First-Boot & Reboot Scripts
  PKGARCH:=all
endef

define Package/auto-scripts/description
  Embeds two scripts into firmware:
  1. /etc/uci-defaults/99-first-run (runs once on first boot)
  2. /etc/init.d/auto-reboot-script (runs on every reboot, auto-enabled)
endef

define Package/auto-scripts/description
	Language Support Packages.
endef

define Build/Compile
endef

define Package/auto-scripts/install
    $(INSTALL_DIR) $(1)/etc/uci-defaults
    $(INSTALL_BIN) ./files/99-first-run $(1)/etc/uci-defaults/99-first-run
    $(INSTALL_DIR) $(1)/etc/init.d
    $(INSTALL_BIN) ./files/auto-reboot-script $(1)/etc/init.d/auto-reboot-script
endef

$(eval $(call BuildPackage,auto-scripts))
