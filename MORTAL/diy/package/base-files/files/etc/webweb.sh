#!/bin/bash

sleep 3

sed -i 's/<a href/<!--<a href/g' /usr/lib/lua/luci/view/themes/*/footer.htm
sed -i 's/%>)<\/a> \//%>)<\/a> \/-->/g' /usr/lib/lua/luci/view/themes/*/footer.htm

sed -i '/coremark.sh/d' /etc/crontabs/root

[[ ! -f /mnt/network ]] && chmod +x /etc/networkip && source /etc/networkip

cp -Rf /etc/config/network /mnt/network

if [[ `grep -c "x86_64" /etc/openwrt_release` -eq '0' ]]; then
  source /etc/openwrt_release
  sed -i "s/x86_64/${DISTRIB_TARGET}/g" /etc/banner
fi

if [[ -e /usr/share/AdGuardHome ]] && [[ -e /etc/init.d/AdGuardHome ]]; then
 chmod -R +x /usr/share/AdGuardHome /etc/init.d/AdGuardHome
fi

rm -rf /etc/networkip
rm -rf /etc/webweb.sh
exit 0
