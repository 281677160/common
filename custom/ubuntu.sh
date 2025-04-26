#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
PWD_DIR="$(pwd)"

function install_mustrelyon(){
echo -e "\033[36m开始升级ubuntu插件和安装依赖.....\033[0m"
# 更新ubuntu源
apt-get update -y

# 升级ubuntu
apt-get full-upgrade -y

# 安装编译openwrt的依赖
apt-get install -y ecj fastjar file gettext java-propose-classpath time xsltproc lib32gcc-s1
apt-get install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
python2 python3 python3-pip python3-cryptography python3-docutils python3-ply python3-pyelftools python3-requests \
python3-setuptools python3-distutils qemu-utils rsync scons squashfs-tools subversion swig \
texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev

# alist依赖
apt-get install -y libfuse-dev

# N1打包需要的依赖
apt-get install -y rename pigz clang gnupg
apt-get install -y $(curl -fsSL https://tinyurl.com/ubuntu2204-make-openwrt)

# 修改21.02编译gn失败
pip install mistune --upgrade
pip install -U --force-reinstall scipy

# 安装gcc g++
GCC_VERSION="13"
add-apt-repository --yes ppa:ubuntu-toolchain-r/test
apt-get update
apt-get install gcc-${GCC_VERSION}
apt-get install g++-${GCC_VERSION}
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} 60
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION} 60
update-alternatives --config gcc
update-alternatives --config g++

# 清理缓存
apt-get autoremove -y --purge
apt-get clean
}

function update_apt_source(){
sudo apt-get autoremove -y --purge
node --version
yarn --version
sudo apt-get clean
}

function Delete_po2lmo(){
sudo rm -rf po2lmo
}

function main(){
	if [[ -n "${BENDI_VERSION}" ]]; then
		BENDI_VERSION="1"
		INS="sudo apt-get"
		echo "开始升级ubuntu插件和安装依赖....."
		install_mustrelyon
		update_apt_source
		Delete_po2lmo
	else
		INS="sudo -E apt-get -qq"
		install_mustrelyon
		Delete_useless
		update_apt_source
	fi
}

main
