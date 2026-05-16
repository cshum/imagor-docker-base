#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
source "$script_dir/versions.sh"

base_tag="vips${VIPS_VERSION}"

case "${1:-default}" in
  default)
    echo "$base_tag"
    ;;
  magick)
    echo "${base_tag}-magick"
    ;;
  mozjpeg)
    echo "${base_tag}-mozjpeg"
    ;;
  *)
    echo "unknown variant: ${1}" >&2
    exit 1
    ;;
esac