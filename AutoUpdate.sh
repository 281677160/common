#!/bin/sh
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoUpdate for Openwrt

function GET_PID() {
  local Result
  while [[ $1 ]];do
    Result=$(busybox ps | grep "$1" | grep -v "grep" | awk '{print $1}' | awk 'NR==1')
    [[ -n ${Result} ]] && echo ${Result}
  shift
  done
}

function LOGGER() {
  [[ ! -d ${AutoUpdate_Log_Path} ]] && mkdir -p ${AutoUpdate_Log_Path}
  [[ ! -f ${AutoUpdate_Log_Path}/AutoUpdate.log ]] && touch ${AutoUpdate_Log_Path}/AutoUpdate.log
  echo "[$(date "+%Y-%m-%d-%H:%M:%S")] [$(GET_PID AutoUpdate)-${Update_explain}] $*" >> ${AutoUpdate_Log_Path}/AutoUpdate.log
}

White="\033[0;37m"
Yellow="\033[0;33m"
White="\033[0;37m"
Yellow="\033[0;33m"
Red="\033[1;91m"
Blue="\033[0;94m"
BLUEB="\033[1;94m"
BCyan="\033[1;36m"
Grey="\033[1;34m"
Green="\033[0;92m"
Purple="\033[1;95m"
TIME() {
  local Color
  [[ -z $1 ]] && {
    echo -ne "\n${Grey}[$(date "+%H:%M:%S")]${White} "
  } || {
  case $1 in
    r) Color="${Red}";;
    g) Color="${Green}";;
    b) Color="${Blue}";;
    B) Color="${BLUEB}";;
    y) Color="${Yellow}";;
    h) Color="${BCyan}";;
    z) Color="${Purple}";;
    x) Color="${Grey}";;
  esac
    [[ $# -lt 2 ]] && {
      echo -e "\n${Grey}[$(date "+%H:%M:%S")]${White} $1"
      LOGGER $1
    } || {
      echo -e "\n${Grey}[$(date "+%H:%M:%S")]${White} ${Color}$2${White}"
      LOGGER $2
    }
  }
}

if [[ -f "/bin/openwrt_info" ]]; then
  chmod +x /bin/openwrt_info
  source /bin/openwrt_info
  if [[ $? -ne 0 ]];then
    TIME r "openwrt_info数据有误,请检查openwrt_info!"
    echo "/bin/openwrt_info文件数据有误,请检查openwrt_info!" > /tmp/cloud_version
    exit 1
  fi
  if [[ -z ${CURRENT_Version} ]]; then
    TIME r "本地固件版本信息获取失败,请检查/bin/openwrt_info文件的值!"
    echo "本地固件版本信息获取失败,请检查/bin/openwrt_info文件的值!" > /tmp/cloud_version
    exit 1
  fi
  if [[ -z ${Github} ]]; then
    TIME r "Github地址获取失败,请检查/bin/openwrt_info文件的值!"
    echo "Github地址获取失败,请检查/bin/openwrt_info文件的值!" > /tmp/cloud_version
    exit 1
  fi
else
  TIME r "未检测到openwrt_info文件,无法运行更新程序!"
  echo "未检测到openwrt_info文件,无法运行更新程序!" > /tmp/cloud_version
  exit 1
fi

export Version=V7.0
export Input_Option=$1
export Input_Other=$2
export Kernel="$(egrep -o "[0-9]+\.[0-9]+\.[0-9]+" /usr/lib/opkg/info/kernel.control)"
export Overlay_Available="$(df -h | grep ":/overlay" | awk '{print $4}' | awk 'NR==1')"
export TMP_Available="$(df -m | grep "/tmp" | awk '{print $4}' | awk 'NR==1' | awk -F. '{print $1}')"
[ ! -d "${Download_Path}" ] && mkdir -p ${Download_Path} || rm -rf "${Download_Path}"/*
opkg list | awk '{print $1}' > ${Download_Path}/Installed_PKG_List
export PKG_List="${Download_Path}/Installed_PKG_List"
export AutoUpdate_Log_Path="/tmp"


function Helper_ml() {
clear
echo
echo
echo "命令说明：

AutoUpdate  保留配置更新固件

AutoUpdate -n 不保留配置更新固件

AutoUpdate -s 查看详情

AutoUpdate -h 查看命令说明

AutoUpdate -z 转换其他作者固件（前提是您编译了有其他作者的固件）

"
exit 0
}

function Shell_Helper() {
if [[ -f "/etc/local_Version" ]]; then
  export LOCAL_Version="$(cat /etc/local_Version)" > /dev/null 2>&1
else
  wget -q -P ${Download_Path} https://ghproxy.com/${Github_API2} -O ${API_PATH} > /dev/null 2>&1
  export LOCAL_Version="$(egrep -o "${LOCAL_CHAZHAO}-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')" > /dev/null 2>&1
fi
clear
echo
echo
echo -e "${Yellow}详细参数：

/overlay 可用:		${Overlay_Available}
/tmp 可用:		${TMP_Available}M
固件下载位置:		${Download_Path}
当前设备名称:		${CURRENT_Device}
固件上的名称:		${DEFAULT_Device}
当前固件版本:		${CURRENT_Version}
Github 地址:		${Github}
解析 API 地址:		${Github_API1}
固件下载地址:		${Github_Release}
更新运行日志:		${AutoUpdate_Log_Path}/AutoUpdate.log
固件作者:		${Author}
作者仓库:		${Library}
固件名称:		${LOCAL_Version}
固件格式:		${BOOT_Type}${Firmware_SFX}

${White}"
exit 0
}

function lian_wang() {
TIME g "检测机器是否联网..."
curl --connect-timeout 8 -o /tmp/baidu.html -s -w %{time_namelookup}: http://www.baidu.com > /dev/null 2>&1
if [[ -f /tmp/baidu.html ]] && [[ `grep -c "百度一下" /tmp/baidu.html` -ge '1' ]]; then
  rm -rf /tmp/baidu.html
  TIME y "您的网络正常!"
else
  TIME r "您可能没进行联网,请检查网络,或您的网络不能连接百度?"
  echo "您可能没进行联网,请检查网络,或您的网络不能连接百度?" > /tmp/cloud_version
  exit 1
fi
}

function model_name() {
case "${TARGET_BOARD}" in
x86)
  [ -d /sys/firmware/efi ] && {
    export BOOT_Type="uefi"
  } || {
    export BOOT_Type="legacy"
  }
  export CPUmodel="$(cat /proc/cpuinfo |grep 'model name' |awk 'END {print}' |cut -f2 -d: |sed 's/^[ ]*//g'|sed 's/\ CPU//g')"
  if [[ "$(echo ${CPUmodel} |grep -c 'Intel')" -ge '1' ]]; then
    export Cpu_Device="$(echo "${CPUmodel}" |awk '{print $2}')"
    export CURRENT_Device="$(echo "${CPUmodel}" |sed "s/${Cpu_Device}//g")"
  else
    export CURRENT_Device="${CPUmodel}"
  fi
;;
rockchip | bcm27xx | mxs | sunxi | zynq)
  [ -d /sys/firmware/efi ] && {
    export BOOT_Type="uefi"
  } || {
    export BOOT_Type="legacy"
  }
  export CURRENT_Device="$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')"
;;
mvebu)
  case "${TARGET_SUBTARGET}" in
  cortexa53 | cortexa72)
    [ -d /sys/firmware/efi ] && {
      export BOOT_Type="uefi"
    } || {
      export BOOT_Type="legacy"
    }
    export CURRENT_Device="$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')"
  ;;
  esac
;;
*)
  export CURRENT_Device="$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')"
  export BOOT_Type="sysupgrade"
esac
}

function api_data() {
TIME g "正在获取云端API数据..."
[ ! -d ${Download_Path} ] && mkdir -p ${Download_Path}
wget -q ${Github_API1} -O ${API_PATH} > /dev/null 2>&1
if [[ $? -ne 0 ]];then
  TIME r "获取云端API数据失败，切换工具继续下载中..."
  wget -q https://ghproxy.com/${Github_API2} -O ${API_PATH} > /dev/null 2>&1
  if [[ $? -ne 0 ]];then
    TIME r "获取云端API数据失败"
    TIME g "您当前Github地址:${Github}"
    TIME y "您当前Github地址获取API数据失败,或您的仓库为私库!"
    echo "获取API数据失败,Github地址不正确，或此地址没云端存在，或您的仓库为私库!" > /tmp/cloud_version
    echo
    exit 1
  else
    TIME y "获取云端API数据成功!"
  fi
else
  TIME y "获取云端API数据成功!"
fi
}

function cloud_Version() {
# 搞出本地版本固件名字用作显示用途
export LOCAL_Version="$(egrep -o "${LOCAL_CHAZHAO}-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
export LOCAL_Firmware="$(grep 'CURRENT_Version=' "/bin/openwrt_info" | cut -d "=" -f2)"
if [[ -z "${LOCAL_Version}" ]]; then
  export LOCAL_Version="云端有没发现您现在安装的固件版本存在"
fi
echo "${LOCAL_Version}" > /etc/local_Version

TIME g "正在获取云端固件版本信息..."
export CLOUD_Version="$(egrep -o "${CLOUD_CHAZHAO}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
export CLOUD_Firmware="$(echo ${CLOUD_Version} | egrep -o "${SOURCE}-${DEFAULT_Device}-[0-9]+")"
if [[ -z "${CLOUD_Version}" ]]; then
  TIME r "获取云端固件版本信息失败,如果是x86的话,注意固件的引导模式是否对应,或者是蛋痛的脚本作者修改过脚本导致固件版本信息不一致!"
  echo "获取云端固件版本信息失败,如果是x86的话,注意固件的引导模式是否对应,或者是蛋痛的脚本作者修改过脚本导致固件版本信息不一致!" > /tmp/cloud_version
  exit 1
else
  TIME y "获取云端固件版本成功,进行对比本地版本和云端版本!"
fi
}

function record_version() {
cat > /tmp/Version_Tags <<-EOF
LOCAL_Firmware=${LOCAL_Firmware}
CLOUD_Firmware=${CLOUD_Firmware}
EOF
cat > /etc/openwrt_upgrade <<-EOF
LOCAL_Firmware=${LOCAL_Firmware}
MODEL_type=${BOOT_Type}${Firmware_SFX}
KERNEL_type=${Kernel} - ${LUCI_EDITION}
CURRENT_Device=${CURRENT_Device}
EOF
if [[ "${Input_Other}" == "-w" ]]; then
exit 0
fi
export LOCAL_Firmware="$(grep 'LOCAL_Firmware=' "/tmp/Version_Tags" | cut -d "-" -f4)"
export CLOUD_Firmware="$(grep 'CLOUD_Firmware=' "/tmp/Version_Tags" | cut -d "-" -f4)"
}

function firmware_Size() {
let X="$(grep -n ${CLOUD_Version} ${API_PATH} | tail -1 | cut -d : -f 1)-4"
if [[ "$X" = "-3" ]]; then
  TIME r "获取云端固件体积失败!"
  export CLOUD_Firmware_Size="1"
else
  let CLOUD_Firmware_Size="$(sed -n "${X}p" ${API_PATH} | egrep -o "[0-9]+" | awk '{print ($1)/1048576}' | awk -F. '{print $1}')+1"
fi
if [[ "${TMP_Available}" -lt "${CLOUD_Firmware_Size}" ]]; then
  TIME g "tmp 剩余空间: ${TMP_Available}M"
  TIME r "tmp空间不足[${CLOUD_Firmware_Size}M],不够下载固件所需,请清理tmp空间或者增加运行内存!"
  echo
  exit 1
fi
}

function comparison_firmware() {
echo
echo -e "\n本地版本：${LOCAL_Version}"
echo "云端版本：${CLOUD_Version}"
echo "设备名称：${CURRENT_Device}"
echo "固件作者：${Author}"
if [[ "${Firmware_SFX}" =~ "(.img.gz|.img)" ]]; then
  echo "引导模式：${BOOT_Type}"
fi
echo "固件体积：${CLOUD_Firmware_Size}M"
echo
if [[ ! "${Input_Other}" == "-t" ]]; then
  if [[ "${LOCAL_Firmware}" == "${CLOUD_Firmware}" ]]; then
    QLMEUN="当前版本和云端最高版本一致，是否需要重新安装固件?[Y/n]"
    while :; do
      read -p "${QLMEUN}"： Choose
      case $Choose in
      [Yy])
        TIME z "正在开始重新安装固件..."
      break
      ;;
      [Nn])
        TIME r "已取消重新安装固件!"
        exit 1
       break
       ;;
       *)
         QLMEUN="请输入正确选择[Y/n]"
       ;;
       esac
    done
  elif [[ "${LOCAL_Firmware}" -gt "${CLOUD_Firmware}" ]]; then
    QLMEUN="云端最高版本,低于您现在安装的版本,是否强制覆盖现有固件?[Y/n]"
    while :; do
      read -p "${QLMEUN}"： Choose
      case $Choose in
      [Yy])
        TIME z "开始使用云端版本覆盖现有固件..."
      break
      ;;
      [Nn])
        TIME r "已取消重新安装固件!"
        exit 1
       break
       ;;
       *)
         QLMEUN="请输入正确选择[Y/n]"
       ;;
       esac
    done
  else
    TIME y "检测到有可更新的固件版本,立即更新固件!"
  fi
fi
}

function u_firmware() {
if [[ "${LOCAL_Firmware}" -lt "${CLOUD_Firmware}" ]]; then
  TIME y "检测到有可更新的固件版本,立即更新固件!"
else
  TIME r "没检测到有可更新的固件版本,退出程序!"
  exit 0
fi
}

function download_firmware() {
cd ${Download_Path}
TIME g "正在下载云端固件,请耐心等待..."
echo
if [[ "$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)" == "301" ]]; then
  rm -rf "${CLOUD_Version}" && curl -# -LJO "${Release_download}/${CLOUD_Version}"
  if [[ $? -ne 0 ]];then
    TIME r "下载固件失败，切换工具继续下载中..."
    rm -rf "${CLOUD_Version}" && wget -q "https://ghproxy.com/${Release_download}/${CLOUD_Version}" -O ${CLOUD_Version}
    if [[ $? -ne 0 ]];then
      TIME r "下载云端固件失败,请尝试手动安装!"
      echo
      exit 1
    else
      TIME y "下载云端固件成功!"
    fi
  else
    TIME y "下载云端固件成功!"
  fi
else
  rm -rf "${CLOUD_Version}" && curl -# -LJO "https://ghproxy.com/${Release_download}/${CLOUD_Version}"
  if [[ $? -ne 0 ]];then
    echo "下载错误，切换工具继续下载中..."
    rm -rf "${CLOUD_Version}" && wget -q "https://pd.zwc365.com/${Release_download}/${CLOUD_Version}" -O ${CLOUD_Version}
    if [[ $? -ne 0 ]];then
      TIME r "下载云端固件失败,请尝试手动安装!"
      echo
      exit 1
    else
      TIME y "下载云端固件成功!"
    fi
  else
    TIME y "下载云端固件成功!"
  fi
fi
}

function md5sum_sha256sum() {
export LOCAL_MD5=$(md5sum ${CLOUD_Version} | cut -c1-3)
export LOCAL_256=$(sha256sum ${CLOUD_Version} | cut -c1-3)
export MD5_256=$(echo ${CLOUD_Version} | egrep -o "[a-zA-Z0-9]+${Firmware_SFX}" | sed -r "s/(.*)${Firmware_SFX}/\1/")
export CLOUD_MD5="$(echo "${MD5_256}" | cut -c1-3)"
export CLOUD_256="$(echo "${MD5_256}" | cut -c 4-)"
if [[ ! "${LOCAL_MD5}" == "${CLOUD_MD5}" ]]; then
  TIME r "MD5对比失败,固件可能在下载时损坏,请检查网络后重试!"
  exit 1
fi
if [[ ! "${LOCAL_256}" == "${CLOUD_256}" ]]; then
  TIME r "SHA256对比失败,固件可能在下载时损坏,请检查网络后重试!"
  exit 1
fi
}

function input_other_t() {
if [[ "${Input_Other}" == "-t" ]]; then
  TIME z "测试模式运行完毕!"
  rm -rf "${Download_Path}"
  echo
  exit 0
fi
}

function update_firmware() {
chmod 777 ${CLOUD_Version}
[[ "$(cat ${PKG_List})" =~ gzip ]] && opkg remove gzip > /dev/null 2>&1
TIME g "正在执行"${Update_explain}",更新期间请不要断开电源或重启设备 ..."
sleep 2
if [[ "${AutoUpdate_Mode}" == "1" ]]; then
  if [[ -f "/etc/deletefile" ]]; then
    chmod 775 "/etc/deletefile"
    source /etc/deletefile
  fi
  curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/281677160/common/main/Custom/Detectionnetwork > /mnt/Detectionnetwork
  if [[ $? -ne 0 ]]; then
    wget -P /mnt https://raw.githubusercontent.com/281677160/common/main/Custom/Detectionnetwork -O /mnt/Detectionnetwork
  fi
  if [[ $? -eq 0 ]]; then
    chmod 775 "/mnt/Detectionnetwork"
    echo "*/5 * * * * source /mnt/Detectionnetwork > /dev/null 2>&1" >> /etc/crontabs/root
    /etc/init.d/cron restart
  fi
  cp -Rf /etc/config/network /mnt/network
  mv -f /etc/config/luci /tmp/luci
  rm -rf /mnt/back.tar.gz
  sysupgrade -b /mnt/back.tar.gz
  [[ $? -ne 0 ]] && {
    mv -f /tmp/luci /etc/config/luci
    export Upgrade_Options="sysupgrade -q"
  } || {
    export Upgrade_Options="sysupgrade -f /mnt/back.tar.gz"
  }
fi

${Upgrade_Options} ${CLOUD_Version}
}

function Update_u() {
lian_wang
model_name
api_data
cloud_Version
record_version
firmware_Size
u_firmware
download_firmware
md5sum_sha256sum
update_firmware
}

function Update_Options() {
lian_wang
model_name
api_data
cloud_Version
record_version
firmware_Size
comparison_firmware
download_firmware
md5sum_sha256sum
input_other_t
update_firmware
}

clear
echo
echo "Openwrt-AutoUpdate Script ${Version}"
echo
if [[ -z "${Input_Option}" ]]; then
  TIME h "执行: 更新固件[保留配置]"
  export Update_explain="保留配置更新固件"
  export Upgrade_Options="sysupgrade -q"
  export AutoUpdate_Mode="1"
  Update_Options
else
  case ${Input_Option} in
  -t | -w | -n | -N | -u)
    case ${Input_Option} in
    -t)
      TIME h "执行: 测试模式(只运行程序,不安装固件)"
      export Update_explain="测试模式"
      export AutoUpdate_Mode="0"
      export Input_Other="-t"
      Update_Options
    ;;
    -w)
      export Input_Other="-w"
      Update_Options
    ;;
    -n | -N)
      TIME h "执行: 更新固件(不保留配置)"
      export Update_explain="不保留配置更新固件"
      export Upgrade_Options="sysupgrade -F -n"
      export AutoUpdate_Mode="0"
      Update_Options
    ;;
    -u)
      export Update_explain="在线静默保留配置更新固件"
      export Upgrade_Options="sysupgrade -q"
      export AutoUpdate_Mode="1"
      Update_u
    ;;
    esac
  ;;
  -c)
      Github="$(grep Github= /bin/openwrt_info | cut -d "=" -f2)"
      TIME h "执行：更换[Github地址]操作"
      TIME y "正确地址格式：https://github.com/帐号/仓库"
      TIME h  "现在所用地址为：${Github}"
      echo
      export YUMING="请输入新的Github地址(直接回车为不修改,退出程序)"      
      while :; do
      dogithub=""
      read -p "${YUMING}：" Input_Other
      Input_Other="${Input_Other:-"$Github"}"
      if [[ "$(echo ${Input_Other} |grep -c 'https://github.com/.*/.*')" == '1' ]]; then
        dogithub="Y"
      fi
      case $dogithub in
      Y)
        export Input_Other="${Input_Other}"
      break
      ;;
      *)
        export YUMING="敬告：您输入的Github地址无效,请输入正确格式的Github地址,或留空回车退出!"
      ;;
      esac
      done
      export Github_uci=$(uci get autoupdate.@login[0].github 2>/dev/null)
      [[ -n "${Github_uci}" ]] && [[ "${Github_uci}" != "${Input_Other}" ]] && {
        export ApAuthor="${Input_Other%.git*}"
        export custm_github_url="${ApAuthor##*com/}"
        export curret_github_url="$(grep Warehouse= /bin/openwrt_info | cut -d "=" -f2)"
        sed -i "s?${curret_github_url}?${custm_github_url}?g" /bin/openwrt_info
        export Input_Other="$(grep Github= /bin/openwrt_info | cut -d "=" -f2)"
        uci set autoupdate.@login[0].github=${Input_Other}
        uci commit autoupdate
        TIME y "Github 地址已更换为: ${Input_Other}"
        TIME y "UCI 设置已更新!"
        export custm_github_url=""
        export curret_github_url=""	
        echo
      }

      Input_Other="${Input_Other:-"$Github"}"
      [[ "${Github}" != "${Input_Other}" ]] && {
        sed -i "s?${Github}?${Input_Other}?g" /bin/openwrt_info
        unset Input_Other
        exit 0
      } || {
        TIME g "INPUT: ${Input_Other}"
        TIME r "输入的 Github 地址相同,无需修改!"
        echo
        exit 1
      }
  ;;
  -z)
    TIME g "加载信息中，请稍后..."
    replace
  ;;
  -h)
    TIME g "加载信息中，请稍后..."
    model_name
    Shell_Helper
  ;;
  -s)
    Helper_ml
  ;;
  *)
    echo -e "\nERROR INPUT: [$*]"
    Helper_ml
  ;;
  esac
fi
