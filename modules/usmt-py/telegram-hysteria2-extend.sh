#!/usr/bin/env bash

USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"
QUOTA="$4"
CYCLE="$5"

tunnel_code="hysteria"
tunnel_name=$(echo "$tunnel_code" | tr '[:lower:]' '[:upper:]')

extend="$(usmt.py user modify ${USERNAME} --protocol ${tunnel_code} --days ${EXPIRED})"

echo -e "HTML_CODE"
echo -e "<b>+++++ ${tunnel_name} Account Extended +++++</b>"
echo -e "Username: <code>${USERNAME}</code>"
echo -e "Password: <code>${PASSWORD}</code>"
echo -e "Extend Days: <code>${EXPIRED}</code> Days"
echo -e "Data Limit: <code>${QUOTA}</code> GB"
echo -e "Quota Cycle: <code>${CYCLE}</code>"
echo -e "<b>+++++ End of Server Details +++++</b>"