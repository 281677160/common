#!/bin/sh /etc/rc.common
# Copyright (C) 2008 OpenWrt.org

START=99

run_FinishIng()
{
	if [[ -f '/etc/webweb.sh' ]]; then
		/etc/webweb.sh
	fi
	if [[ -f '/mnt/network' ]]; then
		cp -Rf /mnt/network /etc/config/network
		uci commit luci
		rm -rf /mnt/network
	fi
	if [[ -f '/etc/FinishIng.sh' ]]; then
		/etc/FinishIng.sh
	fi
	if [[ `grep -c "/tmp/luci-\*cache\*" /etc/crontabs/root` -eq '0' ]]; then
		echo "0 1 * * 1 rm -rf /tmp/luci-*cache* > /dev/null 2>&1" >> /etc/crontabs/root
		/etc/init.d/cron restart
	fi
	if [[ `grep -c "Detectionnetwork" /etc/crontabs/root` -ge '1' ]]; then
		if [[ ! -f '/mnt/Detectionnetwork' ]]; then
			sed -i '/Detectionnetwork/d' /etc/crontabs/root
		fi
	fi
	/etc/init.d/uhttpd restart
	/etc/init.d/dnsmasq restart
	/etc/init.d/firewall restart
	if [[ `grep -c "wan" /etc/config/network` -eq '0' ]]; then
	  /etc/init.d/network restart
	else
	  ifup wan
	fi
}


start() {        
	echo start
	run_FinishIng
}                 
 
stop() {          
	echo stop
	run_FinishIng
}
