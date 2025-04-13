#!/bin/bash
# [CTCGFW]immortalwrt
# Use it under GPLv3, please.
# Convert translation files zh_Hans to zh-cn
# The script is still in testing, welcome to report bugs.
# ------------------------------- Start Conversion -------------------------------
convert_files=0
for X in $(find . -regex '.*zh-cn\|.*zh_Hans' -type f |grep po |grep -v "settings"); do rm -rf "${X}"; done

ha_file="$({ find . -type d -name "zh_Hans" | sed 's|/[^/]*$||' | sort -u; } 2>"/dev/null")"
for y in ${ha_file}
do
    [[ -d "$y/zh_Hans" && -d "$y/zh-cn" ]] && rm -rf "$y/zh_Hans"
    let convert_files++
done

po_file="$({ find |grep -E "[a-z0-9]+\.zh\-Hans.+po" |grep -v "settings"; } 2>"/dev/null")"
for a in ${po_file}
do
    [ -n "$(grep "Language: zh_Hans" "$a")" ] && sed -i "s/zh_Hans/zh_CN/g" "$a"
    po_new_file="$(echo -e "$a"|sed "s/zh_Hans/zh-cn/g")"
    mv "$a" "${po_new_file}" 2>"/dev/null"
    let convert_files++
done

po_file2="$({ find |grep "/zh_Hans/" |grep "\.po" |grep -v "settings"; } 2>"/dev/null")"
for b in ${po_file2}
do
    [ -n "$(grep "Language: zh_Hans" "$b")" ] && sed -i "s/zh_Hans/zh_CN/g" "$b"
    po_new_file2="$(echo -e "$b"|sed "s/zh_Hans/zh-cn/g")"
    mv "$b" "${po_new_file2}" 2>"/dev/null"
    let convert_files++
done

zh_file="$({ find |grep "/zh-cn/" |grep "\.po" |grep -v "settings"; } 2>"/dev/null")"
for h in ${zh_file}
do
    [ -n "$(grep "Language: zh_Hans" "$h")" ] && sed -i "s/zh_Hans/zh_CN/g" "$h"
    let convert_files++
done

lmo_file="$({ find |grep -E "[a-z0-9]+\.zh-cn.+lmo" |grep -v "settings"; } 2>"/dev/null")"
for c in ${lmo_file}
do
    lmo_new_file="$(echo -e "$c"|sed "s/zh-cn/zh_Hans/g")"
    mv "$c" "${lmo_new_file}" 2>"/dev/null"
    let convert_files++
done

lmo_file2="$({ find |grep "/zh-cn/" |grep "\.lmo" |grep -v "settings"; } 2>"/dev/null")"
for d in ${lmo_file2}
do
    lmo_new_file2="$(echo -e "$d"|sed "s/zh-cn/zh_Hans/g")"
    mv "$d" "${lmo_new_file2}" 2>"/dev/null"
    let convert_files++
done

po_dir="$({ find |grep "/zh_Hans" |sed "/\.po/d" |sed "/\.lmo/d" |grep -v "settings"; } 2>"/dev/null")"
for e in ${po_dir}
do
    po_new_dir="$(echo -e "$e"|sed "s/zh_Hans/zh-cn/g")"
    mv "$e" "${po_new_dir}" 2>"/dev/null"
    let convert_files++
done

makefile_file="$({ find|grep Makefile |sed "/Makefile./d" |grep -v "settings"; } 2>"/dev/null")"
for f in ${makefile_file}
do
    [ -n "$(grep "zh-cn" "$f")" ] && sed -i "s/zh_Hans/zh-cn/g" "$f"
    [ -n "$(grep "zh_Hans.lmo" "$f")" ] && sed -i "s/zh-cn.lmo/zh_Hans.lmo/g" "$f"
    let convert_files++
done
