#!/bin/bash

function TIME() {
  case $1 in
    r) export Color="\e[31m";;
    g) export Color="\e[32m";;
    b) export Color="\e[34m";;
    y) export Color="\e[33m";;
    z) export Color="\e[35m";;
    l) export Color="\e[36m";;
  esac
echo
echo -e "\e[36m\e[0m${Color}${2}\e[0m"
}

source /etc/os-release
if [[ ! "${UBUNTU_CODENAME}" =~ (bionic|focal|jammy) ]]; then
  TIME r "请使用Ubuntu 22.04 LTS位系统"
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  TIME r "警告：请勿使用root用户编译，换一个普通用户吧~~"
  exit 1
fi

export GITHUB_WORKSPACE="/home/$USER"
export HOME_PATH="${GITHUB_WORKSPACE}/openwrt"
export OPERATES_PATH="${GITHUB_WORKSPACE}/operates"
export GITHUB_ENV="/tmp/compile"
export BENDI_VERSION="1"
export op_log="${OPERATES_PATH}/common/build.log"
export LICENSES_DOC="${HOME_PATH}/LICENSES/doc"
install -m 0755 /dev/null $GITHUB_ENV

Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
if [ ! "${Google_Check}" == 301 ]; then
  TIME r "提醒：编译之前请自备梯子，编译全程都需要稳定翻墙的梯子~~"
  exit 1
fi
if [[ `sudo grep -c "sudo ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers` -eq '0' ]]; then
  sudo sed -i 's?%sudo.*?%sudo ALL=(ALL:ALL) NOPASSWD:ALL?g' /etc/sudoers
fi

cd $GITHUB_WORKSPACE

function Ben_wslpath() {
if [[ -n "$(echo "${PATH}" |grep -i 'windows')" ]]; then
  clear
  echo
  TIME r "您的ubuntu为Windows子系统,需要解决路径问题"
  read -p " [输入[Y/y]回车解决路径问题，输入[N/n]不使用此脚本编译openwrt： " Bendi_Wsl
  case ${Bendi_Wsl} in
  [Yy])
    bash -c  "$(curl -fsSL https://raw.githubusercontent.com/281677160/bendi/main/wsl.sh)"
    exit 0
  ;;
  [Nn])
    TIME y "不使用此脚本编译openwrt！"
    exit 1
  ;;
  esac
fi
}

function Ben_diskcapacity() {
Cipan_Size="$(df -hT $PWD|awk 'NR==2'|awk '{print $(3)}')"
Cipan_Used="$(df -hT $PWD|awk 'NR==2'|awk '{print $(4)}')"
Cipan_Avail="$(df -hT $PWD|awk 'NR==2'|awk '{print $(5)}' |cut -d 'G' -f1)"
TIME y "磁盘总量为[${Cipan_Size}]，已用[${Cipan_Used}]，可用[${Cipan_Avail}G]"
if [[ "${Cipan_Avail}" -lt "20" ]];then
  TIME r "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于20G,是否继续?"
  read -p "直接回车退出编译，按[Y/y]回车则继续编译： " KJYN
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

function Ben_config() {
if [[ "${MODIFY_CONFIGURATION}" = "true" ]]; then
  TIME g "是否需要选择机型和增删插件?"
  read -t 30 -p " [输入[ Y/y ]回车确认，任意键则为否](不作处理,30秒自动跳过)： " Bendi_Diy
  case ${Bendi_Diy} in
  [Yy])
    Menuconfig_Config="true"
    TIME y "您执行机型和增删插件命令,请耐心等待程序运行至窗口弹出进行机型和插件配置!"
  ;;
  *)
    Menuconfig_Config="false"
    ECHOR "您已关闭选择机型和增删插件设置！"
  ;;
  esac
fi
}

function Ben_update() {
if [[ ! -f "/etc/oprelyon" ]]; then
  bash <(curl -fsSL https://github.com/281677160/common/raw/main/custom/ubuntu.sh)
  if [[ $? -eq 0 ]];then
    sudo sh -c 'echo openwrt > /etc/oprelyon'
  fi
fi
if [[ -f "/etc/ssh/sshd_config" ]] && [[ -z "$(grep -E 'ClientAliveInterval 30' /etc/ssh/sshd_config)" ]]; then
  sudo sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config
  sudo sed -i '/ClientAliveCountMax/d' /etc/ssh/sshd_config
  sudo sh -c 'echo ClientAliveInterval 30 >> /etc/ssh/sshd_config'
  sudo sh -c 'echo ClientAliveCountMax 6 >> /etc/ssh/sshd_config'
  sudo service ssh restart
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
curl -fsSL https://github.com/281677160/common/raw/ceshi/custom/first.sh -o first.sh
chmod -R +x first.sh
source first.sh
rm -rf first.sh
source $COMMON_SH && Diy_variable
}

function Ben_xiazai() {
cd ${GITHUB_WORKSPACE}
if [[ ! -d "openwrt" ]]; then
  TIME y "正在执行：下载源码"
  git clone -b "${REPO_BRANCH}" --single-branch "${REPO_URL}" openwrt
else
  cd ${HOME_PATH}
  git reset --hard HEAD >/dev/null 2>&1
  git pull >/dev/null 2>&1
fi
}

function Ben_diyptsh() {
TIME y "正在执行：加载自定义文件"
cd ${HOME_PATH}
$DIY_PT1_SH
}

function Ben_configuration() {
cd ${HOME_PATH}
if [[ "${Menuconfig_Config}" == "true" ]]; then
  TIME y "正在执行：选取插件等..."
  make menuconfig
  if [[ $? -ne 0 ]]; then
    TIME y "SSH工具窗口分辨率太小，无法弹出设置机型或插件的窗口"
    TIME g "请调整SSH工具窗口分辨率后按[Y/y]继续,或者按[N/n]退出编译"
    XUANMA="请输入您的选择"
    while :; do
    read -p "${XUANMA}：" menu_config
    case ${menu_config} in
    [Yy])
      Ben_configuration
    break
    ;;
    [Nn])
      exit 1
    break
    ;;
    *)
      XUANMA="输入错误,请输入[Y/n]"
    ;;
    esac
    done
  fi
fi
}

function Ben_download() {
TIME y "正在执行：下载DL文件,请耐心等候..."
cd ${HOME_PATH}
rm -rf "${op_log}"
make -j8 download || make -j8 download V=s 2>&1 | tee $op_log
if [[ -f "${op_log}" ]] && [[ -n "$(cat "${op_log}" |grep -i 'ERROR')" ]]; then
  clear
  TIME r "下载DL失败，更换节点后再尝试下载？"
  QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或输入[N/n]回车,退出编译"
  while :; do
    read -p "[${QLMEUN}]： " BenDownload
    case ${BenDownload} in
  [Yy])
    Ben_download
  break
  ;;
  [Nn])
    TIME r "退出编译程序!"
    sleep 1
    exit 1
  break
  ;;
  *)
    QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或现在输入[N/n]回车,退出编译"
  ;;
  esac
  done
fi
}

function Ben_compile() {
cd ${HOME_PATH}
rm -rf "${op_log}"
START_TIME=`date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s`
Model_Name="$(cat /proc/cpuinfo |grep 'model name' |awk 'END {print}' |cut -f2 -d: |sed 's/^[ ]*//g')"
Cpu_Cores="$(cat /proc/cpuinfo | grep 'cpu cores' |awk 'END {print}' | cut -f2 -d: | sed 's/^[ ]*//g')"
RAM_total="$(free -h |awk 'NR==2' |awk '{print $(2)}' |sed 's/.$//')"
RAM_available="$(free -h |awk 'NR==2' |awk '{print $(7)}' |sed 's/.$//')"
[[ -d "${FIRMWARE_PATH}" ]] && sudo rm -rf ${FIRMWARE_PATH}/*
echo
TIME g "您的机器CPU型号为[ ${Model_Name} ]"
TIME y "在此ubuntu分配核心数为[ ${Cpu_Cores} ],线程数为[ $(nproc) ]"
TIME g "在此ubuntu分配内存为[ ${RAM_total} ],现剩余内存为[ ${RAM_available} ]"
echo

if [[ "${Cpu_Cores}" -ge "8" ]];then
  cpunproc="8"
else
  cpunproc="${Cpu_Cores}"
fi

TIME y "即将使用${cpunproc}线程进行编译固件,请耐心等候..."
sleep 5
make -j${cpunproc} || make -j1 V=s 2>&1 | tee $op_log
if [[ -f "${op_log}" ]] && [[ -n "$(cat "${op_log}" |grep -i 'Error 2')" ]]; then
  compile_error="1"
else
  compile_error="0"
fi

sleep 3
if [[ "${compile_error}" == "1" ]]; then
  TIME r "编译失败~~!"
  TIME y "在[operates/common/build.log]可查看编译日志"
  exit 1
else
  echo "
  SUCCESS_FAILED="success"
  SOURCE_CODE="${SOURCE_CODE}"
  SOURCE="${SOURCE}"
  FOLDER_NAME="${FOLDER_NAME}"
  REPO_BRANCH="${REPO_BRANCH}"
  LUCI_EDITION="${LUCI_EDITION}"
  TARGET_BOARD="${TARGET_BOARD}"
  MYCONFIG_FILE="${MYCONFIG_FILE}"
  TARGET_PROFILE="${TARGET_PROFILE}"
  CONFIG_FILE="${CONFIG_FILE}"
  " > ${LICENSES_DOC}/buildzu.ini
  sed -i 's/^[ ]*//g' ${LICENSES_DOC}/buildzu.ini
fi
}

function Ben_firmware() {
cd ${FIRMWARE_PATH}
cp -Rf config.buildinfo ${MYCONFIG_FILE}
if [[ -n "$(ls -1 |grep -E 'immortalwrt')" ]]; then
  rename -v "s/^immortalwrt/openwrt/" * > /dev/null 2>&1
  sed -i 's/immortalwrt/openwrt/g' `egrep "immortalwrt" -rl ./`
fi

for X in $(cat ${CLEAR_PATH} |sed "s/.*${TARGET_BOARD}//g"); do
  rm -rf *"$X"*
done

if [[ -n "$(ls -1 |grep -E 'armvirt')" ]] || [[ -n "$(ls -1 |grep -E 'armsr')" ]]; then
  TIME g "[ Amlogic_Rockchip系列专用固件 ]顺利编译完成~~~"
else
  rename -v "s/^openwrt/${Gujian_Date}-${SOURCE}-${LUCI_EDITION}-${LINUX_KERNEL}/" * > /dev/null 2>&1
  TIME g "[ ${FOLDER_NAME}-${LUCI_EDITION}-${TARGET_PROFILE} ]顺利编译完成~~~"
fi
cd ${HOME_PATH}
TIME y "固件存放路径：openwrt/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
}

function Ben_compiletwo() {
TIME g "编译日期：$(date +'%Y年%m月%d号')"
END_TIME=`date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s`
SECONDS=$((END_TIME-START_TIME))
HOUR=$(( $SECONDS/3600 ))
MIN=$(( ($SECONDS-${HOUR}*3600)/60 ))
SEC=$(( $SECONDS-${HOUR}*3600-${MIN}*60 ))
if [[ "${HOUR}" == "0" ]]; then
  TIME y "编译总计用时 ${MIN}分${SEC}秒"
else
  TIME g "编译总计用时 ${HOUR}时${MIN}分${SEC}秒"
fi
TIME r "提示：再次输入编译命令可进行二次编译"
}

function Ben_erci() {
cd ${HOME_PATH}
Ben_config
Ben_menuconfig
git pull
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
Ben_download
Ben_menu7
}

function Ben_gaierci() {
cd $HOME_PATH
cp -Rf ${LICENSES_DOC}/feeds.conf.default ${HOME_PATH}/feeds.conf.default
}

function Ben_menu() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu
}

function Ben_menu2() {
cd $HOME_PATH
Ben_diyptsh
}

function Ben_menu3() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu3
}

function Ben_menuconfig() {
cd $HOME_PATH
Ben_configuration
}

function Ben_menu4() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu4
}

function Ben_menu5() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu5
source $GITHUB_ENV
}

function Ben_menu6() {
cd $HOME_PATH
Ben_download
}

function Ben_menu7() {
cd $HOME_PATH
Ben_compile
Ben_firmware
Ben_compiletwo
}

function Diy_main() {
Ben_wslpath
Ben_diskcapacity
Ben_config
Ben_update
Ben_variable
Ben_xiazai
Ben_menu
Ben_menu2
Ben_menu3
Ben_menuconfig
Ben_menu4
Ben_menu5
Ben_menu6
Ben_menu7
}

function Diy_main2() {
Ben_wslpath
Ben_diskcapacity
Ben_config
Ben_update
Ben_variable
Ben_xiazai
Ben_gaierci
Ben_menu2
Ben_menu3
Ben_menuconfig
Ben_menu4
Ben_menu5
Ben_menu6
Ben_menu7
}

function Ben_xuanzhe() {
  clear
  echo 
  echo
  cd ${OPERATES_PATH}
  XYZDSZ="$(ls -d */ | grep -v 'common\|backups' |cut -d"/" -f1 |awk '$0=NR" "$0'| awk 'END {print}' |awk '{print $(1)}')"
  ls -d */ | grep -v 'common\|backups' |cut -d"/" -f1 > /tmp/GITHUB_EVN
  ls -d */ | grep -v 'common\|backups' |cut -d"/" -f1 |awk '$0=NR"、"$0'|awk '{print "  " $0}'
  cd ${GITHUB_WORKSPACE}
  TIME y "请输入您要编译源码前面对应的数值(1~X)，输入[N/n]则为退出程序"
  export YUMINGIP="  请输入您的选择"
  while :; do
  YMXZ=""
  read -p "${YUMINGIP}：" YMXZ
  if [[ "${YMXZ}" =~ (W|w) ]]; then
    CUrrenty="W"
  elif [[ "${YMXZ}" =~ (N|n) ]]; then
    CUrrenty="N"
  elif [[ "${YMXZ}" == "0" ]] || [[ -z "${YMXZ}" ]]; then
    CUrrenty="x"
  elif [[ "${YMXZ}" -le "${XYZDSZ}" ]]; then
    CUrrenty="B"
  else
    CUrrenty="x"
  fi
  case $CUrrenty in
  B)
    export FOLDER_NAME=$(cat ${GITHUB_WORKSPACE}/GITHUB_EVN |awk ''NR==${YMXZ}'')
    TIME g " 您选择了使用 ${FOLDER_NAME} 编译固件"
    Diy_main
  break
  ;;
  N)
    exit 0
  break
  ;;
  x)
    export YUMINGIP="  敬告,请输入正确选项"
  ;;
  esac
  done
}

function menu3() {
  clear
  echo
  TIME g " 上回使用${SOURCE}-${LUCI_EDITION}源码${Font}${Blue}成功编译${TARGET_PROFILE}固件"
  echo
  TIME y " 1、保留缓存,不改设置,只更改插件再编译"
  echo
  TIME y " 2、保留缓存,可改设置再编译"
  echo
  TIME y " 3、重选择源码再编译"
  echo
  TIME y " 4、回到编译主菜单"
  echo
  TIME y " 5、打包Amlogic/Rockchip固件(您要有armvirt_64的.tar.gz固件)"
  echo
  TIME r " 6、退出"
  echo
  XUANZop=" 请输入数字"
  echo
  while :; do
  read -p " ${XUANZop}：" menu_num
  case $menu_num in
  1)
    ZX_XZYM="0"
    Ben_erci
  break
  ;;
  2)
    ZX_XZYM="1"
    Diy_main
  break
  ;;
  3)
    menu
  break
  ;;
  4)
    menu2
  break
  ;;
  5)
    Bendi_Dependent
    Bendi_Packaging
  break
  ;;
  6)
    echo
    exit 0
  break
  ;;
  *)
    XUANZop=" 请输入正确的数字编号"
  ;;
  esac
  done
}

function menu2() {
cd ${GITHUB_WORKSPACE}
clear
echo
TIME y " 1. 进行编译固件"
TIME y " 2. 打包Amlogic/Rockchip固件(您要有armvirt_64的.tar.gz固件)"
TIME r " 3. 退出程序"
echo
XUANZHEOP=" 请输入数字"
echo
while :; do
read -p " ${XUANZHEOP}： " CHOOSE
case $CHOOSE in
1)
  zhizuoconfig="0"
  Diy_main
break
;;
2)
  Bendi_Dependent
break
;;
3)
  echo
  exit 0
break
;;
*)
   XUANZHEOP=" 请输入正确的数字编号"
;;
esac
done
}

function main() {
if [[ -n "$(grep -E 'success' ${LICENSES_DOC}/buildzu.ini 2>/dev/null)" ]]; then
  source ${LICENSES_DOC}/buildzu.ini
  required_dirs=("config" "include" "package" "scripts" "target" "toolchain" "tools")
  missing_flag=0
  for dir in "${required_dirs[@]}"; do
      if [[ ! -d "$HOME_PATH/$dir" ]]; then
        echo "目录缺失: $dir"
        missing_flag=1
      fi
  done

  if [[ $missing_flag -eq 0 ]] && [[ -n "$( grep -E "${TARGET_BOARD}" "${MYCONFIG_FILE}" 2>/dev/null)" ]]; then
    menu3
  else
    menu2
  fi
else
  menu2
fi
}
main
