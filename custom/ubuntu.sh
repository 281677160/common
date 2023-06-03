#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) ImmortalWrt.org

function install_mustrelyon(){
# 安装依赖
sudo bash -c 'bash <(curl -s https://build-scripts.immortalwrt.eu.org/init_build_environment.sh)'
sudo apt-get install -y rename pigz libfuse-dev upx subversion
sudo apt-get install -y $(curl -fsSL https://is.gd/depend_ubuntu2204_openwrt)
}

function Delete_useless(){
# 删除一些不需要的东西
docker rmi `docker images -q`
sudo rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /usr/lib/jvm /opt/ghc /swapfile
# sudo -E apt-get -qq remove -y --purge azure-cli ghc* zulu* llvm* firefox google* powershell openjdk* msodbcsql17 mongodb* moby* snapd* mysql*
}

function update_apt_source(){
node --version
yarn --version
sudo apt-get autoremove -y --purge
sudo apt-get clean
}

function main(){
	if [[ -n "${BENDI_VERSION}" ]]; then
		BENDI_VERSION="1"
		INS="sudo apt-get"
		echo "开始升级ubuntu插件和安装依赖....."
		install_mustrelyon
		update_apt_source
	else
		INS="sudo -E apt-get -qq"
		install_mustrelyon
		Delete_useless
		update_apt_source
	fi
}

main
