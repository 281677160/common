#!/bin/bash

# 获取Release中的所有文件
ASSETS=$(curl -s -H "Authorization: token $REPO_TOKEN" \
  "https://api.github.com/repos/$GIT_REPOSITORY/releases/tags/$UPDATE_TAG" \
  | jq -r --arg regex "$FIRMWARE_VERSION-.*-$BOOT_TYPE-.*$FIRMWARE_SUFFIX" '.assets[] | select(.name | test($regex)) | "\(.id) \(.name) \(.updated_at)"')

# 检查是否有符合条件的文件
if [ -z "$ASSETS" ]; then
  echo "没有找到符合条件的固件。"
  exit 0
fi

# 将文件按更新时间排序，保留时间最近的文件
# 使用-tac命令将排序结果反转，确保时间最近的文件在最后
readarray -t sorted_assets < <(echo "$ASSETS" | sort -k3,3 -r)

# 删除除最后一个文件之外的所有文件
for asset in "${sorted_assets[@]:0:${#sorted_assets[@]}-1}"; do
  asset_id=$(echo "$asset" | awk '{print $1}')
  asset_name=$(echo "$asset" | awk '{print $2}')
  echo "删除固件: $asset_name (ID: $asset_id)"
  curl -X DELETE -s -H "Authorization: token $REPO_TOKEN" \
    "https://api.github.com/repos/$GIT_REPOSITORY/releases/assets/$asset_id"
done

echo "操作完成。"
