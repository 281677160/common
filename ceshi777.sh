#!/bin/bash
# https://github.com/281677160/AutoBuild-OpenWrt
# common Module by 28677160
# matrix.target=${matrixtarget}

function TIME() {
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


function Diy_variable() {
echo "HOME_PATH=${GITHUB_WORKSPACE}/openwrt" >> $GITHUB_ENV
echo "BUILD_PATH=${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}" >> $GITHUB_ENV
echo "BASE_PATH=${GITHUB_WORKSPACE}/openwrt/package/base-files/files" >> $GITHUB_ENV
echo "Compile_Date=$(date +%Y%m%d%H%M)" >> $GITHUB_ENV
if [[ "${REPO_BRANCH}" == "master" ]]; then
  echo "ZZZ_PATH=${GITHUB_WORKSPACE}/openwrt/package/lean/default-settings/files/zzz-default-settings" >> $GITHUB_ENV
  echo "SOURCE=Lede" >> $GITHUB_ENV
  echo "MAINTAIN=Lean's" >> $GITHUB_ENV
  echo "LUCI_EDITION=18.06" >> $GITHUB_ENV
elif [[ "${REPO_BRANCH}" == "main" ]]; then
  echo "ZZZ_PATH=${GITHUB_WORKSPACE}/openwrt/package/default-settings/files/zzz-default-settings" >> $GITHUB_ENV
  echo "SOURCE=Lienol" >> $GITHUB_ENV
  echo "MAINTAIN=Lienol's" >> $GITHUB_ENV
  echo "LUCI_EDITION=20.06" >> $GITHUB_ENV
elif [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
  echo "ZZZ_PATH=${GITHUB_WORKSPACE}/openwrt/package/emortal/default-settings/files/99-default-settings" >> $GITHUB_ENV
  echo "SOURCE=Tianling" >> $GITHUB_ENV
  echo "MAINTAIN=CTCGFW's" >> $GITHUB_ENV
  echo "LUCI_EDITION=18.06" >> $GITHUB_ENV
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
  echo "ZZZ_PATH=${GITHUB_WORKSPACE}/openwrt/package/emortal/default-settings/files/99-default-settings" >> $GITHUB_ENV
  echo "SOURCE=Mortal" >> $GITHUB_ENV
  echo "MAINTAIN=CTCGFW's" >> $GITHUB_ENV
  echo "LUCI_EDITION=21.02" >> $GITHUB_ENV
else
  echo "没发现该源码的分支，如果您没更改过的话，应该是上游仓库修改了，请同步上游仓库"
  exit 1
fi
}

function Diy_settings() {
echo "Diy_settings"
  [[ -d "${GITHUB_WORKSPACE}/OP_DIY" ]] && {
    if [ -z "$(ls -A "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}" 2>/dev/null)" ]; then
      TIME r "错误提示：编译脚本缺少[${CONFIG_FILE}]名称的配置文件,请在[OP_DIY/${matrixtarget}]文件夹内补齐"
      exit 1
    fi
    if [ -z "$(ls -A "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${DIY_PART_SH}" 2>/dev/null)" ]; then
      TIME r "错误提示：编译脚本缺少[${DIY_PART_SH}]名称的自定义设置文件,请在[OP_DIY/${matrixtarget}]文件夹内补齐"
      exit 1
    fi
  } || {
    if [ -z "$(ls -A "$BUILD_PATH/${CONFIG_FILE}" 2>/dev/null)" ]; then
      TIME r "错误提示：编译脚本缺少[${CONFIG_FILE}]名称的配置文件,请在[build/${matrixtarget}]文件夹内补齐"
      exit 1
    fi
    if [ -z "$(ls -A "$BUILD_PATH/${DIY_PART_SH}" 2>/dev/null)" ]; then
      TIME r "错误提示：编译脚本缺少[${DIY_PART_SH}]名称的自定义设置文件,请在[build/${matrixtarget}]文件夹内补齐"
      exit 1
    fi
  }
 
}


function Diy_laku() {
echo "Diy_laku"
# 拉库和做标记，一次性操作

./scripts/feeds clean && ./scripts/feeds update -a

case "${REPO_BRANCH}" in
master)

  find . -name 'luci-app-netdata' -o -name 'netdata' -o -name 'luci-theme-argon' -o -name 'mentohust' | xargs -i rm -rf {}
  find . -name 'luci-app-ipsec-vpnd' -o -name 'luci-app-wol' | xargs -i rm -rf {}
  find . -name 'luci-app-wrtbwmon' -o -name 'wrtbwmon' | xargs -i rm -rf {}
  echo -e "\nDISTRIB_RECOGNIZE='18'" >> "$BASE_PATH/etc/openwrt_release" && sed -i '/^\s*$/d' "$BASE_PATH/etc/openwrt_release"

;;
main)

  find . -name 'luci-app-netdata' -o -name 'netdata' -o -name 'luci-app-ttyd' | xargs -i rm -rf {}
  find . -name 'ddns-scripts_aliyun' -o -name 'ddns-scripts_dnspod' -o -name 'luci-app-wol' | xargs -i rm -rf {}
  echo -e "\nDISTRIB_RECOGNIZE='20'" >> "$BASE_PATH/etc/openwrt_release" && sed -i '/^\s*$/d' "$BASE_PATH/etc/openwrt_release"

;;
openwrt-18.06)

  find . -name 'luci-app-argon-config' -o -name 'luci-theme-argon' -o -name 'luci-theme-argonv3' -o -name 'luci-theme-netgear' | xargs -i rm -rf {}
  find . -name 'luci-app-netdata' -o -name 'netdata' -o -name 'luci-app-cifs' | xargs -i rm -rf {}
  find . -name 'luci-app-wrtbwmon' -o -name 'wrtbwmon' -o -name 'luci-app-wol' | xargs -i rm -rf {}
  find . -name 'luci-app-adguardhome' -o -name 'adguardhome' -o -name 'luci-theme-opentomato' | xargs -i rm -rf {}
  echo -e "\nDISTRIB_RECOGNIZE='18'" >> "$BASE_PATH/etc/openwrt_release" && sed -i '/^\s*$/d' "$BASE_PATH/etc/openwrt_release"

;;
openwrt-21.02)

  find . -name 'luci-app-netdata' -o -name 'netdata' -o -name 'luci-app-cifs' | xargs -i rm -rf {}
  find . -name 'luci-app-wol' -o -name 'luci-app-argon-config' | xargs -i rm -rf {}
  find . -name 'luci-app-adguardhome' -o -name 'adguardhome' | xargs -i rm -rf {}
  echo -e "\nDISTRIB_RECOGNIZE='20'" >> "$BASE_PATH/etc/openwrt_release" && sed -i '/^\s*$/d' "$BASE_PATH/etc/openwrt_release"

;;
esac

echo "
src-git helloworld https://github.com/fw876/helloworld
src-git passwall https://github.com/281677160/openwrt-passwall
src-git danshui https://github.com/281677160/openwrt-package.git;${REPO_BRANCH}
" >> $HOME_PATH/feeds.conf.default
}


function sbin_openwrt() {
echo "sbin_openwrt"
[[ -f $BUILD_PATH/openwrt.sh ]] && cp -Rf $BUILD_PATH/openwrt.sh $BASE_PATH/sbin/openwrt
chmod 777 $BASE_PATH/sbin/openwrt
}


function Diy_Lede() {
echo "Diy_lede"
}


function Diy_Lienol() {
echo "Diy_lienol"

sed  -i  's/ luci-app-passwall//g' target/linux/*/Makefile
sed -i 's/DEFAULT_PACKAGES +=/DEFAULT_PACKAGES += luci-app-passwall/g' target/linux/*/Makefile
}


function Diy_Tianling() {
echo "Diy_tianling"
}


function Diy_Mortal() {
echo "Diy_mortal"
}


function Diy_amlogic() {
if [[ "${matrixtarget}" == "openwrt_amlogic" ]]; then
  echo "Diy_amlogic"
  # 修复NTFS格式优盘不自动挂载
  packages=" \
  block-mount fdisk usbutils badblocks ntfs-3g kmod-scsi-core kmod-usb-core \
  kmod-usb-ohci kmod-usb-uhci kmod-usb-storage kmod-usb-storage-extras kmod-usb2 kmod-usb3 \
  kmod-fs-ext4 kmod-fs-vfat kmod-fuse luci-app-amlogic unzip curl \
  brcmfmac-firmware-43430-sdio brcmfmac-firmware-43455-sdio kmod-brcmfmac wpad \
  lscpu htop iperf3 curl lm-sensors python3 losetup resize2fs tune2fs pv blkid lsblk parted \
  kmod-usb-net kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8150 kmod-usb-net-rtl8152
  "
  sed -i '/FEATURES+=/ { s/cpiogz //; s/ext4 //; s/ramdisk //; s/squashfs //; }' \
  target/linux/armvirt/Makefile
  for x in $packages; do
    sed -i "/DEFAULT_PACKAGES/ s/$/ $x/" $HOME_PATH/target/linux/armvirt/Makefile
  done

  # luci-app-cpufreq修改一些代码适配amlogic
  sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' $HOME_PATH/feeds/luci/applications/luci-app-cpufreq/Makefile
  # 为 armvirt 添加 autocore 支持
  sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' $HOME_PATH/package/lean/autocore/Makefile
fi
}


function Package_amlogic() {
git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git amlogic
[ -d amlogic/openwrt-armvirt ] || mkdir -p amlogic/openwrt-armvirt
cp -f $TARGET_BSGET/*.tar.gz amlogic/openwrt-armvirt/ && sync
cd amlogic
sudo chmod +x make
sudo ./make -d -b s905x3_s905x2_s905x_s905w_s905d_s922x_s912 -k 5.10.100_5.4.180 -a true
sudo mv -f $GITHUB_WORKSPACE/amlogic/out/* $TARGET_BSGET/ && sync
sudo rm -rf $GITHUB_WORKSPACE/amlogic
}


function Diy_indexhtm() {
echo "Diy_index.htm"
if [[ "${REPO_BRANCH}" == "master" ]]; then
  sed -i 's/distversion)%>/distversion)%><!--/g' package/lean/autocore/files/*/index.htm
  sed -i 's/luciversion)%>)/luciversion)%>)-->/g' package/lean/autocore/files/*/index.htm
  sed -i 's#localtime  = os.date()#localtime  = os.date("%Y-%m-%d") .. " " .. translate(os.date("%A")) .. " " .. os.date("%X")#g' package/lean/autocore/files/*/index.htm
fi
if [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
  sed -i 's/distversion)%>/distversion)%><!--/g' package/emortal/autocore/files/*/index.htm
  sed -i 's/luciversion)%>)/luciversion)%>)-->/g' package/emortal/autocore/files/*/index.htm
  sed -i 's#localtime  = os.date()#localtime  = os.date("%Y-%m-%d") .. " " .. translate(os.date("%A")) .. " " .. os.date("%X")#g' package/emortal/autocore/files/*/index.htm
fi
}


function Diy_patches() {
echo "Diy_patches"
mv $HOME_PATH/build/common/LEDE $HOME_PATH/build/common/${SOURCE}
if [[ -d "${GITHUB_WORKSPACE}/OP_DIY" ]]; then
  cp -Rf $HOME_PATH/build/common/${SOURCE}/* $BUILD_PATH
  cp -Rf ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/* $BUILD_PATH
else
  cp -Rf $HOME_PATH/build/common/${SOURCE}/* $BUILD_PATH
fi

if [ -n "$(ls -A "$BUILD_PATH/patches" 2>/dev/null)" ]; then
  find "$BUILD_PATH/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward --no-backup-if-mismatch"
fi
}


################################################################################################################
# 判断插件冲突
################################################################################################################
function Diy_chajian() {
echo "Diy_chajian"
make defconfig > /dev/null 2>&1
echo "TIME b \"					插件冲突信息\"" > ${HOME_PATH}/CHONGTU

if [[ `grep -c "CONFIG_PACKAGE_luci-app-docker=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-dockerman=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-docker=y/# CONFIG_PACKAGE_luci-app-docker is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-docker-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-docker-zh-cn is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-docker和luci-app-dockerman，插件有冲突，相同功能插件只能二选一，已删除luci-app-docker\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-advanced=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-fileassistant=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-fileassistant=y/# CONFIG_PACKAGE_luci-app-fileassistant is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-advanced和luci-app-fileassistant，luci-app-advanced已附带luci-app-fileassistant，所以删除了luci-app-fileassistant\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
   fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-adblock-plus=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-adblock=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-adblock=y/# CONFIG_PACKAGE_luci-app-adblock is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_adblock=y/# CONFIG_PACKAGE_adblock is not set/g' ${HOME_PATH}/.config
    sed -i '/luci-i18n-adblock/d' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-adblock-plus和luci-app-adblock，插件有依赖冲突，只能二选一，已删除luci-app-adblock\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-kodexplorer=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-vnstat=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-vnstat=y/# CONFIG_PACKAGE_luci-app-vnstat is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_vnstat=y/# CONFIG_PACKAGE_vnstat is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_vnstati=y/# CONFIG_PACKAGE_vnstati is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_libgd=y/# CONFIG_PACKAGE_libgd is not set/g' ${HOME_PATH}/.config
    sed -i '/luci-i18n-vnstat/d' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-kodexplorer和luci-app-vnstat，插件有依赖冲突，只能二选一，已删除luci-app-vnstat\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-ssr-plus=y" ${HOME_PATH}/.config` -ge '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-cshark=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-cshark=y/# CONFIG_PACKAGE_luci-app-cshark is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_cshark=y/# CONFIG_PACKAGE_cshark is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_libustream-mbedtls=y/# CONFIG_PACKAGE_libustream-mbedtls is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-ssr-plus和luci-app-cshark，插件有依赖冲突，只能二选一，已删除luci-app-cshark\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_wpad-openssl=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_wpad=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_wpad=y/# CONFIG_PACKAGE_wpad is not set/g' ${HOME_PATH}/.config
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_dnsmasq-full=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_dnsmasq=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_PACKAGE_dnsmasq-dhcpv6=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_dnsmasq=y/# CONFIG_PACKAGE_dnsmasq is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_dnsmasq-dhcpv6=y/# CONFIG_PACKAGE_dnsmasq-dhcpv6 is not set/g' ${HOME_PATH}/.config
  fi
  if [[ `grep -c "CONFIG_PACKAGE_dnsmasq_full_conntrack=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_dnsmasq_full_conntrack=y/# CONFIG_PACKAGE_dnsmasq_full_conntrack is not set/g' ${HOME_PATH}/.config
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-samba4=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-samba=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_autosamba=y/# CONFIG_PACKAGE_autosamba is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-app-samba=y/# CONFIG_PACKAGE_luci-app-samba is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-samba-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-samba-zh-cn is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_samba36-server=y/# CONFIG_PACKAGE_samba36-server is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-samba和luci-app-samba4，插件有冲突，相同功能插件只能二选一，已删除luci-app-samba\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon_new=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-theme-argon_new=y/# CONFIG_PACKAGE_luci-theme-argon_new is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-theme-argon和luci-theme-argon_new，插件有冲突，相同功能插件只能二选一，已删除luci-theme-argon_new\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-sfe=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-flowoffload=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_DEFAULT_luci-app-flowoffload=y/# CONFIG_DEFAULT_luci-app-flowoffload is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-app-flowoffload=y/# CONFIG_PACKAGE_luci-app-flowoffload is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-flowoffload-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-flowoffload-zh-cn is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"提示：您同时选择了luci-app-sfe和luci-app-flowoffload，两个ACC网络加速，已删除luci-app-flowoffload\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-ssl=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_libustream-wolfssl=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-ssl=y/# CONFIG_PACKAGE_luci-ssl is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_libustream-wolfssl=y/CONFIG_PACKAGE_libustream-wolfssl=m/g' ${HOME_PATH}/.config
    echo "TIME r \"您选择了luci-ssl会自带libustream-wolfssl，会和libustream-openssl冲突导致编译错误，已删除luci-ssl\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-unblockneteasemusic=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-unblockneteasemusic-go=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-unblockneteasemusic-go=y/# CONFIG_PACKAGE_luci-app-unblockneteasemusic-go is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您选择了luci-app-unblockneteasemusic-go，会和luci-app-unblockneteasemusic冲突导致编译错误，已删除luci-app-unblockneteasemusic-go\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-unblockmusic=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-unblockmusic=y/# CONFIG_PACKAGE_luci-app-unblockmusic is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您选择了luci-app-unblockmusic，会和luci-app-unblockneteasemusic冲突导致编译错误，已删除luci-app-unblockmusic\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_ntfs-3g=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  mkdir -p ${HOME_PATH}/files/etc/hotplug.d/block && curl -fsSL  https://raw.githubusercontent.com/281677160/openwrt-package/usb/block/10-mount > ${HOME_PATH}/files/etc/hotplug.d/block/10-mount
fi

if [[ `grep -c "CONFIG_TARGET_x86=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_rockchip=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_bcm27xx=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  sed -i '/IMAGES_GZIP/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_TARGET_IMAGES_GZIP=y" >> "${HOME_PATH}/.config"
  sed -i '/CONFIG_PACKAGE_openssh-sftp-server/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_PACKAGE_openssh-sftp-server=y" >> "${HOME_PATH}/.config"
  sed -i '/CONFIG_GRUB_IMAGES/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_GRUB_IMAGES=y" >> "${HOME_PATH}/.config"
fi
if [[ `grep -c "CONFIG_TARGET_mxs=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_sunxi=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_zynq=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  sed -i '/IMAGES_GZIP/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_TARGET_IMAGES_GZIP=y" >> "${HOME_PATH}/.config"
  sed -i '/CONFIG_PACKAGE_openssh-sftp-server/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_PACKAGE_openssh-sftp-server=y" >> "${HOME_PATH}/.config"
  sed -i '/CONFIG_GRUB_IMAGES/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_GRUB_IMAGES=y" >> "${HOME_PATH}/.config"
fi

if [[ `grep -c "CONFIG_TARGET_armvirt=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  sed -i 's/CONFIG_PACKAGE_luci-app-autoupdate=y/# CONFIG_PACKAGE_luci-app-autoupdate is not set/g' ${HOME_PATH}/.config
  export REGULAR_UPDATE="false"
  echo "REGULAR_UPDATE=false" >> $GITHUB_ENV
  sed -i '/CONFIG_PACKAGE_openssh-sftp-server/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_PACKAGE_openssh-sftp-server=y" >> "${HOME_PATH}/.config"
fi

if [[ `grep -c "CONFIG_TARGET_ROOTFS_EXT4FS=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  PARTSIZE="$(egrep -o "CONFIG_TARGET_ROOTFS_PARTSIZE=[0-9]+" ${HOME_PATH}/.config |cut -f2 -d=)"
  if [[ "${PARTSIZE}" -lt "950" ]];then
    sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' ${HOME_PATH}/.config
    echo -e "\nCONFIG_TARGET_ROOTFS_PARTSIZE=950" >> ${HOME_PATH}/.config
    echo "TIME g \" \"" > ${HOME_PATH}/EXT4
    echo "TIME r \"EXT4提示：请注意，您选择了ext4安装的固件格式,而检测到您的分配的固件系统分区过小\"" >> ${HOME_PATH}/EXT4
    echo "TIME y \"为避免编译出错,建议修改成950或者以上比较好,已自动帮您修改成950M\"" >> ${HOME_PATH}/EXT4
    echo "TIME g \" \"" >> ${HOME_PATH}/EXT4
  fi
fi

if [ -n "$(ls -A "${HOME_PATH}/Chajianlibiao" 2>/dev/null)" ]; then
  echo "TIME y \"  插件冲突会导致编译失败，以上操作如非您所需，请关闭此次编译，重新开始编译，避开冲突重新选择插件\"" >>CHONGTU
  echo "TIME z \"\"" >>CHONGTU
else
  rm -rf CHONGTU
fi

echo
echo
if [ -n "$(ls -A "${HOME_PATH}/EXT4" 2>/dev/null)" ]; then
  chmod -R +x ${HOME_PATH}/EXT4
  source ${HOME_PATH}/EXT4
  [[ -d "${GITHUB_WORKSPACE}/OP_DIY" ]] && rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao,EXT4}
  echo
fi
if [ -n "$(ls -A "${HOME_PATH}/Chajianlibiao" 2>/dev/null)" ]; then
  chmod -R +x ${HOME_PATH}/CHONGTU
  source ${HOME_PATH}/CHONGTU
  [[ -d "${GITHUB_WORKSPACE}/OP_DIY" ]] && rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao}
  echo
fi
}


function Diy_adguardhome() {
if [[ `grep -c "CONFIG_PACKAGE_luci-app-adguardhome=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  echo "Diy_adguardhome"
  if [[ `grep -c "CONFIG_ARCH=\"x86_64\"" ${HOME_PATH}/.config` -eq '1' ]]; then
    Arch="amd64"
  elif [[ `grep -c "CONFIG_ARCH=\"i386\"" ${HOME_PATH}/.config` -eq '1' ]]; then
    Arch="i386"
  elif [[ `grep -c "CONFIG_ARCH=\"aarch64\"" ${HOME_PATH}/.config` -eq '1' ]]; then
    Arch="arm64"
  elif [[ `grep -c "CONFIG_ARCH=\"arm\"" ${HOME_PATH}/.config` -eq '1' ]] && [[ `grep -c "CONFIG_arm_v7=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    Arch="armv7"
  else
    echo "no shipei adguardhome"
  fi
	
  if [[ "${Arch}" =~ (amd64|i386|arm64|armv7) ]]; then
    downloader="curl -L -k --retry 2 --connect-timeout 20 -o"
    latest_ver="$($downloader - https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest 2>/dev/null|grep -E 'tag_name' |grep -E 'v[0-9.]+' -o 2>/dev/null)"
    wget -q https://github.com/AdguardTeam/AdGuardHome/releases/download/${latest_ver}/AdGuardHome_linux_${Arch}.tar.gz
    tar -zxvf AdGuardHome_linux_${Arch}.tar.gz -C $HOME_PATH

    if [[ -d "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}" ]]; then
      mkdir -p ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/files/usr/bin
      [[ -f "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/files/usr/bin/AdGuardHome" ]] && rm -rf "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/files/usr/bin/AdGuardHome"
      [[ -f "AdGuardHome/AdGuardHome" ]] && mv -f AdGuardHome/AdGuardHome ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/files/usr/bin/AdGuardHome
      [[ -f "AdGuardHome/AdGuardHome" ]] && chmod 777 ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/files/usr/bin/AdGuardHome
      rm -rf $HOME_PATH/{AdGuardHome_linux_${Arch}.tar.gz,AdGuardHome}
    else
      mkdir -p $HOME_PATH/files/usr/bin
      [[ -f "AdGuardHome/AdGuardHome" ]] && mv -f AdGuardHome/AdGuardHome $HOME_PATH/files/usr/bin
      [[ -f "AdGuardHome/AdGuardHome" ]] && chmod 777 $HOME_PATH/files/usr/bin/AdGuardHome
      rm -rf $HOME_PATH/{AdGuardHome_linux_${Arch}.tar.gz,AdGuardHome}
    fi
  fi
fi
}


function Diy_files() {
echo "Diy_files"
if [[ -d "${GITHUB_WORKSPACE}/OP_DIY" ]]; then
  cp -Rf $HOME_PATH/build/common/${SOURCE}/* $BUILD_PATH
  cp -Rf ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/* $BUILD_PATH
else
  cp -Rf $HOME_PATH/build/common/${SOURCE}/* $BUILD_PATH
fi

if [ -n "$(ls -A "$BUILD_PATH/diy" 2>/dev/null)" ]; then
  cp -Rf $BUILD_PATH/diy/* $HOME_PATH
fi
if [ -n "$(ls -A "$BUILD_PATH/files" 2>/dev/null)" ]; then
  cp -Rf $BUILD_PATH/files $HOME_PATH
fi
}


function Diy_zzz() {
echo "Diy_zzz"

case "${REPO_BRANCH}" in
master)

  sed -i "/exit 0/i\chmod +x /etc/webweb.sh && source /etc/webweb.sh" "$ZZZ_PATH"

;;
main)

  sed -i "/exit 0/i\chmod +x /etc/webweb.sh && source /etc/webweb.sh" "$ZZZ_PATH"
  
  DISTRIB="$(egrep -o "DISTRIB_DESCRIPTION='.* '" $ZZZ_PATH |sed -r "s/DISTRIB_DESCRIPTION='(.*) '/\1/")"
  [[ -n "${DISTRIB}" ]] && sed -i "s/${DISTRIB}/OpenWrt/g" "$ZZZ_PATH"

;;
openwrt-18.06)

  chmod -R 777 $HOME_PATH/build/common/Convert
  cp -Rf $HOME_PATH/build/common/Convert/1806-default-settings "$ZZZ_PATH"

;;
openwrt-21.02)

  chmod -R 777 $HOME_PATH/build/common/Convert
  cp -Rf $HOME_PATH/build/common/Convert/* "$HOME_PATH"
  /bin/bash Convert.sh

;;
esac

sed -i '$ s/exit 0$//' $BASE_PATH/etc/rc.local
echo '
if [[ `grep -c "coremark" /etc/crontabs/root` -eq "1" ]]; then
  sed -i "/coremark/d" /etc/crontabs/root
fi
/etc/init.d/network restart
/etc/init.d/uhttpd restart
exit 0
' >> $BASE_PATH/etc/rc.local
}


function Make_defconfig() {
make defconfig > /dev/null 2>&1
if [[ -d "${GITHUB_WORKSPACE}/OP_DIY" ]]; then
  export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' $HOME_PATH/.config)"
  export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' $HOME_PATH/.config)"
  if [[ `grep -c "CONFIG_TARGET_x86_64=y" $HOME_PATH/.config` -eq '1' ]]; then
    export TARGET_PROFILE="x86-64"
  elif [[ `grep -c "CONFIG_TARGET_x86=y" $HOME_PATH/.config` == '1' ]] && [[ `grep -c "CONFIG_TARGET_x86_64=y" $HOME_PATH/.config` == '0' ]]; then
    export TARGET_PROFILE="x86_32"
  elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" $HOME_PATH/.config` -eq '1' ]]; then
    export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" $HOME_PATH/.config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
  else
    export TARGET_PROFILE="${TARGET_BOARD}"
  fi
  export TARGET_BSGET="$HOME_PATH/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET"
else
  export TAR_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' $HOME_PATH/.config)"
  export TAR_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' $HOME_PATH/.config)"
  echo "TARGET_BOARD=$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' $HOME_PATH/.config)" >> $GITHUB_ENV
  echo "TARGET_SUBTARGET=$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' $HOME_PATH/.config)" >> $GITHUB_ENV
  echo "Compile_Date=$(date +%Y%m%d-%H%M)" >> $GITHUB_ENV
  if [ `grep -c "CONFIG_TARGET_x86_64=y" $HOME_PATH/.config` -eq '1' ]; then
    echo "TARGET_PROFILE=x86-64" >> $GITHUB_ENV
  elif [[ `grep -c "CONFIG_TARGET_x86=y" $HOME_PATH/.config` == '1' ]] && [[ `grep -c "CONFIG_TARGET_x86_64=y" $HOME_PATH/.config` == '0' ]]; then
    echo "TARGET_PROFILE=x86_32" >> $GITHUB_ENV
  elif [ `grep -c "CONFIG_TARGET.*DEVICE.*=y" $HOME_PATH/.config` -eq '1' ]; then
    grep '^CONFIG_TARGET.*DEVICE.*=y' $HOME_PATH/.config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
    [ -s DEVICE_NAME ] && echo "TARGET_PROFILE=$(cat DEVICE_NAME)" >> $GITHUB_ENV
  else
    echo "TARGET_PROFILE=$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' $HOME_PATH/.config)" >> $GITHUB_ENV
  fi
  echo "TARGET_BSGET=$HOME_PATH/bin/targets/$TAR_BOARD/$TAR_SUBTARGET" >> $GITHUB_ENV
fi
}


function Diy_firmware() {
# 整理固件
if [ "${REGULAR_UPDATE}" == "true" ]; then
  cp -Rf ${TARGET_BSGET} $HOME_PATH/upgrade
fi
cd ${TARGET_BSGET}
rm -rf packages
rename -v "s/^immortalwrt/openwrt/" *
if [[ -f ${GITHUB_WORKSPACE}/Clear ]]; then
  cp -Rf ${GITHUB_WORKSPACE}/Clear ${TARGET_BSGET}/Clear.sh
  chmod +x ${TARGET_BSGET}/Clear.sh && ${TARGET_BSGET}/Clear.sh
  rm -rf ${TARGET_BSGET}/Clear.sh
fi
rename -v "s/^openwrt/${{ env.date1 }}-${{ env.SOURCE }}/" *

# 发布用的update_log.txt
if [ "${UPLOAD_RELEASE}" == "true" ]; then
  echo "### $(date +"%Y年%m月%d号-%H点%M分")" > ${GITHUB_WORKSPACE}/update_log.txt
fi
}	

################################################################################################################
# 编译信息
################################################################################################################
function Diy_xinxi() {

Plug_in="$(grep -i 'CONFIG_PACKAGE_luci-app' $HOME_PATH/.config && grep -i 'CONFIG_PACKAGE_luci-theme' $HOME_PATH/.config)"
Plug_in2="$(echo "${Plug_in}" | grep -v '^#' |sed '/INCLUDE/d' |sed '/_Transparent_Proxy/d' |sed '/qbittorrent_static/d' |sed 's/CONFIG_PACKAGE_//g' |sed 's/=y//g' |sed 's/^/、/g' |sed 's/$/\"/g' |awk '$0=NR$0' |sed 's/^/TIME g \"       /g')"
echo "${Plug_in2}" >Plug-in

echo
TIME b "编译源码: ${SOURCE}"
TIME b "源码链接: ${REPO_URL}"
TIME b "源码分支: ${REPO_BRANCH}"
TIME b "源码作者: ${MAINTAIN}"
TIME b "Luci版本: ${LUCI_EDITION}"
[[ "${matrixtarget}" == "openwrt_amlogic" ]] && {
	TIME b "编译机型: 晶晨系列"
} || {
	TIME b "编译机型: ${TARGET_PROFILE}"
}
TIME b "固件作者: ${Author}"
TIME b "仓库地址: ${Github}"
TIME b "启动编号: #${Run_number}（${CangKu}仓库第${Run_number}次启动[${Run_workflow}]工作流程）"
TIME b "编译时间: ${Compte}"
[[ "${matrixtarget}" == "openwrt_amlogic" ]] && {
	TIME g "友情提示：您当前使用【${matrixtarget}】文件夹编译【晶晨系列】固件"
} || {
	TIME g "友情提示：您当前使用【${matrixtarget}】文件夹编译【${TARGET_PROFILE}】固件"
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
if [[ ${UPLOAD_WETRANSFER} == "true" ]]; then
  TIME y "上传固件至【WETRANSFER】: 开启"
else
  TIME r "上传固件至【WETRANSFER】: 关闭"
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
if [[ ${BY_INFORMATION} == "true" ]]; then
  TIME y "编译信息显示: 开启"
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
  TIME g "《编译成功后，会自动把固件发布到指定地址，然后才会生成云端路径》"
  TIME g "《普通的那个发布固件跟云端的发布路径是两码事，如果你不需要普通发布的可以不用打开发布功能》"
  TIME g "修改IP、DNS、网关或者在线更新，请输入命令：openwrt"
  echo
else
  echo
fi
echo
TIME z " 系统空间      类型   总数  已用  可用 使用率"
cd ../ && df -hT $PWD && cd $HOME_PATH
echo
echo
if [ -n "$(ls -A "${HOME_PATH}/EXT4" 2>/dev/null)" ]; then
  chmod -R +x ${HOME_PATH}/EXT4
  source ${HOME_PATH}/EXT4
  rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao,EXT4}
  echo
fi
if [ -n "$(ls -A "${HOME_PATH}/Chajianlibiao" 2>/dev/null)" ]; then
  chmod -R +x ${HOME_PATH}/CHONGTU
  source ${HOME_PATH}/CHONGTU
  rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao}
  echo
fi
if [ -n "$(ls -A "${HOME_PATH}/Plug-in" 2>/dev/null)" ]; then
  TIME r "	      已选插件列表"
  chmod -R +x ${HOME_PATH}/Plug-in
  source ${HOME_PATH}/Plug-in
  rm -rf ${HOME_PATH}/{Plug-in,Plug-2}
  echo
fi
}


function Start_notice() {
if [[ "${SERVERCHAN_SCKEY}" == "TELE" ]]; then
  curl -k --data chat_id="${{ secrets.TELEGRAM_CHAT_ID }}" --data "text=🎉 主人：您正在使用【${{matrix.target}}】文件夹编译固件中(${{env.CangKu}}仓库的#${{env.Run_number}}号),请耐心等待...... 😋" "https://api.telegram.org/bot${{ secrets.TELEGRAM_BOT_TOKEN }}/sendMessage"
elif [[ "${SERVERCHAN_SCKEY}" == "PUSH" ]]; then
  curl -k --data token="${{ secrets.PUSH_PLUS_TOKEN }}" --data title="开始编译【${{matrix.target}}】" --data "content=🎉 主人：您正在使用【${{matrix.target}}】文件夹编译固件中(${{env.CangKu}}仓库的#${{env.Run_number}}号),请耐心等待...... 😋💐" "http://www.pushplus.plus/send"
fi
}

function End_notice() {
if [[ "${SERVERCHAN_SCKEY}" == "TELE" ]]; then
  curl -k --data chat_id="${{ secrets.TELEGRAM_CHAT_ID }}" --data "text=我亲爱的✨主人✨：您使用【${{matrix.target}}】文件夹编译的[${{ env.CODE }}-${{ env.TARGET_PROFILE }}]固件(${{env.CangKu}}仓库的#${{env.Run_number}}号)顺利编译完成了！💐" "https://api.telegram.org/bot${{ secrets.TELEGRAM_BOT_TOKEN }}/sendMessage"
elif [[ "${SERVERCHAN_SCKEY}" == "PUSH" ]]; then
  curl -k --data token="${{ secrets.PUSH_PLUS_TOKEN }}" --data title="[${{ env.CODE }}-${{ env.TARGET_PROFILE }}]编译成功" --data "content=我亲爱的✨主人✨：您使用【${{matrix.target}}】文件夹编译的[${{ env.CODE }}-${{ env.TARGET_PROFILE }}]固件(${{env.CangKu}}仓库的#${{env.Run_number}}号)顺利编译完成了！💐" "http://www.pushplus.plus/send"
fi
}


function Diy_menu2() {
Diy_chajian
Diy_adguardhome
Diy_files
Diy_zzz
Make_defconfig
}

function Diy_menu() {
Diy_settings
Diy_laku
sbin_openwrt
Diy_${SOURCE}
Diy_amlogic
/bin/bash $BUILD_PATH/$DIY_PART_SH
Diy_indexhtm
Diy_patches
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
source $BUILD_PATH/upgrade.sh && Diy_Part1
fi
./scripts/feeds update -a
./scripts/feeds install -a > /dev/null 2>&1
./scripts/feeds install -a
mv $BUILD_PATH/$CONFIG_FILE .config
}
