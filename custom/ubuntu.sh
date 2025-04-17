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
${INS} ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
python2.7 python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev

# N1打包需要的依赖
${INS} install rename pigz clang

${INS} install build-essential asciidoc binutils bzip2 curl gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf

# 安装gcc-13
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo add-apt-repository ppa:ubuntu-toolchain-r/ppa
${INS} update > /dev/null 2>&1
${INS} install gcc-13
${INS} install g++-13
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 60 --slave /usr/bin/g++ g++ /usr/bin/g++-13

# 安装po2lmo
${INS} install libncurses-dev libssl-dev libgmp-dev libexpat1-dev python3-pip libpython3-dev
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
echo "依赖安装完毕"
}

function main(){
echo "开始升级ubuntu插件和安装依赖....."
INS="sudo apt-get -y"
install_mustrelyon
update_apt_source
}

main
