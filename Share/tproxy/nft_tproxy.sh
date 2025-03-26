#!/bin/bash

cd ${HOME_PATH}

function gitcon() {
cd "${HOME_PATH}"
local A="${1%.git}"
local B="$2"
local branch_name=""
local path_part=""
local url=""
tmpdir="$(mktemp -d)" && C="$HOME_PATH/${tmpdir#*.}"
rm -fr "${tmpdir}"
if [[ $A =~ tree/([^/]+)(/(.*))? ]]; then
    branch_name="${BASH_REMATCH[1]}"
    path_part="${BASH_REMATCH[3]:-}"
elif [[ $A =~ blob/([^/]+)(/(.*))? ]]; then
    branch_name="${BASH_REMATCH[1]}"
    path_part="${BASH_REMATCH[3]:-}"
    ck_name="$(echo "${A}"|cut -d"/" -f4-5)"
elif [[ "$A" == *"github.com"* ]]; then
    branch_name="1"
else
    echo "无效的GitHub URL格式"
    return 1
fi

if [[ -z "$B" ]]; then
    echo "没设置文件投放路径"
    return 1
elif [[ "$B" == *"openwrt"* ]]; then
    content="$HOME_PATH/${B#*openwrt/}"
    wenjianjia="${B#*openwrt/}"
elif [[ "$B" == *"./"* ]]; then
    content="$HOME_PATH/${B#*./}"
    wenjianjia="${B#*./}"
else
    content="$HOME_PATH/$B"
    wenjianjia="${B}"
fi

if [[ "$A" == *"tree"* ]] && [[ -n "${path_part}" ]]; then
    url="${A%%/tree/*}"
    file_name="${A##*/}"
    git_laqu="1"
elif [[ "$A" == *"tree"* ]] && [[ -n "${branch_name}" ]] && [[ -z "${path_part}" ]]; then
    url="${A%%/tree/*}"
    file_name="$(echo "${A}" |cut -d"/" -f5)"
    git_laqu="2"
elif [[ "${branch_name}" == "1" ]]; then
    url="${A}"
    file_name="$(echo "${A}" |cut -d"/" -f5)"
    git_laqu="3"
elif [[ "$A" == *"blob"* ]]; then
    url="https://raw.githubusercontent.com/${ck_name}/${branch_name}/${path_part}"
    file_name="${path_part}"
    parent_dir="${wenjianjia%/*}"
    git_laqu="4"
fi

if [[ "${git_laqu}" == "1" ]]; then
    if git clone -q --no-checkout "$url" "$C"; then
      cd "${C}"
      git sparse-checkout init --cone > /dev/null 2>&1
      git sparse-checkout set "${path_part}" > /dev/null 2>&1
      git checkout "${branch_name}" > /dev/null 2>&1
      rm -fr "${content}"
      mv "${path_part}" "${content}"
      if [[ $? -ne 0 ]]; then
         echo "${file_name}文件投放失败,请检查投放路径是否正确"
      else
         echo "文件下载完成"
      fi
      cd "${HOME_PATH}"
    else
      echo "${file_name}文件下载失败"
    fi
    [[ "${file_name}" == "auto-scripts" ]] && chmod +x "${content}"
    cd "${HOME_PATH}"
    rm -fr "$C"
elif [[ "${git_laqu}" == "2" ]]; then
    rm -fr "${content}"
    if git clone -q --single-branch --depth=1 --branch=${branch_name} ${url} ${content}; then
      echo "文件下载完成"
    else
      echo "${file_name}文件下载失败"
    fi
elif [[ "${git_laqu}" == "3" ]]; then
    rm -fr "${content}"
    if git clone -q --depth 1 "${url}" "${content}"; then
      echo "文件下载完成"
    else
      echo "${file_name}文件下载失败"
    fi
elif [[ "${git_laqu}" == "4" ]]; then
    [[ ! -d "${parent_dir}" ]] && mkdir -p "${parent_dir}"
    curl -fsSL "${url}" -o "${content}"
    if [[ -s "${content}" ]]; then
      echo "文件下载完成"
      chmod +x "${content}"
    else
      echo "${file_name}文件下载失败"
    fi
fi
}

netsupportmk="${HOME_PATH}/package/kernel/linux/modules/netsupport.mk"
if [[ `grep -c "KernelPackage/netlink-diag" $netsupportmk` -eq '0' ]]; then
echo "
define KernelPackage/netlink-diag
  SUBMENU:=\$(NETWORK_SUPPORT_MENU)
  TITLE:=Netlink diag support for ss utility
  KCONFIG:=CONFIG_NETLINK_DIAG
  FILES:=\$(LINUX_DIR)/net/netlink/netlink_diag.ko
  AUTOLOAD:=\$(call AutoLoad,31,netlink-diag)
endef

define KernelPackage/netlink-diag/description
 Netlink diag is a module made for use with iproute2's ss utility
endef

\$(eval \$(call KernelPackage,netlink-diag))
" >>  $netsupportmk
fi

if [[ `grep -c "KernelPackage/inet-diag" $netsupportmk` -eq '0' ]]; then
echo "
define KernelPackage/inet-diag
  SUBMENU:=\$(NETWORK_SUPPORT_MENU)
  TITLE:=INET diag support for ss utility
  KCONFIG:= \\
	CONFIG_INET_DIAG \\
	CONFIG_INET_TCP_DIAG \\
	CONFIG_INET_UDP_DIAG \\
	CONFIG_INET_RAW_DIAG \\
	CONFIG_INET_DIAG_DESTROY=n
  FILES:= \\
	\$(LINUX_DIR)/net/ipv4/inet_diag.ko \\
	\$(LINUX_DIR)/net/ipv4/tcp_diag.ko \\
	\$(LINUX_DIR)/net/ipv4/udp_diag.ko \\
	\$(LINUX_DIR)/net/ipv4/raw_diag.ko
  AUTOLOAD:=\$(call AutoLoad,31,inet_diag tcp_diag udp_diag raw_diag)
endef

define KernelPackage/inet-diag/description
Support for INET (TCP, DCCP, etc) socket monitoring interface used by
native Linux tools such as ss.
endef

\$(eval \$(call KernelPackage,inet-diag))
" >>  $netsupportmk
fi

iproutemk="${HOME_PATH}/package/network/utils/iproute2/Makefile"
if [[ `grep -c "kmod-netlink-diag" $iproutemk` -eq '0' ]] && \
   [[ `grep -c "Socket statistics utility" $iproutemk` -eq '1' ]]; then
   ax="$(grep -n "Socket statistics utility" -A 1 ${iproutemk} |awk 'END {print}' |grep -Eo [0-9]+)"
   sed -i "${ax}s?.*?  DEPENDS:=+libnl-tiny +(PACKAGE_devlink||PACKAGE_rdma):libmnl +(PACKAGE_tc||PACKAGE_ip-full):libelf +PACKAGE_ip-full:libcap +kmod-netlink-diag?" ${iproutemk}
fi

if [[ "${REPO_BRANCH}" == *"19.07"* ]]; then
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/19.07/include/netfilter.mk -o ${HOME_PATH}/include/netfilter.mk
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/19.07/package/kernel/linux/modules/netfilter.mk -o ${HOME_PATH}/package/kernel/linux/modules/netfilter.mk
fi

if [[ "${REPO_BRANCH}" == *"21.02"* ]]; then
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/openwrt-21.02/package/kernel/linux/modules/netfilter.mk -o ${HOME_PATH}/package/kernel/linux/modules/netfilter.mk
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/openwrt-21.02/include/netfilter.mk -o ${HOME_PATH}/include/netfilter.mk
fi

if [[ "${REPO_BRANCH}" == "openwrt-18.06-k5.4" ]]; then
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/openwrt-18.06-k5.4/package/kernel/linux/modules/netfilter.mk -o ${HOME_PATH}/package/kernel/linux/modules/netfilter.mk
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/openwrt-18.06-k5.4/include/netfilter.mk -o ${HOME_PATH}/include/netfilter.mk
fi

if [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/openwrt-18.06/package/kernel/linux/modules/netfilter.mk -o ${HOME_PATH}/package/kernel/linux/modules/netfilter.mk
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/openwrt-18.06/include/netfilter.mk -o ${HOME_PATH}/include/netfilter.mk
fi

# 19.07补丁
if [[ "${REPO_BRANCH}" == *"19.07"* ]]; then
  gitcon https://github.com/openwrt/packages/tree/2db418f6707af1a938d6c033aa81946334c1a8bb/libs/libcap ${HOME_PATH}/feeds/packages/libs/libcap
  gitcon https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/net/kcptun ${HOME_PATH}/feeds/packages/net/kcptun
  if [[ "${SOURCE_CODE}" == "OFFICIAL" ]]; then
    gitcon https://github.com/openwrt/openwrt/tree/202d404f743a49a50e253c54f43ebd47fd028496/tools/cmake ${HOME_PATH}/tools/cmake
  else
    gitcon https://github.com/openwrt/openwrt/tree/45082d4e51935bb3e8eab255dd69c87f6f9310b0/tools/cmake ${HOME_PATH}/tools/cmake
  fi
  gitcon https://github.com/openwrt/packages/tree/47ea48c09d61610e2d599b94f66f90e21164db1c/lang/ruby ${HOME_PATH}/feeds/packages/lang/ruby
  gitcon https://github.com/openwrt/packages/tree/47ea48c09d61610e2d599b94f66f90e21164db1c/libs/yaml ${HOME_PATH}/feeds/packages/libs/yaml
fi

if [[ "${REPO_BRANCH}" == *"22.03"* ]]; then
  gitcon https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/libs/pcre2 ${HOME_PATH}/feeds/packages/libs/pcre2
  gitcon https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/libs/glib2 ${HOME_PATH}/feeds/packages/libs/glib2
  gitcon https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/net/openssh ${HOME_PATH}/feeds/packages/net/openssh
  gitcon https://github.com/coolsnowwolf/lede/tree/326599e3d08d7fe1dc084e1c87581cdf5a8e41a6/toolchain/gcc ${HOME_PATH}/toolchain/gcc
  gitcon https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/libs/libwebsockets ${HOME_PATH}/feeds/packages/libs/libwebsockets
  curl -fsSL https://raw.githubusercontent.com/Lienol/openwrt/d9d9e37e348f2753ff2c6c3958d46dfc573f20de/package/kernel/linux/modules/netfilter.mk -o ${HOME_PATH}/package/kernel/linux/modules/netfilter.mk
  curl -fsSL https://raw.githubusercontent.com/Lienol/openwrt/d9d9e37e348f2753ff2c6c3958d46dfc573f20de/include/netfilter.mk -o ${HOME_PATH}/include/netfilter.mk
  rm -fr ${HOME_PATH}/feeds/luci/applications/luci-app-ntpc
fi

if [[ "${SOURCE_CODE}" == "MT798X" ]] && [[ "${REPO_BRANCH}" =~ (openwrt-21.02|openwrt-23.05) ]]; then
  git clone --single-branch --depth=1 --branch=2410 https://github.com/padavanonly/immortalwrt-mt798x-24.10 mt798xmk
  cp -r mt798xmk/package/boot/uboot-envtools/files/mediatek_filogic package/boot/uboot-envtools/files/mediatek_filogic
  cp -r mt798xmk/target/linux/mediatek/image/mt7981.mk target/linux/mediatek/image/mt7981.mk
  cp -r mt798xmk/target/linux/mediatek/image/mt7986.mk target/linux/mediatek/image/mt7986.mk
  rm -rf target/linux/mediatek/mt7981 && cp -r mt798xmk/target/linux/mediatek/mt7981 target/linux/mediatek/mt7981
  rm -rf target/linux/mediatek/mt7986 && cp -r mt798xmk/target/linux/mediatek/mt7986 target/linux/mediatek/mt7986
  rm -rf target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek && cp -r mt798xmk/target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek
  rm -rf mt798xmk
  gitcon https://github.com/hanwckf/immortalwrt-mt798x/tree/openwrt-21.02/package/network/services/hostapd package/network/services/hostapd
fi

if [[ "${REPO_BRANCH}" == *"23.05"* ]] && [[ "${SOURCE_CODE}" == "MT798X" ]]; then
  gitcon https://github.com/281677160/common/tree/main/Share/tproxy/openwrt-23.05/package/kernel/linux/modules/crypto.mk package/kernel/linux/modules/crypto.mk
  gitcon https://github.com/281677160/common/tree/main/Share/tproxy/openwrt-23.05/package/kernel/linux/modules/netsupport.mk package/kernel/linux/modules/netsupport.mk
  gitcon https://github.com/immortalwrt/immortalwrt/tree/openwrt-23.05/package/network/config/swconfig package/network/config/swconfig
  gitcon https://github.com/hanwckf/immortalwrt-mt798x/tree/openwrt-21.02/package/firmware package/firmware
  gitcon https://github.com/hanwckf/immortalwrt-mt798x/tree/openwrt-21.02/package/kernel/mac80211 package/kernel/mac80211
fi
