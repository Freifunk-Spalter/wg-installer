include $(TOPDIR)/rules.mk

PKG_NAME:=wg-installer
PKG_VERSION:=2021.01.25
PKG_RELEASE:=1

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>

include $(INCLUDE_DIR)/package.mk

Build/Compile=

define Package/wg-installer/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Wire-Guard Installer
	URL:=https://github.com/Freifunk-Spalter/wg-installer
	PKGARCH:=all
endef

define Package/wg-installer
	$(call Package/wg-installer/Default)
endef

define Package/wg-installer-server
	$(call Package/wg-installer/Default)
	TITLE+= (server)
	DEPENDS:=+rpcd +uhttpd +uhttpd-mod-ubus +owipcalc
endef

define Package/wg-installer-server/install
	$(INSTALL_DIR) $(1)/usr/share/wginstaller/
	$(INSTALL_BIN) ./wg-server/lib/install_wginstaller_user.sh $(1)/usr/share/wginstaller/install_wginstaller_user.sh
	$(INSTALL_BIN) ./wg-server/lib/wg_functions.sh $(1)/usr/share/wginstaller/wg_functions.sh

	$(INSTALL_DIR) $(1)/usr/libexec/rpcd/
	$(INSTALL_BIN) ./wg-server/wginstaller.sh $(1)/usr/libexec/rpcd/wginstaller

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(CP) ./wg-server/config/wginstaller.json $(1)/usr/share/rpcd/acl.d/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./wg-server/config/wgserver.conf $(1)/etc/config/wgserver
endef

define Package/wg-installer-server/postinst
	#!/bin/sh
	if [ -z $${IPKG_INSTROOT} ] ; then
		. /usr/share/wginstaller/install_wginstaller_user.sh
	fi
endef

define Package/wg-installer-client
	$(call Package/wg-installer/Default)
	TITLE+= (client)
	DEPENDS:=+curl +owipcalc
endef

define Package/wg-installer-client/install
	$(INSTALL_DIR) $(1)/usr/share/wginstaller/
	$(INSTALL_BIN) ./wg-client/lib/rpcd_ubus.sh $(1)/usr/share/wginstaller/rpcd_ubus.sh

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./wg-client/wg-client-installer.sh $(1)/usr/bin/wg-client-installer
endef

$(eval $(call BuildPackage,wg-installer))
$(eval $(call BuildPackage,wg-installer-server))
$(eval $(call BuildPackage,wg-installer-client))