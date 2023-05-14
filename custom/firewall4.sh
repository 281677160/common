#!/bin/bash

[[ ! -d "Fullconenat" ]] && mkdir -p Fullconenat || rm -rf Fullconenat/*
cd Fullconenat
git clone -b master --depth 1 https://github.com/coolsnowwolf/lede.git lede
git clone -b 22.03 --depth 1 https://github.com/QiuSimons/YAOF YAOF
git clone -b master --depth 1 https://github.com/immortalwrt/immortalwrt.git immortalwrt
git clone -b openwrt-21.02 --depth 1 https://github.com/immortalwrt/immortalwrt.git immortalwrt_21
git clone -b master --depth 1 https://github.com/Lienol/openwrt.git Lienol
cd ../

### Fullcone-NAT 部分 ###
# Patch Kernel 以解决 FullCone 冲突
cp -rf ./Fullconenat/lede/target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch ./target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch
cp -rf ./Fullconenat/lede/target/linux/generic/hack-5.10/982-add-bcm-fullconenat-support.patch ./target/linux/generic/hack-5.10/982-add-bcm-fullconenat-support.patch
# Patch FireWall 以增添 FullCone 功能
# FW4
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
cp -rf ./lede/package/network/utils/iptables/patches/900-bcm-fullconenat.patch ./package/network/utils/iptables/patches/900-bcm-fullconenat.patch
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

rm -rf Fullconenat
