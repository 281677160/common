#!/bin/bash
# https://github.com/281677160/build-actions
# common Module by 28677160
# matrix.target=${FOLDER_NAME}

function TIME() {
Compte=$(date +%Y年%m月%d号%H时%M分)
  [[ -z "$1" ]] && {
    echo -ne " "
    } || {
    case $1 in
    r) export Color="\e[31m";;
    g) export Color="\e[32m";;
    b) export Color="\e[34m";;
    y) export Color="\e[33m";;
    z) export Color="\e[35m";;
    l) export Color="\e[36m";;
    esac
      [[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
        echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
      }
    }
}


function settings_variable() {
if [[ -n "${INPUTS_REPO_BRANCH}" ]]; then
  ymlpath="build/${FOLDER_NAME}/settings.ini"
  if [[ ! -d "build/${FOLDER_NAME}/relevance" ]]; then
    mkdir -p build/${FOLDER_NAME}/relevance
  else
    rm -rf build/${FOLDER_NAME}/relevance/*.ini
  fi
  ymlsettings="build/${FOLDER_NAME}/relevance/settings.ini"
  echo "ymlsettings=${ymlsettings}" >> ${GITHUB_ENV}
  cp -Rf "${ymlpath}" "${ymlsettings}"
  if [[ "${INPUTS_INFORMATION_NOTICE}" == '关闭' ]]; then
    INFORMATION_NOTICE2="INFORMATION_NOTICE\\=\\\"false\\\""
  elif [[ "${INPUTS_INFORMATION_NOTICE}" == 'Telegram' ]]; then
    INFORMATION_NOTICE2="INFORMATION_NOTICE\\=\\\"TG\\\""
  elif [[ "${INPUTS_INFORMATION_NOTICE}" == 'pushplus' ]]; then
    INFORMATION_NOTICE2="INFORMATION_NOTICE\\=\\\"PUSH\\\""
  fi
        

  if [[ `echo "${INPUTS_CPU_SELECTION}" |grep -Eoc 'E5'` -eq '1' ]] || [[ `echo "${INPUTS_CPU_SELECTION}" |grep -Eoc 'e5'` -eq '1' ]]; then
    export INPUTS_CPU_SELECTION="E5"
  elif [[ `echo "${INPUTS_CPU_SELECTION}" |grep -Eoc '8370'` -eq '1' ]]; then
    export INPUTS_CPU_SELECTION="8370"
  elif [[ `echo "${INPUTS_CPU_SELECTION}" |grep -Eoc '8272'` -eq '1' ]]; then
    export INPUTS_CPU_SELECTION="8272"
  elif [[ `echo "${INPUTS_CPU_SELECTION}" |grep -Eoc '8171'` -eq '1' ]]; then
    export INPUTS_CPU_SELECTION="8171"
  else
    export INPUTS_CPU_SELECTION="E5"
  fi
  REPO_BRANCH1="$(grep "REPO_BRANCH=" "${ymlpath}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  CONFIG_FILE1="$(grep "CONFIG_FILE=" "${ymlpath}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  UPLOAD_FIRMWARE1="$(grep "UPLOAD_FIRMWARE=" "${ymlpath}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  UPLOAD_RELEASE1="$(grep "UPLOAD_RELEASE=" "${ymlpath}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  CACHEWRTBUILD_SWITCH1="$(grep "CACHEWRTBUILD_SWITCH=" "${ymlpath}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  UPDATE_FIRMWARE_ONLINE1="$(grep "UPDATE_FIRMWARE_ONLINE=" "${ymlpath}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  COLLECTED_PACKAGES1="$(grep "COLLECTED_PACKAGES=" "${ymlpath}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  CPU_SELECTION1="$(grep "CPU_SELECTION=" "${ymlpath}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  INFORMATION_NOTICE1="$(grep "INFORMATION_NOTICE=" "${ymlpath}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  
  REPO_BRANCH2="REPO_BRANCH\\=\\\"${INPUTS_REPO_BRANCH}\\\""
  CONFIG_FILE2="CONFIG_FILE\\=\\\"${INPUTS_CONFIG_FILE}\\\""
  UPLOAD_FIRMWARE2="UPLOAD_FIRMWARE\\=\\\"${INPUTS_UPLOAD_FIRMWARE}\\\""
  UPLOAD_RELEASE2="UPLOAD_RELEASE\\=\\\"${INPUTS_UPLOAD_RELEASE}\\\""
  CACHEWRTBUILD_SWITCH2="CACHEWRTBUILD_SWITCH\\=\\\"${INPUTS_CACHEWRTBUILD_SWITCH}\\\""
  UPDATE_FIRMWARE_ONLINE2="UPDATE_FIRMWARE_ONLINE\\=\\\"${INPUTS_UPDATE_FIRMWARE_ONLINE}\\\""
  COLLECTED_PACKAGES2="COLLECTED_PACKAGES\\=\\\"${INPUTS_COLLECTED_PACKAGES}\\\""
  CPU_SELECTION2="CPU_SELECTION\\=\\\"${INPUTS_CPU_SELECTION}\\\""

  sed -i "s?${REPO_BRANCH1}?${REPO_BRANCH2}?g" "${ymlsettings}"
  sed -i "s?${CONFIG_FILE1}?${CONFIG_FILE2}?g" "${ymlsettings}"
  sed -i "s?${UPLOAD_FIRMWARE1}?${UPLOAD_FIRMWARE2}?g" "${ymlsettings}"
  sed -i "s?${UPLOAD_RELEASE1}?${UPLOAD_RELEASE2}?g" "${ymlsettings}"
  sed -i "s?${CACHEWRTBUILD_SWITCH1}?${CACHEWRTBUILD_SWITCH2}?g" "${ymlsettings}"
  sed -i "s?${UPDATE_FIRMWARE_ONLINE1}?${UPDATE_FIRMWARE_ONLINE2}?g" "${ymlsettings}"
  sed -i "s?${COLLECTED_PACKAGES1}?${COLLECTED_PACKAGES2}?g" "${ymlsettings}"
  sed -i "s?${CPU_SELECTION1}?${CPU_SELECTION2}?g" "${ymlsettings}"
  sed -i "s?${INFORMATION_NOTICE1}?${INFORMATION_NOTICE2}?g" "${ymlsettings}"
  export t1=`date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s`
  echo "t1=${t1}" >> ${GITHUB_ENV}
  mv "${ymlsettings}" build/${FOLDER_NAME}/relevance/${t1}.ini
else
  export t1="1234567"
  echo "t1=${t1}" >> ${GITHUB_ENV}
fi
}

function Diy_variable() {

export DIY_PART_SH="diy-part.sh"

if [[ -n "${BENDI_VERSION}" ]]; then
  source "${GITHUB_WORKSPACE}/operates/${FOLDER_NAME}/settings.ini"
elif [[ "${Manually_Run}" == "1" ]]; then
  source "${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/settings.ini"
  echo "t1=1234567" >> ${GITHUB_ENV}
else
  if [[ -z "${t1}" ]]; then
    t1="$(grep "CPU_PASSWORD=" "${GITHUB_WORKSPACE}/.github/workflows/compile.yml" |grep -v '^#' |grep -Eo '[0-9]+')"
    echo "${t1}"
  fi
  if [[ "${t1}" == "1234567" ]]; then
    source "${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/settings.ini"
    echo "t1=1234567" >> ${GITHUB_ENV}
  elif [[ -f "${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/relevance/${t1}.ini" ]]; then
    source "${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/relevance/${t1}.ini"
    echo "t1=${t1}" >> ${GITHUB_ENV}
    echo "运行${t1}.ini"
  else
    source "${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/settings.ini"
  fi
fi

case "${SOURCE_CODE}" in
COOLSNOWWOLF)
  if [[ "${REPO_BRANCH}" == "master" ]]; then
    export REPO_URL="https://github.com/coolsnowwolf/lede"
    export SOURCE="Lede"
    export LUCI_EDITION="18.06"
    export SOURCE_OWNER="Lede's"
    export PACKAGE_BRANCH="master"
    export DIY_WORK="${FOLDER_NAME}MASTER"
    echo "GL_BRANCH=lede" >> ${GITHUB_ENV}
  elif [[ "${REPO_BRANCH}" == "gl-ax1800" ]]; then
    export REPO_URL="https://github.com/coolsnowwolf/openwrt-gl-ax1800"
    export SOURCE="Lede"
    export LUCI_EDITION="gl-ax1800"
    export SOURCE_OWNER="Lede's"
    export PACKAGE_BRANCH="master"
    export REPO_BRANCH="master"
    export DIY_WORK="${FOLDER_NAME}ax1800"
    echo "GL_BRANCH=lede_ax1800" >> ${GITHUB_ENV}
  fi
;;
LIENOL)
  export REPO_URL="https://github.com/Lienol/openwrt"
  export SOURCE="Lienol"
  export SOURCE_OWNER="Lienol's"
  if [[ "${REPO_BRANCH}" == "master" ]]; then
    export PACKAGE_BRANCH="21.02"
    export LUCI_EDITION="master"
    export DIY_WORK="${FOLDER_NAME}MASTER"
  elif [[ "${REPO_BRANCH}" == "21.02" ]]; then
    export PACKAGE_BRANCH="21.02"
    export LUCI_EDITION="21.02"
    export DIY_WORK="${FOLDER_NAME}2102"
  elif [[ "${REPO_BRANCH}" == "22.03" ]]; then
    export PACKAGE_BRANCH="21.02"
    export LUCI_EDITION="22.03"
    export DIY_WORK="${FOLDER_NAME}2102"
  elif [[ "${REPO_BRANCH}" == "19.07-test" ]]; then
    export PACKAGE_BRANCH="19.07"
    export LUCI_EDITION="19.07-test"
    export DIY_WORK="${FOLDER_NAME}CANNO"
  elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
    export PACKAGE_BRANCH="19.07"
    export LUCI_EDITION="19.07"
    export DIY_WORK="${FOLDER_NAME}1907"
  fi
;;
IMMORTALWRT)
  export REPO_URL="https://github.com/immortalwrt/immortalwrt"
  export SOURCE="Immortalwrt"
  export SOURCE_OWNER="ctcgfw's"
  if [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
    export PACKAGE_BRANCH="openwrt-21.02"
    export LUCI_EDITION="21.02"
    export DIY_WORK="${FOLDER_NAME}2102"
  elif [[ "${REPO_BRANCH}" == "master" ]]; then
    export PACKAGE_BRANCH="openwrt-21.02"
    export LUCI_EDITION="master"
    export DIY_WORK="${FOLDER_NAME}MASTER"
  elif [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
    export PACKAGE_BRANCH="openwrt-18.06"
    export LUCI_EDITION="18.06"
    export DIY_WORK="${FOLDER_NAME}1806"
  elif [[ "${REPO_BRANCH}" == "openwrt-18.06-k5.4" ]]; then
    export PACKAGE_BRANCH="openwrt-18.06"
    export LUCI_EDITION="18.06.K5.4"
    export DIY_WORK="${FOLDER_NAME}K54"
  fi
;;
XWRT)
  export REPO_URL="https://github.com/x-wrt/x-wrt"
  export SOURCE="Xwrt"
  export SOURCE_OWNER="ptpt52"
  export PACKAGE_BRANCH="official-all"
  export LUCI_EDITION="${REPO_BRANCH}"
  if [[ "${REPO_BRANCH}" == "21.10" ]]; then
    export DIY_WORK="${FOLDER_NAME}2110"
  elif [[ "${REPO_BRANCH}" == "22.03" ]]; then
    export DIY_WORK="${FOLDER_NAME}2203"
  else
    export DIY_WORK="${FOLDER_NAME}${REPO_BRANCH}"
  fi
;;
OFFICIAL)
  export REPO_URL="https://github.com/openwrt/openwrt"
  export SOURCE="Official"
  export SOURCE_OWNER="openwrt"
  export PACKAGE_BRANCH="official-all"
  if [[ "${REPO_BRANCH}" == "master" ]]; then
    export LUCI_EDITION="master"
    export DIY_WORK="${FOLDER_NAME}MASTER"
  elif [[ "${REPO_BRANCH}" == "openwrt-19.07" ]]; then
    export LUCI_EDITION="19.07"
    export DIY_WORK="${FOLDER_NAME}1907"
  elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
    export LUCI_EDITION="21.02"
    export DIY_WORK="${FOLDER_NAME}2102"
  elif [[ "${REPO_BRANCH}" == "openwrt-22.03" ]]; then
    export LUCI_EDITION="22.03"
    export DIY_WORK="${FOLDER_NAME}2203"
  fi
;;
*)
  TIME r "不支持${SOURCE_CODE}此源码，当前只支持COOLSNOWWOLF、LIENOL、IMMORTALWRT、XWRT、OFFICIAL"
  exit 1
;;
esac

echo "HOME_PATH=${GITHUB_WORKSPACE}/openwrt" >> ${GITHUB_ENV}
echo "DIY_PART_SH=${DIY_PART_SH}" >> ${GITHUB_ENV}
echo "DIY_WORK=${DIY_WORK}" >> ${GITHUB_ENV}
echo "PACKAGE_BRANCH=${PACKAGE_BRANCH}" >> ${GITHUB_ENV}
echo "SOURCE_CODE=${SOURCE_CODE}" >> ${GITHUB_ENV}
echo "REPO_URL=${REPO_URL}" >> ${GITHUB_ENV}
echo "REPO_BRANCH=${REPO_BRANCH}" >> ${GITHUB_ENV}
echo "CONFIG_FILE=seed/${CONFIG_FILE}" >> ${GITHUB_ENV}
echo "DIY_PART_SH=${DIY_PART_SH}" >> ${GITHUB_ENV}
echo "UPLOAD_FIRMWARE=${UPLOAD_FIRMWARE}" >> ${GITHUB_ENV}
echo "UPLOAD_WETRANSFER=${UPLOAD_WETRANSFER}" >> ${GITHUB_ENV}
echo "UPLOAD_RELEASE=${UPLOAD_RELEASE}" >> ${GITHUB_ENV}
echo "INFORMATION_NOTICE=${INFORMATION_NOTICE}" >> ${GITHUB_ENV}
echo "CACHEWRTBUILD_SWITCH=${CACHEWRTBUILD_SWITCH}" >> ${GITHUB_ENV}
echo "UPDATE_FIRMWARE_ONLINE=${UPDATE_FIRMWARE_ONLINE}" >> ${GITHUB_ENV}
echo "COMPILATION_INFORMATION=${COMPILATION_INFORMATION}" >> ${GITHUB_ENV}
echo "COLLECTED_PACKAGES=${COLLECTED_PACKAGES}" >> ${GITHUB_ENV}
echo "WAREHOUSE_MAN=${GIT_REPOSITORY##*/}" >> ${GITHUB_ENV}
echo "SOURCE=${SOURCE}" >> ${GITHUB_ENV}
echo "LUCI_EDITION=${LUCI_EDITION}" >> ${GITHUB_ENV}
if [[ -n "${BENDI_VERSION}" ]]; then
  echo "SOURCE_OWNER=\"${SOURCE_OWNER}\"" >> ${GITHUB_ENV}
else
  echo "SOURCE_OWNER=${SOURCE_OWNER}" >> ${GITHUB_ENV}
fi
echo "CPU_SELECTION=${CPU_SELECTION}" >> ${GITHUB_ENV}
echo "RETAIN_DAYS=${RETAIN_DAYS}" >> ${GITHUB_ENV}
echo "KEEP_LATEST=${KEEP_LATEST}" >> ${GITHUB_ENV}

echo "BUILD_PATH=${GITHUB_WORKSPACE}/openwrt/build/${FOLDER_NAME}" >> ${GITHUB_ENV}
echo "FILES_PATH=${GITHUB_WORKSPACE}/openwrt/package/base-files/files" >> ${GITHUB_ENV}
echo "REPAIR_PATH=${GITHUB_WORKSPACE}/openwrt/package/base-files/files/etc/openwrt_release" >> ${GITHUB_ENV}
echo "DELETE=${GITHUB_WORKSPACE}/openwrt/package/base-files/files/etc/deletefile" >> ${GITHUB_ENV}
echo "DEFAULT_PATH=${GITHUB_WORKSPACE}/openwrt/package/base-files/files/etc/default-setting" >> ${GITHUB_ENV}
echo "KEEPD_PATH=${GITHUB_WORKSPACE}/openwrt/package/base-files/files/lib/upgrade/keep.d/base-files-essential" >> ${GITHUB_ENV}
echo "GENE_PATH=${GITHUB_WORKSPACE}/openwrt/package/base-files/files/bin/config_generate" >> ${GITHUB_ENV}
echo "CLEAR_PATH=${GITHUB_WORKSPACE}/openwrt/Clear" >> ${GITHUB_ENV}
echo "Upgrade_Date=`date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s`" >> ${GITHUB_ENV}
echo "Firmware_Date=$(date +%Y-%m%d-%H%M)" >> ${GITHUB_ENV}
echo "Compte_Date=$(date +%Y年%m月%d号%H时%M分)" >> ${GITHUB_ENV}
echo "Tongzhi_Date=$(date +%Y年%m月%d日)" >> ${GITHUB_ENV}
echo "Gujian_Date=$(date +%m.%d)" >> ${GITHUB_ENV}
}


function Diy_settings() {
echo "正在执行：判断是否缺少[${CONFIG_FILE}、${DIY_PART_SH}]文件"
if [[ -n "${BENDI_VERSION}" ]]; then
  export GIT_BUILD=operates/${FOLDER_NAME}
else
  export GIT_BUILD=build/${FOLDER_NAME}
  export CONFIG_FILE=seed/${CONFIG_FILE}
fi

if [ -z "$(ls -A "${GITHUB_WORKSPACE}/${GIT_BUILD}/${CONFIG_FILE}" 2>/dev/null)" ]; then
  aa="$(echo "${CONFIG_FILE}" |cut -d '/' -f2)"
  TIME r "错误提示：编译脚本的[seed文件夹]缺少[${aa}]名称的配置文件,请在[${GIT_BUILD}/seed]文件夹内补齐"
  exit 1
else
  echo "${GIT_BUILD}/${CONFIG_FILE}文件存在"
fi
if [ -z "$(ls -A "${GITHUB_WORKSPACE}/${GIT_BUILD}/${DIY_PART_SH}" 2>/dev/null)" ]; then
  TIME r "错误提示：编译脚本缺少[${DIY_PART_SH}]名称的自定义设置文件,请在[${GIT_BUILD}]文件夹内补齐"
  exit 1
else
  echo "${GIT_BUILD}/${DIY_PART_SH}文件存在"
fi
}


function Diy_update() {
bash <(curl -fsSL https://raw.githubusercontent.com/281677160/common/main/custom/ubuntu.sh)
if [[ $? -ne 0 ]];then
  TIME r "依赖安装失败，请检测网络后再次尝试!"
  exit 1
else
  sudo sh -c 'echo openwrt > /etc/oprelyon'
  TIME b "全部依赖安装完毕"
fi
}

function Diy_checkout() {
cd ${GITHUB_WORKSPACE}/openwrt
case "${SOURCE_CODE}" in
OFFICIAL)
  if [[ "${REPO_BRANCH}" =~ (openwrt-19.07|openwrt-21.02|openwrt-22.03) ]]; then
    export LUCI_CHECKUT="$(git tag| awk 'END {print}')"
    git checkout ${LUCI_CHECKUT}
    git switch -c ${LUCI_CHECKUT}
    export LUCI_CHECKUT="$(echo ${LUCI_CHECKUT} |sed 's/v//')"
    echo "正在使用${LUCI_CHECKUT}版本源码进行编译"
    echo
  fi
;;
COOLSNOWWOLF)
  if [[ "${GL_BRANCH}" == "lede" ]]; then
    rm -rf ${HOME_PATH}/target/linux/ramips/patches-5.15
    svn co https://github.com/lede-project/source/trunk/target/linux/ramips/patches-5.15 ${HOME_PATH}/target/linux/ramips/patches-5.15 > /dev/null 2>&1
    for i in "mt7620" "mt7621" "mt76x8" "rt288x" "rt305x" "rt3883"; do \
        [[ ! -f "${HOME_PATH}/target/linux/ramips/$i/config-5.15" ]] &&  \
        curl -fsSL https://raw.githubusercontent.com/lede-project/source/master/target/linux/ramips/$i/config-5.15 > ${HOME_PATH}/target/linux/ramips/$i/config-5.15; \
    done
  fi
;;
esac

./scripts/feeds clean
if [[ -n "${BENDI_VERSION}" ]]; then
  ./scripts/feeds update -a
else
  ./scripts/feeds update -a > /dev/null 2>&1
fi
}

function Diy_Notice() {
TIME r ""
TIME y "第一次用我仓库的，请不要拉取任何插件，先SSH进入固件配置那里看过我脚本实在是没有你要的插件才再拉取"
TIME y "拉取插件应该单独拉取某一个你需要的插件，别一下子就拉取别人一个插件包，这样容易增加编译失败概率"
if [[ "${UPDATE_FIRMWARE_ONLINE}" == "true" ]]; then
  TIME r "SSH连接固件输入命令'openwrt'可进行修改后台IP、清空密码、还原出厂设置和在线更新固件操作"
else
  TIME r "SSH连接固件输入命令'openwrt'可进行修改后台IP，清空密码和还原出厂设置操作"
fi
TIME r ""
TIME g "CPU性能：8370C > 8272CL > 8171M > E5系列"
TIME r ""
}

function build_openwrt() {
cd ${GITHUB_WORKSPACE}
if [[ `echo "${CPU_SELECTION}" |grep -Eoc 'E5'` -eq '1' ]] || [[ `echo "${CPU_SELECTION}" |grep -Eoc 'e5'` -eq '1' ]]; then
  export CPU_SELECTIO="E5"
  export kaisbianyixx="弃用E5-编译"
elif [[ `echo "${CPU_SELECTION}" |grep -Eoc '8370'` -eq '1' ]]; then
  export CPU_SELECTIO="8370"
  export kaisbianyixx="选择8370-编译"
elif [[ `echo "${CPU_SELECTION}" |grep -Eoc '8272'` -eq '1' ]]; then
  export CPU_SELECTIO="8272"
  export kaisbianyixx="选择8272-编译"
elif [[ `echo "${CPU_SELECTION}" |grep -Eoc '8171'` -eq '1' ]]; then
  export CPU_SELECTIO="8171"
  export kaisbianyixx="选择8171-编译"
else
  export kaisbianyixx="编译"
fi
git clone -b main https://github.com/${GIT_REPOSITORY}.git ${FOLDER_NAME}
if [[ ! -d "${FOLDER_NAME}/build/${FOLDER_NAME}/relevance" ]]; then
  mkdir -p "${FOLDER_NAME}/build/${FOLDER_NAME}/relevance"
fi
export YML_PATH="${FOLDER_NAME}/.github/workflows/compile.yml"
cp -Rf ${GITHUB_WORKSPACE}/.github/workflows/compile.yml ${YML_PATH}
export TARGET1="$(grep 'target: \[' "${YML_PATH}" |sed 's/^[ ]*//g' |grep -v '^#' |sed 's/\[/\\&/' |sed 's/\]/\\&/')"
export TARGET2="target: \\[${FOLDER_NAME}\\]"
export PATHS1="$(grep -Eo "\- '.*'" "${YML_PATH}" |sed 's/^[ ]*//g' |grep -v "^#" |awk 'NR==1')"
export PATHS2="- 'build/${FOLDER_NAME}/relevance/start'"
export cpu1="CPU_OPTIMIZATION=.*"
export cpu2="CPU_OPTIMIZATION\\=\\\"${CPU_SELECTIO}\\\""
export CPU_PASS1="CPU_PASSWORD=.*"
if [[ "${t1}" == "1234567" ]]; then
  export CPU_PASS2="CPU_PASSWORD\\=\\\"1234567\\\""
else
  if [[ -f "${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/relevance/${t1}.ini" ]]; then
    rm -fr ${FOLDER_NAME}/build/${FOLDER_NAME}/relevance/*.ini
    mv "${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/relevance/${t1}.ini" ${FOLDER_NAME}/build/${FOLDER_NAME}/relevance/${t1}.ini
  fi
  export CPU_PASS2="CPU_PASSWORD\\=\\\"${t1}\\\""
  echo "$CPU_PASS2"
fi

if [[ -n "${CPU_PASS1}" ]] && [[ -n "${CPU_PASS2}" ]]; then
  sed -i "s?${CPU_PASS1}?${CPU_PASS2}?g" "${YML_PATH}"
else
  echo "获取变量失败,请勿胡乱修改compile.yml文件"
  exit 1
fi

if [[ -n "${PATHS1}" ]] && [[ -n "${TARGET1}" ]]; then
  sed -i "s?${PATHS1}?${PATHS2}?g" "${YML_PATH}"
  sed -i "s?${TARGET1}?${TARGET2}?g" "${YML_PATH}"
else
  echo "获取变量失败,请勿胡乱修改compile.yml文件"
  exit 1
fi
if [[ -n ${cpu1} ]] && [[ -n ${cpu2} ]]; then
  sed -i "s?${cpu1}?${cpu2}?g" "${YML_PATH}"
else
  echo "获取变量失败,请勿胡乱修改定时启动编译时的数值设置"
  exit 1
fi
cp -Rf ${HOME_PATH}/build_logo/config.txt ${FOLDER_NAME}/build/${FOLDER_NAME}/${CONFIG_FILE}

restartsj="$(cat "${FOLDER_NAME}/build/${FOLDER_NAME}/relevance/start" |awk '$0=NR" "$0' |awk 'END {print}' |awk '{print $(1)}')"
if [[ "${restartsj}" -lt "3" ]]; then
  echo "${SOURCE}-${REPO_BRANCH}-${CONFIG_FILE}-$(date +%Y年%m月%d号%H时%M分%S秒)" >> ${FOLDER_NAME}/build/${FOLDER_NAME}/relevance/start
else
  echo "${SOURCE}-${REPO_BRANCH}-${CONFIG_FILE}-$(date +%Y年%m月%d号%H时%M分%S秒)" > ${FOLDER_NAME}/build/${FOLDER_NAME}/relevance/start
fi

cd ${FOLDER_NAME}
git add .
git commit -m "${kaisbianyixx}-${FOLDER_NAME}-${LUCI_EDITION}-${TARGET_PROFILE}固件"
git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:main
}

function Diy_wenjian1() {
cd ${HOME_PATH}
# 拉取源码之后增加应用文件
if [[ -d "${HOME_PATH}/extra" ]]; then
  apptions="$(find "${HOME_PATH}/extra" -type d -name "applications"  |grep 'luci')"
else
  apptions="$(find "${HOME_PATH}/feeds" -type d -name "applications"  |grep 'luci')"
fi
if [[ `find "${apptions}" -type d -name "zh_Hans" |grep -c "zh_Hans"` -gt '15' ]]; then
  applica="1"
  echo "applica=1" >> ${GITHUB_ENV}
else
  applica="2"
  echo "applica=2" >> ${GITHUB_ENV}
fi

settingss="$(find "${HOME_PATH}/package" -type d -name "default-settings")"
if [[ ! -d "${settingss}" ]] && [[ "${applica}" == "1" ]]; then
  svn export https://github.com/281677160/common/trunk/OFFICIAL/default-settings ${HOME_PATH}/package/default-settings > /dev/null 2>&1
  [[ ! -d "${HOME_PATH}/feeds/luci/libs/luci-lib-base" ]] && sed -i "s/+luci-lib-base //g" ${HOME_PATH}/package/default-settings/Makefile
elif [[ ! -d "${settingss}" ]] && [[ "${applica}" == "2" ]]; then
  svn export https://github.com/281677160/common/trunk/COOLSNOWWOLF/default-settings ${HOME_PATH}/package/default-settings > /dev/null 2>&1
fi

find . -type d -name 'luci-theme-argon' -o -name 'luci-theme-argonv3' -o -name 'luci-theme-argon-mod' -o -name 'luci-app-argon-config' | xargs -i rm -rf {}

if [[ "${applica}" == "1" ]]; then
  git clone -b master https://github.com/281677160/luci-theme-argon "${HOME_PATH}/feeds/luci/themes/luci-theme-argon"
  git clone -b argon-config https://github.com/281677160/luci-theme-argon "${HOME_PATH}/feeds/luci/applications/luci-app-argon-config"
elif [[ "${applica}" == "2" ]]; then
  if [[ "${GL_BRANCH}" == "lede_ax1800" ]]; then
    git clone -b argonv3 https://github.com/281677160/luci-theme-argon "${HOME_PATH}/extra/luci/themes/luci-theme-argonv3"
    git clone -b 18.06 https://github.com/281677160/luci-theme-argon "${HOME_PATH}//extra/luci/themes/luci-theme-argon"
    git clone -b argon-config https://github.com/281677160/luci-theme-argon "${HOME_PATH}/extra/luci/applications/luci-app-argon-config"
  else
    git clone -b argonv3 https://github.com/281677160/luci-theme-argon "${HOME_PATH}/feeds/luci/themes/luci-theme-argonv3"
    git clone -b 18.06 https://github.com/281677160/luci-theme-argon "${HOME_PATH}/feeds/luci/themes/luci-theme-argon"
    git clone -b argon-config https://github.com/281677160/luci-theme-argon "${HOME_PATH}/feeds/luci/applications/luci-app-argon-config"
  fi
fi

rm -rf ${HOME_PATH}/feeds/packages/lang/golang
svn co https://github.com/openwrt/packages/branches/openwrt-22.03/lang/golang ${HOME_PATH}/feeds/packages/lang/golang > /dev/null 2>&1

if [[ `grep -c 'attendedsysupgrade' "${HOME_PATH}/feeds/luci/collections/luci/Makefile"` -eq '1' ]]; then
   sed -i '/attendedsysupgrade/d' "${HOME_PATH}/feeds/luci/collections/luci/Makefile"
elif [[ -d "${HOME_PATH}/feeds/luci/collections/luci-light" ]] && [[ `grep -c 'attendedsysupgrade' "${HOME_PATH}/feeds/luci/collections/luci-light/Makefile"` -eq '1' ]]; then
   sed -i '/attendedsysupgrade/d' "${HOME_PATH}/feeds/luci/collections/luci-light/Makefile"
fi

if [[ ! -d "${HOME_PATH}/feeds/packages/devel/packr" ]]; then
  svn export https://github.com/coolsnowwolf/packages/trunk/devel/packr ${HOME_PATH}/feeds/packages/devel/packr > /dev/null 2>&1
fi

if [[ ! -d "${HOME_PATH}/feeds/packages/utils/parted" ]]; then
  svn export https://github.com/coolsnowwolf/packages/trunk/utils/parted ${HOME_PATH}/feeds/packages/utils/parted > /dev/null 2>&1
fi

if [[ ! -d "${HOME_PATH}/package/utils/bcm27xx-userland" ]]; then
  svn export https://github.com/openwrt/openwrt/trunk/package/utils/bcm27xx-userland ${HOME_PATH}/package/utils/bcm27xx-userland > /dev/null 2>&1
fi

if [[ -n "$(grep "libustream-wolfssl" ${HOME_PATH}/include/target.mk)" ]]; then
  sed -i 's?libustream-wolfssl?libustream-openssl?g' "${HOME_PATH}/include/target.mk"
elif [[ -z "$(grep "libustream-openssl" ${HOME_PATH}/include/target.mk)" ]]; then
  sed -i 's?DEFAULT_PACKAGES:=?DEFAULT_PACKAGES:=libustream-openssl ?g' "${HOME_PATH}/include/target.mk"
fi

if [[ -n "$(grep "dnsmasq" ${HOME_PATH}/include/target.mk)" ]] && [[ -z "$(grep "dnsmasq-full" ${HOME_PATH}/include/target.mk)" ]]; then
  sed -i 's?dnsmasq?dnsmasq-full luci luci-newapi kmod-nf-nathelper kmod-nf-nathelper-extra luci-compat luci-lib-base luci-lib-fs luci-lib-ipkg?g' "${HOME_PATH}/include/target.mk"
fi

if [[ -z "$(grep "ca-bundle" ${HOME_PATH}/include/target.mk)" ]]; then
  sed -i 's?DEFAULT_PACKAGES:=?DEFAULT_PACKAGES:=ca-bundle ?g' "${HOME_PATH}/include/target.mk"
fi

if [[ -z "$(grep "default-settings" ${HOME_PATH}/include/target.mk)" ]]; then
  sed -i 's?DEFAULT_PACKAGES:=?DEFAULT_PACKAGES:=default-settings ?g' "${HOME_PATH}/include/target.mk"
fi

if [[ -z "$(grep "luci-lib-ipkg" ${HOME_PATH}/include/target.mk)" ]]; then
  sed -i 's?DEFAULT_PACKAGES:=?DEFAULT_PACKAGES:=luci luci-newapi kmod-nf-nathelper kmod-nf-nathelper-extra luci-compat luci-lib-base luci-lib-fs luci-lib-ipkg ?g' "${HOME_PATH}/include/target.mk"
fi
}

function Diy_wenjian2() {
rm -rf "${DEFAULT_PATH}" && cp ${HOME_PATH}/build/common/custom/default-setting "${DEFAULT_PATH}"
sudo chmod +x "${DEFAULT_PATH}"
sed -i "s?112233?${SOURCE} - ${LUCI_EDITION}?g" "${DEFAULT_PATH}" > /dev/null 2>&1
sed -i 's/root:.*/root::0:0:99999:7:::/g' ${FILES_PATH}/etc/shadow
if [[ `grep -Eoc "admin:.*" ${FILES_PATH}/etc/shadow` -eq '1' ]]; then
  sed -i 's/admin:.*/admin::0:0:99999:7:::/g' ${FILES_PATH}/etc/shadow
fi

rm -rf "${FILES_PATH}/etc/init.d/Postapplication"
cp ${HOME_PATH}/build/common/custom/Postapplication "${FILES_PATH}/etc/init.d/Postapplication"
sudo chmod +x "${FILES_PATH}/etc/init.d/Postapplication"

rm -rf "${FILES_PATH}/etc/networkdetection"
cp ${HOME_PATH}/build/common/custom/networkdetection "${FILES_PATH}/etc/networkdetection"
sudo chmod +x "${FILES_PATH}/etc/networkdetection"

[[ ! -d "${FILES_PATH}/usr/bin" ]] && mkdir -p ${FILES_PATH}/usr/bin
cp ${HOME_PATH}/build/common/custom/openwrt.sh "${FILES_PATH}/usr/bin/openwrt"
sudo chmod +x "${FILES_PATH}/usr/bin/openwrt"

rm -rf "${DELETE}"
touch "${DELETE}"
sudo chmod +x "${DELETE}"

sed -i "s?FEATURES+=.*?FEATURES+=targz?g" "${HOME_PATH}/target/linux/armvirt/Makefile"
sed -i '/DISTRIB_SOURCECODE/d' "${REPAIR_PATH}"
echo -e "\nDISTRIB_SOURCECODE='${SOURCE}_${LUCI_EDITION}'" >> "${REPAIR_PATH}" && sed -i '/^\s*$/d' "${REPAIR_PATH}"


# 给固件保留配置更新固件的保留项目
sed -i '/AdGuardHome/d' "${KEEPD_PATH}"
sed -i '/background/d' "${KEEPD_PATH}"
cat >>"${KEEPD_PATH}" <<-EOF
/etc/config/AdGuardHome.yaml
/www/luci-static/argon/background/
EOF
}


function Diy_COOLSNOWWOLF() {
cd ${HOME_PATH}
if [[ "${COLLECTED_PACKAGES}" == "true" ]]; then
  # 删除重复插件（LEDE）
  for X in "${HOME_PATH}/feeds" "${HOME_PATH}/package"; do
    find ${X} -type d -name 'luci-theme-argon-mod' -o -name 'mentohust' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-wrtbwmon' -o -name 'wrtbwmon' -o -name 'luci-app-eqos' | xargs -i rm -rf {}
    find ${X} -type d -name 'adguardhome' -o -name 'luci-app-adguardhome' -o -name 'luci-app-wol' | xargs -i rm -rf {}
    find ${X} -type d -name 'v2ray-geodata' -o -name 'mosdns' -o -name 'luci-app-mosdns' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-smartdns' -o -name 'smartdns' -o -name 'luci-app-gost' -o -name 'gost' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-msd_lite' -o -name 'msd_lite' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-theme-design' -o -name 'luci-app-design-config' | xargs -i rm -rf {}
  done
fi

case "${GL_BRANCH}" in
lede_ax1800)
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/common/main/LIENOL/19.07/package/kernel/linux/modules/netsupport.sh)"
;;
esac
}


function Diy_LIENOL() {
cd ${HOME_PATH}
if [[ "${COLLECTED_PACKAGES}" == "true" ]]; then
  # 删除重复插件（Lienol）
  for X in "${HOME_PATH}/feeds" "${HOME_PATH}/package"; do
    find ${X} -type d -name 'adguardhome' -o -name 'luci-app-adguardhome' -o -name 'luci-app-wol' -o -name 'luci-app-dockerman' -o -name 'luci-app-frpc' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-wrtbwmon' -o -name 'wrtbwmon' -o -name 'luci-app-eqos'| xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-smartdns' -o -name 'smartdns' -o -name 'luci-app-gost' -o -name 'gost' | xargs -i rm -rf {}
    find ${X} -type d -name 'v2ray-geodata' -o -name 'mosdns' -o -name 'luci-app-mosdns' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-msd_lite' -o -name 'msd_lite' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-theme-design' -o -name 'luci-app-design-config' | xargs -i rm -rf {}
  done
fi

case "${REPO_BRANCH}" in
master)
  rm -rf ${HOME_PATH}/feeds/other/lean/autosamba
  svn export https://github.com/coolsnowwolf/lede/trunk/package/lean/autosamba ${HOME_PATH}/feeds/other/lean/autosamba > /dev/null 2>&1
  rm -rf ${HOME_PATH}/feeds/other/lean/automount
  svn export https://github.com/coolsnowwolf/lede/trunk/package/lean/automount ${HOME_PATH}/feeds/other/lean/automount > /dev/null 2>&1
;;
19.07|19.07-test)
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/common/main/LIENOL/19.07/package/kernel/linux/modules/netsupport.sh)"
  rm -rf ${HOME_PATH}/feeds/packages/libs/libcap && svn export https://github.com/281677160/common/trunk/LIENOL/19.07/feeds/packages/libs/libcap ${HOME_PATH}/feeds/packages/libs/libcap > /dev/null 2>&1
  rm -rf ${HOME_PATH}/package/libs/libpcap && svn export https://github.com/281677160/common/trunk/LIENOL/19.07/package/libs/libpcap ${HOME_PATH}/package/libs/libpcap > /dev/null 2>&1
;;
21.02)
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/common/main/LIENOL/19.07/package/kernel/linux/modules/netsupport.sh)"
;;
esac

rm -rf "${HOME_PATH}/feeds/other/lean/mt"
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/mt ${HOME_PATH}/feeds/other/lean/mt > /dev/null 2>&1
rm -rf "${HOME_PATH}/feeds/other/lean/pdnsd-alt"
svn co https://github.com/xiaorouji/openwrt-passwall/trunk/pdnsd-alt ${HOME_PATH}/feeds/other/lean/pdnsd-alt > /dev/null 2>&1
}


function Diy_IMMORTALWRT() {
cd ${HOME_PATH}
if [[ "${COLLECTED_PACKAGES}" == "true" ]]; then
  # 删除重复插件（天灵）
  for X in "${HOME_PATH}/feeds" "${HOME_PATH}/package"; do
    find ${X} -type d -name 'luci-app-cifs' -o -name 'luci-app-wrtbwmon' -o -name 'wrtbwmon' -o -name 'luci-app-wol' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-adguardhome' -o -name 'adguardhome' -o -name 'luci-theme-opentomato' | xargs -i rm -rf {}
    find ${X} -type d -name 'v2ray-geodata' -o -name 'mosdns' -o -name 'luci-app-mosdns' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-theme-design' -o -name 'luci-app-design-config' -o -name 'luci-app-eqos' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-gost' -o -name 'gost' | xargs -i rm -rf {}
  done
fi
}


function Diy_XWRT() {
cd ${HOME_PATH}
if [[ "${COLLECTED_PACKAGES}" == "true" ]]; then
  # 删除重复插件（X-WRT）
  for X in "${HOME_PATH}/feeds" "${HOME_PATH}/package"; do
    find ${X} -type d -name 'adguardhome' -o -name 'luci-app-adguardhome' -o -name 'luci-app-wol' | xargs -i rm -rf {}
    find ${X} -type d -name 'v2ray-geodata' -o -name 'mosdns' -o -name 'luci-app-mosdns' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-smartdns' -o -name 'smartdns' -o -name 'luci-app-gost' -o -name 'gost' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-msd_lite' -o -name 'msd_lite' -o -name 'luci-app-dockerman' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-theme-design' -o -name 'luci-app-design-config' | xargs -i rm -rf {}
  done
fi

if [[ `grep -c "net.netfilter.nf_conntrack_helper" ${HOME_PATH}/package/kernel/linux/files/sysctl-nf-conntrack.conf` -eq '0' ]]; then
  echo "net.netfilter.nf_conntrack_helper = 1" >> ${HOME_PATH}/package/kernel/linux/files/sysctl-nf-conntrack.conf
fi
}


function Diy_OFFICIAL() {
cd ${HOME_PATH}
if [[ "${COLLECTED_PACKAGES}" == "true" ]]; then
  # 删除重复插件（X-WRT）
  for X in "${HOME_PATH}/feeds" "${HOME_PATH}/package"; do
    find ${X} -type d -name 'adguardhome' -o -name 'luci-app-adguardhome' -o -name 'luci-app-wol' | xargs -i rm -rf {}
    find ${X} -type d -name 'v2ray-geodata' -o -name 'mosdns' -o -name 'luci-app-mosdns' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-smartdns' -o -name 'smartdns' -o -name 'luci-app-gost' -o -name 'gost' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-app-msd_lite' -o -name 'msd_lite' -o -name 'luci-app-dockerman' | xargs -i rm -rf {}
    find ${X} -type d -name 'luci-theme-design' -o -name 'luci-app-design-config' | xargs -i rm -rf {}
  done
fi

case "${REPO_BRANCH}" in
openwrt-21.02)
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/common/main/LIENOL/19.07/package/kernel/linux/modules/netsupport.sh)"
;;
openwrt-19.07)
  [[ -d "${HOME_PATH}/package/feeds/danshui/autosamba" ]] && sed -i "s?luci-app-samba4?luci-app-samba?g" ${HOME_PATH}/package/feeds/danshui/autosamba/Makefile
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/common/main/LIENOL/19.07/package/kernel/linux/modules/netsupport.sh)"
  rm -rf ${HOME_PATH}/feeds/packages/libs/libcap && svn export https://github.com/281677160/common/trunk/LIENOL/19.07/feeds/packages/libs/libcap ${HOME_PATH}/feeds/packages/libs/libcap > /dev/null 2>&1
  rm -rf ${HOME_PATH}/package/libs/libpcap && svn export https://github.com/281677160/common/trunk/LIENOL/19.07/package/libs/libpcap ${HOME_PATH}/package/libs/libpcap > /dev/null 2>&1
;;
openwrt-22.03)
  rm -rf ${HOME_PATH}/feeds/packages/net/apinger
  svn export https://github.com/openwrt/packages/trunk/net/apinger ${HOME_PATH}/feeds/packages/net/apinger
;;
esac

if [[ `grep -c "net.netfilter.nf_conntrack_helper" ${HOME_PATH}/package/kernel/linux/files/sysctl-nf-conntrack.conf` -eq '0' ]]; then
  echo "net.netfilter.nf_conntrack_helper = 1" >> ${HOME_PATH}/package/kernel/linux/files/sysctl-nf-conntrack.conf
fi
}

function Diy_distrib() {
# 获取ZZZ_PATH路径
[[ -f "${GITHUB_ENV}" ]] && source ${GITHUB_ENV}
cd ${HOME_PATH}
ZZZ_PATH1="$(find ./package -type f -name "*default-settings" |grep files |cut -d '/' -f2-)"
if [[ -n "${ZZZ_PATH1}" ]]; then
  ZZZ_PATH="${HOME_PATH}/${ZZZ_PATH1}"
  echo "ZZZ_PATH=${ZZZ_PATH}" >> ${GITHUB_ENV}
  sed -i '/exit 0/d' "${ZZZ_PATH}"
  ZZZ_PATHR="1"
else
  ZZZ_PATHR="0"
fi

ttydjso="$(find ./ -type f -name "luci-app-ttyd.json" |grep -v 'dir' |grep menu.d |cut -d '/' -f2-)"
if [[ -n "${ttydjso}" ]]; then
  ttydjson="${HOME_PATH}/${ttydjso}"
fi
if [[ -f "${ttydjson}" ]]; then
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/IMMORTALWRT/ttyd/luci-app-ttyd.json -o "${ttydjson}"
fi


[[ -d "${HOME_PATH}/doc" ]] && rm -rf ${HOME_PATH}/doc
[[ ! -d "${HOME_PATH}/LICENSES/doc" ]] && mkdir -p "${HOME_PATH}/LICENSES/doc"
if [[ -f "${HOME_PATH}/LICENSES/doc/default-settings" ]]; then
  cp -Rf ${HOME_PATH}/LICENSES/doc/default-settings "${ZZZ_PATH}"
else
  cp -Rf "${ZZZ_PATH}" ${HOME_PATH}/LICENSES/doc/default-settings
fi

if [[ -f "${HOME_PATH}/LICENSES/doc/config_generates" ]]; then
  cp -Rf ${HOME_PATH}/LICENSES/doc/config_generates "${GENE_PATH}"
else
  cp -Rf "${GENE_PATH}" ${HOME_PATH}/LICENSES/doc/config_generates
fi
sed -i "s?main.lang=.*?main.lang='zh_cn'?g" "${ZZZ_PATH}"
sed -i '/DISTRIB_DESCRIPTION/d' "${ZZZ_PATH}"
sed -i '/lib\/lua\/luci\/version.lua/d' "${ZZZ_PATH}"

if [[ "${applica}" == "2" ]]; then
cat >> "${ZZZ_PATH}" <<-EOF
sed -i '/DISTRIB_DESCRIPTION/d' /etc/openwrt_release
echo "DISTRIB_DESCRIPTION='OpenWrt '" >> /etc/openwrt_release
sed -i '/luciversion/d' /usr/lib/lua/luci/version.lua
echo "luciversion    = \"${LUCI_EDITION}\"" >> /usr/lib/lua/luci/version.lua
sed -i '/luciname/d' /usr/lib/lua/luci/version.lua
echo "luciname    = \"${SOURCE}\"" >> /usr/lib/lua/luci/version.lua
EOF
else
cat >> "${ZZZ_PATH}" <<-EOF
sed -i '/DISTRIB_DESCRIPTION/d' /etc/openwrt_release
echo "DISTRIB_DESCRIPTION='OpenWrt '" >> /etc/openwrt_release
sed -i '/luciversion/d' /usr/lib/lua/luci/version.lua
echo "luciversion    = \"${SOURCE}\"" >> /usr/lib/lua/luci/version.lua
sed -i '/luciname/d' /usr/lib/lua/luci/version.lua
echo "luciname    = \"- ${LUCI_EDITION}\"" >> /usr/lib/lua/luci/version.lua
EOF
fi
}


function Diy_chajianyuan() {
cd ${HOME_PATH}
case "${COLLECTED_PACKAGES}" in
true)
echo "正在执行：给feeds.conf.default增加插件源"
# 这里增加了源,要对应的删除/etc/opkg/distfeeds.conf插件源
sed -i '/danshui/d' "${HOME_PATH}/feeds.conf.default"
sed -i '/helloworld/d' "${HOME_PATH}/feeds.conf.default"
sed -i '/passwall/d' "${HOME_PATH}/feeds.conf.default"
find . -type d -name 'luci-app-ssr-plus' -o -name 'luci-app-passwall' -o -name 'luci-app-passwall2' | xargs -i rm -rf {}
find . -type d -name 'v2ray-core' -o -name 'v2ray-geodata' -o -name 'v2ray-plugin' -o -name 'xray-core' -o -name 'xray-plugin' | xargs -i rm -rf {}
find . -type d -name 'trojan' -o -name 'trojan-go' -o -name 'trojan-plus' -o -name 'redsocks2' -o -name 'sing-box' -o -name 'microsocks' | xargs -i rm -rf {}

if [[ "${SOURCE_CODE}" =~ (XWRT|OFFICIAL) ]]; then
  rm -rf ${HOME_PATH}/feeds/packages/net/shadowsocks-libev
  svn export https://github.com/coolsnowwolf/packages/trunk/net/shadowsocks-libev ${HOME_PATH}/feeds/packages/net/shadowsocks-libev > /dev/null 2>&1
  rm -rf ${HOME_PATH}/feeds/packages/net/kcptun
  svn export https://github.com/immortalwrt/packages/trunk/net/kcptun ${HOME_PATH}/feeds/packages/net/kcptun > /dev/null 2>&1
  rm -rf ${HOME_PATH}/feeds/packages/net/v2raya
  svn export https://github.com/fw876/helloworld/trunk/v2raya ${HOME_PATH}/feeds/packages/net/v2raya > /dev/null 2>&1
fi

cat >>"${HOME_PATH}/feeds.conf.default" <<-EOF
src-git danshui https://github.com/281677160/openwrt-package.git;${PACKAGE_BRANCH}
src-git helloworld https://github.com/fw876/helloworld.git
src-git passwall1 https://github.com/xiaorouji/openwrt-passwall.git;luci
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git;main
src-git passwall3 https://github.com/xiaorouji/openwrt-passwall.git;packages
EOF

sed -i '/^#/d' "${HOME_PATH}/feeds.conf.default"
sed -i '/^$/d' "${HOME_PATH}/feeds.conf.default"
;;
*)
  echo "没有启用作者收集的插件源包"
;;
esac
}


function Diy_files() {
cd ${HOME_PATH}
echo "正在执行：files大法，设置固件无烦恼"
if [[ -n "${BENDI_VERSION}" ]]; then
  cp -Rf ${GITHUB_WORKSPACE}/operates/${FOLDER_NAME}/* ${BUILD_PATH}/
  sudo chmod -R +x ${BUILD_PATH}
fi

if [ -n "$(ls -A "${BUILD_PATH}/patches" 2>/dev/null)" ]; then
  find "${BUILD_PATH}/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward --no-backup-if-mismatch"
fi

if [ -n "$(ls -A "${BUILD_PATH}/diy" 2>/dev/null)" ]; then
  cp -Rf ${BUILD_PATH}/diy/* ${HOME_PATH}
fi

if [ -n "$(ls -A "${BUILD_PATH}/files" 2>/dev/null)" ]; then
  cp -Rf ${BUILD_PATH}/files ${HOME_PATH}
fi
sudo chmod -R 775 ${HOME_PATH}/files
rm -rf ${HOME_PATH}/files/{LICENSE,.*README}
}

function Diy_zdypartsh() {
cat >"${HOME_PATH}/diy_pa_sh" <<-EOF
$(cat "$BUILD_PATH/$DIY_PART_SH" |grep '\egrep' |grep '\-rl')
EOF
sudo chmod -R 775 ${HOME_PATH}/diy_pa_sh
sed -i '/egrep ".*" -rl .\//d' $BUILD_PATH/$DIY_PART_SH
source $BUILD_PATH/$DIY_PART_SH
}

function Diy_Publicarea() {
cd ${HOME_PATH}
# diy-part.sh文件的延伸
rm -rf ${HOME_PATH}/CHONGTU && touch ${HOME_PATH}/CHONGTU
lan="/set network.\$1.netmask/a"
ipadd="$(grep "ipaddr:-" "${GENE_PATH}" |grep -v 'addr_offset' |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
netmas="$(grep "netmask:-" "${GENE_PATH}" |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
opname="$(grep "hostname=" "${GENE_PATH}" |grep -v '\$hostname' |cut -d "'" -f2)"
if [[ `grep -c 'set network.${1}6.device' "${GENE_PATH}"` -ge '1' ]]; then
  ifnamee="uci set network.ipv6.device='@lan'"
  set_add="uci add_list firewall.@zone[0].network='ipv6'"
else
  ifnamee="uci set network.ipv6.ifname='@lan'"
  set_add="uci set firewall.@zone[0].network='lan ipv6'"
fi

if [[ "${SOURCE_CODE}" == "OFFICIAL" ]] && [[ "${REPO_BRANCH}" == "openwrt-19.07" ]]; then
  devicee="uci set network.ipv6.device='@lan'"
fi

# AdGuardHome内核
if [[ "${COLLECTED_PACKAGES}" == "true" ]] && [[ "${AdGuardHome_Core}" == "1" ]]; then
  echo "AdGuardHome_Core=1" >> ${GITHUB_ENV}
elif [[ "${COLLECTED_PACKAGES}" == "true" ]] && [[ "${AdGuardHome_Core}" == "0" ]]; then
  [[ -f "${HOME_PATH}/files/usr/bin/AdGuardHome" ]] && rm -rf ${HOME_PATH}/files/usr/bin/AdGuardHome
  echo "AdGuardHome_Core=0" >> ${GITHUB_ENV}
elif [[ ! "${COLLECTED_PACKAGES}" == "true" ]]; then
  [[ -f "${HOME_PATH}/files/usr/bin/AdGuardHome" ]] && rm -rf ${HOME_PATH}/files/usr/bin/AdGuardHome
  echo "AdGuardHome_Core=0" >> ${GITHUB_ENV}
else
  [[ -f "${HOME_PATH}/files/usr/bin/AdGuardHome" ]] && rm -rf ${HOME_PATH}/files/usr/bin/AdGuardHome
  echo "AdGuardHome_Core=0" >> ${GITHUB_ENV}
fi

# openclash内核
if [[ "${COLLECTED_PACKAGES}" == "true" ]] && [[ "${OpenClash_Core}" == "1" ]]; then
  echo "OpenClash_Core=1" >> ${GITHUB_ENV}
elif [[ "${COLLECTED_PACKAGES}" == "true" ]] && [[ "${OpenClash_Core}" == "2" ]]; then
  echo "OpenClash_Core=2" >> ${GITHUB_ENV}
elif [[ "${COLLECTED_PACKAGES}" == "true" ]] && [[ "${OpenClash_Core}" == "0" ]]; then
  echo "OpenClash_Core=0" >> ${GITHUB_ENV}
elif [[ ! "${COLLECTED_PACKAGES}" == "true" ]] && [[ "${OpenClash_Core}" == "1" ]]; then
  [[ -d "${HOME_PATH}/files/etc/openclash" ]] && rm -rf ${HOME_PATH}/files/etc/openclash
  echo "OpenClash_Core=0" >> ${GITHUB_ENV}
  echo "TIME r \"因没开作者收集的插件包,没OpenClash插件,对openclash的分支选择无效\"" >> ${HOME_PATH}/CHONGTU
elif [[ ! "${COLLECTED_PACKAGES}" == "true" ]] && [[ "${OpenClash_Core}" == "2" ]]; then
  [[ -d "${HOME_PATH}/files/etc/openclash" ]] && rm -rf ${HOME_PATH}/files/etc/openclash
  echo "OpenClash_Core=0" >> ${GITHUB_ENV}
  echo "TIME r \"因没开作者收集的插件包,没OpenClash插件,对openclash的分支选择无效\"" >> ${HOME_PATH}/CHONGTU
elif [[ ! "${COLLECTED_PACKAGES}" == "true" ]]; then
  echo "OpenClash_Core=0" >> ${GITHUB_ENV}
else
  echo "OpenClash_Core=0" >> ${GITHUB_ENV}
  [[ -d "${HOME_PATH}/files/etc/openclash" ]] && rm -rf ${HOME_PATH}/files/etc/openclash
fi

if [[ "${COLLECTED_PACKAGES}" == "true" ]] && [[ "${OpenClash_branch}" == "0" ]]; then
  echo "OpenClash_branch=0" >> ${GITHUB_ENV}
  OpenClash_branch="0"
elif [[ "${COLLECTED_PACKAGES}" == "true" ]] && [[ -z "${OpenClash_branch}" ]]; then
  echo "OpenClash_branch=0" >> ${GITHUB_ENV}
  OpenClash_branch="0"
elif [[ ! "${COLLECTED_PACKAGES}" == "true" ]]; then
  echo "OpenClash_branch=0" >> ${GITHUB_ENV}
  OpenClash_branch="0"
elif [[ "${OpenClash_branch}" != "dev" && "${OpenClash_branch}" != "master" ]]; then
  if [[ "${SOURCE_CODE}" =~ (OFFICIAL|Xwrt) ]]; then
    OpenClash_branch="dev"
  else
    OpenClash_branch="master"
  fi
  if [[ `grep -c 'luci-app-openclash' "${HOME_PATH}/include/target.mk"` -eq '0' ]]; then
    sed -i "s?DEFAULT_PACKAGES:=?DEFAULT_PACKAGES:=luci-app-openclash ?g" "include/target.mk"
  fi
fi

uci_openclash="0"
sj_clash=`date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s`
if [[ -f "${HOME_PATH}/package/luci-app-openclash/sj_clash" ]]; then
  t1="$(cat ${HOME_PATH}/package/luci-app-openclash/sj_clash)"
else
  t1="1679053605"
fi

t2=`date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s`
SECONDS=$((t2-t1))
HOUR=$(( $SECONDS/3600 ))
if [[ "${HOUR}" -lt "12" ]] && [[ -f "${HOME_PATH}/files/etc/openclash/core/clash" ]]; then
  echo "OpenClash_Core=0" >> ${GITHUB_ENV}
  wuxuxiazai="1"
else
  echo "OpenClash_Core=${OpenClash_Core}" >> ${GITHUB_ENV}
  wuxuxiazai="0"
fi

if [[ -f "${HOME_PATH}/package/luci-app-openclash/sj_branch" ]]; then
  clash_branch="$(cat ${HOME_PATH}/package/luci-app-openclash/sj_branch)"
else
  clash_branch="${OpenClash_branch}"
fi

if [[ "${OpenClash_branch}" == "0" ]]; then
  find . -type d -name 'luci-app-openclash' | xargs -i rm -rf {}
  echo "OpenClash_Core=0" >> ${GITHUB_ENV}
  sed -i 's/ luci-app-openclash//' ${HOME_PATH}/include/target.mk
  echo "不需要OpenClash插件"
elif [[ "${wuxuxiazai}" == "1" ]] && [[ -f "${HOME_PATH}/package/luci-app-openclash/sj_branch" ]]; then
  echo ""
else
  find . -type d -name 'luci-app-openclash' | xargs -i rm -rf {}
  git clone -b "${OpenClash_branch}" --depth 1 https://github.com/vernesong/OpenClash ${HOME_PATH}/package/luci-app-openclash
  if [[ $? -ne 0 ]]; then
    echo
    echo "luci-app-openclash下载失败"
  else
    echo "${OpenClash_branch}" > "${HOME_PATH}/package/luci-app-openclash/sj_branch"
    echo "${sj_clash}" > "${HOME_PATH}/package/luci-app-openclash/sj_clash"
    uci_openclash="1"
    echo
    echo "正在使用"${OpenClash_branch}"分支的openclash"
  fi
fi

echo "OpenClash_branch=${OpenClash_branch}" >> ${GITHUB_ENV}

if [[ "${uci_openclash}" == "1" ]]; then
  uci_path="${HOME_PATH}/package/luci-app-openclash/luci-app-openclash/root/etc/uci-defaults/luci-openclash"
  if [[ `grep -c "uci get openclash.config.enable" "${uci_path}"` -eq '0' ]]; then
    sed -i '/exit 0/d' "${uci_path}"
    sed -i '/uci -q set openclash.config.enable/d' "${uci_path}"
    sed -i '/uci -q commit openclash/d' "${uci_path}"

cat >>"${uci_path}" <<-EOF
if [[ "\$(uci get openclash.config.enable)" == "0" ]] || [[ -z "\$(uci get openclash.config.enable)" ]]; then
  uci -q set openclash.config.enable=0
  uci -q commit openclash
fi
exit 0
EOF
  fi
fi


if [[ "${Enable_IPV6_function}" == "1" ]]; then
  echo "固件加入IPV6功能"
  echo "自动取消IPV4功能 和 爱快+OP双系统时,爱快接管IPV6功能"
  export Create_Ipv6_Lan="0"
  export Enable_IPV4_function="0"
  echo "Enable_IPV4_function=0" >> ${GITHUB_ENV}
  echo "Enable_IPV6_function=1" >> ${GITHUB_ENV}
  echo "
    uci set network.lan.ip6assign='64'
    uci commit network
    uci set dhcp.lan.ra='server'
    uci set dhcp.lan.dhcpv6='server'
    uci set dhcp.lan.ra_management='1'
    uci set dhcp.lan.ra_default='1'
    uci set dhcp.@dnsmasq[0].localservice=0
    uci set dhcp.@dnsmasq[0].nonwildcard=0
    uci set dhcp.@dnsmasq[0].filter_aaaa='0'
    uci commit dhcp
    /etc/init.d/dnsmasq restart
    /etc/init.d/odhcpd restart
  " >> "${DEFAULT_PATH}"
fi

if [[ "${Create_Ipv6_Lan}" == "1" ]]; then
  echo "爱快+OP双系统时,爱快接管IPV6,在OP创建IPV6的lan口接收IPV6信息"
  echo "Create_Ipv6_Lan=1" >> ${GITHUB_ENV}
  export Enable_IPV4_function="0"
  echo "
    uci delete network.lan.ip6assign
    uci set network.lan.delegate='0'
    uci commit network
    uci delete dhcp.lan.ra
    uci delete dhcp.lan.ra_management
    uci delete dhcp.lan.ra_default
    uci delete dhcp.lan.dhcpv6
    uci delete dhcp.lan.ndp
    uci set dhcp.@dnsmasq[0].filter_aaaa='0'
    uci commit dhcp
    uci set network.ipv6=interface
    uci set network.ipv6.proto='dhcpv6'
    ${devicee}
    ${ifnamee}
    uci set network.ipv6.reqaddress='try'
    uci set network.ipv6.reqprefix='auto'
    uci commit network
    ${set_add}
    uci commit firewall
    /etc/init.d/network restart
    /etc/init.d/dnsmasq restart
    /etc/init.d/odhcpd restart
  " >> "${DEFAULT_PATH}"
fi

if [[ "${Enable_IPV4_function}" == "1" ]]; then
  echo "Enable_IPV4_function=1" >> ${GITHUB_ENV}
  echo "Enable_IPV6_function=0" >> ${GITHUB_ENV}
  echo "Create_Ipv6_Lan=0" >> ${GITHUB_ENV}
  echo "固件加入IPV4功能"
  echo "
    uci delete network.globals.ula_prefix
    uci delete network.lan.ip6assign
    uci delete network.wan6
    uci set network.lan.delegate='0' 
    uci commit network
    uci delete dhcp.lan.ra
    uci delete dhcp.lan.ra_management
    uci delete dhcp.lan.ra_default
    uci delete dhcp.lan.dhcpv6
    uci delete dhcp.lan.ndp
    uci set dhcp.@dnsmasq[0].filter_aaaa='1'
    uci commit dhcp
    /etc/init.d/network restart
    /etc/init.d/dnsmasq restart
    /etc/init.d/odhcpd restart
  " >> "${DEFAULT_PATH}"
fi

if [[ "${Mandatory_theme}" == "0" ]] || [[ -z "${Mandatory_theme}" ]]; then
  echo "Mandatory_theme=0" >> ${GITHUB_ENV}
  echo "不进行,替换bootstrap主题设置"
elif [[ -n "${Mandatory_theme}" ]]; then
  echo "Mandatory_theme=${Mandatory_theme}" >> ${GITHUB_ENV}
fi

if [[ "${Default_theme}" == "0" ]] || [[ -z "${Default_theme}" ]]; then
  echo "Default_theme=0" >> ${GITHUB_ENV}
  echo "不进行,默认主题设置"
elif [[ -n "${Default_theme}" ]]; then
  echo "Default_theme=${Default_theme}" >> ${GITHUB_ENV}
fi

if [[ "${Customized_Information}" == "0" ]] || [[ -z "${Customized_Information}" ]]; then
  echo "不进行,个性签名设置"
elif [[ -n "${Customized_Information}" ]]; then
  sed -i "s?DESCRIPTION=.*?DESCRIPTION='OpenWrt '\" >> /etc/openwrt_release?g" "${ZZZ_PATH}"
  sed -i "s?OpenWrt ?${Customized_Information} @ OpenWrt ?g" "${ZZZ_PATH}"
  echo "个性签名[${Customized_Information}]增加完成"
fi

if [[ "${Kernel_partition_size}" == "0" ]] || [[ -z "${Kernel_partition_size}" ]]; then
  echo "Kernel_partition_size=0" >> ${GITHUB_ENV}
  echo "不进行,内核分区大小设置"
elif [[ -n "${Kernel_partition_size}" ]]; then
  echo "Kernel_partition_size=${Kernel_partition_size}" >> ${GITHUB_ENV}
fi

if [[ "${Root_partition_size}" == "0" ]] || [[ -z "${Root_partition_size}" ]]; then
  echo "Root_partition_size=0" >> ${GITHUB_ENV}
  echo "不进行,系统分区大小设置"
elif [[ -n "${Root_partition_size}" ]]; then
  echo "Root_partition_size=${Root_partition_size}" >> ${GITHUB_ENV}
fi

if [[ "${Delete_unnecessary_items}" == "1" ]]; then
   echo "Delete_unnecessary_items=${Delete_unnecessary_items}" >> ${GITHUB_ENV}
fi

if [[ "${Replace_Kernel}" == "0" ]] || [[ -z "${Replace_Kernel}" ]]; then
  echo "Replace_Kernel=0" >> ${GITHUB_ENV}
  echo "使用默认内核"
elif [[ -n "${Replace_Kernel}" ]]; then
  Replace_nel="$(echo ${Replace_Kernel} |grep -Eo "[0-9]+\.[0-9]+")"
  if [[ -n "${Replace_nel}" ]]; then
    echo "Replace_Kernel=${Replace_Kernel}" >> ${GITHUB_ENV}
  else
    echo "Replace_Kernel=0" >> ${GITHUB_ENV}
    echo "填写的内核格式错误,使用源码默认内核编译"
  fi
fi

if [[ "${Ipv4_ipaddr}" == "0" ]] || [[ -z "${Ipv4_ipaddr}" ]]; then
  echo "使用源码默认后台IP"
elif [[ -n "${Ipv4_ipaddr}" ]]; then
  Kernel_Pat="$(echo ${Ipv4_ipaddr} |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  ipadd_Pat="$(echo ${ipadd} |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  if [[ -n "${Kernel_Pat}" ]] && [[ -n "${ipadd_Pat}" ]]; then
     sed -i "s/${ipadd}/${Ipv4_ipaddr}/g" "${GENE_PATH}"
     echo "openwrt后台IP[${Ipv4_ipaddr}]修改完成"
   else
     echo "TIME r \"因IP获取有错误，后台IP更换不成功，请检查IP是否填写正确，如果填写正确，那就是获取不了源码内的IP了\"" >> ${HOME_PATH}/CHONGTU
   fi
fi

if [[ "${Netmask_netm}" == "0" ]] || [[ -z "${Netmask_netm}" ]]; then
  echo "使用默认子网掩码"
elif [[ -n "${Netmask_netm}" ]]; then
  Kernel_netm="$(echo ${Netmask_netm} |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  ipadd_mas="$(echo ${netmas} |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  if [[ -n "${Kernel_netm}" ]] && [[ -n "${ipadd_mas}" ]]; then
     sed -i "s/${netmas}/${Netmask_netm}/g" "${GENE_PATH}"
     echo "子网掩码[${Netmask_netm}]修改完成"
   else
     echo "TIME r \"因子网掩码获取有错误，子网掩码设置失败，请检查IP是否填写正确，如果填写正确，那就是获取不了源码内的IP了\"" >> ${HOME_PATH}/CHONGTU
  fi
fi

if [[ "${Op_name}" == "0" ]] || [[ -z "${Op_name}" ]]; then
  echo "使用源码默认主机名"
elif [[ -n "${Op_name}" ]] && [[ -n "${opname}" ]]; then
  sed -i "s/${opname}/${Op_name}/g" "${GENE_PATH}"
  echo "主机名[${Op_name}]修改完成"
fi

if [[ "${Gateway_Settings}" == "0" ]] || [[ -z "${Gateway_Settings}" ]]; then
  echo "不进行,网关设置"
elif [[ -n "${Gateway_Settings}" ]]; then
  Router_gat="$(echo ${Gateway_Settings} |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  if [[ -n "${Router_gat}" ]]; then
    sed -i "$lan\set network.lan.gateway='${Gateway_Settings}'" "${GENE_PATH}"
    echo "网关[${Gateway_Settings}]修改完成"
  else
    echo "TIME r \"因子网关IP获取有错误，网关IP设置失败，请检查IP是否填写正确，如果填写正确，那就是获取不了源码内的IP了\"" >> ${HOME_PATH}/CHONGTU
  fi
fi

if [[ "${DNS_Settings}" == "0" ]] || [[ -z "${DNS_Settings}" ]]; then
  echo "不进行,DNS设置"
elif [[ -n "${DNS_Settings}" ]]; then
  ipa_dns="$(echo ${DNS_Settings} |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  if [[ -n "${ipa_dns}" ]]; then
     sed -i "$lan\set network.lan.dns='${DNS_Settings}'" "${GENE_PATH}"
     echo "DNS[${DNS_Settings}]设置完成"
  else
    echo "TIME r \"因DNS获取有错误，DNS设置失败，请检查DNS是否填写正确\"" >> ${HOME_PATH}/CHONGTU
  fi
fi

if [[ "${Broadcast_Ipv4}" == "0" ]] || [[ -z "${Broadcast_Ipv4}" ]]; then
  echo "不进行,广播IP设置"
elif [[ -n "${Broadcast_Ipv4}" ]]; then
  IPv4_Bro="$(echo ${Broadcast_Ipv4} |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  if [[ -n "${IPv4_Bro}" ]]; then
    sed -i "$lan\set network.lan.broadcast='${Broadcast_Ipv4}'" "${GENE_PATH}"
    echo "广播IP[${Broadcast_Ipv4}]设置完成"
  else
    echo "TIME r \"因IPv4 广播IP获取有错误，IPv4广播IP设置失败，请检查IPv4广播IP是否填写正确\"" >> ${HOME_PATH}/CHONGTU
  fi
fi

if [[ "${Disable_DHCP}" == "1" ]]; then
   sed -i "$lan\set dhcp.lan.ignore='1'" "${GENE_PATH}"
   echo "关闭DHCP设置完成"
fi

if [[ "${Disable_Bridge}" == "1" ]]; then
   sed -i "$lan\delete network.lan.type" "${GENE_PATH}"
   echo "去掉桥接设置完成"
fi

if [[ "${Ttyd_account_free_login}" == "1" ]]; then
   sed -i "$lan\set ttyd.@ttyd[0].command='/bin/login -f root'" "${GENE_PATH}"
   echo "TTYD免账户登录完成"
fi

if [[ "${Password_free_login}" == "1" ]]; then
   sed -i '/CYXluq4wUazHjmCDBCqXF/d' "${ZZZ_PATH}"
   echo "固件免密登录设置完成"
fi

if [[ "${Disable_53_redirection}" == "1" ]]; then
   sed -i '/to-ports 53/d' "${ZZZ_PATH}"
   echo "删除DNS重定向53端口完成"
fi

if [[ "${Cancel_running}" == "1" ]]; then
   echo "sed -i '/coremark/d' /etc/crontabs/root" >> "${DEFAULT_PATH}"
   echo "删除每天跑分任务完成"
fi


# 晶晨CPU机型自定义机型,内核,分区
echo "amlogic_model=${amlogic_model}" >> ${GITHUB_ENV}
echo "amlogic_kernel=${amlogic_kernel}" >> ${GITHUB_ENV}
echo "auto_kernel=${auto_kernel}" >> ${GITHUB_ENV}
echo "rootfs_size=${rootfs_size}" >> ${GITHUB_ENV}
echo "kernel_repo=ophub/kernel" >> ${GITHUB_ENV}
echo "kernel_usage=${kernel_usage}" >> ${GITHUB_ENV}
[[ -f "${GITHUB_ENV}" ]] && source ${GITHUB_ENV}
}


function Diy_shpart() {
cd ${HOME_PATH}
# 修正连接数
if [[ `grep -c "net.netfilter.nf_conntrack_max" ${HOME_PATH}/package/kernel/linux/files/sysctl-nf-conntrack.conf` -eq '0' ]]; then
  echo -e "\nnet.netfilter.nf_conntrack_max=165535" >> ${HOME_PATH}/package/base-files/files/etc/sysctl.conf
fi
}


function Diy_upgrade1() {
if [[ "${UPDATE_FIRMWARE_ONLINE}" == "true" ]]; then
  cd ${HOME_PATH}
  source ${BUILD_PATH}/upgrade.sh && Diy_Part1
fi
}


function Diy_Language() {
cd ${HOME_PATH}
apptions="$(find "${HOME_PATH}/feeds" -type d -name "applications")"
if [[ -d "${apptions}" ]] && [[ `find "${apptions}" -type d -name "zh_Hans" |grep -c "zh_Hans"` -ge '15' ]]; then
  cp -Rf ${HOME_PATH}/build/common/language/zh_Hans.sh ${HOME_PATH}/zh_Hans.sh
  sudo chmod +x ${HOME_PATH}/zh_Hans.sh
  /bin/bash ${HOME_PATH}/zh_Hans.sh
  rm -rf ${HOME_PATH}/zh_Hans.sh
fi
}


function Diy_feeds() {
echo "正在执行：更新feeds,请耐心等待..."
cd ${HOME_PATH}
./scripts/feeds update -a
if [[ -f "${HOME_PATH}/diy_pa_sh" ]] && [[ ! "${ERCI}" == "1" ]]; then
  source ${HOME_PATH}/diy_pa_sh
  rm -rf ${HOME_PATH}/diy_pa_sh
fi
if [[ "${SOURCE_CODE}" =~ (XWRT|OFFICIAL) ]] && [[ -d "feeds/helloworld" ]]; then
  SSR_LUA="${HOME_PATH}/feeds/helloworld/luci-app-ssr-plus/root/usr/share/shadowsocksr/subscribe.lua"
  [[ -f "${SSR_LUA}" ]] && sed -i 's?result.insecure = "0"?result.insecure = "1"?g' "${SSR_LUA}"

  if [[ -d "${HOME_PATH}/feeds/danshui/luci-app-store" ]] && [[ "${REPO_BRANCH}" == "openwrt-19.07" ]]
    rm -rf ${HOME_PATH}/feeds/danshui/luci-app-store
  fi
fi
./scripts/feeds install -a > /dev/null 2>&1
./scripts/feeds install -a

if [[ ! -f "${HOME_PATH}/staging_dir/host/bin/upx" ]] && [[ ! "${ERCI}" == "1" ]]; then
  cp /usr/bin/upx ${HOME_PATH}/staging_dir/host/bin/upx
  cp /usr/bin/upx-ucl ${HOME_PATH}/staging_dir/host/bin/upx-ucl
fi

[[ -f ${BUILD_PATH}/$CONFIG_FILE ]] && mv ${BUILD_PATH}/$CONFIG_FILE .config

if [[ "${SOURCE_CODE}" == "IMMORTALWRT" ]]; then
cat >> "${HOME_PATH}/.config" <<-EOF
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_default-settings-chn=y
EOF
sed -i '/openwrt_banner/d' "${ZZZ_PATH}"
else
cat >> "${HOME_PATH}/.config" <<-EOF
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_default-settings=y
EOF
fi

if [[ -n "${Kernel_partition_size}" ]] && [[ "${Kernel_partition_size}" != "0" ]]; then
  echo "CONFIG_TARGET_KERNEL_PARTSIZE=${Kernel_partition_size}" >> ${HOME_PATH}/.config
  echo "内核分区设置完成，大小为：${Kernel_partition_size}MB"
fi

if [[ -n "${Root_partition_size}" ]] && [[ "${Root_partition_size}" != "0" ]]; then
  echo "CONFIG_TARGET_ROOTFS_PARTSIZE=${Root_partition_size}" >> ${HOME_PATH}/.config
  echo "系统分区设置完成，大小为：${Root_partition_size}MB"
fi

if [[ "${Mandatory_theme}" == "0" ]]; then
  echo "不进行必选主题修改"
elif [[ -n "${Mandatory_theme}" ]]; then
  if [[ "${GL_BRANCH}" == "lede_ax1800" ]]; then
    collections="${HOME_PATH}/extra/luci/collections/luci/Makefile"
  else
    collections="${HOME_PATH}/feeds/luci/collections/luci/Makefile"
  fi
  luci_light="${HOME_PATH}/feeds/luci/collections/luci-light/Makefile"
  if [[ `grep -Eoc "luci-theme" "${collections}"` -eq "0" ]]; then
    ybtheme="$(grep -Eo "luci-theme-.*" "${luci_light}" 2>&1 |sed -r 's/.*theme-(.*)=y/\1/' |awk '{print $(1)}')"
  else
    ybtheme="$(grep -Eo "luci-theme-.*" "${collections}" 2>&1 |sed -r 's/.*theme-(.*)=y/\1/' |awk '{print $(1)}')"
  fi
  yhtheme="luci-theme-${Mandatory_theme}"
  if [[ `find . -type d -name "${yhtheme}" |grep -v 'dir' |grep -c "${yhtheme}"` -ge "1" ]]; then
    if [[ `grep -Eoc "luci-theme" "${collections}"` -eq "0" ]]; then
      sed -i "s/${ybtheme}/${yhtheme}/g" "${luci_light}"
    else
      sed -i "s/${ybtheme}/${yhtheme}/g" "${collections}"
    fi
    echo "必选主题修改完成，必选主题为：${yhtheme}"
  else
    echo "TIME r \"没有${yhtheme}此主题存在,不进行替换${ybtheme}主题操作\"" >> ${HOME_PATH}/CHONGTU
  fi
fi
}


function Diy_IPv6helper() {
cd ${HOME_PATH}
if [[ "${Enable_IPV6_function}" == "1" ]] || [[ "${Create_Ipv6_Lan}" == "1" ]]; then
echo '
CONFIG_PACKAGE_ipv6helper=y
CONFIG_PACKAGE_ip6tables=y
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_odhcp6c=y
CONFIG_PACKAGE_odhcpd-ipv6only=y
CONFIG_IPV6=y
CONFIG_PACKAGE_6rd=y
CONFIG_PACKAGE_6to4=y
' >> ${HOME_PATH}/.config
fi

if [[ "${Enable_IPV4_function}" == "1" ]]; then
sed -i '/CONFIG_PACKAGE_ipv6helper=y/d' "${HOME_PATH}/.config"
sed -i '/CONFIG_PACKAGE_ip6tables=y/d' "${HOME_PATH}/.config"
sed -i '/CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y/d' "${HOME_PATH}/.config"
sed -i '/CONFIG_PACKAGE_odhcp6c=y/d' "${HOME_PATH}/.config"
sed -i '/CONFIG_PACKAGE_odhcpd-ipv6only=y/d' "${HOME_PATH}/.config"
sed -i '/CONFIG_IPV6=y/d' "${HOME_PATH}/.config"
sed -i '/CONFIG_PACKAGE_6rd=y/d' "${HOME_PATH}/.config"
sed -i '/CONFIG_PACKAGE_6to4=y/d' "${HOME_PATH}/.config"
fi
}


function Diy_prevent() {
cd ${HOME_PATH}
Diy_IPv6helper
echo "正在执行：判断插件有否冲突减少编译错误"
make defconfig > /dev/null 2>&1
if [[ `grep -c "CONFIG_PACKAGE_luci-app-ipsec-server=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-ipsec-vpnd=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-ipsec-vpnd=y/# CONFIG_PACKAGE_luci-app-ipsec-vpnd is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-ipsec-vpnd和luci-app-ipsec-server，插件有冲突，相同功能插件只能二选一，已删除luci-app-ipsec-vpnd\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-docker=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-dockerman=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-docker=y/# CONFIG_PACKAGE_luci-app-docker is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-docker-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-docker-zh-cn is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-docker和luci-app-dockerman，插件有冲突，相同功能插件只能二选一，已删除luci-app-docker\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-qbittorrent=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-qbittorrent-simple=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-qbittorrent-simple=y/# CONFIG_PACKAGE_luci-app-qbittorrent-simple is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-qbittorrent-simple-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-qbittorrent-simple-zh-cn is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_qbittorrent=y/# CONFIG_PACKAGE_qbittorrent is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-qbittorrent和luci-app-qbittorrent-simple，插件有冲突，相同功能插件只能二选一，已删除luci-app-qbittorrent-simple\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-advanced=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-fileassistant=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-fileassistant=y/# CONFIG_PACKAGE_luci-app-fileassistant is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-advanced和luci-app-fileassistant，luci-app-advanced已附带luci-app-fileassistant，所以删除了luci-app-fileassistant\"" >>CHONGTU
    echo "" >>CHONGTU
   fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-adblock-plus=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-adblock=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-adblock=y/# CONFIG_PACKAGE_luci-app-adblock is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_adblock=y/# CONFIG_PACKAGE_adblock is not set/g' ${HOME_PATH}/.config
    sed -i '/luci-i18n-adblock/d' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-adblock-plus和luci-app-adblock，插件有依赖冲突，只能二选一，已删除luci-app-adblock\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-kodexplorer=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-vnstat=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-vnstat=y/# CONFIG_PACKAGE_luci-app-vnstat is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_vnstat=y/# CONFIG_PACKAGE_vnstat is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_vnstati=y/# CONFIG_PACKAGE_vnstati is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_libgd=y/# CONFIG_PACKAGE_libgd is not set/g' ${HOME_PATH}/.config
    sed -i '/luci-i18n-vnstat/d' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-kodexplorer和luci-app-vnstat，插件有依赖冲突，只能二选一，已删除luci-app-vnstat\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-ssr-plus=y" ${HOME_PATH}/.config` -ge '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-cshark=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-cshark=y/# CONFIG_PACKAGE_luci-app-cshark is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_cshark=y/# CONFIG_PACKAGE_cshark is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_libustream-mbedtls=y/# CONFIG_PACKAGE_libustream-mbedtls is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-ssr-plus和luci-app-cshark，插件有依赖冲突，只能二选一，已删除luci-app-cshark\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_SHORTCUT_FE_CM=y" ${HOME_PATH}/.config` -ge '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_SHORTCUT_FE=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_SHORTCUT_FE=y/# CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_SHORTCUT_FE is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_kmod-fast-classifier=y/# CONFIG_PACKAGE_kmod-fast-classifier is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"luci-app-turboacc同时选择Include Shortcut-FE CM和Include Shortcut-FE，有冲突，只能二选一，已删除Include Shortcut-FE\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_wpad-openssl=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_wpad=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_wpad=y/# CONFIG_PACKAGE_wpad is not set/g' ${HOME_PATH}/.config
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_antfs-mount=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_ntfs3-mount=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_antfs-mount=y/# CONFIG_PACKAGE_antfs-mount is not set/g' ${HOME_PATH}/.config
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_dnsmasq-full=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_dnsmasq=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_PACKAGE_dnsmasq-dhcpv6=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_dnsmasq=y/# CONFIG_PACKAGE_dnsmasq is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_dnsmasq-dhcpv6=y/# CONFIG_PACKAGE_dnsmasq-dhcpv6 is not set/g' ${HOME_PATH}/.config
  fi
  if [[ `grep -c "CONFIG_PACKAGE_dnsmasq_full_conntrack=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_dnsmasq_full_conntrack=y/# CONFIG_PACKAGE_dnsmasq_full_conntrack is not set/g' ${HOME_PATH}/.config
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-samba4=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-samba=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_autosamba=y/# CONFIG_PACKAGE_autosamba is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-app-samba=y/# CONFIG_PACKAGE_luci-app-samba is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-samba-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-samba-zh-cn is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_samba36-server=y/# CONFIG_PACKAGE_samba36-server is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-samba和luci-app-samba4，插件有冲突，相同功能插件只能二选一，已删除luci-app-samba\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  pmg="$(echo "$(date +%d)" | sed 's/^.//g')"
  mkdir -p ${HOME_PATH}/files/www/luci-static/argon/background
  curl -fsSL  https://raw.githubusercontent.com/281677160/openwrt-package/usb/argon/jpg/${pmg}.jpg > ${HOME_PATH}/files/www/luci-static/argon/background/moren.jpg
  if [[ $? -ne 0 ]]; then
    echo "拉取文件错误,请检测网络"
    exit 1
  fi
  if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon_new=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-theme-argon_new=y/# CONFIG_PACKAGE_luci-theme-argon_new is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-theme-argon和luci-theme-argon_new，插件有冲突，相同功能插件只能二选一，已删除luci-theme-argon_new\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon=y" ${HOME_PATH}/.config` -eq '1' ]] && [[ `grep -c "CONFIG_TARGET_x86=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-argon-config=y" ${HOME_PATH}/.config` -eq '0' ]]; then
    sed -i '/argon-config/d' "${HOME_PATH}/.config"
    sed -i '/argon=y/i\CONFIG_PACKAGE_luci-app-argon-config=y' "${HOME_PATH}/.config"
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-sfe=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-flowoffload=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_DEFAULT_luci-app-flowoffload=y/# CONFIG_DEFAULT_luci-app-flowoffload is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-app-flowoffload=y/# CONFIG_PACKAGE_luci-app-flowoffload is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-flowoffload-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-flowoffload-zh-cn is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"提示：您同时选择了luci-app-sfe和luci-app-flowoffload，两个ACC网络加速，已删除luci-app-flowoffload\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-ssl=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_libustream-wolfssl=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-ssl=y/# CONFIG_PACKAGE_luci-ssl is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_libustream-wolfssl=y/CONFIG_PACKAGE_libustream-wolfssl=m/g' ${HOME_PATH}/.config
    echo "TIME r \"您选择了luci-ssl会自带libustream-wolfssl，会和libustream-openssl冲突导致编译错误，已删除luci-ssl\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-unblockneteasemusic=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-unblockneteasemusic-go=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-unblockneteasemusic-go=y/# CONFIG_PACKAGE_luci-app-unblockneteasemusic-go is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您选择了luci-app-unblockneteasemusic-go，会和luci-app-unblockneteasemusic冲突导致编译错误，已删除luci-app-unblockneteasemusic-go\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-unblockmusic=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-unblockmusic=y/# CONFIG_PACKAGE_luci-app-unblockmusic is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您选择了luci-app-unblockmusic，会和luci-app-unblockneteasemusic冲突导致编译错误，已删除luci-app-unblockmusic\"" >>CHONGTU
    echo "" >>CHONGTU
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_ntfs-3g=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  mkdir -p ${HOME_PATH}/files/etc/hotplug.d/block && curl -fsSL  https://raw.githubusercontent.com/281677160/openwrt-package/usb/block/10-mount > ${HOME_PATH}/files/etc/hotplug.d/block/10-mount
  if [[ $? -ne 0 ]]; then
    echo "拉取文件错误,请检测网络"
    exit 1
  fi
fi

if [[ `grep -c "CONFIG_TARGET_armvirt_64_Default=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  echo -e "\nCONFIG_TARGET_ROOTFS_TARGZ=y" >> "${HOME_PATH}/.config"
fi

if [[ `grep -c "CONFIG_TARGET_x86=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_rockchip=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_bcm27xx=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  echo -e "\nCONFIG_PACKAGE_snmpd=y" >> "${HOME_PATH}/.config"
  echo -e "\nCONFIG_TARGET_IMAGES_GZIP=y" >> "${HOME_PATH}/.config"
  echo -e "\nCONFIG_PACKAGE_openssh-sftp-server=y" >> "${HOME_PATH}/.config"
  echo -e "\nCONFIG_GRUB_IMAGES=y" >> "${HOME_PATH}/.config"
  if [[ `grep -c "CONFIG_TARGET_ROOTFS_PARTSIZE=" ${HOME_PATH}/.config` -eq '1' ]]; then
    PARTSIZE="$(grep -Eo "CONFIG_TARGET_ROOTFS_PARTSIZE=[0-9]+" ${HOME_PATH}/.config |cut -f2 -d=)"
    if [[ "${PARTSIZE}" -lt "400" ]];then
      sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' ${HOME_PATH}/.config
      echo -e "\nCONFIG_TARGET_ROOTFS_PARTSIZE=400" >> ${HOME_PATH}/.config
    fi
  fi
fi
if [[ `grep -c "CONFIG_TARGET_mxs=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_sunxi=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_zynq=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  echo -e "\nCONFIG_TARGET_IMAGES_GZIP=y" >> "${HOME_PATH}/.config"
  echo -e "\nCONFIG_PACKAGE_openssh-sftp-server=y" >> "${HOME_PATH}/.config"
  echo -e "\nCONFIG_GRUB_IMAGES=y" >> "${HOME_PATH}/.config"
  if [[ `grep -c "CONFIG_TARGET_ROOTFS_PARTSIZE=" ${HOME_PATH}/.config` -eq '1' ]]; then
    PARTSIZE="$(grep -Eo "CONFIG_TARGET_ROOTFS_PARTSIZE=[0-9]+" ${HOME_PATH}/.config |cut -f2 -d=)"
    if [[ "${PARTSIZE}" -lt "400" ]];then
      sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' ${HOME_PATH}/.config
      echo -e "\nCONFIG_TARGET_ROOTFS_PARTSIZE=400" >> ${HOME_PATH}/.config
    fi
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_odhcp6c=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  sed -i '/CONFIG_PACKAGE_odhcpd=y/d' "${HOME_PATH}/.config"
  sed -i '/CONFIG_PACKAGE_odhcpd_full_ext_cer_id=0/d' "${HOME_PATH}/.config"
fi

if [[ "${GL_BRANCH}" == "lede_ax1800" ]] || [[ "${SOURCE_CODE}" == "OFFICIAL" ]] && [[ "${REPO_BRANCH}" == "openwrt-19.07" ]]; then
  sed -i 's/CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_NaiveProxy=y/# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_NaiveProxy is not set/g' ${HOME_PATH}/.config
  sed -i 's/CONFIG_PACKAGE_naiveproxy=y/# CONFIG_PACKAGE_naiveproxy is not set/g' ${HOME_PATH}/.config
  sed -i 's/CONFIG_PACKAGE_luci-app-passwall_INCLUDE_NaiveProxy=y/# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_NaiveProxy is not set/g' ${HOME_PATH}/.config
  sed -i 's/CONFIG_PACKAGE_luci-app-passwall2_INCLUDE_NaiveProxy=y/# CONFIG_PACKAGE_luci-app-passwall2_INCLUDE_NaiveProxy is not set/g' ${HOME_PATH}/.config
fi

if [[ ! "${UPDATE_FIRMWARE_ONLINE}" == "true" ]] || [[ -z "${REPO_TOKEN}" ]]; then
  sed -i 's/CONFIG_PACKAGE_luci-app-autoupdate=y/# CONFIG_PACKAGE_luci-app-autoupdate is not set/g' ${HOME_PATH}/.config
fi

if [[ "${COLLECTED_PACKAGES}" == "true" ]] && [[ "${OpenClash_branch}" == "0" ]]; then
  sed -i 's/CONFIG_PACKAGE_luci-app-openclash=y/# CONFIG_PACKAGE_luci-app-openclash is not set/g' ${HOME_PATH}/.config
elif [[ "${COLLECTED_PACKAGES}" == "true" ]] && [[ "${OpenClash_branch}" != "0" ]]; then
  echo -e "\nCONFIG_PACKAGE_luci-app-openclash=y" >> ${HOME_PATH}/.config
fi

if [[ `grep -c "CONFIG_TARGET_ROOTFS_EXT4FS=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  PARTSIZE="$(grep -Eo "CONFIG_TARGET_ROOTFS_PARTSIZE=[0-9]+" ${HOME_PATH}/.config |cut -f2 -d=)"
  if [[ "${PARTSIZE}" -lt "950" ]];then
    sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' ${HOME_PATH}/.config
    echo -e "\nCONFIG_TARGET_ROOTFS_PARTSIZE=950" >> ${HOME_PATH}/.config
    echo "TIME r \"EXT4提示：请注意，您选择了ext4安装的固件格式,而检测到您的分配的固件系统分区过小\"" >> ${HOME_PATH}/CHONGTU
    echo "TIME y \"为避免编译出错,已自动帮您修改成950M\"" >> ${HOME_PATH}/CHONGTU
    echo "" >> ${HOME_PATH}/CHONGTU
  fi
fi

cd ${HOME_PATH}
make defconfig > /dev/null 2>&1
[[ ! -d "${HOME_PATH}/build_logo" ]] && mkdir -p ${HOME_PATH}/build_logo
./scripts/diffconfig.sh > ${HOME_PATH}/build_logo/config.txt
}


function Make_defconfig() {
cd ${HOME_PATH}
echo "正在执行：识别源码编译为何机型"
export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' ${HOME_PATH}/.config)"
export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' ${HOME_PATH}/.config)"
export TARGET_PROFILE_DG="$(awk -F '[="]+' '/TARGET_PROFILE/{print $2}' ${HOME_PATH}/.config)"
if [[ `grep -Eoc 'CONFIG_TARGET_x86_64=y' ${HOME_PATH}/.config` -eq '1' ]]; then
  export TARGET_PROFILE="x86-64"
elif [[ `grep -Eoc 'CONFIG_TARGET_x86=y' ${HOME_PATH}/.config` -eq '1' ]]; then
  export TARGET_PROFILE="x86-32"
elif [[ `grep -Eoc 'CONFIG_TARGET_armvirt_64_Default=y' ${HOME_PATH}/.config` -eq '1' ]]; then
  export TARGET_PROFILE="Armvirt_64"
elif [[ `grep -Eoc "CONFIG_TARGET.*DEVICE.*=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  export TARGET_PROFILE="$(grep -Eo "CONFIG_TARGET.*DEVICE.*=y" ${HOME_PATH}/.config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
  export TARGET_PROFILE="${TARGET_PROFILE_DG}"
fi
export FIRMWARE_PATH=${HOME_PATH}/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}
export TARGET_OPENWRT=openwrt/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}
echo "正在编译：${TARGET_PROFILE}"

if [[ "${SOURCE_CODE}" == "AMLOGIC" && "${PACKAGING_FIRMWARE}" == "true" ]]; then
  echo "PROMPT_TING=${amlogic_model}" >> ${GITHUB_ENV}
else
  echo "PROMPT_TING=${LUCI_EDITION}-${TARGET_PROFILE}" >> ${GITHUB_ENV}
fi

echo "TARGET_BOARD=${TARGET_BOARD}" >> ${GITHUB_ENV}
echo "TARGET_SUBTARGET=${TARGET_SUBTARGET}" >> ${GITHUB_ENV}
echo "TARGET_PROFILE=${TARGET_PROFILE}" >> ${GITHUB_ENV}
echo "FIRMWARE_PATH=${FIRMWARE_PATH}" >> ${GITHUB_ENV}
}


function CPU_Priority() {
export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' build/${FOLDER_NAME}/${CONFIG_FILE})"
export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' build/${FOLDER_NAME}/${CONFIG_FILE})"
if [[ `grep -Eoc 'CONFIG_TARGET_x86_64=y' build/${FOLDER_NAME}/${CONFIG_FILE}` -eq '1' ]]; then
  export TARGET_PROFILE="x86-64"
elif [[ `grep -Eoc 'CONFIG_TARGET_x86=y' build/${FOLDER_NAME}/${CONFIG_FILE}` -eq '1' ]]; then
  export TARGET_PROFILE="x86-32"
elif [[ `grep -Eoc 'CONFIG_TARGET_armvirt_64_Default=y' build/${FOLDER_NAME}/${CONFIG_FILE}` -eq '1' ]]; then
  export TARGET_PROFILE="Armvirt_64"
elif [[ `grep -Eoc "CONFIG_TARGET.*DEVICE.*=y" build/${FOLDER_NAME}/${CONFIG_FILE}` -eq '1' ]]; then
  export TARGET_PROFILE="$(grep -Eo "CONFIG_TARGET.*DEVICE.*=y" build/${FOLDER_NAME}/${CONFIG_FILE} | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
  export TARGET_PROFILE="$(cat "build/${FOLDER_NAME}/${CONFIG_FILE}" |grep "CONFIG_TARGET_.*=y" |awk 'END {print}'|sed "s/CONFIG_TARGET_//g"|sed "s/=y//g")"
fi

cpu_model=`cat /proc/cpuinfo  |grep 'model name' |gawk -F : '{print $2}' | uniq -c  | sed 's/^ \+[0-9]\+ //g'`
TIME y "正在使用CPU型号：${cpu_model}"

if [[ -n "${CPU_SELECTIOY}" ]]; then
  CPU_OPTIMIZATION="${CPU_SELECTIOY}"
fi

case "${CPU_OPTIMIZATION}" in
E5|弃用E5系列|弃用E5)
  if [[ `echo "${cpu_model}" |grep -Eoc "E5"` -eq '1' ]]; then
    export chonglaixx="E5-重新编译"
    export Continue_selecting="1"
  else
    TIME g " 恭喜,不是E5系列的CPU啦"
    export Continue_selecting="0"
  fi
;;
8370|8272|8171|8370C|8272CL|8171M)
  if [[ `echo "${cpu_model}" |grep -Eoc "${CPU_OPTIMIZATION}"` -eq '0' ]]; then
    export chonglaixx="非${CPU_OPTIMIZATION}-重新编译"
    export Continue_selecting="1"
  else
    TIME g " 恭喜,正是您想要的${CPU_OPTIMIZATION}CPU"
    export Continue_selecting="0"
  fi
;;
*)
  echo "${CPU_OPTIMIZATION},变量检测有错误"
  export Continue_selecting="0"
;;
esac

if [[ "${Continue_selecting}" == "1" ]]; then
  cd ${GITHUB_WORKSPACE}
  git clone -b main https://github.com/${GIT_REPOSITORY}.git ${FOLDER_NAME}
  if [[ ! -d "${FOLDER_NAME}/build/${FOLDER_NAME}/relevance" ]]; then
    mkdir -p "${FOLDER_NAME}/build/${FOLDER_NAME}/relevance"
  fi
  rm -rf ${FOLDER_NAME}/build/${FOLDER_NAME}
  cp -Rf build/${FOLDER_NAME} ${FOLDER_NAME}/build/${FOLDER_NAME}
  rm -rf ${FOLDER_NAME}/build/${FOLDER_NAME}/*.sh
  cp -Rf build/${FOLDER_NAME}/${DIY_PART_SH} ${FOLDER_NAME}/build/${FOLDER_NAME}/${DIY_PART_SH}
  
  rm -rf ${FOLDER_NAME}/.github/workflows
  cp -Rf .github/workflows ${FOLDER_NAME}/.github/workflows
  
  if [[ -n "${CPU_SELECTIOY}" ]]; then
    YML_PATH="${FOLDER_NAME}/.github/workflows/compile.yml"
    rm -fr ${FOLDER_NAME}/build/${FOLDER_NAME}/relevance/*.ini
    cpu1="CPU_OPTIMIZATION=.*"
    cpu2="CPU_OPTIMIZATION\\=\\\"${CPU_SELECTIOY}\\\""
    CPU_PASS1="CPU_PASSWORD=.*"
    CPU_PASS2="CPU_PASSWORD\\=\\\"1234567\\\""
    if [[ -n "${cpu1}" ]] && [[ -n "${cpu2}" ]]; then
      sed -i "s?${cpu1}?${cpu2}?g" "${YML_PATH}"
    else
      echo "获取变量失败,请勿胡乱修改compile.yml文件"
      exit 1
    fi
    if [[ -n "${CPU_PASS1}" ]] && [[ -n "${CPU_PASS2}" ]]; then
      sed -i "s?${CPU_PASS1}?${CPU_PASS2}?g" "${YML_PATH}"
    else
      echo "获取变量失败,请勿胡乱修改compile.yml文件"
      exit 1
    fi
  fi
  
  restarts="$(cat "${FOLDER_NAME}/build/${FOLDER_NAME}/relevance/start" |awk '$0=NR" "$0' |awk 'END {print}' |awk '{print $(1)}')"
  if [[ "${restarts}" -lt "3" ]]; then
    echo "${SOURCE}-${REPO_BRANCH}-${CONFIG_FILE}-$(date +%Y年%m月%d号%H时%M分%S秒)" >> ${FOLDER_NAME}/build/${FOLDER_NAME}/relevance/start
  else
    echo "${SOURCE}-${REPO_BRANCH}-${CONFIG_FILE}-$(date +%Y年%m月%d号%H时%M分%S秒)" > ${FOLDER_NAME}/build/${FOLDER_NAME}/relevance/start
  fi
  
  cd ${FOLDER_NAME}
  git add .
  git commit -m "${chonglaixx}-${FOLDER_NAME}-${LUCI_EDITION}-${TARGET_PROFILE}"
  git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:main
  exit 1
fi
}

function Diy_Publicarea2() {
cd ${HOME_PATH}
if [[ "${Delete_unnecessary_items}" == "1" ]]; then
  echo "删除其他机型的固件,只保留当前主机型固件完成"
  sed -i "s|^TARGET_|# TARGET_|g; s|# TARGET_DEVICES += ${TARGET_PROFILE}|TARGET_DEVICES += ${TARGET_PROFILE}|" ${HOME_PATH}/target/linux/${TARGET_BOARD}/image/Makefile
fi

export patchverl="$(grep "KERNEL_PATCHVER" "${HOME_PATH}/target/linux/${TARGET_BOARD}/Makefile" |grep -Eo "[0-9]+\.[0-9]+")"
if [[ "${TARGET_BOARD}" == "armvirt" ]]; then
  export KERNEL_patc="config-${Replace_Kernel}"
else
  export KERNEL_patc="patches-${Replace_Kernel}"
fi
if [[ "${Replace_Kernel}" == "0" ]]; then
  echo "不进行内核更换"
elif [[ -n "${Replace_Kernel}" ]] && [[ -n "${patchverl}" ]]; then
  if [[ `ls -1 "${HOME_PATH}/target/linux/${TARGET_BOARD}" |grep -c "${KERNEL_patc}"` -eq '1' ]]; then
    sed -i "s/${patchverl}/${Replace_Kernel}/g" ${HOME_PATH}/target/linux/${TARGET_BOARD}/Makefile
    echo "内核[${Replace_Kernel}]更换完成"
  else
    echo "TIME r \"${TARGET_PROFILE}机型源码没发现[ ${Replace_Kernel} ]内核存在，替换内核操作失败，保持默认内核[${patchverl}]继续编译\"" >> ${HOME_PATH}/CHONGTU
  fi
fi

if [[ "${Default_theme}" == "0" ]]; then 
  echo "不进行默认主题设置"
elif [[ -n "${Default_theme}" ]]; then
  export defaultt=CONFIG_PACKAGE_luci-theme-${Default_theme}=y
  if [[ `grep -c "${defaultt}" ${HOME_PATH}/.config` -eq '1' ]]; then
    echo "
      uci set luci.main.mediaurlbase='/luci-static/${Default_theme}'
      uci commit luci
    " >> "${DEFAULT_PATH}"
    echo "默认主题[${Default_theme}]设置完成"
  else
     echo "TIME r \"没有选择luci-theme-${Default_theme}此主题,将${Default_theme}设置成默认主题的操作失败\"" >> ${HOME_PATH}/CHONGTU
  fi
fi

if [[ "${TARGET_PROFILE}" == "Armvirt_64" ]]; then
  echo "AMLOGIC_CODE=AMLOGIC" >> ${GITHUB_ENV}
  if [[ -z "${BENDI_VERSION}" ]]; then
    export PACKAGING_FIRMWARE="${UPDATE_FIRMWARE_ONLINE}"
    echo "PACKAGING_FIRMWARE=${UPDATE_FIRMWARE_ONLINE}" >> ${GITHUB_ENV}
    echo "UPDATE_FIRMWARE_ONLINE=false" >> ${GITHUB_ENV}
  fi
  # 修改cpufreq代码适配amlogic"
  for X in $(find . -type d -name "luci-app-cpufreq"); do \
    [[ -d "$X" ]] && \
    sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' "$X/Makefile"; \
  done
elif [[ "${TARGET_BOARD}" == "armvirt" ]]; then
  echo "PACKAGING_FIRMWARE=false" >> ${GITHUB_ENV}
  echo "UPDATE_FIRMWARE_ONLINE=false" >> ${GITHUB_ENV}
else
  echo "UPDATE_FIRMWARE_ONLINE=${UPDATE_FIRMWARE_ONLINE}" >> ${GITHUB_ENV}
fi

if [[ "${PACKAGING_FIRMWARE}" == "true" ]]; then
  echo "ING_FIRMWAR=false" >> ${GITHUB_ENV}
else
  echo "ING_FIRMWAR=true" >> ${GITHUB_ENV}
fi
}

function Diy_adguardhome() {
cd ${HOME_PATH}
if [[ `grep -c "CONFIG_ARCH=\"x86_64\"" ${HOME_PATH}/.config` -eq '1' ]]; then
  Arch="linux_amd64"
  Archclash="linux-amd64"
  echo "CPU架构：amd64"
elif [[ `grep -c "CONFIG_ARCH=\"i386\"" ${HOME_PATH}/.config` -eq '1' ]]; then
  Arch="linux_386"
  Archclash="linux-386"
  echo "CPU架构：X86 32"
elif [[ `grep -c "CONFIG_ARCH=\"aarch64\"" ${HOME_PATH}/.config` -eq '1' ]]; then
  Arch="linux_arm64"
  Archclash="linux-arm64"
  echo "CPU架构：arm64"
elif [[ `grep -c "CONFIG_arm_v7=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  Arch="linux_armv7"
  Archclash="linux-armv7"
  echo "CPU架构：armv7"
elif [[ `grep -c "CONFIG_ARCH=\"arm\"" ${HOME_PATH}/.config` -eq '1' ]] && [[ `grep -c "CONFIG_arm_v7=y" ${HOME_PATH}/.config` -eq '0' ]] && [[ `grep "CONFIG_TARGET_ARCH_PACKAGES" "${HOME_PATH}/.config" |grep -c "vfp"` -eq '1' ]]; then
  Arch="linux_armv6"
  Archclash="linux-armv6"
  echo "CPU架构：armv6"
elif [[ `grep -c "CONFIG_ARCH=\"arm\"" ${HOME_PATH}/.config` -eq '1' ]] && [[ `grep -c "CONFIG_arm_v7=y" ${HOME_PATH}/.config` -eq '0' ]] && [[ `grep "CONFIG_TARGET_ARCH_PACKAGES" "${HOME_PATH}/.config" |grep -c "vfp"` -eq '0' ]]; then
  Arch="linux_armv5"
  Archclash="linux-armv5"
  echo "CPU架构：armv6"
elif [[ `grep -c "CONFIG_ARCH=\"mips\"" ${HOME_PATH}/.config` -eq '1' ]]; then
  Arch="linux_mips_softfloat"
  Archclash="linux-mips-softfloat"
  echo "CPU架构：mips"
elif [[ `grep -c "CONFIG_ARCH=\"mips64\"" ${HOME_PATH}/.config` -eq '1' ]]; then
  Arch="linux_mips64_softfloat"
  Archclash="linux-mips64"
  echo "CPU架构：mips64"
elif [[ `grep -c "CONFIG_ARCH=\"mipsel\"" ${HOME_PATH}/.config` -eq '1' ]]; then
  Arch="linux_mipsle_softfloat"
  Archclash="linux-mipsle-softfloat"
  echo "CPU架构：mipsel"
elif [[ `grep -c "CONFIG_ARCH=\"mips64el\"" ${HOME_PATH}/.config` -eq '1' ]]; then
  Arch="linux_mips64le_softfloat"
  Archclash="linux-mips64le"
  echo "CPU架构：mips64el"
else
  echo "不了解您的CPU为何架构"
  weizhicpu="1"
fi

if [[ ! "${weizhicpu}" == "1" ]] && [[ -n "${OpenClash_Core}" ]] && [[ `grep -c "CONFIG_PACKAGE_luci-app-openclash=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ "${wuxuxiazai}" == "1" ]]; then
    echo "已有核心"
  else
    echo "正在执行：给openclash下载核心"
    rm -rf ${HOME_PATH}/files/etc/openclash/core
    rm -rf ${HOME_PATH}/clash-neihe && mkdir -p ${HOME_PATH}/clash-neihe
    mkdir -p ${HOME_PATH}/files/etc/openclash/core
    cd ${HOME_PATH}/clash-neihe
  fi
  if [[ "${OpenClash_Core}" == "2" ]]; then
    wget -q https://raw.githubusercontent.com/vernesong/OpenClash/core/${OpenClash_branch}/meta/clash-${Archclash}.tar.gz -O meta.tar.gz
    wget -q https://raw.githubusercontent.com/vernesong/OpenClash/core/${OpenClash_branch}/dev/clash-${Archclash}.tar.gz -O clash.tar.gz
    wget -q https://raw.githubusercontent.com/vernesong/OpenClash/core/master/core_version -O core_version
    TUN="$(cat core_version |grep -v "^v\|^V|^a" |grep -Eo "[0-9]+.[0-9]+.[0-9]+-[a-zA-Z0-9]+-[a-zA-Z0-9]+")"
    wget -q https://raw.githubusercontent.com/vernesong/OpenClash/core/${OpenClash_branch}/premium/clash-${Archclash}-${TUN}.gz -O clash_tun.gz
    
    tar -zxvf clash.tar.gz -O > clash
    if [[ $? -eq 0 ]];then
      mv -f ${HOME_PATH}/clash-neihe/clash ${HOME_PATH}/files/etc/openclash/core/clash
      sudo chmod +x ${HOME_PATH}/files/etc/openclash/core/clash
      echo "OpenClash增加dev内核成功"
    else
      echo "OpenClash增加dev内核失败"
    fi
    tar -zxvf meta.tar.gz -O > clash_meta
    if [[ $? -eq 0 ]];then
      mv -f ${HOME_PATH}/clash-neihe/clash_meta ${HOME_PATH}/files/etc/openclash/core/clash_meta
      sudo chmod +x ${HOME_PATH}/files/etc/openclash/core/clash_meta
      echo "OpenClash增加meta内核成功"
    else
      echo "OpenClash增加meta内核失败"
    fi
    gzip -d clash_tun.gz
    if [[ $? -eq 0 ]];then
      mv -f ${HOME_PATH}/clash-neihe/clash_tun ${HOME_PATH}/files/etc/openclash/core/clash_tun
      sudo chmod +x ${HOME_PATH}/files/etc/openclash/core/clash_tun
      echo "clash"
      echo "OpenClash增加tun内核成功"
    else
      echo "OpenClash增加tun内核失败"
    fi
  elif [[ "${OpenClash_Core}" == "1" ]]; then
    wget -q https://raw.githubusercontent.com/vernesong/OpenClash/core/${OpenClash_branch}/dev/clash-${Archclash}.tar.gz
    if [[ $? -ne 0 ]];then
      wget -q https://github.com/vernesong/OpenClash/releases/download/Clash/clash-${Archclash}.tar.gz
    else
      echo "OpenClash内核下载成功"
    fi
    tar -zxvf clash-${Archclash}.tar.gz
    if [[ -f "${HOME_PATH}/clash-neihe/clash" ]]; then
      mv -f ${HOME_PATH}/clash-neihe/clash ${HOME_PATH}/files/etc/openclash/core/clash
      sudo chmod +x ${HOME_PATH}/files/etc/openclash/core/clash
      echo "OpenClash增加内核成功"
    else
      echo "OpenClash增加内核失败"
    fi
  else
    echo "无需内核"
  fi
  cd ${HOME_PATH}
  rm -rf ${HOME_PATH}/clash-neihe
fi

if [[ ! "${weizhicpu}" == "1" ]] && [[ "${AdGuardHome_Core}" == "1" ]] && [[ `grep -c "CONFIG_PACKAGE_luci-app-adguardhome=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  echo "正在执行：给adguardhome下载核心"
  rm -rf ${HOME_PATH}/AdGuardHome && rm -rf ${HOME_PATH}/files/usr/bin
  downloader="curl -L -k --retry 2 --connect-timeout 20 -o"
  latest_ver="$($downloader - https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest 2>/dev/null|grep -E 'tag_name' |grep -E 'v[0-9.]+' -o 2>/dev/null)"
  wget -q https://github.com/AdguardTeam/AdGuardHome/releases/download/${latest_ver}/AdGuardHome_${Arch}.tar.gz
  if [[ -f "AdGuardHome_${Arch}.tar.gz" ]]; then
    tar -zxvf AdGuardHome_${Arch}.tar.gz -C ${HOME_PATH}
    echo "核心下载成功"
  else
    echo "下载核心失败"
  fi
  mkdir -p ${HOME_PATH}/files/usr/bin
  if [[ -f "${HOME_PATH}/AdGuardHome/AdGuardHome" ]]; then
    mv -f ${HOME_PATH}/AdGuardHome/AdGuardHome ${HOME_PATH}/files/usr/bin/
    sudo chmod +x ${HOME_PATH}/files/usr/bin/AdGuardHome
    echo "增加AdGuardHome核心完成"
  else
    echo "增加AdGuardHome核心失败"
  fi
    rm -rf ${HOME_PATH}/{AdGuardHome_${Arch}.tar.gz,AdGuardHome}
fi
}


function Diy_upgrade2() {
cd ${HOME_PATH}
sed -i 's/^[ ]*//g' "${DEFAULT_PATH}"
sed -i '$a\exit 0' "${DEFAULT_PATH}"
sed -i 's/^[ ]*//g' "${ZZZ_PATH}"
sed -i '$a\exit 0' "${ZZZ_PATH}" 

if [[ "${UPDATE_FIRMWARE_ONLINE}" == "true" ]]; then
  source ${BUILD_PATH}/upgrade.sh && Diy_Part2
fi
}


function openwrt_armvirt() {
cd ${GITHUB_WORKSPACE}
export FOLDER_NAME2="${GITHUB_WORKSPACE}/REPOSITORY"
export RELEVANCE="${FOLDER_NAME2}/build/${FOLDER_NAME}/relevance"

git clone -b main https://github.com/${GIT_REPOSITORY}.git ${FOLDER_NAME2}
if [[ ! -d "${RELEVANCE}" ]]; then
  mkdir -p "${RELEVANCE}"
fi

export YML_PATH="${FOLDER_NAME2}/.github/workflows/packaging.yml"
cp -Rf ${GITHUB_WORKSPACE}/.github/workflows/packaging.yml ${YML_PATH}
export PATHS1="$(grep -A 5 'paths:' "${YML_PATH}" |sed 's/^[ ]*//g' |grep -v "^#" |grep -Eo "\- '.*'" |cut -d"'" -f2 |awk 'NR==1')"
export PATHS2="build/${FOLDER_NAME}/relevance/${SOURCE}start"
export SOURCE_NAME1="$(grep 'SOURCE:' "${YML_PATH}"|sed 's/^[ ]*//g' |grep -v "^#" |awk 'NR==1')"
export SOURCE_NAME2="SOURCE: ${SOURCE}"
export ER_NAME1="$(grep 'FOLDER_NAME:' "${YML_PATH}"|sed 's/^[ ]*//g' |grep -v "^#" |awk 'NR==1')"
export ER_NAME2="FOLDER_NAME: ${FOLDER_NAME}"


if [[ -n "${PATHS1}" ]] && [[ -n "${ER_NAME1}" ]] && [[ -n "${SOURCE_NAME1}" ]]; then
  sed -i "s?${PATHS1}?${PATHS2}?g" "${YML_PATH}"
  sed -i "s?${ER_NAME1}?${ER_NAME2}?g" "${YML_PATH}"
  sed -i "s?${SOURCE_NAME1}?${SOURCE_NAME2}?g" "${YML_PATH}"
else
  echo "获取变量失败,请勿胡乱修改pack_armvirt.yml文件"
  exit 1
fi

cat >"${RELEVANCE}/${SOURCE}start" <<-EOF
Trigger packaging ${FOLDER_NAME} program-$(date +%Y%m%d%H%M%S)
EOF

cat >"${RELEVANCE}/${SOURCE}.ini" <<-EOF
amlogic_model="${amlogic_model}"
amlogic_kernel="${amlogic_kernel}"
auto_kernel="${auto_kernel}"
rootfs_size="${rootfs_size}"
kernel_repo="${kernel_repo}"
kernel_usage="${kernel_usage}"
FOLDER_NAME="${FOLDER_NAME}"
SOURCE="${SOURCE}"
UPLOAD_FIRMWARE="${UPLOAD_FIRMWARE}"
UPLOAD_RELEASE="${UPLOAD_RELEASE}"
UPLOAD_WETRANSFER="${UPLOAD_WETRANSFER}"
EOF

chmod -R +x ${FOLDER_NAME2}
cd ${FOLDER_NAME2}
git add .
git commit -m "启动打包amlogic固件(${SOURCE}-${LUCI_EDITION})"
git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:main
}

function firmware_jiance() {
if [[ "${TARGET_PROFILE}" == "Armvirt_64" ]] && [[ `ls -1 "${FIRMWARE_PATH}" |grep -c ".*.tar.gz"` -eq '1' ]] && [[ "${PACKAGING_FIRMWARE}" == "true" ]]; then
  mkdir -p "${HOME_PATH}/targz"
  cp -rf ${FIRMWARE_PATH}/*.tar.gz ${HOME_PATH}/targz/${SOURCE}-armvirt-64-default-rootfs.tar.gz
elif [[ "${TARGET_PROFILE}" == "Armvirt_64" ]] && [[ `ls -1 "${FIRMWARE_PATH}" |grep -c ".*.tar.gz"` -eq '0' ]] && [[ "${PACKAGING_FIRMWARE}" == "true" ]]; then
  echo "PACKAGING_FIRMWARE=false" >> ${GITHUB_ENV}
  TIME r "没发现armvirt-64-default-rootfs.tar.gz包存在，关闭自动打包操作"
fi
}

function Package_amlogic() {
echo "正在执行：打包N1和景晨系列固件"
# 下载上游仓库
cd ${GITHUB_WORKSPACE}
[[ -d "${GITHUB_WORKSPACE}/amlogic" ]] && sudo rm -rf ${GITHUB_WORKSPACE}/amlogic
[[ ! -d "${HOME_PATH}/bin/targets/armvirt/64" ]] && mkdir -p "${HOME_PATH}/bin/targets/armvirt/64"
export FIRMWARE_PATH="${HOME_PATH}/bin/targets/armvirt/64"
[[ -z "${amlogic_model}" ]] && export amlogic_model="s905d"
[[ -z "${auto_kernel}" ]] && export auto_kernel="true"
[[ -z "${rootfs_size}" ]] && export rootfs_size="2560"
export kernel_repo="ophub/kernel"
[[ -z "${kernel_usage}" ]] && export kernel_usage="stable"
[[ -z "${UPLOAD_WETRANSFER}" ]] && export UPLOAD_WETRANSFER="true"
if [[ -z "${amlogic_kernel}" ]]; then
  curl -fsSL https://github.com/281677160/common/releases/download/API/${kernel_usage}.api -o ${HOME_PATH}/${kernel_usage}.api
  export amlogic_kernel="$(grep -Eo '"name": "[0-9]+\.[0-9]+\.[0-9]+\.tar.gz"' ${HOME_PATH}/${kernel_usage}.api |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+" |awk 'END {print}' |sed s/[[:space:]]//g)"
  [[ -z "${amlogic_kernel}" ]] && export amlogic_kernel="5.10.170"
fi
export gh_token="${REPO_TOKEN}"

echo "芯片型号：${amlogic_model}"
echo "使用内核：${amlogic_kernel}"
echo "自动检测：${auto_kernel}"
echo "rootfs大小：${rootfs_size}"
echo "内核仓库：${kernel_usage}"

git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git ${GITHUB_WORKSPACE}/amlogic
[ ! -d ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt ] && mkdir -p ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt
if [[ `ls -1 "${FIRMWARE_PATH}" |grep -c ".*.tar.gz"` -eq '1' ]]; then
  cp -Rf ${FIRMWARE_PATH}/*.tar.gz ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz && sync
else
  curl -H "Authorization: Bearer ${REPO_TOKEN}" https://api.github.com/repos/${GIT_REPOSITORY}/releases/tags/targz -o targz.api
  if [[ $? -ne 0 ]];then
    TIME r "下载api失败"
    exit 1
  fi
  if [[ `grep -c "${SOURCE}-armvirt-64-default-rootfs.tar.gz" "targz.api"` -eq '0' ]]; then
    TIME r "该链接 https://github.com/${GIT_REPOSITORY}/releases/tag/targz"
    TIME r "不存在 ${SOURCE}-armvirt-64-default-rootfs.tar.gz 包"
    exit 1
  else
    wget -q https://github.com/${GIT_REPOSITORY}/releases/download/targz/${SOURCE}-armvirt-64-default-rootfs.tar.gz -O ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz
  fi
  if [[ $? -ne 0 ]];then
    TIME r "下载rootfs.tar.gz包失败,请检查网络"
    exit 1
  fi
fi

if [[ `ls -1 "${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt" |grep -c ".*default-rootfs.tar.gz"` -eq '1' ]]; then
  mkdir -p ${GITHUB_WORKSPACE}/amlogic/temp_dir
  cp -Rf ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/*default-rootfs.tar.gz ${GITHUB_WORKSPACE}/amlogic/temp_dir/openwrt-armvirt-64-default-rootfs.tar.gz && sync
  tar -xzf ${GITHUB_WORKSPACE}/amlogic/temp_dir/openwrt-armvirt-64-default-rootfs.tar.gz -C amlogic/temp_dir/
  if [[ `grep -c "DISTRIB_SOURCECODE" ${GITHUB_WORKSPACE}/amlogic/temp_dir/etc/openwrt_release` -eq '1' ]]; then
    source_codename="$(cat "${GITHUB_WORKSPACE}/amlogic/temp_dir/etc/openwrt_release" 2>/dev/null | grep -oE "^DISTRIB_SOURCECODE=.*" | head -n 1 | cut -d"'" -f2)"
    echo "source_codename=${source_codename}" >> ${GITHUB_ENV}
    sudo rm -rf ${GITHUB_WORKSPACE}/amlogic/temp_dir
  else
    source_codename="armvirt"
    echo "source_codename=${source_codename}" >> ${GITHUB_ENV}
    sudo rm -rf ${GITHUB_WORKSPACE}/amlogic/temp_dir
  fi
else
  TIME r "没发现openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
  exit 1
fi

echo "开始打包"
cd ${GITHUB_WORKSPACE}/amlogic
sudo chmod +x make
if [[ -z "${gh_token}" ]]; then
  sudo ./make -b ${amlogic_model} -k ${amlogic_kernel} -a ${auto_kernel} -s ${rootfs_size} -r ${kernel_repo} -u ${kernel_usage}
else
  sudo ./make -b ${amlogic_model} -k ${amlogic_kernel} -a ${auto_kernel} -s ${rootfs_size} -r ${kernel_repo} -u ${kernel_usage} -g ${gh_token}
fi
if [[ 0 -eq $? ]]; then
  sudo mv -f ${GITHUB_WORKSPACE}/amlogic/out/* ${FIRMWARE_PATH}/ && sync
  sudo rm -rf ${GITHUB_WORKSPACE}/amlogic
  echo "FIRMWARE_PATH=${FIRMWARE_PATH}" >> ${GITHUB_ENV}
  TIME g "固件打包完成,已将固件存入${FIRMWARE_PATH}文件夹内"
else
  TIME r "固件打包失败"
fi
}


function Diy_upgrade3() {
if [ "${UPDATE_FIRMWARE_ONLINE}" == "true" ]; then
  cd ${HOME_PATH}
  source ${BUILD_PATH}/upgrade.sh && Diy_Part3
fi
}


function Diy_organize() {
Diy_xinxi1
cd ${FIRMWARE_PATH}
if [[ -d "${PACKAGED_OUTPUTPATH}" ]]; then
  sudo mv -f ${PACKAGED_OUTPUTPATH}/* ${FIRMWARE_PATH}/ && sync
fi
mkdir -p ipk
cp -rf $(find ${HOME_PATH}/bin/packages/ -type f -name "*.ipk") ipk/ && sync
sudo tar -czf ipk.tar.gz ipk && sync && sudo rm -rf ipk
if [[ `ls -1 | grep -c "immortalwrt"` -ge '1' ]]; then
  rename -v "s/^immortalwrt/openwrt/" *
fi

for X in $(cat ${CLEAR_PATH} |sed "s/.*${TARGET_BOARD}//g"); do
  rm -rf *"$X"*
done

if [[ `ls -1 | grep -c "armvirt"` -eq '0' ]]; then
  rename -v "s/^openwrt/${Gujian_Date}-${SOURCE}-${LUCI_EDITION}-${LINUX_KERNEL}/" *
fi
sudo rm -rf "${CLEAR_PATH}"
}


function Diy_firmware() {
echo "正在执行：整理固件,您不想要啥就删啥,删删删"
echo "需要配合${DIY_PART_SH}文件设置使用"
echo
if [[ "${PACKAGING_FIRMWARE}" == "true" ]] && [[ -z "${BENDI_VERSION}" ]]; then
  # 打包固件转换仓库
  openwrt_armvirt
fi
Diy_upgrade3
Diy_organize
}

function Diy_xinxi1() {
export KERNEL_PATCH="$(grep "KERNEL_PATCHVER" "${HOME_PATH}/target/linux/${TARGET_BOARD}/Makefile" |grep -Eo "[0-9.]+")"
export KERNEL_patc="kernel-${KERNEL_PATCH}"
if [[ `ls -1 "${HOME_PATH}/include" |grep -c "${KERNEL_patc}"` -eq '1' ]]; then
  export LINUX_KERNEL="$(grep "LINUX_KERNEL_HASH" "${HOME_PATH}/include/${KERNEL_patc}" |sed s/[[:space:]]//g |cut -d '-' -f2 |cut -d '=' -f1)"
  [[ -z ${LINUX_KERNEL} ]] && export LINUX_KERNEL="nono"
else
  export LINUX_KERNEL="$(grep "LINUX_KERNEL_HASH" "${HOME_PATH}/include/kernel-version.mk" |grep -Eo "${KERNEL_PATCH}\.[0-9]+")"
  [[ -z ${LINUX_KERNEL} ]] && export LINUX_KERNEL="nono"
fi

echo "LINUX_KERNEL=${LINUX_KERNEL}" >> ${GITHUB_ENV}
}


function Diy_xinxi() {
Diy_xinxi1
Plug_in="$(grep 'CONFIG_PACKAGE_luci-app' ${HOME_PATH}/.config && grep 'CONFIG_PACKAGE_luci-theme' ${HOME_PATH}/.config)"
Plug_in2="$(echo "${Plug_in}" | grep -v '^#' |sed '/INCLUDE/d' |sed '/=m/d' |sed '/_Transparent_Proxy/d' |sed '/qbittorrent_static/d' |sed 's/CONFIG_PACKAGE_//g' |sed 's/=y//g' |sed 's/^/、/g' |sed 's/$/\"/g' |awk '$0=NR$0' |sed 's/^/TIME g \"       /g')"
echo "${Plug_in2}" >Plug-in
sed -i '/luci-app-qbittorrent-simple_dynamic/d' Plug-in > /dev/null 2>&1

if [[ `grep -c "CONFIG_GRUB_EFI_IMAGES=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  export EFI_NO="1"
else
  export EFI_NO="0"
fi

echo
TIME b "编译源码: ${SOURCE}"
TIME b "源码链接: ${REPO_URL}"
TIME b "源码分支: ${REPO_BRANCH}"
TIME b "源码作者: ${SOURCE_OWNER}"
TIME b "Luci版本: ${LUCI_EDITION}"
if [[ "${AMLOGIC_CODE}" == "AMLOGIC" ]]; then
  TIME b "编译机型: 晶晨系列"
  if [[ "${PACKAGING_FIRMWARE}" == "true" ]]; then
     TIME g "打包机型: ${amlogic_model}"
     TIME g "打包内核: ${amlogic_kernel}"
     TIME g "分区大小: ${rootfs_size}"
     if [[ "${auto_kernel}" == "true" ]]; then
       TIME g "自动检测最新内核: 是"
     else
       TIME g "自动检测最新内核: 不是"
     fi
  else
     TIME b "内核版本: ${LINUX_KERNEL}"
     TIME r "自动打包: 没开启自动打包设置"
  fi
else
  TIME b "内核版本: ${LINUX_KERNEL}"
  TIME b "编译机型: ${TARGET_PROFILE}"
fi
TIME b "固件作者: ${GIT_ACTOR}"
TIME b "仓库地址: ${GITHUB_LINK}"
TIME b "启动编号: #${RUN_NUMBER}（${WAREHOUSE_MAN}仓库第${RUN_NUMBER}次启动[${RUN_WORKFLOW}]工作流程）"
TIME b "编译时间: ${Compte_Date}"
if [[ "${SOURCE_CODE}" == "AMLOGIC" && "${PACKAGING_FIRMWARE}" == "true" ]]; then
  TIME g "友情提示：您当前使用【${FOLDER_NAME}】文件夹编译【${amlogic_model}】固件"
else
  TIME g "友情提示：您当前使用【${FOLDER_NAME}】文件夹编译【${TARGET_PROFILE}】固件"
fi
echo
echo
if [[ ${INFORMATION_NOTICE} == "TG" ]] || [[ ${INFORMATION_NOTICE} == "PUSH" ]]; then
  TIME y "pushplus/Telegram通知: 开启"
else
  TIME r "pushplus/Telegram通知: 关闭"
fi
if [[ ${UPLOAD_FIRMWARE} == "true" ]]; then
  TIME y "上传固件在github actions: 开启"
else
  TIME r "上传固件在github actions: 关闭"
fi
if [[ ${UPLOAD_RELEAS} == "true" ]]; then
  TIME y "发布固件(Releases): 开启"
else
  TIME r "发布固件(Releases): 关闭"
fi
if [[ ${CACHEWRTBUILD_SWITCH} == "true" ]]; then
  TIME y "是否开启缓存加速: 开启"
else
  TIME r "是否开启缓存加速: 关闭"
fi
if [[ ${COLLECTED_PACKAGES} == "true" ]]; then
  TIME y "是否加入作者收集的插件包: 开启"
else
  TIME r "是否加入作者收集的插件包: 关闭"
fi
if [[ ${UPLOAD_WETRANSFER} == "true" ]]; then
  TIME y "上传固件至【WETRANSFER】: 开启"
else
  TIME r "上传固件至【WETRANSFER】: 关闭"
fi
if [[ ${COMPILATION_INFORMATION} == "true" ]]; then
  TIME y "编译信息显示: 开启"
fi
if [[ ${AMLOGIC_CODE} == "AMLOGIC" ]]; then
  if [[ ${PACKAGING_FIRMWARE} == "true" ]]; then
    TIME y "N1和晶晨系列固件自动打包成 .img 固件: 开启"
  else
    TIME r "N1和晶晨系列固件自动打包成 .img 固件: 关闭"
  fi
else
  if [[ ${UPDATE_FIRMWARE_ONLINE} == "true" ]]; then
    TIME y "把定时自动更新插件编译进固件: 开启"
  else
    TIME r "把定时自动更新插件编译进固件: 关闭"
  fi
fi
if [[ "${UPDATE_FIRMWARE_ONLINE}" == "true" ]] && [[ -z "${REPO_TOKEN}" ]]; then
  echo
  echo
  TIME r "您虽然开启了编译在线更新固件操作,但是您的[REPO_TOKEN]密匙为空,"
  TIME r "无法将固件发布至云端,已为您自动关闭了编译在线更新固件"
  echo
elif [[ "${UPDATE_FIRMWARE_ONLINE}" == "true" ]] && [[ -n "${REPO_TOKEN}" ]]; then
  echo
  TIME l "定时自动更新信息"
  TIME z "插件版本: ${AutoUpdate_Version}"
  if [[ ${TARGET_BOARD} == "x86" ]]; then
    TIME b "传统固件: ${AutoBuild_Legacy}${Firmware_SFX}"
    [[ "${EFI_NO}" == "1" ]] && TIME b "UEFI固件: ${AutoBuild_Uefi}${Firmware_SFX}"
  else
    TIME b "固件名称: ${AutoBuild_Firmware}${Firmware_SFX}"
  fi
  TIME b "固件后缀: ${Firmware_SFX}"
  TIME b "固件版本: ${Openwrt_Version}"
  TIME b "云端路径: ${Github_Release}"
  TIME g "《编译成功后，会自动把固件发布到指定地址，然后才会生成云端路径》"
  TIME g "《普通的那个发布固件跟云端的发布路径是两码事，如果你不需要普通发布的可以不用打开发布功能》"
  TIME g "修改IP、DNS、网关或者在线更新，请输入命令：openwrt"
  echo
else
  echo
fi
echo
TIME z " 系统空间      类型   总数  已用  可用 使用率"
df -hT $PWD
echo
echo

if [[ -s "${HOME_PATH}/CHONGTU" ]]; then
  echo
  echo
  TIME b "			错误信息"
  echo
  chmod -R +x ${HOME_PATH}/CHONGTU
  source ${HOME_PATH}/CHONGTU
fi
rm -rf ${HOME_PATH}/CHONGTU
if [ -n "$(ls -A "${HOME_PATH}/Plug-in" 2>/dev/null)" ]; then
  echo
  echo
  TIME r "	      已选插件列表"
  chmod -R +x ${HOME_PATH}/Plug-in
  source ${HOME_PATH}/Plug-in
  rm -rf ${HOME_PATH}/{Plug-in,Plug-2}
  echo
fi
}

function Diy_menu5() {
Diy_prevent
Make_defconfig
Diy_Publicarea2
Diy_adguardhome
Diy_upgrade2
}

function Diy_menu4() {
Diy_files
Diy_shpart
Diy_Language
Diy_feeds
Diy_IPv6helper
}

function Diy_menu3() {
Diy_wenjian1
Diy_wenjian2
Diy_${SOURCE_CODE}
Diy_distrib
Diy_chajianyuan
Diy_upgrade1
}

function Diy_menu2() {
Diy_Notice
}

function Diy_menu1() {
Diy_variable
Diy_settings
}
