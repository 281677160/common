#!/bin/bash

if [[ ! -d "build" ]]; then
  echo "根目录缺少build文件夹"
fi

if [[ ! -d "build/${FOLDER_NAME}" ]]; then
  echo "build文件夹内缺少${FOLDER_NAME}文件夹"
fi
