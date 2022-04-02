#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoBuild Functions


function Diy_Part1() {
  rm -rf "$HOME_PATH/package/luci-app-autoupdate"
  git clone https://github.com/281677160/luci-app-autoupdate $HOME_PATH/package/luci-app-autoupdate
  [[ -f "$BUILD_PATH/AutoUpdate.sh" ]] && cp -Rf $BUILD_PATH/AutoUpdate.sh $BASE_PATH/bin/AutoUpdate.sh
  [[ -f "$BUILD_PATH/replace.sh" ]] && cp -Rf $BUILD_PATH/replace.sh $BASE_PATH/bin/replace.sh
  sed  -i  's/ luci-app-ttyd//g' $HOME_PATH/target/linux/*/Makefile
  sed  -i  's/ luci-app-autoupdate//g' $HOME_PATH/target/linux/*/Makefile
  sed -i 's?DEFAULT_PACKAGES +=?DEFAULT_PACKAGES += luci-app-autoupdate luci-app-ttyd?g' $HOME_PATH/target/linux/*/Makefile
}

function GET_TARGET_INFO() {
	source $BUILD_PATH/common.sh && Make_upgrade
	if [[ "${TARGET_PROFILE}" =~ (phicomm_k3|phicomm-k3) ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="phicomm_k3"
	elif [[ "${TARGET_PROFILE}" =~ (k2p|phicomm_k2p|phicomm-k2p) ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="phicomm_k2p"
	elif [[ "${TARGET_PROFILE}" =~ (xiaomi_mi-router-3g-v2|xiaomi_mir3g_v2) ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="xiaomi_mir3g-v2"
	elif [[ "${TARGET_PROFILE}" == "xiaomi_mi-router-3g" ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="xiaomi_mir3g"
	elif [[ "${TARGET_PROFILE}" == "xiaomi_mi-router-3-pro" ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="xiaomi_mir3p"
	else
		export TARGET_PROFILE="${TARGET_PROFILE}"
	fi
	
	case "${TARGET_BOARD}" in
	ramips | reltek | ath* | ipq* | bcm47xx | bmips | kirkwood | mediatek)
		export Firmware_SFX=".bin"
		export Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade${Firmware_SFX}"
	;;
	x86 | rockchip | bcm27xx | mxs | sunxi | zynq)
		export Firmware_SFX=".img.gz"
		export Legacy_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-combined${Firmware_SFX}"
		export UEFI_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-combined-efi${Firmware_SFX}"
	;;
	mvebu)
		case "${TARGET_SUBTARGET}" in
		cortexa53 | cortexa72)
			export Firmware_SFX=".img.gz"
			export Legacy_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-combined${Firmware_SFX}"
			export UEFI_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-combined-efi${Firmware_SFX}"
		;;
		esac
	;;
	bcm53xx)
		export Firmware_SFX=".trx"
		export Up_Firmware="openwrt-bcm53xx-generic-${TARGET_PROFILE}-squashfs${Firmware_SFX}"
	;;
	octeon | oxnas | pistachio)
		export Firmware_SFX=".tar"
		export Up_Firmware="openwrt-${TARGET_BOARD}-generic-${TARGET_PROFILE}-squashfs${Firmware_SFX}"
	;;
	*)
		export Firmware_SFX=".bin"
		export Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade${Firmware_SFX}"
	;;
	esac
	
	AutoUp_Ver="$BASE_PATH/bin/AutoUpdate.sh"
	[[ -f ${AutoUp_Ver} ]] && export AutoUpdate_Version=$(egrep -o "V[0-9].+" $BASE_PATH/bin/AutoUpdate.sh | awk 'END{print}')
	export In_Firmware_Info="$BASE_PATH/bin/openwrt_info"
	export Github_Release="${Github}/releases/tag/AutoUpdate"
	export Openwrt_Version="${SOURCE}-${TARGET_PROFILE}-${Upgrade_Date}"
	export Github_API1="https://api.github.com/repos/${Warehouse}/releases/tags/AutoUpdate"
	export Github_API2="${Github}/releases/download/AutoUpdate/Github_Tags"
	export Release_download="https://github.com/${Warehouse}/releases/download/AutoUpdate"
	export LOCAL_CHAZHAO="${LUCI_EDITION}-${Openwrt_Version}"
	export CLOUD_CHAZHAO="${LUCI_EDITION}-${SOURCE}-${TARGET_PROFILE}"
}

function Diy_Part2() {
	GET_TARGET_INFO
	cat >${In_Firmware_Info} <<-EOF
	Github=${Github}
	Author=${Author}
	Library=${Library}
	Warehouse=${Warehouse}
	SOURCE=${SOURCE}
	LUCI_EDITION=${LUCI_EDITION}
	DEFAULT_Device=${TARGET_PROFILE}
	Firmware_SFX=${Firmware_SFX}
	TARGET_BOARD=${TARGET_BOARD}
	CURRENT_Version=${Openwrt_Version}
	LOCAL_CHAZHAO=${LOCAL_CHAZHAO}
	CLOUD_CHAZHAO=${CLOUD_CHAZHAO}
	Download_Path=/tmp/Downloads
	Version=${AutoUpdate_Version}
	API_PATH=/tmp/Downloads/Github_Tags
	Github_API1=${Github_API1}
	Github_API2=${Github_API2}
	Github_Release=${Github_Release}
	Release_download=${Release_download}
	EOF
}

function Diy_Part3() {
	GET_TARGET_INFO
	export AutoBuild_Firmware="${LUCI_EDITION}-${Openwrt_Version}"
	export Firmware_Path="$HOME_PATH/upgrade"
	export Transfer_Path="$HOME_PATH/bin/transfer"
	export Discard_Path="$HOME_PATH/bin/targets/discard"
	rm -rf $HOME_PATH/bin/Firmware && Mkdir $HOME_PATH/bin/Firmware
	rm -rf "${Transfer_Path}" && Mkdir "${Transfer_Path}"
	rm -rf "${Discard_Path}" && Mkdir "${Discard_Path}"
	cd "${Firmware_Path}"
	if [[ `ls -1 ${Firmware_Path} | grep -c ".img"` -ge '1' ]] && [[ `ls -1 ${Firmware_Path} | grep -c ".img.gz"` == '0' ]]; then
		gzip *.img
	fi
	
	case "${TARGET_BOARD}" in
	ramips | reltek | ath* | ipq* | bcm47xx | bmips | kirkwood | mediatek)
		if [[ -n ${Rename} ]]; then
			mv -f ${Firmware_Path}/*${Rename}* "${Transfer_Path}"
			rm -f "${Firmware_Path}/${Up_Firmware}"
			[[ `ls -1 ${Transfer_Path} | grep -c "sysupgrade.bin"` == '1' ]] && mv -f ${Transfer_Path}/*sysupgrade.bin "${Firmware_Path}/${Up_Firmware}"
		else
			mv -f ${Firmware_Path}/*${TARGET_PROFILE}* "${Transfer_Path}"
			rm -f "${Firmware_Path}/${Up_Firmware}"
			[[ `ls -1 ${Transfer_Path} | grep -c "sysupgrade.bin"` == '1' ]] && mv -f ${Transfer_Path}/*sysupgrade.bin "${Firmware_Path}/${Up_Firmware}"
		fi	
	;;
	x86 | rockchip | bcm27xx | mxs | sunxi | zynq)
		if [[ `ls -1 "${Firmware_Path}" | grep -c "ext4"` -ge '1' ]]; then
			mv -f ${Firmware_Path}/*ext4* ${Discard_Path}
		fi
		if [[ `ls -1 "${Firmware_Path}" | grep -c "rootfs"` -ge '1' ]]; then
			mv -f ${Firmware_Path}/*rootfs* ${Discard_Path}
		fi
		if [[ `ls -1 "${Firmware_Path}" | grep -c "${Firmware_SFX}"` -ge '1' ]]; then
			mv -f ${Firmware_Path}/*${Firmware_SFX}* "${Transfer_Path}"
			if [[ `ls -1 "${Transfer_Path}" | grep -c "efi"` -eq '1' ]]; then
				mv -f "${Transfer_Path}"/*efi* "${Firmware_Path}/${UEFI_Firmware}"
			fi
			if [[ `ls -1 "${Transfer_Path}" | grep -c "squashfs"` -eq '1' ]]; then
				mv -f "${Transfer_Path}"/*squashfs* "${Firmware_Path}/${Legacy_Firmware}"
			fi
		fi
	;;
	mvebu)
		case "${TARGET_SUBTARGET}" in
		cortexa53 | cortexa72)
			if [[ `ls -1 "${Firmware_Path}" | grep -c "ext4"` -ge '1' ]]; then
				mv -f ${Firmware_Path}/*ext4* ${Discard_Path}
			fi
			if [[ `ls -1 "${Firmware_Path}" | grep -c "rootfs"` -ge '1' ]]; then
				mv -f ${Firmware_Path}/*rootfs* ${Discard_Path}
			fi
			if [[ `ls -1 "${Firmware_Path}" | grep -c "${Firmware_SFX}"` -ge '1' ]]; then
				mv -f ${Firmware_Path}/*${Firmware_SFX}* "${Transfer_Path}"
				if [[ `ls -1 "${Transfer_Path}" | grep -c "efi"` -eq '1' ]]; then
					mv -f "${Transfer_Path}"/*efi* "${Firmware_Path}/${UEFI_Firmware}"
				fi
				if [[ `ls -1 "${Transfer_Path}" | grep -c "squashfs"` -eq '1' ]]; then
					mv -f "${Transfer_Path}"/*squashfs* "${Firmware_Path}/${Legacy_Firmware}"
				fi
			fi
		;;
		esac
	;;
	bcm53xx)
		if [[ -n ${Rename} ]]; then
			mv -f ${Firmware_Path}/*${Rename}* "${Transfer_Path}"
			rm -f "${Firmware_Path}/${Up_Firmware}"
			[[ `ls -1 ${Transfer_Path} | grep -c ".trx"` == '1' ]] && mv -f ${Transfer_Path}/*.trx "${Firmware_Path}/${Up_Firmware}"
		else
			mv -f ${Firmware_Path}/*${TARGET_PROFILE}* "${Transfer_Path}"
			rm -f "${Firmware_Path}/${Up_Firmware}"
			[[ `ls -1 ${Transfer_Path} | grep -c ".trx"` == '1' ]] && mv -f ${Transfer_Path}/*.trx "${Firmware_Path}/${Up_Firmware}"
		fi
	;;
	octeon | oxnas | pistachio)
		if [[ -n ${Rename} ]]; then
			mv -f ${Firmware_Path}/*${Rename}* "${Transfer_Path}"
			rm -f "${Firmware_Path}/${Up_Firmware}"
			[[ `ls -1 ${Transfer_Path} | grep -c ".tar"` == '1' ]] && mv -f ${Transfer_Path}/*.tar "${Firmware_Path}/${Up_Firmware}"
		else
			mv -f ${Firmware_Path}/*${TARGET_PROFILE}* "${Transfer_Path}"
			rm -f "${Firmware_Path}/${Up_Firmware}"
			[[ `ls -1 ${Transfer_Path} | grep -c ".tar"` == '1' ]] && mv -f ${Transfer_Path}/*.tar "${Firmware_Path}/${Up_Firmware}"
		fi
	;;
	*)
		if [[ -n ${Rename} ]]; then
			mv -f ${Firmware_Path}/*${Rename}* "${Transfer_Path}"
			rm -f "${Firmware_Path}/${Up_Firmware}"
			[[ `ls -1 ${Transfer_Path} | grep -c "sysupgrade.bin"` == '1' ]] && mv -f ${Transfer_Path}/*sysupgrade.bin "${Firmware_Path}/${Up_Firmware}"
		else
			mv -f ${Firmware_Path}/*${TARGET_PROFILE}* "${Transfer_Path}"
			rm -f "${Firmware_Path}/${Up_Firmware}"
			[[ `ls -1 ${Transfer_Path} | grep -c "sysupgrade.bin"` == '1' ]] && mv -f ${Transfer_Path}/*sysupgrade.bin "${Firmware_Path}/${Up_Firmware}"
		fi
	;;
	esac

	cd "${Firmware_Path}"
	case "${TARGET_BOARD}" in
	x86 | rockchip | bcm27xx | mxs | sunxi | zynq)
		[[ -f ${Legacy_Firmware} ]] && {
			MD5=$(md5sum ${Legacy_Firmware} | cut -c1-3)
			SHA256=$(sha256sum ${Legacy_Firmware} | cut -c1-3)
			SHA5BIT="${MD5}${SHA256}"
			cp ${Legacy_Firmware} $HOME_PATH/bin/Firmware/${AutoBuild_Firmware}-legacy-${SHA5BIT}${Firmware_SFX}
		}
		[[ -f ${UEFI_Firmware} ]] && {
			MD5=$(md5sum ${UEFI_Firmware} | cut -c1-3)
			SHA256=$(sha256sum ${UEFI_Firmware} | cut -c1-3)
			SHA5BIT="${MD5}${SHA256}"
			cp ${UEFI_Firmware} $HOME_PATH/bin/Firmware/${AutoBuild_Firmware}-uefi-${SHA5BIT}${Firmware_SFX}
		}
	;;
	mvebu)
		case "${TARGET_SUBTARGET}" in
		cortexa53 | cortexa72)
			[[ -f ${Legacy_Firmware} ]] && {
				MD5=$(md5sum ${Legacy_Firmware} | cut -c1-3)
				SHA256=$(sha256sum ${Legacy_Firmware} | cut -c1-3)
				SHA5BIT="${MD5}${SHA256}"
				cp ${Legacy_Firmware} $HOME_PATH/bin/Firmware/${AutoBuild_Firmware}-legacy-${SHA5BIT}${Firmware_SFX}
			}
			[[ -f ${UEFI_Firmware} ]] && {
				MD5=$(md5sum ${UEFI_Firmware} | cut -c1-3)
				SHA256=$(sha256sum ${UEFI_Firmware} | cut -c1-3)
				SHA5BIT="${MD5}${SHA256}"
				cp ${UEFI_Firmware} $HOME_PATH/bin/Firmware/${AutoBuild_Firmware}-uefi-${SHA5BIT}${Firmware_SFX}
			}
		;;
		esac
	;;
	*)
		[[ -f ${Up_Firmware} ]] && {
			MD5=$(md5sum ${Up_Firmware} | cut -c1-3)
			SHA256=$(sha256sum ${Up_Firmware} | cut -c1-3)
			SHA5BIT="${MD5}${SHA256}"
			cp ${Up_Firmware} $HOME_PATH/bin/Firmware/${AutoBuild_Firmware}-sysupgrade-${SHA5BIT}${Firmware_SFX}
		} || {
			echo "Firmware is not detected !"
		}
	;;
	esac
	cd $HOME_PATH
	rm -rf "${Firmware_Path}"
	rm -rf "${Transfer_Path}"
	rm -rf "${Discard_Path}"
}

Mkdir() {
	_DIR=${1}
	if [ ! -d "${_DIR}" ];then
		mkdir -p ${_DIR}
	fi
	unset _DIR
}
