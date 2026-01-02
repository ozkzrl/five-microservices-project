#!/bin/bash

set -e

CONTAINERS=(
  gateway
  order
  product
  user
)

echo "🧹 Stopping and removing containers..."

for c in "${CONTAINERS[@]}"; do
  docker stop $c 2>/dev/null || true
  docker rm $c 2>/dev/null || true
done

echo "✅ Containers removed."
docker ps
