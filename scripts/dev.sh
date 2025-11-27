#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

mkdir -p logs

# Load environment
if [ -f .env ]; then
  set -a; source .env; set +a
fi

echo "Starting Battle dev environment..."

# 1. Database
echo "[1/3] Starting PostgreSQL..."
docker-compose up battle-db -d
sleep 2

# 2. Backend
echo "[2/3] Starting backend on :8000..."
cd backend
source .venv/bin/activate
nohup uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 > "$PROJECT_ROOT/logs/backend.log" 2>&1 &
echo $! > "$PROJECT_ROOT/logs/backend.pid"
cd "$PROJECT_ROOT"

# 3. Frontend
echo "[3/3] Starting frontend on :3000..."
cd frontend
nohup npm run dev > "$PROJECT_ROOT/logs/frontend.log" 2>&1 &
echo $! > "$PROJECT_ROOT/logs/frontend.pid"
cd "$PROJECT_ROOT"

sleep 2

echo ""
echo "Dev environment ready!"
echo "  Frontend: http://localhost:3000"
echo "  Backend:  http://localhost:8000"
echo "  API Docs: http://localhost:8000/docs"
echo ""
echo "Stop: ./scripts/dev-stop.sh"
