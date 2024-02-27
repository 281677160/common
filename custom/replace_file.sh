#!/bin/bash
# https://github.com/281677160/build-actions
# replace_file.sh Module by 28677160

if [[ $# -lt 2 ]]; then
  echo "格式错误,正确格式为: [svn_co] [文件夹或文件链接] [需要替换的文件夹或文件的对应路径],分别以空格分隔"
  return 1
fi
A="$1" B="$2" && shift 2
cd "${HOME_PATH}" && r="$PWD/"
rootdir="$(echo "${B}"|sed "s?${r}??g"|sed 's/^.\///')"
localdir="${HOME_PATH}/${rootdir}"
fssl="$(echo "${A}" |cut -d"/" -f4-5)"
curl="$(echo "${A}" |cut -d"/" -f1-5)"
crutch="$(echo "${A}" |cut -d"/" -f6)"
branch="$(echo "${A}" |cut -d"/" -f7)"
test="$(echo "${A}" |cut -d"/" -f8-)"
link="https://raw.githubusercontent.com/${fssl}/${branch}/${test}"
if [[ "${crutch}" == "blob" ]]; then
  curl -L "${link}" -o "${localdir}"
  if [[ $? -ne 0 ]]; then
    echo "${rootdir}文件下载失败,请检查网络,或查看链接正确性"
    return 1
  else
    echo "${rootdir}文件替换成功"
  fi
elif [[ "${crutch}" == "tree" ]]; then
  tmpdir="$(mktemp -d)" || exit 1
  trap 'rm -rf "${tmpdir}"' EXIT
  git clone -b "${branch}" --depth 1 --filter=blob:none --sparse "${curl}" "${tmpdir}"
  cd "${tmpdir}"
  git sparse-checkout init --cone
  git sparse-checkout set "${test}"
  if [[ $? -ne 0 ]]; then
    echo "${rootdir}文件夹下载失败,请检查网络,或查看链接正确性"
    return 1
  else
    echo "${rootdir}文件夹替换成功"
  fi
  sudo rm -rf "${localdir}" && cp -Rf "${test}" "${localdir}"
  cd "${HOME_PATH}" && sudo rm -rf "${tmpdir}"
else
  echo "${rootdir}替换文件操作失败,请保证链接正确性"
fi
