#!/bin/sh

. /usr/share/libubox/jshn.sh
. /usr/share/wginstaller/wg_functions.sh

case "$1" in
	list)
		cmd='{ "get_usage": {},'
		cmd=$(echo $cmd ' "register": {"uplink_bw":"10", "public_key": "xyz"} }')
		echo $cmd
	;;
	call)
		case "$2" in
			get_usage)
				read input;
				logger -t "wginstaller" "call" "$2" "$input"
				wg_get_usage
			;;
			register)
				read input;
				logger -t "wginstaller" "call" "$2" "$input"
				# ToDo: register wireguard instance
			;;
		esac
	;;
esac
