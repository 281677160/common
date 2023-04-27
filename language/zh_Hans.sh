#!/bin/bash
# [CTCGFW]Immortalwrt
# Use it under GPLv3, please.
# --------------------------------------------------------
# Convert translation files zh-cn to zh_Hans
# The script is still in testing, welcome to report bugs.

for X in $(find . -type l -name 'zh-cn' |grep po |grep -v "openclash\|store\|settings"); do rm -rf "${X}"; done
for X in $(find . -type f -name 'zh-cn' |grep po |grep -v "openclash\|store\|settings"); do rm -rf "${X}"; done
for X in $(find . -type l -name 'zh_Hans' |grep po |grep -v "openclash\|store\|settings"); do rm -rf "${X}"; done
for X in $(find . -type f -name 'zh_Hans' |grep po |grep -v "openclash\|store\|settings"); do rm -rf "${X}"; done


po_file="$({ find |grep -E "[a-z0-9]+\.zh\-cn.+po" |grep -v "openclash\|store\|settings"; } 2>"/dev/null")"
for a in ${po_file}
do
	po_new_file="$(echo -e "$a"|sed "s/zh-cn/zh_Hans/g")"
	mv "$a" "${po_new_file}" 2>"/dev/null"
done

po_file2="$({ find |grep "/zh-cn/" |grep "\.po" |grep -v "openclash\|store\|settings"; } 2>"/dev/null")"
for b in ${po_file2}
do
	cc="$(echo ${po_file2%/*})"
	dd="$(echo ${cc} |sed "s/zh-cn/zh_Hans/g")"
	if [[ -d "${cc}" ]] && [[ -d "${dd}" ]]; then
	  rm -rf ${dd}
	fi
	po_new_file2="$(echo -e "$b"|sed "s/zh-cn/zh_Hans/g")"
	mv "$b" "${po_new_file2}" 2>"/dev/null"
	sed -i "s?Language: .*\\\n?Language: zh_Hans\\\n?g" ${po_new_file2} > /dev/null 2>&1
done

lmo_file="$({ find |grep -E "[a-z0-9]+\.zh_Hans.+lmo" |grep -v "openclash\|store\|settings"; } 2>"/dev/null")"
for c in ${lmo_file}
do
	lmo_new_file="$(echo -e "$c"|sed "s/zh_Hans/zh-cn/g")"
	mv "$c" "${lmo_new_file}" 2>"/dev/null"
done

lmo_file2="$({ find |grep "/zh_Hans/" |grep -v "openclash\|store\|settings" |grep "\.lmo"; } 2>"/dev/null")"
for d in ${lmo_file2}
do
	lmo_new_file2="$(echo -e "$d"|sed "s/zh_Hans/zh-cn/g")"
	mv "$d" "${lmo_new_file2}" 2>"/dev/null"
done

po_dir="$({ find |grep "/zh-cn" |grep -v "openclash\|store\|settings" |sed "/\.po/d" |sed "/\.lmo/d"; } 2>"/dev/null")"
for e in ${po_dir}
do
	po_new_dir="$(echo -e "$e"|sed "s/zh-cn/zh_Hans/g")"
	mv "$e" "${po_new_dir}" 2>"/dev/null"
done

makefile_file="$({ find |grep Makefile |grep -v "openclash\|store\|settings" |sed "/Makefile./d"; } 2>"/dev/null")"
for f in ${makefile_file}
do
	[ -n "$(grep "zh-cn" "$f")" ] && sed -i "s/zh-cn/zh_Hans/g" "$f"
	[ -n "$(grep "zh_Hans.lmo" "$f")" ] && sed -i "s/zh_Hans.lmo/zh-cn.lmo/g" "$f"
done
exit 0
