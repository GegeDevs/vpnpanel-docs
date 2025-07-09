#!/usr/bin/env bash

USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"
QUOTA="$4"
CYCLE="$5"

tunnel_code="trojan"
tunnel_name=$(echo "$tunnel_code" | tr '[:lower:]' '[:upper:]')
tunnel_mode="ws"

created="$(usmt.py user add ${USERNAME} --protocol ${tunnel_code}-${tunnel_mode} --days ${EXPIRED} --limit-gb ${QUOTA} --subscription ${CYCLE})"
syncpass="$(usmt.py user modify ${USERNAME} --protocol ${tunnel_code}-${tunnel_mode} --new-secret ${PASSWORD})"

# Parsing menggunakan regex dan awk/grep/sed
json_transform=$(jq -n \
  --arg username "$(grep -oP 'Username\s+:\s+\K.*' <<< "$created")" \
  --arg uuid "$(grep -oP 'Password/UUID\s+:\s+\K.*' <<< "$created")" \
  --arg subscription "$(grep -oP 'Subscription\s+:\s+\K.*' <<< "$created")" \
  --arg traffic "$(grep -oP 'Traffic Limit\s+:\s+\K.*' <<< "$created" | sed 's/ GB//')" \
  --arg expired "$(grep -oP 'Tanggal Expired\s+:\s+\K.*' <<< "$created")" \
  --arg domain "$(grep -oP 'Domain\s+:\s+\K.*' <<< "$created")" \
  --arg ip "$(grep -oP 'IP Address\s+:\s+\K.*' <<< "$created")" \
  --arg transport "$(grep -oP 'Transport\s+:\s+\K.*' <<< "$created")" \
  --arg host "$(grep -oP 'Host \(SNI\)\s+:\s+\K.*' <<< "$created")" \
  --arg path "$(grep -oP 'Path\s+:\s+\K.*' <<< "$created")" \
  --arg wildcard_path "$(grep -oP 'Wildcard URI Path\s+:\s+\K.*' <<< "$created")" \
  --arg ${tunnel_code}_tls "$(grep -A1 'HTTPS/TLS Based' <<< "$created" | tail -n1)" \
  --arg ${tunnel_code}_nontls "$(grep -A1 'HTTP/Non-TLS Based' <<< "$created" | tail -n1)" \
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
      host_sni: $host,
      path: $path,
      wildcard_uri_path: $wildcard_path
    },
    '"${tunnel_code}"': {
      tls: {
        url: $'"${tunnel_code}"'_tls,
        port: 443,
        security: "tls"
      },
      non_tls: {
        url: $'"${tunnel_code}"'_nontls,
        port: 80,
        security: "none"
      }
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
usmt_host_sni="$(echo "$json_transform" | jq -r '.server.host_sni')"
usmt_path="$(echo "$json_transform" | jq -r '.server.path')"
usmt_wildcard_uri_path="$(echo "$json_transform" | jq -r '.server.wildcard_uri_path')"
usmt_tls_url="$(echo "$json_transform" | jq -r '.'"${tunnel_code}"'.tls.url')"
usmt_tls_port="$(echo "$json_transform" | jq -r '.'"${tunnel_code}"'.tls.port')"
usmt_tls_security="$(echo "$json_transform" | jq -r '.'"${tunnel_code}"'.tls.security')"
usmt_nontls_url="$(echo "$json_transform" | jq -r '.'"${tunnel_code}"'.non_tls.url')"
usmt_nontls_port="$(echo "$json_transform" | jq -r '.'"${tunnel_code}"'.non_tls.port')"
usmt_nontls_security="$(echo "$json_transform" | jq -r '.'"${tunnel_code}"'.non_tls.security')"
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
echo -e "Host (SNI): <code>${usmt_host_sni}</code>"
echo -e "Username: <code>${usmt_username}</code>"
echo -e "Password: <code>${usmt_uuid}</code>"
echo -e "Expired: <code>${usmt_expired}</code>"
echo -e "Data Limit: <code>${usmt_traffic_limit_gb}</code> GB"
echo -e "Quota Cycle: <code>${usmt_subscription}</code>"
echo -e "Websocket : <code>${usmt_tls_url}</code>"
echo -e "Path: <code>${usmt_path}</code>"
echo -e "Wildcard URI Path: <code>${usmt_wildcard_uri_path}</code>"
echo -e "TLS URL: <code>${usmt_tls_url}</code>"
echo -e "TLS Port: <code>${usmt_tls_port}</code>"
echo -e "TLS Security: <code>${usmt_tls_security}</code>"
echo -e "Non-TLS URL: <code>${usmt_nontls_url}</code>"
echo -e "Non-TLS Port: <code>${usmt_nontls_port}</code>"
echo -e "Non-TLS Security: <code>${usmt_nontls_security}</code>"
echo -e "Check Status Account: <code>${usmt_check_status_url}</code>"
echo -e "Extend Notice: <code>${usmt_extend_notice}</code>"
echo -e "Contact: <code>${usmt_contact}</code>"
echo -e "<b>+++++ End of Server Details +++++</b>"