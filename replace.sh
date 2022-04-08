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
GreenBG="\033[1;36m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
GX=" ${Red}[恭喜]${Font}"
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
}
function ECHOBG() {
  echo
  echo -e "${GreenBG} $1 ${Font}"
}
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOG() {
  echo -e "${Green} $1 ${Font}"
  echo
}
function print_ok() {
  echo
  echo -e " ${OK} ${Blue} $1 ${Font}"
  echo
}
function print_error() {
  echo
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
  echo
}
function print_gg() {
  echo
  echo -e "${GX}${Green} $1 ${Font}"
  echo
}

ECHOB "加载数据中,请稍后..."
if [[ -f /bin/openwrt_info ]]; then
  chmod +x /bin/openwrt_info && source /bin/openwrt_info
  if [[ $? -ne 0 ]];then
    print_error "openwrt_info数据有误,请检查openwrt_info!"
    exit 1
  fi
else
  print_error "未检测到openwrt_info文件,无法运行更新程序!"
  exit 1
fi
[[ ! -d "${Download_Path}" ]] && mkdir -p ${Download_Path} || rm -fr ${Download_Path}/*
opkg list | awk '{print $1}' > ${Download_Path}/Installed_PKG_List
export PKG_List="${Download_Path}/Installed_PKG_List"
export Kernel="$(egrep -o "Version: [0-9]+\.[0-9]+\.[0-9]+" /usr/lib/opkg/info/kernel.control |sed s/[[:space:]]//g |cut -d ":" -f2)"


case ${Firmware_SFX} in
.img.gz | .img )
  [ -d /sys/firmware/efi ] && {
    export BOOT_Type="uefi"
  } || {
    export BOOT_Type="legacy"
  }
  if [[ -f /etc/openwrt_upgrade ]]; then
    export CURRENT_Device="$(grep CURRENT_Device= /etc/openwrt_upgrade | cut -c16-100)"
  else
    export CPUmodel="$(cat /proc/cpuinfo |grep 'model name' |awk 'END {print}' |cut -f2 -d: |sed 's/^[ ]*//g'|sed 's/\ CPU//g')"
    if [[ "$(echo ${CPUmodel} |grep -c 'Intel')" -ge '1' ]]; then
      export Cpu_Device="$(echo "${CPUmodel}" |awk '{print $2}')"
      export CURRENT_Device="$(echo "${CPUmodel}" |sed "s/${Cpu_Device}//g")"
    else
      export CURRENT_Device="${CPUmodel}"
    fi
  fi
;;
*)
  export BOOT_Type="sysupgrade"
  export CURRENT_Device="$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')"
;;
esac

opapi() {
[ ! -d ${Download_Path} ] && mkdir -p ${Download_Path}
wget -q ${Github_API1} -O ${API_PATH} > /dev/null 2>&1
if [[ $? -ne 0 ]];then
  wget -q -P ${Download_Path} https://pd.zwc365.com/${Github_API2} -O ${API_PATH} > /dev/null 2>&1
  if [[ $? -ne 0 ]];then
    wget -q -P ${Download_Path} https://ghproxy.com/${Github_API2} -O ${API_PATH} > /dev/null 2>&1
  fi
  if [[ $? -ne 0 ]];then
    print_error "获取固件版本信息失败,请检测网络,或者您更改的Github地址为无效地址,或者您的仓库是私库,或者发布已被删除!"
    exit 1
  fi
fi
}

menuaz() {
  echo
  echo
  ECHOG "正在下载编号[ ${BianHao} ]云端固件,请耐心等待..."
  cd ${Download_Path}
  [[ "$(cat ${Download_Path}/Installed_PKG_List)" =~ curl ]] && {
    export Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
    if [ ! "$Google_Check" == 301 ];then
      wget -q --show-progress --progress=bar:force:noscroll "https://ghproxy.com/${Release_download}/${Firmware}" -O ${Firmware}
      if [[ $? -ne 0 ]];then
        wget -q --show-progress --progress=bar:force:noscroll "https://pd.zwc365.com/${Release_download}/${Firmware}" -O ${Firmware}
        if [[ $? -ne 0 ]];then
          print_error "下载云端固件失败,请尝试手动安装!"
          exit 1
        else
          print_ok "下载云端固件成功!"
        fi
      else
        print_ok "下载云端固件成功!"
      fi
    else
      wget -q --show-progress --progress=bar:force:noscroll "${Release_download}/${Firmware}" -O ${Firmware}
      if [[ $? -ne 0 ]];then
        wget -q --show-progress --progress=bar:force:noscroll "https://ghproxy.com/${Release_download}/${Firmware}" -O ${Firmware}
        if [[ $? -ne 0 ]];then
          print_error "下载云端固件失败,请尝试手动安装!"
          echo
          exit 1
        else
          print_ok "下载云端固件成功!"
        fi
      else
        print_ok "下载云端固件成功!"
      fi
    fi
  }
}

function anzhuang() {
  cd ${Download_Path}
  export LOCAL_MD5=$(md5sum ${Firmware} | cut -c1-3)
  export LOCAL_256=$(sha256sum ${Firmware} | cut -c1-3)
  export MD5_256=$(echo ${Firmware} | egrep -o "[a-zA-Z0-9]+${Firmware_SFX}" | sed -r "s/(.*)${Firmware_SFX}/\1/")
  export CLOUD_MD5="$(echo "${MD5_256}" | cut -c1-3)"
  export CLOUD_256="$(echo "${MD5_256}" | cut -c 4-)"
  [[ ${LOCAL_MD5} != ${CLOUD_MD5} ]] && {
    print_error "MD5对比失败,固件可能在下载时损坏,请检查网络后重试!"
    exit 1
  }
  [[ ${LOCAL_256} != ${CLOUD_256} ]] && {
    print_error "SHA256对比失败,固件可能在下载时损坏,请检查网络后重试!"
    exit 1
  }

  chmod 777 ${Firmware}
  [[ "$(cat ${PKG_List})" =~ gzip ]] && opkg remove gzip > /dev/null 2>&1
  ECHOG "正在更新固件,更新期间请不要断开电源或重启设备 ..."
  sleep 2
  sysupgrade -F -n ${Firmware}
}


function Firmware_Path() {
  export CLOUD_Version_1="$(egrep -o "${MAINTAIN_1}-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
  export CLOUD_Version_2="$(egrep -o "${MAINTAIN_2}-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
  export CLOUD_Version_3="$(egrep -o "${MAINTAIN_3}-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"

  if [[ -n "${CLOUD_Version_1}" ]] && [[ -n "${CLOUD_Version_2}" ]] && [[ -n "${CLOUD_Version_3}" ]]; then
    CLOUD_Firmware1="${CLOUD_Version_1}"
    Display_1="1、${CLOUD_Version_1}"
    CLOUD_Firmware2="${CLOUD_Version_2}"
    Display_2="2、${CLOUD_Version_2}"
    CLOUD_Firmware3="${CLOUD_Version_3}"
    Display_3="3、${CLOUD_Version_3}"
  elif [[ -n "${CLOUD_Version_1}" ]] && [[ -n "${CLOUD_Version_2}" ]] && [[ -z "${CLOUD_Version_3}" ]]; then
    CLOUD_Firmware1="${CLOUD_Version_1}"
    Display_1="1、${CLOUD_Version_1}"
    CLOUD_Firmware2="${CLOUD_Version_2}"
    Display_2="2、${CLOUD_Version_2}"
  elif [[ -n "${CLOUD_Version_1}" ]] && [[ -z "${CLOUD_Version_2}" ]] && [[ -n "${CLOUD_Version_3}" ]]; then
    CLOUD_Firmware1="${CLOUD_Version_1}"
    Display_1="1、${CLOUD_Version_1}"
    CLOUD_Firmware2="${CLOUD_Version_3}"
    Display_3="2、${CLOUD_Version_3}"
  elif [[ -z "${CLOUD_Version_1}" ]] && [[ -n "${CLOUD_Version_2}" ]] && [[ -n "${CLOUD_Version_3}" ]]; then
    CLOUD_Firmware1="${CLOUD_Version_2}"
    Display_2="1、${CLOUD_Version_2}"
    CLOUD_Firmware2="${CLOUD_Version_3}"
    Display_3="2、${CLOUD_Version_3}"
  elif [[ -n "${CLOUD_Version_1}" ]] && [[ -z "${CLOUD_Version_2}" ]] && [[ -z "${CLOUD_Version_3}" ]]; then
    CLOUD_Firmware1="${CLOUD_Version_1}"
    Display_1="1、${CLOUD_Version_1}"
  elif [[ -z "${CLOUD_Version_1}" ]] && [[ -n "${CLOUD_Version_2}" ]] && [[ -z "${CLOUD_Version_3}" ]]; then
    CLOUD_Firmware1="${CLOUD_Version_2}"
    Display_2="1、${CLOUD_Version_2}"
  elif [[ -z "${CLOUD_Version_1}" ]] && [[ -z "${CLOUD_Version_2}" ]] && [[ -n "${CLOUD_Version_3}" ]]; then
    CLOUD_Firmware1="${CLOUD_Version_3}"
    Display_3="1、${CLOUD_Version_3}"
  fi
}

menuws() {
  clear
  echo
  echo
  ECHOYY " 当前源码：${SOURCE} / ${LUCI_EDITION} / ${Kernel}"
  ECHOYY " 固件格式：${BOOT_Type}${Firmware_SFX}"
  ECHOYY " 设备型号：${CURRENT_Device}"
  echo
  if [[ -z "${CLOUD_Version_1}" ]] && [[ -z "${CLOUD_Version_2}" ]] && [[ -z "${CLOUD_Version_3}" ]]; then
   print_error "无其他作者固件,如需要更换请先编译出 ${tixinggg} 的固件!"
   sleep 1
   exit 1
  else
    print_gg "检测到有如下固件可供选择（敬告：如若转换,则不保留配置安装固件）"
  fi
  if [[ -z "${Display_1}" ]] && [[ -z "${Display_2}" ]]; then
     [[ -n "${Display_3}" ]] && ECHOBG " ${Display_3}"
  elif [[ -z "${Display_1}" ]]; then
    [[ -n "${Display_2}" ]] && ECHOBG " ${Display_2}"
    [[ -n "${Display_3}" ]] && ECHOBG " ${Display_3}"
  else
    [[ -n "${Display_1}" ]] && ECHOBG " ${Display_1}"
    [[ -n "${Display_2}" ]] && ECHOBG " ${Display_2}"
    [[ -n "${Display_3}" ]] && ECHOBG " ${Display_3}"
  fi
  ECHOBG " Q、退出程序"
  echo
  echo
  XUANZHEOP=" 请输入数字,或按[Q/q]退出"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      export Firmware="${CLOUD_Firmware1}"
      export BianHao="1"
      menuaz
      anzhuang
    break
    ;;
    2)
      export Firmware="${CLOUD_Firmware2}"
      export BianHao="2"
      menuaz
      anzhuang
    break
    ;;
    3)
      export Firmware="${CLOUD_Firmware3}"
      export BianHao="3"
      menuaz
      anzhuang
    break
    ;;
    [Qq])
      ECHOR " 您选择了退出程序"
      echo
      exit 0
    break
    ;;
    *)
      XUANZHEOP=" 请输入正确的数字编号,或按[Q/q]退出!"
    ;;
    esac
    done
}

menu() {
  if [[ ${SOURCE} == "Lede" ]]; then
    export MAINTAIN_1="18.06-Tianling"
    export MAINTAIN_2="21.02-Mortal"
    export MAINTAIN_3="22.03-Lienol"
    export tixinggg="Tianling、Mortal或Lienol"
    opapi
    Firmware_Path
    menuws
    clear
  elif [[ ${SOURCE} == "Lienol" ]]; then
    export MAINTAIN_1="18.06-Lede"
    export MAINTAIN_2="21.02-Mortal"
    export MAINTAIN_3="18.06-Tianling"
    export tixinggg="Lede、Mortal或Tianling"
    opapi
    Firmware_Path
    menuws
    clear
  elif [[ ${SOURCE} == "Mortal" ]]; then
    export MAINTAIN_1="18.06-Lede"
    export MAINTAIN_2="22.03-Lienol"
    export MAINTAIN_3="18.06-Tianling"
    export tixinggg="Lede、Lienol或Tianling"
    opapi
    Firmware_Path
    menuws
  elif [[ ${SOURCE} == "Tianling" ]]; then
    export MAINTAIN_1="18.06-Lede"
    export MAINTAIN_2="21.02-Mortal"
    export MAINTAIN_3="22.03-Lienol"
    export tixinggg="Lede、Mortal或Lienol"
    opapi
    Firmware_Path
    menuws
    clear
  else
    print_error "没检测到您现有的源码作者!"
    exit 1
  fi
}
menu "$@"
