#!/bin/bash

# Parameters
source /etc/gegevps/softether/params
vpncmd_execute="vpncmd /server localhost:5555 /password:${MYPASS} /adminhub:${HUB_NAME} /cmd"
username="$1"
password="$2"
days="$3"
transport="$4"

function sevpn_ListUsers(){
    ${vpncmd_execute} UserList | grep -w 'User Name\|Group Name\|Expiration Date' | sed -z 's/\nExpiration Date/ | Expiration Date/g' | sed -z 's/\nGroup Name/ | Group Name/g' | cut -d '|' -f 2,4,6 | sed '/private/d' | sed 's/ |selling |/ /g' | sed '/trial_/d' |cut -d ' ' -f 1,2 | sed 's/\<No\>/Lifetime/g'
}

if [[ "$(sevpn_ListUsers | grep -wc ${username})" == 0 ]]; then
    echo "Username ${username} tidak ditemukan"
    exit 1
fi

# Current Exp Date
function current_expdate(){
    sevpn_expformat="$(sevpn_ListUsers | grep -e "^${username} " | cut -d ' ' -f 2)"
    expdate="$(date -d "${sevpn_expformat}" +"%Y-%m-%d")" &> /dev/null
    echo -e "${expdate}"
}

# Renewing
${vpncmd_execute} UserExpiresSet "${username}" /EXPIRES:"$(date -d "$(current_expdate) + ${days} days" +"%Y/%m/%d 23:59:59")" &> /dev/null

# Renewed
echo "━━━━━━━━━━━━━━━━"
echo "<b>SoftetherVPN Account Renewed</b>"
echo "━━━━━━━━━━━━━━━━"
echo "Username : <code>${username}</code>"
echo "Expired : <code>$(current_expdate)</code>"
echo "━━━━━━━━━━━━━━━━"
echo "<b>Berhasil diperpanjang</b>"
exit 0