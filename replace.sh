#!/bin/bash


TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\033[1;91m";;
	g) export Color="\033[0;92m";;
	B) export Color="\033[1;36m";;
	y) export Color="\033[0;33m";;
	z) export Color="\033[1;95m";;
	h) export Color="\033[1;34m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
[ -f /etc/openwrt_info ] && chmod +x /etc/openwrt_info
[ -f /etc/openwrt_info ] && source /etc/openwrt_info || {
	TIME r "未检测到更换固件所需文件,无法运行固件更换程序!"
	exit 1
}
export Apidz="${Github##*com/}"
export Author="${Apidz%/*}"
export CangKu="${Apidz##*/}"
export Github_Tags=https://api.github.com/repos/${Apidz}/releases/tags/AutoUpdate
[ ! -d ${Download_Path} ] && mkdir -p ${Download_Path}
wget -q --no-cookie --no-check-certificate -T 15 -t 4 ${Github_Tags} -O ${Download_Path}/Github_Tags
[[ ! $? == 0 ]] && {
	TIME r "获取固件版本信息失败,请检测网络是否翻墙或更换节点再尝试,或者您的Github地址为无效地址!"
	exit 1
}
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
	[ -f /etc/openwrt_boot ] && {
		export GESHI_Type="$(cat /etc/openwrt_boot)"
	} || {
		[ -d /sys/firmware/efi ] && {
			export GESHI_Type="UEFI"
		} || export GESHI_Type="Legacy"
	}
	[[ "${Firmware_Type}" == img.gz ]] && {
		export Firmware_SFX=".img.gz"
	} || {
		export Firmware_SFX=".img"
	}
;;
*)
	export Firmware_SFX=".${Firmware_Type}"
	export BOOT_Type="-Sysupg"
	export GESHI_Type="Sysupg"
esac
clear
TIME h "执行：转换成其他源码固件"
echo
echo
TIME y "您当前固件为：${GESHI_Type}${Firmware_SFX}格式的 ${REPO_Name} ${Luci_Edition} ${Kernel} 内核版!"
echo
if [[ "${REPO_Name}" == "lede" ]]; then
	if [[ `cat ${Download_Path}/Github_Tags | grep -c "19.07-lienol-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG1="1"
	fi
	if [[ `cat ${Download_Path}/Github_Tags | grep -c "21.02-mortal-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG2="2"
	fi
	if [[ -z "${ZHUANG1}" ]] && [[ -z "${ZHUANG2}" ]]; then
		TIME r "没有检测到有其他作者相同机型的固件版本或者固件格式不相同!"
		echo
		exit 1
	fi
	if [[ -n "${ZHUANG1}" ]] && [[ -n "${ZHUANG2}" ]]; then
		ZHUANG1="3"
		ZHUANG2="3"
		ZHUANG3="3"
	fi
fi
if [[ "${REPO_Name}" == "lienol" ]]; then
	if [[ `cat ${Download_Path}/Github_Tags | grep -c "18.06-lede-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG1="1"
	fi
	if [[ `cat ${Download_Path}/Github_Tags | grep -c "21.02-mortal-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG2="2"
	fi
	if [[ -z "${ZHUANG1}" ]] && [[ -z "${ZHUANG2}" ]]; then
		TIME r "没有检测到有其他作者相同机型的固件版本或者固件格式不相同!"
		echo
		exit 1
	fi
	if [[ -n "${ZHUANG1}" ]] && [[ -n "${ZHUANG2}" ]]; then
		ZHUANG1="3"
		ZHUANG2="3"
		ZHUANG3="3"
	fi
fi
if [[ "${REPO_Name}" == "mortal" ]]; then
	if [[ `cat ${Download_Path}/Github_Tags | grep -c "18.06-lede-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG1="1"
	fi
	if [[ `cat ${Download_Path}/Github_Tags | grep -c "19.07-lienol-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG2="2"
	fi
	if [[ -z "${ZHUANG1}" ]] && [[ -z "${ZHUANG2}" ]]; then
		TIME r "没有检测到有其他作者相同机型的固件版本或者固件格式不相同!"
		echo
		exit 1
	fi
	if [[ -n "${ZHUANG1}" ]] && [[ -n "${ZHUANG2}" ]]; then
		ZHUANG1="3"
		ZHUANG2="3"
		ZHUANG3="3"
	fi
fi
echo
TIME z "请注意：选择更改其他源码固件后立即执行不保留配置安装固件"
echo
echo
echo
if [[ "${REPO_Name}" == "lede" ]]; then
	if [[ "${ZHUANG1}" == "1" ]]; then
		TIME B "1. 转换成 Lienol 19.07 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="19.07"
			CURRENT_Version="lienol-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="19.07"
			REPO_Name="lienol"
			Github_Release=${Github_Release}
			Egrep_Firmware="19.07-lienol-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			TIME r "您退出了固件转换程序"
			echo
			sleep 2
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG2}" == "2" ]]; then
		TIME B "1. 转换成 mortal 21.02 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="21.02"
			CURRENT_Version="mortal-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="21.02"
			REPO_Name="mortal"
			Github_Release=${Github_Release}
			Egrep_Firmware="21.02-mortal-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			TIME r "您退出了固件转换程序"
			echo
			sleep 2
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG3}" == "3" ]]; then
		TIME B "1. 转换成 Lienol 19.07 其他内核版本?"
		echo
		TIME B "2. 转换成 mortal 21.02 其他内核版本?"
		echo
		TIME B "3. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2、3 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="19.07"
			CURRENT_Version="lienol-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="19.07"
			REPO_Name="lienol"
			Github_Release=${Github_Release}
			Egrep_Firmware="19.07-lienol-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="21.02"
			CURRENT_Version="mortal-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="21.02"
			REPO_Name="mortal"
			Github_Release=${Github_Release}
			Egrep_Firmware="21.02-mortal-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		3)
			TIME r "您退出了固件转换程序"
			echo
			sleep 2
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	fi

fi
if [[ "${REPO_Name}" == "lienol" ]]; then
	if [[ "${ZHUANG1}" == "1" ]]; then
		TIME B "1. 转换成 Lede 18.06 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="18.06"
			CURRENT_Version="lede-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="18.06"
			REPO_Name="lede"
			Github_Release=${Github_Release}
			Egrep_Firmware="18.06-lede-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			TIME r "您退出了固件转换程序"
			echo
			sleep 2
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG2}" == "2" ]]; then
		TIME B "1. 转换成 mortal 21.02 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="21.02"
			CURRENT_Version="mortal-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="21.02"
			REPO_Name="mortal"
			Github_Release=${Github_Release}
			Egrep_Firmware="21.02-mortal-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			TIME r "您退出了固件转换程序"
			echo
			sleep 2
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG3}" == "3" ]]; then
		TIME B "1. 转换成 Lede 18.06 其他内核版本?"
		echo
		TIME B "2. 转换成 mortal 21.02 其他内核版本?"
		echo
		TIME B "3. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2、3 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="18.06"
			CURRENT_Version="lede-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="18.06"
			REPO_Name="lede"
			Github_Release=${Github_Release}
			Egrep_Firmware="18.06-lede-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="21.02"
			CURRENT_Version="mortal-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="21.02"
			REPO_Name="mortal"
			Github_Release=${Github_Release}
			Egrep_Firmware="21.02-mortal-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		3)
			TIME r "您退出了固件转换程序"
			echo
			sleep 2
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	fi

fi
if [[ "${REPO_Name}" == "mortal" ]]; then
	if [[ "${ZHUANG1}" == "1" ]]; then
		TIME B "1. 转换成 Lede 18.06 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="18.06"
			CURRENT_Version="lede-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="18.06"
			REPO_Name="lede"
			Github_Release=${Github_Release}
			Egrep_Firmware="18.06-lede-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			TIME r "您退出了固件转换程序"
			echo
			sleep 2
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG2}" == "2" ]]; then
		TIME B "1. 转换成 lienol 19.07 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="19.07"
			CURRENT_Version="lienol-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="19.07"
			REPO_Name="lienol"
			Github_Release=${Github_Release}
			Egrep_Firmware="19.07-lienol-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			TIME r "您退出了固件转换程序"
			echo
			sleep 2
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG3}" == "3" ]]; then
		TIME B "1. 转换成 Lede 18.06 其他内核版本?"
		echo
		TIME B "2. 转换成 lienol 19.07 其他内核版本?"
		echo
		TIME B "3. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2、3 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="18.06"
			CURRENT_Version="lede-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="18.06"
			REPO_Name="lede"
			Github_Release=${Github_Release}
			Egrep_Firmware="18.06-lede-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			cat >/etc/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition="19.07"
			CURRENT_Version="lienol-${DEFAULT_Device}-202106010101"
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name="19.07"
			REPO_Name="lienol"
			Github_Release=${Github_Release}
			Egrep_Firmware="19.07-lienol-${DEFAULT_Device}"
			Download_Path=${Download_Path}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 5
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		3)
			TIME r "您退出了固件转换程序"
			echo
			sleep 2
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	fi

fi
exit 0
