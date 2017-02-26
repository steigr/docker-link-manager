FROM busybox
ADD  docker-entrypoint.sh /bin/link-manager
ENTRYPOINT ["link-manager"]