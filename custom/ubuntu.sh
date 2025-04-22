#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only

function install_mustrelyon(){
# 更新ubuntu源
apt-get update -y

# 升级ubuntu
apt-get full-upgrade -y

# 安装编译openwrt的依赖
apt-get install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
python3 python3-pyelftools python3-distutils python3-setuptools qemu-utils rsync scons squashfs-tools \
subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev

# alist依赖
apt-get install -y libfuse-dev

# N1打包需要的依赖
apt-get install -y rename pigz gnupg
apt-get install -y $(curl -fsSL https://tinyurl.com/ubuntu2204-make-openwrt)

TMP_DIR="$(mktemp -d)"
cd $TMP_DIR

# 安装clang
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh 18
apt-get update -y
apt-get install -y clang-18 lldb-18 lld-18 libc++-18-dev libc++abi-18-dev
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100


# 安装golang
GO_VERSION="1.24.2"
wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf /tmp/go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile.d/go.sh
source /etc/profile.d/go.sh

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

# 19.07
echo "python2.7"
wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
tar -xzf Python-2.7.18.tgz
apt-get install -y build-essential checkinstall
apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
cd Python-2.7.18
./configure
make
make install
cd ..
apt-get install -y ecj fastjar file gettext java-propose-classpath time xsltproc lib32gcc-s1 python3-distutils

# 安装nodejs yarn
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
apt-get install -y nodejs
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/yarnkey.gpg
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt-get update -y && apt-get install -y yarn gh

# 安装UPX
UPX_VERSION="5.0.0"
curl -fLO "https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-$UPX_VERSION-amd64_linux.tar.xz"
tar -Jxf "upx-$UPX_VERSION-amd64_linux.tar.xz"
rm -rf "/usr/bin/upx" "/usr/bin/upx-ucl"
cp -fp "upx-$UPX_VERSION-amd64_linux/upx" "/usr/bin/upx-ucl"
chmod 0755 "/usr/bin/upx-ucl"
ln -svf "/usr/bin/upx-ucl" "/usr/bin/upx"

# 安装padjffs2
git clone --filter=blob:none --no-checkout "https://github.com/openwrt/openwrt.git" "padjffs2"
pushd "padjffs2"
git config core.sparseCheckout true
echo "tools/padjffs2/src" >> ".git/info/sparse-checkout"
git checkout
cd "tools/padjffs2/src"
make padjffs2
strip "padjffs2"
rm -rf "/usr/bin/padjffs2"
cp -fp "padjffs2" "/usr/bin/padjffs2"
popd

# 安装po2lmo
git clone --filter=blob:none --no-checkout "https://github.com/openwrt/luci.git" "po2lmo"
pushd "po2lmo"
git config core.sparseCheckout true
echo "modules/luci-base/src" >> ".git/info/sparse-checkout"
git checkout
cd "modules/luci-base/src"
make po2lmo
strip "po2lmo"
rm -rf "/usr/bin/po2lmo"
cp -fp "po2lmo" "/usr/bin/po2lmo"
popd

curl -fL "https://build-scripts.immortalwrt.org/modify-firmware.sh" -o "/usr/bin/modify-firmware"
chmod 0755 "/usr/bin/modify-firmware"

cd ~
}

function update_apt_source(){
apt-get autoremove -y --purge
apt-get clean -y

python2.7 --version
node -v
yarn -v
go version
gcc --version
g++ --version
clang --version
upx --version
}

function main(){
	if [[ -n "${BENDI_VERSION}" ]]; then
		export BENDI_VERSION="1"
		echo "开始升级ubuntu插件和安装依赖....."
		install_mustrelyon
		update_apt_source
	else
                echo "开始升级ubuntu插件和安装依赖....."
		install_mustrelyon
		update_apt_source
	fi
}

main
