#!/bin/bash

set -e

mkdir -p web/roms

cp -f tests/chip8-test-suite/bin/*.ch8 web/roms/ 2>/dev/null || true

docker build -t shrimp-wasm-builder .
docker run --rm -v $(pwd):/app shrimp-wasm-builder

echo
echo "Starting local server at http://localhost:8000"
echo "Press Ctrl+C to stop"
cd web && python3 -m http.server 8000
