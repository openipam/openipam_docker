# openipam_docker
Our docker container definitions

Hopefully, this helps give an idea about what it takes to set this up.

# install docker-engine

Be sure you aren't talking to 172.17.0.0/16 before you do this!  If you use
that address range elsewhere, please apply the fix for docker0 before
installing docker.

### add docker repo from dockerproject.org

# set up interfaces

Using docker for services that require a fixed IP address (ie. DNS/DHCP) can be
a bit tricky.  My goal was to avoid adding NAT in the middle so that a stopped
container would not respond to ARP requests and could be moved without fiddling
with the host network.  To accomplish this, I use a bridge with a physical
interface in the proper network as the docker network for these containers.

### Get docker0 to behave

By default, docker0 will use the least-convenient IPv4 non-routable range
possible in my environment.  To make matters worse, the typical way to fix this
on Debian (editing `/etc/default/docker`) has no effect if you are running
under systemd (the new default in debian).  To change the docker0 bridge IP, I
do the following:

```
# /etc/systemd/system/docker.service
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --bip=192.0.2.1/24

```

### bridge config

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

### add bridge to docker, NB: removing the bridge in docker will delete the bridge and all slave interfaces

```
docker network create -d bridge --gateway <ip_for_br0> -o com.docker.network.bridge.name=br0 -o com.docker.network.bridge.enable_ip_masquerade=false --aux-address "DefaultGatewayIPv4=<default_gateway>" --subnet <network_CIDR> ipamnet
```

# How I run the servers

### set some values

Look at the `*.env.example` files to get an idea of which environment options are respected

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

This will need to be running on the IP address configured as a helper address on your routers (it may also work on something in the same L2 domain as your clients).

```sh
docker run --env-file ~/dhcp_server.env --net ipamnet --ip $IP_HELPER_ADDRESS -v /dev/log:/dev/log --name dhcptest --restart=unless-stopped -d openipam-dhcp
```

### PostgreSQL replica

TODO:
I don't recommend running your production database in a docker container.  We are currently using londiste3 to keep an up-to-date replica without the write load from DHCP to handle DNS queries.

### PowerDNS authoritative

This is the DNS server you should point NS records at

```sh
# FIXME: I don't think this is configured to log to syslog currently
docker run --env-file openipam-root-test.env --net ipamnet --ip $IP_FROM_NS_RECORDS -v /run/postgresql/:/var/run/postgresql/ -v /dev/log:/dev/log --name dev-openipam-nsroot -d openipam-powerdns-authoritative
```

### PowerDNS recursor

TODO:
This is the DNS server you should point clients at -- any other DNS recursor will work as well
