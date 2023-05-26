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

function tongbu_1() {
sudo rm -rf repogx shangyou
git clone -b main https://github.com/${GIT_REPOSITORY}.git repogx
git clone -b main https://github.com/${GITHUD_REPOSITORY} shangyou
if [[ -d "repogx/build" ]]; then
  mv -f repogx/build operates
else
  cp -Rf shangyou/build operates
fi
sudo rm -rf operates/backups
if [[ "${SYNCHRONISE}" == "1" ]]; then
  mkdir -p backupstwo/b123
  cp -Rf operates backupstwo/operates
  cp -Rf repogx/.github/workflows/* backupstwo/b123/
fi
}

function tongbu_2() {
# 从上游仓库覆盖文件到本地仓库
rm -rf shangyou/build/*/{diy,files,patches,seed}

for X in $(grep "\"COOLSNOWWOLF\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Lede/* "${X}"; done
for X in $(grep "\"LIENOL\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Lienol/* "${X}"; done
for X in $(grep "\"IMMORTALWRT\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Immortalwrt/* "${X}"; done
for X in $(grep "\"XWRT\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Xwrt/* "${X}"; done
for X in $(grep "\"OFFICIAL\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Official/* "${X}"; done
for X in $(find "operates" -type d -name "relevance"); do echo "ACTIONS_VERSION=${ACTIONS_VERSION}" > ${X}/actions_version; done

cp -Rf ${GITHUB_WORKSPACE}/shangyou/README.md repogx/README.md
cp -Rf ${GITHUB_WORKSPACE}/shangyou/LICENSE repogx/LICENSE
  
for X in $(find "${GITHUB_WORKSPACE}/repogx/.github/workflows" -name "*.yml" |grep -v 'synchronise.yml\|compile.yml\|packaging.yml\|.bak'); do
  aa="$(grep 'target: \[.*\]' "${X}" |sed 's/^[ ]*//g' |grep -v '^#' | sed -r 's/target: \[(.*)\]/\1/')"
  if [[ ! -d "${GITHUB_WORKSPACE}/operates/${aa}" ]]; then
    rm -rf "${X}"
    rm -rf "${X}".bak
    echo -e "\033[31m build文件夹里面没发现有${SOURCE_CODE1}此文件夹存在,删除${X}文件 \033[0m"
  fi
done
    
for X in $(find "${GITHUB_WORKSPACE}/repogx/.github/workflows" -name "*.yml" |grep -v 'synchronise.yml\|compile.yml\|packaging.yml\|.bak'); do
  aa="$(grep 'target: \[.*\]' "${X}" |sed 's/^[ ]*//g' |grep -v '^#' | sed -r 's/target: \[(.*)\]/\1/')"
  TARGE1="target: \\[.*\\]"
  TARGE2="target: \\[${aa}\\]"
  yml_name2="$(grep 'name:' "${X}" |sed 's/^[ ]*//g' |grep -v '^#\|^-' |awk 'NR==1')"
  SOURCE_CODE1="$(grep 'SOURCE_CODE=' "${GITHUB_WORKSPACE}/operates/${aa}/settings.ini" | cut -d '"' -f2)"
  if [[ "${SOURCE_CODE1}" == "IMMORTALWRT" ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Immortalwrt.yml ${X}
  elif [[ "${SOURCE_CODE1}" == "COOLSNOWWOLF" ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Lede.yml ${X}
  elif [[ "${SOURCE_CODE1}" == "LIENOL" ]]; then 
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Lienol.yml ${X}
  elif [[ "${SOURCE_CODE1}" == "OFFICIAL" ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Official.yml ${X}
  elif [[ "${SOURCE_CODE1}" == "XWRT" ]]; then 
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Xwrt.yml ${X}
  else
    echo ""
  fi
  yml_name1="$(grep 'name:' "${X}" |sed 's/^[ ]*//g' |grep -v '^#\|^-' |awk 'NR==1')"
  sed -i "s?${TARGE1}?${TARGE2}?g" ${X}
  sed -i "s?${yml_name1}?${yml_name2}?g" "${X}"
done
  
cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/compile.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/compile.yml
cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/packaging.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/packaging.yml
cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/synchronise.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/synchronise.yml
mv -f operates repogx/build

for X in $(find "operates" -name "*.bak"); do rm -rf "${X}"; done
if [[ -d "repogx/.github/workflows" ]]; then
  for X in $(find "repogx/.github/workflows" -name "*.bak"); do rm -rf "${X}"; done
fi

if [[ "${SYNCHRONISE}" == "1" ]]; then
  cd backupstwo
  mkdir -p backups
  cp -Rf operates backups/build
  cp -Rf b123/* backups/
  cp -Rf backups ${GITHUB_WORKSPACE}/repogx/build/backups
fi
}

function tongbu_3() {
if [[ "${SYNCHRONISE}" == "2" ]]; then
  mkdir -p backups
  cp -Rf operates backups/build
  cp -Rf repogx/.github/workflows/* backups/
  cp -Rf backups shangyou/build/backups
fi
sudo rm -rf repogx/*
cp -Rf shangyou/* repogx/
sudo rm -rf repogx/.github/workflows/*
cp -Rf shangyou/.github/workflows/* repogx/.github/workflows/
for X in $(find "repogx" -type d -name "relevance" |grep -v 'backups'); do echo "$(date +%Y%m%d%H%M%S)" > ${X}/1678864096.ini; done
for X in $(find "repogx" -type d -name "relevance" |grep -v 'backups'); do echo "ACTIONS_VERSION=${ACTIONS_VERSION}" > ${X}/actions_version; done
sudo chmod -R +x ${GITHUB_WORKSPACE}/repogx
}

function tongbu_4() {
cd ${GITHUB_WORKSPACE}/repogx
git add .
git commit -m "强制同步上游仓库 $(date +%Y-%m%d-%H%M%S)"
git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:main
exit 1
}

function Diy_memu() {
git clone -b main --depth 1 https://github.com/281677160/common upcommon
ACTIONS_VERSION="$(grep -E "ACTIONS_VERSION=.*" "upcommon/xiugai.sh" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+)"
GIT_REPOSITORY="${GIT_REPOSITORY}"
REPO_TOKEN="${REPO_TOKEN}"

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
  A="$(grep -E "ACTIONS_VERSION=.*" build/${FOLDER_NAME}/relevance/actions_version |grep -Eo [0-9]+\.[0-9]+\.[0-9]+)"
  B="$(echo "${A}" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+ |cut -d"." -f1)"
  C="$(echo "${ACTIONS_VERSION}" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+ |cut -d"." -f1)"
  echo "${A}-${B}-${C}-${ACTIONS_VERSION}"
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


if [[ "${SYNCHRONISE}" == "1" ]]; then
  tongbu_1
  tongbu_2
  tongbu_4
elif [[ "${SYNCHRONISE}" == "2" ]]; then
  tongbu_1
  tongbu_3
  tongbu_4
else
  Diy_continue
fi
}

Diy_memu "$@"
