#!/bin/bash


cat << EOF > /etc/powerdns/pdns.conf
# generated on $(date) by start_pdns.sh, do not edit

$(if "$PDNS_CARBON_SERVER"; then
cat << EOFCARBON
carbon-interval=60
carbon-ourname=ipam.dns.docker.${PDNS_SERVER_LABEL:-UNSET}
carbon-server=$PDNS_CARBON_SERVER
EOFCARBON
fi)

distributor-threads=4
launch=gpgsql
local-address=${PDNS_LOCAL_ADDRESS:-0.0.0.0}
log-dns-details=yes
log-dns-queries=yes
logging-facility=1
loglevel=9
out-of-zone-additional-processing=yes
setuid=pdns
webserver=yes
gpgsql-dbname=${PDNS_PGSQL_DB:-openipam_cache}
gpgsql-host=${PDNS_PGSQL_HOST:-/var/run/postgresql}
gpgsql-user=${PDNS_PGSQL_USER:-pdns}
gpgsql-password=${PDNS_PGSQL_PASSWORD:-}

EOF

unset PDNS_PGSQL_DB PDNS_PGSQL_HOST PDNS_PGSQL_USER PDNS_PGSQL_PASSWORD PDNS_CARBON_SERVER PDNS_SERVER_LABEL

exec /usr/sbin/pdns_server

