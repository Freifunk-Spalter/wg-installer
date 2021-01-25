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
    '')
      break
      ;;
    *)
      break
      ;;
  esac
done

# rpc login
token="$(request_token $IP $USER $PASSWORD)"

# now call procedure 
case $CMD in
  "get_usage") wg_get_usage $token $IP;;
  "register") wg_register $token $IP $BANDWIDTH $PUBKEY ;;
   *) echo "Usage: wg-client-installer [cmd] --ip [2001::1] --user wginstaller --password wginstaller --pubkey xyz ;;"
esac
