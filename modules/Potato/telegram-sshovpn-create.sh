#!/usr/bin/env bash

USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"

apiKey="YOUR_APIKEY"
limitip="YOUR_LIMITIP"

api_output=$(curl --location 'http://127.0.0.1/vps/sshvpn' \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: ${apiKey}" \
    --data '{
    "expired": ${EXPIRED},
    "limitip": ${limitip},
    "password": "${PASSWORD}",
    "username": "${USERNAME}"
    }')

if [[ $(echo ${api_output} | jq -r '.meta.code') !== "200" ]]; then
    echo -e "Failed"
    exit 1
fi

fix_username="$(echo -e ${api_output} | jq -r '.data.username')"
fix_password="$(echo -e ${api_output} | jq -r '.data.password')"
fix_expired="$(echo -e ${api_output} | jq -r '.data.exp')"
fix_time="$(echo -e ${api_output} | jq -r '.data.time')"
fix_isp="$(echo -e ${api_output} | jq -r '.meta.ISP')"
fix_city="$(echo -e ${api_output} | jq -r '.meta.CITY')"
fix_hostname="$(echo -e ${api_output} | jq -r '.data.hostname')"
fix_ip="$(echo -e ${api_output} | jq -r '.meta.ip_address')"
fix_pubkey="$(echo -e ${api_output} | jq -r '.data.pubkey')"
fix_port_tls="$(echo -e ${api_output} | jq -r '.data.port.tls')"
fix_port_none="$(echo -e ${api_output} | jq -r '.data.port.none')"
fix_port_any="$(echo -e ${api_output} | jq -r '.data.port.any')"
fix_port_ovpntcp="$(echo -e ${api_output} | jq -r '.data.port.ovpntcp')"
fix_port_ovpnudp="$(echo -e ${api_output} | jq -r '.data.port.ovpnudp')"
fix_port_slowdns="$(echo -e ${api_output} | jq -r '.data.port.slowdns')"
fix_port_sshohp="$(echo -e ${api_output} | jq -r '.data.port.sshohp')"
fix_port_ovpnohp="$(echo -e ${api_output} | jq -r '.data.port.ovpnohp')"
fix_port_squid="$(echo -e ${api_output} | jq -r '.data.port.squid')"
fix_port_udpcustom="$(echo -e ${api_output} | jq -r '.data.port.udpcustom')"
fix_port_udpgw="$(echo -e ${api_output} | jq -r '.data.port.udpgw')"
fix_payloadcdn="$(echo -e ${api_output} | jq -r '.data.payloadws.payloadcdn')"
fix_payloadwithpath="$(echo -e ${api_output} | jq -r '.data.payloadws.payloadwithpath')"

echo -e "HTML_CODE"
echo -e "<b>+++++ SSH Account Created +++++</b>"
echo -e "ISP: <code>${fix_isp}</code>"
echo -e "City: <code>${fix_city}</code>"
echo -e "Hostname: <code>${fix_hostname}</code>"
echo -e "IP Address: <code>${fix_ip}</code>"
echo -e "Username: <code>${fix_username}</code>"
echo -e "Password: <code>${fix_password}</code>"
echo -e "Expired: <code>${fix_expired}</code>"
echo -e "Time: <code>${fix_time}</code>"
echo -e "Public Key: <code>${fix_pubkey}</code>"
echo -e "Port TLS: <code>${fix_port_tls}</code>"
echo -e "Port Non-TLS: <code>${fix_port_none}</code>"
echo -e "Port Any: <code>${fix_port_any}</code>"
echo -e "Port OVPN TCP: <code>${fix_port_ovpntcp}</code>"
echo -e "Port OVPN UDP: <code>${fix_port_ovpnudp}</code>"
echo -e "Port SlowDNS: <code>${fix_port_slowdns}</code>"
echo -e "Port SSHOHP: <code>${fix_port_sshohp}</code>"
echo -e "Port OVPNOHP: <code>${fix_port_ovpnohp}</code>"
echo -e "Port Squid: <code>${fix_port_squid}</code>"
echo -e "Port UDP Custom: <code>${fix_port_udpcustom}</code>"
echo -e "Port UDP GW: <code>${fix_port_udpgw}</code>"
echo -e "Payload CDN: <code>${fix_payloadcdn}</code>"
echo -e "Payload with Path: <code>${fix_payloadwithpath}</code>"
echo -e "<b>+++++ End of Server Details +++++</b>"