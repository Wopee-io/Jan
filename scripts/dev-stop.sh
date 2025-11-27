#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "Stopping dev environment..."

[ -f logs/backend.pid ] && kill $(cat logs/backend.pid) 2>/dev/null; rm -f logs/backend.pid
[ -f logs/frontend.pid ] && kill $(cat logs/frontend.pid) 2>/dev/null; rm -f logs/frontend.pid
docker-compose stop jan-db

echo "Done. Start again: ./scripts/dev.sh"
