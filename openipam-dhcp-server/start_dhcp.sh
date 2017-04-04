#!/bin/sh

PYTHONPATH=/usr/local/openipam/openIPAM/pydhcplib:/usr/local/openipam/openIPAM
export PYTHONPATH

exec /usr/local/openipam/openIPAM/openipam_dhcpd

