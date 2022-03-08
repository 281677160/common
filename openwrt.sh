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
  echo
  echo -e "${Red} $1 ${Font}"
  echo
}
function ECHOB() {
  echo
  echo -e "${Blue} $1 ${Font}"
  echo
}
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}

menu() {
  clear
  echo  
  ECHOB "  请选择执行命令编码"
  ECHOY " 1. 检查更新(保留配置)"
  ECHOYY " 2. 检查更新(不保留配置)"
  echo
  ECHOYY " 3. 更换其他作者固件(不保留配置)"
  ECHOY " 4. 测试模式,观看运行步骤(不安装固件)"
  ECHOYY " 5. 查看状态信息"
  ECHOY " 6. 更换检测固件的gihub地址"
  ECHOYY " 7. 重启openwrt"
  ECHOY " 8. 退出菜单"
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
      bash /bin/AutoUpdate.sh -g
    break
    ;;
    4)
      bash /bin/AutoUpdate.sh -t
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
      ECHOR "正在执行重启openwrt中..."
      reboot
    break
    ;;
    8)
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
menu "$@"
exit 0
