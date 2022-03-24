#!/bin/bash /etc/rc.common
START=99

run_autoupdate()
{
	local enable
	config_get_bool enable $1 enable
	if [ $enable == "1" ]; then
		local minute
		local hour
		config_get week $1 week
		config_get minute $1 minute
		config_get hour $1 hour
		[ "$week" == 7 ] && week="*"
		sed -i '/AutoUpdate/d' /etc/crontabs/root >/dev/null 2>&1
		echo "$minute $hour * * $week bash /bin/AutoUpdate.sh -u" >> /etc/crontabs/root
	else
		sed -i '/AutoUpdate/d' /etc/crontabs/root >/dev/null 2>&1	
	fi
	if [ -f /bin/AutoUpdate.sh ] && [ -f /bin/openwrt_info ];then
		cus_url="$(uci get autoupdate.@login[0].github)"
                ApAuthor="${cus_url%.git}"
                custom_github_url="${ApAuthor##*com/}"
		current_github_url="$(grep Warehouse= /bin/openwrt_info | cut -d "=" -f2)"
		[[ -n "${custom_github_url}" ]] && {
			[[ "${custom_github_url}" != "${current_github_url}" ]] && {
				sed -i "s?${current_github_url}?${custom_github_url}?g" /bin/openwrt_info
			}
		}
	fi
	/etc/init.d/cron restart
}


start()
{
	config_load autoupdate
	config_foreach run_autoupdate login
}

stop()
{
	sed -i '/AutoUpdate/d' /etc/crontabs/root >/dev/null 2>&1
}

restart()
{
	stop
	start
}
