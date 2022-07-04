#!/bin/bash

EXTENSION_DIR=extensions
CONFIG_FILE=firefox_addons.conf
IS_VERBOSE=false

usage(){ echo "Usage: $0 [-v (verbosity ON)] [-d <temporary extension dir>] [-c <config file>]" 1>&2; exit 1; }

verbose_echo(){
    if [[ "${IS_VERBOSE}" = true  ]]; then
        echo "$1"
    fi
}

# create the addon temp dir
init(){
    verbose_echo "[...] Creating ${EXTENSION_DIR}"
	mkdir -p "$EXTENSION_DIR"
    verbose_echo "[+] Done"
}

# $1 = name of the file
# return = if not existing or not valid false else true
valid_conf_file(){
	local file_name="$1"
    verbose_echo "[...] Checking conf file ${file_name}"
	if [[ ! -f "${file_name}" ]]; then
		echo "[-] The config file ${file_name} does not exist."
		false
	else
		# check if there is a non-valid line
		local count_invalid_lines=`grep -vo '^[^:\s]+:\d+$' ${file_name} | wc -l`
		if [[ ${count_invalid_lines} -le 0 ]]; then
			echo '[-] The config file has invalid lines:'
			grep -von '^[^:\s]+:\d+$' ${file_name}
			false
		else
            verbose_echo "[+] The config file ${file_name} is valid"
			true
		fi
	fi
}

# downloads addon
# $1 = name of the addon
# $2 = id of the account used for the addon
# return = /
get_addon(){
	local addon_name="$1"
	local addon_account_id="$2"
	local addon_url="https://addons.mozilla.org/firefox/downloads/latest/${addon_name}/addon-${addon_account_id}-latest.xpi"
    local addon_destination="${EXTENSION_DIR}/${addon_name}.xpi"
    verbose_echo "[...] Getting addon from ${addon_url}"
    wget ${addon_url} -O ${addon_destination}
    verbose_echo "[+] File saved in ${addon_destination}"
}

# install addon
# $1 = name of the addon
# return = /
install_addon(){
	local addon_name="$1"
    local addon_file="${EXTENSION_DIR}/${addon_name}.xpi"
    local addon_destination="${EXTENSION_DIR}/${addon_name}"

    verbose_echo "[...] Unzipping ${addon_file}"
	unzip ${addon_file} -d ${addon_destination}
	rm -f ${addon_file}
    verbose_echo "[+] ${addon_file} unziped in ${addon_destination} and deleted"

    local addon_id=`cat ${addon_destination}/manifest.json |jq -r '.applications.gecko.id'`
    local addon_destination_id="$HOME/.mozilla/extensions/${addon_id}"
    verbose_echo "[?] id is: ${addon_id}"
    verbose_echo "[...] renaming ${addon_destination} into ${addon_destination_id}"
    mkdir -p "${addon_destination_id}"
    mv ${addon_destination}/* "${addon_destination_id}/."
    rm -rf "${addon_destination}"
    verbose_echo "[+] Done"
}

while getopts ":d:c:v" opt; do
	case "${opt}" in
		d)
			EXTENSION_DIR=${OPTARG}
			;;
		c)
			CONFIG_FILE=${OPTARG}
			valid_conf_file || usage
			;;
		v)	IS_VERBOSE=true
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

init
while read conf; do
	addon_name=${conf%:*}
	addon_account_id=${conf##*:}
	get_addon $addon_name $addon_account_id
	install_addon $addon_name $addon_account_id
done < ${CONFIG_FILE}
