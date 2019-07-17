FROM debian:stretch

MAINTAINER Eldon Koyle <ekoyle@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update \
	&& apt-get install -y --no-install-recommends curl ca-certificates gnupg \
	&& curl https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add - \
	&& /bin/echo -e "\n# powerdns official packages\ndeb http://repo.powerdns.com/debian stretch-auth-41 main\n" >> /etc/apt/sources.list \
	&& apt-get -y update \
	&& apt-get install -q -y pdns-server pdns-backend-pgsql \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists

ADD ./start_pdns.sh /usr/local/bin/start_pdns.sh
RUN chmod u+x       /usr/local/bin/start_pdns.sh

EXPOSE 53

ENTRYPOINT [ "/usr/local/bin/start_pdns.sh" ]




