#!/bin/bash
set -e

NETWORK="five-microservices-net"

if ! docker network ls | grep -q $NETWORK; then
  docker network create $NETWORK
fi

run () {
  NAME=$1
  IMAGE=$2
  HOST_PORT=$3
  CONTAINER_PORT=$4

  docker stop $NAME 2>/dev/null || true
  docker rm   $NAME 2>/dev/null || true

  docker run -d \
    --name $NAME \
    --network $NETWORK \
    -p $HOST_PORT:$CONTAINER_PORT \
    $IMAGE
}

run gateway five-microservices-gateway-service 8000 8000
run order   five-microservices-order-service   5001 5000
run product five-microservices-product-service 5002 5000
run user    five-microservices-user-service    5003 5000

docker ps
