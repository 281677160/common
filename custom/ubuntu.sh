#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
 
function install_mustrelyon(){
# 更新ubuntu源
${INS} update > /dev/null 2>&1

# 升级ubuntu
if [[ -n "${BENDI_VERSION}" ]]; then
  ${INS} full-upgrade > /dev/null 2>&1
fi

# 安装编译openwrt的依赖
sudo bash -c 'bash <(curl -s https://build-scripts.immortalwrt.org/init_build_environment.sh)'

# N1打包需要的依赖
${INS} install rename pigz clang

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
upx --version
}

function update_apt_source(){
${INS} autoremove --purge
${INS} clean
echo "依赖安装完毕"
}

function main(){
echo "开始升级ubuntu插件和安装依赖....."
INS="sudo apt-get -y"
install_mustrelyon
update_apt_source
}

main
