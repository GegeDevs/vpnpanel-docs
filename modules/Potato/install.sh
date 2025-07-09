#!/bin/bash

source_code="GegeDevs/vpnpanel-docs"
module_name="Potato"
bin_dir="/etc/gegevps/bin"

if [[ "$EUID" -ne 0 ]]; then
    echo "The script must be run as root." >&2
    exit 1
fi

APIKEY="${1}"
LIMITGB="${2}"
LIMITIP="${3}"

if [[ -z "${APIKEY}" || -z "${LIMITGB}" || -z "${LIMITIP}" ]]; then
    echo "Usage: $0 <apikey> <limitgb> <limitip>"
    exit 1
fi

function link_gen(){
    dl_link="https://raw.githubusercontent.com/${source_code}/refs/heads/main/modules/${module_name}/telegram-${1}-${2}.sh"
    echo "${dl_link}"
}

function install_sh(){
    full_link="$(link_gen ${1} ${2})"
    file_name="$(echo "${full_link}" | rev | cut -d'/' -f 1 | rev)"
    wget -qO- "${full_link}" | sed 's/YOUR_APIKEY/'"${APIKEY}"'/g' > "${bin_dir}/${file_name}"
    chmod +x "${bin_dir}/${file_name}"
}

function tunnels_list(){
    echo "
        sshovpn
        vmess
        vless
        trojan
    " | sed 's/^[ \t]*//g;/^$/d'
}

function actions_list(){
    echo "
        create
        extend
        delete
    " | sed 's/^[ \t]*//g;/^$/d'
}

apt-get install -qq -y expect wget
tunnels_list | while read -r tunnel; do
    if [[ ! -d "${bin_dir}" ]]; then
        mkdir -p "${bin_dir}"
    fi
    actions_list | while read -r action; do
        install_sh "${tunnel}" "${action}"
    done
done

echo "Module ${module_name} installed successfully."
