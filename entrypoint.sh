#!/bin/sh


# Based on https://github.com/Kr328/kr328-clash-setup-scripts/blob/master/setup-clash-tun.sh
ipset create localnetwork hash:net
ipset add localnetwork 127.0.0.0/8
ipset add localnetwork 10.0.0.0/8
ipset add localnetwork 169.254.0.0/16
ipset add localnetwork 192.168.0.0/16
ipset add localnetwork 224.0.0.0/4
ipset add localnetwork 240.0.0.0/4
ipset add localnetwork 172.16.0.0/12

#ip tuntap add user root mode tun utun
#ip link set utun up

ip route replace default dev utun table 0x162
ip rule add fwmark 0x162 lookup 0x162

iptables -t mangle -N CLASH
iptables -t mangle -F CLASH
iptables -t mangle -A CLASH -p tcp --dport 53 -j MARK --set-mark 0x162
iptables -t mangle -A CLASH -p udp --dport 53 -j MARK --set-mark 0x162
iptables -t mangle -A CLASH -m addrtype --dst-type BROADCAST -j RETURN
iptables -t mangle -A CLASH -m set --match-set localnetwork dst -j RETURN
iptables -t mangle -A CLASH -d 198.18.0.0/16 -j MARK --set-mark 0x162
iptables -t mangle -A CLASH -j MARK --set-mark 0x162

iptables -t mangle -I OUTPUT -j CLASH
iptables -t mangle -I PREROUTING -m set ! --match-set localnetwork dst -j MARK --set-mark 0x162

#iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 53 -j REDIRECT --to-ports 1053
#iptables -t nat -A PREROUTING -p udp -i eth0 --dport 53 -j REDIRECT --to-ports 1053

iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE

sysctl -w net/ipv4/ip_forward=1
sysctl -w net.ipv4.conf.utun.rp_filter=0
