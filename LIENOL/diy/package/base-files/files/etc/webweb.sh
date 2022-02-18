#!/bin/bash

sed -i '/DISTRIB_REVISION/d' /etc/openwrt_release
echo "DISTRIB_REVISION='Lienol-19.07'" >> /etc/openwrt_release

sed -i 's/<%=pcdata(ver.distversion)%>/<%=pcdata(ver.distversion)%><!--/g' /usr/lib/lua/luci/view/admin_status/index.htm
sed -i 's/(<%=pcdata(ver.luciversion)%>)/(<%=pcdata(ver.luciversion)%>)-->/g' /usr/lib/lua/luci/view/admin_status/index.htm

[[ ! -f /mnt/network ]] && chmod +x /etc/networkip && source /etc/networkip

cp -Rf /etc/config/network /mnt/network

echo "0 1 * * 1 rm /tmp/luci-indexcache > /dev/null 2>&1" >> /etc/crontabs/root

if [[ `grep -c "x86_64" /etc/openwrt_release` -eq '0' ]]; then
  source /etc/openwrt_release
  sed -i "s/x86_64/${DISTRIB_TARGET}/g" /etc/banner
fi

if [[ -e /usr/share/AdGuardHome ]] && [[ -e /etc/init.d/AdGuardHome ]]; then
 chmod -R +x /usr/share/AdGuardHome /etc/init.d/AdGuardHome
fi

if [[ ! -e /usr/bin/AdGuardHome ]]; then
rm -fr /etc/config/AdGuardHome.yaml
rm -fr /etc/AdGuardHome.yaml
fi

chmod -R +x /etc/init.d /usr/share

/etc/init.d/uhttpd restart

if [[ -e /etc/init.d/ddnsto ]]; then
 chmod +x /etc/init.d/ddnsto
 /etc/init.d/ddnsto enable
fi

uci set argon.@global[0].bing_background=0
uci commit argon

rm -rf /etc/networkip
rm -rf /etc/webweb.sh
exit 0
