#!/bin/bash

if [[ -d "${HOME_PATH}/package/new/luci-app-passwall" ]]; then
  exit 0
fi

cd ${GITHUB_WORKSPACE}
mkdir -p ${HOME_PATH}/package/new
rm -rf  passwall_pkg passwall_luci ssrp
git clone -b packages --depth 1 https://github.com/xiaorouji/openwrt-passwall passwall_pkg
git clone -b luci --depth 1 https://github.com/xiaorouji/openwrt-passwall passwall_luci
git clone -b master --depth 1 https://github.com/fw876/helloworld ssrp

cp -rf ${GITHUB_WORKSPACE}/passwall_luci/luci-app-passwall ${HOME_PATH}/package/new/luci-app-passwall

sed -i 's,iptables-legacy,iptables-nft,g' ${HOME_PATH}/package/new/luci-app-passwall/Makefile

wget -P ${HOME_PATH}/package/new/luci-app-passwall/ https://github.com/QiuSimons/OpenWrt-Add/raw/master/move_2_services.sh
chmod -R 755 ${HOME_PATH}/package/new/luci-app-passwall/move_2_services.sh
cd ${HOME_PATH}/package/new/luci-app-passwall
bash move_2_services.sh

cd ${HOME_PATH}
cp -rf ${GITHUB_WORKSPACE}/passwall_pkg/tcping ${HOME_PATH}/package/new/tcping
cp -rf ${GITHUB_WORKSPACE}/passwall_pkg/trojan-go ${HOME_PATH}/package/new/trojan-go
cp -rf ${GITHUB_WORKSPACE}/passwall_pkg/brook ${HOME_PATH}/package/new/brook
cp -rf ${GITHUB_WORKSPACE}/passwall_pkg/ssocks ${HOME_PATH}/package/new/ssocks
cp -rf ${GITHUB_WORKSPACE}/passwall_pkg/microsocks ${HOME_PATH}/package/new/microsocks
cp -rf ${GITHUB_WORKSPACE}/passwall_pkg/dns2socks ${HOME_PATH}/package/new/dns2socks
cp -rf ${GITHUB_WORKSPACE}/passwall_pkg/ipt2socks ${HOME_PATH}/package/new/ipt2socks
cp -rf ${GITHUB_WORKSPACE}/passwall_pkg/pdnsd-alt ${HOME_PATH}/package/new/pdnsd-alt
cp -rf ${GITHUB_WORKSPACE}/passwall_pkg/trojan-plus ${HOME_PATH}/package/new/trojan-plus
cp -rf ${GITHUB_WORKSPACE}/passwall_pkg/xray-plugin ${HOME_PATH}/package/new/xray-plugin
# Passwall 白名单
echo '
teamviewer.com
epicgames.com
dangdang.com
account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn
' >> ${HOME_PATH}/package/new/luci-app-passwall/root/usr/share/passwall/rules/direct_host

cd ${HOME_PATH}
rm -rf ${HOME_PATH}/feeds/packages/net/shadowsocks-libev
svn co https://github.com/coolsnowwolf/packages/trunk/net/shadowsocks-libev ${HOME_PATH}/package/new/shadowsocks-libev
cp -rf ${GITHUB_WORKSPACE}/ssrp/redsocks2 ${HOME_PATH}/package/new/redsocks2
cp -rf ${GITHUB_WORKSPACE}/ssrp/chinadns-ng ${HOME_PATH}/package/new/chinadns-ng
cp -rf ${GITHUB_WORKSPACE}/ssrp/trojan ${HOME_PATH}/package/new/trojan
cp -rf ${GITHUB_WORKSPACE}/ssrp/tcping ${HOME_PATH}/package/new/tcping
cp -rf ${GITHUB_WORKSPACE}/ssrp/dns2tcp ${HOME_PATH}/package/new/dns2tcp
cp -rf ${GITHUB_WORKSPACE}/ssrp/gn ${HOME_PATH}/package/new/gn
cp -rf ${GITHUB_WORKSPACE}/ssrp/shadowsocksr-libev ${HOME_PATH}/package/new/shadowsocksr-libev
cp -rf ${GITHUB_WORKSPACE}/ssrp/simple-obfs ${HOME_PATH}/package/new/simple-obfs
cp -rf ${GITHUB_WORKSPACE}/ssrp/naiveproxy ${HOME_PATH}/package/new/naiveproxy
cp -rf ${GITHUB_WORKSPACE}/ssrp/v2ray-core ${HOME_PATH}/package/new/v2ray-core
cp -rf ${GITHUB_WORKSPACE}/ssrp/hysteria ${HOME_PATH}/package/new/hysteria
rm -rf ${HOME_PATH}/feeds/packages/net/xray-core
cp -rf ${GITHUB_WORKSPACE}/ssrp/xray-core ${HOME_PATH}/package/new/xray-core
cp -rf ${GITHUB_WORKSPACE}/ssrp/v2ray-plugin ${HOME_PATH}/package/new/v2ray-plugin
cp -rf ${GITHUB_WORKSPACE}/ssrp/shadowsocks-rust ${HOME_PATH}/package/new/shadowsocks-rust
cp -rf ${GITHUB_WORKSPACE}/ssrp/lua-neturl ${HOME_PATH}/package/new/lua-neturl
rm -rf ${HOME_PATH}/feeds/packages/net/kcptun
svn co https://github.com/immortalwrt/packages/trunk/net/kcptun ${HOME_PATH}/feeds/packages/net/kcptun
ln -sf ../../../feeds/packages/net/kcptun ./package/feeds/packages/kcptun
# ShadowsocksR Plus+
cp -rf ${GITHUB_WORKSPACE}/ssrp/luci-app-ssr-plus ${HOME_PATH}/package/new/luci-app-ssr-plus
cd ${HOME_PATH}/package/new
wget -qO - https://github.com/fw876/helloworld/commit/5bbf6e7.patch | patch -p1

cd ${GITHUB_WORKSPACE}
rm -rf  passwall_pkg passwall_luci ssrp
exit 0
