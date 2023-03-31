#!/bin/bash

if [[ `grep -c "KernelPackage/netlink-diag" package/kernel/linux/modules/netsupport.mk` -eq '0' ]]; then
echo "
define KernelPackage/netlink-diag
  SUBMENU:=\$(NETWORK_SUPPORT_MENU)
  TITLE:=Netlink diag support for ss utility
  KCONFIG:=CONFIG_NETLINK_DIAG
  FILES:=\$(LINUX_DIR)/net/netlink/netlink_diag.ko
  AUTOLOAD:=\$(call AutoLoad,31,netlink-diag)
endef

define KernelPackage/netlink-diag/description
 Netlink diag is a module made for use with iproute2's ss utility
endef

\$(eval \$(call KernelPackage,netlink-diag))
" >>  package/kernel/linux/modules/netsupport.mk
fi

if [[ `grep -c "KernelPackage/inet-diag" package/kernel/linux/modules/netsupport.mk` -eq '0' ]]; then
echo "
define KernelPackage/inet-diag
  SUBMENU:=\$(NETWORK_SUPPORT_MENU)
  TITLE:=INET diag support for ss utility
  KCONFIG:= \\
	CONFIG_INET_DIAG \\
	CONFIG_INET_TCP_DIAG \\
	CONFIG_INET_UDP_DIAG \\
	CONFIG_INET_RAW_DIAG \\
	CONFIG_INET_DIAG_DESTROY=n
  FILES:= \\
	\$(LINUX_DIR)/net/ipv4/inet_diag.ko \\
	\$(LINUX_DIR)/net/ipv4/tcp_diag.ko \\
	\$(LINUX_DIR)/net/ipv4/udp_diag.ko \\
	\$(LINUX_DIR)/net/ipv4/raw_diag.ko
  AUTOLOAD:=\$(call AutoLoad,31,inet_diag tcp_diag udp_diag raw_diag)
endef

define KernelPackage/inet-diag/description
Support for INET (TCP, DCCP, etc) socket monitoring interface used by
native Linux tools such as ss.
endef

\$(eval \$(call KernelPackage,inet-diag))
" >>  package/kernel/linux/modules/netsupport.mk
fi

if [[ `grep -c "kmod-netlink-diag" package/network/utils/iproute2/Makefile` -eq '0' ]]; then
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/LIENOL/19.07/package/network/utils/iproute2/netlink_diag > netlink_diag
  sed -i "/Socket statistics utility/a\danshui" package/network/utils/iproute2/Makefile
  line_cnt="$(cat ./netlink_diag)"
  sed -i "s/danshui/${line_cnt}/g" package/network/utils/iproute2/Makefile
  let Size="$(nl -ba package/network/utils/iproute2/Makefile |grep "Socket statistics utility" |sed 's/^[ ]*//g'| awk '{print $1}')+2"
  sed -i "${Size}d" package/network/utils/iproute2/Makefile
  rm -rf ./netlink_diag
fi

exit 0
