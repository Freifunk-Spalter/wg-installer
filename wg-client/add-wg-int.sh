#client installation

function register_interface {
    local ip=$1
    local bw=$2
    local mtu=$3
    local pubkey=$4

    wg-client-installer register $ip --user wginstaller --password wginstaller --ip $ip --banwdith $bw --mtu $mtu --pubkey $pubkey
}