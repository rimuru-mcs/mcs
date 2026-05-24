#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-status}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANUAL_DIR="$ROOT_DIR/database/recovery/manual_tests"

HOST_NAME="${MSR_DB_HOST:-localhost}"
PORT="${MSR_DB_PORT:-3306}"
USER_NAME="${MSR_DB_USER:-${MSR_DB_USERNAME:-msr_migrate}}"
DB="${MSR_DB_NAME:-${MSR_DB_DATABASE:-msr_world_recovery}}"
MYSQL_BIN="${MSR_DB_CLIENT:-mariadb}"

if [[ "$USER_NAME" == "root" && "${MSR_ALLOW_ROOT_MIGRATIONS:-0}" != "1" ]]; then
  echo "Refusing to run as MariaDB root. Set MSR_DB_USER to msr_migrate or set MSR_ALLOW_ROOT_MIGRATIONS=1 intentionally." >&2
  exit 1
fi

ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" --table "$DB")
if [[ -n "${MSR_DB_PASSWORD:-}" ]]; then
  ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" -p"$MSR_DB_PASSWORD" --table "$DB")
else
  echo "MSR_DB_PASSWORD is not set. The DB client may prompt for a password." >&2
fi

case "$ACTION" in
  on|enable|enabled|true)
    SQL_FILE="$MANUAL_DIR/enable_permanent_server_buffs_dev_only.sql"
    ;;
  off|disable|disabled|false)
    SQL_FILE="$MANUAL_DIR/disable_permanent_server_buffs_dev_only.sql"
    ;;
  status)
    SQL_FILE=""
    ;;
  *)
    echo "Usage: $0 [status|on|off]" >&2
    exit 2
    ;;
esac

if [[ -n "${SQL_FILE:-}" ]]; then
  if [[ ! -f "$SQL_FILE" ]]; then
    echo "SQL file not found: $SQL_FILE" >&2
    exit 1
  fi
  echo "Applying permanent server buff dev toggle: $ACTION"
  "$MYSQL_BIN" "${ARGS[@]}" < "$SQL_FILE"
else
  "$MYSQL_BIN" "${ARGS[@]}" -e "SELECT ruleset_id, rule_name, rule_value, notes FROM rule_values WHERE rule_name = 'Custom:PermanentServerBuffsEnabled' ORDER BY ruleset_id;"
fi
