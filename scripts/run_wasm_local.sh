#!/bin/bash
scripts/build_wasm.sh

python3 -m http.server -d docs & SERVER_PID=$!

open "http://localhost:8000" || xdg-open "http://localhost:8000" || false

echo "Server running on http://localhost:8000 (PID: $SERVER_PID)"
echo "Press Ctrl+C to stop"
trap "kill $SERVER_PID; exit" INT
wait $SERVER_PID
