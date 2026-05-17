#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
source "$script_dir/versions.sh"

base_tag="vips${VIPS_VERSION}-r${IMAGOR_BASE_REVISION}"

case "${1:-default}" in
  default)
    echo "$base_tag"
    ;;
  default-dev)
    echo "${base_tag}-dev"
    ;;
  magick)
    echo "${base_tag}-magick"
    ;;
  magick-dev)
    echo "${base_tag}-magick-dev"
    ;;
  mozjpeg)
    echo "${base_tag}-mozjpeg"
    ;;
  mozjpeg-dev)
    echo "${base_tag}-mozjpeg-dev"
    ;;
  ffmpeg)
    echo "${base_tag}-ffmpeg"
    ;;
  ffmpeg-dev)
    echo "${base_tag}-ffmpeg-dev"
    ;;
  magick-ffmpeg)
    echo "${base_tag}-magick-ffmpeg"
    ;;
  magick-ffmpeg-dev)
    echo "${base_tag}-magick-ffmpeg-dev"
    ;;
  *)
    echo "unknown variant: ${1}" >&2
    exit 1
    ;;
esac