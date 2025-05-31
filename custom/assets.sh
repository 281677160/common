#!/bin/bash

function del_assets() {
    # 获取Release中的所有文件
    API_RESPONSE=$(curl -s -H "Authorization: token $REPO_TOKEN" \
        "https://api.github.com/repos/$GIT_REPOSITORY/releases/tags/$UPDATE_TAG")
    
    # 检查API响应是否有效
    if [ -z "$API_RESPONSE" ] || [ "$(echo "$API_RESPONSE" | jq -r '.message? // empty')" = "Not Found" ]; then
        echo "警告: 找不到标签 $UPDATE_TAG 对应的发布，可能已被删除"
        return 0
    fi

    # 检查assets是否存在
    if [ "$(echo "$API_RESPONSE" | jq -r '.assets')" = "null" ]; then
        echo "信息: 该发布没有资源文件"
        return 0
    fi

    # 提取符合条件的文件（使用try-catch模式）
    ASSETS=$(echo "$API_RESPONSE" | jq -r --arg regex "$DEL_FIRMWARE" \
        'try (.assets[]? | select(.name | test($regex)) | "\(.id) \(.name) \(.updated_at)") catch ""')

    # 计算符合条件的文件数量
    COUNT=$(echo "$ASSETS" | grep -c '^' || echo "0")

    # 检查是否有符合条件的文件（至少2个才继续，否则退出）
    if [ "$COUNT" -lt 2 ]; then
        echo "信息: 找到 $COUNT 个匹配文件，无需删除"
        return 0
    fi

    # 将文件按更新时间排序，最新的文件在最前
    readarray -t sorted_assets < <(echo "$ASSETS" | sort -k3,3 -r 2>/dev/null)

    # 删除除第一个文件（最新的）之外的所有文件
    for asset in "${sorted_assets[@]:1}"; do
        asset_id=$(echo "$asset" | awk '{print $1}')
        asset_name=$(echo "$asset" | awk '{print $2}')
        echo "删除旧的远程更新固件: $asset_name (ID: $asset_id)"
        curl -X DELETE -s -H "Authorization: token $REPO_TOKEN" \
            "https://api.github.com/repos/$GIT_REPOSITORY/releases/assets/$asset_id"
    done
}

if [ -n "$BOOT_TYPE" ]; then
    DEL_FIRMWARE="$FIRMWARE_PROFILEER-.*-$BOOT_TYPE-.*$FIRMWARE_SUFFIX"
    del_assets
fi

if [ -n "$BOOT_UEFI" ]; then
    DEL_FIRMWARE="$FIRMWARE_PROFILEER-.*-$BOOT_UEFI-.*$FIRMWARE_SUFFIX"
    del_assets
fi
