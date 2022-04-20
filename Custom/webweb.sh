#!/bin/bash

touch /etc/crontabs/root

chmod -R 775 /etc/init.d /usr/share

if [[ -f /etc/networkip ]]; then
  chmod +x /etc/networkip
  source /etc/networkip
  rm -rf /etc/networkip
  uci commit network
  uci commit dhcp
  uci commit system
  uci commit luci
  uci commit firewall
  [[ -f /etc/config/ttyd ]] && uci commit ttyd
fi

if [[ `grep -c "x86_64" /etc/openwrt_release` -eq '0' ]]; then
  export DISTRIB_TA="$(grep DISTRIB_TARGET= /etc/openwrt_release |sed "s/'//g" |cut -d "=" -f2)"
  sed -i "s?x86_64?${DISTRIB_TA}?g" /etc/banner
fi

if [[ ! -d /usr/share/AdGuardHome ]] && [[ ! -f /etc/init.d/AdGuardHome ]]; then
  rm -fr /etc/config/AdGuardHome.yaml
  rm -fr /etc/AdGuardHome.yaml
fi

if [[ -f /etc/init.d/ddnsto ]]; then
 /etc/init.d/ddnsto enable
fi

if [[ -f /etc/config/argon ]]; then
  uci set argon.@global[0].bing_background=0
  uci commit argon
fi

if [[ `grep -c "danshui" /etc/opkg/distfeeds.conf` -ge '1' ]]; then
  sed -i '/danshui/d' /etc/opkg/distfeeds.conf
fi
if [[ `grep -c "helloworld" /etc/opkg/distfeeds.conf` -ge '1' ]]; then
  sed -i '/helloworld/d' /etc/opkg/distfeeds.conf
fi
if [[ `grep -c "passwall" /etc/opkg/distfeeds.conf` -ge '1' ]]; then
  sed -i '/passwall/d' /etc/opkg/distfeeds.conf
fi

rm -rf /etc/webweb.sh

exit 0
