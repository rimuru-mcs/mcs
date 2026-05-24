#!/usr/bin/env bash
set -euo pipefail

DB="peq"
USER_NAME="root"
HOST_NAME="127.0.0.1"
PORT="3306"
AUDIT_DIR="database/recovery/audits"
OUTPUT_DIR="database/recovery/audit_output"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --database) DB="$2"; shift 2 ;;
    --user) USER_NAME="$2"; shift 2 ;;
    --host) HOST_NAME="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    --audit-dir) AUDIT_DIR="$2"; shift 2 ;;
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
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

mkdir -p "$OUTPUT_DIR"

ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" --table "$DB")
if [[ -n "${MSR_DB_PASSWORD:-}" ]]; then
  ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" -p"$MSR_DB_PASSWORD" --table "$DB")
else
  echo "MSR_DB_PASSWORD is not set. The DB client may prompt for a password for each audit file." >&2
  ARGS=(-h "$HOST_NAME" -P "$PORT" -u "$USER_NAME" -p --table "$DB")
fi

shopt -s nullglob
files=("$AUDIT_DIR"/*.sql)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No audit SQL files found in $AUDIT_DIR" >&2
  exit 1
fi

for file in "${files[@]}"; do
  base="$(basename "$file" .sql)"
  out="$OUTPUT_DIR/$base.txt"
  echo "Running audit $(basename "$file") -> $out"
  "$CLIENT" "${ARGS[@]}" < "$file" 2>&1 | tee "$out"
done

echo "Database audits completed. Output written to $OUTPUT_DIR"
