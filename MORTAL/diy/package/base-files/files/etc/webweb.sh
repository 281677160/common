#!/bin/bash

[[ ! -f /mnt/network ]] && chmod +x /etc/networkip && source /etc/networkip

cp -Rf /etc/config/network /mnt/network

if [[ `grep -c "x86_64" /etc/openwrt_release` -eq '0' ]]; then
  source /etc/openwrt_release
  sed -i "s/x86_64/${DISTRIB_TARGET}/g" /etc/banner
fi

echo "0 1 * * 1 rm /tmp/luci-indexcache > /dev/null 2>&1" >> /etc/crontabs/root

if [[ -e /usr/share/AdGuardHome ]] && [[ -e /etc/init.d/AdGuardHome ]]; then
 chmod -R +x /usr/share/AdGuardHome /etc/init.d/AdGuardHome
fi

if [[ ! -e /usr/bin/AdGuardHome ]]; then
rm -fr /etc/config/AdGuardHome.yaml
rm -fr /etc/AdGuardHome.yaml
fi

chmod -R +x /etc/init.d /usr/share

if [[ -e /etc/init.d/ddnsto ]]; then
 chmod +x /etc/init.d/ddnsto
 /etc/init.d/ddnsto enable
fi

uci set argon.@global[0].bing_background=0
uci commit argon

rm -rf /etc/networkip
rm -rf /etc/webweb.sh
exit 0
