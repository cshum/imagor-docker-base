#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
source "$script_dir/versions.sh"

deps_dir=/root/deps
prefix=/opt/imagor

mkdir -p "$deps_dir"
cd "$deps_dir"

curl -fsSLO "https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz"
tar xf "ffmpeg-${FFMPEG_VERSION}.tar.xz"
cd "ffmpeg-${FFMPEG_VERSION}"

./configure \
  --prefix="$prefix" \
  --disable-debug \
  --disable-doc \
  --disable-ffplay \
  --disable-static \
  --enable-shared \
  --enable-version3 \
  --enable-gpl \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-librtmp \
  --enable-libwebp \
  --enable-libvpx \
  --enable-libx265 \
  --enable-libx264 \
  --enable-libdav1d \
  --enable-libaom

make -j"$(nproc)"
make install

find "$prefix"/lib -name '*.a' -delete
find "$prefix"/lib -name '*.la' -delete
rm -rf "$deps_dir"