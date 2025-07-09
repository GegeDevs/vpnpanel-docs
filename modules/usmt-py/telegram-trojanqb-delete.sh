#!/usr/bin/env bash

USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"
QUOTA="$4"
CYCLE="$5"

tunnel_code="vless"
tunnel_name=$(echo "$tunnel_code" | tr '[:lower:]' '[:upper:]')
tunnel_mode="ws"

extend="$(usmt.py user delete ${USERNAME} --protocol ${tunnel_code}-${tunnel_mode} --days ${EXPIRED})"

echo -e "HTML_CODE"
echo -e "<b>+++++ ${tunnel_name} Account Deleted +++++</b>"
echo -e "Username: <code>${USERNAME}</code>"
echo -e "Password: <code>${PASSWORD}</code>"
echo -e "Data Limit: <code>${QUOTA}</code> GB"
echo -e "Quota Cycle: <code>${CYCLE}</code>"
echo -e "<b>+++++ End of Server Details +++++</b>"