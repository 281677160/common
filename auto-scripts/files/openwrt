#!/bin/sh

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"
Input_Optio=$1

function ECHOY() {
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}
function ECHOR() {
  echo -e "${Red} $1 ${Font}"
}
function ECHOB() {
  echo
  echo -e "${Blue} $1 ${Font}"
  echo
}
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOG() {
  echo
  echo -e "${Green} $1 ${Font}"
}
function print_ok() {
  echo
  echo -e " ${OK} ${Blue} $1 ${Font}"
  echo
}
function print_error() {
  echo
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
  echo
}
judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 完成,正在为您重启系统"
    reboot -f
  else
    print_error "$1 失败"
    exit 0
  fi
}

function xiugai_ip() {
  echo
  export YUMING="请输入您想要更改成的后台IP(tian xie ni de IP)"
  echo
  while :; do
  domainy=""
  read -p " ${YUMING}：" domain
  if [[ -n "${domain}" ]] && [[ "$(echo ${domain} |grep -Eoc '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')" == '1' ]]; then
    domainy="Y"
  fi
  case $domainy in
  Y)
    export domain="${domain}"
    uci set network.lan.ipaddr="${domain}"
    uci commit network
    ECHOG "您的IP为：${domain}"
    ECHOY "正在为您清空密码"
    if [[ `grep -c "admin" /etc/shadow` -eq '1' ]]; then
      passwd -d admin
      passwd -d root
      judge
    else
      passwd -d root
      judge
    fi
  break
  ;;
  *)
    export YUMING="敬告：请输入正确格式的IP"
  ;;
  esac
  done
}

function qingkong_mima() {
while :; do
read -p "否清空密码(shi fou qing kong mi ma)[Y/n]：" YN
case ${YN} in
[Yy]) 
    if [[ `grep -c "admin" /etc/shadow` -eq '1' ]]; then
      passwd -d admin
      passwd -d root
    else
      passwd -d root
    fi
    judge
break
;;
[Nn])
    ECHOR "退出操作(tui chu)"
    exit 0
break
;;
*)
    ECHOR "输入正确选择[Y/n]"
;;
esac
done
}

function re_boot() {
echo
while :; do
read -p "是否重启系统(shi fou chong qi xi tong)[Y/n]：" YN
case ${YN} in
[Yy]) 
    ECHOG "系统重启中，稍后自行登录openwrt后台"
    uci set argon.@global[0].bing_background=0
    uci commit argon
    reboot -f
    judge
break
;;
[Nn])
    ECHOR "退出操作(tui chu)"
    exit 0
break
;;
*)
    ECHOR "输入正确选择[Y/n]"
;;
esac
done
}

function first_boot() {
  echo
  echo
  ECHOR "是否恢复出厂设置?按[Y/y]执行,按[N/n]退出"
  firstboot
  judge
}

function rm_init() {
rm -rf /tmp/luci-modulecache/
rm -rf /tmp/luci-indexcache
/etc/init.d/uhttpd restart
/etc/init.d/network restart
/etc/init.d/dnsmasq restart
/etc/init.d/system restart
if [[ `grep -c "/tmp/luci-\*cache\*" /etc/crontabs/root` -eq '0' ]]; then
  echo "0 1 * * 1 rm -rf /tmp/luci-*cache* > /dev/null 2>&1" >> /etc/crontabs/root
  /etc/init.d/cron restart
fi
}

function ks_reboot() {
if [ -f "/etc/default-setting" ]; then
  rm -rf /etc/default-setting
fi
sed -i '/openwrt -r/d' "/etc/init.d/Postapplication"
sleep 2
if [[ `grep -c "openwrt -r" /etc/init.d/Postapplication` -ge '1' ]]; then
  sed -i "s?openwrt -r??g" "/etc/init.d/Postapplication"
fi
reboot
}

menu2() {
  clear
  echo  
  ECHOB "  请选择执行命令编码"
  ECHOYY " 1. 修改后台IP和清空密码(xiu gai hou tai IP)"
  ECHOY " 2. 清空密码(qing kong mi ma)"
  ECHOYY " 3. 重启系统(chong qi xi tong)"
  ECHOY " 4. 恢复出厂设置(hui fu chu chang she zhi)"
  ECHOYY " 5. 退出(tui chu)"
  echo
  XUANZHEOP="请输入数字"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      xiugai_ip
    break
    ;;
    2)
      qingkong_mima
    break
    ;;
    3)
      re_boot
    break
    ;;
    4)
      first_boot
    break
    ;;
    5)
      ECHOR "您选择了退出程序"
      exit 0
    break
    ;;
    *)
      XUANZHEOP="请输入正确的数字编号"
    ;;
    esac
    done
}

menu() {
  clear
  echo  
  ECHOB "  请选择执行命令编码"
  ECHOY " 1. 在线更新固件或转换其他作者固件(zai xian sheng ji gu jian)"
  ECHOYY " 2. 修改后台IP和清空密码(xiu gai hou tai IP)"
  ECHOY " 3. 清空密码(qing kong mi ma)"
  ECHOYY " 4. 重启系统(chong qi xi tong)"
  ECHOY " 5. 恢复出厂设置(hui fu chu chang she zhi)"
  ECHOYY " 6. 退出(tui chu)"
  echo
  XUANZHEOP="请输入数字"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      replace -u
    break
    ;;
    2)
      xiugai_ip
    break
    ;;
    3)
      qingkong_mima
    break
    ;;
    4)
      re_boot
    break
    ;;
    5)
      first_boot
    break
    ;;
    6)
      ECHOR "您选择了退出程序"
      exit 0
    break
    ;;
    *)
      XUANZHEOP="请输入正确的数字编号"
    ;;
    esac
    done
}

if [[ -z "${Input_Optio}" ]]; then
  if [[ -f '/usr/bin/replace' ]]; then
    menu "$@"
  else
    menu2 "$@"
  fi
else
  case ${Input_Optio} in
  -r)
    ks_reboot
  ;;
  -e)
    rm_init
  ;;
  esac
fi
