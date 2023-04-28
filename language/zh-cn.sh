#!/bin/bash
# [CTCGFW]Immortalwrt
# Use it under GPLv3, please.
# --------------------------------------------------------
# Convert translation files zh-cn to zh_Hans
# The script is still in testing, welcome to report bugs.

for X in $(find . -type l -name 'zh-cn' |grep po |grep -v "openclash\|store"); do rm -rf "${X}"; done
for X in $(find . -type f -name 'zh-cn' |grep po |grep -v "openclash\|store"); do rm -rf "${X}"; done
for X in $(find . -type l -name 'zh_Hans' |grep po |grep -v "openclash\|store"); do rm -rf "${X}"; done
for X in $(find . -type f -name 'zh_Hans' |grep po |grep -v "openclash\|store"); do rm -rf "${X}"; done

po_file="$({ find |grep -E "[a-z0-9]+\.zh\_Hans.+po" |grep -v "openclash\|store"; } 2>"/dev/null")"
for a in ${po_file}
do
	[ -n "$(grep "Language: zh_Hans" "$a")" ] && sed -i "s/Language: zh_Hans/Language: zh_CN/g" "$a"
	po_new_file="$(echo -e "$a"|sed "s/zh_Hans/zh-cn/g")"
	mv "$a" "${po_new_file}" 2>"/dev/null"
done

po_file2="$({ find |grep "/zh_Hans/" |grep "\.po" |grep -v "openclash\|store"; } 2>"/dev/null")"
for b in ${po_file2}
do
	[ -n "$(grep "Language: zh_Hans" "$b")" ] && sed -i "s/Language: zh_Hans/Language: zh_CN/g" "$b"
	cc="$(echo ${po_file2%/*})"
	dd="$(echo ${cc} |sed "s/zh_Hans/zh-cn/g")"
	[[ -d "${cc}" && -d "${dd}" ]] && rm -rf "${dd}"
	po_new_file2="$(echo -e "$b"|sed "s/zh_Hans/zh-cn/g")"
	mv "$b" "${po_new_file2}" 2>"/dev/null"
done

lmo_file="$({ find |grep -E "[a-z0-9]+\.zh-cn.+lmo" |grep -v "openclash\|store"; } 2>"/dev/null")"
for c in ${lmo_file}
do
	lmo_new_file="$(echo -e "$c"|sed "s/zh-cn/zh_Hans/g")"
	mv "$c" "${lmo_new_file}" 2>"/dev/null"
done

lmo_file2="$({ find |grep "/zh-cn/" |grep "\.lmo" |grep -v "openclash\|store"; } 2>"/dev/null")"
for d in ${lmo_file2}
do
	lmo_new_file2="$(echo -e "$d"|sed "s/zh-cn/zh_Hans/g")"
	mv "$d" "${lmo_new_file2}" 2>"/dev/null"
done

po_dir="$({ find |grep "/zh_Hans" |grep -v "openclash\|store" |sed "/\.po/d" |sed "/\.lmo/d"; } 2>"/dev/null")"
for e in ${po_dir}
do
	po_new_dir="$(echo -e "$e"|sed "s/zh_Hans/zh-cn/g")"
	mv "$e" "${po_new_dir}" 2>"/dev/null"
done

makefile_file="$({ find |grep Makefile |grep -v "openclash\|store\|settings" |sed "/Makefile./d"; } 2>"/dev/null")"
for f in ${makefile_file}
do
	[ -n "$(grep "zh_Hans" "$f")" ] && sed -i "s/zh_Hans/zh-cn/g" "$f"
	[ -n "$(grep "zh_Hans.lmo" "$f")" ] && sed -i "s/zh_Hans.lmo/zh-cn.lmo/g" "$f"
done

settings_file="$({ find |grep Makefile |grep default-settings |sed "/Makefile./d"; } 2>"/dev/null")"
for f in ${settings_file}
do
	if [ -z "$(grep "LUCI_LANG_zh-cn" "$f")" ] && [ -z "$(grep "LUCI_LANG_zh_Hans" "$f")" ]; then
		sed -i "s?DEPENDS:=?DEPENDS:=\+\@LUCI_LANG_zh-cn ?g" "$f"
	elif [ -n "$(grep "LUCI_LANG_zh_Hans" "$f")" ]; then
		sed -i "s/LUCI_LANG_zh_Hans/LUCI_LANG_zh-cn/g" "$f"
	fi
done
exit 0
