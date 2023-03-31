#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoBuild Functions


function Diy_Part1() {
	find . -type d -name 'luci-app-autoupdate' | xargs -i rm -rf {}
	echo "正在执行：给源码增加定时更新固件插件和设置插件和ttyd成默认自选"
	git clone -b main https://github.com/281677160/luci-app-autoupdate $HOME_PATH/package/luci-app-autoupdate
	if [[ `grep -c "luci-app-autoupdate" ${HOME_PATH}/include/target.mk` -eq '0' ]]; then
		sed -i 's?DEFAULT_PACKAGES:=?DEFAULT_PACKAGES:=luci-app-autoupdate luci-app-ttyd ?g' ${HOME_PATH}/include/target.mk
	fi
	if [[ -d "${HOME_PATH}/package/luci-app-autoupdate" ]]; then
		echo "增加定时更新固件的插件成功"
	else
		echo "插件源码下载失败"
	fi
}


function Diy_Part2() {
	export In_Firmware_Info="$FILES_PATH/etc/openwrt_update"
	export In_Firmware_Replace="$FILES_PATH/etc/openwrt_replace"
	export Github_API1="https://api.github.com/repos/${GIT_REPOSITORY}/releases/tags/${TARGET_BOARD}"
	export Github_API2="https://ghproxy.com/https://github.com/${GIT_REPOSITORY}/releases/download/${TARGET_BOARD}/zzz_api"
	export API_PATH="/tmp/Downloads/zzz_api"
	export Release_download1="${GITHUB_LINK}/releases/download/${TARGET_BOARD}"
	export Release_download2="https://ghproxy.com/${GITHUB_LINK}/releases/download/${TARGET_BOARD}"
	export Github_Release="${GITHUB_LINK}/releases/tag/${TARGET_BOARD}"
	
	if [[ "${TARGET_PROFILE}" =~ (phicomm_k3|phicomm-k3) ]]; then
		export TARGET_PROFILE_ER="phicomm-k3"
	elif [[ "${TARGET_PROFILE}" =~ (k2p|phicomm_k2p|phicomm-k2p) ]]; then
		export TARGET_PROFILE_ER="phicomm-k2p"
	elif [[ "${TARGET_PROFILE}" =~ (xiaomi_mi-router-3g-v2|xiaomi_mir3g_v2) ]]; then
		export TARGET_PROFILE_ER="xiaomi_mir3g-v2"
	elif [[ "${TARGET_PROFILE}" == "xiaomi_mi-router-3g" ]]; then
		export TARGET_PROFILE_ER="xiaomi_mir3g"
	elif [[ "${TARGET_PROFILE}" == "xiaomi_mi-router-3-pro" ]]; then
		export TARGET_PROFILE_ER="xiaomi_mir3p"
	else
		export TARGET_PROFILE_ER="${TARGET_PROFILE}"
	fi
	
	case "${TARGET_BOARD}" in
	ramips | reltek | ath* | ipq* | bcm47xx | bmips | kirkwood | mediatek)
		export Firmware_SFX=".bin"
		export AutoBuild_Firmware="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${Upgrade_Date}-sysupgrade"
	;;
	x86)
		export Firmware_SFX=".img.gz"
		export AutoBuild_Uefi="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${Upgrade_Date}-uefi"
		export AutoBuild_Legacy="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${Upgrade_Date}-legacy"
	;;
	rockchip | bcm27xx | mxs | sunxi | zynq)
		export Firmware_SFX=".img.gz"
		export AutoBuild_Firmware="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${Upgrade_Date}-sysupgrade"
	;;
	mvebu)
		case "${TARGET_SUBTARGET}" in
		cortexa53 | cortexa72)
			export Firmware_SFX=".img.gz"
			export AutoBuild_Firmware="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${Upgrade_Date}-sysupgrade"
		;;
		esac
	;;
	bcm53xx)
		export Firmware_SFX=".trx"
		export AutoBuild_Firmware="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${Upgrade_Date}-sysupgrade"
	;;
	octeon | oxnas | pistachio)
		export Firmware_SFX=".tar"
		export AutoBuild_Firmware="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${Upgrade_Date}-sysupgrade"
	;;
	*)
		export Firmware_SFX=".bin"
		export AutoBuild_Firmware="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${Upgrade_Date}-sysupgrade"
	;;
	esac
	
	if [[ -f "${HOME_PATH}/package/luci-app-autoupdate/root/usr/bin/AutoUpdate" ]]; then
		export AutoUpdate_Version=$(grep -Eo "Version=V[0-9.]+" "${HOME_PATH}/package/luci-app-autoupdate/root/usr/bin/AutoUpdate" |grep -Eo [0-9.]+)
	fi
	
	export Openwrt_Version="${SOURCE}-${TARGET_PROFILE_ER}-${Upgrade_Date}"
	export LOCAL_FIRMW="${LUCI_EDITION}-${SOURCE}"
	export CLOUD_CHAZHAO="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}"
	
	if [[ "${TARGET_BOARD}" == "x86" ]]; then
		echo "AutoBuild_Uefi=${AutoBuild_Uefi}" >> ${GITHUB_ENV}
		echo "AutoBuild_Legacy=${AutoBuild_Legacy}" >> ${GITHUB_ENV}
	else
		echo "AutoBuild_Firmware=${AutoBuild_Firmware}" >> ${GITHUB_ENV}
	fi
	
	echo "Firmware_SFX=${Firmware_SFX}" >> ${GITHUB_ENV}
	echo "AutoUpdate_Version=${AutoUpdate_Version}" >> ${GITHUB_ENV}
	echo "Openwrt_Version=${Openwrt_Version}" >> ${GITHUB_ENV}
	echo "Github_Release=${Github_Release}" >> ${GITHUB_ENV}


cat >"${In_Firmware_Info}" <<-EOF
GITHUB_LINK=${GITHUB_LINK}
CURRENT_Version=${Openwrt_Version}
SOURCE="${SOURCE}"
LUCI_EDITION="${LUCI_EDITION}"
DEFAULT_Device="${TARGET_PROFILE_ER}"
Firmware_SFX="${Firmware_SFX}"
TARGET_BOARD="${TARGET_BOARD}"
CLOUD_CHAZHAO="${CLOUD_CHAZHAO}"
Download_Path="/tmp/Downloads"
Version="${AutoUpdate_Version}"
API_PATH="${API_PATH}"
Github_API1="${Github_API1}"
Github_API2="${Github_API2}"
Github_Release="${Github_Release}"
Release_download1="${Release_download1}"
Release_download2="${Release_download2}"
EOF
	sudo chmod +x ${In_Firmware_Info}
	
	
cat >"${In_Firmware_Replace}" <<-EOF
GITHUB_LINK=${GITHUB_LINK}
CURRENT_Version=${Openwrt_Version}
SOURCE="${SOURCE}"
LUCI_EDITION="${LUCI_EDITION}"
DEFAULT_Device="${TARGET_PROFILE_ER}"
Firmware_SFX="${Firmware_SFX}"
TARGET_BOARD="${TARGET_BOARD}"
CLOUD_CHAZHAO="${CLOUD_CHAZHAO}"
Download_Path="/tmp/Downloads"
Version="${AutoUpdate_Version}"
API_PATH="${API_PATH}"
Github_API1="${Github_API1}"
Github_API2="${Github_API2}"
Github_Release="${Github_Release}"
Release_download1="${Release_download1}"
Release_download2="${Release_download2}"
EOF
	bash <(curl -fsSL https://raw.githubusercontent.com/281677160/common/main/autoupdate/replacebianliang.sh)
	sudo chmod +x ${In_Firmware_Replace}
}

function Diy_Part3() {
	BIN_PATH="${HOME_PATH}/bin/Firmware"
	echo "BIN_PATH=${BIN_PATH}" >> ${GITHUB_ENV}
	[[ ! -d "${BIN_PATH}" ]] && mkdir -p "${BIN_PATH}" || rm -rf "${BIN_PATH}"/*
	
	cd "${FIRMWARE_PATH}"
	if [[ `ls -1 |grep -c ".img"` -ge '1' ]] && [[ `ls -1 |grep -c ".img.gz"` -eq '0' ]]; then
		gzip -f9n *.img
	fi
	
	case "${TARGET_BOARD}" in
	x86)
		if [[ `ls -1 | grep -c "efi"` -ge '1' ]]; then
			EFI_ZHONGZHUAN="$(ls -1 |grep -Eo ".*squashfs.*efi.*img.gz")"
			if [[ -f "${EFI_ZHONGZHUAN}" ]]; then
		  		EFIMD5="$(md5sum ${EFI_ZHONGZHUAN} |cut -c1-3)$(sha256sum ${EFI_ZHONGZHUAN} |cut -c1-3)"
		  		cp -Rf "${EFI_ZHONGZHUAN}" "${BIN_PATH}/${AutoBuild_Uefi}-${EFIMD5}${Firmware_SFX}"
			else
				echo "没找到在线升级可用的${Firmware_SFX}格式固件"
			fi
		else
			echo "没有uefi格式固件"
		fi
		
		if [[ `ls -1 | grep -c "squashfs"` -ge '1' ]]; then
			LEGA_ZHONGZHUAN="$(ls -1 |grep -Eo ".*squashfs.*img.gz" |grep -v ".vm\|.vb\|.vh\|.qco\|efi\|root")"
			if [[ -f "${LEGA_ZHONGZHUAN}" ]]; then
				LEGAMD5="$(md5sum ${LEGA_ZHONGZHUAN} |cut -c1-3)$(sha256sum ${LEGA_ZHONGZHUAN} |cut -c1-3)"
				cp -Rf "${LEGA_ZHONGZHUAN}" "${BIN_PATH}/${AutoBuild_Legacy}-${LEGAMD5}${Firmware_SFX}"
			else
				echo "没找到在线升级可用的${Firmware_SFX}格式固件"
			fi
		else
			echo "没有squashfs格式固件"
		fi
	;;
	*)
		if [[ `ls -1 | grep -c "sysupgrade"` -ge '1' ]]; then
			UP_ZHONGZHUAN="$(ls -1 |grep -Eo ".*${TARGET_PROFILE}.*sysupgrade.*${Firmware_SFX}" |grep -v "rootfs\|ext4\|factory")"
		else
			UP_ZHONGZHUAN="$(ls -1 |grep -Eo ".*${TARGET_PROFILE}.*squashfs.*${Firmware_SFX}" |grep -v "rootfs\|ext4\|factory")"
		fi
		if [[ -f "${UP_ZHONGZHUAN}" ]]; then
			MD5="$(md5sum ${UP_ZHONGZHUAN} | cut -c1-3)$(sha256sum ${UP_ZHONGZHUAN} | cut -c1-3)"
			cp -Rf "${UP_ZHONGZHUAN}" "${BIN_PATH}/${AutoBuild_Firmware}-${MD5}${Firmware_SFX}"
		else
			echo "没找到在线升级可用的${Firmware_SFX}格式固件，或者没适配该机型"
		fi
	;;
	esac
	cd ${HOME_PATH}
}
