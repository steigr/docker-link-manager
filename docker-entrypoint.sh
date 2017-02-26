#!/bin/sh

test -z "$TRACE" || set -x

__deconfig() {
	echo deconfig "$@" >> /proc/1/fd/2
	echo env $(printenv) >> /proc/1/fd/2
	ip link set $interface up
	# remove ipv4 addresses
}

__bound() {
	if test "$TRACE"; then
		echo bound "$@" >> /proc/1/fd/2
		echo env $(printenv) >> /proc/1/fd/2
	fi
	# requires CAP_NET_ADMIN ( --cap-add=NET_ADMIN )
	ip link set $interface up
	ip addr add $ip/$mask dev $interface
	echo "search $domain" > /etc/resolv.conf
	echo "nameserver $dns" > /etc/resolv.conf
	ip route add default via $router
	echo $hostname > /etc/hostname
	# requires CAP_SYS_ADMIN ( --cap-add=SYS_ADMIN )
	hostname -F /etc/hostname || true
}

__renew() {
	if test "$TRACE"; then
		echo renew "$@" >> /proc/1/fd/2
		echo env $(printenv) >> /proc/1/fd/2
	fi
}

__nak() {
	if test "$TRACE"; then
		echo nak "$@" >> /proc/1/fd/2
		echo env $(printenv) >> /proc/1/fd/2
	fi
}

main() {
	set -e
	iface=$1
	if test -z $iface; then
		until ls -d /sys/class/net/e* 2>/dev/null | grep -q 'net/e'; do
			sleep .01
		done
		iface=$(ls -d /sys/class/net/e* 2>/dev/null | sort | head -1 | xargs basename)
	else
		until test -d /sys/class/net/$iface >/dev/null 2>&1; do sleep .01; done	
	fi	
	ip=$2
	ip link show $iface > /dev/urandom
	exec udhcpc -f -i $iface -R -s "$0" -a 500 ${ip:+-r $ip} -F $(hostname -f 2>/dev/null || hostname) ${TRACE:+-v}
}

case "$1" in
	deconfig|bound|renew|nak)
		cmd=$1; shift
		"__$cmd" "$@"
	;;
	*)
		main "$@"
	;;
esac