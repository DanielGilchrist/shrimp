#!/bin/bash
set -e

mkdir -p docs
docker build --platform=linux/amd64 -t shrimp-wasm-builder .
docker run --platform=linux/amd64 -v $(pwd):/app shrimp-wasm-builder

echo "Build complete! Files are ready in docs/"
