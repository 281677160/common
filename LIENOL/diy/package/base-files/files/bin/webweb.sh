#!/bin/bash

sed -i '/DISTRIB_REVISION/d' /etc/openwrt_release
echo "DISTRIB_REVISION='19.07'" >> /etc/openwrt_release

source /etc/openwrt_release
sed -i "s/x86_64/${DISTRIB_TARGET}/g" /etc/banner

sed -i 's/<%=pcdata(ver.distversion)%>/<%=pcdata(ver.distversion)%><!--/g' /usr/lib/lua/luci/view/admin_status/index.htm
sed -i 's/(<%=pcdata(ver.luciversion)%>)/(<%=pcdata(ver.luciversion)%>)-->/g' /usr/lib/lua/luci/view/admin_status/index.htm

sed -i '/coremark.sh/d' /etc/crontabs/root

sed -i 's/<a href/<!--<a href/g' /usr/lib/lua/luci/view/themes/*/footer.htm
sed -i 's/%>)<\/a> \//%>)<\/a> \/-->/g' /usr/lib/lua/luci/view/themes/*/footer.htm

[[ ! -f /mnt/network ]] && chmod +x /bin/networkip && source /bin/networkip

rm -rf /bin/networkip
rm -rf /bin/webweb.sh
exti 0
