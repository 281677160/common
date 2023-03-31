#!/bin/bash

# 同步上游操作

function tongbu_0() {
# 第一步下载上游仓库

GITHUD_REPOSITORY="281677160/build-actions"

if [[ "${TONGBU_CANGKU}" == "1" ]]; then
  sudo rm -rf repogx
  git clone -b main https://github.com/${GIT_REPOSITORY}.git repogx
  mv -f repogx/build operates
  sudo rm -rf shangyou
  git clone -b main https://github.com/${GITHUD_REPOSITORY} shangyou
else
  sudo rm -rf shangyou
  git clone -b main https://github.com/${GITHUD_REPOSITORY} shangyou
  if [[ ! -d "operates" ]]; then
    cp -Rf shangyou/build operates
  fi
fi
}

function tongbu_1() {
# 删除上游的seed和备份diy-part.sh、settings.ini
rm -rf shangyou/build/*/{diy,files,patches,seed}
for X in $(find "operates" -name "diy-part.sh" |sed 's/\/diy-part.sh//g'); do mv "${X}"/diy-part.sh "${X}"/diy-part.sh.bak; done
for X in $(find "operates" -name "settings.ini" |sed 's/\/settings.ini//g'); do mv "${X}"/settings.ini "${X}"/settings.ini.bak; done

for X in $(grep "\"AMLOGIC\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do rm -rf "${X}"; done


# 从上游仓库覆盖文件到本地仓库
for X in $(grep "\"COOLSNOWWOLF\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Lede/* "${X}"; done
for X in $(grep "\"LIENOL\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Lienol/* "${X}"; done
for X in $(grep "\"IMMORTALWRT\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Immortalwrt/* "${X}"; done
for X in $(grep "\"XWRT\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Xwrt/* "${X}"; done
for X in $(grep "\"OFFICIAL\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Official/* "${X}"; done

# 云仓库的修改文件
case "${TONGBU_CANGKU}" in
1)
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/README.md repogx/README.md
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/LICENSE repogx/LICENSE
  
  for X in $(find "${GITHUB_WORKSPACE}/repogx/.github/workflows" -name "*.yml" |grep -v '.bak'); do cp -Rf "${X}" "${X}.bak"; done
  
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
;;
esac

# 修改本地文件
if [[ ! "${TONGBU_CANGKU}" == "1" ]]; then
  for X in $(grep "\"AMLOGIC\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do rm -rf "${X}"; done
  
  rm -rf operates/*/relevance
  for X in $(find "operates" -name "settings.ini" |sed 's/\/settings.ini//g'); do 
    mkdir -p "${X}/relevance"
    echo "BENDI_VERSION=${BENDI_VERSION}" > "${X}/relevance/bendi_version"
    echo "bendi_version文件为检测版本用,请勿修改和删除" > "${X}/relevance/README.md"
  done

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
    echo 'PACKAGING_FIRMWARE="true"           # N1和晶晨系列固件自动打包成 .img 固件（true=开启）（false=关闭）' >> "${X}"
    echo 'MODIFY_CONFIGURATION="true"         # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "${X}"
    if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
      echo 'WSL_ROUTEPATH="false"               # 关闭询问改变WSL路径（true=开启）（false=关闭）' >> "${X}"
    fi
  done

  for X in $(find "operates" -type f -name "diy-part.sh"); do 
    sed -i 's?修改插件名字?修改插件名字(二次编译如若有更改名字的,不能照搬此格式,要把修改的文件路径完整的写上)?g' "${X}"
  done
fi
}

function tongbu_2() {
  for X in $(find "operates" -name "*.bak"); do rm -rf "${X}"; done
  if [[ -d "repogx/.github/workflows" ]]; then
    for X in $(find "repogx/.github/workflows" -name "*.bak"); do rm -rf "${X}"; done
  fi
}

function tongbu_3() {
# 上游仓库用完，删除了
if [[ "${TONGBU_CANGKU}" == "1" ]]; then
  mv -f operates repogx/build
else
  rm -rf shangyou
fi
}

function tongbu_4() {
echo "d" > repogx/README.md
sudo rm -rf repogx/*
cp -Rf shangyou/* repogx/
sudo rm -rf repogx/.github/workflows/*
cp -Rf shangyou/.github/workflows/* repogx/.github/workflows/
xx="$(find repogx/ -type d -name "relevance" |awk 'NR==1')"
echo "$(date +%Y%m%d%H%M%S)" > ${xx}/1678864096.ini
sudo chmod -R +x ${GITHUB_WORKSPACE}/repogx
}

function github_establish() {
rm -rf shangyoues
git clone -b main https://github.com/281677160/build-actions.git shangyoues
if [[ ! -d "repogx" ]]; then
  git clone -b main https://github.com/${GIT_REPOSITORY}.git repogx
fi
aa="${inputs_establish_sample}"
bb="${inputs_establish_name}"
if [[ "${aa}" == "请选择" ]]; then
  echo
  echo -e "\033[31m 没选择源码,创建文件夹时请选择创建文件夹的源码 \033[0m"
  echo
  exit 1
fi
if [[ ! -d "repogx/build/${bb}" ]]; then
  cp -Rf shangyoues/build/"${aa}" repogx/build/"${bb}"
  rm -rf repogx/build/${bb}/relevance/*.ini
  rm -rf repogx/build/${bb}/*.bak
  echo
  echo -e "\033[32m [${bb}]文件夹创建完成 \033[0m"
  echo
else
  echo
  echo -e "\033[31m [${bb}]文件夹已存在,无法继续创建,请更换其他名称再来 \033[0m"
  echo
  exit 1
fi

SOURCE_CODE1="$(source "repogx/build/${bb}/settings.ini" && echo ${SOURCE_CODE})"
if [[ "${SOURCE_CODE1}" == "IMMORTALWRT" ]]; then
  cp -Rf shangyoues/.github/workflows/Immortalwrt.yml repogx/.github/workflows/${bb}.yml
  nn="Immortalwrt"
elif [[ "${SOURCE_CODE1}" == "COOLSNOWWOLF" ]]; then
  cp -Rf shangyoues/.github/workflows/Lede.yml repogx/.github/workflows/${bb}.yml
  nn="Lede"
elif [[ "${SOURCE_CODE1}" == "LIENOL" ]]; then
  cp -Rf shangyoues/.github/workflows/Lienol.yml repogx/.github/workflows/${bb}.yml
  nn="Lienol"
elif [[ "${SOURCE_CODE1}" == "OFFICIAL" ]]; then
  cp -Rf shangyoues/.github/workflows/Official.yml repogx/.github/workflows/${bb}.yml
  nn="Official"
elif [[ "${SOURCE_CODE1}" == "XWRT" ]]; then
  cp -Rf shangyoues/.github/workflows/Xwrt.yml repogx/.github/workflows/${bb}.yml
  nn="Xwrt"
fi

yml_name="$(grep 'name:' "repogx/.github/workflows/${bb}.yml" |sed 's/^[ ]*//g' |grep -v '^#\|^-' |awk 'NR==1')"
if [[ `echo "${bb}" |grep -ic "${nn}"` -eq '0' ]]; then
  sed -i "s?${yml_name}?name: ${nn}-${bb}?g" "repogx/.github/workflows/${bb}.yml"
else
  sed -i "s?${yml_name}?name: ${bb}?g" "repogx/.github/workflows/${bb}.yml"
fi
        
TARGE1="target: \\[.*\\]"
TARGE2="target: \\[${bb}\\]"
sed -i "s?${TARGE1}?${TARGE2}?g" repogx/.github/workflows/${bb}.yml
}

function github_deletefile() {
if [[ ! -d "repogx" ]]; then
  git clone -b main https://github.com/${GIT_REPOSITORY}.git repogx
fi
aa="${inputs_Deletefile_name}"
bb=(${aa//,/ })
for cc in ${bb[@]}; do
  if [[ -d "repogx/build/${cc}" ]]; then
    rm -rf repogx/build/"$cc"
    rm -rf $(grep -rl "target: \[$cc\]" "repogx/.github/workflows" |sed 's/^[ ]*//g' |grep -v '^#\|compile')
    echo
    echo -e "\033[31m 已删除[${cc}]文件夹 \033[0m"
    echo
  else
    echo
    echo -e "\033[31m [${cc}]文件夹不存在 \033[0m"
    echo
  fi
done
}

function menu1() {
  tongbu_0
  tongbu_2
  tongbu_3
}
function menu2() {
  tongbu_0
  tongbu_1
  tongbu_3
}
function menu3() {
  tongbu_0
  tongbu_1
  tongbu_2
  tongbu_3
}

function menu4() {
  tongbu_0
  tongbu_4
}

