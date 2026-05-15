#!/bin/bash

set -euo pipefail

PATH="/root/.cargo/bin:$PATH"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --profile minimal --default-toolchain stable

cargo install cargo-c
