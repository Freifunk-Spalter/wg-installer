#!/bin/sh

. /usr/share/libubox/jshn.sh

function wg_get_usage {
    num_interfaces = $(wg show interfaces | wc -w)
    json_init
    json_add_int "num_interfaces" $num_interfaces
    echo $(json_dump)
}

function next_port {
	ports=$(wg show all listen-port | awk '{print $2}')

	# assume for now only 1 value @[0]
	port_start=$(uci get wgserver.@server[0].port_start)
	port_end=$(uci get wgserver.@server[0].port_end)

	for i in $(seq $port_start $port_end)
	do
		if ! echo $ports|grep -q "$i";
		then
			echo $i
			return
		fi
	done
}

function wg_register {
	uplink_bw=$1
	public_key=$2
	port=$(next_port)
	ifname="wg_$port"
	base_prefix=$(uci get wgserver.@server[0].base_prefix)

	# create wg tunnel
	#ip link add dev $ifname type wireguard
	#wg set $ifname listen-port $port private-key /root/wgserver.key peer $public_key allowed-ips ::/0
	#ip -6 a a  $BASE_PREIFX_NEXT_PORT_NUM_ALS_IP dev $ifname
	#ip -6 a a fe80::1/64 dev $ifname
	#ip link set up dev $ifname	

	#uci add network wireguard_wg0
	#uci set network.@wireguard_wg0[-1].public_key=$2
	#uci add_list network.@wireguard_wg0[-1].allowed_ips="::/0"

	# reload babel
	/etc/init.d/babeld reload
}
