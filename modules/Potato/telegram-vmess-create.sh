#!/usr/bin/env bash

USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"

apiKey="YOUR_APIKEY"
limitgb="YOUR_LIMITGB"
limitip="YOUR_LIMITIP"

read -r -d '' json_payload <<EOF
{
  "expired": ${EXPIRED},
  "limitip": ${limitip},
  "kuota": ${limitgb},
  "username": "${USERNAME}",
  "uuidv2": "${PASSWORD}"
}
EOF

api_output=$(curl -sSkL --location 'http://127.0.0.1/vps/vmessall' \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: ${apiKey}" \
    --data "${json_payload}")

if [[ $(echo ${api_output} | jq -r '.meta.code') -ne 200 ]]; then
    echo -e "Failed"
    exit 1
fi

fix_username="$(echo -e ${api_output} | jq -r '.data.username')"
fix_password="$(echo -e ${api_output} | jq -r '.data.uuid')"
fix_expired="$(echo -e ${api_output} | jq -r '.data.expired')"
fix_time="$(echo -e ${api_output} | jq -r '.data.time')"
fix_isp="$(echo -e ${api_output} | jq -r '.meta.ISP')"
fix_city="$(echo -e ${api_output} | jq -r '.meta.CITY')"
fix_hostname="$(echo -e ${api_output} | jq -r '.data.hostname')"
fix_ip="$(echo -e ${api_output} | jq -r '.meta.ip_address')"
fix_port_tls="$(echo -e ${api_output} | jq -r '.data.port.tls')"
fix_port_none="$(echo -e ${api_output} | jq -r '.data.port.none')"
fix_port_any="$(echo -e ${api_output} | jq -r '.data.port.any')"
fix_path_stn="$(echo -e ${api_output} | jq -r '.data.path.stn')"
fix_path_multi="$(echo -e ${api_output} | jq -r '.data.path.multi')"
fix_path_grpc="$(echo -e ${api_output} | jq -r '.data.path.grpc')"
fix_path_up="$(echo -e ${api_output} | jq -r '.data.path.up')"
fix_link_tls="$(echo -e ${api_output} | jq -r '.data.link.tls')"
fix_link_none="$(echo -e ${api_output} | jq -r '.data.link.none')"
fix_link_grpc="$(echo -e ${api_output} | jq -r '.data.link.grpc')"
fix_link_uptls="$(echo -e ${api_output} | jq -r '.data.link.uptls')"
fix_link_upntls="$(echo -e ${api_output} | jq -r '.data.link.upntls')"

echo -e "HTML_CODE"
echo -e "<b>+++++ VMESS Account Created +++++</b>"
echo -e "ISP: <code>${fix_isp}</code>"
echo -e "City: <code>${fix_city}</code>"
echo -e "Hostname: <code>${fix_hostname}</code>"
echo -e "IP Address: <code>${fix_ip}</code>"
echo -e "Username: <code>${fix_username}</code>"
echo -e "Password: <code>${fix_password}</code>"
echo -e "Expired: <code>${fix_expired}</code>"
echo -e "Time: <code>${fix_time}</code>"
echo -e "Port TLS: <code>${fix_port_tls}</code>"
echo -e "Port Non-TLS: <code>${fix_port_none}</code>"
echo -e "Port Any: <code>${fix_port_any}</code>"
echo -e "Path STN: <code>${fix_path_stn}</code>"
echo -e "Path Multi: <code>${fix_path_multi}</code>"
echo -e "Path gRPC: <code>${fix_path_grpc}</code>"
echo -e "Path UP: <code>${fix_path_up}</code>"
echo -e "Link TLS: <code>${fix_link_tls}</code>"
echo -e "Link Non-TLS: <code>${fix_link_none}</code>"
echo -e "Link gRPC: <code>${fix_link_grpc}</code>"
echo -e "Link UP TLS: <code>${fix_link_uptls}</code>"
echo -e "Link UP Non-TLS: <code>${fix_link_upntls}</code>"
echo -e "<b>+++++ End of Server Details +++++</b>"