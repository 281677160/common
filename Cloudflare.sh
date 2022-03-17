#!/bin/bash

#########################################注意注意注意注意注意############################################

# 1、请在脚本中修改你期望优选 IP 的带宽大小（默认5MB/S）

# 2、请更改 尾行 的 xxxxxxxxxx 字符串，为你自己 PassWall 的节点值

######################################################################################################
echo
echo
echo ==========================================================
echo   项目: 基于 CloudflareSpeedTest 的 OpenWRT 自动更新 IP
echo   用途：用于自动筛选 Cloudflare IP，并自动替换优选 IP 为 PassWall 的节点地址
echo ==========================================================
echo
echo =================脚本正在运行中.....=======================

# 准备测速,停止passwall
service passwall stop
service haproxy stop

######################################################################################################
##参数设置!!

#下载速度下限,请自行设置,单位 MB/S
speed=5

#下载测速数量,默认 10
speeddn=10

#测速线程数量,视设备性能大小而定,默认 200
speedn=500

#单个IP下载测速最长时间,默认 10 秒
speeddt=10

#平均延迟上限,默认 9999.00 ms
speedtl=300

#平均延迟下限,过滤假墙 IP；(默认 0 ms)
speedtll=10

#下载测速URL
speedurl=https://speed.cloudflare.com/__down?bytes=300000000


######################################################################################################

# 下载文件
curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/db-one/dbone-packages/main/CloudflareSpeedTest/CloudflareST > /tmp/CloudflareST
curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/db-one/dbone-packages/main/CloudflareSpeedTest/ip.txt > /tmp/ip.txt
curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/db-one/dbone-packages/main/CloudflareSpeedTest/ipv6.txt > /tmp/ipv6.txt
chmod +x /tmp/CloudflareST
cd /tmp

######################################################################################################
##检查网络！！
ping speed.cloudflare.com -c1 >/dev/null 2>&1
        if [ $? -eq 0 ];then
                echo
                echo =================网络正常，继续运行=================
        else
                echo
                echo =================网络异常，停止运行=================
                service passwall start
                service haproxy start
                exit 0
        fi
######################################################################################################

######################################################################################################

# 计算开始时间
starttime=`date +'%Y-%m-%d %H:%M:%S'`

# 开始测速
./CloudflareST -sl $speed -dn $speeddn -n $speedn -dt $speeddt -tl $speedtl -tll $speedtll -url $speedurl

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
SP1=$(sed -n "2p" result.csv | awk -F, '{print $6}')
SP2=$(sed -n "3p" result.csv | awk -F, '{print $6}')
SP3=$(sed -n "4p" result.csv | awk -F, '{print $6}')
SP4=$(sed -n "5p" result.csv | awk -F, '{print $6}')
SP5=$(sed -n "6p" result.csv | awk -F, '{print $6}')
SP6=$(sed -n "7p" result.csv | awk -F, '{print $6}')

# 判断一下是否成功获取到了 IP（如果没有就退出脚本）：
[[ -z "${IP1}" ]] && echo "CloudflareST 测速结果 IP 数量为 0，跳过下面步骤..." && /etc/init.d/haproxy restart && /etc/init.d/passwall restart && echo && echo && exit 0

# 计算结束时间
endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s)
end_seconds=$(date --date="$endtime" +%s)

echo 优选以下IP满足 $speed MB/S带宽需求
echo IP: $IP1 实测带宽 $SP1 Mbps
echo IP: $IP2 实测带宽 $SP2 Mbps
echo IP: $IP3 实测带宽 $SP3 Mbps
echo IP: $IP4 实测带宽 $SP4 Mbps
echo IP: $IP5 实测带宽 $SP5 Mbps
echo IP: $IP6 实测带宽 $SP6 Mbps
echo 总计用时 $((end_seconds-start_seconds)) 秒
echo
echo

######################################################################################################

uci set passwall.xxxxxxxxxxxxx.address=$IP1
#uci set passwall.xxxxxxxxxxxxx.address=$IP2
#uci set passwall.xxxxxxxxxxxxx.address=$IP3
#uci set passwall.xxxxxxxxxxxxx.address=$IP4
#uci set passwall.xxxxxxxxxxxxx.address=$IP5
#uci set passwall.xxxxxxxxxxxxx.address=$IP6

######################################################################################################

uci commit passwall
service passwall start
service haproxy start

exit 0


