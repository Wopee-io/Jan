#!/bin/bash

echo
echo "DOWN"
echo "===="

. ./utils/export-uids.sh

ENV_FILE="./deployment/${DEPLOYMENT}/.env"
DEFAULT_ENV_FILE="./deployment/default/.env"
. ./utils/load-env.sh

SECRETS_ENC_FILE="./deployment/${DEPLOYMENT}/secrets.enc.env"
. ./utils/load-secrets-enc-env.sh

VERSIONS_ENV_FILE="./deployment/${DEPLOYMENT}/versions.env"
. ./utils/load-versions-env.sh

export ABS_DATA_DIR_PREFIX=$(realpath ${DATA_DIR_PREFIX}${DEPLOYMENT})

ls -la $ABS_DATA_DIR_PREFIX

DEPLOYMENT_NAME=${DEPLOYMENT//./-}
docker compose --project-name "${DEPLOYMENT_NAME}" -f ./deployment/${DEPLOYMENT}/docker-compose.yml down && wait $!

if [ -n "$REMOVE_ALL_DATA" ]; then
    [ -d "$ABS_DATA_DIR_PREFIX/${DEPLOYMENT}" ] && sudo rm -rf $ABS_DATA_DIR_PREFIX/${DEPLOYMENT}
fi

ls -la $ABS_DATA_DIR_PREFIX
