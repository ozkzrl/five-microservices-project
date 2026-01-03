#!/bin/bash
set -e

PROJECT_NAME="five-microservices"

echo "🧹 ${PROJECT_NAME}- ile başlayan Docker image'ları siliniyor..."

IMAGES=$(docker images --format "{{.Repository}} {{.ID}}" | grep "^${PROJECT_NAME}-" | awk '{print $2}')

if [ -z "$IMAGES" ]; then
  echo "ℹ️ Silinecek image bulunamadı."
  exit 0
fi

echo "$IMAGES" | xargs docker rmi -f

echo "✅ Image'lar başarıyla silindi."
