#!/bin/bash

sed -i '/luciname/d' /usr/lib/lua/luci/version.lua
sed -i '/luciversion/d' /usr/lib/lua/luci/version.lua

sed -i 's/<a href/<!--<a href/g' /usr/lib/lua/luci/view/themes/*/footer.htm
sed -i 's/%>)<\/a> \//%>)<\/a> \/-->/g' /usr/lib/lua/luci/view/themes/*/footer.htm

[[ ! -f /mnt/network ]] && chmod +x /bin/networkip && source /bin/networkip

if [[ `grep -c "x86" /etc/openwrt_release` -eq '0' ]]; then
  source /etc/openwrt_release
  sed -i "s/x86_64/${DISTRIB_TARGET}/g" /etc/banner
fi

cp -Rf /etc/config/network /mnt/network

rm -rf /bin/networkip
rm -rf /bin/webweb.sh
exit 0
