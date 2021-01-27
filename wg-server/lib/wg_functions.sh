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
	local uplink_bw=$1
	local mtu=$2
	local public_key=$3

	port=$(next_port)
	ifname="wg_$port"
	base_prefix=$(uci get wgserver.@server[0].base_prefix)
	#delegate_prefix=$(uci get wgserver.@server[0].delegate_prefix)
	port_start=$(uci get wgserver.@server[0].port_start)

	offset=$(($port-$port_start))
	#addbase=$(($offset * $delegate_prefix))
	addbase=$(($offset * 2 - 1))
	gw_ip=$(owipcalc $base_prefix add $addbase next 128) # gateway ip
	client_ip=$(owipcalc $gw_ip next 128) # client ip
	gw_ip_assign="${gw_ip}/128"
	client_ip_assign="${client_ip}/128"


	#gw_ip=$base_prefix
	#for i in $(seq $offset);
	#do  
   	#	gw_ip=$(owipcalc $gw_ip next $delegate_prefix)
	#done
	#gw_ip_assign=$(owipcalc $gw_ip add 1)

	gw_key=$(uci get wgserver.@server[0].wg_key)
	gw_pub=$(uci get wgserver.@server[0].wg_pub)
	wg_server_pubkey=$(cat $gw_pub)

	# create wg tunnel
	ip link add dev $ifname type wireguard
	wg set $ifname listen-port $port private-key $gw_key peer $public_key allowed-ips ::0/0
	ip -6 a a  $gw_ip_assign dev $ifname
	ip -6 a a fe80::1/64 dev $ifname
	ip link set up dev $ifname
	ip link set mtu $mtu dev $ifname

	# craft return address
	json_init
	json_add_string "pubkey" $wg_server_pubkey
	json_add_string "gw_ip" $gw_ip_assign
	json_add_int "port" $port
	json_add_string "client_ip" $client_ip_assign

	# reload babel
	/etc/init.d/babeld reload

	echo $(json_dump)
}
