Some docker hints:

#create a network

Since I hate the idea of adding NAT to the mix, here is how I did this:

Create a bridge with the outside interface as a member in `/etc/network/interfaces`:

```bash
auto br123
iface br123 inet static
        address 192.0.2.1
        netmask 255.255.255.0
        gateway 192.0.2.254
        bridge-ports eth0
        bridge-fd 0
        bridge-maxwait 0
        bridge-stp off

```

Create the bridge in docker:

```bash
# FIXME: this appears to delete the existing bridge on a `docker network rm`
# Note: --gateway specifies the bridge IP that docker will set, not necessarily the default gateway
docker network create -o com.docker.network.bridge.name=br123 --aux-address "DefaultGatewayIPv4=192.0.2.1" --subnet 192.0.2.0/25 --gateway 192.0.2.32 docker_ipamnet
```

Build the docker image:

```bash
esk@bits:~/src/openipam_docker$ docker build ./openipam-dhcp-server
Sending build context to Docker daemon 32.26 kB
Step 1 : FROM debian:jessie
<...>
Successfully built d7315bc5c1a0
esk@bits:~/src/openipam_docker$ 
```

and run it:

```bash
docker run --env-file=openipam_dhcp_options.env --net=my_docker_bridge --ip=192.0.2.2 --name openipam_dhcp_server d7315bc5c1a0
```


