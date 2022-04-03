#!/bin/bash

touch /etc/crontabs/root

chmod -R 775 /etc/init.d /usr/share

[[ ! -f /mnt/network ]] && chmod +x /etc/networkip && source /etc/networkip
uci commit network
uci commit dhcp
uci commit system
uci commit luci
uci commit firewall
[[ -f /etc/config/ttyd ]] && uci commit ttyd

cp -Rf /etc/config/network /mnt/network

sed -i '/mp\/luci-/d' /etc/crontabs/root
echo "0 1 * * 1 rm -rf /tmp/luci-*cache* > /dev/null 2>&1" >> /etc/crontabs/root
echo "*/2 * * * * source /etc/FinishIng.sh > /dev/null 2>&1" >> /etc/crontabs/root
/etc/init.d/cron restart
chmod -R 775 /etc/FinishIng.sh

if [[ `grep -c "x86_64" /etc/openwrt_release` -eq '0' ]]; then
  export DISTRIB_TA="$(grep DISTRIB_TARGET= /etc/openwrt_release |sed "s/'//g" |cut -d "=" -f2)"
  sed -i "s?x86_64?${DISTRIB_TA}?g" /etc/banner
fi

if [[ ! -d /usr/share/AdGuardHome ]] && [[ ! -f /etc/init.d/AdGuardHome ]]; then
  rm -fr /etc/config/AdGuardHome.yaml
  rm -fr /etc/AdGuardHome.yaml
fi

[[ -f /etc/init.d/adguardhome ]] && rm -rf /etc/init.d/adguardhome
[[ -f /etc/config/adguardhome ]] && rm -rf /etc/config/adguardhome
[[ -f /etc/config/adguardhome.yaml ]] && rm -rf /etc/config/adguardhome.yaml

if [[ -f /etc/init.d/ddnsto ]]; then
 /etc/init.d/ddnsto enable
fi

if [[ `grep -c "bing_background" /etc/config/argon` -eq '1' ]]; then
  uci set argon.@global[0].bing_background=0
  uci commit argon
fi

sed -i '/danshui/d' /etc/opkg/distfeeds.conf
sed -i '/helloworld/d' /etc/opkg/distfeeds.conf
sed -i '/passwall/d' /etc/opkg/distfeeds.conf

rm -rf /etc/networkip
rm -rf /etc/webweb.sh
exit 0
