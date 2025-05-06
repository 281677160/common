include $(TOPDIR)/rules.mk

PKG_NAME:=auto-scripts
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/auto-scripts
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Automatic First-Boot & Reboot Scripts
endef

define Package/auto-scripts/description
  Embeds two scripts into firmware:
  1. /etc/uci-defaults/99-first-run (runs once on first boot)
  2. /etc/init.d/restart_scripts (runs on every reboot, auto-enabled)
  3. /usr/bin/openwrt (runs openwrt)
  4. /usr/bin/check_network (runs check_network)
  5. /etc/scripts_reboot (runs scripts_reboot)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/auto-scripts/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/99-first-run $(1)/etc/uci-defaults/99-first-run
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/restart_scripts $(1)/etc/init.d/restart_scripts
	$(INSTALL_DIR) $(1)/etc/rc.d
	ln -s ../init.d/restart_scripts $(1)/etc/rc.d/S99restart_scripts
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/openwrt $(1)/usr/bin/openwrt
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/check_network $(1)/usr/bin/check_network
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) ./files/scripts_reboot $(1)/etc/scripts_reboot
endef

$(eval $(call BuildPackage,auto-scripts))
