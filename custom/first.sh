#!/bin/bash
# https://github.com/281677160/build-actions  
# common Module by 28677160
# matrix.target=${FOLDER_NAME}

export TONGBU_YUANMA=""
export SYNCHRONISE=""

# 颜色输出函数
function TIME() {
  case "$1" in
    r) local Color="\033[0;31m";;
    g) local Color="\033[0;32m";;
    y) local Color="\033[0;33m";;
    b) local Color="\033[0;34m";;
    z) local Color="\033[0;35m";;
    l) local Color="\033[0;36m";;
    *) local Color="\033[0;0m";;
  esac
echo -e "\n${Color}${2}\033[0m"
}

# 第一个自定义函数
Diy_one() {
    cd "${GITHUB_WORKSPACE}"
    LINSHI_COMMON="/tmp/common"
    [[ -d "${LINSHI_COMMON}" ]] && rm -rf "${LINSHI_COMMON}"
    if ! git clone -q --single-branch --depth=1 --branch=main https://github.com/281677160/common "${LINSHI_COMMON}"; then
      TIME r "对比版本号文件下载失败，请检查网络"
      exit 1
    fi
    export COMMON_SH="${LINSHI_COMMON}/common.sh"
    export UPGRADE_SH="${LINSHI_COMMON}/upgrade.sh"
    export CONFIG_TXT="${LINSHI_COMMON}/config.txt"
    export ACTIONS_VERSION1=$(sed -nE 's/^[[:space:]]*ACTIONS_VERSION[[:space:]]*=[[:space:]]*"?([0-9.]+)"?.*/\1/p' "${COMMON_SH}")
    
    if [[ -d "build" ]] && [[ "${BENDI_VERSION}" == "2" ]]; then
        rm -rf "${OPERATES_PATH}"
        cp -Rf build "${OPERATES_PATH}"
    fi
}

# 第二个自定义函数
Diy_two() {
    cd "${GITHUB_WORKSPACE}"
    local required_dirs=("${OPERATES_PATH}" "${COMPILE_PATH}")
    local required_files=("${BUILD_PARTSH}" "${BUILD_SETTINGS}" "${COMPILE_PATH}/relevance/actions_version" "${COMPILE_PATH}/seed/${CONFIG_FILE}")

    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            TIME r "缺少 $dir 文件夹"
            SYNCHRONISE="NO"
            tongbu_message="缺少编译必要文件夹"
            return
        fi
    done

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            if [[ "$file" == "${COMPILE_PATH}/seed/${CONFIG_FILE}" ]]; then
                TIME r "缺少 seed/${CONFIG_FILE} 文件，请先建立该文件"
                exit 1
            else
                TIME r "缺少 $file 文件"
                SYNCHRONISE="NO"
                tongbu_message="缺少文件"
                return
            fi
        fi
    done

    if [[ -f "${COMPILE_PATH}/relevance/actions_version" ]]; then
        ACTIONS_VERSION2=$(sed -nE 's/^[[:space:]]*ACTIONS_VERSION[[:space:]]*=[[:space:]]*"?([0-9.]+)"?.*/\1/p' "${COMPILE_PATH}/relevance/actions_version")
        if [[ "$ACTIONS_VERSION1" != "$ACTIONS_VERSION2" ]]; then
            sudo rm -rf /etc/oprelyo*
            TIME r "和上游版本不一致"
            SYNCHRONISE="NO"
            tongbu_message="和上游版本不一致"
        else
            SYNCHRONISE="YES"
        fi
    else
        SYNCHRONISE="YES"
    fi
}

# 第三个自定义函数
Diy_three() {
    cd "${GITHUB_WORKSPACE}"
    if [[ "$SYNCHRONISE" == "NO" ]]; then
        if [[ "${BENDI_VERSION}" == "1" ]]; then
            TIME r "${tongbu_message}，正在同步上游仓库"
            shangyou=$(mktemp -d)
            if git clone --single-branch --depth=1 --branch=main https://github.com/281677160/build-actions "${shangyou}"; then
                if [[ -d "${OPERATES_PATH}" ]]; then
                    mv "${OPERATES_PATH}" backups
                    cp -Rf "$shangyou/build" "${OPERATES_PATH}"
                    mv backups "${OPERATES_PATH}/backups"
                else
                    cp -Rf "$shangyou/build" "${OPERATES_PATH}"
                fi
                rm -rf "$shangyou"
                chmod -R +x "${OPERATES_PATH}"

                local settings_files=($(find "${OPERATES_PATH}" -name "settings.ini"))
                for X in "${settings_files[@]}"; do
                    sed -i '/SSH_ACTIONS/d' "$X"
                    sed -i '/INFORMATION_NOTICE/d' "$X"
                    sed -i '/UPLOAD_FIRMWARE/d' "$X"
                    sed -i '/UPLOAD_RELEASE/d' "$X"
                    sed -i '/CACHEWRTBUILD_SWITCH/d' "$X"
                    sed -i '/COMPILATION_INFORMATION/d' "$X"
                    sed -i '/UPDATE_FIRMWARE_ONLINE/d' "$X"
                    sed -i '/RETAIN_DAYS/d' "$X"
                    sed -i '/RETAIN_MINUTE/d' "$X"
                    sed -i '/KEEP_LATEST/d' "$X"
                    echo 'PACKAGING_FIRMWARE="true"           # 自动把aarch64系列固件,打包成.img格式（true=开启）（false=关闭）' >> "$X"
                    echo 'MODIFY_CONFIGURATION="true"         # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "$X"
                done

                local relevance_dirs=($(find "${OPERATES_PATH}" -type d -name "relevance" | grep -v 'backups'))
                for X in "${relevance_dirs[@]}"; do
                    rm -rf "${X}"/{*.ini,*start,run_number}
                    echo "ACTIONS_VERSION=${ACTIONS_VERSION1}" > "${X}/actions_version"
                    echo "请勿修改和删除此文件夹内的任何文件" > "${X}/README"
                    echo "$(date +%Y%m%d%H%M%S)" > "${X}/start"
                done

                if [[ -d "${OPERATES_PATH}/backups" ]]; then
                    TIME g "同步上游仓库完成，operates 文件夹内有个 backups 备份包，您以前的文件都存放在这里"
                else
                    TIME g "同步上游仓库完成"
                fi
                TIME r "因刚同步上游文件，请设置好 [operates] 文件夹内的配置后，再次使用命令编译"
                export TONGBU_YUANMA="1"
            else
                TIME r "同步上游仓库失败，注意网络环境，请重新再运行命令试试"
                export TONGBU_YUANMA="1"
                exit 1
            fi
        else
            git clone -b "${GIT_REFNAME}" https://user:${REPO_TOKEN}@github.com/${GIT_REPOSITORY}.git repogx
            git clone -q --single-branch --depth=1 --branch=main https://github.com/281677160/build-actions shangyou
            [[ -d "repogx/backups" ]] && rm -rf "repogx/backups"
            [[ -d "backups" ]] && rm -rf "backups"
            mkdir -p backups
            cp -Rf repogx/* backups
            cp -Rf repogx/.github/workflows backups/workflows
            cd repogx
            rm -rf *
            git rm --cache *
            cd "${GITHUB_WORKSPACE}"
            rsync -a shangyou/ repogx/
            if [[ "$GIT_REPOSITORY" != "281677160/build-actions" ]]; then
                cp -Rf backups repogx/backups
            fi

            local relevance_dirs=($(find "${GITHUB_WORKSPACE}/repogx" -type d -name "relevance" | grep -v 'backups'))
            for X in "${relevance_dirs[@]}"; do
                rm -rf "${X}"/{*.ini,*start,run_number}
                echo "ACTIONS_VERSION=${ACTIONS_VERSION1}" > "${X}/actions_version"
                echo "请勿修改和删除此文件夹内的任何文件" > "${X}/README"
                echo "$(date +%Y%m%d%H%M%S)" > "${X}/start"
                echo "$(date +%Y%m%d%H%M%S)" > "${X}/armsrstart"
            done

            BANBEN_SHUOMING="同步上游于 $(date +%Y.%m%d.%H%M.%S)"
            chmod -R +x repogx
            cd repogx
            git add .
            git commit -m "${BANBEN_SHUOMING}"
            git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:${GIT_REFNAME}
            if [[ $? -ne 0 ]]; then
                TIME r "同步上游仓库失败，请注意密匙是否正确"
            else
                TIME r "同步上游仓库完成，请重新设置好文件再继续编译"
            fi
            exit 1
        fi
    fi
}

# 第四个自定义函数
Diy_four() {
    cp -Rf "${COMPILE_PATH}" "${LINSHI_COMMON}/${FOLDER_NAME}"
    export DIY_PT1_SH="${LINSHI_COMMON}/${FOLDER_NAME}/diy-part.sh"
    export DIY_PT2_SH="${LINSHI_COMMON}/${FOLDER_NAME}/diy2-part.sh"

    echo "DIY_PT1_SH=${DIY_PT1_SH}" >> "${GITHUB_ENV}"
    echo "DIY_PT2_SH=${DIY_PT2_SH}" >> "${GITHUB_ENV}"
    echo "COMMON_SH=${COMMON_SH}" >> "${GITHUB_ENV}"
    echo "UPGRADE_SH=${UPGRADE_SH}" >> "${GITHUB_ENV}"
    echo "CONFIG_TXT=${CONFIG_TXT}" >> "${GITHUB_ENV}"

    echo '#!/bin/bash' > "${DIY_PT2_SH}"
    grep -E '.*export.*=".*"' "$DIY_PT1_SH" >> "${DIY_PT2_SH}"
    chmod +x "${DIY_PT2_SH}"
    source "${DIY_PT2_SH}"

    grep -E 'grep -rl '.*'.*|.*xargs -r sed -i' "$DIY_PT1_SH" >> "${DIY_PT2_SH}"
    sed -i 's/\. |/${HOME_PATH}\/feeds |/g' "${DIY_PT2_SH}"
    grep -E 'grep -rl '.*'.*|.*xargs -r sed -i' "$DIY_PT1_SH" >> "${DIY_PT2_SH}"
    sed -i 's/\. |/${HOME_PATH}\/package |/g' "${DIY_PT2_SH}"
    sed -i 's?packagefeeds?feeds?g' "${DIY_PT2_SH}"
    grep -vE '^[[:space:]]*grep -rl '.*'.*|.*xargs -r sed -i' "$DIY_PT1_SH" > tmp && mv tmp "$DIY_PT1_SH"

    echo "OpenClash_branch=${OpenClash_branch}" >> "${GITHUB_ENV}"
    echo "Mandatory_theme=${Mandatory_theme}" >> "${GITHUB_ENV}"
    echo "Default_theme=${Default_theme}" >> "${GITHUB_ENV}"
    chmod -R +x "${OPERATES_PATH}"
    chmod -R +x "${LINSHI_COMMON}"
}

# 主菜单函数
Diy_memu() {
    Diy_one
    Diy_two
    Diy_three
    if [[ "$TONGBU_YUANMA" != "1" ]]; then
        Diy_four
    fi
}

Diy_memu "$@"
