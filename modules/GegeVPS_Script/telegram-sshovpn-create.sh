#!/bin/bash

# Parameters
username="$1"
password="$2"
days="$3"
transport="${4:-all}"
USERNAME="${username//[^[:alnum:]]/}"
PASSWORD="${password}"

# Limiter
function account_limiter(){
    tunnel_type="$1"
    tunnel_name="$2"
    limiter_name="limit_${tunnel_type}"
    limiter_dir="/etc/gegevps/telegram-bot/limiter"
    limiter_path="${limiter_dir}/${limiter_name}"
    account_limit="$(cat ${limiter_path} | sed '/^$/d')"
    account_total="$3"
    mkdir -p ${limiter_dir} &>/dev/null
    touch ${limiter_path} &>/dev/null
    if [[ -z "${account_limit}" ]]; then
        account_limit="unlimited"
    fi
    if [[ ! "${account_limit}" == "unlimited" ]]; then
        if [[ ${account_total} -ge ${account_limit} ]]; then
            echo -e "HTML_CODE"
            echo -e "<b>${tunnel_name} Account</b>"
            echo -e "Host: <code>${MYIP}</code>"
            echo -e ""
            echo -e "<b>Slots have run out.</b>"
            echo -e "Account Total : <code>${account_total}</code> accounts"
            echo -e "Account Limit : <code>${account_limit}</code> accounts"
            exit 1
        fi
    fi
}

# Parameters Static
source /etc/gegevps/domain/domain
source /etc/gegevps/domain/wildcard
source /etc/os-release
source /etc/gegevps/slowdns/config
source /etc/gegevps/domain/slowdnsd
source /etc/gegevps/domain/coredomain
dns_pubkey="$(cat /etc/gegevps/slowdns/server.pub)"
MYIP="$(cat /etc/myip)"

if [[ ! "$(cat /etc/passwd | grep -w -c ${USERNAME})" == 0 ]]; then
    echo " Username ${USERNAME} sudah ada"
    echo " Gunakan username yang lain"
    exit 1
fi

function cat_allconfig(){
    awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | sed '/^admin$/d'
}
user_sumbefore="$(cat_allconfig | wc -l)"

# Account Limiter
account_limiter \
    "ssh" \
    "SSH/OpenVPN" \
    "${user_sumbefore}"

function username_mod(){
    useradd "${USERNAME}" -g users -s /bin/false
    echo "${USERNAME}:${PASSWORD}" | chpasswd
    until [[ ! "$(chage -l "${USERNAME}" | grep "Account expires" | awk -F": " '{print $2}')" == 'never' ]]; do
        usermod -e "$(date -d "${days} days" +"%Y-%m-%d")" "${USERNAME}"
    done
}
username_mod

function restart_fromzero(){
	if [[ ${user_sumbefore} == 0 ]]; then
        # Restart
		sudo /usr/local/bin/badvpn-autofix &
		$(crontab -l | grep "SSH-" | sed '/^@reboot /d' | cut -d ' ' -f 6- | head -1) &
        systemctl restart squid &
        systemctl restart danted &
		systemctl restart ohpserver &
		systemctl restart dnsserver &
		systemctl restart dnsclient &
		systemctl restart privoxy &
		systemctl restart openvpn@server-tcp &
		systemctl restart openvpn@server-udp &
        
        # Enable
        systemctl enable squid &
        systemctl enable danted &
		systemctl enable ohpserver &
		systemctl enable dnsserver &
		systemctl enable dnsclient &
		systemctl enable privoxy &
		systemctl enable openvpn@server-tcp &
		systemctl enable openvpn@server-udp &
	fi
}
restart_fromzero &>/dev/null

#show details
exp="$(date -d "${days} days" +"%d %B %Y")"
echo -e "HTML_CODE"
echo "━━━━━━━━━━━━━━━━"
echo "<b>SSH/OpenVPN Account Details</b>"
echo "━━━━━━━━━━━━━━━━"
echo " Host : <code>${MYIP}</code>"
echo " Domain : <code>${coredomain}</code>"
if [[ -s /etc/gegevps/cloudfront/data-deployed.json ]]; then
    cloudfront_domain="$(cat /etc/gegevps/cloudfront/data-deployed.json | jq -r .Distribution.DomainName)"
    echo -e " CloudFront CDN : <code>${cloudfront_domain}</code>"
fi
echo " Username : <code>${USERNAME}</code>"
echo " Password : <code>${PASSWORD}</code>"
echo " Expired : ${exp}"
echo "━━━━━━━━━━━━━━━━"
cat /etc/gegevps/ssh_template
if [[ -s /etc/gegevps/sshws/payload ]]; then
    echo "━━━━━━━━━━━━━━━━"
    echo " Payload SSH WebSocket"
    echo "<code>$(cat /etc/gegevps/sshws/payload)</code>"
fi
if [[ -s /etc/gegevps/cloudfront/payload ]]; then
    echo "━━━━━━━━━━━━━━━━"
    echo " Payload SSH WebSocket Cloudfront"
    echo "<code>$(cat /etc/gegevps/cloudfront/payload)</code>"
fi
echo "━━━━━━━━━━━━━━━━"
echo " SlowDNS (HTTP Custom)"
echo " <code>${MYIP}:${dns_pubkey}@${USERNAME}:${PASSWORD}@${slowdnsNS}</code>"
echo "━━━━━━━━━━━━━━━━"
echo " OpenVPN TCP : http://$MYIP:81/openvpn-tcp.ovpn"
echo " OpenVPN UDP : http://$MYIP:81/openvpn-udp.ovpn"
echo " OpenVPN TLS : http://$MYIP:81/openvpn-tls.ovpn"
echo " OpenVPN OHP : http://$MYIP:81/openvpn-ohp.ovpn"
echo " OpenVPN ZIP : http://$MYIP:81/openvpn.zip"
echo "━━━━━━━━━━━━━━━━"
