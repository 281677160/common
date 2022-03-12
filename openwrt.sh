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

function ip_install() {
  echo
  echo
  export YUMING="请输入您的IP"
  ECHOYY "${YUMING}[比如:192.168.2.2]"
  while :; do
  domainy=""
  read -p " ${YUMING}：" domain
  if [[ -n "${domain}" ]] && [[ "$(echo ${domain} |egrep -c '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')" == '1' ]]; then
    domainy="Y"
  fi
  case $domainy in
  Y)
    export domain="${domain}"
    uci set network.lan.ipaddr="${domain}"
    uci set network.lan.dns=
    uci set network.lan.gateway=
    uci set network.lan.broadcast=
    uci commit network
    judge "IP 修改"
    ECHOG "您的IP为：${domain}"
  break
  ;;
  *)
    export YUMING="敬告：请输入正确格式的IP"
  ;;
  esac
  done
}

function dns_install() {
  export YUMING="请输入您的DNS"
  ECHOYY "${YUMING}[比如:114.114.114.114]"
  ECHOYY "多个DNS之间要用空格分开[比如:114.114.114.114 223.5.5.5 8.8.8.8]"
  while :; do
  domaind=""
  read -p " ${YUMING}：" domaindns
  if [[ -n "${domaindns}" ]] && [[ "$(echo ${domaindns} |egrep -c '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')" == '1' ]]; then
    domaind="Y"
  fi
  case $domaind in
  Y)
    export domaindns="${domaindns}"
    uci set network.lan.dns="${domaindns}"
    uci commit network
    judge "DNS 修改"
    ECHOG "您的DNS为：${domaindns}"
  break
  ;;
  *)
    export YUMING="敬告：请输入正确格式的DNS"
  ;;
  esac
  done
}

function wg_install() {
  export YUMING="请输入您的主路由IP（网关）"
  ECHOYY "${YUMING}[比如:192.168.2.1]"
  while :; do
  domainw=""
  read -p " ${YUMING}：" domainwg
  if [[ -n "${domainwg}" ]] && [[ "$(echo ${domainwg} |egrep -c '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')" == '1' ]]; then
    domainw="Y"
  fi
  case $domainw in
  Y)
    export domainwg="${domainwg}"
    uci set network.lan.gateway="${domainwg}"
    uci commit network
    judge "DNS 修改"
    ECHOG "您的DNS为：${domainwg}"
  break
  ;;
  *)
    export YUMING="敬告：请输入正确格式的网关IP"
  ;;
  esac
  done
}

function install_ws() {
  clear
  ip_install
  echo
  echo
  read -p " 是否设置DNS?主路由一般无需设置DSN,直接回车跳过，旁路由按[Y/y]设置：" YN
  case ${YN} in
    [Yy]) 
      dns_install
    ;;
    *)
      ECHOR "您已跳过DNS设置"
    ;;
  esac
  echo
  echo
  read -p " 是否设置网关?主路由无需设置网关,直接回车跳过，旁路由按[Y/y]设置：" YN
  case ${YN} in
    [Yy]) 
      wg_install
    ;;
    *)
      ECHOR "您已跳过网关设置"
    ;;
  esac
  echo
  echo
  ECHOG "正在为您重启openwrt中，预计需要1~2分钟，请稍后..."
  echo
  reboot
}

function first_boot() {
  echo
  echo
  ECHOR "是否恢复出厂设置?按[Y/y]执行,按[N/n]退出,如果执行的话,请耐心等待openwrt重启完成"
  firstboot && reboot
}

menu() {
  clear
  echo  
  ECHOB "  请选择执行命令编码"
  ECHOY " 1. 检查更新(保留配置)"
  ECHOYY " 2. 检查更新(不保留配置)"
  ECHOY " 3. 测试模式,观看运行步骤(不安装固件)"
  ECHOYY " 4. 转换成其他源码作者固件(不保留配置)"
  ECHOY " 5. 查看状态信息"
  ECHOYY " 6. 更换检测固件的gihub地址"
  ECHOY " 7. 修改IP/DSN/网关"
  ECHOYY " 8. 恢复出厂设置"
  ECHOY " 9. 退出菜单"
  echo
  XUANZHEOP="请输入数字"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      bash /bin/AutoUpdate.sh
    break
    ;;
    2)
      bash /bin/AutoUpdate.sh -n
    break
    ;;
    3)
      bash /bin/AutoUpdate.sh -t
    break
    ;;
    4)
      bash /bin/replace2.sh
    break
    ;;
    5)
      bash /bin/AutoUpdate.sh -h
    break
    ;;
    6)
      bash /bin/AutoUpdate.sh -c
    break
    ;;
    7)
      install_ws
    break
    ;;
    8)
      first_boot
    break
    ;;
    9)
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

menuws() {
  clear
  echo  
  ECHOB "  请选择执行命令编码"
  ECHOY " 1. 修改IP/DSN/网关"
  ECHOYY " 2. 恢复出厂设置"
  ECHOY " 3. 退出菜单"
  echo
  XUANZHEOP="请输入数字"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      install_ws
    break
    ;;
    2)
      first_boot
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

if [[ -f /bin/openwrt_info ]] && [[ -f /bin/AutoUpdate.sh ]];then
  menu "$@"
else
  menuws "$@"
fi

exit 0
