FROM busybox
ADD  usr/bin/nsenter /bin/nsenter
ADD  lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
ADD  docker-entrypoint.sh /bin/link-manager
ENTRYPOINT ["link-manager"]