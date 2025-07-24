#!/bin/bash

username="$1"
password="$2"
expires="$3"
transport="$4"

# Parameters
MYIP="$(cat /etc/myip)"
DIR_SSLHM="/etc/gegevps/sslhm"

# Hysteria Ports
# hs_port="$(cat /etc/gegevps/hysteria/server.json | jq -r .listen | grep -E -o "[0-9]+")"
if [[ -s ${DIR_SSLHM}/443.cfg ]]; then
    hs_port=443
else
    ls -1 ${DIR_SSLHM} | grep -e "\.cfg$" | cut -d '.' -f 1 > /tmp/hysteria_ports.txt
    hs_port_sum=$(cat /tmp/hysteria_ports.txt | wc -l)
    hs_port_shuffle=$(shuf -i1-"${hs_port_sum}" -n1)
    hs_port=$(sed -n "${hs_port_shuffle}"p /tmp/hysteria_ports.txt)
    rm -rf /tmp/hysteria_ports.txt
fi

# Hysteria Parameters
hs_obfs="$(cat /etc/gegevps/hysteria/server.json | jq -r .obfs)"
hs_auth_type="STRING"
hs_insecure="YES"
hs_max_up="$(cat /etc/gegevps/hysteria/server.json | jq -r .up_mbps) Mbps"
hs_max_dl="$(cat /etc/gegevps/hysteria/server.json | jq -r .down_mbps) Mbps"
hs_sni="Your SNI"

function cat_allconfig(){
	cat /etc/gegevps/hysteria/userdata
}
if [[ $(cat_allconfig | sed '/^$/d' | wc -l) == 0 ]]; then
	userzero=0
fi

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
account_limiter \
    "hysteria" \
    "Hysteria" \
    "$(expr $(cat_allconfig | sed '/^$/d' | wc -l) + 1)"

# User Form
function user_form(){
	username="${username}"
	password="${password//[^[:alnum:]]/}"
	DATEEXP=`date -d "${expires} hours" +"%s"`
	SDATEEXP=`date -d "${expires} hours" +"%Y %B %d %H:%M:%S %Z"`
}

# User Record
function user_rec(){
	if [[ ! -f /etc/gegevps/hysteria/userdata ]]; then
		touch /etc/gegevps/hysteria/userdata
	fi
	
	echo -e "${DATEEXP} ${username}" >> /etc/gegevps/hysteria/userdata
	echo -e 'insert into hysteria values("'"${password}"'");' | sqlite3 /etc/gegevps/hysteria/server.db
}

# User Show
function user_show(){
    source /etc/gegevps/domain/wildcard
    source /etc/gegevps/domain/coredomain
    hs_up_speed="$(cat /etc/gegevps/hysteria/server.json | jq -r .up_mbps)"
    hs_down_speed="$(cat /etc/gegevps/hysteria/server.json | jq -r .down_mbps)"
    echo -e "HTML_CODE"
    echo -e "━━━━━━━━━━━━━━━━"
    echo -e "<b>Hysteria Account</b>"
    echo -e "━━━━━━━━━━━━━━━━"
    echo -e "Host : <code>$MYIP</code>"
    echo -e "Domain : <code>${coredomain}</code>"
    echo -e "Port : <code>${hs_port}</code>"
    echo -e "Obfuscation : <code>${hs_obfs}</code>"
    echo -e "Auth. Type : <code>${hs_auth_type}</code>"
    echo -e "Auth. Payload    : <code>${password}</code>"
    echo -e "SNI : <code>${hs_sni}</code>"
    echo -e "Allow Insecure : <code>YES</code>"
    echo -e "Max Upload Speed : <code>${hs_max_up}</code>"
    echo -e "Max Down Speed : <code>${hs_max_dl}</code>"
    echo -e "Expired : ${SDATEEXP}"
    echo -e "Link : <code>hysteria://${MYIP}:${hs_port}?protocol=udp&auth=${password}&peer=${coredomain}&insecure=1&upmbps=${hs_up_speed}&downmbps=${hs_down_speed}&obfs=${hs_auth_type}&obfsParam=${hs_obfs}#hysteria-${username}</code>"
    echo -e "━━━━━━━━━━━━━━━━"
}

function restart_from0(){
	if [[ ${userzero} == 0 ]]; then
		systemctl restart hysteria@server
	fi
}

user_form
user_rec
user_show
restart_from0
