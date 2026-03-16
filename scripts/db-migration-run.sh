#!/usr/bin/env bash
# Run Flyway/Liquibase migrations against a target database
# Expects JDBC env vars to be set (or sourced from aws-ssm-env.sh)
set -euo pipefail

TOOL="${1:-flyway}"   # flyway | liquibase
DB_URL="${DB_URL:?Set DB_URL (jdbc:postgresql://host:5432/dbname)}"
DB_USER="${DB_USER:?Set DB_USER}"
DB_PASSWORD="${DB_PASSWORD:?Set DB_PASSWORD}"
MIGRATIONS_DIR="${MIGRATIONS_DIR:-./src/main/resources/db/migration}"

case "$TOOL" in
  flyway)
    echo "==> Running Flyway migrations against $DB_URL..."
    flyway \
      -url="$DB_URL" \
      -user="$DB_USER" \
      -password="$DB_PASSWORD" \
      -locations="filesystem:$MIGRATIONS_DIR" \
      migrate
    ;;
  liquibase)
    echo "==> Running Liquibase migrations against $DB_URL..."
    liquibase \
      --url="$DB_URL" \
      --username="$DB_USER" \
      --password="$DB_PASSWORD" \
      --changeLogFile="$MIGRATIONS_DIR/changelog.xml" \
      update
    ;;
  *)
    echo "Unknown tool: $TOOL. Use 'flyway' or 'liquibase'." >&2
    exit 1
    ;;
esac

echo "Migrations complete."
