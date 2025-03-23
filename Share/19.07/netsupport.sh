#!/bin/bash

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

if [[ "${REPO_BRANCH}" == *"19.07"* ]]; then
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/19.07/19.07/include/netfilter.mk -o ${HOME_PATH}/include/netfilter.mk
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/Share/19.07/19.07/package/kernel/linux/modules/netfilter.mk -o ${HOME_PATH}/package/kernel/linux/modules/netfilter.mk
fi

if [[ "${REPO_BRANCH}" == *"21.02"* ]]; then
  curl -fsSL https://raw.githubusercontent.com/Lienol/openwrt/d9d9e37e348f2753ff2c6c3958d46dfc573f20de/package/kernel/linux/modules/netfilter.mk -o ${HOME_PATH}/package/kernel/linux/modules/netfilter.mk
  curl -fsSL https://raw.githubusercontent.com/Lienol/openwrt/d9d9e37e348f2753ff2c6c3958d46dfc573f20de/include/netfilter.mk -o ${HOME_PATH}/include/netfilter.mk
fi

# 19.07补丁
if [[ "${REPO_BRANCH}" == *"19.07"* ]]; then
  gitsvn https://github.com/openwrt/packages/tree/openwrt-21.02/libs/libcap ${HOME_PATH}/feeds/packages/libs/libcap
  gitsvn https://github.com/coolsnowwolf/packages/tree/master/net/kcptun ${HOME_PATH}/feeds/packages/net/kcptun
  gitsvn https://github.com/openwrt/openwrt/tree/openwrt-23.05/tools/cmake ${HOME_PATH}/tools/cmake
  gitsvn https://github.com/openwrt/packages/tree/openwrt-23.05/lang/ruby ${HOME_PATH}/feeds/packages/lang/ruby
  gitsvn https://github.com/openwrt/packages/tree/openwrt-23.05/libs/yaml ${HOME_PATH}/feeds/packages/libs/yaml
fi

if [[ "${REPO_BRANCH}" == *"22.03"* ]]; then
  gitsvn https://github.com/coolsnowwolf/packages/tree/master/libs/pcre2 ${HOME_PATH}/feeds/packages/libs/pcre2
  gitsvn https://github.com/coolsnowwolf/packages/tree/master/libs/glib2 ${HOME_PATH}/feeds/packages/libs/glib2
  gitsvn https://github.com/coolsnowwolf/packages/tree/master/net/openssh ${HOME_PATH}/feeds/packages/net/openssh
  gitsvn https://github.com/coolsnowwolf/lede/tree/master/toolchain/gcc ${HOME_PATH}/toolchain/gcc
  gitsvn https://github.com/coolsnowwolf/packages/tree/master/libs/libwebsockets ${HOME_PATH}/feeds/packages/libs/libwebsockets
  rm -fr ${HOME_PATH}/feeds/luci/applications/luci-app-ntpc
fi



function gitsvn() {
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
         echo "${file_name}文件下载完成"
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
      echo "${file_name}文件下载完成"
    else
      echo "${file_name}文件下载失败"
    fi
elif [[ "${git_laqu}" == "3" ]]; then
    rm -fr "${content}"
    if git clone -q --depth 1 "${url}" "${content}"; then
      echo "${file_name}文件下载完成"
    else
      echo "${file_name}文件下载失败"
    fi
elif [[ "${git_laqu}" == "4" ]]; then
    [[ ! -d "${parent_dir}" ]] && mkdir -p "${parent_dir}"
    curl -fsSL "${url}" -o "${content}"
    if [[ -s "${content}" ]]; then
      echo "${file_name}文件下载完成"
      chmod +x "${content}"
    else
      echo "${file_name}文件下载失败"
    fi
fi
}
