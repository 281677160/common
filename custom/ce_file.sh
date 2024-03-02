#!/bin/bash
if [[ $# -lt 2 ]]; then
  echo "Syntax error: [$#] [$*]" >&2
  return 1
fi
branch="$1" curl="$2" && shift 2
rootdir="/home/danshui/openwrt"
localdir="/home/danshui/openwrt/package/danshui"
[ -d "$localdir" ] || mkdir -p "$localdir"
tmpdir="$(mktemp -d)" || exit 1
trap 'rm -rf "$tmpdir"' EXIT
git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
cd "$tmpdir"
git sparse-checkout init --cone
git sparse-checkout set "$@"
mv -f "$@" "$localdir" && cd "$rootdir"
