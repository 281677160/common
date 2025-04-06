#!/bin/bash
# https://github.com/281677160/build-actions
# common Module by 28677160
# matrix.target=${FOLDER_NAME}

function Diy_one() {
echo "${OPER_ATES}"
echo "${FOLDER_NAME}"
cd ${GITHUB_WORKSPACE}
if [[ -n "${BENDI_VERSION}" ]] && [[ ! -d "${OPER_ATES}" ]]; then
  git clone -q --single-branch --depth=1 --branch=main https://github.com/281677160/build-actions shangyou
  cp -Rf shangyou/build ${OPER_ATES}
  rm -rf shangyou
  chmod -R +x ${OPER_ATES}
  for X in $(find "${OPER_ATES}" -name "settings.ini"); do
    sed -i '/SSH_ACTIONS/d' "${X}"
    sed -i '/INFORMATION_NOTICE/d' "${X}"
    sed -i '/UPLOAD_FIRMWARE/d' "${X}"
    sed -i '/UPLOAD_RELEASE/d' "${X}"
    sed -i '/CACHEWRTBUILD_SWITCH/d' "${X}"
    sed -i '/COMPILATION_INFORMATION/d' "${X}"
    sed -i '/UPDATE_FIRMWARE_ONLINE/d' "${X}"
    sed -i '/RETAIN_DAYS/d' "${X}"
    sed -i '/KEEP_LATEST/d' "${X}"
    echo 'PACKAGING_FIRMWARE="true"           # 自动把Amlogic_Rockchip系列固件,打包成.img格式（true=开启）（false=关闭）' >> "${X}"
    echo 'MODIFY_CONFIGURATION="true"         # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "${X}"
    echo 'WSL_ROUTEPATH="false"               # 关闭询问改变WSL路径（true=开启）（false=关闭）' >> "${X}"
  done
else
  if [[ -d "build" ]]; then
    rm -rf ${OPER_ATES}
    cp -Rf build ${OPER_ATES}
  fi
fi
}

function Diy_two() {
cd ${GITHUB_WORKSPACE}
curl -fsSL https://raw.githubusercontent.com/281677160/common/main/common.sh -o common.sh
if [[ ! -d "${OPER_ATES}" ]]; then
  echo -e "\033[31m 根目录缺少编译必要文件夹存在 \033[0m"
  SYNCHRONISE="NO"
elif [[ ! -d "${FOLDER_NAME}" ]]; then
  echo -e "\033[31m 缺少${FOLDER_NAME}文件夹 \033[0m"
  SYNCHRONISE="NO"
elif [[ ! -f "${BUILD_PARTSH}" ]]; then
  echo -e "\033[31m 缺少${BUILD_PARTSH}文件 \033[0m"
  SYNCHRONISE="NO"
elif [[ ! -f "${BUILD_SETTINGS}" ]]; then
  echo -e "\033[31m 缺少${BUILD_SETTINGS}文件 \033[0m"
  SYNCHRONISE="NO"
elif [[ ! -f "${FOLDER_NAME}/relevance/actions_version" ]]; then
  echo -e "\033[31m 缺少relevance/actions_version文件 \033[0m"
  SYNCHRONISE="NO"
elif [[ -f "${FOLDER_NAME}/relevance/actions_version" ]]; then
  ACTIONS_VERSION1="$(sed -nE 's/^[[:space:]]*ACTIONS_VERSION[[:space:]]*=[[:space:]]*"?([0-9.]+)"?.*/\1/p' common.sh)"
  ACTIONS_VERSION2="$(sed -nE 's/^[[:space:]]*ACTIONS_VERSION[[:space:]]*=[[:space:]]*"?([0-9.]+)"?.*/\1/p' ${FOLDER_NAME}/relevance/actions_version)"
  if [[ ! "${ACTIONS_VERSION1}" == "${ACTIONS_VERSION2}" ]]; then
    echo -e "\033[31m 和上游版本不一致 \033[0m"
    SYNCHRONISE="NO"
  fi
else
  SYNCHRONISE="YES"
fi
}

function Diy_three() {
cd ${GITHUB_WORKSPACE}
if [[ "${SYNCHRONISE}" == "NO" ]]; then
  if [[ -n "${BENDI_VERSION}" ]]; then
    git clone -q --single-branch --depth=1 --branch=main https://github.com/281677160/build-actions shangyou
    if [[ -d "${OPER_ATES}" ]]; then
      mv ${OPER_ATES} backups
      cp -Rf shangyou/build ${OPER_ATES}
      mv backups ${OPER_ATES}/backups
      rm -rf shangyou
    else
      cp -Rf shangyou/build ${OPER_ATES}
      rm -rf shangyou
    fi
    chmod -R +x ${OPER_ATES}
    for X in $(find "${OPER_ATES}" -name "settings.ini"); do
      sed -i '/SSH_ACTIONS/d' "${X}"
      sed -i '/INFORMATION_NOTICE/d' "${X}"
      sed -i '/UPLOAD_FIRMWARE/d' "${X}"
      sed -i '/UPLOAD_RELEASE/d' "${X}"
      sed -i '/CACHEWRTBUILD_SWITCH/d' "${X}"
      sed -i '/COMPILATION_INFORMATION/d' "${X}"
      sed -i '/UPDATE_FIRMWARE_ONLINE/d' "${X}"
      sed -i '/RETAIN_DAYS/d' "${X}"
      sed -i '/KEEP_LATEST/d' "${X}"
      echo 'PACKAGING_FIRMWARE="true"           # 自动把Amlogic_Rockchip系列固件,打包成.img格式（true=开启）（false=关闭）' >> "${X}"
      echo 'MODIFY_CONFIGURATION="true"         # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "${X}"
      echo 'WSL_ROUTEPATH="false"               # 关闭询问改变WSL路径（true=开启）（false=关闭）' >> "${X}"
    done
  else
    git clone -b ${GIT_REFNAME} https://user:${REPO_TOKEN}@github.com/${GIT_REPOSITORY}.git repogx
    git clone -q --single-branch --depth=1 --branch=main https://github.com/281677160/autobuild shangyou
    if [[ -d "repogx/build" ]]; then
      cp -Rf repogx/build shangyou/backups
    fi
    cd repogx
    rm -rf *
    git rm --cache *
    cd ../
    cp -Rf shangyou/* repogx
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

function Diy_memu() {
Diy_one
Diy_two
Diy_three
}

Diy_memu "$@"
