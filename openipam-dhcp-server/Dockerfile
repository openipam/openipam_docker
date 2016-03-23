FROM debian:jessie

MAINTAINER Eldon Koyle <ekoyle@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

#RUN /bin/echo -e "\n# backports for pdns-server\ndeb http://http.debian.net/debian jessie-backports main\n" >> /etc/apt/sources.list

RUN apt-get -y update && \
    apt-get install -q -y python-sqlalchemy python-ldap python-psycopg2 python-ipy git

COPY ./start_dhcp.sh /usr/local/bin/start_dhcp.sh

RUN chmod u+x /usr/local/bin/start_dhcp.sh

RUN adduser --disabled-password --gecos="openipam_user" openipam

RUN install -d -m 2775 -o openipam -g openipam /usr/local/openipam

USER openipam

RUN git clone https://github.com/openipam/openipam.git /usr/local/openipam

COPY ./openipam_config /usr/local/openipam/openIPAM/openipam_config

USER root

EXPOSE 67/udp

#ENTRYPOINT ["/usr/local/bin/start_postgres.py"]
CMD "/usr/local/bin/start_dhcp.sh"

