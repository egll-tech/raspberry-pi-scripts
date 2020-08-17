#!/bin/bash

## ARP Routing Management Script
## Made by Jiab77 <jonathan.barda@gmail.com>
## Original post https://gist.github.com/Jiab77/76000284f8200da5019a232854421564

## Config
ETHERNET_IFACE=eth0
WIRELESS_IFACE=wlan0
DISABLE_POWER_MGMT=true

## Help
if [ $# -eq 0 ]; then
	echo -e "\nUsage: $0 action [start|stop|restart|status]\n"
	exit
fi

## Functions
function start_service {
	## Setup system forwarding
	echo -e "\nEnable IP forwarding..."
	echo 1 > /proc/sys/net/ipv4/ip_forward
	## Uncomment lines below if you don't want to use parprouted.
	#echo "Enable ARP forwarding"
	# Comment for all interfaces
	#echo 1 > /proc/sys/net/ipv4/conf/${WIRELESS_IFACE}/proxy_arp
	# Uncomment for all interfaces
	#echo 1 > /proc/sys/net/ipv4/conf/all/proxy_arp

	## Fix the 'eth0' interface that don't want to mount at boot on 3b+
	## Uncomment this part if the 'eth0' interface is not mounted at boot
	#/usr/sbin/netplan apply

	## A little sleep
	sleep 2

	## Assign address
	echo "Cloning IP from ${WIRELESS_IFACE} to ${ETHERNET_IFACE}..."
	/sbin/ip addr add $(/sbin/ip addr show $WIRELESS_IFACE | perl -wne 'm|^\s+inet (.*)/| && print $1')/32 dev $ETHERNET_IFACE

	## Uncomment lines below in case you're encountering the same issues
	#echo "Removing bad APIPA IP from ${ETHERNET_IFACE}"
	#/sbin/ip addr del $(/sbin/ip addr show $ETHERNET_IFACE | perl -wne 'm|^\s+inet (169.254.*)/| && print $1')/16 dev $ETHERNET_IFACE
	#echo "Removing bad APIPA route from ${ETHERNET_IFACE}"
	#/sbin/ip route del 169.254.0.0/16 dev $ETHERNET_IFACE

	## Make sure that the eth0 interface is up
	echo "Setting up lan interface..."
	/sbin/ip link set $ETHERNET_IFACE up

	## Setup ARP forwarding
	echo "Starting paraprouted..."
	/usr/bin/killall -KILL parprouted 2> /dev/null
	/usr/sbin/parprouted $ETHERNET_IFACE $WIRELESS_IFACE

	## Reloading DHCP Relay
	echo "Start / Reload DHCP Relay..."
	/bin/systemctl restart dhcp-helper

	## A little sleep
	sleep 2

	## Refresh local ARP cache
	echo "Refresh local ARP cache..."
	/sbin/ip -s -s neigh flush all
}

function stop_service {
	## Stop ARP forwarding
	echo -e "\nKilling paraprouted..."
	/usr/bin/killall -KILL parprouted 2> /dev/null

	## Stop DHCP Relay
	echo "Stoping DHCP Relay..."
	/bin/systemctl stop dhcp-helper

	## Remove assigned address
	echo "Removing attached IP to ${ETHERNET_IFACE}..."
	/sbin/ip addr del $(/sbin/ip addr show $WIRELESS_IFACE | perl -wne 'm|^\s+inet (.*)/| && print $1')/32 dev $ETHERNET_IFACE

	## Stop ethernet interface
	echo "Setting lan interface down..."
	/sbin/ip link set $ETHERNET_IFACE down

	## Disable system forwarding
	echo "Disable IP forwarding..."
	echo 0 > /proc/sys/net/ipv4/ip_forward

	## Refresh local ARP cache
	echo "Refresh local ARP cache..."
	/sbin/ip -s -s neigh flush all
}

function service_status {
	IP_FORWARDING_STATUS=$(cat /proc/sys/net/ipv4/ip_forward)
	ARP_ROUTING_PROC=$(ps aux | grep -v grep | grep -i parprouted)

	## Display network interfaces config
	echo -e "\nNetwork interfaces:\n"
	/sbin/ip -c a

	## Display IP forwarding status
	if [[ $IP_FORWARDING_STATUS == '0' ]]; then
		echo -e "\nIP forwarding: disabled"
	else
		echo -e "\nIP forwarding: enabled"
	fi

	## Display ARP routing process
	echo -e "\nARP Routing process:\n$ARP_ROUTING_PROC"

	## Display ARP table
	echo -e "\nARP table:\n"
	/usr/sbin/arp -vn

	## Display DHCP Helper status
	echo -e "\nDHCP Relay status:\n"
	/bin/systemctl status dhcp-helper
}

function generic_actions {
	## Disable wireless power management
	## Set the variable to true if your wireless speed is too low
	if [[ $DISABLE_POWER_MGMT == true ]]; then
		/sbin/iwconfig $WIRELESS_IFACE power off
	fi
}

## Actions (Generic)
generic_actions

## Actions (Service)
case "$1" in
	'start')
		start_service
	;;

	'stop')
		stop_service
	;;

	'restart')
		stop_service
		sleep 5
		start_service
	;;

	'status')
		service_status
	;;

	*)
		echo -e "\nInvalid argument.\n"
	;;
esac

## End Process