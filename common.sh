#!/bin/bash
# https://github.com/281677160/AutoBuild-OpenWrt
# common Module by 28677160
# matrix.target=${Modelfile}

TIME() {
Compte=$(date +%Y年%m月%d号%H时%M分)
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31m";;
	g) export Color="\e[32m";;
	b) export Color="\e[34m";;
	y) export Color="\e[33m";;
	z) export Color="\e[35m";;
	l) export Color="\e[36m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}

################################################################################################################
# LEDE源码通用diy.sh文件
################################################################################################################
Diy_lede() {
find . -name 'luci-app-netdata' -o -name 'netdata' -o -name 'luci-theme-argon' -o -name 'mentohust' | xargs -i rm -rf {}
find . -name 'luci-app-ipsec-vpnd' -o -name 'k3screenctrl' -o -name 'luci-app-fileassistant' | xargs -i rm -rf {}

sed -i '/to-ports 53/d' $ZZZ

git clone https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

sed -i "/exit 0/i\chmod +x /etc/webweb.sh && source /etc/webweb.sh" $ZZZ


if [[ "${Modelfile}" == "Lede_source" ]]; then
	sed -i '/IMAGES_GZIP/d' "${PATH1}/${CONFIG_FILE}" > /dev/null 2>&1
	echo -e "\nCONFIG_TARGET_IMAGES_GZIP=y" >> "${PATH1}/${CONFIG_FILE}"
fi
if [[ "${Modelfile}" == "openwrt_amlogic" ]]; then
	# 修复NTFS格式优盘不自动挂载
	packages=" \
	brcmfmac-firmware-43430-sdio brcmfmac-firmware-43455-sdio kmod-brcmfmac wpad \
	kmod-fs-ext4 kmod-fs-vfat kmod-fs-exfat dosfstools e2fsprogs ntfs-3g \
	kmod-usb2 kmod-usb3 kmod-usb-storage kmod-usb-storage-extras kmod-usb-storage-uas \
	kmod-usb-net kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 \
	blkid lsblk parted fdisk cfdisk losetup resize2fs tune2fs pv unzip \
	lscpu htop iperf3 curl lm-sensors python3 luci-app-amlogic
	"
	sed -i '/FEATURES+=/ { s/cpiogz //; s/ext4 //; s/ramdisk //; s/squashfs //; }' \
    		target/linux/armvirt/Makefile
	for x in $packages; do
    		sed -i "/DEFAULT_PACKAGES/ s/$/ $x/" target/linux/armvirt/Makefile
	done

	# luci-app-cpufreq修改一些代码适配amlogic
	sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' package/lean/luci-app-cpufreq/Makefile
	# 为 armvirt 添加 autocore 支持
	sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' package/lean/autocore/Makefile
fi
}


################################################################################################################
# LIENOL源码通用diy.sh文件
################################################################################################################
Diy_lienol() {
find . -name 'luci-app-netdata' -o -name 'netdata' -o -name 'luci-theme-argon' -o -name 'luci-app-fileassistant' | xargs -i rm -rf {}
find . -name 'ddns-scripts_aliyun' -o -name 'ddns-scripts_dnspod' | xargs -i rm -rf {}
rm -rf feeds/packages/libs/libcap

git clone https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

sed -i 's/DEFAULT_PACKAGES +=/DEFAULT_PACKAGES += luci-app-passwall/g' target/linux/x86/Makefile
sed -i "/exit 0/i\chmod +x /etc/webweb.sh && source /etc/webweb.sh" $ZZZ
}


################################################################################################################
# 天灵源码21.02 diy.sh文件
################################################################################################################
Diy_mortal() {

find . -name 'luci-app-argon-config' -o -name 'luci-theme-argon' -o -name 'luci-light' -o -name 'luci-app-fileassistant'  | xargs -i rm -rf {}
find . -name 'luci-app-netdata' -o -name 'netdata' -o -name 'luci-theme-openwrt' -o -name 'luci-app-cifs' | xargs -i rm -rf {}
}


################################################################################################################
# 全部作者源码公共diy.sh文件
################################################################################################################
Diy_all() {
git clone --depth 1 -b "${REPO_BRANCH}" https://github.com/281677160/openwrt-package
cp -Rf openwrt-package/* "${Home}" && rm -rf "${Home}"/openwrt-package

if [[ ${REGULAR_UPDATE} == "true" ]]; then
	git clone https://github.com/281677160/luci-app-autoupdate feeds/luci/applications/luci-app-autoupdate
	cp -Rf "${PATH1}"/{AutoUpdate.sh,replace.sh} package/base-files/files/bin
fi
if [[ "${REPO_BRANCH}" == "master" ]]; then
	cp -Rf "${Home}"/build/common/LEDE/files "${Home}"
	cp -Rf "${Home}"/build/common/LEDE/diy/* "${Home}"
	cp -Rf "${Home}"/build/common/LEDE/patches/* "${PATH1}/patches"
elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
	cp -Rf "${Home}"/build/common/LIENOL/files "${Home}"
	cp -Rf "${Home}"/build/common/LIENOL/diy/* "${Home}"
	cp -Rf "${Home}"/build/common/LIENOL/patches/* "${PATH1}/patches"
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
	cp -Rf "${Home}"/build/common/MORTAL/files "${Home}"
	cp -Rf "${Home}"/build/common/MORTAL/diy/* "${Home}"
	cp -Rf "${Home}"/build/common/MORTAL/patches/* "${PATH1}/patches"
	chmod -R 777 ${Home}/build/common/Convert
	cp -Rf ${Home}/build/common/Convert/* "${Home}"
	/bin/bash Convert.sh
fi
if [ -n "$(ls -A "${PATH1}/diy" 2>/dev/null)" ]; then
	cp -Rf "${PATH1}"/diy/* "${Home}"
fi
if [ -n "$(ls -A "${PATH1}/files" 2>/dev/null)" ]; then
	cp -Rf "${PATH1}/files" "${Home}" && chmod -R +x ${Home}/files
fi
if [ -n "$(ls -A "${PATH1}/patches" 2>/dev/null)" ]; then
	find "${PATH1}/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward --no-backup-if-mismatch"
fi
if [[ "${REPO_BRANCH}" == "master" ]]; then
	sed -i 's/distversion)%>/distversion)%><!--/g' package/lean/autocore/files/*/index.htm
	sed -i 's/luciversion)%>)/luciversion)%>)-->/g' package/lean/autocore/files/*/index.htm
fi
if [ -n "$(ls -A "feeds/luci/applications/luci-app-rebootschedule" 2>/dev/null)" ]; then
	chmod -R 775 feeds/luci/applications/luci-app-rebootschedule
fi
}

################################################################################################################
# s905x3_s905x2_s905x_s905d_s922x_s912 一键打包脚本
################################################################################################################
Diy_amlogic() {
git clone https://github.com/ophub/amlogic-s9xxx-openwrt
mv amlogic-s9xxx-openwrt/{amlogic-s9xxx,make} $GITHUB_WORKSPACE
rm -rf amlogic-s9xxx-openwrt
source $GITHUB_WORKSPACE/amlogic_openwrt
if [[ ${amlogic_kernel} == "5.12.12_5.4.127" ]]; then
	curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-openwrt/main/.github/workflows/build-openwrt-lede.yml > open.yml
	Make_kernel="$(cat open.yml | grep ./make | cut -d "k" -f3 | sed s/[[:space:]]//g)"
	amlogic_kernel="${Make_kernel}"
else
	amlogic_kernel="${amlogic_kernel}"
fi
if [[ -z "${Make_kernel}" ]];then
	amlogic_kernel="5.12.12_5.4.127"
fi
minsize="$(egrep -o "ROOT_MB=+.*?[0-9]" $GITHUB_WORKSPACE/make)"
rootfssize="ROOT_MB=${rootfs_size}"
sed -i "s/"${minsize}"/"${rootfssize}"/g" $GITHUB_WORKSPACE/make
mkdir -p $GITHUB_WORKSPACE/openwrt-armvirt
cp -Rf ${Home}/bin/targets/*/*/*.tar.gz $GITHUB_WORKSPACE/openwrt-armvirt/ && sync
sudo chmod +x make
sudo ./make -d -b "${amlogic_model}" -k "${amlogic_kernel}"
cp -Rf $GITHUB_WORKSPACE/out/* ${Home}/bin/targets/*/*
}

################################################################################################################
# 判断脚本是否缺少主要文件（如果缺少settings.ini设置文件在检测脚本设置就运行错误了）
################################################################################################################
Diy_settings() {
rm -rf ${Home}/build/QUEWENJIANerros
if [ -z "$(ls -A "$PATH1/${CONFIG_FILE}" 2>/dev/null)" ]; then
	echo
	TIME r "错误提示：编译脚本缺少[${CONFIG_FILE}]名称的配置文件,请在[build/${Modelfile}]文件夹内补齐"
	echo "errors" > ${Home}/build/QUEWENJIANerros
	echo
fi
if [ -z "$(ls -A "$PATH1/${DIY_PART_SH}" 2>/dev/null)" ]; then
	echo
	TIME r "错误提示：编译脚本缺少[${DIY_PART_SH}]名称的自定义设置文件,请在[build/${Modelfile}]文件夹内补齐"
	echo "errors" > ${Home}/build/QUEWENJIANerros
	echo
fi
if [ -n "$(ls -A "${Home}/build/QUEWENJIANerros" 2>/dev/null)" ]; then
rm -rf ${Home}/build/QUEWENJIANerros
exit 1
fi
rm -rf {build,README.md}
}


################################################################################################################
# 判断插件冲突
################################################################################################################
Diy_chajian() {
echo
echo "TIME b \"					插件冲突信息\"" > ${Home}/CHONGTU

if [[ `grep -c "CONFIG_PACKAGE_luci-app-docker=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-app-dockerman=y" ${Home}/.config` -eq '1' ]]; then
		sed -i 's/CONFIG_PACKAGE_luci-app-docker=y/# CONFIG_PACKAGE_luci-app-docker=y is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-i18n-docker-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-docker-zh-cn=y is not set/g' ${Home}/.config
		echo "TIME r \"您同时选择luci-app-docker和luci-app-dockerman，插件有冲突，相同功能插件只能二选一，已删除luci-app-docker\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "TIME b \"插件冲突信息\"" > ${Home}/Chajianlibiao
	fi
	
fi
if [[ `grep -c "CONFIG_PACKAGE_luci-app-samba4=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-app-samba=y" ${Home}/.config` -eq '1' ]]; then
		sed -i 's/CONFIG_PACKAGE_autosamba=y/# CONFIG_PACKAGE_autosamba is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-app-samba=y/# CONFIG_PACKAGE_luci-app-samba is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-i18n-samba-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-samba-zh-cn is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_samba36-server=y/# CONFIG_PACKAGE_samba36-server is not set/g' ${Home}/.config
		echo "TIME r \"您同时选择luci-app-samba和luci-app-samba4，插件有冲突，相同功能插件只能二选一，已删除luci-app-samba\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "TIME b \"插件冲突信息\"" > ${Home}/Chajianlibiao
	fi
	
fi
if [[ `grep -c "CONFIG_PACKAGE_luci-app-autotimeset=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-app-autoreboot=y" ${Home}/.config` -eq '1' ]]; then
		sed -i 's/CONFIG_PACKAGE_luci-app-autoreboot=y/# CONFIG_PACKAGE_luci-app-autoreboot is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-i18n-autoreboot-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-autoreboot-zh-cn=y is not set/g' ${Home}/.config
		echo "TIME r \"您同时选择luci-app-autotimeset和luci-app-autoreboot，插件有冲突，相同功能插件只能二选一，已删除luci-app-autoreboot\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "插件冲突信息\"" > ${Home}/Chajianlibiao
	fi
	
fi
if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon_new=y" ${Home}/.config` -eq '1' ]]; then
		sed -i 's/CONFIG_PACKAGE_luci-theme-argon_new=y/# CONFIG_PACKAGE_luci-theme-argon_new is not set/g' ${Home}/.config
		echo "TIME r \"您同时选择luci-theme-argon和luci-theme-argon_new，插件有冲突，相同功能插件只能二选一，已删除luci-theme-argon_new\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "TIME b \"插件冲突信息\"" > ${Home}/Chajianlibiao
	fi

fi
if [[ `grep -c "CONFIG_PACKAGE_luci-app-sfe=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-app-flowoffload=y" ${Home}/.config` -eq '1' ]]; then
		sed -i 's/CONFIG_DEFAULT_luci-app-flowoffload=y/# CONFIG_DEFAULT_luci-app-flowoffload is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-app-flowoffload=y/# CONFIG_PACKAGE_luci-app-flowoffload is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-i18n-flowoffload-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-flowoffload-zh-cn is not set/g' ${Home}/.config
		echo "TIME r \"提示：您同时选择了luci-app-sfe和luci-app-flowoffload，两个ACC网络加速，已删除luci-app-flowoffload\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "TIME b \"插件冲突信息\"" > ${Home}/Chajianlibiao
	fi
fi
if [[ `grep -c "CONFIG_PACKAGE_luci-i18n-qbittorrent-zh-cn=y" ${Home}/.config` -eq '0' ]]; then
	sed -i 's/CONFIG_PACKAGE_luci-app-qbittorrent_static=y/# CONFIG_PACKAGE_luci-app-qbittorrent_static is not set/g' ${Home}/.config
	sed -i 's/CONFIG_DEFAULT_luci-app-qbittorrent=y/# CONFIG_DEFAULT_luci-app-qbittorrent is not set/g' ${Home}/.config
	sed -i 's/CONFIG_PACKAGE_luci-app-qbittorrent_dynamic=y/# CONFIG_PACKAGE_luci-app-qbittorrent_dynamic is not set/g' ${Home}/.config
	sed -i 's/CONFIG_PACKAGE_qBittorrent-static=y/# CONFIG_PACKAGE_qBittorrent-static is not set/g' ${Home}/.config
	sed -i 's/CONFIG_PACKAGE_qbittorrent=y/# CONFIG_PACKAGE_qbittorrent is not set/g' ${Home}/.config
fi
if [[ `grep -c "CONFIG_TARGET_ROOTFS_EXT4FS=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_TARGET_ROOTFS_PARTSIZE" ${Home}/.config` -eq '0' ]]; then
		sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' ${Home}/.config > /dev/null 2>&1
		echo -e "\nCONFIG_TARGET_ROOTFS_PARTSIZE=950" >> ${Home}/.config
	fi
	egrep -o "CONFIG_TARGET_ROOTFS_PARTSIZE=+.*?[0-9]" ${Home}/.config > ${Home}/EXT4PARTSIZE
	sed -i 's|CONFIG_TARGET_ROOTFS_PARTSIZE=||g' ${Home}/EXT4PARTSIZE
	PARTSIZE="$(cat EXT4PARTSIZE)"
	if [[ "${PARTSIZE}" -lt "950" ]];then
		sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' ${Home}/.config > /dev/null 2>&1
		echo -e "\nCONFIG_TARGET_ROOTFS_PARTSIZE=950" >> ${Home}/.config
		echo "TIME g \" \"" > ${Home}/EXT4
		echo "TIME r \"EXT4提示：请注意，您选择了ext4安装的固件格式,而检测到您的分配的固件系统分区过小\"" >> ${Home}/EXT4
		echo "TIME y \"为避免编译出错,建议修改成950或者以上比较好,已帮您修改成950M\"" >> ${Home}/EXT4
		echo "TIME g \" \"" >> ${Home}/EXT4
	fi
	rm -rf ${Home}/EXT4PARTSIZE
fi
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	echo "TIME y \"  插件冲突会导致编译失败，以上操作如非您所需，请关闭此次编译，重新开始编译，避开冲突重新选择插件\"" >>CHONGTU
	echo "TIME z \"\"" >>CHONGTU
else
	rm -rf CHONGTU
fi
}


################################################################################################################
# 为编译做最后处理
################################################################################################################
Diy_chuli() {

if [[ "${TARGET_PROFILE}" == "x86-64" ]]; then
	cp -Rf "${Home}"/build/common/Custom/DRM-I915 target/linux/x86/DRM-I915
	for X in $(ls -1 target/linux/x86 | grep "config-"); do echo -e "\n$(cat target/linux/x86/DRM-I915)" >> target/linux/x86/${X}; done
fi

if [[ "${Modelfile}" == "openwrt_amlogic" ]]; then
	[[ -e $GITHUB_WORKSPACE/amlogic_openwrt ]] && source $GITHUB_WORKSPACE/amlogic_openwrt
	[[ "${amlogic_kernel}" == "5.12.12_5.4.127" ]] && {
		curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-openwrt/main/.github/workflows/build-openwrt-lede.yml > open.yml
		Make_ker="$(cat open.yml | grep ./make | cut -d "k" -f3 | sed s/[[:space:]]//g)"
		TARGET_kernel="${Make_ker}"
		TARGET_model="${amlogic_model}"
	} || {
		TARGET_kernel="${amlogic_kernel}"
		TARGET_model="${amlogic_model}"
	}
fi

if [[ `grep -c "CONFIG_ARCH=\"x86_64\"" ${Home}/.config` -eq '1' ]]; then
	Arch="amd64"
elif [[ `grep -c "CONFIG_ARCH=\"i386\"" ${Home}/.config` -eq '1' ]]; then
	Arch="i386"
elif [[ `grep -c "CONFIG_ARCH=\"aarch64\"" ${Home}/.config` -eq '1' ]]; then
	Arch="arm64"
fi
if [[ `grep -c "CONFIG_ARCH=\"arm\"" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_arm_v7=y" ${Home}/.config` -eq '1' ]]; then
		Arch="armv7"
	fi	
fi
if [[ "${Arch}" =~ (amd64|i386|mipsle_softfloat|armeb|armv7) ]]; then
	downloader="curl -L -k --retry 2 --connect-timeout 20 -o"
	latest_ver="$($downloader - https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest 2>/dev/null|grep -E 'tag_name' |grep -E 'v[0-9.]+' -o 2>/dev/null)"
	wget -q https://github.com/AdguardTeam/AdGuardHome/releases/download/${latest_ver}/AdGuardHome_linux_${Arch}.tar.gz
	tar -zxvf AdGuardHome_linux_${Arch}.tar.gz -C ${Home}
	mkdir -p files/usr/bin
	mv -f AdGuardHome/AdGuardHome files/usr/bin
	chmod 777 files/usr/bin/AdGuardHome
	rm -rf {AdGuardHome_linux_${Arch}.tar.gz,AdGuardHome}
fi

if [[ "${BY_INFORMATION}" == "true" ]]; then
	grep -i CONFIG_PACKAGE_luci-app .config | grep  -v \# > Plug-in
	grep -i CONFIG_PACKAGE_luci-theme .config | grep  -v \# >> Plug-in
	if [[ `grep -c "CONFIG_PACKAGE_luci-i18n-qbittorrent-zh-cn=y" ${Home}/.config` -eq '0' ]]; then
		if [[ `grep -c "luci-app-qbittorrent_static" ${Home}/Plug-in` -eq '1' ]]; then
			sed -i '/qbittorrent/d' Plug-in
		fi
	fi
	sed -i '/INCLUDE/d' Plug-in > /dev/null 2>&1
	sed -i 's/CONFIG_PACKAGE_/、/g' Plug-in
	sed -i 's/=y/\"/g' Plug-in
	awk '$0=NR$0' Plug-in > Plug-2
	awk '{print "	" $0}' Plug-2 > Plug-in
	sed -i "s/^/TIME g \"/g" Plug-in
	cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c > CPU
	cat /proc/cpuinfo | grep "cpu cores" | uniq >> CPU
	sed -i 's|[[:space:]]||g; s|^.||' CPU && sed -i 's|CPU||g; s|pucores:||' CPU
	CPUNAME="$(awk 'NR==1' CPU)" && CPUCORES="$(awk 'NR==2' CPU)"
	rm -rf CPU
	if [[ `grep -c "KERNEL_PATCHVER:=" ${Home}/target/linux/${TARGET_BOARD}/Makefile` -eq '1' ]]; then
		PATCHVER=$(grep KERNEL_PATCHVER:= ${Home}/target/linux/${TARGET_BOARD}/Makefile | cut -c18-100)
	elif [[ `grep -c "KERNEL_PATCHVER=" ${Home}/target/linux/${TARGET_BOARD}/Makefile` -eq '1' ]]; then
		PATCHVER=$(grep KERNEL_PATCHVER= ${Home}/target/linux/${TARGET_BOARD}/Makefile | cut -c17-100)
	else
		PATCHVER="unknown"
	fi
	if [[ ! "${PATCHVER}" == "unknown" ]]; then
		PATCHVER=$(egrep -o "${PATCHVER}.[0-9]+" ${Home}/include/kernel-version.mk)
	fi
fi
find . -name 'README' -o -name 'README.md' | xargs -i rm -rf {}
find . -name 'CONTRIBUTED.md' -o -name 'README_EN.md' -o -name 'DEVICE_NAME' | xargs -i rm -rf {}
}


################################################################################################################
# 公告
################################################################################################################
GONGGAO() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
	case $1 in
		r) export Color="\e[31;1m";;
		g) export Color="\e[32m";;
		b) export Color="\e[34m";;
		y) export Color="\e[33m";;
		z) export Color="\e[36m";;
	esac
		echo -e "\n\e[35;1m[$(date "+ 公 告 ")]\e[0m ${Color}${2}\e[0m"
	}
}

Diy_gonggao() {
GONGGAO z "《Lede_source文件，Luci版本为18.06，内核版本为5.10》"
GONGGAO y "《Lienol_source文件，Luci版本为19.07，内核版本为4.14》"
GONGGAO g "《Mortal_source文件，Luci版本为21.02，内核版本为5.4》"
GONGGAO z "《openwrt_amlogic文件，编译N1和晶晨系列盒子专用，Luci版本为18.06，内核版本为5.4》"
GONGGAO g "第一次用我仓库的，请不要拉取任何插件，先SSH进入固件配置那里看过我脚本实在是没有你要的插件才再拉取"
GONGGAO g "拉取插件应该单独拉取某一个你需要的插件，别一下子就拉取别人一个插件包，这样容易增加编译失败概率"
GONGGAO r "《如果编译脚本在这里就出现错误的话，意思就是不得不更新脚本了，怎么更新我会在这里写明》"
GONGGAO y "7月11号修复定时更新不保存改过的IP、DNS、DHCP的问题，修复不保存adguardhome配置文件问题"
GONGGAO g "7月12号把luci-app-ddnsto插件,重新加入插件包"
GONGGAO g "7月12号修复LEDE源码不选择qbittorrent都会显示带有这个插件的问题"
GONGGAO g "LEDE源码默认是带两套qbittorrent插件的，一套完整版，一套精简版"
GONGGAO g "精简版不管你选择没选择qbittorrentd都会默认编译进固件的，就是在页面不显示而已"
GONGGAO g "我写了个判断，如果不选择qbittorrentd就把相关的默认选项都去除了"
GONGGAO g "重新改了一下定时更新插件的MD5对比方式,有用定时更新插件的更新仓库后重新编译的固件自己手动安装一次,以后才会对比MD5成功,要不然一直对比失败的"
echo
echo
}

Diy_tongzhi() {
GONGGAO r "7月12号修复LEDE源码不选择qbittorrent都会显示带有这个插件的问题"
GONGGAO r "LEDE源码默认是带两套qbittorrent插件的，一套完整版，一套精简版"
GONGGAO r "精简版不管你选择没选择qbittorrentd都会默认编译进固件的，就是在页面不显示而已"
GONGGAO r "我写了个判断，如果不选择qbittorrentd就把相关的默认选项都去除了"
GONGGAO y "重新改了一下定时更新插件的MD5对比方式,有用定时更新插件的更新仓库后重新编译的固件自己手动安装一次,以后才会对比MD5成功,要不然一直对比失败的"
GONGGAO y "手动安装的意思就是编译好固件后，下载出来，然后在openwrt后台自己更新一次不保存配置的更新"
GONGGAO y "最近更新的比较频繁，希望大家理解，谢谢！"
GONGGAO g "这一次更新，你们只要复制我仓库的build-openwrt.yml内容覆盖到你仓库的build-openwrt.yml上就可以了，麻烦大家了！"
echo
echo
exit 1
}

################################################################################################################
# 编译信息
################################################################################################################
Diy_xinxi_Base() {
GET_TARGET_INFO
if [[ "${TARGET_PROFILE}" =~ (friendlyarm_nanopi-r2s|friendlyarm_nanopi-r4s|armvirt) ]]; then
	REGULAR_UPDATE="false"
fi
echo
TIME b "编译源码: ${CODE}"
TIME b "源码链接: ${REPO_URL}"
TIME b "源码分支: ${REPO_BRANCH}"
TIME b "源码作者: ${ZUOZHE}"
TIME b "默认内核: ${PATCHVER}"
TIME b "Luci版本: ${OpenWrt_name}"
[[ "${Modelfile}" == "openwrt_amlogic" ]] && {
	TIME b "编译机型: ${TARGET_model}"
	TIME b "打包内核: ${TARGET_kernel}"
} || {
	TIME b "编译机型: ${TARGET_PROFILE}"
}
TIME b "固件作者: ${Author}"
TIME b "仓库地址: ${Github}"
TIME b "启动编号: #${Run_number}（${CangKu}仓库第${Run_number}次启动[${Run_workflow}]工作流程）"
TIME b "编译时间: ${Compte}"
[[ "${Modelfile}" == "openwrt_amlogic" ]] && {
	TIME g "友情提示：您当前使用【${Modelfile}】文件夹编译【${TARGET_model}】固件"
} || {
	TIME g "友情提示：您当前使用【${Modelfile}】文件夹编译【${TARGET_PROFILE}】固件"
}
echo
echo
if [[ ${UPLOAD_FIRMWARE} == "true" ]]; then
	TIME y "上传固件在github actions: 开启"
else
	TIME r "上传固件在github actions: 关闭"
fi
if [[ ${UPLOAD_CONFIG} == "true" ]]; then
	TIME y "上传[.config]配置文件: 开启"
else
	TIME r "上传[.config]配置文件: 关闭"
fi
if [[ ${UPLOAD_BIN_DIR} == "true" ]]; then
	TIME y "上传BIN文件夹(固件+IPK): 开启"
else
	TIME r "上传BIN文件夹(固件+IPK): 关闭"
fi
if [[ ${UPLOAD_COWTRANSFER} == "true" ]]; then
	TIME y "上传固件至【奶牛快传】和【WETRANSFER】: 开启"
else
	TIME r "上传固件至【奶牛快传】和【WETRANSFER】: 关闭"
fi
if [[ ${UPLOAD_RELEASE} == "true" ]]; then
	TIME y "发布固件: 开启"
else
	TIME r "发布固件: 关闭"
fi
if [[ ${SERVERCHAN_SCKEY} == "true" ]]; then
	TIME y "微信/电报通知: 开启"
else
	TIME r "微信/电报通知: 关闭"
fi
if [[ ${SSH_ACTIONS} == "true" ]]; then
	TIME y "SSH远程连接: 开启"
else
	TIME r "SSH远程连接: 关闭"
fi
if [[ ${BY_INFORMATION} == "true" ]]; then
	TIME y "编译信息显示: 开启"
fi
if [[ ${SSHYC} == "true" ]]; then
	TIME y "SSH远程连接临时开关: 开启"
fi
if [[ ${REGULAR_UPDATE} == "true" ]]; then
	TIME y "把定时自动更新插件编译进固件: 开启"
else
	TIME r "把定时自动更新插件编译进固件: 关闭"
fi
if [[ ${REGULAR_UPDATE} == "true" ]]; then
	echo
	TIME l "定时自动更新信息"
	TIME z "插件版本: ${AutoUpdate_Version}"
	if [[ ${TARGET_PROFILE} == "x86-64" ]]; then
		TIME b "传统固件: ${Legacy_Firmware}"
		TIME b "UEFI固件: ${UEFI_Firmware}"
		TIME b "固件后缀: ${Firmware_sfx}"
	else
		TIME b "固件名称: ${Up_Firmware}"
		TIME b "固件后缀: ${Firmware_sfx}"
	fi
	TIME b "固件版本: ${Openwrt_Version}"
	TIME b "云端路径: ${Github_UP_RELEASE}"
	TIME g "《编译成功，会自动把固件发布到指定地址，然后才会生成云端路径》"
	TIME g "《普通的那个发布固件跟云端的发布路径是两码事，如果你不需要普通发布的可以不用打开发布功能》"
	TIME g "《请把“REPO_TOKEN”密匙设置好,没设置好密匙运行到 “把定时更新固件发布到云端” 步骤就会出错,生成不了云端地址》"
	TIME g "《设置密匙教程： https://github.com/danshui-git/shuoming/blob/master/jm.md 》"
	echo
else
	echo
fi
echo
TIME z " 系统空间      类型   总数  已用  可用 使用率"
cd ../ && df -hT $PWD && cd openwrt
echo
echo
TIME z "  本服务器的CPU型号为[ ${CPUNAME} ]"
echo
TIME z "  在此系统上使用核心数为[ ${CPUCORES} ],线程数为[ $(nproc) ]"
echo
TIME z "  经过几次测试,随机分配到E5系列CPU编译是最慢的,8171M的CPU快很多，8272CL的又比8171M快一丢丢！"
echo
TIME z "  如果你编译的插件较多，而你又分配到E5系列CPU的话，你可以考虑关闭了重新再来的！"
echo
TIME z "  下面将使用[ $(nproc)线程 ]编译固件"
if [ -n "$(ls -A "${Home}/EXT4" 2>/dev/null)" ]; then
	echo
	echo
	chmod -R +x ${Home}/EXT4
	source ${Home}/EXT4
	rm -rf EXT4
fi
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	echo
	echo
	chmod -R +x ${Home}/CHONGTU
	source ${Home}/CHONGTU
	rm -rf {CHONGTU,Chajianlibiao}
fi
if [ -n "$(ls -A "${Home}/Plug-in" 2>/dev/null)" ]; then
	echo
	echo
	TIME r "	      已选插件列表"
	chmod -R +x ${Home}/Plug-in
	source ${Home}/Plug-in
	rm -rf {Plug-in,Plug-2}
	echo
fi
}
