#!/bin/bash

#########################################注意注意注意注意注意############################################

# 1、请在脚本中修改你期望优选 IP 的带宽大小（默认5MB/S）

# 2、请更改 尾行 的 xxxxxxxxxx 字符串，为你自己 PassWall 的节点值

######################################################################################################

#下载脚本
# wget -q http://git.m.cc/cloudflare-passwall-ip/cloudflare-passwall-ip.sh -O /etc/config/cloudflare-passwall-ip.sh --no-check-certificate && chmod +x /etc/config/cloudflare-passwall-ip.sh

#加入计划任务
# 20 3 */2 * * bash /etc/config/cloudflare-passwall-ip.sh > /tmp/log/passwall.log #定时优选 cloudflare 网络IP

######################################################################################################
echo
echo
echo ==========================================================
echo   项目: 基于 CloudflareSpeedTest 的 OpenWRT 自动更新 IP
echo   用途：用于自动筛选 Cloudflare IP，并自动替换优选 IP 为 PassWall 的节点地址
echo ==========================================================
echo
echo ====================脚本正在运行中.....====================
echo


######################################################################################################

# 参数设置!!

#下载速度下限,请自行设置,单位 MB/S，不要超过自己最大带宽限制，否则会导致无限运行下去
speed=15

#下载测速数量,默认 10，数量越多时间越久，选到的IP可能越好
speeddn=10

#平均延迟上限,默认 9999.00 ms
speedtl=300

#下载测速URL
speedurl=https://speed.cloudflare.com/__down?bytes=300000000

######################################################################################################

# 准备测速,停止passwall
/etc/init.d/haproxy stop
/etc/init.d/passwall stop

######################################################################################################

# 下载文件
echo =====================下载所需文件=====================
cd /tmp
curl -fsSL  https://ghproxy.com/https://raw.githubusercontent.com/db-one/dbone-packages/main/CloudflareSpeedTest/CloudflareST > /tmp/CloudflareST
curl -fsSL  https://ghproxy.com/https://raw.githubusercontent.com/db-one/dbone-packages/main/CloudflareSpeedTest/ip.txt > /tmp/ip.txt
curl -fsSL  https://ghproxy.com/https://raw.githubusercontent.com/db-one/dbone-packages/main/CloudflareSpeedTest/ipv6.txt > /tmp/ipv6.txt
chmod +x /tmp/CloudflareST

######################################################################################################
##检查文件！！
if [ -f "/tmp/CloudflareST" -a -f "/tmp/ip.txt" -a -f "/tmp/ipv6.txt" ];then
                echo
                echo ==================文件下载成功，继续运行==================
        else
                echo
                echo ==================文件下载失败，停止运行==================
                exit 0
        fi
######################################################################################################

# 计算开始时间
START_TIME=`date +'%Y-%m-%d %H:%M:%S'`

# 开始测速
./CloudflareST -tll 10 -n 500 -dt 10 -sl $speed -dn $speeddn -tl $speedtl -url $speedurl

# 参数：
#    -n 200
#        测速线程数量；越多测速越快，性能弱的设备 (如路由器) 请勿太高；(默认 200 最多 1000)
#    -t 4
#        延迟测速次数；单个 IP 延迟测速次数，为 1 时将过滤丢包的IP，TCP协议；(默认 4 次)
#    -tp 443
#        指定测速端口；延迟测速/下载测速时使用的端口；(默认 443 端口)
#    -dn 10
#        下载测速数量；延迟测速并排序后，从最低延迟起下载测速的数量；(默认 10 个)
#    -dt 10
#        下载测速时间；单个 IP 下载测速最长时间，不能太短；(默认 10 秒)
#    -url https://cf.xiu2.xyz/url
#        下载测速地址；用来下载测速的 Cloudflare CDN 文件地址，默认地址不保证可用性，建议自建；
#    -tl 200
#        平均延迟上限；只输出低于指定平均延迟的 IP，可与其他上限/下限搭配；(默认 9999 ms)
#    -tll 40
#        平均延迟下限；只输出高于指定平均延迟的 IP，可与其他上限/下限搭配、过滤假墙 IP；(默认 0 ms)
#    -sl 5
#        下载速度下限；只输出高于指定下载速度的 IP，凑够指定数量 [-dn] 才会停止测速；(默认 0.00 MB/s)
#    -p 10
#        显示结果数量；测速后直接显示指定数量的结果，为 0 时不显示结果直接退出；(默认 10 个)
#    -f ip.txt
#        IP段数据文件；如路径含有空格请加上引号；支持其他 CDN IP段；(默认 ip.txt)
#    -o result.csv
#        写入结果文件；如路径含有空格请加上引号；值为空时不写入文件 [-o ""]；(默认 result.csv)
#    -dd
#        禁用下载测速；禁用后测速结果会按延迟排序 (默认按下载速度排序)；(默认 启用)
#    -ipv6
#        IPv6测速模式；确保 IP 段数据文件内只包含 IPv6 IP段，软件不支持同时测速 IPv4+IPv6；(默认 IPv4)
#    -allip
#        测速全部的IP；对 IP 段中的每个 IP (仅支持 IPv4) 进行测速；(默认 每个 IP 段随机测速一个 IP)
#    -v
#        打印程序版本+检查版本更新
#    -h
#        打印帮助说明
######################################################################################################

# 输出筛选IP
IP1=$(sed -n "2p" result.csv | awk -F, '{print $1}')
IP2=$(sed -n "3p" result.csv | awk -F, '{print $1}')
IP3=$(sed -n "4p" result.csv | awk -F, '{print $1}')
IP4=$(sed -n "5p" result.csv | awk -F, '{print $1}')
IP5=$(sed -n "6p" result.csv | awk -F, '{print $1}')
IP6=$(sed -n "7p" result.csv | awk -F, '{print $1}')
IP7=$(sed -n "8p" result.csv | awk -F, '{print $1}')
SP1=$(sed -n "2p" result.csv | awk -F, '{print $6}')
SP2=$(sed -n "3p" result.csv | awk -F, '{print $6}')
SP3=$(sed -n "4p" result.csv | awk -F, '{print $6}')
SP4=$(sed -n "5p" result.csv | awk -F, '{print $6}')
SP5=$(sed -n "6p" result.csv | awk -F, '{print $6}')
SP6=$(sed -n "7p" result.csv | awk -F, '{print $6}')
SP7=$(sed -n "8p" result.csv | awk -F, '{print $6}')

# 判断一下是否成功获取到了 IP（如果没有就退出脚本）：
[[ -z "${IP1}" ]] && echo "CloudflareST 测速结果 IP 数量为 0，跳过下面步骤..." && /etc/init.d/haproxy restart && /etc/init.d/passwall restart && echo && echo && exit 0

# 计算结束时间
END_TIME=`date +'%Y-%m-%d %H:%M:%S'`
START_SECONDS=$(date --date="$START_TIME" +%s)
END_SECONDS=$(date --date="$END_TIME" +%s)
SECONDS=$((END_SECONDS-START_SECONDS))
MIN=$(( $SECONDS/60 ))
SEC=$(( $SECONDS-${MIN}*60 ))

echo 优选以下IP满足 $speed MB/S带宽需求
echo IP: $IP1 实测带宽 $SP1 Mbps
echo IP: $IP2 实测带宽 $SP2 Mbps
echo IP: $IP3 实测带宽 $SP3 Mbps
echo IP: $IP4 实测带宽 $SP4 Mbps
echo IP: $IP5 实测带宽 $SP5 Mbps
echo IP: $IP6 实测带宽 $SP6 Mbps
echo 总计用时 ${MIN}分${SEC}秒
echo
echo

######################################################################################################
uci commit passwall
uci set passwall.xxxxxxxxx.address=$IP1
uci set passwall.xxxxxxxxx.address=$IP2
uci set passwall.xxxxxxxxx.address=$IP3
uci set passwall.xxxxxxxxx.address=$IP4
uci set passwall.xxxxxxxxx.address=$IP5
uci set passwall.xxxxxxxxx.address=$IP6
uci set passwall.xxxxxxxxx.address=$IP7
uci commit passwall
######################################################################################################

[[ $(/etc/init.d/haproxy status) != "running" ]] && /etc/init.d/haproxy start
[[ $(/etc/init.d/passwall status) != "running" ]] && /etc/init.d/passwall start
exit 0


