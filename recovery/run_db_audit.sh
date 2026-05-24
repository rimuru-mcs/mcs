#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_DIR="$ROOT_DIR/database/recovery/audits"
OUTPUT_DIR="$ROOT_DIR/database/recovery/audit_output"

HOST_NAME="${MSR_DB_HOST:-${1:-localhost}}"
PORT="${MSR_DB_PORT:-${2:-3306}}"
USER_NAME="${MSR_DB_USER:-${MSR_DB_USERNAME:-${3:-root}}}"
DB="${MSR_DB_NAME:-${MSR_DB_DATABASE:-${4:-msr_world_recovery}}}"
MYSQL_BIN="${MSR_DB_CLIENT:-mariadb}"

mkdir -p "$OUTPUT_DIR"

if [[ ! -d "$AUDIT_DIR" ]]; then
  echo "Audit directory not found: $AUDIT_DIR" >&2
  exit 1
fi

shopt -s nullglob
AUDIT_FILES=("$AUDIT_DIR"/*.sql)

if [[ ${#AUDIT_FILES[@]} -eq 0 ]]; then
  echo "No audit SQL files found in: $AUDIT_DIR" >&2
  exit 1
fi

ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" --table "$DB")

if [[ -n "${MSR_DB_PASSWORD:-}" ]]; then
  ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" -p"$MSR_DB_PASSWORD" --table "$DB")
else
  echo "MSR_DB_PASSWORD is not set. The DB client may prompt for a password for each audit file." >&2
fi

echo "MSR database audit"
echo "  Host:     $HOST_NAME"
echo "  Port:     $PORT"
echo "  User:     $USER_NAME"
echo "  Database: $DB"
echo "  Audits:   ${#AUDIT_FILES[@]}"
echo

for audit_file in "${AUDIT_FILES[@]}"; do
  audit_name="$(basename "$audit_file")"
  output_file="$OUTPUT_DIR/${audit_name%.sql}.txt"

  echo "Running audit $audit_name -> ${output_file#$ROOT_DIR/}"
  "$MYSQL_BIN" "${ARGS[@]}" < "$audit_file" > "$output_file"
done

echo
echo "Audit complete."
echo "Output directory: ${OUTPUT_DIR#$ROOT_DIR/}"
