#!/bin/bash

set -e

PROJECT_NAME="five-microservices"
SERVICES_DIR="services"

echo "▶ Eski image'lar siliniyor..."

docker images --format "{{.Repository}} {{.ID}}" \
| grep "^${PROJECT_NAME}-" \
| awk '{print $2}' \
| xargs -r docker rmi -f

echo "▶ Dockerfile'lardan yeni image'lar build ediliyor..."

for service in ${SERVICES_DIR}/*; do
  if [ -f "$service/Dockerfile" ]; then
    SERVICE_NAME=$(basename "$service")
    IMAGE_NAME="${PROJECT_NAME}-${SERVICE_NAME}:latest"

    echo "▶ Build ediliyor: $IMAGE_NAME"
    docker build -t "$IMAGE_NAME" "$service"
  fi
done

echo "✅ 4 Docker image başarıyla oluşturuldu."
