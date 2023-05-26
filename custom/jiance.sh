#!/bin/bash
# https://github.com/281677160/build-actions
# common Module by 28677160
# matrix.target=${FOLDER_NAME}
cd ${GITHUB_WORKSPACE}

function Diy_continue() {
rm -rf upcommon
git clone -b main --depth 1 https://github.com/281677160/common build/common
mv -f build/common/upgrade.sh build/${FOLDER_NAME}/upgrade.sh
mv -f build/common/xiugai.sh build/${FOLDER_NAME}/common.sh
sudo chmod -R +x build
}

function Diy_synchronise() {
export TONGBU_CANGKU="1"
export GIT_REPOSITORY="${GIT_REPOSITORY}"
export REPO_TOKEN="${REPO_TOKEN}"
cp -Rf ${GITHUB_WORKSPACE}/upcommon/bendi/tongbu.sh ${GITHUB_WORKSPACE}/tongbu.sh
if [[ "${SYNCHRONISE}" == "1" ]]; then
  source ${GITHUB_WORKSPACE}/tongbu.sh && menu2
elif [[ "${SYNCHRONISE}" == "2" ]]; then
  source ${GITHUB_WORKSPACE}/tongbu.sh && menu4
fi
rm -rf upcommon
cd ${GITHUB_WORKSPACE}/repogx
for X in $(find "build" -type d -name "relevance"); do echo "ACTIONS_VERSION=${ACTIONS_VERSION}" > "${X}"; done
git add .
git commit -m "强制同步上游仓库 $(date +%Y-%m%d-%H%M%S)"
git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:main
exit 1
}

git clone -b main --depth 1 https://github.com/281677160/common upcommon
sudo chmod -R +x upcommon && source upcommon/xiugai.sh
ACTIONS_VERSION="${ACTIONS_VERSION}"
echo "${ACTIONS_VERSION}"

if [[ ! -d "build" ]]; then
  echo -e "\033[31m 根目录缺少build文件夹存在,进行同步上游仓库操作 \033[0m"
  export SYNCHRONISE="2"
elif [[ ! -d "build/${FOLDER_NAME}" ]]; then
  echo -e "\033[31m build文件夹内缺少${FOLDER_NAME}文件夹存在 \033[0m"
  exit 1
elif [[ ! -d "build/${FOLDER_NAME}/relevance" ]]; then
  echo -e "\033[31m build文件夹内的${FOLDER_NAME}缺少relevance文件夹存在,进行同步上游仓库操作 \033[0m"
  export SYNCHRONISE="2"
elif [[ ! -f "build/${FOLDER_NAME}/relevance/actions_version" ]]; then
  echo -e "\033[31m 缺少build/${FOLDER_NAME}/relevance/actions_version文件,进行同步上游仓库操作 \033[0m"
  export SYNCHRONISE="2"
elif [[ -f "build/${FOLDER_NAME}/relevance/actions_version" ]]; then
  A="$(grep -E "a=.*" GITHUB_ENV |grep -Eo [0-9]+\.[0-9]+\.[0-9]+)"
  B="$(echo "${A}" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+ |cut -d"." -f1)"
  C="$(echo "${ACTIONS_VERSION}" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+ |cut -d"." -f1)"
  if [[ "${B}" != "${C}" ]]; then
    echo -e "\033[31m 版本号不对等,进行同步上游仓库操作 \033[0m"
    export SYNCHRONISE="2"
  elif [[ "${A}" != "${ACTIONS_VERSION}" ]]; then
    echo -e "\033[31m 版本号不对等,进行同步上游仓库操作 \033[0m"
    export SYNCHRONISE="1"
  else
    export SYNCHRONISE="0"
  fi
else
  export SYNCHRONISE="0"
fi

if [[ "${SYNCHRONISE}" =~ (1|2) ]]; then
  Diy_synchronise
else
  Diy_continue
fi
