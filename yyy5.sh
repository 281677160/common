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
export DIAN_GIT="${HOME_PATH}/.git/config"
export BENDI_VERSION="1"
export op_log="${OPERATES_PATH}/build.log"
export LICENSES_DOC="${HOME_PATH}/LICENSES/doc"
export NUM_BER=""
export SUCCESS_FAILED=""
install -m 0755 /dev/null $GITHUB_ENV
cd $GITHUB_WORKSPACE

Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
if [ ! "${Google_Check}" == 301 ]; then
  TIME r "提醒：编译之前请自备梯子，编译全程都需要稳定翻墙的梯子~~"
  exit 1
fi
if [[ `sudo grep -c "sudo ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers` -eq '0' ]]; then
  sudo sed -i 's?%sudo.*?%sudo ALL=(ALL:ALL) NOPASSWD:ALL?g' /etc/sudoers
fi

function Ben_wslpath() {
if [[ -n "$(echo "${PATH}" |grep -i 'windows')" ]]; then
  clear
  echo
  TIME r "您的ubuntu为Windows子系统,需要解决路径问题"
  read -p "输入[Y/y]回车解决路径问题，输入[N/n]回车则退出编译： " Bendi_Wsl
  case ${Bendi_Wsl} in
  [Yy])
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/bendi/main/wsl.sh)"
    exit 0
  ;;
  [Nn])
    TIME y "退出编译openwrt固件"
    exit 1
  ;;
  esac
fi
}

function Ben_diskcapacity() {
total_size=$(df -h / | awk 'NR==2 {gsub("G", "", $2); print $2}')
available_size=$(df -h / | awk 'NR==2 {gsub("G", "", $4); print $4}')
TIME y "磁盘总量为[${total_size}G]，可用[${available_size}G]"
if [[ "${available_size}" -lt "20" ]];then
  TIME r "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于[ 20G ],是否继续?"
  read -p "直接回车退出编译，按[Y/y]回车则继续编译： " KJYN
  case ${KJYN} in
  [Yy]) 
    TIME y "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
    sleep 2
  ;;
  *)
    TIME y "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
    exit 0
  ;;
  esac
fi
}

function Ben_update() {
if [[ ! -f "/etc/oprelyon" ]]; then
  clear
  echo
  TIME y "首次使用本脚本，需要先安装依赖"
  TIME y "升级ubuntu插件和安装依赖，时间或者会比较长(取决于您的网络质量)，请耐心等待"
  TIME y "如果出现 YES OR NO 选择界面，直接按回车即可"
  TIME g "请确认是否继续进行,按任意键则继续,输入[N]后按回车则退出编译"
  read -p "确认选择:" elyou
    case $elyou in
    [Nn])
        echo
        exit 0
    ;;
    *)
        echo
    ;;
    esac
  sudo bash -c 'bash <(curl -fsSL https://github.com/281677160/common/raw/main/custom/ubuntu.sh)'
  if [[ $? -eq 0 ]];then
    sudo sh -c 'echo openwrt > /etc/oprelyonu'
  fi
fi
if [[ -f "/etc/ssh/sshd_config" ]] && [[ -z "$(grep -E 'ClientAliveInterval 30' /etc/ssh/sshd_config)" ]]; then
  sudo sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config
  sudo sed -i '/ClientAliveCountMax/d' /etc/ssh/sshd_config
  sudo sh -c 'echo ClientAliveInterval 30 >> /etc/ssh/sshd_config'
  sudo sh -c 'echo ClientAliveCountMax 6 >> /etc/ssh/sshd_config'
  sudo service ssh restart
fi
clear
}

function Ben_variable() {
cd ${GITHUB_WORKSPACE}
export FOLDER_NAME="$FOLDER_NAME"
export SETT_TINGS="$OPERATES_PATH/$FOLDER_NAME/settings.ini"
if [[ -f "${SETT_TINGS}" ]] && [[ "${NUM_BER}" == "1" ]]; then
  source ${SETT_TINGS}
else
  MODIFY_CONFIGURATION="$(grep '^MODIFY_CONFIGURATION=' "${SETT_TINGS}" | awk -F'"' '{print $2}')"
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
TIME y "正在执行：判断文件是否缺失"
curl -fsSL https://github.com/281677160/common/raw/ceshi/custom/first.sh -o /tmp/first.sh
if grep -q "TIME" "/tmp/first.sh"; then
  chmod +x /tmp/first.sh && source /tmp/first.sh
else
  TIME r "文件下载失败,请检查网络"
  exit 1
fi
if [[ "${TONGBU_YUANMA}" == "1" ]] && [[ -z "${SUCCESS_FAILED}" ]]; then
  exit 0
else
  source $COMMON_SH && Diy_variable
fi
}

function Ben_config() {
clear
echo
if [[ "${MODIFY_CONFIGURATION}" == "true" ]]; then
  TIME g "是否需要增删插件?"
  read -t 30 -p "[输入[ Y/y ]回车确认，任意键则为否](不作处理,30秒自动跳过)： " Bendi_Diy
  case ${Bendi_Diy} in
  [Yy])
    Menuconfig_Config="true"
    TIME y "您执行增删插件命令,请耐心等待程序运行至窗口弹出进行插件配置!"
  ;;
  *)
    Menuconfig_Config="false"
    TIME r "您已关闭选择增删插件设置!"
  ;;
  esac
fi
}

function Ben_xiazai() {
TIME g "开始执行编译固件"
cd ${GITHUB_WORKSPACE}
if [[ "${NUM_BER}" == "1" ]]; then
  TIME y "正在执行：下载${SOURCE}-${LUCI_EDITION}源码中，请耐心等候..."
  tmpdir="$(mktemp -d)"
  if git clone -b "${REPO_BRANCH}" --single-branch "${REPO_URL}" "${tmpdir}"; then
    rm -rf openwrt
    cp -Rf $tmpdir $HOME_PATH
    rm -rf $tmpdir
    TIME g "源码下载完成"
  else
    TIME r "源码下载失败,请检测网络"
    exit 1
  fi
elif [[ "${NUM_BER}" == "2" ]]; then
  TIME y "正在同步上游源码(${SOURCE}-${LUCI_EDITION})"
  tmpdir="$(mktemp -d)"
  if git clone -b "${REPO_BRANCH}" --single-branch "${REPO_URL}" "${tmpdir}"; then
    cd $HOME_PATH
    find . -maxdepth 1 \
      ! -name '.' \
      ! -name 'feeds' \
      ! -name 'dl' \
      ! -name 'build_dir' \
      ! -name 'staging_dir' \
      ! -name 'LICENSES' \
      ! -name '.config' \
      ! -name '.config.old' \
      -exec rm -rf {} +
    rsync -a $tmpdir/ $HOME_PATH/
    rm -rf $tmpdir
  else
    TIME r "源码下载失败,请检查网络"
    exit 1
  fi
elif [[ "${NUM_BER}" == "3" ]]; then
  cd $HOME_PATH
  TIME y "正在执行：更新和安装feeds"
  ./scripts/feeds update -a > /dev/null 2>&1
  ./scripts/feeds install -a
fi
}

function Ben_diyptsh() {
#加载自定义文件"
cd ${HOME_PATH}
source $COMMON_SH && Diy_partsh
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
rm -rf /tmp/build.log
make -j8 download |& tee /tmp/build.log 2>&1
if [[ -n "$(grep -E 'ERROR' /tmp/build.log)" ]]; then
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

if [[ "$(nproc)" -ge "8" ]];then
  cpunproc="8"
else
  cpunproc="$(nproc)"
fi

TIME z "即将使用${cpunproc}线程进行编译固件,请耐心等候..."
sleep 5

# 开始编译固件
make -j${cpunproc} || make -j1 V=s 2>&1 | tee $op_log

# 检测编译结果
if [[ -f "${op_log}" ]] && [[ -n "$(cat "${op_log}" |grep -i 'Error 2')" ]]; then
  echo "
  SUCCESS_FAILED="breakdown"
  SOURCE_CODE="${SOURCE_CODE}"
  SOURCE="${SOURCE}"
  FOLDER_NAME="${FOLDER_NAME}"
  REPO_BRANCH="${REPO_BRANCH}"
  REPO_URL="${REPO_URL}"
  LUCI_EDITION="${LUCI_EDITION}"
  TARGET_BOARD="${TARGET_BOARD}"
  MYCONFIG_FILE="${MYCONFIG_FILE}"
  TARGET_PROFILE="${TARGET_PROFILE}"
  CONFIG_FILE="${CONFIG_FILE}"
  " > ${LICENSES_DOC}/buildzu.ini
  sed -i 's/^[ ]*//g' ${LICENSES_DOC}/buildzu.ini
  TIME r "编译失败~~!"
  TIME y "在[operates/build.log]可查看编译日志"
  exit 1
else
  echo "
  SUCCESS_FAILED="success"
  SOURCE_CODE="${SOURCE_CODE}"
  SOURCE="${SOURCE}"
  FOLDER_NAME="${FOLDER_NAME}"
  REPO_BRANCH="${REPO_BRANCH}"
  REPO_URL="${REPO_URL}"
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
# 整理固件
cp -Rf config.buildinfo ${MYCONFIG_FILE}
if [[ -n "$(ls -1 |grep -E 'immortalwrt')" ]]; then
  rename -v "s/^immortalwrt/openwrt/" * > /dev/null 2>&1
  sed -i 's/immortalwrt/openwrt/g' `egrep "immortalwrt" -rl ./`
fi

for X in $(cat ${CLEAR_PATH} |sed "s/.*${TARGET_BOARD}//g"); do
  rm -rf *"$X"*
done

if [[ -n "$(ls -1 |grep -E 'armvirt')" ]] || [[ -n "$(ls -1 |grep -E 'armsr')" ]]; then
  mkdir -p $GITHUB_WORKSPACE/amlogic
  rm -rf $GITHUB_WORKSPACE/amlogic/${SOURCE}-${LUCI_EDITION}-armvirt-64-default-rootfs.tar.gz
  cp -Rf *rootfs.tar.gz $GITHUB_WORKSPACE/amlogic/${SOURCE}-${LUCI_EDITION}-armvirt-64-default-rootfs.tar.gz
  TIME g "[ Amlogic_Rockchip系列专用固件 ]顺利编译完成~~~"
  TIME y "固件存放路径：$GITHUB_WORKSPACE/amlogic/${SOURCE}-${LUCI_EDITION}-armvirt-64-default-rootfs.tar.gz"
else
  rename -v "s/^openwrt/${Gujian_Date}-${SOURCE}-${LUCI_EDITION}-${LINUX_KERNEL}/" * > /dev/null 2>&1
  TIME g "[ ${FOLDER_NAME}-${LUCI_EDITION}-${TARGET_PROFILE} ]顺利编译完成~~~"
  TIME y "固件存放路径：openwrt/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
fi

cd ${HOME_PATH}
# 计算结编译束时间
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

function jianli_wenjian() {
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "\n${YELLOW}请选择以什么文件夹为蓝本来建立新文件夹：${NC}"
PS3="请输入选项编号: "
select gender_wenjian in "Lede" "Immortalwrt" "Lienol" "Official" "Xwrt" "Mt798x"; do
    case $REPLY in
        1|2|3|4|5|6) 
            echo -e "已选择${GREEN}[$gender_wenjian]${NC}作为蓝本\n"
            break
            ;;
        *) 
            echo -e "${RED}无效选项，请重新输入！${NC}"
            ;;
    esac
done

echo -e "\n${YELLOW}请输入您要建立的文件夹名称${NC}"
while :; do
    read -p "请输入文件夹名称: " openwrt_wenjian
    if [[ -n "$openwrt_wenjian" ]]; then
        echo -e "${GREEN}文件夹名称：$openwrt_wenjian${NC}\n"
        break
    else
        echo -e "${RED}错误：文件夹名称不能为空！${NC}\n"
    fi
done

echo -e "\n${YELLOW}正在建立文件夹,请稍后...${NC}"
sudo rm -rf /tmp/actions
if git clone -q --depth 1 https://github.com/281677160/build-actions /tmp/actions; then
  if [[ -d "${OPERATES_PATH}/${openwrt_wenjian}" ]]; then
    echo -e "${RED}错误：${openwrt_wenjian}文件夹已存在,无法再次建立！${NC}\n"
  else
    cp -Rf /tmp/actions/build/$gender_wenjian ${OPERATES_PATH}/${openwrt_wenjian}
    echo -e "${GREEN}$openwrt_wenjian文件夹建立完成！${NC}\n"
  fi
else
  clear
  echo -e "${RED}上游文件下载错误,请检查网络${NC}\n"
  jianli_wenjian
fi

echo -e "\n${YELLOW}按Q回车返回主菜单,按N退出程序${NC}\n"
read -p "确认选择: " WNKC
while :; do
    case $WNKC in
    [Qq])
        menu1
        break
    ;;
    [Nn])
        exit 0
        break
    ;;
    *)
        echo "请输入正确的数字编号"
    ;;
    esac
done
}

function shanchu_wenjian() {
echo
cd ${OPERATES_PATH}
ls -d */ |cut -d"/" -f1 |awk '{print "  " $0}'
cd ${GITHUB_WORKSPACE}
TIME y "请输入您要删除的文件名称,多个文件名的话请用英文的逗号分隔,输入[N/n]回车则退出"
while :; do
    read -p "请输入：" cc
    if [[ "${cc}" =~ ^[Nn]$ ]]; then
        exit 0
    elif [[ -z "${cc}" ]]; then
        TIME r " 警告：文件夹名称不能为空"
    else
        TIME g " 选择删除[${cc}]文件夹"
        break
    fi
done

bb=(${cc//,/ })
for i in ${bb[@]}; do
  if [[ -d "${OPERATES_PATH}/${i}" ]]; then
    sudo rm -rf ${OPERATES_PATH}/${i}
    TIME y " 已删除[${i}]文件夹"
  else
    TIME r " [${i}]文件夹不存在"
  fi
done

TIME g "按Q回车返回主菜单,按N退出程序"
read -p "确认选择: " SNKC
while :; do
    case $SNKC in
    [Qq])
        menu1
        break
    ;;
    [Nn])
        exit 0
        break
    ;;
    *)
        echo "请输入正确的数字编号"
    ;;
    esac
done
}

function Ben_packaging() {
# 固件打包程序,本地不能使用,不知何解
cd $GITHUB_WORKSPACE
CLONE_DIR="$GITHUB_WORKSPACE/amlogic/armvirt"
if [[ -d "${CLONE_DIR}" ]]; then
  TIME_THRESHOLD=86400
  LAST_MODIFIED=$(stat -c %Y "$CLONE_DIR" 2>/dev/null || echo 0)
  CURRENT_TIME=$(date +%s)
  TIME_DIFF=$((CURRENT_TIME - LAST_MODIFIED))
  if [ "$TIME_DIFF" -gt "$TIME_THRESHOLD" ]; then
    sudo rm -rf "$CLONE_DIR"
    if [[ -d "${CLONE_DIR}" ]]; then
      TIME r "旧的打包程序存在，且无法删除,请重启ubuntu再来操作"
      exit 1
    fi
  fi
fi

if [[ ! -d "amlogic" ]]; then
  mkdir -p $GITHUB_WORKSPACE/amlogic
  TIME r "请用WinSCP工具将\"xxx-armvirt-64-default-rootfs.tar.gz\"固件存入[$GITHUB_WORKSPACE/amlogic]文件夹中"
  exit 1
else
  find $GITHUB_WORKSPACE/amlogic -type f -name "*.rootfs.tar.gz" -size -2M -delete
  sudo rm -rf $GITHUB_WORKSPACE/amlogic/*Identifier*
  if [[ -z "$(find $GITHUB_WORKSPACE/amlogic -maxdepth 1 -name '*rootfs.tar.gz' -print -quit)" ]]; then
    TIME r "请用WinSCP工具将\"xxx-armvirt-64-default-rootfs.tar.gz\"固件存入[$GITHUB_WORKSPACE/amlogic]文件夹中"
    exit 1
  fi
fi

if [[ ! -d "${CLONE_DIR}" ]]; then
  if git clone -q https://github.com/ophub/amlogic-s9xxx-openwrt.git $CLONE_DIR; then
    echo ""
    mkdir -p $CLONE_DIR/openwrt-armvirt
  else
    TIME r "打包程序下载失败,请检查网络"
    exit 1
  fi
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}\n==== 打包信息采集 ====${NC}\n"
kernel_repo="ophub/kernel"
builder_name="ophub"

echo -e "\n${YELLOW}请选择固件名称：${NC}"
PS3="请输入选项编号: "
select gender in "Lede" "Immortalwrt" "Lienol" "Official" "Xwrt" "Mt798x"; do
    case $REPLY in
        1|2|3|4|5|6) 
            echo -e "已选择: ${GREEN}$gender-armvirt-64-default-rootfs.tar.gz${NC}\n"
            break
            ;;
        *) 
            echo -e "${RED}无效选项，请重新输入！${NC}"
            ;;
    esac
done

echo -e "\n${YELLOW}输入机型,比如：s905d 或 s905d_s905x2${NC}"
while :; do
    read -p "请输入打包机型: " openwrt_board
    if [[ -n "$openwrt_board" ]]; then
        break
    else
        echo -e "${RED}错误：机型不能为空！${NC}\n"
    fi
done

echo -e "\n${YELLOW}输入内核版本,比如：5.10.172 或 5.15.97_6.1.16${NC}"
while :; do
    read -p "请输入打包机型: " openwrt_kernel
    if [[ -n "$openwrt_kernel" ]]; then
        break
    else
        echo -e "${RED}错误：机型不能为空！${NC}\n"
    fi
done

echo -e "\n${YELLOW}是否自动选择输入内核版本为最新版本：${NC}"
PS3="请输入选项编号: "
select auto_kernell in "自动选择最新版本内核" "无需选择最新版本内核"; do
    case $REPLY in
        1|2) 
            echo -e "已选择: ${GREEN}$auto_kernell${NC}"
            break
            ;;
        *) 
            echo -e "${RED}无效选项，请重新输入！${NC}"
            ;;
    esac
done

if [[ "${auto_kernell}" == "无需选择最新版本内核" ]]; then
    auto_kernel="false"
else
    auto_kernel="true"
fi

echo -e "\n${YELLOW}设置rootfs大小(单位：MiB),比如：1024 或 512/2560${NC}"
while :; do
    read -p "请输入打包机型: " openwrt_size
    if [[ -n "$openwrt_size" ]]; then
        break
    else
        echo -e "${RED}错误：机型不能为空！${NC}\n"
    fi
done

echo -e "\n${YELLOW}请选择内核仓库(内核的作者)：${NC}"
PS3="请输入选项编号: "
select kernel_usage in "stable" "flippy" "dev" "beta"; do
    case $REPLY in
        1|2|3|4) 
            echo -e "已选择: ${GREEN}$kernel_usage${NC}\n"
            break
            ;;
        *) 
            echo -e "${RED}无效选项，请重新输入！${NC}"
            ;;
    esac
done

echo -e "\n${GREEN}==== 录入完成 ====${NC}"
echo -e "▪ 固件名称\t: $gender"
echo -e "▪ 打包机型\t: $openwrt_board"
echo -e "▪ 内核版本\t: $openwrt_kernel"
echo -e "▪ 分区大小\t: $openwrt_size"
echo -e "▪ 内核仓库\t: $kernel_usage"
echo -e "▪ 内核选择\t: $auto_kernell"

echo -e "\n${YELLOW}检查信息是否正确,正确回车继续,不正确按Q回车重新输入,按N退出打包${NC}\n"
read -p "确认选择: " NNKC
case $NNKC in
  [Qq])
    Ben_packaging
    clear
    break
  ;;
  [Nn])
    exit 0
    break
  ;;
  *)
    echo
    break
  ;;
esac

if [[ -f "$GITHUB_WORKSPACE/amlogic/armvirt/remake" ]]; then
  cp -Rf $GITHUB_WORKSPACE/amlogic/${gender}-armvirt-64-default-rootfs.tar.gz $GITHUB_WORKSPACE/amlogic/armvirt/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz
  cd $GITHUB_WORKSPACE/amlogic/armvirt
  TIME g "开始打包固件..."
  sudo chmod +x remake
  sudo ./remake -b ${openwrt_board} -k ${openwrt_kernel} -a ${auto_kernel} -s ${openwrt_size} -r ${kernel_repo} -u ${kernel_usage} -n ${builder_name}
  if [[ $? -eq 0 ]];then
    TIME g "打包完成，固件存放在[amlogic/armvirt/openwrt/out]文件夹"
  else
    TIME r "打包失败!"
  fi
else
  TIME r "未知原因打包程不存在,或上游改变了程序名称"
  exit 1
fi
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
}


function Diy_main() {
Ben_wslpath
Ben_diskcapacity
Ben_update
Ben_variable
Ben_config
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
Ben_variable
Ben_config
Ben_diskcapacity
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

function Diy_main3() {
Ben_variable
Ben_config
Ben_diskcapacity
Ben_xiazai
Ben_menuconfig
Ben_menu4
Ben_download
Ben_menu7
}


function wenjian() {
cd ${GITHUB_WORKSPACE}
clear
echo
TIME y " 1. 添加文件夹"
TIME y " 2. 删除文件夹"
TIME r " 3. 返回主菜单"
echo
XUANZHEOP="请输入数字"
echo
while :; do
read -p " ${XUANZHEOP}： " CHOOSE
case $CHOOSE in
1)
  jianli_wenjian
break
;;
2)
  shanchu_wenjian
break
;;
3)
  menu1
break
;;
*)
   XUANZHEOP="请输入正确的数字编号"
;;
esac
done
}

function menu1() {
cd ${GITHUB_WORKSPACE}
clear
echo
TIME y " 1. 进行编译固件"
TIME g " 2. 创建或删除文件夹"
TIME r " 3. 退出程序"
echo
XUANZHEOP="请输入数字"
echo
while :; do
read -p " ${XUANZHEOP}： " CHOOSE
case $CHOOSE in
1)
  menu3
break
;;
2)
  wenjian
break
;;
3)
  echo
  exit 0
break
;;
*)
   XUANZHEOP="请输入正确的数字编号"
;;
esac
done
}

function menu2() {
  clear
  echo
  if [[ "${SUCCESS_FAILED}" == "success" ]]; then
    TIME g " 上回使用${SOURCE}-${LUCI_EDITION}源码${Font}${Blue}成功编译${TARGET_PROFILE}固件"
  else
    TIME r " 上回使用${SOURCE}-${LUCI_EDITION}源码${Font}${Blue}编译${TARGET_PROFILE}固件失败"
    TIME g " 需要注意的是,有些情况下编译失败,还保留缓存继续编译的话,会一直编译失败的"
  fi
  echo
  TIME y " 1、保留全部缓存,不再读取配置文件,只执行(make menuconfig)再编译"
  echo
  TIME y " 2、保留部分缓存(插件源码都重新下载),可改配置文件再编译"
  echo
  TIME y " 3、放弃缓存,重新编译"
  echo
  TIME y " 4、重选择源码编译"
  echo
  TIME y " 5、返回主菜单"
  echo
  TIME r " 6、退出"
  echo
  XUANZop="请输入数字"
  echo
  while :; do
  read -p " ${XUANZop}：" menu_num
  case $menu_num in
  1)
    export NUM_BER="3"
    Diy_main3
  break
  ;;
  2)
    export NUM_BER="2"
    Diy_main2
  break
  ;;
  3)
    export NUM_BER="1"
    Diy_main
  break
  ;;
  4)
    export NUM_BER=""
    menu3
  break
  ;;
  5)
    export NUM_BER=""
    menu1
  break
  ;;
  6)
    echo
    exit 0
  break
  ;;
  *)
    XUANZop="请输入正确的数字编号"
  ;;
  esac
  done
}

function menu3() {
  clear
  echo 
  echo
  cd ${OPERATES_PATH}
  XYZDSZ="$(ls -d */ | grep -v 'common\|backups' |cut -d"/" -f1 |awk '$0=NR" "$0'| awk 'END {print}' |awk '{print $(1)}')"
  ls -d */ | grep -v 'common\|backups' |cut -d"/" -f1 > /tmp/GITHUB_EVN
  ls -d */ | grep -v 'common\|backups' |cut -d"/" -f1 |awk '$0=NR"、"$0'|awk '{print "  " $0}'
  cd ${GITHUB_WORKSPACE}
  YMXZQ="QpyZm"
  if [[ "${SUCCESS_FAILED}" =~ (success|breakdown) ]]; then
      hx=",输入[Q/q]返回上一步"
      YMXZQ="Q|q"
  fi
  TIME y "请输入您要编译源码前面对应的数值(1~X)${hx}，输入[N/n]则为退出程序"
  while :; do
    read -p "请输入您的选择：" YMXZ
    if [[ "${YMXZ}" =~ ^[Nn]$ ]]; then
        exit 0
    elif [[ -z "${YMXZ}" ]]; then
        TIME r "敬告,输入不能为空"
    elif [[ "$YMXZ" =~ ^[0-9]+$ ]]; then
      if (( YMXZ >= 1 && YMXZ <= XYZDSZ )); then
        export FOLDER_NAME=$(cat /tmp/GITHUB_EVN | awk ''NR==${YMXZ}'')
        export NUM_BER="1"
        TIME g "您选择了使用 ${FOLDER_NAME} 编译固件"
        sleep 3
        Diy_main
        break
      else
        TIME r "敬告,请输入正确数值(1~${XYZDSZ})" >&2
      fi
    elif [[ "${YMXZ}" =~ (${YMXZQ}) ]]; then
        menu2
        break
    else
        TIME r "敬告,请输入正确值"
    fi
  done
}

function main() {
if [[ -f "${LICENSES_DOC}/buildzu.ini" ]]; then
  source ${LICENSES_DOC}/buildzu.ini
fi
if [[ ! -d "${OPERATES_PATH}" ]]; then
  TIME y "缺少编译主文件"
  curl -fsSL https://github.com/281677160/common/raw/ceshi/custom/first.sh -o /tmp/first.sh
  chmod +x /tmp/first.sh && source /tmp/first.sh
  if [[ -z "${SUCCESS_FAILED}" ]]; then
    exit 0
  fi
fi
if [[ -n "${SUCCESS_FAILED}" ]]; then
  required_dirs=("config" "include" "package" "scripts" "target" "toolchain" "tools" "build_dir")
  missing_flag=0
  for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$HOME_PATH/$dir" ]]; then
      missing_flag=1
    fi
  done
  
  if [[ $missing_flag -eq 0 ]] && [[ -n "$( grep -E "${TARGET_BOARD}" "$HOME_PATH/.config" 2>/dev/null)" ]] && \
  [[ -n "$( grep -E "${REPO_URL}" "${DIAN_GIT}" 2>/dev/null)" ]] && [[ -n "$( grep -E "${REPO_BRANCH}" "${DIAN_GIT}" 2>/dev/null)" ]]; then
    menu2
  else
    menu1
  fi
else
  menu1
fi
}
main
