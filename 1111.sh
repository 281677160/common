#!/bin/bash

# 示例URL
url="https://github.com/coolsnowwolf/lede/tree/master/package/firmware/armbian-firmware"
# https://github.com/coolsnowwolf/lede/blob/master/package/firmware/armbian-firmware/Makefile
# url="https://github.com/coolsnowwolf/lede"
HOME_PATH="$(pwd)"
tmpdir="$(mktemp -d)

# 判断URL中是否包含tree
if [[ "$url" == *"tree"* ]]; then
    # 提取tree前面的链接
    base_url="${url%/tree*}"
    echo "base_url: $base_url"

    # 提取账号跟仓库
    ck_name="$(echo "$base_url" | cut -d"/" -f4-5)"

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
    # 提取tree前面的链接
    base_url="${url%/blob*}"
    echo "base_url: $base_url"

    # 提取tree前面的第一个/值（即仓库名）
    repo_name=$(basename "$base_url")
    echo "repo_name: $repo_name"

    # 提取tree后的第一个/值（如master）
    after_tree="${url#*blob/}"
    branch="${after_tree%%/*}"
    echo "branch: $branch"

    # 提取master后面的值
    path_after_branch="${after_tree#*/}"
    echo "path_after_branch: $path_after_branch"

    # 确定最后的下载链接
    base_url="https://raw.githubusercontent.com/$ck_name/$branch/$path_after_branch"

    # 确定文件名称
    [[ -n "$path_files_branch" ]] && files_name="$path_files_branch" || echo "错误链接,文件名为空" && return
elif [[ "$url" == *"https://github.com"* ]]; then
    # 不包含tree的情况
    base_url="$url"
    echo "base_url: $base_url"
    
    # 提取最后一个/的内容
    last_part=$(basename "$base_url")
    echo "last_part: $last_part"

    # 确定文件名称
    [[ -n "$last_part" ]] && files_name="$last_part" || echo "错误链接,仓库名为空" && return
else
    echo "无效的github链接"
    return
fi

if [[ "$B" == "all" ]]; then
    store_away="$HOME_PATH/"
if [[ "$B" == *"openwrt"* ]]; then
    store_away="$HOME_PATH/${B#*openwrt/}"
elif [[ "$B" == *"./"* ]]; then
    store_away="$HOME_PATH/${B#*./}"
elif [[ -n "$B" ]]; then
    store_away="$HOME_PATH/$B"
else
    store_away="$HOME_PATH/$files_name"
fi

if [[ "$url" == *"tree"* ]] && [[ -n "$path_after_branch" ]]; then
    [[ "$B" == "all" ]] && path_name="$tmpdir/$path_after_branch/*" || path_name="$tmpdir/$path_after_branch"
    if git clone -q --no-checkout "$base_url" "$tmpdir"; then
        cd "$tmpdir"
        git sparse-checkout init --cone > /dev/null 2>&1
        git sparse-checkout set "$path_after_branch" > /dev/null 2>&1
        git checkout "$branch" > /dev/null 2>&1
        # 替换路径中的特定字符串
        grep -rl 'include ../../luci.mk' . | xargs -r sed -i 's#include ../../luci.mk#include \$(TOPDIR)/feeds/luci/luci.mk#g'
        grep -rl 'include ../../lang/' . | xargs -r sed -i 's#include ../../lang/#include \$(TOPDIR)/feeds/packages/lang/#g'
        cd $HOME_PATH
    else
        echo "$files_name文件下载失败"
        return
    fi
elif [[ "$url" == *"tree"* ]] && [[ -n "$branch" ]]; then
    [[ "$B" == "all" ]] && path_name="$tmpdir/*" || path_name="$tmpdir"
    if ! git clone -q --single-branch --depth=1 --branch=$branch $base_url $tmpdir; then
        echo "$files_name文件下载失败"
        return
    fi
elif [[ "$url" == *"blob"* ]]; then
    parent_dir="${store_away%/*}"
    [[ ! -d "$parent_dir" ]] && mkdir -p "$parent_dir"
    if ! curl -fsSL $branch -o $store_away; then
        echo "$files_name文件下载失败"
        return
    fi
elif [[ "$url" == *"https://github.com"* ]]; then
    [[ "$B" == "all" ]] && path_name="$tmpdir/*" || path_name="$tmpdir"
    if ! git clone -q --depth 1 $base_url $tmpdir; then
        echo "$files_name文件下载失败"
        return
    fi
else
    echo "无效的github链接"
    return
fi
