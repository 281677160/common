#!/bin/bash
# https://github.com/281677160/build-actions
# common Module by 28677160
# matrix.target=${FOLDER_NAME}
cd ${GITHUB_WORKSPACE}

function Diy_continue() {
cd ${GITHUB_WORKSPACE}
if [[ -n "${BENDI_VERSION}" ]]; then
  sudo rm -rf build common.sh
else
  sudo rm -rf build/common && git clone -b main --depth 1 https://github.com/281677160/common build/common
  cp -Rf build/common/*.sh build/${FOLDER_NAME}/
  cp -Rf build/common/common.sh build/${FOLDER_NAME}/common.sh
  cp -Rf build/common/upgrade.sh build/${FOLDER_NAME}/upgrade.sh
  chmod -R +x build 
fi
}

function tongbu_1() {
cd ${GITHUB_WORKSPACE}
sudo rm -rf repogx shangyou
if [[ -n "${BENDI_VERSION}" ]]; then
  git clone -b main https://github.com/${GIT_REPOSITORY}.git repogx
else
  git clone -b main https://user:${REPO_TOKEN}@github.com/${GIT_REPOSITORY}.git repogx
fi
git clone -b main --depth 1 https://github.com/281677160/build-actions shangyou

if [[ ! -d "repogx" ]]; then
  echo -e "\033[31m 本地仓库下载错误 \033[0m"
  exit 1
elif [[ ! -d "shangyou" ]]; then
  echo -e "\033[31m 上游仓库下载错误 \033[0m"
  exit 1
fi

if [[ -n "${BENDI_VERSION}" ]]; then
  rm -rf repogx/build
else
  rm -rf operates && mv -f repogx/build operates
fi

[[ -d "repogx/backups" ]] && sudo rm -rf repogx/backups
[[ -d "operates/backups" ]] && sudo rm -rf operates/backups

rm -rf backupstwo && mkdir -p backupstwo
cp -Rf operates backupstwo/operates
cp -Rf repogx/.github/workflows backupstwo/workflows
}

function tongbu_2() {
# 从上游仓库覆盖文件到本地仓库
cd ${GITHUB_WORKSPACE}
BANBEN_SHUOMING="更新小版本于 $(date +%Y.%m%d.%H%M.%S)"
rm -rf shangyou/build/*/{diy,files,patches,seed}

for i in $({ find "${GITHUB_WORKSPACE}/operates" -type d -name "relevance" |grep -v 'backups'; } 2>"/dev/null"); do sudo rm -rf "${i}"; done

settings_file="$({ find ${GITHUB_WORKSPACE}/operates |grep -v 'backups' |grep settings.ini; } 2>"/dev/null")"
for a in ${settings_file}
do
  X="$(echo "${a}" |sed "s/settings.ini//g")"
  if [ -n "$(grep 'SOURCE_CODE="COOLSNOWWOLF"' "${a}")" ]; then
    Y="${GITHUB_WORKSPACE}/shangyou/build/Lede/settings.ini"
    REPO_BRANCH1="$(grep -E "REPO_BRANCH=" "${Y}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    CONFIG_FILE1="$(grep -E "CONFIG_FILE=" "${Y}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    REPO_BRANCH2="$(grep -E "REPO_BRANCH=" "${a}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    CONFIG_FILE2="$(grep -E "CONFIG_FILE=" "${a}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    if [[ -n "${REPO_BRANCH1}" ]] && [[ -n "${REPO_BRANCH2}" ]]; then
      sed -i "s?${REPO_BRANCH1}?${REPO_BRANCH2}?g" ${Y}
    fi
    if [[ -n "${CONFIG_FILE1}" ]] && [[ -n "${CONFIG_FILE2}" ]]; then
      sed -i "s?${CONFIG_FILE1}?${CONFIG_FILE2}?g" ${Y}
    fi
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/build/Lede/* "${X}"
  elif [ -n "$(grep 'SOURCE_CODE="LIENOL"' "${a}")" ]; then
    Y="${GITHUB_WORKSPACE}/shangyou/build/Lienol/settings.ini"
    REPO_BRANCH1="$(grep -E "REPO_BRANCH=" "${Y}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    CONFIG_FILE1="$(grep -E "CONFIG_FILE=" "${Y}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    REPO_BRANCH2="$(grep -E "REPO_BRANCH=" "${a}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    CONFIG_FILE2="$(grep -E "CONFIG_FILE=" "${a}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    if [[ -n "${REPO_BRANCH1}" ]] && [[ -n "${REPO_BRANCH2}" ]]; then
      sed -i "s?${REPO_BRANCH1}?${REPO_BRANCH2}?g" ${Y}
    fi
    if [[ -n "${CONFIG_FILE1}" ]] && [[ -n "${CONFIG_FILE2}" ]]; then
      sed -i "s?${CONFIG_FILE1}?${CONFIG_FILE2}?g" ${Y}
    fi
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/build/Lienol/* "${X}"
  elif [ -n "$(grep 'SOURCE_CODE="IMMORTALWRT"' "${a}")" ]; then
    Y="${GITHUB_WORKSPACE}/shangyou/build/Immortalwrt/settings.ini"
    REPO_BRANCH1="$(grep -E "REPO_BRANCH=" "${Y}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    CONFIG_FILE1="$(grep -E "CONFIG_FILE=" "${Y}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    REPO_BRANCH2="$(grep -E "REPO_BRANCH=" "${a}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    CONFIG_FILE2="$(grep -E "CONFIG_FILE=" "${a}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    if [[ -n "${REPO_BRANCH1}" ]] && [[ -n "${REPO_BRANCH2}" ]]; then
      sed -i "s?${REPO_BRANCH1}?${REPO_BRANCH2}?g" ${Y}
    fi
    if [[ -n "${CONFIG_FILE1}" ]] && [[ -n "${CONFIG_FILE2}" ]]; then
      sed -i "s?${CONFIG_FILE1}?${CONFIG_FILE2}?g" ${Y}
    fi
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/build/Immortalwrt/* "${X}"
  elif [ -n "$(grep 'SOURCE_CODE="XWRT"' "${a}")" ]; then
    Y="${GITHUB_WORKSPACE}/shangyou/build/Xwrt/settings.ini"
    REPO_BRANCH1="$(grep -E "REPO_BRANCH=" "${Y}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    CONFIG_FILE1="$(grep -E "CONFIG_FILE=" "${Y}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    REPO_BRANCH2="$(grep -E "REPO_BRANCH=" "${a}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    CONFIG_FILE2="$(grep -E "CONFIG_FILE=" "${a}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    if [[ -n "${REPO_BRANCH1}" ]] && [[ -n "${REPO_BRANCH2}" ]]; then
      sed -i "s?${REPO_BRANCH1}?${REPO_BRANCH2}?g" ${Y}
    fi
    if [[ -n "${CONFIG_FILE1}" ]] && [[ -n "${CONFIG_FILE2}" ]]; then
      sed -i "s?${CONFIG_FILE1}?${CONFIG_FILE2}?g" ${Y}
    fi
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/build/Xwrt/* "${X}"
  elif [ -n "$(grep 'SOURCE_CODE="OFFICIAL"' "${a}")" ]; then
    Y="${GITHUB_WORKSPACE}/shangyou/build/Official/settings.ini"
    REPO_BRANCH1="$(grep -E "REPO_BRANCH=" "${Y}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    CONFIG_FILE1="$(grep -E "CONFIG_FILE=" "${Y}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    REPO_BRANCH2="$(grep -E "REPO_BRANCH=" "${a}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    CONFIG_FILE2="$(grep -E "CONFIG_FILE=" "${a}" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}' |sed 's?=?\\&?g' |sed 's?"?\\&?g')"
    if [[ -n "${REPO_BRANCH1}" ]] && [[ -n "${REPO_BRANCH2}" ]]; then
      sed -i "s?${REPO_BRANCH1}?${REPO_BRANCH2}?g" ${Y}
    fi
    if [[ -n "${CONFIG_FILE1}" ]] && [[ -n "${CONFIG_FILE2}" ]]; then
      sed -i "s?${CONFIG_FILE1}?${CONFIG_FILE2}?g" ${Y}
    fi
    cp -Rf ${GITHUB_WORKSPACE}/shangyou/build/Official/* "${X}"
  fi
done

yml_file="$({ find ${GITHUB_WORKSPACE}/repogx |grep .yml |grep -v 'institution.yml\|compile.yml\|packaging.yml\|backups'; } 2>"/dev/null")"
for f in ${yml_file}
do
  a="$({ grep 'target: \[.*\]' "${f}" |sed 's/^[ ]*//g' |grep -v '^#' | sed -r 's/target: \[(.*)\]/\1/'; } 2>"/dev/null")"
  TARGE1="target: \\[.*\\]"
  TARGE2="target: \\[${a}\\]"
  yml_name2="$({ grep 'name:' "${f}" |sed 's/^[ ]*//g' |grep -v '^#\|^-' |awk 'NR==1'; } 2>"/dev/null")"
  schedule_name2="$({ grep -E 'schedule:' "${f}" |sed 's/\*/\\&/g' |sed 's/\:/\\&/' |awk 'NR==1'; } 2>"/dev/null")"
  cron_name2="$({ grep -E '\- cron:.*' "${f}" |sed 's/\*/\\&/g' |sed 's/\,/\\&/' |awk 'NR==1'; } 2>"/dev/null")"
  SOURCE_CODE1="$({ grep 'SOURCE_CODE=' "${GITHUB_WORKSPACE}/operates/${a}/settings.ini" |grep -v '^#' |cut -d '"' -f2; } 2>"/dev/null")"
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
  [ ! -d "${GITHUB_WORKSPACE}/operates/${a}" ] && rm -rf "${f}"
  yml_name1="$({ grep 'name:' "${f}" |sed 's/^[ ]*//g' |grep -v '^#\|^-' |awk 'NR==1'; } 2>"/dev/null")"
  schedule_name1="$({ grep -E 'schedule:' "${f}" |sed 's/\*/\\&/g' |sed 's/\:/\\&/g' |awk 'NR==1'; } 2>"/dev/null")"
  cron_name1="$({ grep -E '\- cron:.*' "${f}" |sed 's/\*/\\&/g' |sed 's/\,/\\&/g' |awk 'NR==1'; } 2>"/dev/null")"
  if [[ -n "${TARGE1}" ]] && [[ -n "${TARGE2}" ]] && [[ -f "${f}" ]]; then
    sed -i "s?${TARGE1}?${TARGE2}?g" ${f}
  fi
  if [[ -n "${yml_name1}" ]] && [[ -n "${yml_name2}" ]] && [[ -f "${f}" ]]; then
    sed -i "s?${yml_name1}?${yml_name2}?g" ${f}
  fi
  if [[ -n "${schedule_name1}" ]] && [[ -n "${schedule_name2}" ]] && [[ -f "${f}" ]]; then
    sed -i "s?${schedule_name1}?${schedule_name2}?g" ${f}
  fi
  if [[ -n "${cron_name1}" ]] && [[ -n "${cron_name2}" ]] && [[ -f "${f}" ]]; then
    sed -i "s?${cron_name1}?${cron_name2}?g" ${f}
  fi
done

for X in $(find "${GITHUB_WORKSPACE}/operates" -type d -name "relevance" |grep -v 'backups'); do
  rm -rf ${X}/{*.ini,*start}
  echo "ACTIONS_VERSION=${ACTIONS_VERSION}" > ${X}/actions_version
  echo "请勿修改和删除此文件夹内的任何文件" > ${X}/README
  echo "$(date +%Y%m%d%H%M%S)" > ${X}/start
  echo "$(date +%Y%m%d%H%M%S)" > ${X}/armsrstart
done

cp -Rf ${GITHUB_WORKSPACE}/shangyou/README.md ${GITHUB_WORKSPACE}/repogx/README.md
cp -Rf ${GITHUB_WORKSPACE}/shangyou/LICENSE ${GITHUB_WORKSPACE}/repogx/LICENSE
  
cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/compile.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/compile.yml
cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/packaging.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/packaging.yml
cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/institution.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/institution.yml

for X in $({ find ${GITHUB_WORKSPACE}/operates |grep -v 'backups' |grep .bak; } 2>"/dev/null"); do rm -rf "${X}"; done

cp -Rf operates repogx/build

if [[ -d "backupstwo" ]]; then
  cd ${GITHUB_WORKSPACE}
  mkdir -p backupstwo/backups
  if [[ -n "${BENDI_VERSION}" ]]; then
    cp -Rf backupstwo/operates/* backupstwo/backups/
    cp -Rf backupstwo/backups ${GITHUB_WORKSPACE}/operates/backups
    sudo chmod -R +x operates
    sudo rm -rf backupstwo repogx shangyou build
  else
    cp -Rf backupstwo/operates/* backupstwo/backups/
    cp -Rf backupstwo/workflows backupstwo/backups/workflows
    cp -Rf backupstwo/backups ${GITHUB_WORKSPACE}/repogx/backups
  fi
fi
cd ${GITHUB_WORKSPACE}
if [[ -n "${BENDI_VERSION}" ]]; then
  echo "TONGBU_BENDI=1" >> ${GITHUB_ENV}
  tongbu_5
else
  tongbu_4
fi
}

function tongbu_3() {
cd ${GITHUB_WORKSPACE}
BANBEN_SHUOMING="大版本覆盖于 $(date +%Y.%m%d.%H%M.%S)"
cd ${GITHUB_WORKSPACE}
if [[ -d "backupstwo" ]]; then
  mkdir -p backupstwo/backups
  if [[ -n "${BENDI_VERSION}" ]]; then
    cp -Rf backupstwo/operates/* backupstwo/backups/
  else
    cp -Rf backupstwo/operates/* backupstwo/backups/
    cp -Rf backupstwo/workflows backupstwo/backups/workflows
  fi
fi
sudo rm -rf ${GITHUB_WORKSPACE}/repogx/*
cp -Rf ${GITHUB_WORKSPACE}/shangyou/* ${GITHUB_WORKSPACE}/repogx/
sudo rm -rf ${GITHUB_WORKSPACE}/repogx/.github/workflows/*
cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/* ${GITHUB_WORKSPACE}/repogx/.github/workflows/
for X in $(find "${GITHUB_WORKSPACE}/repogx" -type d -name "relevance" |grep -v 'backups'); do 
  rm -rf ${X}/{*.ini,*start}
  echo "ACTIONS_VERSION=${ACTIONS_VERSION}" > ${X}/actions_version
  echo "请勿修改和删除此文件夹内的任何文件" > ${X}/README
  echo "$(date +%Y%m%d%H%M%S)" > ${X}/start
  echo "$(date +%Y%m%d%H%M%S)" > ${X}/armsrstart
done
if [[ -n "${BENDI_VERSION}" ]]; then
  rm -rf backupstwo/backups/workflows
  cp -Rf backupstwo/backups ${GITHUB_WORKSPACE}/repogx/build/backups
  rm -rf build operates
  cp -Rf ${GITHUB_WORKSPACE}/repogx/build ${GITHUB_WORKSPACE}/operates
  rm -rf shangyou repogx backupstwo
  echo "TONGBU_BENDI=2" >> ${GITHUB_ENV}
  tongbu_5
else
  cp -Rf backupstwo/backups ${GITHUB_WORKSPACE}/repogx/backups
  tongbu_4
fi
}

function tongbu_4() {
chmod -R +x ${GITHUB_WORKSPACE}/repogx
cd ${GITHUB_WORKSPACE}/repogx
BRANCH_HEAD="$(git rev-parse --abbrev-ref HEAD)"
if [[ "${OPERATES_BUILD}" == "1" ]]; then
  rm -rf backups
fi
if [[ "${GIT_REPOSITORY}" =~ (281677160/build-actions|281677160/autobuild) ]]; then
  rm -rf backups
  BANBEN_SHUOMING="Update $(date +%Y.%m%d.%H%M.%S)"
fi
git add .
git commit -m "${BANBEN_SHUOMING}"
git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:${BRANCH_HEAD}
if [[ $? -ne 0 ]]; then
  echo -e "\033[31m 同步上游仓库失败,请注意密匙是否正确 \033[0m"
else
  echo -e "\033[33m 同步上游仓库完成,请重新设置好文件再继续编译 \033[0m"
fi
exit 1
}

function tongbu_5() {
cd ${GITHUB_WORKSPACE}
if [[ "${OPERATES_BUILD}" == "1" ]]; then
  rm -rf operates/backups
fi
for X in $(find "operates" -name "settings.ini"); do
  sed -i '/SSH_ACTIONS/d' "${X}"
  sed -i '/UPLOAD_FIRMWARE/d' "${X}"
  sed -i '/UPLOAD_WETRANSFER/d' "${X}"
  sed -i '/UPLOAD_RELEASE/d' "${X}"
  sed -i '/INFORMATION_NOTICE/d' "${X}"
  sed -i '/CACHEWRTBUILD_SWITCH/d' "${X}"
  sed -i '/COMPILATION_INFORMATION/d' "${X}"
  sed -i '/UPDATE_FIRMWARE_ONLINE/d' "${X}"
  sed -i '/CPU_SELECTION/d' "${X}"
  sed -i '/RETAIN_DAYS/d' "${X}"
  sed -i '/KEEP_LATEST/d' "${X}"
  sed -i '/COLLECTED_PACKAGES/d' "${X}"
  echo 'PACKAGING_FIRMWARE="true"           # 自动把Amlogic_Rockchip系列固件,打包成.img格式（true=开启）（false=关闭）' >> "${X}"
  echo 'MODIFY_CONFIGURATION="true"         # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "${X}"
  if [[ `echo "${PATH}" |grep -ic "Windows"` -ge '1' ]]; then
    echo 'WSL_ROUTEPATH="false"               # 关闭询问改变WSL路径（true=开启）（false=关闭）' >> "${X}"
  fi
done
chmod -R +x ${GITHUB_WORKSPACE}/operates
exit 0
}

function Diy_memu() {
cd ${GITHUB_WORKSPACE}
export OPERATES_BUILD="0"
curl -fsSL https://raw.githubusercontent.com/281677160/common/main/common.sh -o common.sh
if [[ $? -ne 0 ]]; then
  wget -q https://raw.githubusercontent.com/281677160/common/main/common.sh -O common.sh
fi
export ACTIONS_VERSION="$(grep -E "ACTIONS_VERSION=.*" "common.sh" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+)"
export DIY_PART_SH="$(grep -Eo "DIY_PART_SH=.*" "common.sh" |grep '.sh' |awk 'NR==1' |cut -d'"' -f2)"
echo "DIY_PART_SH=${DIY_PART_SH}" >> ${GITHUB_ENV}
if [[ -n "${BENDI_VERSION}" ]]; then
  export BENDI_VERSION="1"
  export GIT_REPOSITORY="281677160/build-actions"
  sudo rm -rf build common.sh
  [[ -d "operates" ]] && cp -Rf operates build
  sed -i '/TONGBU_BENDI/d' ${GITHUB_ENV}
else
  export GIT_REPOSITORY="${GIT_REPOSITORY}"
  export REPO_TOKEN="${REPO_TOKEN}"
  git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
  git config --global user.name "github-actions[bot]"
fi

if [[ ! -d "build" ]]; then
  echo -e "\033[31m 根目录缺少编译必要文件夹存在,进行同步上游仓库操作 \033[0m"
  export SYNCHRONISE="2"
  export OPERATES_BUILD="1"
  sleep 2
elif [[ ! -d "build/${FOLDER_NAME}" ]]; then
  echo -e "\033[31m build文件夹内缺少${FOLDER_NAME}文件夹存在 \033[0m"
  exit 1
elif [[ ! -f "${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/settings.ini" ]]; then
  echo -e "\033[31m ${FOLDER_NAME}文件夹内缺少[settings.ini]存在 \033[0m"
  exit 1
elif [[ ! -f "${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/${DIY_PART_SH}" ]]; then
  echo -e "\033[31m ${FOLDER_NAME}文件夹内缺少[${DIY_PART_SH}]存在 \033[0m"
  exit 1
elif [[ ! -d "build/${FOLDER_NAME}/relevance" ]]; then
  echo -e "\033[31m build文件夹内的${FOLDER_NAME}缺少relevance文件夹存在,进行同步上游仓库操作 \033[0m"
  export SYNCHRONISE="2"
  sleep 2
elif [[ ! -f "build/${FOLDER_NAME}/relevance/actions_version" ]]; then
  echo -e "\033[31m 缺少build/${FOLDER_NAME}/relevance/actions_version文件,进行同步上游仓库操作 \033[0m"
  export SYNCHRONISE="2"
  sleep 2
elif [[ -f "build/${FOLDER_NAME}/relevance/actions_version" ]]; then
  export A="$(grep -E "ACTIONS_VERSION=.*" build/${FOLDER_NAME}/relevance/actions_version |grep -Eo [0-9]+\.[0-9]+\.[0-9]+)"
  export B="$(echo "${A}" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+ |cut -d"." -f1)"
  export C="$(echo "${ACTIONS_VERSION}" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+ |cut -d"." -f1)"
  echo " 本地版本：${A}"
  echo " 上游版本：${ACTIONS_VERSION}"
  if [[ "${B}" != "${C}" ]]; then
    echo -e "\033[31m 版本号不对等,进行同步上游仓库操作 \033[0m"
    export SYNCHRONISE="2"
    sleep 2
  elif [[ "${A}" != "${ACTIONS_VERSION}" ]]; then
    echo -e "\033[31m 此仓库版本号跟上游仓库不对等,进行小版本更新 \033[0m"
    export SYNCHRONISE="1"
    sleep 2
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
elif [[ "${SYNCHRONISE}" == "2" ]]; then
  tongbu_1
  tongbu_3
else
  Diy_continue
fi
}

Diy_memu "$@"
