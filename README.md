# openipam_docker
Our docker container definitions

Hopefully, this helps give an idea about what it takes to set this up.

# Get docker0 to behave
```
# /etc/systemd/system/docker.service
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --bip=192.0.2.1/24

```

# add docker repo from dockerproject.org

# install docker-engine

# set up interfaces

```
# /etc/network/interfaces
auto bond0
iface bond0 inet manual
        bond_slaves eth2 eth3
	# LACP, requires matching switch configuration
        bond_mode 802.3ad

auto br0
iface br0 inet manual
	bridge-ports bond0
	bridge-maxwait 0
	bridge-fd 0

```

# add bridge to docker, NB: removing the bridge in docker will delete the bridge and all slave interfaces

```
docker network create -d bridge --gateway <ip_for_br0> -o com.docker.network.bridge.name=br0 -o com.docker.network.bridge.enable_ip_masquerade=false --aux-address "DefaultGatewayIPv4=<default_gateway>" --subnet <network_CIDR> ipamnet
```

# login to local registry

```
docker login local.registry.hostname
```

# set some values

```
# dhcptest.env 
# Database options
db_host=openipam.my.site
db_database=openipam
db_username=dhcp
db_password=something_secure

# other server parameters
listen_address=<container_ip>
listen_interface=eth0
sentry_url=https://my.sentry.host/...

```

# run the servers

## DHCP

```sh
docker run --env-file ~/dhcp_server.env --net ipamnet --ip <container_ip> -v /dev/log:/dev/log --name dhcptest --restart=unless-stopped -d <local_registry>/openipam/dhcp:latest
```

## PowerDNS authoritative

```sh
# FIXME: I don't think this is configured to log to syslog currently
docker run --env-file openipam-root-test.env --net ipamnet --ip 129.123.0.7 -v /run/postgresql/:/var/run/postgresql/ -v /dev/log:/dev/log --name openipam-nsroot-test_0.7 -d openipam-powerdns-authoritative
```

