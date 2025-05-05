#!/bin/bash
# common Module by 28677160
# matrix.target=${FOLDER_NAME}

# 初始化全局变量
export TONGBU_YUANMA=""
export SYNCHRONISE=""

# 定义颜色输出函数
function TIME() {
  local color_map=(
    [r]="\e[31m" [g]="\e[32m" [b]="\e[34m"
    [y]="\e[33m" [z]="\e[35m" [l]="\e[36m"
  )
  local color=${color_map[$1]:-"\e[36m"}
  echo -e "${color}${2}\e[0m"
}

# 检查并同步编译环境
function Diy_two() {
  local error_message=""
  if [[ ! -d "${OPERATES_PATH}" ]]; then
    error_message="根目录缺少编译必要文件夹"
  elif [[ ! -d "${COMPILE_PATH}" ]]; then
    error_message="缺少${COMPILE_PATH}文件夹"
  elif [[ ! -f "${BUILD_PARTSH}" ]]; then
    error_message="缺少${BUILD_PARTSH}文件"
  elif [[ ! -f "${BUILD_SETTINGS}" ]]; then
    error_message="缺少${BUILD_SETTINGS}文件"
  elif [[ ! -f "${COMPILE_PATH}/relevance/actions_version" ]]; then
    error_message="缺少relevance/actions_version文件"
  elif [[ ! -f "${COMPILE_PATH}/seed/${CONFIG_FILE}" ]]; then
    error_message="缺少seed/${CONFIG_FILE}文件，请先建立seed/${CONFIG_FILE}文件"
    exit 1
  fi

  if [[ -n "${error_message}" ]]; then
    TIME r "${error_message}"
    SYNCHRONISE="NO"
    tongbu_message="${error_message}"
    return
  fi

  local common_sh_url="https://raw.githubusercontent.com/281677160/common/main/common.sh"
  curl -fsSL "${common_sh_url}" -o /tmp/common.sh
  if [[ ! -s "/tmp/common.sh" ]]; then
    TIME r "对比版本号文件下载失败,请检查网络"
    exit 1
  fi

  local ACTIONS_VERSION1=$(sed -nE 's/^[[:space:]]*ACTIONS_VERSION[[:space:]]*=[[:space:]]*"?([0-9.]+)"?.*/\1/p' /tmp/common.sh)
  local ACTIONS_VERSION2=$(sed -nE 's/^[[:space:]]*ACTIONS_VERSION[[:space:]]*=[[:space:]]*"?([0-9.]+)"?.*/\1/p' "${COMPILE_PATH}/relevance/actions_version")
  if [[ "${ACTIONS_VERSION1}" != "${ACTIONS_VERSION2}" ]]; then
    sudo rm -rf /etc/oprelyo*
    TIME r "和上游版本不一致"
    SYNCHRONISE="NO"
    tongbu_message="和上游版本不一致"
  else
    SYNCHRONISE="YES"
  fi
}

# 同步上游仓库
function Diy_three() {
  if [[ "${SYNCHRONISE}" != "NO" ]]; then
    return
  fi

  local shangyou=$(mktemp -d)
  local build_actions_url="https://github.com/281677160/build-actions"
  if git clone --single-branch --depth=1 --branch=main "${build_actions_url}" "${shangyou}"; then
    if [[ -d "${OPERATES_PATH}" ]]; then
      mv "${OPERATES_PATH}" backups
      cp -Rf "${shangyou}/build" "${OPERATES_PATH}"
      mv backups "${OPERATES_PATH}/backups"
    else
      cp -Rf "${shangyou}/build" "${OPERATES_PATH}"
    fi
    rm -rf "${shangyou}"
    chmod -R +x "${OPERATES_PATH}"

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
      echo 'PACKAGING_FIRMWARE="true"           # 自动把aarch64系列固件,打包成.img格式（true=开启）（false=关闭）' >> "${X}"
      echo 'MODIFY_CONFIGURATION="true"         # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "${X}"
    done

    local ACTIONS_VERSION1=$(sed -nE 's/^[[:space:]]*ACTIONS_VERSION[[:space:]]*=[[:space:]]*"?([0-9.]+)"?.*/\1/p' /tmp/common.sh)
    for X in $(find "${OPERATES_PATH}" -type d -name "relevance" | grep -v 'backups'); do
      rm -rf "${X}/{*.ini,*start,run_number}"
      echo "ACTIONS_VERSION=${ACTIONS_VERSION1}" > "${X}/actions_version"
      echo "请勿修改和删除此文件夹内的任何文件" > "${X}/README"
      echo "$(date +%Y%m%d%H%M%S)" > "${X}/start"
    done

    if [[ -d "${OPERATES_PATH}/backups" ]]; then
      TIME g "同步上游仓库完成, operates文件夹内有个backups备份包, 您以前的文件都存放在这里"
    else
      TIME g "同步上游仓库完成"
    fi
    TIME r "因刚同步上游文件, 请设置好[operates]文件夹内的配置后，再次使用命令编译"
    export TONGBU_YUANMA="1"
  else
    TIME r "同步上游仓库失败, 注意网络环境, 请重新再运行命令试试"
    export TONGBU_YUANMA="1"
    exit 1
  fi
}

# 准备编译环境
function Diy_four() {
  local LINSHI_COMMON="/tmp/common"
  rm -rf "${LINSHI_COMMON}"
  mkdir -p "${LINSHI_COMMON}"

  local common_sh_url="https://raw.githubusercontent.com/281677160/common/main/common.sh"
  local upgrade_sh_url="https://raw.githubusercontent.com/281677160/common/main/upgrade.sh"
  curl -fsSL "${common_sh_url}" -o "${LINSHI_COMMON}/common.sh"
  curl -fsSL "${upgrade_sh_url}" -o "${LINSHI_COMMON}/upgrade.sh"

  if grep -q "TIME" "${LINSHI_COMMON}/common.sh" && grep -q "Diy_Part2" "${LINSHI_COMMON}/upgrade.sh"; then
    cp -Rf "${COMPILE_PATH}" "${LINSHI_COMMON}/${FOLDER_NAME}"
    export DIY_PT1_SH="${LINSHI_COMMON}/${FOLDER_NAME}/diy-part.sh"
    export DIY_PT2_SH="${LINSHI_COMMON}/${FOLDER_NAME}/diy2-part.sh"

    echo '#!/bin/bash' > "${DIY_PT2_SH}"
    grep -E '.*export.*=".*"' "${DIY_PT1_SH}" >> "${DIY_PT2_SH}"
    chmod +x "${DIY_PT2_SH}"
    source "${DIY_PT2_SH}"

    grep -E 'grep -rl '.*'.*|.*xargs -r sed -i' "${DIY_PT1_SH}" >> "${DIY_PT2_SH}"
    sed -i 's/\. |/.\/feeds |/g' "${DIY_PT2_SH}"
    grep -E 'grep -rl '.*'.*|.*xargs -r sed -i' "${DIY_PT1_SH}" >> "${DIY_PT2_SH}"
    sed -i 's/\. |/.\/package |/g' "${DIY_PT2_SH}"
    sed -i 's?./packagefeeds?./feeds?g' "${DIY_PT2_SH}"
    grep -vE '^[[:space:]]*grep -rl '.*'.*|.*xargs -r sed -i' "${DIY_PT1_SH}" > tmp && mv tmp "${DIY_PT1_SH}"

    echo "OpenClash_branch=${OpenClash_branch}" >> "${GITHUB_ENV}"
    echo "Mandatory_theme=${Mandatory_theme}" >> "${GITHUB_ENV}"
    echo "Default_theme=${Default_theme}" >> "${GITHUB_ENV}"
    chmod -R +x "${OPERATES_PATH}"
    chmod -R +x "${LINSHI_COMMON}"
  else
    TIME r "common文件下载失败"
    exit 1
  fi
}

# 主函数
function Diy_memu() {
  local error_message=""
  if [[ -d "build" ]] && [[ -z "${BENDI_VERSION}" ]]; then
    rm -rf "${OPERATES_PATH}"
    cp -Rf "build" "${OPERATES_PATH}"
  fi

  Diy_two
  Diy_three
  if [[ ! "${TONGBU_YUANMA}" == "1" ]]; then
    Diy_four
  fi
}

# 执行主函数
Diy_memu "$@"
