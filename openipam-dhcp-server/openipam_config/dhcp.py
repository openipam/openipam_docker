# The default DHCP lease time for all statically assigned addresses. Dynamic
# lease times are configured on the pool.

import os

static_lease_time = 86400

# The IP address of this server
listen_address = os.environ.get('listen_address', '192.168.0.1')
listen_interface = os.environ.get('listen_interface', 'eth0')

server_listen = [{'address': listen_address, 'interface': listen_interface, 'broadcast': True, 'unicast': True, }]

# DHCP options that should always be returned if they are defined
force_options = [60, 66, 67]

sentry_url = os.environ.get('sentry_url')
