#!/bin/bash

[[ ! -d "Fullconenat" ]] && mkdir -p Fullconenat || rm -rf Fullconenat/*
cd Fullconenat
git clone -b master --depth 1 https://github.com/coolsnowwolf/lede.git lede
git clone -b 22.03 --depth 1 https://github.com/QiuSimons/YAOF YAOF
git clone -b master --depth 1 https://github.com/immortalwrt/immortalwrt.git immortalwrt
git clone -b openwrt-21.02 --depth 1 https://github.com/immortalwrt/immortalwrt.git immortalwrt_21
git clone -b master --depth 1 https://github.com/Lienol/openwrt.git Lienol
git clone -b master --depth 1 https://github.com/openwrt/openwrt.git openwrt_ma
git clone -b master --depth 1 https://github.com/openwrt/luci.git openwrt_luci_ma
git clone -b master --depth 1 https://github.com/nxhack/openwrt-node-packages.git openwrt-node
cd ../

### Fullcone-NAT 部分 ###
# Patch Kernel 以解决 FullCone 冲突
if [[ -d "target/linux/generic/hack-5.10" ]]; then
  cp -rf ./Fullconenat/lede/target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch ./target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch
  cp -rf ./Fullconenat/lede/target/linux/generic/hack-5.10/982-add-bcm-fullconenat-support.patch ./target/linux/generic/hack-5.10/982-add-bcm-fullconenat-support.patch
fi
# Patch FireWall 以增添 FullCone 功能
# FW4
[[ ! -d "package/utils/ucode" ]] && cp -rf ./Fullconenat/immortalwrt/package/utils/ucode ./package/utils/ucode
rm -rf ./package/network/config/firewall4
cp -rf ./Fullconenat/immortalwrt/package/network/config/firewall4 ./package/network/config/firewall4
cp -rf ./Fullconenat/YAOF/PATCH/firewall/990-unconditionally-allow-ct-status-dnat.patch ./package/network/config/firewall4/patches/990-unconditionally-allow-ct-status-dnat.patch
rm -rf ./package/libs/libnftnl
cp -rf ./Fullconenat/immortalwrt/package/libs/libnftnl ./package/libs/libnftnl
rm -rf ./package/network/utils/nftables
cp -rf ./Fullconenat/immortalwrt/package/network/utils/nftables ./package/network/utils/nftables
# FW3
mkdir -p package/network/config/firewall/patches
cp -rf ./Fullconenat/immortalwrt_21/package/network/config/firewall/patches/100-fullconenat.patch ./package/network/config/firewall/patches/100-fullconenat.patch
cp -rf ./Fullconenat/lede/package/network/config/firewall/patches/101-bcm-fullconenat.patch ./package/network/config/firewall/patches/101-bcm-fullconenat.patch
# iptables
cp -rf ./Fullconenat/lede/package/network/utils/iptables/patches/900-bcm-fullconenat.patch ./package/network/utils/iptables/patches/900-bcm-fullconenat.patch
# network
wget -qO - https://github.com/openwrt/openwrt/commit/bbf39d07.patch | patch -p1
# Patch LuCI 以增添 FullCone 开关
pushd feeds/luci
wget -qO- https://github.com/openwrt/luci/commit/471182b2.patch | patch -p1
popd
# FullCone PKG
mkdir -p package/new
git clone --depth 1 https://github.com/fullcone-nat-nftables/nft-fullcone package/new/nft-fullcone
cp -rf ./Fullconenat/Lienol/package/network/utils/fullconenat ./package/new/fullconenat

# 更换 SSL
rm -rf ./package/libs/mbedtls
cp -rf ./Fullconenat/immortalwrt/package/libs/mbedtls ./package/libs/mbedtls
rm -rf ./package/libs/openssl
cp -rf ./Fullconenat/immortalwrt_21/package/libs/openssl ./package/libs/openssl
# fstool
wget -qO - https://github.com/coolsnowwolf/lede/commit/8a4db76.patch | patch -p1

# Dnsmasq
rm -rf ./package/network/services/dnsmasq
cp -rf ./Fullconenat/openwrt_ma/package/network/services/dnsmasq ./package/network/services/dnsmasq
cp -rf ./Fullconenat/openwrt_luci_ma/modules/luci-mod-network/htdocs/luci-static/resources/view/network/dhcp.js ./feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/

# 更换 golang 版本
rm -rf ./feeds/packages/lang/golang
cp -rf ./Fullconenat/openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang

# 更换 Nodejs 版本
rm -rf ./feeds/packages/lang/node
cp -rf ./Fullconenat/openwrt-node/node ./feeds/packages/lang/node
rm -rf ./feeds/packages/lang/node-arduino-firmata
cp -rf ./Fullconenat/openwrt-node/node-arduino-firmata ./feeds/packages/lang/node-arduino-firmata
rm -rf ./feeds/packages/lang/node-cylon
cp -rf ./Fullconenat/openwrt-node/node-cylon ./feeds/packages/lang/node-cylon
rm -rf ./feeds/packages/lang/node-hid
cp -rf ./Fullconenat/openwrt-node/node-hid ./feeds/packages/lang/node-hid
rm -rf ./feeds/packages/lang/node-homebridge
cp -rf ./Fullconenat/openwrt-node/node-homebridge ./feeds/packages/lang/node-homebridge
rm -rf ./feeds/packages/lang/node-serialport
cp -rf ./Fullconenat/openwrt-node/node-serialport ./feeds/packages/lang/node-serialport
rm -rf ./feeds/packages/lang/node-serialport-bindings
cp -rf ./Fullconenat/openwrt-node/node-serialport-bindings ./feeds/packages/lang/node-serialport-bindings
rm -rf ./feeds/packages/lang/node-yarn
cp -rf ./Fullconenat/openwrt-node/node-yarn ./feeds/packages/lang/node-yarn
cp -rf ./Fullconenat/openwrt-node/node-serialport-bindings-cpp ./feeds/packages/lang/node-serialport-bindings-cpp

rm -rf ./Fullconenat
