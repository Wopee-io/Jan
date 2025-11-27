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
DEFAULT_SECRETS_ENC_FILE="./deployment/default/secrets.enc.env"
. ./utils/load-secrets-enc-env.sh

VERSIONS_ENV_FILE="./deployment/${DEPLOYMENT}/versions.env"
DEFAULT_VERSIONS_ENV_FILE="./deployment/default/versions.env"
. ./utils/load-versions-env.sh


DEPLOYMENT_PREFIX="${DEPLOYMENT_PREFIX-}"

# Use empty prefix by default; prefix is appended when provided (e.g., staging-).
if [ -n "${DEPLOYMENT_PREFIX}" ]; then
  export STACK_PREFIX="${DEPLOYMENT_PREFIX}-"
  DEPLOYMENT_NAME="${DEPLOYMENT_PREFIX}-${DEPLOYMENT//./-}"
else
  export STACK_PREFIX=""
  DEPLOYMENT_NAME="${DEPLOYMENT//./-}"
fi

# Ensure a sane data root even if env loading failed in CI shells.
: "${DATA_DIR_PREFIX:=/srv/}"
DATA_ROOT="${DATA_DIR_PREFIX%/}/${DEPLOYMENT_NAME}"
export ABS_PROJECT_DIR="$(mkdir -p "${DATA_ROOT}" && realpath "${DATA_ROOT}")"
mkdir -p "${ABS_PROJECT_DIR}/postgresql"

: "${DOMAIN:=battle.wopee.io}"
export APP_HOST="${STACK_PREFIX}app.${DOMAIN}"

for required in POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB SECRET_KEY DOMAIN; do
  if [ -z "${!required:-}" ]; then
    echo "Missing required environment variable: ${required}" >&2
    exit 1
  fi
done

ls -la "$ABS_PROJECT_DIR"

docker compose --project-name "${DEPLOYMENT_NAME}" -f ./docker-compose.yml pull && wait $!

# Force rebuild if requested
if [ "${FORCE_REBUILD}" = "true" ]; then
  echo "Force rebuilding images (--no-cache)..."
  docker compose --project-name "${DEPLOYMENT_NAME}" -f ./docker-compose.yml build --no-cache
fi

docker compose --project-name "${DEPLOYMENT_NAME}" -f ./docker-compose.yml up -d

ls -la "$ABS_PROJECT_DIR"
