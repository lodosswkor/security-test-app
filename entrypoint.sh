#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Wait for database
until pg_isready -h db -p 5432 -U postgres 2>/dev/null; do
  echo "Waiting for database..."
  sleep 2
done

# Run migrations and seeds
rails db:create 2>/dev/null || true
rails db:migrate
rails db:seed 2>/dev/null || true

exec "$@"
