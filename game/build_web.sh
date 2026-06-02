#!/bin/bash
# Web build script for MG-0023 game
# Uses --no-wasm-dry-run to suppress warnings from wasm_ffi dependency
# The wasm_ffi package is used by flame_spine and has JS interop warnings
# that don't affect the actual JS compilation for web.

flutter build web --release --no-wasm-dry-run "$@"
