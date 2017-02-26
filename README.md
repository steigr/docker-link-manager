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

# Docker image

[![](https://images.microbadger.com/badges/image/steigr/link-manager.svg)](http://microbadger.com/images/steigr/link-manager "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/steigr/link-manager.svg)](http://microbadger.com/images/steigr/link-manager "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/steigr/link-manager.svg)](http://microbadger.com/images/steigr/link-manager "Get your own commit badge on microbadger.com")
