#!/bin/sh
version="0.1.8"
source /koolshare/scripts/base.sh
eval `dbus export ddnspod`
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
# ====================================函数定义====================================
# 获得外网地址 nvram适用有动态ip4的（但可能受小猫影响得不到地址）。curl适用nat的大内网，不过这个ddns没意义
# 参数: record_type   区分ipv6 或 ipv4
arIpAdress() {
    local record_type=${1}
    if [ "${record_type}" == "A" ]; then
        local inter=$(curl -s whatismyip.akamai.com)
        #local inter=$(nvram get wan0_realip_ip)
        echo $inter
    else
        # 获得外网IPv6地址,一般ipv6没有nat 直接用本机的
        echo "`ifconfig $(nvram get wan0_ifname_t) | awk '/Global/{print $3}' | awk -F/ '{print $1}' | awk 'NR==1'`"
    fi
}

# 查询域名地址
# 参数: 待查询domain submain域名 record_type
arNslookup() {
    local domainID recordID recordIP record_type
    record_type=${3}
    # Get domain ID
    domainID=$(arApiPost "Domain.Info" "domain=${1}")
    domainID=$(echo $domainID | sed 's/.*{"id":"\([0-9]*\)".*/\1/')
    # Get Record ID
    recordID=$(arApiPost "Record.List" "domain_id=${domainID}&sub_domain=${2}&record_type=${record_type}")
    recordID=$(echo $recordID | sed 's/.*\[{"id":"\([0-9]*\)".*/\1/')
    # Last IP
    recordIP=$(arApiPost "Record.Info" "domain_id=${domainID}&record_id=${recordID}&record_type=${record_type}")
    recordIP=$(echo $recordIP | sed 's/.*,"value":"\([0-9a-f\.:]*\)".*/\1/')
    
    # Output IP
    case "$recordIP" in 
      [0-9a-f]*)
        echo $recordIP
        return 0
        ;;
      *)
        echo "Get Record Info Failed!"
        return 1
        ;;
    esac
}

# 读取接口数据
# 参数: 接口类型 待提交数据
arApiPost() {
    local agent="AnripDdns/5.07(mail@anrip.com)"
    #local inter="https://dnsapi.cn/${1:?'Info.Version'}"
    local inter="https://dnsapi.cn/${1}"
    local param="login_token=$ddnspod_config_token&format=json&${2}"
    wget --quiet --no-check-certificate --secure-protocol=TLSv1_2 --output-document=- --user-agent=$agent --post-data $param $inter
    #curl -X POST --silent --insecure --user-agent $agent --data $param $inter
}

# 更新记录信息
# 参数: 主域名 子域名 ip type
arDdnsUpdate() {
    local domainID recordID recordRS recordCD myIP errMsg record_type
    record_type=${4}
    # 获得域名ID
    domainID=$(arApiPost "Domain.Info" "domain=${1}")
	domainID=$(echo $domainID | sed 's/.*"id":"\([0-9]*\)".*/\1/')
    # 获得记录ID
    recordID=$(arApiPost "Record.List" "domain_id=${domainID}&sub_domain=${2}&record_type=${record_type}")
    recordID=$(echo $recordID | sed 's/.*\[{"id":"\([0-9]*\)".*/\1/')
    # 更新记录IP
    myIP=$3
    recordRS=$(arApiPost "Record.Ddns" "domain_id=${domainID}&record_id=${recordID}&sub_domain=${2}&record_type=${record_type}&value=${myIP}&record_line=默认")
    recordCD=$(echo $recordRS | sed 's/.*{"code":"\([0-9]*\)".*/\1/')
    # 输出记录IP
    if [ "$recordCD" == "1" ]; then
        echo $recordRS | sed 's/.*,"value":"\([0-9\.]*\)".*/\1/'
        dbus set ddnspod_run_status="`echo_date` ${2}更新成功，wan ip：${myIP}"
        sleep 10
        if [ ${isFirst} == 1 ]; then
            isFirst=0
            arDdnsCheck ${mainDomain} ${subDomain6} "AAAA"
        fi
        return 1
    fi
    # 输出错误信息
    errMsg=$(echo $recordRS | sed 's/.*,"message":"\([^"]*\)".*/\1/')
    dbus set ddnspod_run_status="失败，错误代码：$errMsg"
    echo $errMsg
}

# 检查ip信息
# 参数: 主域名 子域名 record_type
arDdnsCheck() {
	local hostIP lastIP postRS record_type
    record_type=${3}
	hostIP=$(arIpAdress ${record_type})
	lastIP=$(arNslookup ${1} ${2} ${record_type})
	echo "hostIP: ${hostIP}"
	echo "lastIP: ${lastIP}"
	if [ "$lastIP" != "$hostIP" ]; then
		dbus set ddnspod_run_status="更新中。。。"
		postRS=$(arDdnsUpdate $1 $2 $hostIP $3)
		echo "postRS: ${postRS}"
		if [ $? -ne 1 ]; then
			dbus set ddnspod_run_status="wan ip：${hostIP} 更新失败，原因：${postRS}"
		    return 1
		fi
	else
		dbus set ddnspod_run_status="`echo_date` wan ip：${hostIP} 未改变，无需更新"
	fi
	return 0
}

parseDomain() {
    isFirst=1
	mainDomain=${ddnspod_config_domain}
	subDomain4=${ddnspod_config_old_pwd}
    subDomain6=${ddnspod_config_uname}
}

add_ddnspod_cru(){
	sed -i '/ddnspod/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	cru a ddnspod "*/$ddnspod_refresh_time * * * * /koolshare/scripts/ddnspod_config.sh update"
}

stop_ddnspod(){
    local ddnspodcru=$(cru l | grep "ddnspod")
	if [ ! -z "$ddnspodcru" ]; then
		cru d ddnspod
	fi
	sed -i '/ddnspod/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
}

write_ddnspod_version(){
	dbus set ddnspod_version="$version"
}

# ====================================used by init or cru====================================
case $ACTION in
start)
	#此处为开机自启动设计
	if [ "$ddnspod_enable" == "1" ]  && [ "$ddnspod_auto_start" == "1" ];then
		logger "[软件中心]: 启动ddnspod！"
        parseDomain
        add_ddnspod_cru
        sleep $ddnspod_delay_time
        arDdnsCheck ${mainDomain} ${subDomain4} "A"
        sleep 10
        #arDdnsCheck ${mainDomain} ${subDomain6} "AAAA"
	else
		logger "[软件中心]: ddnspod未设置开机启动，跳过！"
	fi
	;;
stop | kill )
	#此处卸载插件时关闭插件设计
	stop_ddnspod
	;;
update)
	#此处为定时脚本设计
	parseDomain
	arDdnsCheck ${mainDomain} ${subDomain4} "A"
    sleep 10
    #arDdnsCheck ${mainDomain} ${subDomain6} "AAAA"
	;;
restart)
    stop_ddnspod
    parseDomain
    add_ddnspod_cru
    sleep $ddnspod_delay_time
    arDdnsCheck ${mainDomain} ${subDomain4} "A"
    sleep 10
    #arDdnsCheck ${mainDomain} ${subDomain6} "AAAA"
	write_ddnspod_version
	;;
*)
	echo "Usage: $0 (start|stop|restart|kill)"
	exit 1
	;;
esac