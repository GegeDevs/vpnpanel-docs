#!/usr/bin/env bash

USERNAME="${1}"
PASSWORD="${2}"
EXPIRED="${3}" # days
QUOTA="${4}"
CYCLE="${5}"
TRANSPORT="${6}"
EXPIRED_TIMESTAMP_BOT="${7}"

tunnel_name="VMESS"
limit_gb="200"
limit_bytes=$((limit_gb * 1024 * 1024 * 1024))
expired_seconds=$((EXPIRED * 24 * 60 * 60))

api_host="127.0.0.1"
api_port="YOUR_API_PORT"
api_username="YOUR_API_USERNAME"
api_password="YOUR_API_PASSWORD"
api_token="$(curl -sSkL -X 'POST' \
  "http://${api_host}:${api_port}/api/admin/token" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d "grant_type=password&username=${api_username}&password=${api_password}&scope=&client_id=&client_secret=" | jq -r .access_token)"

if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$EXPIRED" ]]; then
    echo "Usage: $0 <username> <password> <expired_days>"
    exit 1
fi

response_file="/tmp/$(uuid).json"

# GET USER
http_response=$(curl -sSkL -w "%{http_code}" -o "${response_file}" -X 'GET' \
  "http://${api_host}:${api_port}/api/user/${USERNAME}" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer ${api_token}")
get_user=$(cat "${response_file}")
rm -rf "${response_file}"

if [[ "$http_response" != "200" ]]; then
    echo "API Response: $(echo "${get_user}" | jq -r '.detail')"
    exit 1
fi

expire_before=$(echo "${get_user}" | jq -r '.expire')
expire_after=$((expire_before + expired_seconds))

# MODIFY_USER
req_json='{
  "expire": '"${expire_after}"'
}'

http_response=$(curl -sSkL -w "%{http_code}" -o "${response_file}" -X 'PUT' \
  "http://${api_host}:${api_port}/api/user/${USERNAME}" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${api_token}" \
  -d "${req_json}")
mod_user=$(cat "${response_file}")
rm -rf "${response_file}"

if [[ "$http_response" != "200" ]]; then
    echo "API Response: $(echo "${mod_user}" | jq -r '.detail')"
    exit 1
fi

expire=$(echo "${mod_user}" | jq -r '.expire')
used_traffic=$(echo "${mod_user}" | jq -r '.used_traffic')
used_traffic_gb=$(awk "BEGIN {printf \"%.2f\", ${used_traffic}/1024/1024/1024}")
link_ws=$(echo "${mod_user}" | jq -r '.links[0]')
link_xhttp=$(echo "${mod_user}" | jq -r '.links[1]')

echo -e "HTML_CODE"
echo -e "<b>+++++ ${tunnel_name} Account Extended +++++</b>"
echo -e "Username: <code>${USERNAME}</code>"
echo -e "Password: <code>${PASSWORD}</code>"
echo -e "Expired: <code>$(date -d "@${expire}" '+%Y-%m-%d %H:%M:%S')</code>"
echo -e "Data Limit: <code>${limit_gb}</code> GB"
echo -e "Used Traffic: <code>${used_traffic_gb}</code> GB"
echo -e "Websocket : <code>${link_ws}</code>"
echo -e "XHTTP: <code>${link_xhttp}</code>"
echo -e "<b>+++++ End of Account Details +++++</b>"