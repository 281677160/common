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

LEDE_Name="$(egrep -o "18.06-lede-x86-64-.*-Legacy-.*.img.gz" /home/dan/Github_Tags | awk 'END {print}')"
TIAN_Name="$(egrep -o "21.02-tian-x86-64-.*-Legacy-.*.img.gz" /home/dan/Github_Tags | awk 'END {print}')"
LIDA_Name="$(egrep -o "20.06-lienol-x86-64-.*-Legacy-.*.img.gz" /home/dan/Github_Tags | awk 'END {print}')"

if [[ -z "${LEDE_Name}" ]] && [[ -z "${TIAN_Name}" ]] && [[ -z "${LIDA_Name}" ]]; then
 echo "无其他作者固件"
 exit 1
fi

if [[ -n "${LEDE_Name}" ]] && [[ -n "${TIAN_Name}" ]] && [[ -n "${LIDA_Name}" ]]; then
  gujian1="${LEDE_Name}"
  gg1="ECHOY \"1. ${LEDE_Name}\""
  gujian2="${TIAN_Name}"
  gg2="ECHOY \"1. ${TIAN_Name}\""
  gujian3="${TIAN_Name}"
  gg3="ECHOY \"1. ${TIAN_Name}\""
  menuws
fi

if [[ -n "${LEDE_Name}" ]] && [[ -n "${TIAN_Name}" ]] && [[ -z "${LIDA_Name}" ]]; then
  gujian1="${LEDE_Name}"
  gg1="ECHOY \"1. ${LEDE_Name}\""
  gujian2="${TIAN_Name}"
  gg2="ECHOY \"1. ${TIAN_Name}\""
  gujian3=""
  gg3=""
  menuws
fi

if [[ -n "${LEDE_Name}" ]] && [[ -z "${TIAN_Name}" ]] && [[ -n "${LIDA_Name}" ]]; then
  gujian1="${LEDE_Name}"
  gg1="ECHOY \"1. ${LEDE_Name}\""
  gujian2="${LIDA_Name}"
  gg2="ECHOY \"1. ${LIDA_Name}\""
  gujian3=""
  gg3=""
  menuws
fi

if [[ -z "${LEDE_Name}" ]] && [[ -n "${TIAN_Name}" ]] && [[ -n "${LIDA_Name}" ]]; then
  gujian1="${TIAN_Name}"
  gg1="ECHOY \"1. ${TIAN_Name}\""
  gujian2="${LIDA_Name}"
  gg2="ECHOY \"1. ${LIDA_Name}\""
  gujian3=""
  gg3=""
  menuws
fi


menuws() {
  clear
  echo  
  ECHOB "  请选择执行命令编码"
  ${gg1}
  ${gg2}
  ${gg3}
  ECHOY " 3. 退出菜单"
  echo
  XUANZHEOP="请输入数字"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      gujian="gujian1"
      echo "${gg1}"
    break
    ;;
    2)
      gujian="gujian2"
      echo "${gg2}"
    break
    ;;
    3)
      gujian="gujian3"
      echo "${gg3}"
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
