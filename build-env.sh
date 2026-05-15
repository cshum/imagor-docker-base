#!/bin/bash

set -euo pipefail

case "$(uname -m)" in
  x86_64)
    arch_flags="-msse4"
    ;;
  aarch64)
    arch_flags="-march=armv8.2-a+fp16"
    ;;
  *)
    echo "unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

cat <<EOF
export PATH="/opt/imagor/bin:/root/.cargo/bin:/root/.python/bin:\$PATH"
export PKG_CONFIG_LIBDIR=/opt/imagor/lib/pkgconfig
export PKG_CONFIG_PATH=/opt/imagor/lib/pkgconfig
export CGO_CFLAGS="-I/opt/imagor/include"
export CGO_LDFLAGS="-L/opt/imagor/lib -Wl,-rpath,/opt/imagor/lib"
export CFLAGS="$arch_flags -Os -fPIC -ffunction-sections -fdata-sections"
export CXXFLAGS="\$CFLAGS"
export CPPFLAGS="\$CPPFLAGS -I/opt/imagor/include"
export LDFLAGS="\$LDFLAGS -L/opt/imagor/lib -Wl,--gc-sections -Wl,-rpath,/opt/imagor/lib"
EOF
