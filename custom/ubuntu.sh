#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only

function get_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        version_id=$(grep "VERSION_ID" /etc/os-release | cut -d '"' -f 2)
        echo "$version_id"
    else
        echo "错误：非Ubuntu系统或缺少/etc/os-release文件" >&2
        exit 1
    fi
}

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

# 19.07
apt-get install -y ecj fastjar file gettext java-propose-classpath lib32gcc-s1 python2 python2.7-dev time xsltproc gh

# alist依赖
apt-get install -y libfuse-dev

# N1打包需要的依赖
apt-get install -y rename pigz
apt-get install -y $(curl -fsSL https://tinyurl.com/ubuntu2204-make-openwrt)
}

function install_tools() {
    version=$1
    case "$version" in
        "18.04")
            echo "[+] Ubuntu 18.04安装：clang-18 + golang-1.24 + gcc-13"
            sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test  # 添加Toolchain PPA:ml-citation{ref="3,8" data="citationList"}
            apt-get update -y && apt-get install -y clang-18  gcc-13 golang-1.24
            ;;
        "22.04")
            echo "[+] Ubuntu 22.04安装：nodejs-22 + yarn + gcc-13"
            curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
            sudo apt update && apt-get install -y nodejs clang-18 gcc-13 golang-1.24
            curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/yarnkey.gpg
            echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            apt-get update -y && apt-get install -y yarn
            ;;
        "24.04")
            echo "[+] Ubuntu 24.04安装：全组件(nodejs-22/yarn/clang-18/golang-1.24/gcc-13)"
            curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
            sudo apt update && apt-get install -y nodejs clang-18 gcc-13 golang-1.24
            curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/yarnkey.gpg
            echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            apt-get update -y && apt-get install -y yarn
            ;;
        *)
            echo "[!] 不支持的版本：$version，仅支持18.04/22.04/24.04"
            exit 2
            ;;
    esac
}

function install_miscellaneous() {
TMP_DIR="$(mktemp -d)"
cd $TMP_DIR
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
		current_version=$(get_ubuntu_version)
		install_tools "$current_version"
  		get_ubuntu_version
		install_mustrelyon
		install_miscellaneous
		update_apt_source
		echo "[√] 安装完成！"
	else
                echo "开始升级ubuntu插件和安装依赖....."
		current_version=$(get_ubuntu_version)
		install_tools "$current_version"
		get_ubuntu_version
		install_mustrelyon
		install_miscellaneous
		update_apt_source
		echo "[√] 安装完成！"
	fi
}

main
