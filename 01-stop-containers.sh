#!/bin/bash
set -e

CONTAINERS=(
  gateway
  order
  product
  user
)

echo "🛑 Containers durduruluyor ve siliniyor..."

for c in "${CONTAINERS[@]}"; do
  docker stop "$c" 2>/dev/null || true
  docker rm   "$c" 2>/dev/null || true
done

echo "✅ Containers başarıyla kaldırıldı."

