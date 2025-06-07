#!/bin/bash

function nfttproxy() {
cd ${HOME_PATH}
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

if [[ "${REPO_BRANCH}" == *"21.02"* ]]; then
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/openwrt-21.02/package/kernel/linux/modules/netfilter.mk -o ${HOME_PATH}/package/kernel/linux/modules/netfilter.mk
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/openwrt-21.02/include/netfilter.mk -o ${HOME_PATH}/include/netfilter.mk
  rm -rf ${HOME_PATH}/feeds/packages/devel/gn
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
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/19.07/include/netfilter.mk -o ${HOME_PATH}/include/netfilter.mk
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/tproxy/19.07/package/kernel/linux/modules/netfilter.mk -o ${HOME_PATH}/package/kernel/linux/modules/netfilter.mk
  gitsvn https://github.com/openwrt/packages/tree/2db418f6707af1a938d6c033aa81946334c1a8bb/libs/libcap ${HOME_PATH}/feeds/packages/libs/libcap
  gitsvn https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/net/kcptun ${HOME_PATH}/feeds/packages/net/kcptun
  if [[ "${SOURCE_CODE}" == "OFFICIAL" ]]; then
    gitsvn https://github.com/openwrt/openwrt/tree/202d404f743a49a50e253c54f43ebd47fd028496/tools/cmake ${HOME_PATH}/tools/cmake
  else
    gitsvn https://github.com/openwrt/openwrt/tree/45082d4e51935bb3e8eab255dd69c87f6f9310b0/tools/cmake ${HOME_PATH}/tools/cmake
  fi
  gitsvn https://github.com/openwrt/packages/tree/47ea48c09d61610e2d599b94f66f90e21164db1c/lang/ruby ${HOME_PATH}/feeds/packages/lang/ruby
  gitsvn https://github.com/openwrt/packages/tree/47ea48c09d61610e2d599b94f66f90e21164db1c/libs/yaml ${HOME_PATH}/feeds/packages/libs/yaml
fi

if [[ "${REPO_BRANCH}" == *"22.03"* ]]; then
  gitsvn https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/libs/pcre2 ${HOME_PATH}/feeds/packages/libs/pcre2
  gitsvn https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/libs/glib2 ${HOME_PATH}/feeds/packages/libs/glib2
  gitsvn https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/net/openssh ${HOME_PATH}/feeds/packages/net/openssh
  gitsvn https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/net/dnsproxy ${HOME_PATH}/feeds/packages/net/dnsproxy
  gitsvn https://github.com/coolsnowwolf/lede/tree/326599e3d08d7fe1dc084e1c87581cdf5a8e41a6/package/libs/libjson-c ${HOME_PATH}/package/libs/libjson-c
  gitsvn https://github.com/coolsnowwolf/lede/tree/326599e3d08d7fe1dc084e1c87581cdf5a8e41a6/toolchain/gcc ${HOME_PATH}/toolchain/gcc
  gitsvn https://github.com/immortalwrt/packages/tree/openwrt-23.05/devel/gn ${HOME_PATH}/feeds/packages/devel/gn
  gitsvn https://github.com/coolsnowwolf/packages/tree/152022403f0ab2a85063ae1cd9687bd5240fe9b7/libs/libwebsockets ${HOME_PATH}/feeds/packages/libs/libwebsockets
  curl -fsSL https://raw.githubusercontent.com/Lienol/openwrt/d9d9e37e348f2753ff2c6c3958d46dfc573f20de/package/kernel/linux/modules/netfilter.mk -o ${HOME_PATH}/package/kernel/linux/modules/netfilter.mk
  curl -fsSL https://raw.githubusercontent.com/Lienol/openwrt/d9d9e37e348f2753ff2c6c3958d46dfc573f20de/include/netfilter.mk -o ${HOME_PATH}/include/netfilter.mk
  rm -fr ${HOME_PATH}/feeds/luci/applications/luci-app-ntpc
fi

if [[ "${SOURCE_CODE}" == "MT798X" ]] && [[ "${REPO_BRANCH}" =~ (openwrt-21.02|openwrt-23.05) ]]; then
  if ! git clone -q https://github.com/danshui-git/mt798x-24.10 mt798xmk; then
    echo -e "\033[31m 拉取同步上游机型文件失败 \033[0m\n"
    exit 1
  fi
  rm -rf package/boot/uboot-envtools && cp -r mt798xmk/package/boot/uboot-envtools package/boot/uboot-envtools
  rm -rf package/boot/uboot-mediatek && cp -r mt798xmk/package/boot/uboot-mediatek package/boot/uboot-mediatek
  rm -rf package/boot/arm-trusted-firmware-mediatek && cp -r mt798xmk/package/boot/arm-trusted-firmware-mediatek package/boot/arm-trusted-firmware-mediatek

  rm -rf package/mtk && cp -r mt798xmk/package/mtk package/mtk
  rm -rf package/network/utils/ebtables && cp -r mt798xmk/package/network/utils/ebtables package/network/utils/ebtables
  [[ "${REPO_BRANCH}" == "openwrt-21.02" ]] && sed -i "s/+rpcd-mod-ucode//g" package/mtk/applications/luci-app-upnp-mtk-adjust/Makefile

  cp -r mt798xmk/target/linux/mediatek/image/mt7981.mk target/linux/mediatek/image/mt7981.mk
  cp -r mt798xmk/target/linux/mediatek/image/mt7986.mk target/linux/mediatek/image/mt7986.mk
  
  rm -rf target/linux/mediatek/mt7981 && cp -r mt798xmk/target/linux/mediatek/mt7981 target/linux/mediatek/mt7981
  rm -rf target/linux/mediatek/mt7986 && cp -r mt798xmk/target/linux/mediatek/mt7986 target/linux/mediatek/mt7986
  rm -rf target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek && cp -r mt798xmk/target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek
  rm -rf mt798xmk
  gitsvn https://github.com/immortalwrt/packages/tree/openwrt-24.10/net/hysteria feeds/packages/net/hysteria
  gitsvn https://github.com/hanwckf/immortalwrt-mt798x/tree/openwrt-21.02/package/network/services/hostapd package/network/services/hostapd
fi

if [[ "${REPO_BRANCH}" == *"23.05"* ]] && [[ "${SOURCE_CODE}" == "MT798X" ]]; then
  gitsvn https://github.com/281677160/common/tree/main/Share/tproxy/openwrt-23.05/package/kernel/linux/modules/crypto.mk package/kernel/linux/modules/crypto.mk
  gitsvn https://github.com/281677160/common/tree/main/Share/tproxy/openwrt-23.05/package/kernel/linux/modules/netsupport.mk package/kernel/linux/modules/netsupport.mk
  gitsvn https://github.com/immortalwrt/immortalwrt/tree/openwrt-23.05/package/network/config/swconfig package/network/config/swconfig
  gitsvn https://github.com/hanwckf/immortalwrt-mt798x/tree/openwrt-21.02/package/firmware package/firmware
  gitsvn https://github.com/hanwckf/immortalwrt-mt798x/tree/openwrt-21.02/package/kernel/mac80211 package/kernel/mac80211
fi
}

function gitsvn() {
local url="${1%.git}"
local route="$2"
local tmpdir="$(mktemp -d)"
local base_url=""
local repo_name=""
local branch=""
local path_after_branch=""
local last_part=""
local files_name=""
local download_url=""
local parent_dir=""
local store_away=""

if [[ "$url" == *"tree"* ]]; then
    base_url=$(echo "$url" | sed 's|/tree/.*||')
    repo_name=$(echo "$base_url" | awk -F'/' '{print $5}')
    branch=$(echo "$url" | awk -F'/tree/' '{print $2}' | cut -d'/' -f1)
    path_after_branch=$(echo "$url" | sed -n "s|.*/tree/$branch||p" | sed 's|^/||')
    last_part=$(echo "$path_after_branch" | awk -F'/' '{print $NF}')
    [[ -n "$path_after_branch" ]] && path_name="$tmpdir/$path_after_branch" || path_name="$tmpdir"
    [[ -n "$last_part" ]] && files_name="$last_part" || files_name="$repo_name"
    [[ -z "$repo_name" ]] && { echo "错误链接,仓库名为空"; return 1; }
elif [[ "$url" == *"blob"* ]]; then
    base_url=$(echo "$url" | sed 's|/blob/.*||')
    repo_name=$(echo "$base_url" | awk -F'/' '{print $5}')
    branch=$(echo "$url" | awk -F'/blob/' '{print $2}' | cut -d'/' -f1)
    path_after_branch=$(echo "$url" | sed -n "s|.*/blob/$branch||p" | sed 's|^/||')
    download_url="https://raw.githubusercontent.com/${base_url#*https://github.com/}/$branch/$path_after_branch"
    parent_dir="${path_after_branch%/*}"
    [[ -n "$path_after_branch" ]] && files_name="$path_after_branch" || { echo "错误链接,文件名为空"; return 1; }
elif [[ "$url" == *"https://github.com"* ]]; then
    base_url="$url"
    repo_name=$(echo "$base_url" | awk -F'/' '{print $5}')
    path_name="$tmpdir"
    [[ -n "$repo_name" ]] && files_name="$repo_name" || { echo "错误链接,仓库名为空"; return 1; }
else
    echo "无效的github链接"
    return 1
fi

if [[ "$route" == "all" ]]; then
    store_away="$HOME_PATH/"
elif [[ "$route" == *"openwrt"* ]]; then
    store_away="$HOME_PATH/${route#*openwrt/}"
elif [[ "$route" == *"./"* ]]; then
    store_away="$HOME_PATH/${route#*./}"
elif [[ -n "$route" ]]; then
    store_away="$HOME_PATH/$route"
else
    store_away="$HOME_PATH/$files_name"
fi

if [[ "$url" == *"tree"* ]] && [[ -n "$path_after_branch" ]]; then
    if git clone -q --no-checkout "$base_url" "$tmpdir"; then
        cd "$tmpdir"
        git sparse-checkout init --cone > /dev/null 2>&1
        git sparse-checkout set "$path_after_branch" > /dev/null 2>&1
        git checkout "$branch" > /dev/null 2>&1
        grep -rl 'include ../../luci.mk' . | xargs -r sed -i 's#include ../../luci.mk#include \$(TOPDIR)/feeds/luci/luci.mk#g'
        grep -rl 'include ../../lang/' . | xargs -r sed -i 's#include ../../lang/#include \$(TOPDIR)/feeds/packages/lang/#g'
        if [[ "$route" == "all" ]]; then
            find "$path_name" -mindepth 1 -printf '%P\n' | while read -r item; do
            target="$HOME_PATH/${item}"
            if [ -e "$target" ]; then
                rm -rf "$target"
            fi
            done
            cp -r "$path_name"/* "$store_away"
        else
            rm -rf "$store_away" && cp -r "$path_name" "$store_away"
        fi
        [[ $? -eq 0 ]] && echo "$files_name文件下载完成" || { echo "$files_name文件下载失败"; return 1; }
        cd "$HOME_PATH"
    else
        echo "$files_name文件下载失败"
        return 1
    fi
elif [[ "$url" == *"tree"* ]] && [[ -n "$branch" ]]; then
    if git clone -q --single-branch --depth=1 --branch="$branch" "$base_url" "$tmpdir"; then
        if [[ "$route" == "all" ]]; then
            find "$path_name" -mindepth 1 -printf '%P\n' | while read -r item; do
            target="$HOME_PATH/${item}"
            if [ -e "$target" ]; then
                rm -rf "$target"
            fi
            done
            cp -r "$path_name"/* "$store_away"
        else
            rm -rf "$store_away" && cp -r "$path_name" "$store_away"
        fi
        [[ $? -eq 0 ]] && echo "$files_name文件下载完成" || { echo "$files_name文件下载失败"; return 1; }
    else
        echo "$files_name文件下载失败"
        return 1
    fi
elif [[ "$url" == *"blob"* ]]; then
    if [[ -n "$(echo "$parent_dir" | grep -E '/')" ]]; then
        [[ ! -d "${parent_dir}" ]] && mkdir -p "${parent_dir}"
    fi
    if curl -fsSL "$download_url" -o "$store_away"; then
        echo "$files_name 文件下载成功"
    else
        echo "$files_name文件下载失败"
        return 1
    fi
elif [[ "$url" == *"https://github.com"* ]]; then
    if git clone -q --depth 1 "$base_url" "$tmpdir"; then
        if [[ "$route" == "all" ]]; then
            find "$path_name" -mindepth 1 -printf '%P\n' | while read -r item; do
            target="$HOME_PATH/${item}"
            if [ -e "$target" ]; then
                rm -rf "$target"
            fi
            done
            cp -r "$path_name"/* "$store_away"
        else
            rm -rf "$store_away" && cp -r "$path_name" "$store_away"
        fi
        [[ $? -eq 0 ]] && echo "$files_name文件下载完成" || { echo "$files_name文件下载失败"; return 1; }
    else
        echo "$files_name文件下载失败"
        return 1
    fi
else
    echo "无效的github链接"
    return 1
fi
rm -rf "$tmpdir"
}

nfttproxy
