#!/bin/bash

. ./deployment/down.sh

echo
echo "UP"
echo "=="

. ./utils/export-uids.sh

ENV_FILE="./deployment/${DEPLOYMENT}/.env"
DEFAULT_ENV_FILE="./deployment/default/.env"
. ./utils/load-env.sh

SECRETS_ENC_FILE="./deployment/${DEPLOYMENT}/secrets.enc.env"
. ./utils/load-secrets-enc-env.sh

VERSIONS_ENV_FILE="./deployment/${DEPLOYMENT}/versions.env"
. ./utils/load-versions-env.sh

[ ! -d "${DATA_DIR_PREFIX}${DEPLOYMENT}" ] && mkdir -p "${DATA_DIR_PREFIX}${DEPLOYMENT}"
export ABS_PROJECT_DIR=$(realpath ${DATA_DIR_PREFIX}${DEPLOYMENT})

ls -la $ABS_PROJECT_DIR

# replace dots with dashes for docker compose project name
DEPLOYMENT_NAME=${DEPLOYMENT//./-}

docker compose --project-name "${DEPLOYMENT_NAME}" -f ./deployment/${DEPLOYMENT}/docker-compose.yml pull && wait $!

# Pre-pull the studio image that will be used by the spawner
echo "Pre-pulling studio image for spawner..."
docker pull ghcr.io/autonomous-testing/studio:latest

# Force rebuild spawner if requested
if [ "${FORCE_REBUILD_SPAWNER}" = "true" ]; then
  echo "Force rebuilding spawner image (--no-cache)..."
  docker compose --project-name "${DEPLOYMENT_NAME}" -f ./deployment/${DEPLOYMENT}/docker-compose.yml build --no-cache spawner
fi

docker compose --project-name "${DEPLOYMENT_NAME}" -f ./deployment/${DEPLOYMENT}/docker-compose.yml up -d

ls -la $ABS_PROJECT_DIR

