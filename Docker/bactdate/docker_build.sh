#!/bin/bash

# to ensure multi-platform builds, turn on "enable containerd for pulling and storing images" in docker desktop settings

read -p "Enter version number " VERSION
docker login
echo Building Docker image $VERSION
docker build --platform linux/amd64,linux/arm64 -t samalate/bactdate:"$VERSION" .
echo Pushing to Docker Hub
docker push samalate/bactdate:"$VERSION"