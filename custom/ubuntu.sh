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
${INS} install ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
python2.7 python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
swig texinfo uglifyjs unzip upx-ucl vim wget xmlto xxd zlib1g-dev

# N1打包需要的依赖
${INS} install rename pigz clang

# 安装gcc-13
sudo add-apt-repository --yes ppa:ubuntu-toolchain-r/test
${INS} update > /dev/null 2>&1
${INS} install gcc-13 g++-13
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 60
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 60

wget -q https://apt.llvm.org/llvm.sh -O /tmp/llvm.sh
chmod +x /tmp/llvm.sh
sudo ./tmp/llvm.sh 18
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100

gcc --version
g++ --version
clang --version
upx --version
echo "依赖安装完毕"
}

function update_apt_source(){
${INS} autoremove --purge
${INS} clean
}

function main(){
echo "开始升级ubuntu插件和安装依赖....."
INS="sudo apt-get -y"
install_mustrelyon
update_apt_source
}

main
