#!/bin/bash

username="$1"
password="$2"
days="$3"
transport="$4"

function ListUsers(){
    cat /etc/gegevps/hysteria/userdata
}

if [[ "$(ListUsers | grep -wc ${username})" == 0 ]]; then
    echo "Username ${username} tidak ditemukan"
    exit 1
fi

# Current Exp Date
function current_expdate(){
    expdate="$(ListUsers | grep -e "${username}$" | cut -d ' ' -f 1)" &> /dev/null
    echo -e "${expdate}"
}

sed -i "s/^$(current_expdate) ${username}$/$(date -d "$(date -d "@$(current_expdate)") + ${days} days" +"%s") ${username}/g" /etc/gegevps/hysteria/userdata

# Renewed
echo "HTML_CODE"
echo "━━━━━━━━━━━━━━━━"
echo "<b>Hysteria Account Renewed</b>"
echo "━━━━━━━━━━━━━━━━"
echo "Username : <code>${username}</code>"
echo "Expired : <code>$(date -d "@$(current_expdate)" +"%Y-%m-%d")</code>"
echo "━━━━━━━━━━━━━━━━"
echo "<b>Berhasil diperpanjang</b>"
exit 0
