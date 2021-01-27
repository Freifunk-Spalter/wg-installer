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
    --pubkey)
      PUBKEY=$2
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

function register_client_interface {
  local pubkey=$1
  local ip_addr=$2
  local port=$3
  local endpoint=$4

  # use the 2 as interface ip
  client_ip=$(owipcalc $ip_addr add 1)
  echo "Installing Interface With:"
  echo "Endpoint ${endpoint}"
  echo "client_ip ${client_ip}"
  echo "port ${port}"
  echo "pubkey ${pubkey}"

  ip link add dev wg0 type wireguard
  
  # todo check if ipv6
  ip -6 a a dev wg0 $client_ip
  wg set wg0 listen-port $port private-key /root/wg.key peer $pubkey allowed-ips ::1 endpoint "${endpoint}:${port}"
  ip link set up dev wg0
  ip link set mtu 1372 dev wg0
}

# rpc login
token="$(request_token $IP $USER $PASSWORD)"

# now call procedure 
case $CMD in
  "get_usage")
    wg_rpcd_get_usage $token $IP
    ;;
  "register") 
    register_output=$(wg_rpcd_register $token $IP $BANDWIDTH $WG_MTU $PUBKEY)
    pubkey=$(echo $register_output | grep pubkey | awk '{print $2}')
    ip_addr=$(echo $register_output | grep ip_addr | awk '{print $4}')
    port=$(echo $register_output | grep port | awk '{print $6}')
    register_client_interface $pubkey $ip_addr $port $IP
    ;;
   *) echo "Usage: wg-client-installer [cmd] --ip [2001::1] --user wginstaller --password wginstaller --pubkey xyz ;;"
esac
