#!/bin/sh

sed -i '/coremark.sh/d' /etc/crontabs/root 2>/dev/null
if [ -n "$(ls -A "/etc/closedhcp" 2>/dev/null)" ]; then
  sed -i "s/option start '100'/option ignore '1'/g" /etc/config/dhcp
  sed -i '/limit/d' /etc/config/dhcp
  sed -i '/leasetime/d' /etc/config/dhcp
  rm -rf /etc/closedhcp
fi
source /etc/openwrt_release
sed -i "s/x86_64/${DISTRIB_ARCH}/g" /etc/banner
sed -i '/luciname/d' /usr/lib/lua/luci/version.lua
sed -i '/luciversion/d' /usr/lib/lua/luci/version.lua
rm -rf /etc/webweb.sh
