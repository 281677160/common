#!/bin/bash
# https://github.com/281677160/build-actions
# common Module by 28677160
# matrix.target=${FOLDER_NAME}
export TONGBU_YUANMA=""

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

function Diy_one() {
cd ${GITHUB_WORKSPACE}
if [[ -n "${BENDI_VERSION}" ]] && [[ ! -d "${OPERATES_PATH}" ]]; then
  TIME r "缺少编译主文件,正在同步上游仓库"
  if git clone --single-branch --depth=1 --branch=main https://github.com/281677160/build-actions shangyou; then
    cp -Rf shangyou/build ${OPERATES_PATH}
    rm -rf shangyou
    chmod -R +x ${OPERATES_PATH}
    for X in $(find "${OPERATES_PATH}" -name "settings.ini"); do
      sed -i '/SSH_ACTIONS/d' "${X}"
      sed -i '/INFORMATION_NOTICE/d' "${X}"
      sed -i '/UPLOAD_FIRMWARE/d' "${X}"
      sed -i '/UPLOAD_RELEASE/d' "${X}"
      sed -i '/CACHEWRTBUILD_SWITCH/d' "${X}"
      sed -i '/COMPILATION_INFORMATION/d' "${X}"
      sed -i '/UPDATE_FIRMWARE_ONLINE/d' "${X}"
      sed -i '/RETAIN_DAYS/d' "${X}"
      sed -i '/RETAIN_MINUTE/d' "${X}"
      sed -i '/KEEP_LATEST/d' "${X}"
      echo 'PACKAGING_FIRMWARE="true"           # 自动把Amlogic_Rockchip系列固件,打包成.img格式（true=开启）（false=关闭）' >> "${X}"
      echo 'MODIFY_CONFIGURATION="true"         # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "${X}"
    done
    TIME g "同步上游仓库完成"
    export TONGBU_YUANMA="YES"
  else
    TIME r "同步上游仓库失败,注意网络环境,请重新再运行命令试试"
    exit 1
  fi
else
  if [[ -d "build" ]]; then
    rm -rf ${OPERATES_PATH}
    cp -Rf build ${OPERATES_PATH}
  fi
fi
}

function Diy_two() {
cd ${GITHUB_WORKSPACE}
if [[ ! -d "${OPERATES_PATH}" ]]; then
  echo -e "\033[31m 根目录缺少编译必要文件夹 \033[0m"
  SYNCHRONISE="NO"
  tongbu_message="根目录缺少编译必要文件夹"
elif [[ ! -d "${COMPILE_PATH}" ]]; then
  echo -e "\033[31m 缺少${COMPILE_PATH}文件夹 \033[0m"
  SYNCHRONISE="NO"
  tongbu_message="缺少编译必要文件夹"
elif [[ ! -f "${BUILD_PARTSH}" ]]; then
  echo -e "\033[31m 缺少${BUILD_PARTSH}文件 \033[0m"
  SYNCHRONISE="NO"
  tongbu_message="缺少文件"
elif [[ ! -f "${BUILD_SETTINGS}" ]]; then
  echo -e "\033[31m 缺少${BUILD_SETTINGS}文件 \033[0m"
  SYNCHRONISE="NO"
  tongbu_message="缺少文件"
elif [[ ! -f "${COMPILE_PATH}/relevance/actions_version" ]]; then
  echo -e "\033[31m 缺少relevance/actions_version文件 \033[0m"
  SYNCHRONISE="NO"
  tongbu_message="缺少文件"
elif [[ -f "${COMPILE_PATH}/relevance/actions_version" ]]; then
  curl -fsSL https://raw.githubusercontent.com/281677160/common/ceshi/common.sh -o common.sh
  ACTIONS_VERSION1="$(sed -nE 's/^[[:space:]]*ACTIONS_VERSION[[:space:]]*=[[:space:]]*"?([0-9.]+)"?.*/\1/p' common.sh)"
  ACTIONS_VERSION2="$(sed -nE 's/^[[:space:]]*ACTIONS_VERSION[[:space:]]*=[[:space:]]*"?([0-9.]+)"?.*/\1/p' ${COMPILE_PATH}/relevance/actions_version)"
  rm -rf common.sh
  if [[ ! "${ACTIONS_VERSION1}" == "${ACTIONS_VERSION2}" ]]; then
    echo -e "\033[31m 和上游版本不一致 \033[0m"
    SYNCHRONISE="NO"
    tongbu_message="和上游版本不一致"
  fi
else
  SYNCHRONISE="YES"
fi
}

function Diy_three() {
cd ${GITHUB_WORKSPACE}
if [[ "${SYNCHRONISE}" == "NO" ]]; then
  if [[ -n "${BENDI_VERSION}" ]]; then
    TIME r "${tongbu_message},正在同步上游仓库"
    if git clone --single-branch --depth=1 --branch=main https://github.com/281677160/build-actions shangyou; then
      if [[ -d "${OPERATES_PATH}" ]]; then
        mv ${OPERATES_PATH} backups
        cp -Rf shangyou/build ${OPERATES_PATH}
        mv backups ${OPERATES_PATH}/backups
        rm -rf shangyou
      else
        cp -Rf shangyou/build ${OPERATES_PATH}
        rm -rf shangyou
      fi
      chmod -R +x ${OPERATES_PATH}
      for X in $(find "${OPERATES_PATH}" -name "settings.ini"); do
        sed -i '/SSH_ACTIONS/d' "${X}"
        sed -i '/INFORMATION_NOTICE/d' "${X}"
        sed -i '/UPLOAD_FIRMWARE/d' "${X}"
        sed -i '/UPLOAD_RELEASE/d' "${X}"
        sed -i '/CACHEWRTBUILD_SWITCH/d' "${X}"
        sed -i '/COMPILATION_INFORMATION/d' "${X}"
        sed -i '/UPDATE_FIRMWARE_ONLINE/d' "${X}"
        sed -i '/RETAIN_DAYS/d' "${X}"
        sed -i '/RETAIN_MINUTE/d' "${X}"
        sed -i '/KEEP_LATEST/d' "${X}"
        echo 'PACKAGING_FIRMWARE="true"           # 自动把Amlogic_Rockchip系列固件,打包成.img格式（true=开启）（false=关闭）' >> "${X}"
        echo 'MODIFY_CONFIGURATION="true"         # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "${X}"
      done
      TIME g "同步上游仓库完成"
      export TONGBU_YUANMA="YES"
    else
      TIME r "同步上游仓库失败,注意网络环境,请重新再运行命令试试"
      exit 1
    fi
  else
    git clone -b ${GIT_REFNAME} https://user:${REPO_TOKEN}@github.com/${GIT_REPOSITORY}.git repogx
    git clone -q --single-branch --depth=1 --branch=main https://github.com/281677160/build-actions shangyou
    find . -type d -name "backups" -exec sudo rm -rf {} \;
    mkdir -p backups
    cp -Rf repogx/* backups
    cp -Rf repogx/.github/workflows backups/workflows
    cd repogx
    rm -rf *
    git rm --cache *
    cd ../
    mkdir -p repogx/.github/workflows
    cp -Rf shangyou/* repogx
    cp -Rf shangyou/.github/workflows/* repogx/.github/workflows
    cp -Rf backups repogx/backups
    BANBEN_SHUOMING="同步上游于 $(date +%Y.%m%d.%H%M.%S)"
    chmod -R +x repogx
    cd repogx
    git add .
    git commit -m "${BANBEN_SHUOMING}"
    git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:${GIT_REFNAME}
    if [[ $? -ne 0 ]]; then
      echo -e "\033[31m 同步上游仓库失败,请注意密匙是否正确 \033[0m"
    else
      echo -e "\033[33m 同步上游仓库完成,请重新设置好文件再继续编译 \033[0m"
    fi
    exit 1
  fi
fi
}

function Diy_four() {
rm -rf ${OPERATES_PATH}/common
mkdir -p ${OPERATES_PATH}/common
curl -fsSL https://raw.githubusercontent.com/281677160/common/ceshi/common.sh -o ${OPERATES_PATH}/common/common.sh
curl -fsSL https://raw.githubusercontent.com/281677160/common/ceshi/upgrade.sh -o ${OPERATES_PATH}/common/upgrade.sh
export COMMON_SH="${OPERATES_PATH}/common/common.sh"
export UPGRADE_SH="${OPERATES_PATH}/common/upgrade.sh"
export CONFIG_TXT="${OPERATES_PATH}/common/config.txt"
if grep -q "TIME" "${COMMON_SH}" && grep -q "Diy_Part2" "${UPGRADE_SH}"; then
  cp -Rf ${COMPILE_PATH} ${OPERATES_PATH}/common/${FOLDER_NAME}
  export DIY_PT_SH=${OPERATES_PATH}/common/${FOLDER_NAME}/diy-part.sh
else
  echo -e "\033[31m common文件下载失败 \033[0m"
  exit 1
fi

export TWO_SH="${OPERATES_PATH}/common/${FOLDER_NAME}/two.sh"
export BUILD_PARTSH="${DIY_PT_SH}"
echo "BUILD_PARTSH=${DIY_PT_SH}" >> ${GITHUB_ENV}
echo "COMMON_SH=${COMMON_SH}" >> ${GITHUB_ENV}
echo "UPGRADE_SH=${UPGRADE_SH}" >> ${GITHUB_ENV}
echo "CONFIG_TXT=${CONFIG_TXT}" >> ${GITHUB_ENV}

sed -i 's/^[[:space:]]*//' $DIY_PT_SH

echo '#!/bin/sh' > ${TWO_SH}
grep -E 'grep -rl '.*'.*|.*xargs -r sed' $DIY_PT_SH >> ${TWO_SH}
sed -i '$a\exit 0' ${TWO_SH}
grep -vE '^[[:space:]]*grep -rl '.*'.*|.*xargs -r sed' $DIY_PT_SH > tmp && mv tmp $DIY_PT_SH

chmod -R +x ${OPERATES_PATH}
}

function Diy_memu() {
TIME y "正在执行：判断文件是否缺失"
Diy_one
Diy_two
Diy_three
Diy_four
}

Diy_memu "$@"
