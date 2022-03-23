#!/bin/bash

chmod -R 775 /etc/init.d /usr/share

[[ ! -f /mnt/network ]] && chmod +x /etc/networkip && source /etc/networkip

cp -Rf /etc/config/network /mnt/network

sed -i '/mp\/luci-/d' /etc/crontabs/root && echo "0 1 * * 1 rm -rf /tmp/luci-*cache* > /dev/null 2>&1" >> /etc/crontabs/root
/etc/init.d/cron restart


if [[ `grep -c "x86_64" /etc/openwrt_release` -eq '0' ]]; then
  DISTRIB_TA="$(grep -i "DISTRIB_TARGET" /etc/openwrt_release |sed "s/'//g" |cut -f2 -d=)"
  sed -i "s#x86_64#${DISTRIB_TA}#g" /etc/banner
fi

if [[ ! -d /usr/share/AdGuardHome ]] && [[ ! -f /etc/init.d/AdGuardHome ]]; then
  rm -fr /etc/config/AdGuardHome.yaml
  rm -fr /etc/AdGuardHome.yaml
fi

if [[ -f /etc/init.d/ddnsto ]]; then
 /etc/init.d/ddnsto enable
fi

if [[ -d /usr/lib/lua/luci/view/themes/argon ]]; then
  uci set argon.@global[0].bing_background=0
  uci commit argon
fi

rm -rf /etc/networkip
rm -rf /etc/webweb.sh
exit 0
