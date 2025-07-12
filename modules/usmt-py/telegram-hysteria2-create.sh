#!/usr/bin/env bash

USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"
QUOTA="$4"
CYCLE="$5"

tunnel_code="hysteria"
tunnel_name=$(echo "$tunnel_code" | tr '[:lower:]' '[:upper:]')

created="$(usmt.py user add ${USERNAME} --protocol ${tunnel_code} --days ${EXPIRED} --limit-gb ${QUOTA} --subscription ${CYCLE})"

# Parsing using regex and awk/grep/sed
json_transform=$(jq -n \
  --arg username "$(grep -oP 'Username\s+:\s+\K.*' <<< "$created")" \
  --arg uuid "$(grep -oP 'Password/UUID\s+:\s+\K.*' <<< "$created")" \
  --arg subscription "$(grep -oP 'Subscription\s+:\s+\K.*' <<< "$created")" \
  --arg traffic "$(grep -oP 'Traffic Limit\s+:\s+\K.*' <<< "$created" | sed 's/ GB//')" \
  --arg expired "$(grep -oP 'Tanggal Expired\s+:\s+\K.*' <<< "$created")" \
  --arg domain "$(grep -oP 'Domain\s+:\s+\K.*' <<< "$created")" \
  --arg ip "$(grep -oP 'IP Address\s+:\s+\K.*' <<< "$created")" \
  --arg transport "$(grep -oP 'Transport\s+:\s+\K.*' <<< "$created")" \
  --arg port "$(grep -oP 'Port\s+:\s+\K.*' <<< "$created")" \
  --arg sni "$(grep -oP 'SNI \(ServerName\)\s+:\s+\K.*' <<< "$created")" \
  --arg obfs "$(grep -oP 'obfs\s+:\s+\K.*' <<< "$created")" \
  --arg obfs_password "$(grep -oP 'obfs-password\s+:\s+\K.*' <<< "$created")" \
  --arg url "$(grep -A1 'Hysteria2' <<< "$created" | tail -n1)" \
  --arg status_url "$(grep -oP 'Check Status Account\s+:\s+\K.*' <<< "$created")" \
  --arg contact "$(grep -oP 'Contact:\s+\K.*' <<< "$created")" \
  --arg group "$(grep -oP 'VVIP Group:\s+\K.*' <<< "$created")" \
  --arg log "$(grep -oP 'nginx-rc.service.*' <<< "$created")" \
  '{
    account_info: {
      username: $username,
      uuid: $uuid,
      subscription: $subscription,
      traffic_limit_gb: ($traffic | tonumber),
      expired_date: $expired
    },
    server: {
      domain: $domain,
      ip_address: $ip,
      transport: $transport,
      port: $port,
      sni: $sni,
      obfs: $obfs,
      obfs_password: $obfs_password
    },
    '"${tunnel_code}"': {
      url: $url
    },
    additional: {
      check_status_url: $status_url,
      extend_notice: "Perpanjang 3 hari sebelum tanggal expired",
      contact: $contact,
      vip_group: $group
    },
    log: $log
  }')

usmt_username="$(echo "$json_transform" | jq -r '.account_info.username')"
usmt_uuid="$(echo "$json_transform" | jq -r '.account_info.uuid')"
usmt_subscription="$(echo "$json_transform" | jq -r '.account_info.subscription')"
usmt_traffic_limit_gb="$(echo "$json_transform" | jq -r '.account_info.traffic_limit_gb')"
usmt_expired="$(echo "$json_transform" | jq -r '.account_info.expired_date')"

usmt_domain="$(echo "$json_transform" | jq -r '.server.domain')"
usmt_ip_address="$(echo "$json_transform" | jq -r '.server.ip_address')"
usmt_transport="$(echo "$json_transform" | jq -r '.server.transport')"
usmt_port="$(echo "$json_transform" | jq -r '.server.port')"
usmt_sni="$(echo "$json_transform" | jq -r '.server.sni')"
usmt_obfs="$(echo "$json_transform" | jq -r '.server.obfs')"
usmt_obfs_password="$(echo "$json_transform" | jq -r '.server.obfs_password')"
usmt_url="$(echo "$json_transform" | jq -r '.'"${tunnel_code}"'.url')"
usmt_check_status_url="$(echo "$json_transform" | jq -r '.additional.check_status_url')"
usmt_extend_notice="$(echo "$json_transform" | jq -r '.additional.extend_notice')"
usmt_contact="$(echo "$json_transform" | jq -r '.additional.contact')"
usmt_vip_group="$(echo "$json_transform" | jq -r '.additional.vip_group')"
usmt_log="$(echo "$json_transform" | jq -r '.log')"

echo -e "HTML_CODE"
echo -e "<b>+++++ ${tunnel_name} Account Created +++++</b>"
echo -e "Domain: <code>${usmt_domain}</code>"
echo -e "IP Address: <code>${usmt_ip_address}</code>"
echo -e "Transport: <code>${usmt_transport}</code>"
echo -e "Port: <code>${usmt_port}</code>"
echo -e "SNI: <code>${usmt_sni}</code>"
echo -e "Username: <code>${usmt_username}</code>"
echo -e "Password: <code>${usmt_uuid}</code>"
echo -e "Expired: <code>${usmt_expired}</code>"
echo -e "Data Limit: <code>${usmt_traffic_limit_gb}</code> GB"
echo -e "Quota Cycle: <code>${usmt_subscription}</code>"
echo -e "OBFS: <code>${usmt_obfs}</code>"
echo -e "OBFS Password: <code>${usmt_obfs_password}</code>"
echo -e "URL: <code>${usmt_url}</code>"
echo -e "Check Status Account: <code>${usmt_check_status_url}</code>"
echo -e "Extend Notice: <code>${usmt_extend_notice}</code>"
echo -e "Contact: <code>${usmt_contact}</code>"
echo -e "<b>+++++ End of Server Details +++++</b>"