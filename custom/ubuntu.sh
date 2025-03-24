#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) ImmortalWrt.org

function install_mustrelyon(){
# 安装编译openwrt的依赖
#sudo bash -c 'bash <(curl -s https://build-scripts.immortalwrt.eu.org/init_build_environment.sh)'
${INS} update > /dev/null 2>&1
#${INS} full-upgrade > /dev/null 2>&1
${INS} install $(curl -fsSL https://tinyurl.com/ubuntu2204-make-openwrt)

# N1打包需要的依赖
${INS} install rename pigz upx-ucl libfuse-dev clang


# 安装gcc-13
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo add-apt-repository ppa:ubuntu-toolchain-r/ppa
${INS} update > /dev/null 2>&1
${INS} install gcc-13
${INS} install g++-13
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 60 --slave /usr/bin/g++ g++ /usr/bin/g++-13
gcc --version
g++ --version
clang --version
}

function update_apt_source(){
${INS} autoremove --purge
sudo apt-get clean
}

function Delete_po2lmo(){
sudo rm -rf po2lmo
}

function main(){
	if [[ -n "${BENDI_VERSION}" ]]; then
		BENDI_VERSION="1"
		INS="sudo apt-get -y"
		echo "开始升级ubuntu插件和安装依赖....."
		install_mustrelyon
		update_apt_source
	else
		INS="sudo apt-get -y"
		install_mustrelyon
		update_apt_source
	fi
}

main
