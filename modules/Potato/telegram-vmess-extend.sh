#!/usr/bin/env bash

USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"

apiKey="YOUR_APIKEY"

read -r -d '' json_payload <<EOF
{
  "kuota": 0
}
EOF

api_output=$(curl -sSkL --location --request PATCH "http://18.141.1.2/vps/renewvmess/${USERNAME}/${EXPIRED}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: ${apiKey}" \
    --data "${json_payload}")

if [[ $(echo ${api_output} | jq -r '.meta.code') -ne 200 ]]; then
    echo -e "Failed"
    exit 1
fi

fix_ip="$(echo -e ${api_output} | jq -r '.meta.ip_address')"
fix_username="$(echo -e ${api_output} | jq -r '.data.username')"
fix_quota="$(echo -e ${api_output} | jq -r '.data.quota')"
fix_ebe="$(echo -e ${api_output} | jq -r '.data.from')"
fix_expired="$(echo -e ${api_output} | jq -r '.data.to')"

echo -e "HTML_CODE"
echo -e "<b>+++++ VMESS Account Extended +++++</b>"
echo -e "IP Address: <code>${fix_ip}</code>"
echo -e "Username: <code>${fix_username}</code>"
echo -e "Quota: <code>${fix_quota}</code>"
echo -e "EBE: <code>${fix_ebe}</code>"
echo -e "Expired: <code>${fix_expired}</code>"
echo -e "<b>+++++ End of Server Details +++++</b>"