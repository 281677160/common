include $(TOPDIR)/rules.mk

PKG_NAME:=auto-scripts
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/auto-scripts
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Automatic Scripts (Compatible with default-settings)
endef

define Package/auto-scripts/install
	# 安装首次启动脚本（唯一文件名）
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/99-first-run $(1)/etc/uci-defaults/99-first-run

	# 安装重启脚本（避免覆盖 default-settings 的服务）
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/auto-reboot-script $(1)/etc/init.d/auto-reboot-script
	$(INSTALL_DIR) $(1)/etc/rc.d
	ln -s ../init.d/auto-reboot-script $(1)/etc/rc.d/S99auto-reboot-script
endef

$(eval $(call BuildPackage,auto-scripts))
