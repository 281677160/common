#!/bin/sh

if [ -n "$(ls -A "/etc/closedhcp" 2>/dev/null)" ]; then
  sed -i "s/option start '100'/option ignore '1'/g" /etc/config/dhcp
  sed -i '/limit/d' /etc/config/dhcp
  sed -i '/leasetime/d' /etc/config/dhcp
  rm -rf /etc/closedhcp
fi
sed -i '/DISTRIB_REVISION/d' /etc/openwrt_release
echo "DISTRIB_REVISION='19.07'" >> /etc/openwrt_release
source /etc/openwrt_release
sed -i "s/x86_64/${DISTRIB_TARGET}/g" /etc/banner
sed -i 's/<%=pcdata(ver.distversion)%>/<%=pcdata(ver.distversion)%><!--/g' /usr/lib/lua/luci/view/admin_status/index.htm
sed -i 's/(<%=pcdata(ver.luciversion)%>)/(<%=pcdata(ver.luciversion)%>)-->/g' /usr/lib/lua/luci/view/admin_status/index.htm
sed -i '/coremark.sh/d' /etc/crontabs/root
rm -rf /etc/webweb.sh
