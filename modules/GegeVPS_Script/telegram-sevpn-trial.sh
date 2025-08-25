#!/bin/bash

# Load Parameters
source /etc/gegevps/softether/params
source /etc/gegevps/domain/domain
source /etc/gegevps/domain/wildcard
source /etc/gegevps/domain/coredomain

# Account Parameters
segrup='selling'
username="$1"
password="$2"
expires="$3"
transport="$4"
expired_timestamp_bot="$5"

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
account_limiter \
    "sevpn" \
    "Softether VPN" \
    "$(expr $(vpncmd /server localhost:5555 /password:${MYPASS} /adminhub:${HUB_NAME} /cmd UserList | grep -w 'User Name\|Group Name\|Expiration Date' | sed -z 's/\nExpiration Date/ | Expiration Date/g' | sed -z 's/\nGroup Name/ | Group Name/g' | cut -d '|' -f 2,4,6 | sed '/private/d' | sed '/trial_/d' | wc -l) + 1)"

# DATE EXPIRED
DATEEXP=`date -d "${expires} hours" +"%Y/%m/%d %H:%M:%S"`
SDATEEXP=`date -d "${expires} hours" +"%Y %B %d %H:%M:%S %Z"`

function port_stunnel_softether(){
	cat -n /etc/gegevps/stunnel/server.conf | grep softether | while read line_detect; do
		line_number_start="$(echo -n "${line_detect}" | awk '{print $1}')"
		line_number_end="$(echo "${line_number_start}+2" | bc)"
		cat /etc/gegevps/stunnel/server.conf | sed -n "${line_number_start},${line_number_end}p" | grep "^accept" | sed 's/ //g' | cut -d '=' -f 2
	done
}
stunnel_ovpn_port="$(port_stunnel_softether)"
ipsecpsk=$(vpncmd /server localhost:5555 /password:${MYPASS} /adminhub:${HUB_NAME} /cmd IPsecGet | grep -w 'IPsec Pre-Shared Key String' | cut -d '|' -f 2) &> /dev/null
seport=$(vpncmd /server localhost:5555 /password:${MYPASS} /adminhub:${HUB_NAME} /cmd ListenerList | grep -w 'Listening' | cut -d '|' -f 1 | cut -d ' ' -f 2 | sed -z 's/\n/ /g' ) &> /dev/null

#Show details
echo -e "HTML_CODE"
echo -e "━━━━━━━━━━━━━━━━"
echo -e "<b>Softether VPN Account</b>"
echo -e "━━━━━━━━━━━━━━━━"
echo -e "Host     : <code>${PUB_IP}</code>"
echo -e "Domain   : <code>${coredomain}</code>"
echo -e "Port     : <code>${seport}</code>"
echo -e "Port TLS : <code>${stunnel_ovpn_port}</code>"
echo -e "Username : <code>${username}</code>"
echo -e "Password : <code>${password}</code>"
echo -e "Expired  : <code>${SDATEEXP}</code>"
echo -e "━━━━━━━━━━━━━━━━"
echo -e "Hub Name    : <code>${HUB_NAME}</code>"
echo -e "IPsec PSK   : <code>${ipsecpsk}</code>"
echo -e "SSTP Cert   : http://${PUB_IP}:81/vpn/server.crt"
echo -e "OpenVPN TCP : http://${PUB_IP}:81/vpn/vpn-tcp.ovpn"
echo -e "OpenVPN UDP : http://${PUB_IP}:81/vpn/vpn-udp.ovpn"
echo -e "OpenVPN TLS : http://${PUB_IP}:81/vpn/vpn-tls.ovpn"
echo -e "━━━━━━━━━━━━━━━━"

function sevpn_creator(){
    # Execution
    vpncmd /server localhost:5555 /password:$MYPASS /adminhub:$HUB_NAME /cmd UserCreate $username /GROUP:$segrup /REALNAME:$username /NOTE:$username &> /dev/null
    vpncmd /server localhost:5555 /password:$MYPASS /adminhub:$HUB_NAME /cmd UserPasswordSet $username /PASSWORD:$password &> /dev/null
    vpncmd /server localhost:5555 /password:$MYPASS /adminhub:$HUB_NAME /cmd UserExpiresSet $username /EXPIRES:"$DATEEXP" &> /dev/null

    # OpenVPN Client Config Generate
    mkdir -p /etc/gegevps/softether &>/dev/null
    cd /etc/gegevps/softether && vpncmd /server localhost:5555 /password:$MYPASS /adminhub:$HUB_NAME /cmd OpenVpnMakeConfig se-ovpn.zip &>/dev/null && cd
    apt-get install -qq -y unzip &>/dev/null
    unzip -C /etc/gegevps/softether/se-ovpn.zip -d /etc/gegevps/softether &>/dev/null

    # OpenVPN Config Mod
    mv /etc/gegevps/softether/$(ls -1 /etc/gegevps/softether | grep remote_access) /etc/gegevps/softether/vpn-udp.ovpn
    sed -i '/#/d' /etc/gegevps/softether/vpn-udp.ovpn
    sed -i '/;/d' /etc/gegevps/softether/vpn-udp.ovpn
    sed -i '/^$/d' /etc/gegevps/softether/vpn-udp.ovpn
    cp /etc/gegevps/softether/vpn-udp.ovpn /etc/gegevps/softether/vpn-tcp.ovpn
    sed -i 's/proto udp/proto tcp/g' /etc/gegevps/softether/vpn-tcp.ovpn
    cp /etc/gegevps/softether/vpn-tcp.ovpn /etc/gegevps/softether/vpn-tls.ovpn
    ovpn_port_current="$(vpncmd /server localhost:5555 /password:$MYPASS /adminhub:$HUB_NAME /cmd OpenVpnGet | grep 'Port List' | sed 's/ //g' | cut -d '|' -f 2)"
    sed -i "s/${ovpn_port_current}/${stunnel_ovpn_port}/g" /etc/gegevps/softether/vpn-tls.ovpn

    # SSTP Cert & Key Generate
    cd /etc/gegevps/softether && vpncmd /server localhost:5555 /password:$MYPASS /adminhub:$HUB_NAME /cmd ServerCertGet server.crt &> /dev/null && cd
    cd /etc/gegevps/softether && vpncmd /server localhost:5555 /password:$MYPASS /adminhub:$HUB_NAME /cmd ServerKeyGet server.key &> /dev/null && cd

    # Copy file to Web Folder
    mkdir /var/www/html/vpn
    cp /etc/gegevps/softether/vpn-udp.ovpn /var/www/html/vpn/vpn-udp.ovpn
    cp /etc/gegevps/softether/vpn-tcp.ovpn /var/www/html/vpn/vpn-tcp.ovpn
    cp /etc/gegevps/softether/vpn-tls.ovpn /var/www/html/vpn/vpn-tls.ovpn
    cp /etc/gegevps/softether/server.crt /var/www/html/vpn/server.crt
    chmod +r /var/www/html/vpn/server.crt
}
sevpn_creator &
