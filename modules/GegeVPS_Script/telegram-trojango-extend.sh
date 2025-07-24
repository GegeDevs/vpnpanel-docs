#!/bin/bash

# Parameters
username="$1"
password="$2"
days="$3"
transport="${4:-all}"
userpass="${username//[^[:alnum:]]/}"

function ListUsers(){
    cat /etc/gegevps/trojan-go/userpass.txt
}

if [[ "$(ListUsers | grep -wc ${userpass})" == 0 ]]; then
    echo "Username ${userpass} tidak ditemukan"
    exit 1
fi

# Current Exp Date
function current_expdate(){
    expdate="$(ListUsers | grep -e "^${userpass} " | cut -d ' ' -f 2)" &> /dev/null
    echo -e "${expdate}"
}

sed -i "s/^${userpass} $(current_expdate)$/${userpass} $(date -d "$(date -d "@$(current_expdate)") + ${days} days" +"%s")/g" /etc/gegevps/trojan-go/userpass.txt

# Extended
echo "━━━━━━━━━━━━━━━━"
echo "<b>Trojan-Go Account Extended</b>"
echo "━━━━━━━━━━━━━━━━"
echo "Username : <code>${userpass}</code>"
echo "Expired : <code>$(date -d "@$(current_expdate)" +"%Y-%m-%d")</code>"
echo "━━━━━━━━━━━━━━━━"
echo "<b>Berhasil diperpanjang</b>"
exit 0
