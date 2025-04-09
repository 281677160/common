#!/bin/bash

export GITHUB_WORKSPACE="$PWD"
export HOME_PATH="${GITHUB_WORKSPACE}/openwrt"
export OPERATES_PATH="${GITHUB_WORKSPACE}/operates"
export GITHUB_ENV="${GITHUB_WORKSPACE}/bendi"
export CURRENT_PATH="${GITHUB_WORKSPACE##*/}"
export BENDI_VERSION="1"
install -m 0755 /dev/null $GITHUB_ENV
if [[ ! "$USER" == "openwrt" ]] && [[ "${CURRENT_PATH}" == "openwrt" ]]; then
  print_error "已在openwrt文件夹内,请在勿在此路径使用一键命令"
  exit 1
fi
source /etc/os-release
if [[ ! "${UBUNTU_CODENAME}" =~ (bionic|focal|jammy) ]]; then
  print_error "请使用Ubuntu 64位系统，推荐 Ubuntu 20.04 LTS 或 Ubuntu 22.04 LTS"
  exit 1
fi
if [[ "$USER" == "root" ]]; then
  print_error "警告：请勿使用root用户编译，换一个普通用户吧~~"
  exit 1
fi
Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
if [ ! "${Google_Check}" == 301 ]; then
  print_error "提醒：编译之前请自备梯子，编译全程都需要稳定翻墙的梯子~~"
  exit 1
fi
if [[ `sudo grep -c "sudo ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers` -eq '0' ]]; then
  sudo sed -i 's?%sudo.*?%sudo ALL=(ALL:ALL) NOPASSWD:ALL?g' /etc/sudoers
fi

function TIME() {
  case $1 in
    r) export Color="\e[31m";;
    g) export Color="\e[32m";;
    b) export Color="\e[34m";;
    y) export Color="\e[33m";;
    z) export Color="\e[35m";;
    l) export Color="\e[36m";;
  esac
echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
}

function Ben_diskcapacity() {
Cipan_Size="$(df -hT $PWD|awk 'NR==2'|awk '{print $(3)}')"
Cipan_Used="$(df -hT $PWD|awk 'NR==2'|awk '{print $(4)}')"
Cipan_Avail="$(df -hT $PWD|awk 'NR==2'|awk '{print $(5)}' |cut -d 'G' -f1)"
TIME y "磁盘总量为[${Cipan_Size}]，已用[${Cipan_Used}]，可用[${Cipan_Avail}G]"
if [[ "${Cipan_Avail}" -lt "20" ]];then
  TIME r "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于20G,是否继续?"
  read -p " 直接回车退出编译，按[Y/y]回车则继续编译： " KJYN
  case ${KJYN} in
  [Yy]) 
    TIME y  "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
    sleep 2
  ;;
  *)
    TIME y  "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
    exit 0
  ;;
  esac
fi
}

function Ben_update() {
if [[ ! -f "/etc/oprelyon" ]]; then
  bash <(curl -fsSL https://raw.githubusercontent.com/281677160/common/main/custom/ubuntu.sh)
fi
if [[ $? -ne 0 ]];then
  TIME r "依赖安装失败，请检测网络后再次尝试!"
  exit 1
else
  sudo sh -c 'echo openwrt > /etc/oprelyon'
  TIME b "全部依赖安装完毕"
fi
}

function Ben_variable() {
cd ${GITHUB_WORKSPACE}
export FOLDER_NAME="$FOLDER_NAME"
if [[ -f "$OPERATES_PATH/$FOLDER_NAME/settings.ini" ]]; then
  source $OPERATES_PATH/$FOLDER_NAME/settings.ini
fi
export COMPILE_PATH="$OPERATES_PATH/$FOLDER_NAME"
export SOURCE_CODE="${SOURCE_CODE}"
export REPO_BRANCH="${REPO_BRANCH}"
export BUILD_DIY="${COMPILE_PATH}/diy"
export BUILD_FILES="${COMPILE_PATH}/files"
export BUILD_PATCHES="${COMPILE_PATH}/patches"
export BUILD_PARTSH="${COMPILE_PATH}/diy-part.sh"
export BUILD_SETTINGS="${COMPILE_PATH}/settings.ini"
export CONFIG_FILE="${CONFIG_FILE}"
export MYCONFIG_FILE="${COMPILE_PATH}/seed/${CONFIG_FILE}"

echo "FOLDER_NAME=${FOLDER_NAME}" >> ${GITHUB_ENV}
echo "SOURCE_CODE=${SOURCE_CODE}" >> ${GITHUB_ENV}
echo "REPO_BRANCH=${REPO_BRANCH}" >> ${GITHUB_ENV}
echo "CONFIG_FILE=${CONFIG_FILE}" >> ${GITHUB_ENV}
echo "HOME_PATH=$HOME_PATH" >> ${GITHUB_ENV}
echo "OPERATES_PATH=$OPERATES_PATH" >> ${GITHUB_ENV}
echo "COMPILE_PATH=${COMPILE_PATH}" >> ${GITHUB_ENV}
echo "BUILD_DIY=${BUILD_DIY}" >> ${GITHUB_ENV}
echo "BUILD_FILES=${BUILD_FILES}" >> ${GITHUB_ENV}
echo "BUILD_PATCHES=${BUILD_PATCHES}" >> ${GITHUB_ENV}
echo "BUILD_PARTSH=${BUILD_PARTSH}" >> ${GITHUB_ENV}
echo "BUILD_SETTINGS=${BUILD_SETTINGS}" >> ${GITHUB_ENV}
echo "MYCONFIG_FILE=${MYCONFIG_FILE}" >> ${GITHUB_ENV}

bash <(curl -fsSL https://raw.githubusercontent.com/281677160/common/ceshi/custom/first.sh)
echo "$COMMON_SH"
source $COMMON_SH && Diy_variable

}


function Ben_xiazai() {
cd ${GITHUB_WORKSPACE}
rm -rf openwrt
git clone -b "${REPO_BRANCH}" --single-branch "${REPO_URL}" openwrt
cd $HOME_PATH
}

function Ben_menu() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu
}

function Ben_menuconfig() {
cd $HOME_PATH
make menuconfig
}

function Ben_menu2() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu2
}

function Ben_menu3() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu3
}

function Diy_main() {
export FOLDER_NAME="Lede"
Ben_diskcapacity
Ben_update
Ben_variable
Ben_xiazai
Ben_menu
Ben_menuconfig
Ben_menu2
Ben_menu3
}

Diy_main
