#!/bin/bash

set -e

tag='latest'
if [ ! -z "$BRANCH" ] ; then
	tag="$BRANCH"
	add_args="--build-arg git_branch=$BRANCH"
fi

date=$(date +%Y%m%d-%H%M)

(cd openipam-web/django-openipam && git pull)

source $(dirname $0)/.env

docker build $add_args $@ -t openipam-web:${tag} -t openipam-web:${tag}-$date openipam-web/

docker tag openipam-web:${tag} ${DOCKER_REPO}/openipam-web:${tag}
docker tag openipam-web:${tag} ${DOCKER_REPO}/openipam-web:${tag}-$date

docker push ${DOCKER_REPO}/openipam-web:${tag}
docker push ${DOCKER_REPO}/openipam-web:${tag}-$date

