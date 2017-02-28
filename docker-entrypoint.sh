#!/bin/sh

pidof tini </dev/null >/dev/null 2>&1 || exec tini "$0" "$@"
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
	echo "nameserver $dns" >> /etc/resolv.conf
	ip route add default via $router
	echo $hostname > /etc/hostname
	sed "/ $hostname/d" /etc/hosts > /etc/hosts.tmp
	cat /etc/hosts.tmp > /etc/hosts
	rm /etc/hosts.tmp
	hstring="$ip"
	test "$domain" && hstring="$hstring $hostname.$domain"
	echo "$hstring $hostname" >> /etc/hosts
	# requires CAP_SYS_ADMIN ( --cap-add=SYS_ADMIN )
	if hostname -F /etc/hostname; then
		# obviously we have CAP_SYS_ADMIN
		# so check all other pids with ppid==0 and
		# apply the hostname too
		find /proc -regex "/proc/[0-9]*/stat" -maxdepth 2 -mindepth 2 -exec awk '{ if(($4=="0")&&($1 > 1)) print $1}' '{}' ';' \
		| xargs -I{} -n1 -r nsenter -m -u -t {} hostname -F /etc/hostname
	fi
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