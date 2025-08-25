#!/bin/bash

# Parameters
username="$1"
password="$2"
days="$3"
transport="${4:-all}"
expired_timestamp_bot="$5"
userpass="${username//[^[:alnum:]]/}"

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

function url_encode() {
    echo "$@" \
    | sed \
        -e 's/%/%25/g' \
        -e 's/ /%20/g' \
        -e 's/!/%21/g' \
        -e 's/"/%22/g' \
        -e "s/'/%27/g" \
        -e 's/#/%23/g' \
        -e 's/(/%28/g' \
        -e 's/)/%29/g' \
        -e 's/+/%2b/g' \
        -e 's/,/%2c/g' \
        -e 's/-/%2d/g' \
        -e 's/:/%3a/g' \
        -e 's/;/%3b/g' \
        -e 's/?/%3f/g' \
        -e 's/@/%40/g' \
        -e 's/\$/%24/g' \
        -e 's/\&/%26/g' \
        -e 's/\*/%2a/g' \
        -e 's/\./%2e/g' \
        -e 's/\//%2f/g' \
        -e 's/\[/%5b/g' \
        -e 's/\\/%5c/g' \
        -e 's/\]/%5d/g' \
        -e 's/\^/%5e/g' \
        -e 's/_/%5f/g' \
        -e 's/`/%60/g' \
        -e 's/{/%7b/g' \
        -e 's/|/%7c/g' \
        -e 's/}/%7d/g' \
        -e 's/~/%7e/g'
}

# Paramaters
MYIP="$(cat /etc/myip)"
trojango_workdir="/etc/gegevps/trojan-go"

if [[ ! -d ${trojango_workdir} ]]; then
    echo -e "Trojan-Go not installed"
    exit 1
fi

# Account Limiter
account_limiter \
    "trojango" \
    "Trojan-Go" \
    "$(cat "${trojango_workdir}/userpass.txt" | sed '/^$/d' | wc -l)"

# Number Check
function num_check(){
    re='^[+-]?[0-9]+([.][0-9]+)?$'
    if [[ ! $1 =~ ${re} ]] ; then
       echo "notok"
    else
       echo "ok"
    fi
}

# Userpass
exist_user="$(cat ${trojango_workdir}/config.json | jq -r .password[] | grep -wce "^${userpass}$")"
if [[ ! "${exist_user}" == '0' ]]; then
    echo -e "HTML_CODE"
    echo -e "Userpass ${userpass} already exist"
    echo -e "Please choose another Userpass"
    exit 1
fi

# Check Expired entry
if [[ ! "$(num_check ${days})" == 'ok' ]]; then
    echo -e "HTML_CODE"
    echo -e "Invalid Expire Days"
    echo -e "${days} not a Number"
    exit 1
fi

# User Expired (Timestamp)
user_timestamp="$(date -d "${days} days" +"%s")"

# Userpass Expired Database
echo -e "${userpass} ${user_timestamp}" >> ${trojango_workdir}/userpass.txt

# Insert to Config
mv ${trojango_workdir}/config.json ${trojango_workdir}/config.json.old
jq '.password = if (.password | type) == "array" then .password + ["'"${userpass}"'"] else ["'"${userpass}"'"] end' ${trojango_workdir}/config.json.old > ${trojango_workdir}/config.json
rm -rf ${trojango_workdir}/config.json.old

# Reload Running
function systemd_manager(){
    if [[ $(cat "${trojango_workdir}/userpass.txt" | sed '/^$/d' | wc -l) -ne 0 ]]; then
        systemctl restart trojan-go
        systemctl enable trojan-go
    else
        systemctl stop trojan-go
        systemctl disable trojan-go
    fi
}
systemd_manager &>/dev/null

# Show
source /etc/gegevps/domain/domain
source /etc/gegevps/domain/coredomain
port_trojango="443"
wspath_trojango="/YOURPATH/trojan-go"
wspath_trojango_encode="$(url_encode "${wspath_trojango}")"
echo -e "HTML_CODE"
echo -e "━━━━━━━━━━━━━━━━"
echo -e "<b>Trojan-Go Account Detail</b>"
echo -e "━━━━━━━━━━━━━━━━"
echo -e "Host : <code>${MYIP}</code>"
echo -e "Domain : <code>${coredomain}</code>"
echo -e "Port : <code>${port_trojango}</code>"
echo -e "Userpass : <code>${userpass}</code>"
echo -e "Websocket Path : <code>${wspath_trojango}</code>"
echo -e "Allow Insecure : <code>YES</code>"
echo -e "Expired : $(date -d "@${user_timestamp}" +"%d %B %Y")"
echo -e "━━━━━━━━━━━━━━━━"
echo -e "<b>Trojan-Go Link</b>"
echo -e "<code>trojan-go://${userpass}@${MYIP}:${port_trojango}?encryption=none&host=${subdomain}.${domain}&path=${wspath_trojango_encode}&sni=${subdomain}.${domain}&type=ws#trojan-go-ws-tls-${userpass}</code>"
echo -e "━━━━━━━━━━━━━━━━"
exit 0


