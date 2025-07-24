#!/bin/bash

# Parameters
corename="xray"
username="$1"
password="$2"
days="$3"
transport="${4:-all}"

root_vpnray="/etc/gegevps/vpnray"
name_vpnray="Shadowsocks"
type_vpnray="shadowsocks"

# Cat Config
function cat_allconfig(){
	if [[ ${network_type} == "all" ]] || [[ ${network_type} == 'aio' ]]; then
		ls -1 ${dir_vpnray} | grep "${selected_core}\-${type_vpnray}\-" | while read name_config; do
			cat ${dir_vpnray}/${name_config}
		done
	else
		ls -1 ${dir_vpnray} | grep "${selected_core}\-${type_vpnray}\-${network_type}\-" | while read name_config; do
			cat ${dir_vpnray}/${name_config}
		done
	fi
}

# List Users
function userList(){
    cat_allconfig | grep "###" | cut -d ' ' -f 3,5 | sort -u
}

# Get Core Version
function get_core_version(){
	DIR_NATIVE_BIN="/etc/gegevps-bin"
	core_name="$1"
	
	# Executor
	if [[ -x ${DIR_NATIVE_BIN}/${core_name} ]]; then
		execute_bin="${DIR_NATIVE_BIN}/${core_name}"
	else
		execute_bin="docker run --rm gegedesembri/${core_name}:latest"
	fi
	
	${execute_bin} version | head -1 | cut -d ' ' -f 2 
}

# Select Core
function select_core(){
	selected_core="${corename}"
	dir_vpnray="${root_vpnray}/${selected_core}"
	network_list="$(ls -1 ${dir_vpnray} | grep "^${selected_core}-${type_vpnray}-" | cut -d '.' -f 1 | cut -d '-' -f 3 | sort -ur | awk '{ print length(), $0 | "sort -n" }' | cut -d ' ' -f 2 | sed ':a;N;$!ba;s/\n/\//g')"
	network_type="${transport}"
	core_version="$(get_core_version ${selected_core})"
}

# SUM Account
function sum_account(){
	if [[ $(userList | grep -ce " ${username}$") == '0' ]]; then
		echo -e "HTML_CODE"
		echo "━━━━━━━━━━━━━━━━"
		echo "<b>${name_vpnray} Account Not Found</b>"
		echo "━━━━━━━━━━━━━━━━"
		echo "Username : <code>${username}</code>"
		echo "━━━━━━━━━━━━━━━━"
		echo "<b>Extend Failed</b>"
		exit 1
	fi
}

# Delete Form
function renew_form(){
    CLIENT_NAME="$(userList | grep -e " ${username}$")"
    CLIENT_USERNAME=$(echo -e "${CLIENT_NAME}" | rev | cut -d ' ' -f 1 | rev)
	DATEEXP=$(echo -e "${CLIENT_NAME}" | cut -d ' ' -f 1)
	SDATEEXP=`date -d "${DATEEXP}" +"%d %B %Y"`
	renew_days="${days}"
    RDATEEXP=`date -d "${DATEEXP} + ${renew_days} days" +"%Y-%m-%d"`
	SRDATEEXP=`date -d "${RDATEEXP}" +"%d %B %Y"`
}

# Account deleter
function renew_action(){
	config_fullpath="$1"
	config_path="$(echo -e "${config_fullpath}" | rev | cut -d '/' -f 2- | rev)"
	config_filename="$(echo -e "${config_fullpath}" | rev | cut -d '/' -f 1 | rev)"
	config_name="$(echo -e "${config_filename}" | cut -d '.' -f 1)"
	config_core="$(echo -e "${config_name}" | cut -d '-' -f 1)"
	config_protocol="$(echo -e "${config_name}" | cut -d '-' -f 2)"
	config_network="$(echo -e "${config_name}" | cut -d '-' -f 3)"
	config_security="$(echo -e "${config_name}" | cut -d '-' -f 4)"
    
    client_expionly="$(echo -e "${CLIENT_NAME}" | cut -d ' ' -f 1)"
    client_nameonly="$(echo -e "${CLIENT_NAME}" | rev | cut -d ' ' -f 1 | rev)"
    if [[ $(echo -e "${CLIENT_NAME}" | wc -w) == 3 ]]; then
        client_typeonly="$(echo -e "${CLIENT_NAME}" | cut -d ' ' -f 2)"
    fi
    
    datamod="${client_expionly} ${config_network^^} ${client_nameonly}"

	if [[ -f ${config_fullpath} ]]; then
		sed -i "s|${datamod}$|${RDATEEXP} ${config_network^^} ${client_nameonly}|g" ${config_fullpath}
	fi
}

function renew_account(){
	if [[ ${network_type} == "all" ]] || [[ ${network_type} == 'aio' ]]; then
		ls -1 ${dir_vpnray} | grep "${selected_core}\-${type_vpnray}\-" | while read config_list; do
			renew_action ${dir_vpnray}/${config_list}
		done
	else
		ls -1 ${dir_vpnray} | grep "${selected_core}\-${type_vpnray}\-${network_type}\-" | while read config_list; do
			renew_action ${dir_vpnray}/${config_list}
		done
	fi

    # Renewed
	echo "HTML_CODE"
    echo "━━━━━━━━━━━━━━━━"
    echo "<b>${name_vpnray} Account Renewed</b>"
    echo "━━━━━━━━━━━━━━━━"
    echo "Username : <code>${CLIENT_USERNAME}</code>"
    echo "Expired : <code>${SRDATEEXP}</code>"
    echo "━━━━━━━━━━━━━━━━"
    echo "<b>Extended</b>"
    exit 0
}

select_core
sum_account
renew_form
renew_account
