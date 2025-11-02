#!/bin/bash
set -e

CRYSTAL_VERSION=$(grep crystal .tool-versions | cut -d' ' -f2)

mkdir -p docs
docker build --platform=linux/amd64 --build-arg CRYSTAL_VERSION=$CRYSTAL_VERSION -t shrimp-wasm-builder .
docker run --platform=linux/amd64 -v $(pwd):/app shrimp-wasm-builder

echo "Build complete! Files are ready in docs/"
