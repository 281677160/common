if [[ `grep -c "error" build.log` -ge '1' ]]; then
	clear
	echo "青龙面板安装完成"
	echo
	while :; do
	echo "error" > build.log
	read -p " [ N/n ]退出程序，[ Y/y ]回车继续安装脚本： " MENU
	if [[ `grep -c "error" build.log` -ge '1' ]]; then
		S="Yy"
		rm -fr build.log
	else
		echo
		echo "提示：一定要登录管理面板之后再执行下一步操作,或者您输入[N/n]按回车退出!"
		echo
	fi
	case $MENU in
		[${S}])
			echo
			echo "开始安装脚本，请耐心等待..."
			echo "error" > build.log
		break
		;;
		[Nn])
			echo
			echo "退出安装程序!"
			echo
		break
    		;;
    		*)
			echo
			echo "输入错误，请输入正确选择!"
			echo
		;;
	esac
	done
else
	echo
	echo
	echo "青龙面板安装失败！"
fi
