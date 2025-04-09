#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only

function install_mustrelyon(){
# 更新ubuntu源
${INS} update > /dev/null 2>&1

# 升级ubuntu
# ${INS} full-upgrade > /dev/null 2>&1

# 安装编译openwrt的依赖
${INS} install ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
swig texinfo uglifyjs unzip upx-ucl vim wget xmlto xxd zlib1g-dev

# N1打包需要的依赖
${INS} install rename pigz

# 安装clang
CLANG_REV="18"
curl -fsSL https://apt.llvm.org/llvm.sh -o llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh $CLANG_REV
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$CLANG_REV 100
sudo update-alternatives --config clang
sudo rm -rf llvm.sh

# 安装gcc g++
GCC_REV="13"
sudo add-apt-repository --yes ppa:ubuntu-toolchain-r/test
${INS} update > /dev/null 2>&1
${INS} install gcc-$GCC_REV g++-$GCC_REV
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$GCC_REV 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-$GCC_REV 100
sudo update-alternatives --config gcc
sudo update-alternatives --config g++

# 安装upx
UPX_REV="5.0.0"
sudo rm -rf upx-$UPX_REV-amd64_linux
sudo rm -rf upx-$UPX_REV-amd64_linux.tar.xz
curl -fLO "https://github.com/upx/upx/releases/download/v${UPX_REV}/upx-$UPX_REV-amd64_linux.tar.xz"
sudo tar -Jxf "upx-$UPX_REV-amd64_linux.tar.xz"
sudo rm -rf "/usr/bin/upx" "/usr/bin/upx-ucl"
sudo cp -fp "upx-$UPX_REV-amd64_linux/upx" "/usr/bin/upx-ucl"
sudo chmod 0755 "/usr/bin/upx-ucl"
sudo ln -svf "/usr/bin/upx-ucl" "/usr/bin/upx"
sudo rm -rf upx-$UPX_REV-amd64_linux
sudo rm -rf upx-$UPX_REV-amd64_linux.tar.xz

# 安装po2lmo
${INS} install libncurses-dev libssl-dev libgmp-dev libexpat1-dev python3-pip
sudo rm -rf po2lmo
git clone --filter=blob:none --no-checkout "https://github.com/openwrt/luci.git" "po2lmo"
pushd "po2lmo"
git config core.sparseCheckout true
echo "modules/luci-base/src" >> ".git/info/sparse-checkout"
git checkout
cd "modules/luci-base/src"
sudo make po2lmo
sudo strip "po2lmo"
sudo rm -rf "/usr/bin/po2lmo"
sudo cp -fp "po2lmo" "/usr/bin/po2lmo"
popd
sudo rm -rf po2lmo


gcc --version
g++ --version
clang --version
upx --version
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
