#!/bin/sh

. /usr/share/libubox/jshn.sh

function wg_get_usage {
    num_interfaces = $(wg show interfaces | wc -w)
    json_init
    json_add_int "num_interfaces" $num_interfaces
    echo $(json_dump)
}
