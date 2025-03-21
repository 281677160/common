#!/bin/bash

cd ${HOME_PATH}

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

if [[ `grep -c "KernelPackage/nf-tproxy" package/kernel/linux/modules/netfilter.mk` -eq '0' ]]; then
echo "
define KernelPackage/nf-tproxy
  SUBMENU:=\$(NF_MENU)
  TITLE:=Netfilter tproxy support
  KCONFIG:= \$(KCONFIG_NF_TPROXY)
  FILES:=\$(foreach mod,\$(NF_TPROXY-m),\$(LINUX_DIR)/net/\$(mod).ko)
  AUTOLOAD:=\$(call AutoProbe,\$(notdir \$(NF_TPROXY-m)))
endef

\$(eval \$(call KernelPackage,nf-tproxy))

" >>  package/kernel/linux/modules/netfilter.mk
fi

if [[ `grep -c "KernelPackage/nft-tproxy" package/kernel/linux/modules/netfilter.mk` -eq '0' ]]; then
echo "
define KernelPackage/nft-tproxy
  SUBMENU:=\$(NF_MENU)
  TITLE:=Netfilter nf_tables tproxy support
  DEPENDS:=+kmod-nft-core +kmod-nf-tproxy +kmod-nf-conntrack
  FILES:=\$(foreach mod,\$(NFT_TPROXY-m),\$(LINUX_DIR)/net/\$(mod).ko)
  AUTOLOAD:=\$(call AutoProbe,\$(notdir \$(NFT_TPROXY-m)))
  KCONFIG:=\$(KCONFIG_NFT_TPROXY)
endef

\$(eval \$(call KernelPackage,nft-tproxy))

" >>  package/kernel/linux/modules/netfilter.mk
fi

if [[ `grep -c "KernelPackage/nft-compat" package/kernel/linux/modules/netfilter.mk` -eq '0' ]]; then
echo "
define KernelPackage/nft-compat
  SUBMENU:=\$(NF_MENU)
  TITLE:=Netfilter nf_tables compat support
  DEPENDS:=+kmod-nft-core +kmod-nf-ipt
  FILES:=\$(foreach mod,\$(NFT_COMPAT-m),\$(LINUX_DIR)/net/\$(mod).ko)
  AUTOLOAD:=\$(call AutoProbe,\$(notdir \$(NFT_COMPAT-m)))
  KCONFIG:=\$(KCONFIG_NFT_COMPAT)
endef

\$(eval \$(call KernelPackage,nft-compat))
" >>  package/kernel/linux/modules/netfilter.mk
fi

if [[ `grep -c "nft_tproxy" include/netfilter.mk` -eq '0' ]]; then
  sed -i '344i\$(eval \$(if \$(NF_KMOD),\$(call nf_add,NFT_TPROXY,CONFIG_NFT_TPROXY, \$(P_XT)nft_tproxy),))' include/netfilter.mk
fi

iproute1="package/network/utils/iproute2/Makefile"
if [[ `grep -c "kmod-netlink-diag" ${iproute1}` -eq '0' ]] && [[ `grep -c "Socket statistics utility" ${iproute1}` -eq '1' ]]; then
  ax="$(grep -n "Socket statistics utility" -A 1 ${iproute1} |awk 'END {print}' |grep -Eo [0-9]+)"
  sed -i "${ax}s?.*?  DEPENDS:=+libnl-tiny +(PACKAGE_devlink||PACKAGE_rdma):libmnl +(PACKAGE_tc||PACKAGE_ip-full):libelf +PACKAGE_ip-full:libcap +kmod-netlink-diag?" ${iproute1}
fi
