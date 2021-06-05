#!/bin/bash

# shellcheck source=.env
source .env

_os="`uname`"
_now=$(date +"%m_%d_%Y")
_file="data/"$MYSQL_DATABASE"_$_now.sql"

if [ ! -d "./data" ]; then
  mkdir ./data
fi

# Export dump
EXPORT_COMMAND='exec mysqldump "$MYSQL_DATABASE" -uroot -p"$MYSQL_ROOT_PASSWORD"'
docker-compose exec mysql sh -c "$EXPORT_COMMAND" > $_file

if [[ $_os == "Darwin"* ]] ; then
  sed -i '.bak' 1,1d $_file
else
  sed -i 1,1d $_file # Removes the password warning from the file
fi