#!/bin/bash

if [[ ! -d "build" ]]; then
  echo "根目录缺少build文件夹存在"
  exit 1
fi

if [[ ! -d "build/${FOLDER_NAME}" ]]; then
  echo "build文件夹内缺少${FOLDER_NAME}文件夹存在"
  exit 1
fi

git clone https://github.com/281677160/common build/common
mv -f build/common/upgrade.sh build/${FOLDER_NAME}/upgrade.sh
mv -f build/common/xiugai.sh build/${FOLDER_NAME}/common.sh
chmod -R +x build
