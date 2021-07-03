#!/bin/sh

sed -i '/coremark.sh/d' /etc/crontabs/root 2>/dev/null
source /etc/openwrt_release
sed -i "s/x86_64/${DISTRIB_TARGET}/g" /etc/banner
rm -rf /etc/webweb.sh
