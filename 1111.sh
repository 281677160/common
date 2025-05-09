#!/bin/bash

function Diy_firmware() {
gitsvn https://github.com/coolsnowwolf/lede/tree/master/package/firmware/armbian-firmware
gitsvn https://github.com/coolsnowwolf/lede/blob/master/package/firmware/armbian-firmware/Makefile ./package/firmware/armbian-firmware/Makefile
gitsvn https://github.com/coolsnowwolf/lede.git all
}

function gitsvn() {
url="${1%.git}"
route="$2"
HOME_PATH="$(pwd)"
tmpdir="$(mktemp -d)"

# 判断URL中是否包含tree
if [[ "$url" == *"tree"* ]]; then
    # 提取tree前面的链接
    base_url="${url%/tree*}"
    echo "base_url: $base_url"

    # 提取tree前面的第一个/值（即仓库名）
    repo_name=$(basename "$base_url")
    echo "repo_name: $repo_name"

    # 提取tree后的第一个/值（如master）
    after_tree="${url#*tree/}"
    branch="${after_tree%%/*}"
    echo "branch: $branch"

    # 提取master后面的值
    path_after_branch="${after_tree#*/}"
    echo "path_after_branch: $path_after_branch"

    # 提取最后一个/后的数值
    last_part="${path_after_branch##*/}"
    echo "last_part: $last_part"

    # 确定文件名称
    [[ -n "$last_part" ]] && files_name="$last_part" || files_name="$repo_name"
elif [[ "$url" == *"blob"* ]]; then
    # 提取blob前面的链接
    base_url="${url%/blob*}"
    echo "base_url: $base_url"

    # 提取账号跟仓库
    ck_name="$(echo "$base_url" | cut -d"/" -f4-5)"
    echo "ck_name: $ck_name"

    # 提取仓库名
    repo_name=$(basename "$base_url")
    echo "repo_name: $repo_name"

    # 提取blob后的第一个/值（如master）
    after_blob="${url#*blob/}"
    branch="${after_blob%%/*}"
    echo "branch: $branch"

    # 提取master后面的路径
    path_after_branch="${after_blob#*/}"
    echo "path_after_branch: $path_after_branch"

    # 确定最后的下载链接
    download_url="https://raw.githubusercontent.com/$ck_name/$branch/$path_after_branch"
    echo "download_url: $download_url"

    # 确定文件名称（使用路径中的最后一部分）
    files_name="${path_after_branch##*/}"
    [[ -z "$files_name" ]] && { echo "错误链接,文件名为空"; exit 1; }
elif [[ "$url" == *"https://github.com"* ]]; then
    # 不包含tree/blob的情况（完整仓库）
    base_url="$url"
    echo "base_url: $base_url"
    
    # 提取最后一个/的内容
    last_part=$(basename "$base_url")
    echo "last_part: $last_part"

    # 确定文件名称
    [[ -n "$last_part" ]] && files_name="$last_part" || { echo "错误链接,仓库名为空"; exit 1; }
else
    echo "无效的github链接"
    exit 1
fi

# 确定存储路径
if [[ "$route" == "all" ]]; then
    store_away="$HOME_PATH/"
elif [[ "$route" == *"openwrt"* ]]; then
    store_away="$HOME_PATH/${route#*openwrt/}"
elif [[ "$route" == *"./"* ]]; then
    store_away="$HOME_PATH/${route#*./}"
elif [[ -n "$route" ]]; then
    store_away="$HOME_PATH/$route"
else
    store_away="$HOME_PATH/$files_name"
fi

# 处理不同类型的URL
if [[ "$url" == *"tree"* ]] && [[ -n "$path_after_branch" ]]; then
    # 下载指定目录
    path_name="$tmpdir/$path_after_branch"
    if git clone -q --no-checkout "$base_url" "$tmpdir"; then
        cd "$tmpdir"
        git sparse-checkout init --cone > /dev/null 2>&1
        git sparse-checkout set "$path_after_branch" > /dev/null 2>&1
        git checkout "$branch" > /dev/null 2>&1
        
        # 替换路径中的特定字符串
        grep -rl 'include ../../luci.mk' . | xargs -r sed -i 's#include ../../luci.mk#include \$(TOPDIR)/feeds/luci/luci.mk#g'
        grep -rl 'include ../../lang/' . | xargs -r sed -i 's#include ../../lang/#include \$(TOPDIR)/feeds/packages/lang/#g'
        
        # 复制文件到目标位置
        if [[ "$route" == "all" ]]; then
            find "$path_name" -mindepth 1 -printf '%P\n' | while read -r item; do
            target="$HOME_PATH/${item}"
            if [ -e "$target" ]; then
                echo "匹配项: $target"
                rm -rf "$target"
            fi
            done
            cp -r "$path_name"/* "$store_away"
        else
            rm -rf "$store_away" && cp -r "$path_name" "$store_away"
        fi
        cd "$HOME_PATH"
    else
        echo "$files_name文件下载失败"
        exit 1
    fi
elif [[ "$url" == *"tree"* ]]; then
    # 下载整个仓库
    path_name="$tmpdir"
    if git clone -q --single-branch --depth=1 --branch="$branch" "$base_url" "$tmpdir"; then
        # 复制文件到目标位置
        if [[ "$route" == "all" ]]; then
            find "$path_name" -mindepth 1 -printf '%P\n' | while read -r item; do
            target="$HOME_PATH/${item}"
            if [ -e "$target" ]; then
                echo "匹配项: $target"
                rm -rf "$target"
            fi
            done
            cp -r "$path_name"/* "$store_away"
        else
            rm -rf "$store_away" && cp -r "$path_name" "$store_away"
        fi
    else
        echo "$files_name文件下载失败"
        exit 1
    fi
elif [[ "$url" == *"blob"* ]]; then
    # 下载单个文件
    parent_dir="${path_after_branch%/*}"
    [[ ! -d "${parent_dir}" ]] && mkdir -p "${parent_dir}"
    if curl -fsSL "$download_url" -o "$store_away"; then
        echo "$files_name 文件下载成功，保存到: $store_away"
    else
        echo "$files_name文件下载失败"
        exit 1
    fi
elif [[ "$url" == *"https://github.com"* ]]; then
    # 下载完整仓库
    path_name="$tmpdir"
    if git clone -q --depth 1 "$base_url" "$tmpdir"; then
        # 复制文件到目标位置
        if [[ "$route" == "all" ]]; then
            find "$path_name" -mindepth 1 -printf '%P\n' | while read -r item; do
            target="$HOME_PATH/${item}"
            if [ -e "$target" ]; then
                echo "匹配项: $target"
                rm -rf "$target"
            fi
            done
            cp -r "$path_name"/* "$store_away"
        else
            rm -rf "$store_away" && cp -r "$path_name" "$store_away"
        fi
    else
        echo "$files_name文件下载失败"
        exit 1
    fi
else
    echo "无效的github链接"
    exit 1
fi
}
