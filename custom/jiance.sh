#!/bin/bash
# https://github.com/281677160/build-actions
# common Module by 28677160
# matrix.target=${FOLDER_NAME}
cd ${GITHUB_WORKSPACE}

function Diy_continue() {
rm -rf upcommon
sudo rm -rf build/common && git clone -b main --depth 1 https://github.com/281677160/common build/common
cp -Rf build/common/*.sh build/${FOLDER_NAME}/
cp -Rf build/common/xiugai.sh build/${FOLDER_NAME}/common.sh
sudo chmod -R +x build
}

function tongbu_1() {
sudo rm -rf repogx shangyou
git clone -b main https://github.com/${GIT_REPOSITORY}.git repogx
git clone -b main https://github.com/281677160/build-actions shangyou

if [[ ! -d "repogx" ]]; then
  echo "本地仓库下载错误"
  exit 1
elif [[ ! -d "shangyou" ]]; then
  echo "上游仓库下载错误"
  exit 1
fi

if [[ -d "repogx/build" ]]; then
  mv -f repogx/build ${GITHUB_WORKSPACE}/operates
  mkdir -p backupstwo/b123
  cp -Rf operates backupstwo/operates
  cp -Rf repogx/.github/workflows backupstwo/b123/workflows
fi
[[ -d "repogx/backups" ]] && sudo rm -rf repogx/backups
[[ -d "operates/backups" ]] && sudo rm -rf operates/backups
}

function tongbu_2() {
# 从上游仓库覆盖文件到本地仓库
BANBEN_SHUOMING="小版本更新于 $(date +%Y.%m%d.%H%M.%S)"
rm -rf shangyou/build/*/{diy,files,patches,seed}

settings_file="$({ find ${GITHUB_WORKSPACE}/operates |grep settings.ini; } 2>"/dev/null")"
for f in ${settings_file}
do
  X="$(echo "$f" |sed "s/settings.ini//g")"
  REPO_BRANCH1="$(grep "REPO_BRANCH=" "$f" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  CONFIG_FILE1="$(grep "CONFIG_FILE=" "$f" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  [ -n "$(grep 'SOURCE_CODE="COOLSNOWWOLF"' "$f")" ] && cp -Rf ${GITHUB_WORKSPACE}/shangyou/build/Lede/* "${X}"
  [ -n "$(grep 'SOURCE_CODE="LIENOL"' "$f")" ] && cp -Rf ${GITHUB_WORKSPACE}/shangyou/build/Lienol/* "${X}"
  [ -n "$(grep 'SOURCE_CODE="IMMORTALWRT"' "$f")" ] && cp -Rf ${GITHUB_WORKSPACE}/shangyou/build/Immortalwrt/* "${X}"
  [ -n "$(grep 'SOURCE_CODE="XWRT"' "$f")" ] && cp -Rf ${GITHUB_WORKSPACE}/shangyou/build/Xwrt/* "${X}"
  [ -n "$(grep 'SOURCE_CODE="OFFICIAL"' "$f")" ] && cp -Rf ${GITHUB_WORKSPACE}/shangyou/build/Official/* "${X}"
  REPO_BRANCH2="$(grep "REPO_BRANCH=" "$f" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  CONFIG_FILE2="$(grep "CONFIG_FILE=" "$f" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
  if [[ -n "${REPO_BRANCH1}" ]] && [[ -n "${REPO_BRANCH2}" ]]; then
    sed -i "s?${REPO_BRANCH1}?${REPO_BRANCH2}?g" ${f}
  fi
  if [[ -n "${CONFIG_FILE1}" ]] && [[ -n "${CONFIG_FILE2}" ]]; then
    sed -i "s?${CONFIG_FILE1}?${CONFIG_FILE2}?g" ${f}
  fi
done

yml_file="$({ find ${GITHUB_WORKSPACE}/repogx |grep .yml |grep -v 'synchronise.yml\|compile.yml\|packaging.yml'; } 2>"/dev/null")"
for f in ${yml_file}
do
  a="$(grep 'target: \[.*\]' "${f}" |sed 's/^[ ]*//g' |grep -v '^#' | sed -r 's/target: \[(.*)\]/\1/')"
  [ ! -d "${GITHUB_WORKSPACE}/operates/${a}" ] && rm -rf "${f}"
  TARGE1="target: \\[.*\\]"
  TARGE2="target: \\[${a}\\]"
  yml_name2="$(grep 'name:' "${f}" |sed 's/^[ ]*//g' |grep -v '^#\|^-' |awk 'NR==1')"
  schedule_name2="$(grep -E 'schedule:' "${f}" |sed 's/\*/\\&/g' |sed 's/\:/\\&/' |awk 'NR==1')"
  cron_name2="$(grep -E '\- cron:.*' "${f}" |sed 's/\*/\\&/g' |sed 's/\,/\\&/' |awk 'NR==1')"
  SOURCE_CODE1="$(grep 'SOURCE_CODE=' "${GITHUB_WORKSPACE}/operates/${a}/settings.ini" |grep -v '^#' |cut -d '"' -f2)"
  if [[ "${SOURCE_CODE1}" == "IMMORTALWRT" ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Immortalwrt.yml ${f}
  elif [[ "${SOURCE_CODE1}" == "COOLSNOWWOLF" ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Lede.yml ${f}
  elif [[ "${SOURCE_CODE1}" == "LIENOL" ]]; then 
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Lienol.yml ${f}
  elif [[ "${SOURCE_CODE1}" == "OFFICIAL" ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Official.yml ${f}
  elif [[ "${SOURCE_CODE1}" == "XWRT" ]]; then 
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Xwrt.yml ${f}
  fi
  yml_name1="$(grep 'name:' "${f}" |sed 's/^[ ]*//g' |grep -v '^#\|^-' |awk 'NR==1')"
  schedule_name1="$(grep -E 'schedule:' "${f}" |sed 's/\*/\\&/g' |sed 's/\:/\\&/' |awk 'NR==1')"
  cron_name1="$(grep -E '\- cron:.*' "${f}" |sed 's/\*/\\&/g' |sed 's/\,/\\&/' |awk 'NR==1')"
  if [[ -n "${TARGE1}" ]] && [[ -n "${TARGE2}" ]]; then
    sed -i "s?${TARGE1}?${TARGE2}?g" ${f}
  fi
  if [[ -n "${yml_name1}" ]] && [[ -n "${yml_name2}" ]]; then
    sed -i "s?${yml_name1}?${yml_name2}?g" ${f}
  fi
  if [[ -n "${schedule_name1}" ]] && [[ -n "${schedule_name2}" ]]; then
    sed -i "s?${schedule_name1}?${schedule_name2}?g" ${f}
  fi
  if [[ -n "${cron_name1}" ]] && [[ -n "${cron_name2}" ]]; then
    sed -i "s?${cron_name1}?${cron_name2}?g" ${f}
  fi
done

for X in $(find "${GITHUB_WORKSPACE}/operates" -type d -name "relevance"); do
  rm -rf ${X}/{*.ini,*start}
  echo "ACTIONS_VERSION=${ACTIONS_VERSION}" > ${X}/actions_version
  echo "请勿修改和删除此文件夹内的任何文件" > ${X}/README
done

cp -Rf ${GITHUB_WORKSPACE}/shangyou/README.md ${GITHUB_WORKSPACE}/repogx/README.md
cp -Rf ${GITHUB_WORKSPACE}/shangyou/LICENSE ${GITHUB_WORKSPACE}/repogx/LICENSE
  
cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/compile.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/compile.yml
cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/packaging.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/packaging.yml
cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/synchronise.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/synchronise.yml
mv -f operates repogx/build

for X in $({ find ${GITHUB_WORKSPACE}/repogx |grep .bak; } 2>"/dev/null"); do rm -rf "${X}"; done

if [[ -d "backupstwo" ]]; then
  cd backupstwo
  mkdir -p backups
  cp -Rf operates backups/build
  cp -Rf b123/workflows backups/workflows
  cp -Rf backups ${GITHUB_WORKSPACE}/repogx/backups
  cd ${GITHUB_WORKSPACE}
fi
}

function tongbu_3() {
BANBEN_SHUOMING="大版本覆盖于 $(date +%Y.%m%d.%H%M.%S)"
if [[ -d "backupstwo" ]]; then
  cd backupstwo
  mkdir -p backups
  cp -Rf operates backups/build
  cp -Rf b123/workflows backups/workflows
  cp -Rf backups ${GITHUB_WORKSPACE}/shangyou/backups
  cd ${GITHUB_WORKSPACE}
fi
sudo rm -rf repogx/*
cp -Rf shangyou/* repogx/
sudo rm -rf repogx/.github/workflows/*
cp -Rf shangyou/.github/workflows/* repogx/.github/workflows/
for X in $(find "${GITHUB_WORKSPACE}/repogx" -type d -name "relevance"); do 
  rm -rf ${X}/{*.ini,*start}
  echo "ACTIONS_VERSION=${ACTIONS_VERSION}" > ${X}/actions_version
  echo "请勿修改和删除此文件夹内的任何文件" > ${X}/README
done
sudo chmod -R +x ${GITHUB_WORKSPACE}/repogx
}

function tongbu_4() {
cd ${GITHUB_WORKSPACE}/repogx
git add .
git commit -m "${BANBEN_SHUOMING}"
git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:main
exit 1
}

function Diy_memu() {
git clone -b main --depth 1 https://github.com/281677160/common upcommon
ACTIONS_VERSION="$(grep -E "ACTIONS_VERSION=.*" "upcommon/xiugai.sh" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+)"
GIT_REPOSITORY="${GIT_REPOSITORY}"
REPO_TOKEN="${REPO_TOKEN}"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config --global user.name "github-actions[bot]"

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
  echo "本地版本：${A}"
  echo "上游版本：${ACTIONS_VERSION}"
  if [[ "${B}" != "${C}" ]]; then
    echo -e "\033[31m 版本号不对等,进行同步上游仓库操作 \033[0m"
    export SYNCHRONISE="2"
  elif [[ "${A}" != "${ACTIONS_VERSION}" ]]; then
    echo -e "\033[31m 此仓库版本号跟上游仓库不对等,进行小版本更新 \033[0m"
    export SYNCHRONISE="1"
  else
    export SYNCHRONISE="0"
    echo -e "\033[32m 版本一致,继续编译固件... \033[0m"
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
