#!/bin/bash
./build_wasm.sh
python3 -m http.server -d docs
