#!/bin/bash
# https://github.com/281677160/build-actions  
# common Module by 28677160
# matrix.target=${FOLDER_NAME}

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
    # 更改LINSHI_COMMON变量时,需要同步修改本地编译文件和云编译的mishi文件
    export LINSHI_COMMON="/tmp/common"
    echo "LINSHI_COMMON=${LINSHI_COMMON}" >> "${GITHUB_ENV}"
    
    if [[ ! -d "${LINSHI_COMMON}" ]]; then
      TIME r "缺少对比版本号文件"
      SYNCHRONISE="NO"
      Diy_three
      Diy_four
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
            SYNCHRONISE="NO"
            [[ "${BENDI_VERSION}" == "2" ]] && TIME r "缺少编译主文件bulid，正在同步上游仓库..."
            [[ "${BENDI_VERSION}" == "1" ]] && TIME r "缺少编译主文件operates，正在同步上游仓库..."
            return
        fi
    done

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            if [[ "$file" == "${COMPILE_PATH}/seed/${CONFIG_FILE}" ]]; then
                TIME r "缺少 seed/${CONFIG_FILE} 文件，请先建立该文件"
                exit 1
            else
                SYNCHRONISE="NO"
                tongbu_message="缺少$file文件"
                TIME r "缺少$file文件，正在同步上游仓库..."
                return
            fi
        fi
    done

    if [[ -f "${COMPILE_PATH}/relevance/actions_version" ]]; then
        ACTIONS_VERSION2=$(sed -nE 's/^[[:space:]]*ACTIONS_VERSION[[:space:]]*=[[:space:]]*"?([0-9.]+)"?.*/\1/p' "${COMPILE_PATH}/relevance/actions_version")
        if [[ "$ACTIONS_VERSION1" != "$ACTIONS_VERSION2" ]]; then
            sudo rm -rf /etc/oprelyo*
            SYNCHRONISE="NO"
            tongbu_message="和上游版本不一致"
            TIME r "和上游版本不一致，正在同步上游仓库..."
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
                    echo 'PACKAGING_FIRMWARE="true"           # 自动把armsr_rootfs_tar_gz,打包成.img格式（true=开启）（false=关闭）' >> "$X"
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
                TIME y "因刚同步上游文件，请设置好 [operates] 文件夹内的配置后，再次使用命令编译"
                exit 1
            else
                TIME r "同步上游仓库失败，注意网络环境，请重新再运行命令试试"
                exit 1
            fi
        else
            rm -rf repogx shangyou
            git clone --depth=1 -b "${GIT_REFNAME}" https://user:${REPO_TOKEN}@github.com/${GIT_REPOSITORY}.git repogx
            if ! git clone -q --single-branch --depth=1 --branch=main https://github.com/281677160/build-actions shangyou; then
              git clone --depth=1 https://github.com/281677160/build-actions shangyou
            fi
            if [[ ! -d "repogx" ]]; then
              TIME r "同步上游仓库失败，请注意密匙制作时候勾选是否正确"
              exit 1
            fi
            if [[ ! -d "shangyou" ]]; then
              TIME r "下载上游仓库失败,请重新尝试看看"
              exit 1
            fi
            cd repogx
            git reset --hard HEAD
            cd "${GITHUB_WORKSPACE}"
            [[ -d "repogx/backups" ]] && rm -rf "repogx/backups"
            [[ -d "backups" ]] && rm -rf "backups"
            mkdir -p backups
            cp -Rf repogx/* backups
            cp -Rf repogx/.github/workflows backups/workflows
            cd repogx
            rm -rf *
            rm -rf .github/workflows/*
            cd "${GITHUB_WORKSPACE}"
            mkdir -p repogx/.github/workflows
            cp -Rf shangyou/* repogx
            cp -Rf shangyou/.github/workflows/* repogx/.github/workflows
            if [[ "$GIT_REPOSITORY" != "281677160/build-actions" ]]; then
                cp -Rf backups repogx/backups
            fi

            local relevance_dirs=($(find "${GITHUB_WORKSPACE}/repogx" -type d -name "relevance" | grep -v 'backups'))
            for X in "${relevance_dirs[@]}"; do
                rm -rf "${X}"/{*.ini,*start,run_number}
                echo "ACTIONS_VERSION=${ACTIONS_VERSION1}" > "${X}/actions_version"
                echo "请勿修改和删除此文件夹内的任何文件" > "${X}/README"
                echo "$(date +%Y%m%d%H%M%S)" > "${X}/start"
            done

            BANBEN_SHUOMING="同步上游于 $(date +%Y.%m%d.%H%M.%S)"
            chmod -R +x repogx
            cd repogx
            find "$UPLOAD" -type f -size +100M -exec rm -f {} \; || true
            git status
            git add .
            git commit -m "${BANBEN_SHUOMING}"
            PUSH_SUCCESS=false
            RETRY_COUNT=0
            MAX_RETRIES=5
            while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
              RETRY_COUNT=$((RETRY_COUNT+1))
              echo "尝试推送 (${RETRY_COUNT}/${MAX_RETRIES})..."
              # 每次重试前重置HEAD并重新添加文件
              if [ $RETRY_COUNT -gt 1 ]; then
                echo "重置HEAD并重新添加文件..."
                git reset --hard HEAD
                git add .
              fi
              if git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:${GIT_REFNAME}; then
                PUSH_SUCCESS=true
                break
              else
                echo "推送失败，尝试恢复..."
                # 清除可能损坏的缓存
                git gc --prune=now
                git remote prune origin
                # 增加随机延迟，避免持续峰值请求
                DELAY=$((RANDOM % 5 + 2))
                echo "等待${DELAY}秒后重试..."
                sleep $DELAY
              fi
            done

            # 检查推送结果
            if [ "$PUSH_SUCCESS" = false ]; then
              TIME r "同步上游仓库失败，请注意密匙是否正确"
            else
              TIME g "同步上游仓库完成，请重新设置好文件再继续编译"
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
    if grep -q "export" "${DIY_PT1_SH}"; then
      grep -E '.*export.*=".*"' "${DIY_PT1_SH}" >> "${DIY_PT2_SH}"
    fi
    chmod +x "${DIY_PT2_SH}"
    source "${DIY_PT2_SH}"

    if [[ -n "$(grep -Eo "grep -rl '.*'.*|.*xargs -r sed -i" "${DIY_PT1_SH}")" ]]; then
      grep -E 'grep -rl '.*'.*|.*xargs -r sed -i' "$DIY_PT1_SH" >> "${DIY_PT2_SH}"
      sed -i 's/\. |/${HOME_PATH}\/feeds |/g' "${DIY_PT2_SH}"
      grep -E 'grep -rl '.*'.*|.*xargs -r sed -i' "$DIY_PT1_SH" >> "${DIY_PT2_SH}"
      sed -i 's/\. |/${HOME_PATH}\/package |/g' "${DIY_PT2_SH}"
      grep -vE '^[[:space:]]*grep -rl '.*'.*|.*xargs -r sed -i' "${DIY_PT1_SH}" > tmp && mv tmp "${DIY_PT1_SH}"
    fi

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
    Diy_four
}

Diy_memu "$@"
