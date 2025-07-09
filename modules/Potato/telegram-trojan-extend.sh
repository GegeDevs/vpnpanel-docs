#!/usr/bin/env bash

USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"

apiKey="YOUR_APIKEY"

api_output=$(curl --location --request PATCH "http://18.141.1.2/vps/renewtrojan/${USERNAME}/${EXPIRED}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: ${apiKey}" \
    --data '{
    "kuota": 0
    }')

if [[ $(echo ${api_output} | jq -r '.meta.code') !== "200" ]]; then
    echo -e "Failed"
    exit 1
fi

fix_ip="$(echo -e ${api_output} | jq -r '.meta.ip_address')"
fix_username="$(echo -e ${api_output} | jq -r '.data.username')"
fix_quota="$(echo -e ${api_output} | jq -r '.data.quota')"
fix_ebe="$(echo -e ${api_output} | jq -r '.data.from')"
fix_expired="$(echo -e ${api_output} | jq -r '.data.to')"

echo -e "HTML_CODE"
echo -e "<b>+++++ TROJAN Account Extended +++++</b>"
echo -e "IP Address: <code>${fix_ip}</code>"
echo -e "Username: <code>${fix_username}</code>"
echo -e "Quota: <code>${fix_quota}</code>"
echo -e "EBE: <code>${fix_ebe}</code>"
echo -e "Expired: <code>${fix_expired}</code>"
echo -e "<b>+++++ End of Server Details +++++</b>"