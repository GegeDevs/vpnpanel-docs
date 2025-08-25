#!/bin/bash

# Parameters
username="$1"
password="$2"
days="$3"
transport="${4:-all}"
expired_timestamp_bot="$5"

if [[ "$(cat /etc/passwd | grep -w -c ${username})" == 0 ]]; then
    echo -e "HTML_CODE"
    echo "━━━━━━━━━━━━━━━━"
    echo "Username ${username} tidak ditemukan"
    exit 1
fi

# Current Exp Date
function current_expdate(){
    expdate="$(chage -l ${username} | grep "Account expires" | awk -F": " '{print $2}')" &> /dev/null
    if [[ ! "${expdate}" == 'never' ]]; then
        expdate=$(date -d "$(chage -l ${username} | grep "Account expires" | awk -F": " '{print $2}')" +"%d %B %Y") &> /dev/null
    fi
}

# Renewing
current_expdate
usermod -e `date -d "${expdate} + ${days} days" +"%Y-%m-%d"` ${username}
current_expdate

# Extended
echo -e "HTML_CODE"
echo "━━━━━━━━━━━━━━━━"
echo "<b>SSH/OpenVPN Account Extended</b>"
echo "━━━━━━━━━━━━━━━━"
echo "Username : <code>${username}</code>"
echo "Expired : <code>${expdate}</code>"
echo "━━━━━━━━━━━━━━━━"
echo "<b>Berhasil diperpanjang</b>"
exit 0