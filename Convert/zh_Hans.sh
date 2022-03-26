#!/bin/bash

po_file="$({ find |grep -E "[a-z0-9]+\.zh\-cn.+po"; } 2>"/dev/null")"
for a in ${po_file}
do
	[ -n "$(grep "Language: zh_CN" "$a")" ] && sed -i "s/Language: zh_CN/Language: zh_Hans/g" "$a"
	po_new_file="$(echo -e "$a"|sed "s/zh-cn/zh_Hans/g")"
	mv "$a" "${po_new_file}" 2>"/dev/null"
done

po_file2="$({ find |grep "/zh-cn/" |grep "\.po"; } 2>"/dev/null")"
for b in ${po_file2}
do
	[[ `grep -c "Language: zh_Hans" "$b"` -eq '0' ]] && {
	sed -i -e '$!N;/\n.*charset=UTF-8/!P;D' "$b"
	sed -i -e '$!N;/\n.*charset=UTF-8/!P;D' "$b"
	sed -i '/charset=UTF-8/d' "$b"
	sed -i '1i msgid ""' "$b"
	sed -i '2i msgstr ""' "$b"
	sed -i '3i "openwrt/luciapplicationsacl/zh_Hans/>\\n"\n' "$b"
	sed -i '4i "Language: zh_Hans\\n"\n' "$b"
	sed -i '5i "Content-Type: text/plain; charset=UTF-8\\n"\n' "$b"
	sed -i '6i "Content-Transfer-Encoding: 8bit\\n"\n' "$b"
	}
	[ -n "$(grep "Language: zh_CN" "$b")" ] && sed -i "s/Language: zh_CN/Language: zh_Hans/g" "$b"
	po_new_file2="$(echo -e "$b"|sed "s/zh-cn/zh_Hans/g")"
	mv "$b" "${po_new_file2}" 2>"/dev/null"
done

lmo_file="$({ find |grep -E "[a-z0-9]+\.zh_Hans.+lmo"; } 2>"/dev/null")"
for c in ${lmo_file}
do
	lmo_new_file="$(echo -e "$c"|sed "s/zh_Hans/zh-cn/g")"
	mv "$c" "${lmo_new_file}" 2>"/dev/null"
done

lmo_file2="$({ find |grep "/zh_Hans/" |grep "\.lmo"; } 2>"/dev/null")"
for d in ${lmo_file2}
do
	lmo_new_file2="$(echo -e "$d"|sed "s/zh_Hans/zh-cn/g")"
	mv "$d" "${lmo_new_file2}" 2>"/dev/null"
done

po_dir="$({ find |grep "/zh-cn" |sed "/\.po/d" |sed "/\.lmo/d"; } 2>"/dev/null")"
for e in ${po_dir}
do
	po_new_dir="$(echo -e "$e"|sed "s/zh-cn/zh_Hans/g")"
	mv "$e" "${po_new_dir}" 2>"/dev/null"
done

makefile_file="$({ find |grep Makefile |sed "/Makefile./d"; } 2>"/dev/null")"
for f in ${makefile_file}
do
	[ -n "$(grep "zh-cn" "$f")" ] && sed -i "s/zh-cn/zh_Hans/g" "$f"
	[ -n "$(grep "zh_Hans.lmo" "$f")" ] && sed -i "s/zh_Hans.lmo/zh-cn.lmo/g" "$f"
done

exit 0
