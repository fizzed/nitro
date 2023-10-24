#!/bin/sh -l
# Use a shell as though we logged in

BASEDIR=$(dirname "$0")
cd "$BASEDIR/.." || exit 1
PROJECT_DIR=$PWD

DOCKER_IMAGE="$1"
CONTAINER_NAME="$2"
BUILDOS="$3"
BUILDARCH="$4"

USERID=$(id -u ${USER})
USERNAME=${USER}

echo "Building docker container..."
echo " dockerImage: $DOCKER_IMAGE"
echo " containerName: $CONTAINER_NAME"

DOCKERFILE="setup/Dockerfile.linux-generic"

docker build -f "$DOCKERFILE" \
  --build-arg "FROM_IMAGE=${DOCKER_IMAGE}" \
  --build-arg USERID=${USERID} \
  --build-arg USERNAME=${USERNAME} \
  -t ${CONTAINER_NAME} \
  "$PROJECT_DIR/setup" || exit 1
