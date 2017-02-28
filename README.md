# Link-Manager

This docker-image can be started by pipework, because the pipework dhcp support cannot refresh dhcp leases.

# Usage

```shell
pipework $(docker run --name=myapp-network \
                      --cap-add=net_admin \
                      --network=none \
                      --detach \
                      steigr/link-manager) 0/0
docker run --rm --network=container:myapp-network myapp-container
```

## UTS namespace inheritance

As of Docker 17.03 sharing UTS namespaces between is not supported. Thus updating uts hostname in link-manager via DHCP will not update uts hostname which inherited the networkstack from link-manager (but /etc/hosts, /etc/hostname and /etc/resolv.conf will be updated!).

An (little bit weird) option is to share PID namespaces between those containers. Then the link-manager checks if
a) hostname can be updated -> container has CAP_SYS_ADMIN
b) all PIDs with 0 as PPID and unequal to 1 -> other containers init processes, running in their respective UTS namespace.

Then it tries to `nsenter -m -u` to each pid and set the hostname there which works but has some implications:
- service container init aren't PID=1 (because of the shared PID namespace). This may confuse some container and/or real init systems like tini (See `TINI_SUBREAPER` environment variable) or systemd (run with `--system` or use included systemd-networkd to container manage network on its own).

# Docker image

[![](https://images.microbadger.com/badges/image/steigr/link-manager.svg)](http://microbadger.com/images/steigr/link-manager "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/steigr/link-manager.svg)](http://microbadger.com/images/steigr/link-manager "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/steigr/link-manager.svg)](http://microbadger.com/images/steigr/link-manager "Get your own commit badge on microbadger.com")
