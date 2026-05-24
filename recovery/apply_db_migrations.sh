#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

HOST_NAME="${MSR_DB_HOST:-localhost}"
PORT="${MSR_DB_PORT:-3306}"
USER_NAME="${MSR_DB_USER:-${MSR_DB_USERNAME:-msr_migrate}}"
DB="${MSR_DB_NAME:-${MSR_DB_DATABASE:-msr_world_recovery}}"
MIGRATION_DIR="$ROOT_DIR/database/recovery/migrations_safe"
MYSQL_BIN="${MSR_DB_CLIENT:-}"
DRY_RUN=0

usage() {
  cat <<USAGE
Usage: recovery/apply_db_migrations.sh [options]

Applies ONLY SQL files from database/recovery/migrations_safe by default.
Pending/review migrations are never applied unless you explicitly pass another
--migration-dir. Use a disposable/dev database first.

Options:
  --database NAME       Database name. Default: MSR_DB_NAME or msr_world_recovery
  --user USER           DB user. Default: MSR_DB_USER or msr_migrate
  --host HOST           DB host. Default: MSR_DB_HOST or localhost
  --port PORT           DB port. Default: MSR_DB_PORT or 3306
  --migration-dir DIR   Migration directory. Default: database/recovery/migrations_safe
  --dry-run             Print migrations that would run, but do not apply them
  -h, --help            Show this help

Environment:
  MSR_DB_PASSWORD       DB password. If unset, the DB client will prompt.
  MSR_DB_CLIENT         mariadb/mysql client binary override.
  MSR_ALLOW_ROOT_MIGRATIONS=1 allows using root. Otherwise root is refused.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --database) DB="$2"; shift 2 ;;
    --user) USER_NAME="$2"; shift 2 ;;
    --host) HOST_NAME="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    --migration-dir) MIGRATION_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$MYSQL_BIN" ]]; then
  if command -v mariadb >/dev/null 2>&1; then
    MYSQL_BIN="mariadb"
  elif command -v mysql >/dev/null 2>&1; then
    MYSQL_BIN="mysql"
  else
    echo "Could not find mariadb/mysql client on PATH." >&2
    exit 1
  fi
fi

if [[ "$USER_NAME" == "root" && "${MSR_ALLOW_ROOT_MIGRATIONS:-0}" != "1" ]]; then
  echo "Refusing to run migrations as root." >&2
  echo "Use the msr_migrate user, or set MSR_ALLOW_ROOT_MIGRATIONS=1 only on a disposable dev DB." >&2
  exit 3
fi

if [[ ! -d "$MIGRATION_DIR" ]]; then
  echo "Migration directory not found: $MIGRATION_DIR" >&2
  exit 1
fi

shopt -s nullglob
files=("$MIGRATION_DIR"/*.sql)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No SQL migration files found in: $MIGRATION_DIR" >&2
  exit 1
fi

ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" "$DB")
if [[ -n "${MSR_DB_PASSWORD:-}" ]]; then
  ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" -p"$MSR_DB_PASSWORD" "$DB")
else
  echo "MSR_DB_PASSWORD is not set. The DB client may prompt for each migration." >&2
fi

cat <<SUMMARY
MSR safe migration apply
  Host:          $HOST_NAME
  Port:          $PORT
  User:          $USER_NAME
  Database:      $DB
  Client:        $MYSQL_BIN
  Migration dir: ${MIGRATION_DIR#$ROOT_DIR/}
  File count:    ${#files[@]}
  Dry run:       $DRY_RUN
SUMMARY

echo
if [[ "$DRY_RUN" == "1" ]]; then
  echo "Dry run only. Migrations that would be applied:"
  for file in "${files[@]}"; do
    echo "  - $(basename "$file")"
  done
  exit 0
fi

echo "Applying SAFE migrations only. Pending/review migrations are not applied by this script."
for file in "${files[@]}"; do
  echo "Applying migration $(basename "$file")"
  "$MYSQL_BIN" "${ARGS[@]}" < "$file"
done

echo
echo "Safe migrations applied. Run recovery/run_db_audit.sh next to verify."
