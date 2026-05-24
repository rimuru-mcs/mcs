#!/usr/bin/env bash
set -euo pipefail

DB="peq"
USER_NAME="root"
HOST_NAME="127.0.0.1"
PORT="3306"
MIGRATION_DIR="database/recovery/migrations_safe"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --database) DB="$2"; shift 2 ;;
    --user) USER_NAME="$2"; shift 2 ;;
    --host) HOST_NAME="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    --migration-dir) MIGRATION_DIR="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if command -v mariadb >/dev/null 2>&1; then
  CLIENT="mariadb"
elif command -v mysql >/dev/null 2>&1; then
  CLIENT="mysql"
else
  echo "Could not find mariadb/mysql client on PATH." >&2
  exit 1
fi

ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" "$DB")
if [[ -n "${MSR_DB_PASSWORD:-}" ]]; then
  ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" -p"$MSR_DB_PASSWORD" "$DB")
else
  echo "MSR_DB_PASSWORD is not set. The DB client may prompt for a password for each migration file." >&2
  ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" -p "$DB")
fi

shopt -s nullglob
files=("$MIGRATION_DIR"/*.sql)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No safe migration SQL files found in $MIGRATION_DIR" >&2
  exit 1
fi

echo "About to apply SAFE migrations from $MIGRATION_DIR to database '$DB' on $HOST_NAME:$PORT."
echo "Pending migrations are NOT applied by this script."

for file in "${files[@]}"; do
  echo "Applying migration $(basename "$file")"
  "$CLIENT" "${ARGS[@]}" < "$file"
done

echo "Safe migrations applied."
