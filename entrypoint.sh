#!/bin/sh

# TUN Interface
TUN_ADDR='198.18.0.1'
TUN_NET='198.18.0.0/16'
TUN_DEV='utun'

# MISC
CLASH_TABLE='0x164'
CLASH_USER='proxy'
CLASH_UID=$(id -u "$CLASH_USER")
MAIN_TABLE='main'

SELF=$(readlink -f "$0")
BASEDIR=$(dirname "$SELF")

#wait for TUN device
while ! ip address show "$TUN_DEV" > /dev/null; do
    sleep 0.2
done

ip route flush table "$CLASH_TABLE"
ip route add default via "$TUN_ADDR" dev "$TUN_DEV" table "$CLASH_TABLE"
ip route add "$TUN_NET" dev "$TUN_DEV" table "$CLASH_TABLE"

ip rule add from all table "$CLASH_TABLE"
ip rule add uidrange "${CLASH_UID}-${CLASH_UID}" table "$MAIN_TABLE"
ip rule add to 192.168.0.0/16 table "$MAIN_TABLE"
ip rule add to 172.16.0.0/12 table "$MAIN_TABLE"
ip rule add to 10.0.0.0/8 table "$MAIN_TABLE"
