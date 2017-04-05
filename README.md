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
## LACP is not needed, just something we chose to do in our environment
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

Look at the `*.env.example` files to get an idea of which environment options are respected

# How I run the servers

### web

I have proxied the web foo behind nginx on the host because I am lazy.

```sh
docker run --name dev-openipam-web --env-file=openipam_web_options.env -v /var/run/docker_openipam_dev:/var/run/uwsgi openipam-web
```

Here is the corresponding nginx config:

```
upstream openipam_dev {
    server unix:///var/run/docker_openipam_dev/openipam.sock;
}

server {
    listen 443 ssl;
    
    # SSL config omitted for brevity
    
    location / {
        uwsgi_pass openipam_dev;
        include uwsgi_params;
    }
}
```

### DHCP

```sh
docker run --env-file ~/dhcp_server.env --net ipamnet --ip <container_ip> -v /dev/log:/dev/log --name dhcptest --restart=unless-stopped -d openipam-dhcp
```

### PostgreSQL replica

TODO:
I don't recommend running your production database in a docker container.  We are currently using londiste3 to keep an up-to-date replica without the write load from DHCP to handle DNS queries.

### PowerDNS authoritative

This is the DNS server you should point NS records at

```sh
# FIXME: I don't think this is configured to log to syslog currently
docker run --env-file openipam-root-test.env --net ipamnet --ip 129.123.0.7 -v /run/postgresql/:/var/run/postgresql/ -v /dev/log:/dev/log --name openipam-nsroot-test_0.7 -d openipam-powerdns-authoritative
```

### PowerDNS recursor

TODO:
This is the DNS server you should point clients at -- any other DNS recursor will work as well
