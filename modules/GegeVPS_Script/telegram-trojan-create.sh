#!/bin/bash

corename="xray"
username="$1"
password="$2"
days="$3"
transport="${4:-all}"
expired_timestamp_bot="$5"

# Parameters
source /etc/gegevps/domain/coredomain
MYIP="$(cat /etc/myip)"
root_vpnray="/etc/gegevps/vpnray"
name_vpnray="Trojan"
type_vpnray="trojan"

# Limiter
function account_limiter(){
    tunnel_type="$1"
    tunnel_name="$2"
    limiter_name="limit_${tunnel_type}"
    limiter_dir="/etc/gegevps/telegram-bot/limiter"
    limiter_path="${limiter_dir}/${limiter_name}"
    account_limit="$(cat ${limiter_path} | sed '/^$/d')"
    account_total="$3"
    mkdir -p ${limiter_dir} &>/dev/null
    touch ${limiter_path} &>/dev/null
    if [[ -z "${account_limit}" ]]; then
        account_limit="unlimited"
    fi
    if [[ ! "${account_limit}" == "unlimited" ]]; then
        if [[ ${account_total} -ge ${account_limit} ]]; then
            echo -e "HTML_CODE"
            echo -e "<b>${tunnel_name} Account</b>"
            echo -e "Host: <code>${MYIP}</code>"
            echo -e ""
            echo -e "<b>Slots have run out.</b>"
            echo -e "Account Total : <code>${account_total}</code> accounts"
            echo -e "Account Limit : <code>${account_limit}</code> accounts"
            exit 1
        fi
    fi
}

# Prepare
function prepare(){
	if [[ ! -d "${dir_vpnray}" ]]; then
		mkdir -p "${dir_vpnray}" &>/dev/null
	fi
	mkdir -p /var/www/html/vpnray
}

# End Client Line
function end_client(){
	config_name="$1"
	line_endclient="$2"
	if [[ $(cat ${dir_vpnray}/${config_name}.json | grep -w -c '## END Client') == 0 ]]; then
		sed -i "${line_endclient} i ## END Client" ${dir_vpnray}/${config_name}.json
	fi
}

# Cat Config
function cat_allconfig(){
	if [[ ${network_type} == "all" ]]; then
		ls -1 ${dir_vpnray} | grep "${selected_core}\-${type_vpnray}\-" | while read name_config; do
			cat ${dir_vpnray}/${name_config}
		done
	else
		ls -1 ${dir_vpnray} | grep "${selected_core}\-${type_vpnray}\-${network_type}\-" | while read name_config; do
			cat ${dir_vpnray}/${name_config}
		done
	fi
}

# Account Limiter
account_limiter \
    "${type_vpnray}" \
    "${name_vpnray}" \
    "$(cat_allconfig | grep -E "^### Client" | cut -d ' ' -f 1,2,3,5 | sort -u | wc -l)"

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

# Add User Form
function user_form(){	
	selected_core="${corename}"
	dir_vpnray="${root_vpnray}/${selected_core}"
	network_type="${transport}"
	core_version="$(get_core_version ${selected_core})"
	prepare &>/dev/null
    
    # Protocol not found
    if [[ $(ls -1 "${dir_vpnray}" | grep -ce "\-${type_vpnray}\-") -eq 0 ]]; then
        echo -e "---------"
        echo -e "Protocol ${type_vpnray} not found on ${selected_core} core"
        echo -e "---------"
        exit 1
    fi

	# Generate Account Details
	userid="${password}"
	level='0'
	alterid='0'

    userpass="${username}"
    userpass="${userpass//[^[:alnum:]]/}"
    exist_user="$(cat_allconfig | grep -ic [[:space:]]${userpass}$)"
    if [[ ! "${exist_user}" == '0' ]]; then
        echo -e "Username '${userpass}' already exist"
        echo -e "Please choose another Username"
        exit 1
    fi
    
    # Make sure user not process if already exist
    exist_user="$(cat_allconfig | grep -ic [[:space:]]${userpass}$)"
    if [[ ! "${exist_user}" == '0' ]]; then
        echo -e "---------"
        echo -e "Username '${userpass}' already exist"
        echo -e "---------"
        exit 1
    fi
    
    # Expired Date
	expi="${days}"
	email="${userpass}@${name_vpnray}.tunnel"
	DATEEXP=`date -d "${expi} days" +"%Y-%m-%d"`
	SDATEEXP=`date -d "${expi} days" +"%d %B %Y"`
}
user_form

# Add Account
function add_account(){
	if [[ ${network_type} == "all" ]]; then
		ls -1 ${dir_vpnray} | grep "${selected_core}\-${type_vpnray}\-" 
	else
		ls -1 ${dir_vpnray} | grep "${selected_core}\-${type_vpnray}\-${network_type}\-"
	fi | while read config_list; do
		config_filename="${config_list}"
		config_name="$(echo -e ${config_list} | cut -d '.' -f 1)"
		transport_name="$(echo -e ${config_name} | cut -d '-' -f 3)"
		if [[ "${transport_name}" == "grpc" ]]; then
			path_content="${config_name}"
			type_mode="gun"
		else
			path_content="/YOURPATH/${config_name}"
			type_mode="none"
		fi

		if [[ "${transport_name}" == "tcp" ]]; then
			tls_type="$(echo -e ${config_name} | cut -d '-' -f 4)"
			tunnel_port="$(cat ${dir_vpnray}/${config_filename} | sed "/^#/d" | jq -r .inbounds[].port)"
			if [[ "${tls_type}" == "ntls" ]]; then
				tls_type=""
			else
				tls_type="tls"
			fi
		else
			tls_type="$(echo -e ${config_name} | cut -d '-' -f 4)"
			if [[ "${tls_type}" == "ntls" ]]; then
				tls_type=""
				tunnel_port="80"
			else
				tls_type="tls"
				tunnel_port="443"
			fi
		fi
		
		# End Client
		end_client ${config_name} $(cat -n ${dir_vpnray}/${config_filename} | grep '## END Client' | awk '{print $1}')

		#Insert Template
		if [[ $(cat ${dir_vpnray}/${config_filename} | grep -c '### Client') == 0 ]]; then
			sed -i 's|## END Client|### Client dddddddddd gggggggggg eeeeeeeeee\n{"user": "ffffffffff","pass": "aaaaaaaaaa","email": "ffffffffff"}\n## END Client|g' ${dir_vpnray}/${config_filename}
			
		else
			sed -i 's|## END Client|,\n### Client dddddddddd gggggggggg eeeeeeeeee\n{"user": "ffffffffff","pass": "aaaaaaaaaa","email": "ffffffffff"}\n## END Client|g' ${dir_vpnray}/${config_filename}
		fi
		
		#Insert Details Account
		sed -i "s|aaaaaaaaaa|${userid}|g" ${dir_vpnray}/${config_filename}
		sed -i "s|bbbbbbbbbb|${level}|g" ${dir_vpnray}/${config_filename}
		sed -i "s|cccccccccc|${alterid}|g" ${dir_vpnray}/${config_filename}
		sed -i "s|dddddddddd|${DATEEXP}|g" ${dir_vpnray}/${config_filename}
		sed -i "s|eeeeeeeeee|${userpass}|g" ${dir_vpnray}/${config_filename}
		sed -i "s|ffffffffff|${config_name}-${userpass}|g" ${dir_vpnray}/${config_filename}
		sed -i "s|gggggggggg|${transport_name^^}|g" ${dir_vpnray}/${config_filename}
		
		#Config Link
		link_config="${type_vpnray}://$(echo -n "${config_name}-${userpass}:${userid}" | base64 | sed ':a;N;$!ba;s/\n//g')@${MYIP}:${tunnel_port}#${config_name}-${userpass}"
		echo -e "━━━━━━━━━━━━━━━━"
		echo -e "<b>${config_name^^}</b>"
		echo -e "Username : <code>${config_name}-${userpass}</code>"
		echo -e "Password : <code>${userid}</code>"
		if [[ "${transport_name}" == "tcp" ]]; then
			if [[ "${tls_type}" == "ntls" ]]; then
				echo -e "Port TCP nTLS : <code>${tunnel_port}</code>"
			else
				echo -e "Port TCP TLS : <code>${tunnel_port}</code>"
			fi
		fi
		if [[ "${transport_name}" == "grpc" ]]; then
			echo -e "Service Name : <code>${config_name}</code>"
			echo -e "gRPC Mode : <code>gun</code>"
		elif [[ "${transport_name}" == "ws" ]]; then
			echo -e "WS PATH : <code>/YOURPATH/${config_name}</code>"
		fi
		echo -e "<code>${link_config}</code>"
        
        # Clash Proxy
        if [[ ! "$(cat ${root_vpnray}/vpnray-clash 2> /dev/null)" == 'disable' ]]; then
            tunnel_type="$(echo -e "${config_name}" | cut -d '-' -f 2-)"
            link_clash="https://raw.githubusercontent.com/GegeDevs/sshvpn-script/master/Custom-Client-Config/clash-oneline/clash-${tunnel_type}.yaml"
            http_status="$(curl --write-out '%{http_code}' --silent --output /dev/null "${link_clash}")"
            if [[ ${http_status} -eq 200 ]]; then
                echo -e "━━━━━━━━<b>CLASH PROXY</b>━━━━━━━━"
                clash_config="$(curl -Ss -kL "${link_clash}" | \
                    sed "s|CONFIG_NAME|${config_name}-${userpass}|g" | \
                    sed "s|IPVPS|${MYIP}|g" | \
                    sed "s|PORT_TUNNEL|${tunnel_port}|g" | \
                    sed "s|DOMAINVPS|${coredomain}|g" | \
                    sed "s|SS_CIPHER|${ss_method}|g" | \
                    sed "s|WSPATH|${path_content}|g" | \
                    sed "s|SERVICENAME|${path_content}|g" | \
                    sed "s|USERNAME|${config_name}-${userpass}|g" | \
                    sed "s|UUID_DATA|${userid}|g" | \
                    sed "s|PASSWORD|${userid}|g")"
                echo -e "<code>${clash_config}</code>"
                echo -e ''
            fi
        fi
	done
}

# Service Restarter
function vpnray_restarter(){
	systemctl enable vpnray@$1
	systemctl restart vpnray@$1
}

function show_account(){
    echo "HTML_CODE"
    echo "━━━━━━━━━━━━━━━━"
	echo "<b>${name_vpnray} Account Detail</b>"
    echo "━━━━━━━━━━━━━━━━"
	echo "Host : <code>${MYIP}</code>"
	echo "Domain : <code>${coredomain}</code>"
	echo "Client Name : <code>${userpass}</code>"
	echo "Expired : ${SDATEEXP}"
	if [[ ! "${network_type}" == "tcp" ]]; then
		if [[ ! "${network_type}" == "grpc" ]]; then
			echo "Port nTLS : <code>80</code>"
		fi
		echo "Port TLS : <code>443</code>"
	fi
	echo "━━━━━━━━<b>${name_vpnray}</b>━━━━━━━━"
	echo "Core : <i>${selected_core^^} ${core_version}</i>"
	echo "Username : Username is different for each type"
	echo "Password : <code>${userid}</code>"
	add_account
    echo "━━━━━━━━━━━━━━━━"
	echo "<b>Download your account</b>"
	echo "http://${MYIP}:81/vpnray/${userid}.txt"
    echo "━━━━━━━━━━━━━━━━"
}

show_account | tee -a /var/www/html/vpnray/${userid}.txt
sed -i 's/━/-/g;s/<[^>]\+>//g' /var/www/html/vpnray/${userid}.txt
vpnray_restarter ${selected_core} &
