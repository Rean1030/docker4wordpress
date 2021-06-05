#!/usr/bin/env bash
set -o errexit

# shellcheck source=.env
source .env

if [ ! -f certs/nginx.key ] || [ ! -f certs/nginx.crt ]; then
  if [ ! -f mkcert ]; then
    curl -L https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 -o mkcert
  fi
  chmod +x mkcert
  ./mkcert -install
  ./mkcert -key-file nginx.key -cert-file nginx.crt ${SERVER_NAME}
  mv nginx.key nginx.crt certs/;
fi

WORKER_PROCESSES=$(grep processor /proc/cpuinfo | wc -l)
SYS_FMLMT=$(cat /proc/sys/fs/file-max)
USR_FMLMT=$(ulimit -n)
# Get the min num of system and user file open limit
[ $SYS_FMLMT -lt $USR_FMLMT ] && WORKER_CONNECTIONS=$SYS_FMLMT || WORKER_CONNECTIONS=$USR_FMLMT

ENV_CONFIG=".env"
[ ! -z "${WORKER_PROCESSES}" ] && sed -i "s/!WORKER_PROCESSES!/${WORKER_PROCESSES}/" $ENV_CONFIG
[ ! -z "${WORKER_CONNECTIONS}" ] && sed -i "s/!WORKER_CONNECTIONS!/${WORKER_CONNECTIONS}/" $ENV_CONFIG

docker-compose up -d