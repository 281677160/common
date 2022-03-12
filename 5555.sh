#!/usr/bin/env bash

#====================================================
#	Author:	281677160
#	Dscription: openwrt onekey Management
#	github: https://github.com/281677160/build-actions
#====================================================

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"

function ECHOY() {
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}
function ECHOR() {
  echo -e "${Red} $1 ${Font}"
}
function ECHOB() {
  echo
  echo -e "${Blue} $1 ${Font}"
  echo
}
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOG() {
  echo -e "${Green} $1 ${Font}"
}
function print_ok() {
  echo -e " ${OK} ${Blue} $1 ${Font}"
}
function print_error() {
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
}
judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 完成,等待重启openwrt"
  else
    print_error "$1 失败"
  fi
}

if [ -f /bin/openwrt_info ]; then
  chmod +x /bin/openwrt_info && source /bin/openwrt_info
else
  print_error "未检测到openwrt_info文件,无法运行更新程序!"
  echo
  exit 1
fi
export Github="${Github}"
export Apidz="${Github##*com/}"
export Author="${Apidz%/*}"
export CangKu="${Apidz##*/}"
export Github_Tags="https://api.github.com/repos/${Apidz}/releases/tags/AutoUpdate"
export Github_Tagstwo="${Github}/releases/download/AutoUpdate/Github_Tags"
export Github_Release="${Github_Release}"
[ ! -d "${Download_Path}" ] && mkdir -p ${Download_Path} || rm -fr ${Download_Path}/*
opkg list | awk '{print $1}' > ${Download_Path}/Installed_PKG_List
export PKG_List="${Download_Path}/Installed_PKG_List"

menuws() {
  clear
  echo  
  ECHOB "  请选择执行命令编码"
  ECHOY " ${gg1}"
  ECHOYY " ${gg2}"
  ECHOY " ${gg3}"
  ECHOYY " 3. 退出菜单"
  echo
  XUANZHEOP="请输入数字"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      Firmware="${gujian1}"
    break
    ;;
    2)
      Firmware="${gujian2}"
    break
    ;;
    3)
      Firmware="${gujian3}"
    break
    ;;
    3)
      ECHOR "您选择了退出程序"
      exit 0
    break
    ;;
    *)
      XUANZHEOP="请输入正确的数字编号!"
    ;;
    esac
    done
}

opapi() {
  wget -q ${Github_Tags} -O ${Download_Tags} > /dev/null 2>&1
  if [[ $? -ne 0 ]];then
  wget -q -P ${Download_Path} https://pd.zwc365.com/${Github_Tagstwo} -O ${Download_Path}/Github_Tags > /dev/null 2>&1
    if [[ $? -ne 0 ]];then
      wget -q -P ${Download_Path} https://ghproxy.com/${Github_Tagstwo} -O ${Download_Path}/Github_Tags > /dev/null 2>&1
    fi
    if [[ $? -ne 0 ]];then
      print_error "获取固件版本信息失败,请检测网络,或者您更改的Github地址为无效地址,或者您的仓库是私库,或者发布已被删除!"
      echo
      exit 1
    fi
  fi
}

menuaz() {
  cd ${Download_Path}
  if [[ "$(cat ${Download_Path}/Installed_PKG_List)" =~ curl ]]; then
    export Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
    if [ ! "$Google_Check" == 301 ];then
      TIME g "正在下载云端固件,请耐心等待..."
      wget -q --show-progress --progress=bar:force:noscroll "https://ghproxy.com/${Github_Release}/${Firmware}" -O ${Firmware}
      if [[ $? -ne 0 ]];then
        wget -q --show-progress --progress=bar:force:noscroll "https://pd.zwc365.com/${Github_Release}/${Firmware}" -O ${Firmware}
	if [[ $? -ne 0 ]];then
	   print_error "下载云端固件失败,请尝试手动安装!"
	   echo
	   exit 1
	else
	   TIME y "下载云端固件成功!"
	fi
      else
        TIME y "下载云端固件成功!"
      fi
  else
      TIME g "正在下载云端固件,请耐心等待..."
      wget -q --show-progress --progress=bar:force:noscroll "${Github_Release}/${Firmware}" -O ${Firmware}
      if [[ $? -ne 0 ]];then
        wget -q --show-progress --progress=bar:force:noscroll "https://ghproxy.com/${Github_Release}/${Firmware}" -O ${Firmware}
        if [[ $? -ne 0 ]];then
          print_error "下载云端固件失败,请尝试手动安装!"
          echo
          exit 1
        else
          TIME y "下载云端固件成功!"
        fi
      else
        TIME y "下载云端固件成功!"
      fi
    fi
  fi
}

function anzhuang() {
  export CLOUD_MD5=$(md5sum ${Firmware} | cut -c1-3)
  export CLOUD_256=$(sha256sum ${Firmware} | cut -c1-3)
  export MD5_256=$(echo ${Firmware} | egrep -o "[a-zA-Z0-9]+${Firmware_SFX}" | sed -r "s/(.*)${Firmware_SFX}/\1/")
  export CURRENT_MD5="$(echo "${MD5_256}" | cut -c1-3)"
  export CURRENT_256="$(echo "${MD5_256}" | cut -c 4-)"
  [[ ${CURRENT_MD5} != ${CLOUD_MD5} ]] && {
    print_error "MD5对比失败,固件可能在下载时损坏,请检查网络后重试!"
    exit 1
  }
  [[ ${CURRENT_256} != ${CLOUD_256} ]] && {
    print_error "SHA256对比失败,固件可能在下载时损坏,请检查网络后重试!"
    exit 1
  }
  chmod 777 ${Firmware}
  [[ "$(cat ${PKG_List})" =~ gzip ]] && opkg remove gzip > /dev/null 2>&1
  TIME g "正在更新固件,更新期间请不要断开电源或重启设备 ..."
  sleep 2

  ${Upgrade_Options} ${Firmware}
}


lede_Firmware() {
  case ${DEFAULT_Device} in
  x86-64)
    [ -d /sys/firmware/efi ] && {
      export Name_1="$(egrep -o "18.06_tl-Tianling-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "21.02-mortal-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "20.06-lienol-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    } || {
      export Name_1="$(egrep -o "18.06_tl-Tianling-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "21.02-mortal-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "20.06-lienol-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    }
    ;;
    *)
      export Name_1="$(egrep -o "18.06_tl-Tianling-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "21.02-mortal-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "20.06-lienol-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    esac

  if [[ -z "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
   print_error "无其他作者固件!"
   exit 1
  fi

  if [[ -n "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi
}

lienol_Firmware() {
  case ${DEFAULT_Device} in
  x86-64)
    [ -d /sys/firmware/efi ] && {
      export Name_1="$(egrep -o "18.06-lede-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "21.02-mortal-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "18.06_tl-Tianling-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    } || {
      export Name_1="$(egrep -o "18.06-lede-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "21.02-mortal-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "18.06_tl-Tianling-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    }
    ;;
    *)
      export Name_1="$(egrep -o "18.06-lede-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "21.02-mortal-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "18.06_tl-Tianling-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    esac

  if [[ -z "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
   print_error "无其他作者固件!"
   exit 1
  fi

  if [[ -n "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi
}

mortal_Firmware() {
  case ${DEFAULT_Device} in
  x86-64)
    [ -d /sys/firmware/efi ] && {
      export Name_1="$(egrep -o "18.06-lede-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "18.06_tl-Tianling-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "20.06-lienol-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    } || {
      export Name_1="$(egrep -o "18.06-lede-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "18.06_tl-Tianling-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "20.06-lienol-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    }
    ;;
    *)
      export Name_1="$(egrep -o "18.06-lede-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "18.06_tl-Tianling-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "20.06-lienol-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    esac

  if [[ -z "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
   print_error "无其他作者固件!"
   exit 1
  fi

  if [[ -n "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi
}

Tianling_Firmware() {
  case ${DEFAULT_Device} in
  x86-64)
    [ -d /sys/firmware/efi ] && {
      export Name_1="$(egrep -o "18.06-lede-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "21.02-mortal-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "20.06-lienol-${DEFAULT_Device}-.*-UEFI-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    } || {
      export Name_1="$(egrep -o "18.06-lede-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "21.02-mortal-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "20.06-lienol-${DEFAULT_Device}-.*-Legacy-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    }
    ;;
    *)
      export Name_1="$(egrep -o "18.06-lede-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_2="$(egrep -o "21.02-mortal-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
      export Name_3="$(egrep -o "20.06-lienol-${DEFAULT_Device}-.*-Sysupg-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
    esac

  if [[ -z "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
   print_error "无其他作者固件!"
   exit 1
  fi

  if [[ -n "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -n "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi

  if [[ -z "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  fi
}


