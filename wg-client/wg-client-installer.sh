#!/bin/sh

. /usr/share/wginstaller/rpcd_ubus.sh

CMD=$1
shift

while true ; do
  case "$1" in
    -h|--help)
      echo "help"
      shift 1
      ;;
    -i|--ip)
      IP=$2
      shift 2
      ;;
    --user)
      USER=$2
      shift 2
      ;;
    --password)
      PASSWORD=$2
      shift 2
      ;;
    --bandwidth)
      BANDWIDTH=$2
      shift 2
      ;;
    --mtu)
      WG_MTU=$2
      shift 2
      ;;
    '')
      break
      ;;
    *)
      break
      ;;
  esac
done

function escape_ip {
  local gw_ip=$1

  # ipv4 processing
  ret_ip=$(echo $gw_ip | tr '.' '_')
	
	# ipv6 processing
	ret_ip=$(echo $ret_ip | tr ':' '_')
	ret_ip=$(echo $ret_ip | cut -d '[' -f 2)
	ret_ip=$(echo $ret_ip | cut -d ']' -f 1)

  echo $ret_ip
}

function register_client_interface {
  local pubkey=$1
  local ip_addr=$2
  local port=$3
  local endpoint=$4

  gw_key=$(uci get wgclient.@client[0].wg_key)
  interface_name="gw_$(escape_ip $endpoint)"

  # use the 2 as interface ip
  client_ip=$(owipcalc $ip_addr add 2)
  echo "Installing Interface With:"
  echo "Endpoint ${endpoint}"
  echo "client_ip ${client_ip}"
  echo "port ${port}"
  echo "pubkey ${pubkey}"

  ip link add dev $interface_name type wireguard
  
  # todo check if ipv6
  ip -6 a a dev $interface_name $client_ip
  wg set $interface_name listen-port $port private-key $gw_key peer $pubkey allowed-ips ::/0 endpoint "${endpoint}:${port}"
  ip link set up dev $interface_name
  ip link set mtu 1372 dev $interface_name # configure mtu here!
}

# rpc login
token="$(request_token $IP $USER $PASSWORD)"

# now call procedure 
case $CMD in
  "get_usage")
    pubkey
    wg_rpcd_get_usage $token $IP
    ;;
  "register")
  	gw_pub=$(uci get wgclient.@client[0].wg_pub)
    gw_pub_string=$(cat $gw_pub)
    register_output=$(wg_rpcd_register $token $IP $BANDWIDTH $WG_MTU $gw_pub_string)
    pubkey=$(echo $register_output | grep pubkey | awk '{print $2}')
    ip_addr=$(echo $register_output | grep ip_addr | awk '{print $4}')
    port=$(echo $register_output | grep port | awk '{print $6}')
    register_client_interface $pubkey $ip_addr $port $IP
    ;;
   *) echo "Usage: wg-client-installer [cmd] --ip [2001::1] --user wginstaller --password wginstaller --pubkey xyz ;;"
esac
