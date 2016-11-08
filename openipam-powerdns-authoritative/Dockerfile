FROM debian:jessie

MAINTAINER Eldon Koyle <ekoyle@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN /bin/echo -e "\n# backports for pdns-server\ndeb http://http.debian.net/debian jessie-backports main\n" >> /etc/apt/sources.list

RUN apt-get -y update && \
    apt-get install -t jessie-backports -q -y pdns-server pdns-backend-pgsql

ADD ./start_pdns.sh /usr/local/bin/start_pdns.sh
RUN chmod u+x       /usr/local/bin/start_pdns.sh

EXPOSE 53

ENTRYPOINT [ "/usr/local/bin/start_pdns.sh" ]




