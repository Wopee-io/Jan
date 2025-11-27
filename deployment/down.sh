#!/bin/bash

echo
echo "DOWN"
echo "===="

. ./utils/export-uids.sh


ENV_FILE="./deployment/${DEPLOYMENT}/.env"
DEFAULT_ENV_FILE="./deployment/default/.env"
. ./utils/load-env.sh

SECRETS_ENC_FILE="./deployment/${DEPLOYMENT}/secrets.enc.env"
DEFAULT_SECRETS_ENC_FILE="./deployment/default/secrets.enc.env"
. ./utils/load-secrets-enc-env.sh

VERSIONS_ENV_FILE="./deployment/${DEPLOYMENT}/versions.env"
DEFAULT_VERSIONS_ENV_FILE="./deployment/default/versions.env"
. ./utils/load-versions-env.sh

: "${DATA_DIR_PREFIX:=/srv/}"

DEPLOYMENT_PREFIX="${DEPLOYMENT_PREFIX-}"
if [ -n "${DEPLOYMENT_PREFIX}" ]; then
  export STACK_PREFIX="${DEPLOYMENT_PREFIX}-"
  DEPLOYMENT_NAME="${DEPLOYMENT_PREFIX}-${DEPLOYMENT//./-}"
else
  export STACK_PREFIX=""
  DEPLOYMENT_NAME="${DEPLOYMENT//./-}"
fi

: "${DOMAIN:=battle.wopee.io}"
export APP_HOST="jan.wopee.io"


export ABS_PROJECT_DIR="${DATA_DIR_PREFIX%/}/${DEPLOYMENT_NAME}"

ls -la "${ABS_PROJECT_DIR}" || true

docker compose --project-name "${DEPLOYMENT_NAME}" -f ./docker-compose.yml down && wait $!

if [ -n "$REMOVE_ALL_DATA" ]; then
    [ -d "${ABS_PROJECT_DIR}/postgresql" ] && sudo rm -rf "${ABS_PROJECT_DIR}/postgresql"
fi

ls -la "${ABS_PROJECT_DIR}" || true
