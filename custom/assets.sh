#!/bin/bash

function del_type() {
# 获取Release中的所有文件
ASSETS=$(curl -s -H "Authorization: token $REPO_TOKEN" \
  "https://api.github.com/repos/$GIT_REPOSITORY/releases/tags/$UPDATE_TAG" \
  | jq -r --arg regex "$DEL_FIRMWARE" '.assets[] | select(.name | test($regex)) | "\(.id) \(.name) \(.updated_at)"')

# 计算符合条件的文件数量
COUNT=$(echo "$ASSETS" | grep -c '^')

echo "$COUNT"

# 检查是否有符合条件的文件（至少2个才继续，否则退出）
if [ "$COUNT" -lt 2 ]; then
  exit 0
fi

# 将文件按更新时间排序，最新的文件在最前
readarray -t sorted_assets < <(echo "$ASSETS" | sort -k3,3 -r)

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
  echo "$BOOT_TYPE"
  DEL_FIRMWARE="$FIRMWARE_PROFILEER-.*-$BOOT_TYPE-.*$FIRMWARE_SUFFIX"
  del_type
fi

if [ -n "$BOOT_UEFI" ]; then
  echo "$BOOT_UEFI"
  DEL_FIRMWARE="$FIRMWARE_PROFILEER-.*-$BOOT_UEFI-.*$FIRMWARE_SUFFIX"
  del_type
fi
