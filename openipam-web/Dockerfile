FROM debian:buster

MAINTAINER Eldon Koyle <ekoyle@gmail.com>

ARG git_branch=master

ENV DEBIAN_FRONTEND noninteractive

RUN    apt-get -y update \
    && apt-get install -q -y \
        uwsgi \
        uwsgi-plugin-python3 \
        python3-ldap \
        python3-psycopg2 \
        git \
        python3-setuptools \
        python3-pip \
        python3-mysqldb \
        build-essential \
        python3-dev \
        python3-coverage \
        zlib1g-dev \
        python3-appdirs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos="openipam_user" openipam

RUN install -d -m 2775 -o openipam -g openipam /usr/local/django-openipam

RUN echo "$git_branch" | tee /git_branch

USER openipam

RUN git clone --branch $git_branch --depth=1 https://github.com/openipam/django-openipam.git /usr/local/django-openipam

USER root

# We want the Debian psycopg and python-ldap, for simplicity
RUN cat /usr/local/django-openipam/env/requirements.txt | sed '/^## EXCLUDE FROM DOCKER ##$/,$d' > /requirements_docker.txt \
    && pip3 install -r /requirements_docker.txt

COPY uwsgi.ini /etc/uwsgi/uwsgi.ini
RUN chmod a+r /etc/uwsgi/uwsgi.ini

RUN install -d -m 2775 -o openipam -g openipam /var/run/uwsgi

COPY start_uwsgi.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/start_uwsgi.sh

USER openipam

# FIXME: why is this directory referenced in STATICFILES_DIRS (openipam/conf/settings.py) if it doesn't exist?
RUN [ -d /usr/local/django-openipam/components/static_components ] || mkdir -p /usr/local/django-openipam/components/static_components

RUN cd /usr/local/django-openipam && python3 ./manage.py collectstatic --no-input

USER root

# run as root and let uwsgi drop privs
CMD /usr/local/bin/start_uwsgi.sh

