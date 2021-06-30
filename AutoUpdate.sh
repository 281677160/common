#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoUpdate for Openwrt

Version=V5.9

Shell_Helper() {
cat <<EOF

更新参数:
		bash /bin/AutoUpdate.sh				[保留配置更新]
		bash /bin/AutoUpdate.sh	-n			[不保留配置更新]
		bash /bin/AutoUpdate.sh	-g			[更改其他作者固件，不保留配置更新]
			
其    他:
		bash /bin/AutoUpdate.sh	-c			[更换检查更新以及固件下载的Github地址]
		bash /bin/AutoUpdate.sh	-b		        [x86设备 更改引导格式设置]
		bash /bin/AutoUpdate.sh	-t			[执行测试模式(只运行,不安装,查看更新固件操作流程)]
		bash /bin/AutoUpdate.sh	-l			[列出所有更新固件相关信息]
		bash /bin/AutoUpdate.sh	-h			[列出命令使用帮助信息]
	
EOF
exit 1
}
List_Info() {
cat <<EOF

/overlay 可用:		${Overlay_Available}
/tmp 可用:		${TMP_Available}M
固件下载位置:		${Download_Path}
当前设备:		${CURRENT_Device}
默认设备:		${DEFAULT_Device}
当前固件版本:		${CURRENT_Version}
Github 地址:		${Github}
解析 API 地址:		${Github_Tags}
固件下载地址:		${Github_Release}
固件作者:		${Author}
作者仓库:		${CangKu}
固件名称:		${LUCI_Name}-${CURRENT_Version}${Firmware_SFX}
固件格式:		${Firmware_GESHI}
EOF
[[ "${DEFAULT_Device}" == x86-64 ]] && {
	echo "GZIP压缩:		${Compressed_Firmware}"
	echo "引导模式:		${EFI_Mode}"
	echo
} || {
	echo
}
exit 0
}
[ -f /etc/openwrt_info ] && chmod +x /etc/openwrt_info
[ -f /etc/openwrt_info ] && source /etc/openwrt_info || {
	TIME r "未检测到更新插件所需文件,无法运行更新程序!"
	exit 1
}
GengGai_Install() {
[ ! -d ${Download_Path} ] && mkdir -p ${Download_Path}
wget -q --timeout 5 ${Github_Tags} -O ${Download_Path}/Github_Tags
[[ ! $? == 0 ]] && {
	TIME r "获取固件版本信息失败,请检测网络是否翻墙或更换节点再尝试!"
	exit 1
}
source /etc/openwrt_info
Kernel="$(egrep -o "[0-9]+\.[0-9]+\.[0-9]+" /usr/lib/opkg/info/kernel.control)"
case ${DEFAULT_Device} in
x86-64)
	[ -f /etc/openwrt_boot ] && {
		export BOOT_Type="-$(cat /etc/openwrt_boot)"
	} || {
		[ -d /sys/firmware/efi ] && {
			export BOOT_Type="-UEFI"
		} || export BOOT_Type="-Legacy"
	}
	[[ "${Firmware_Type}" == img.gz ]] && {
		export Firmware_SFX="${BOOT_Type}.img.gz"
	} || {
		export Firmware_SFX="${BOOT_Type}.img"
	}
;;
*)
	export Firmware_SFX=".${Firmware_Type}"
esac
TIME h "执行：转换成其他源码固件"
echo
if [[ "${REPO_Name}" == "lede" ]]; then
	lienol_Device="19.07-lienol-${DEFAULT_Device}.*${Firmware_SFX}"
	if [[ `cat ${Download_Path}/Github_Tags | grep -c "${lienol_Device}"` -ge '1' ]]; then
		TIME z "请注意：选择更改其他源码固件后立即执行不保留配置安装固件"
		TIME y "您当前固件为：${REPO_Name} ${Luci_Edition} ${Kernel} 内核版!"
	else
		TIME r "没有检测到有其他作者相同机型的固件版本或者固件格式不相同!"
		echo
		exit 1
	fi
fi
if [[ "${REPO_Name}" == "lienol" ]]; then
	lede_Device="18.06-lede-${DEFAULT_Device}.*${Firmware_SFX}"
	if [[ `cat ${Download_Path}/Github_Tags | grep -c "${lede_Device}"` -ge '1' ]]; then
		TIME z "请注意：选择更改其他源码固件后立即执行不保留配置安装固件"
		TIME y "您当前固件为：${REPO_Name} ${Luci_Edition} ${Kernel} 内核版!"
	else
		TIME r "没有检测到有其他作者相同机型的固件版本或者固件格式不相同!"
		echo
		exit 1
	fi
fi
echo
echo
if [[ "${REPO_Name}" == "lede" ]]; then
	TIME B " 1. 转换成 Lienol 19.07 其他内核版本?"
	Luci_Edition="19.07"
	CURRENT_Version="lienol-${DEFAULT_Device}-202106010101"
	Egrep_Firmware="19.07-lienol-${DEFAULT_Device}"
	LUCI_Name="19.07"
	REPO_Name="lienol"

else
	TIME B " 1. 转换成 Lede 18.06 其他内核版本?"
	Luci_Edition="18.06"
	CURRENT_Version="lede-${DEFAULT_Device}-202106010101"
	Egrep_Firmware="18.06-lede-${DEFAULT_Device}"
	LUCI_Name="18.06"
	REPO_Name="lede"

fi
echo
TIME B " 2. 退出固件转换程序?"
echo
echo
while :; do
TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
echo
read -p "输入您的选择： " CHOOSE
case $CHOOSE in
	1)
		cat >/etc/openwrt_info <<-EOF
		Github=${Github}
		Author=${Author}
		CangKu=${CangKu}
		Luci_Edition=${Luci_Edition}
		CURRENT_Version=${CURRENT_Version}
		DEFAULT_Device=${DEFAULT_Device}
		Firmware_Type=${Firmware_Type}
		LUCI_Name=${LUCI_Name}
		REPO_Name=${REPO_Name}
		Github_Release=${Github_Release}
		Github_Tags=${Github_Tags}
		Egrep_Firmware=${Egrep_Firmware}
		Download_Path=${Download_Path}
		EOF
		TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
		sleep 5
		bash /bin/AutoUpdate.sh	-s
	break
	;;
	2)
		TIME r "您退出了固件转换程序"
		echo
		sleep 2
		exit 0
	;;
esac
done
}
export Input_Option=$1
export Input_Other=$2
export Overlay_Available="$(df -h | grep ":/overlay" | awk '{print $4}' | awk 'NR==1')"
rm -rf "${Download_Path}" && TMP_Available="$(df -m | grep "/tmp" | awk '{print $4}' | awk 'NR==1' | awk -F. '{print $1}')"
[ ! -d "${Download_Path}" ] && mkdir -p ${Download_Path}
opkg list | awk '{print $1}' > ${Download_Path}/Installed_PKG_List
TIME() {
	[ ! -f /tmp/AutoUpdate.log ] && touch ${Download_Path}/AutoUpdate.log
	[[ -z "$1" ]] && {
		echo -ne "\n\e[36m[$(date "+%H:%M:%S")]\e[0m "
	} || {
	case $1 in
		r) export Color="\e[31;1m";;
		g) export Color="\e[32m";;
		b) export Color="\e[34m";;
		B) export Color="\e[34;1m";;
		y) export Color="\e[33m";;
		z) export Color="\e[35;1m";;
		h) export Color="\e[36;1m";;
	esac
		[[ $# -lt 2 ]] && {
			echo -e "\n\e[36m[$(date "+%H:%M:%S")]\e[0m ${1}"
			echo "[$(date "+%H:%M:%S")] ${1}" >> ${Download_Path}/AutoUpdate.log
		} || {
			echo -e "\n\e[36m[$(date "+%H:%M:%S")]\e[0m ${Color}${2}\e[0m"
			echo "[$(date "+%H:%M:%S")] ${2}" >> ${Download_Path}/AutoUpdate.log
		}
	}
}
case ${DEFAULT_Device} in
x86-64)
	[[ -z "${Firmware_Type}" ]] && export Firmware_Type=img
	[[ "${Firmware_Type}" == img.gz ]] && {
		export Compressed_Firmware="YES"
	} || export Compressed_Firmware="NO"
	[ -f /etc/openwrt_boot ] && {
		export BOOT_Type="-$(cat /etc/openwrt_boot)"
	} || {
		[ -d /sys/firmware/efi ] && {
			export BOOT_Type="-UEFI"
		} || export BOOT_Type="-Legacy"
	}
	case ${BOOT_Type} in
	-Legacy)
		export EFI_Mode="Legacy"
	;;
	-UEFI)
		export EFI_Mode="UEFI"
	;;
	esac
	export CURRENT_Des="$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')"
	export CURRENT_Device="${CURRENT_Des} (x86-64)"
  	export Firmware_SFX="${BOOT_Type}.${Firmware_Type}"
  	export Firmware_GESHI=".${Firmware_Type}"
;;
*)
	export CURRENT_Device="$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')"
	export Firmware_SFX=".${Firmware_Type}"
  	export Firmware_GESHI=".${Firmware_Type}"
	[[ -z ${Firmware_SFX} ]] && export Firmware_SFX=".bin"
esac
CURRENT_Ver="${CURRENT_Version}${BOOT_Type}"
cd /etc
clear && echo "Openwrt-AutoUpdate Script ${Version}"
echo
if [[ -z "${Input_Option}" ]];then
	export Upgrade_Options="-c"
	TIME g "执行: 保留配置更新固件[静默模式]"
else
	case ${Input_Option} in
	-t | -n | -f | -u | -N | -s)
		case ${Input_Option} in
		-t)
			Input_Other="-t"
			TIME h "执行: 测试模式"
			TIME g "测试模式(只运行,不安装,查看更新固件操作流程是否正确)"
		;;

		-n | -N)
			export Upgrade_Options="-n"
			TIME h "执行: 更新固件(不保留配置)"
		;;

		-s)
			export Upgrade_Options="-F -n"
			TIME h "执行: 强制更新固件(不保留配置)"
		;;

		-u)
			export AutoUpdate_Mode=1
			export Upgrade_Options="-c"
		;;
		esac
	;;
	-c)
			source /etc/openwrt_info
			TIME h "执行：更换[Github地址]操作"
			TIME y "地址格式：https://github.com/帐号/仓库"
			TIME z  "正确地址示例：https://github.com/281677160/AutoBuild-OpenWrt"
			TIME h  "现在所用地址为：${Github}"
			echo
			read -p "请输入新的Github地址：" Input_Other
			Input_Other="${Input_Other:-"$Github"}"
			Github_uci=$(uci get autoupdate.@login[0].github 2>/dev/null)
			[[ -n "${Github_uci}" ]] && [[ "${Github_uci}" != "${Input_Other}" ]] && {
				uci set autoupdate.@login[0].github=${Input_Other}
				uci commit autoupdate
				TIME y "Github 地址已更换为: ${Input_Other}"
				TIME y "UCI 设置已更新!"
				echo
			}
			Input_Other="${Input_Other:-"$Github"}"
			[[ "${Github}" != "${Input_Other}" ]] && {
				sed -i "s?${Github}?${Input_Other}?g" /etc/openwrt_info
				unset Input_Other
				exit 0
			} || {
				TIME g "INPUT: ${Input_Other}"
				TIME r "输入的 Github 地址相同,无需修改!"
				echo
				exit 1
			}
	;;
	-l | -list)
		List_Info
	;;
	-h | -help)
		Shell_Helper
	;;
	-g)
		GengGai_Install	
	;;
	-b)
		TIME h "执行：引导格式更改操作"
		echo
		TIME r "警告：更改引导格式有更新固件时不能安装固件的风险,请慎重！"
		TIME h "爱快虚拟机的请勿使用,因爱快虚拟机只支持Legacy引导格式!"
		TIME z "请注意：选择更改引导模式后会立即执行不保留配置升级固件!"
		[ -f /etc/openwrt_boot ] && {
			export x86_64_Boot="$(cat /etc/openwrt_boot)"
			TIME y "您现在的引导模式为：${x86_64_Boot}"
		} || {
			[ -d /sys/firmware/efi ] && {
				export x86_64_Boot="UEFI"
				TIME y "您现在的引导模式为：${x86_64_Boot}"
			} || export x86_64_Boot="Legacy"
			TIME y "您现在的引导模式为：${x86_64_Boot}"
		}
		echo
		echo
		[[ "${x86_64_Boot}" == "UEFI" ]] && {
			TIME B " 1. 强制改为[Legacy引导格式]?"
			EFI_Mode="Legacy"
		} || {
			TIME B " 1. 强制改为[UEFI引导格式]?"
			EFI_Mode="UEFI"
		}
		TIME B " 2. 退出引导更改程序?"
		echo
		echo
		while :; do
		TIME g "请选择序列号[ 1、2 ]输入,然后回车确认您的选择！"
		echo
		read -p "请输入您的选择： " YDGS
		case $YDGS in
			1)
				source /etc/openwrt_info
				echo "${EFI_Mode}" > /etc/openwrt_boot
				sed -i '/openwrt_boot/d' /etc/sysupgrade.conf
				echo -e "\n/etc/openwrt_boot" >> /etc/sysupgrade.conf
				TIME y "固件引导方式已指定为: ${EFI_Mode}!"
				sed -i '/CURRENT_Version/d' /etc/openwrt_info > /dev/null 2>&1
				echo -e "\nCURRENT_Version=${REPO_Name}-${DEFAULT_Device}-202106010101" >> /etc/openwrt_info
				TIME y "3秒后开始更新固件，请稍后...!"
				echo
				sleep 3
				bash /bin/AutoUpdate.sh -s
			break
			;;
			2)
				TIME r "您选择了退出更改程序"
				echo
				exit 0
			;;
		esac
		done	
	;;
	*)
		echo -e "\nERROR INPUT: [$*]"
		Shell_Helper
	;;
	esac
fi
TIME b "检测网络环境中,请稍后..."
if [[ "$(cat ${Download_Path}/Installed_PKG_List)" =~ curl ]];then
	export Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
	if [ ! "$Google_Check" == 301 ];then
		TIME z "网络检测失败,因Github现在也筑墙了,请先使用梯子翻墙再来尝试!"
		sleep 2
		exit 1
	else
		TIME y "网络检测成功,您的梯子翻墙成功！"
	fi
fi
[[ -z ${CURRENT_Version} ]] && TIME r "本地固件版本获取失败,请检查/etc/openwrt_info文件的值!" && EXIT 1
[[ -z ${Github} ]] && TIME r "Github地址获取失败,请检查/etc/openwrt_info文件的值!" && EXIT 1
[[ -z ${Github_Release} ]] && TIME r "固件下载地址获取失败,请检查/etc/openwrt_info文件的值!" && EXIT 1
[[ -z ${Github_Tags} ]] && TIME r "解析 API 地址获取失败,请检查/etc/openwrt_info文件的值!" && EXIT 1
[[ -z ${Firmware_Type} ]] && TIME r "固件后缀获取失败,请检查/etc/openwrt_info文件的值!" && EXIT 1
TIME g "正在获取固件版本信息..."
[ ! -d ${Download_Path} ] && mkdir -p ${Download_Path}
wget -q --timeout 5 ${Github_Tags} -O ${Download_Path}/Github_Tags
[[ ! $? == 0 ]] && {
	TIME r "获取固件版本信息失败,请检测网络是否翻墙或更换节点再尝试!"
	exit 1
}
TIME g "正在比对云端固件和本地安装固件版本..."
export CLOUD_Firmware="$(egrep -o "${Egrep_Firmware}-[0-9]+${Firmware_SFX}" ${Download_Path}/Github_Tags | awk 'END {print}')"
export CLOUD_Version="$(echo ${CLOUD_Firmware} | egrep -o "${REPO_Name}-${DEFAULT_Device}-[0-9]+${BOOT_Type}")"
[[ -z "${CLOUD_Version}" ]] && {
	TIME r "比对固件版本失败!"
	exit 1
}
export Firmware_Name="$(echo ${CLOUD_Firmware} | egrep -o "${Egrep_Firmware}-[0-9]+")"
export Firmware="${CLOUD_Firmware}"
let X=$(grep -n "${Firmware}" ${Download_Path}/Github_Tags | tail -1 | cut -d : -f 1)-4
let CLOUD_Firmware_Size=$(sed -n "${X}p" ${Download_Path}/Github_Tags | egrep -o "[0-9]+" | awk '{print ($1)/1048576}' | awk -F. '{print $1}')+1
echo -e "\n本地版本：${CURRENT_Ver}"
echo "云端版本：${CLOUD_Version}"	
[[ "${TMP_Available}" -lt "${CLOUD_Firmware_Size}" ]] && {
	TIME g "tmp 剩余空间: ${TMP_Available}M"
	TIME r "tmp空间不足[${CLOUD_Firmware_Size}M],不够下载固件所需,请清理tmp空间或者增加运行内存!"
	echo
	exit 1
}
if [[ ! "${Force_Update}" == 1 ]];then
  	if [[ "${CURRENT_Version}" -gt "${CLOUD_Version}" ]];then
		TIME r "检测到有可更新的固件版本,立即更新固件!"
	fi
  	if [[ "${CURRENT_Version}" -eq "${CLOUD_Version}" ]];then
		[[ "${AutoUpdate_Mode}" == 1 ]] && exit 0
		TIME && read -p "当前版本和云端最新版本一致，是否还要重新安装固件?[Y/n]:" Choose
		[[ "${Choose}" == Y ]] || [[ "${Choose}" == y ]] && {
			TIME b "正在开始重新安装固件..."
		} || {
			TIME r "已取消重新安装固件,即将退出程序..."
			sleep 2
			exit 0
		}
	fi
  	if [[ "${CURRENT_Version}" -lt "${CLOUD_Version}" ]];then
		[[ "${AutoUpdate_Mode}" == 1 ]] && exit 0
		TIME && read -p "当前版本高于云端最新版,是否强制覆盖固件?[Y/n]:" Choose
		[[ "${Choose}" == Y ]] || [[ "${Choose}" == y ]] && {
			TIME  "正在开始使用云端版本覆盖现有固件..."
		} || {
			TIME r "已取消覆盖固件,退出程序..."
			sleep 2
			exit 0
		}
	fi
fi
TIME g "列出详细信息..."
sleep 1
echo -e "\n固件作者：${Author}"
echo "设备名称：${CURRENT_Device}"
echo "固件格式：${Firmware_GESHI}"
[[ "${DEFAULT_Device}" == x86-64 ]] && {
	echo "引导模式：${EFI_Mode}"
}
echo "固件名称：${Firmware}"
echo "下载保存：${Download_Path}"
sleep 1
cd ${Download_Path}
TIME g "正在下载云端固件,请耐心等待..."
wget -q --no-cookie --no-check-certificate -T 15 -t 4 "${Github_Release}/${Firmware}" -O ${Firmware}
if [[ $? -ne 0 ]];then
	wget -q --no-cookie --no-check-certificate -T 15 -t 4 "https://ghproxy.com/${Github_Release}/${Firmware}" -O ${Firmware}
	if [[ $? -ne 0 ]];then
		TIME r "下载云端固件失败,请尝试手动安装!"
		echo
		exit 1
	else
		TIME y "下载云端固件成功!"
	fi
else
	TIME y "下载云端固件成功!"
fi
TIME g "准备就绪,开始刷写固件..."
[[ "${Input_Other}" == "-t" ]] && {
	TIME z "测试模式运行完毕!"
	rm -rf "${Download_Path}"
	opkg remove gzip > /dev/null 2>&1
	echo
	exit 0
}

chmod 777 ${Firmware}
sysupgrade ${Upgrade_Options} ${Firmware}
[[ $? -ne 0 ]] && {
	TIME r "固件刷写失败,请尝试手动更新固件!"
	exit 1
} || exit 0
