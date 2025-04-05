#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only

function install_mustrelyon(){
# 更新ubuntu源
#${INS} update > /dev/null 2>&1

# 升级ubuntu
# ${INS} full-upgrade > /dev/null 2>&1

# 安装编译openwrt的依赖
sudo bash -c 'bash <(curl -s https://build-scripts.immortalwrt.org/init_build_environment.sh)'

# N1打包需要的依赖
${INS} install rename pigz clang-14 libclang-14-dev upx-ucl build-essential
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
${INS} update
${INS} install gcc-13 g++-13
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 13
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 13
sudo update-alternatives --config gcc
sudo update-alternatives --config g++
gcc --version
g++ --version
clang --version
}

function update_apt_source(){
${INS} autoremove --purge
${INS} clean
}

function main(){
	if [[ -n "${BENDI_VERSION}" ]]; then
		export BENDI_VERSION="1"
		INS="sudo apt-get -y"
		echo "开始升级ubuntu插件和安装依赖....."
		install_mustrelyon
		update_apt_source
	else
		INS="sudo apt-get -y"
                echo "开始升级ubuntu插件和安装依赖....."
		install_mustrelyon
		update_apt_source
	fi
}

main
