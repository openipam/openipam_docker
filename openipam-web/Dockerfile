FROM debian:jessie

MAINTAINER Eldon Koyle <ekoyle@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN /bin/echo -e "\n# backports\ndeb http://http.debian.net/debian jessie-backports main\n" >> /etc/apt/sources.list.d/backports.list \
    && apt-get -y update \
    && apt-get install -q -y \
        uwsgi \
        uwsgi-plugin-python \
        python-ldap \
        python-psycopg2 \
        python-ipy \
        git \
        python-setuptools \
        python-pip \
        python-mysqldb \
        build-essential \
        python-dev \
        python-coverage \
        libreadline-dev \
        zlib1g-dev \
        python-pil \
        python-pycryptopp \
        python-appdirs \
    && apt-get install -q -y -t jessie-backports \
        python-cryptography \
        python-cffi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos="openipam_user" openipam

RUN install -d -m 2775 -o openipam -g openipam /usr/local/django-openipam

USER openipam

RUN git clone --depth=1 https://github.com/openipam/django-openipam.git /usr/local/django-openipam

USER root

# We want the Debian psycopg and python-ldap, for simplicity
RUN grep -v "^python-ldap=\|^psycopg2=\|^MySQL-python=\|^cffi=\|^cryptography=\|^\(gnu\)\?readline=\|^coverage=\|^Pillow=\|pip-review=\|^pycparser=\|pycrypto" /usr/local/django-openipam/env/requirements.txt > /requirements_docker.txt \
    && pip install -r /requirements_docker.txt

COPY uwsgi.ini /etc/uwsgi/uwsgi.ini
RUN chmod a+r /etc/uwsgi/uwsgi.ini

RUN install -d -m 2775 -o openipam -g openipam /var/run/uwsgi

COPY start_uwsgi.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/start_uwsgi.sh

USER openipam

CMD exec /usr/local/bin/start_uwsgi.sh

