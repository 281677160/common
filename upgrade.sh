#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoBuild Functions
AUTOUPDATE_VERSION=8.0

function Diy_Part1() {
	find . -type d -name 'luci-app-autoupdate' | xargs -i rm -rf {}
        if git clone -q --single-branch --depth=1 --branch=main https://github.com/281677160/luci-app-autoupdate $HOME_PATH/package/luci-app-autoupdate; then
        	if ! grep -q "luci-app-autoupdate" "${HOME_PATH}/include/target.mk"; then
			sed -i 's?DEFAULT_PACKAGES:=?DEFAULT_PACKAGES:=luci-app-autoupdate luci-app-ttyd ?g' ${HOME_PATH}/include/target.mk
		fi
		echo "增加定时更新固件的插件下载完成"
	else
		echo "增加定时更新固件的插件下载失败"
	fi
}


function Diy_Part2() {
	export UPDATE_TAG="Update-${TARGET_BOARD}"
	export FILESETC_UPDATE="${HOME_PATH}/package/base-files/files/etc/openwrt_update"
	export RELEASE_DOWNLOAD1="https://ghfast.top/\$GITHUB_LINK/releases/download/${UPDATE_TAG}"
	export RELEASE_DOWNLOAD2="\$GITHUB_LINK/releases/download/${UPDATE_TAG}"
	export GITHUB_RELEASE="${GITHUB_LINK}/releases/tag/${UPDATE_TAG}"
	install -m 0755 /dev/null "${FILESETC_UPDATE}"
        if [[ ! -f "$LINSHI_COMMON/autoupdate/replace" ]]; then
		echo -e "\n\033[0;31m缺少autoupdate/replace文件\033[0m"
   		exit 1
  	fi
	if [[ "${TARGET_PROFILE}" == *"k3"* ]]; then
		export TARGET_PROFILE_ER="phicomm-k3"
	elif [[ "${TARGET_PROFILE}" == *"k2p"* ]]; then
		export TARGET_PROFILE_ER="phicomm-k2p"
	elif [[ "$TARGET_PROFILE" == *xiaomi* && "$TARGET_PROFILE" == *3g* && "$TARGET_PROFILE" == *v2* ]]; then
		export TARGET_PROFILE_ER="xiaomi_mir3g-v2"
	elif [[ "$TARGET_PROFILE" == *xiaomi* && "$TARGET_PROFILE" == *3g* ]]; then
		export TARGET_PROFILE_ER="xiaomi_mir3g"
 	elif [[ "$TARGET_PROFILE" == *xiaomi* && "$TARGET_PROFILE" == *3* && "$TARGET_PROFILE" == *pro* ]]; then
		export TARGET_PROFILE_ER="xiaomi_mi3pro"
	else
		export TARGET_PROFILE_ER="${TARGET_PROFILE}"
	fi
	
	case "${TARGET_BOARD}" in
	ramips | reltek | ath* | ipq* | bmips | kirkwood | mediatek |bcm4908 |gemini |lantiq |layerscape |qualcommax |qualcommbe |siflower |silicon)
		export FIRMWARE_SUFFIX=".bin"
		export AUTOBUILD_FIRMWARE="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${UPGRADE_DATE}-sysupgrade"
	;;
 	bcm47xx)
          	if echo "$TARGET_PROFILE" | grep -Eq 'asus'; then
			export FIRMWARE_SUFFIX=".trx"
             	elif echo "$TARGET_PROFILE" | grep -Eq 'netgear'; then
			export FIRMWARE_SUFFIX=".chk"
		else
			export FIRMWARE_SUFFIX=".bin"
		fi
		export AUTOBUILD_FIRMWARE="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${UPGRADE_DATE}-sysupgrade"
	;;
	x86)
		export FIRMWARE_SUFFIX=".img.gz"
		export AUTOBUILD_UEFI="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${UPGRADE_DATE}-uefi"
		export AUTOBUILD_LEGACY="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${UPGRADE_DATE}-legacy"
	;;
	rockchip | bcm27xx | mxs | sunxi | zynq |loongarch64 |omap |sifiveu |tegra |amlogic)
		export FIRMWARE_SUFFIX=".img.gz"
		export AUTOBUILD_FIRMWARE="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${UPGRADE_DATE}-legacy"
	;;
	mvebu)
		case "${TARGET_SUBTARGET}" in
		cortexa53 | cortexa72)
			export FIRMWARE_SUFFIX=".img.gz"
			export AUTOBUILD_FIRMWARE="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${UPGRADE_DATE}-legacy"
		;;
		esac
	;;
	bcm53xx)
 		if echo "$TARGET_PROFILE" | grep -Eq 'mr32|tplink|dlink'; then
			export FIRMWARE_SUFFIX=".bin"
     		elif echo "$TARGET_PROFILE" | grep -Eq 'luxul'; then
			export FIRMWARE_SUFFIX=".lxl"
        	elif echo "$TARGET_PROFILE" | grep -Eq 'netgear'; then
			export FIRMWARE_SUFFIX=".chk"
		else
			export FIRMWARE_SUFFIX=".trx"
		fi
		export AUTOBUILD_FIRMWARE="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${UPGRADE_DATE}-sysupgrade"
	;;
	octeon | oxnas | pistachio)
		export FIRMWARE_SUFFIX=".tar"
		export AUTOBUILD_FIRMWARE="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${UPGRADE_DATE}-sysupgrade"
	;;
	*)
		export FIRMWARE_SUFFIX=".bin"
		export AUTOBUILD_FIRMWARE="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE_ER}-${UPGRADE_DATE}-sysupgrade"
	;;
	esac
	
	export FIRMWARE_VERSION="${SOURCE}-${TARGET_PROFILE_ER}-${UPGRADE_DATE}"
	
	if [[ "${TARGET_BOARD}" == "x86" ]]; then
		echo "AUTOBUILD_UEFI=${AUTOBUILD_UEFI}" >> ${GITHUB_ENV}
		echo "AUTOBUILD_LEGACY=${AUTOBUILD_LEGACY}" >> ${GITHUB_ENV}
	else
		echo "AUTOBUILD_FIRMWARE=${AUTOBUILD_FIRMWARE}" >> ${GITHUB_ENV}
	fi

 	echo "UPDATE_TAG=${UPDATE_TAG}" >> ${GITHUB_ENV}
	echo "FIRMWARE_SUFFIX=${FIRMWARE_SUFFIX}" >> ${GITHUB_ENV}
	echo "AUTOUPDATE_VERSION=${AUTOUPDATE_VERSION}" >> ${GITHUB_ENV}
	echo "FIRMWARE_VERSION=${FIRMWARE_VERSION}" >> ${GITHUB_ENV}
	echo "GITHUB_RELEASE=${GITHUB_RELEASE}" >> ${GITHUB_ENV}


	# 写入openwrt_update文件
	echo "GITHUB_LINK=\"${GITHUB_LINK}\"" > ${FILESETC_UPDATE}
 	echo "FIRMWARE_VERSION=\"${FIRMWARE_VERSION}\"" >> ${FILESETC_UPDATE}
 	echo "LUCI_EDITION=\"${LUCI_EDITION}\"" >> ${FILESETC_UPDATE}
 	echo "SOURCE=\"${SOURCE}\"" >> ${FILESETC_UPDATE}
   	echo "DEVICE_MODEL=\"${TARGET_PROFILE_ER}\"" >> ${FILESETC_UPDATE}
 	echo "FIRMWARE_SUFFIX=\"${FIRMWARE_SUFFIX}\"" >> ${FILESETC_UPDATE}
 	echo "TARGET_BOARD=\"${TARGET_BOARD}\"" >> ${FILESETC_UPDATE}
 	echo "RELEASE_DOWNLOAD1=\"${RELEASE_DOWNLOAD1}\"" >> ${FILESETC_UPDATE}
 	echo "RELEASE_DOWNLOAD2=\"${RELEASE_DOWNLOAD2}\"" >> ${FILESETC_UPDATE}
	cat "$LINSHI_COMMON/autoupdate/replace" >> ${FILESETC_UPDATE}
}

function Diy_Part3() {
	BIN_PATH="${HOME_PATH}/bin/Firmware"
	echo "BIN_PATH=${BIN_PATH}" >> ${GITHUB_ENV}
	[[ ! -d "${BIN_PATH}" ]] && mkdir -p "${BIN_PATH}" || rm -rf "${BIN_PATH}"/*
	
	cd "${FIRMWARE_PATH}"
 	if [[ -n "$(ls -1 | grep -E '.img')" ]] && [[ -z "$(ls -1 | grep -E '.img.gz')" ]]; then
		gzip -f9n *.img
	fi
	
	case "${TARGET_BOARD}" in
	x86)
		if [[ -n "$(ls -1 | grep -E 'efi')" ]]; then
			EFI_ZHONGZHUAN="$(ls -1 |grep -Eo ".*squashfs.*efi.*img.gz")"
			if [[ -f "${EFI_ZHONGZHUAN}" ]]; then
		  		EFIMD5="$(md5sum ${EFI_ZHONGZHUAN} |cut -c1-3)$(sha256sum ${EFI_ZHONGZHUAN} |cut -c1-3)"
		  		cp -Rf "${EFI_ZHONGZHUAN}" "${BIN_PATH}/${AUTOBUILD_UEFI}-${EFIMD5}${FIRMWARE_SUFFIX}"
			else
				echo "没找到在线升级可用的${FIRMWARE_SUFFIX}格式固件"
			fi
		else
			echo "没有uefi格式固件"
		fi
		
  		if [[ -n "$(ls -1 | grep -E 'squashfs')" ]]; then
			LEGA_ZHONGZHUAN="$(ls -1 |grep -Eo ".*squashfs.*img.gz" |grep -v ".vm\|.vb\|.vh\|.qco\|efi\|root")"
			if [[ -f "${LEGA_ZHONGZHUAN}" ]]; then
				LEGAMD5="$(md5sum ${LEGA_ZHONGZHUAN} |cut -c1-3)$(sha256sum ${LEGA_ZHONGZHUAN} |cut -c1-3)"
				cp -Rf "${LEGA_ZHONGZHUAN}" "${BIN_PATH}/${AUTOBUILD_LEGACY}-${LEGAMD5}${FIRMWARE_SUFFIX}"
			else
				echo "没找到在线升级可用的${FIRMWARE_SUFFIX}格式固件"
			fi
		else
			echo "没有squashfs格式固件"
		fi
	;;
	*)
  		if [[ -n "$(ls -1 | grep -E 'sysupgrade')" ]]; then
			UP_ZHONGZHUAN="$(ls -1 |grep -Eo ".*${TARGET_PROFILE}.*sysupgrade.*${FIRMWARE_SUFFIX}" |grep -v "rootfs\|ext4\|factory\|kernel")"
		elif [[ -n "$(ls -1 | grep -E 'squashfs')" ]]; then
			UP_ZHONGZHUAN="$(ls -1 |grep -Eo ".*${TARGET_PROFILE}.*squashfs.*${FIRMWARE_SUFFIX}" |grep -v "rootfs\|ext4\|factory\|kernel")"
   		elif [[ -n "$(ls -1 | grep -E 'combined')" ]]; then
			UP_ZHONGZHUAN="$(ls -1 |grep -Eo ".*${TARGET_PROFILE}.*combined.*${FIRMWARE_SUFFIX}" |grep -v "rootfs\|ext4\|factory\|kernel")"
      		elif [[ -n "$(ls -1 | grep -E 'sdcard')" ]]; then
			UP_ZHONGZHUAN="$(ls -1 |grep -Eo ".*${TARGET_PROFILE}.*sdcard.*${FIRMWARE_SUFFIX}" |grep -v "rootfs\|ext4\|factory\|kernel")"
   		else
     			echo "没找到在线升级可用的${FIRMWARE_SUFFIX}格式固件，或者没适配该机型"
		fi
		if [[ -f "${UP_ZHONGZHUAN}" ]]; then
   			MD5="$(md5sum ${UP_ZHONGZHUAN} | cut -c1-3)$(sha256sum ${UP_ZHONGZHUAN} | cut -c1-3)"
			cp -Rf "${UP_ZHONGZHUAN}" "${BIN_PATH}/${AUTOBUILD_FIRMWARE}-${MD5}${FIRMWARE_SUFFIX}"
		fi
	;;
	esac
 	echo -e "\n\033[0;32m远程更新固件\033[0m"
 	ls -1 $BIN_PATH
	cd ${HOME_PATH}
}
