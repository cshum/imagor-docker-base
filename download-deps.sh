#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
source "$script_dir/versions.sh"

deps_dir=/root/deps
mkdir -p "$deps_dir"

snake_version() {
  echo "$1" | sed 's/\./_/g'
}

minor_version() {
  echo "$1" | sed -E 's/^([0-9]+\.[0-9]+).*/\1/'
}

fetch_tar() {
  local name="$1"
  local url="$2"
  local strip_flag="$3"
  local archive

  mkdir -p "$deps_dir/$name"
  archive="$(mktemp "/tmp/${name}.XXXXXX")"

  rm -rf "$deps_dir/$name"
  mkdir -p "$deps_dir/$name"

  curl \
    -LfsS \
    --retry 5 \
    --retry-all-errors \
    --retry-delay 2 \
    -o "$archive" \
    "$url"

  tar "$strip_flag" -f "$archive" -C "$deps_dir/$name" --strip-components=1
  rm -f "$archive"
}

fetch_git() {
  local name="$1"
  local repo="$2"
  local ref="$3"

  git clone "$repo" "$deps_dir/$name" --branch "$ref" --depth 1 -c advice.detachedHead=false
}

fetch_tar zlib "https://github.com/zlib-ng/zlib-ng/archive/${ZLIB_VERSION}.tar.gz" -xz
fetch_tar brotli "https://github.com/google/brotli/archive/refs/tags/v${BROTLI_VERSION}.tar.gz" -xz
fetch_tar ffi "https://github.com/libffi/libffi/releases/download/v${FFI_VERSION}/libffi-${FFI_VERSION}.tar.gz" -xz
fetch_tar pcre2 "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.tar.gz" -xz
fetch_tar meson "https://github.com/mesonbuild/meson/releases/download/${MESON_VERSION}/meson-${MESON_VERSION}.tar.gz" -xz
fetch_tar glib "https://download.gnome.org/sources/glib/$(minor_version "$GLIB_VERSION")/glib-${GLIB_VERSION}.tar.xz" -xJ
fetch_tar highway "https://github.com/google/highway/archive/refs/tags/${HIGHWAY_VERSION}.tar.gz" -xz
fetch_tar expat "https://github.com/libexpat/libexpat/releases/download/R_$(snake_version "$LIBEXPAT_VERSION")/expat-${LIBEXPAT_VERSION}.tar.gz" -xz
fetch_tar libxml2 "https://download.gnome.org/sources/libxml2/$(minor_version "$LIBXML2_VERSION")/libxml2-${LIBXML2_VERSION}.tar.xz" -xJ
fetch_tar libexif "https://github.com/libexif/libexif/archive/libexif-$(snake_version "$LIBEXIF_VERSION")-release.tar.gz" -xz
fetch_tar lcms2 "https://github.com/mm2/Little-CMS/releases/download/lcms${LCMS2_VERSION}/lcms2-${LCMS2_VERSION}.tar.gz" -xz
fetch_tar libjpeg-turbo "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${LIBJPEGTURBO_VERSION}.tar.gz" -xz
fetch_tar mozjpeg "https://github.com/mozilla/mozjpeg/archive/refs/tags/v${MOZJPEG_VERSION}.tar.gz" -xz
fetch_tar libjxl "https://github.com/libjxl/libjxl/archive/refs/tags/v${LIBJXL_VERSION}.tar.gz" -xz
fetch_tar libpng "https://download.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.gz" -xz
fetch_tar libwebp "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${LIBWEBP_VERSION}.tar.gz" -xz
fetch_tar libtiff "https://gitlab.com/libtiff/libtiff/-/archive/v${LIBTIFF_VERSION}/libtiff-v${LIBTIFF_VERSION}.tar.gz" -xz
fetch_tar cgif "https://github.com/dloebl/cgif/archive/refs/tags/v${CGIF_VERSION}.tar.gz" -xz
fetch_tar libde265 "https://github.com/strukturag/libde265/releases/download/v${LIBDE265_VERSION}/libde265-${LIBDE265_VERSION}.tar.gz" -xz
fetch_git x265 https://github.com/videolan/x265.git "${X265_VERSION}"
fetch_tar kvazaar "https://github.com/ultravideo/kvazaar/archive/refs/tags/v${KVAZAAR_VERSION}.tar.gz" -xz
fetch_tar dav1d "https://code.videolan.org/videolan/dav1d/-/archive/${DAV1D_VERSION}/dav1d-${DAV1D_VERSION}.tar.gz" -xz
fetch_tar aom "https://storage.googleapis.com/aom-releases/libaom-${AOM_VERSION}.tar.gz" -xz
fetch_tar libheif "https://github.com/strukturag/libheif/releases/download/v${LIBHEIF_VERSION}/libheif-${LIBHEIF_VERSION}.tar.gz" -xz
fetch_tar freetype "https://gitlab.freedesktop.org/freetype/freetype/-/archive/VER-${FREETYPE_VERSION//./-}/freetype-VER-${FREETYPE_VERSION//./-}.tar.bz2" -xj
fetch_tar fontconfig "https://gitlab.freedesktop.org/fontconfig/fontconfig/-/archive/${FONTCONFIG_VERSION}/fontconfig-${FONTCONFIG_VERSION}.tar.gz" -xz
fetch_tar harfbuzz "https://github.com/harfbuzz/harfbuzz/archive/${HARFBUZZ_VERSION}.tar.gz" -xz
fetch_tar pixman "https://cairographics.org/releases/pixman-${PIXMAN_VERSION}.tar.gz" -xz
fetch_tar cairo "https://gitlab.freedesktop.org/cairo/cairo/-/archive/${CAIRO_VERSION}/cairo-${CAIRO_VERSION}.tar.gz" -xz
fetch_tar fribidi "https://github.com/fribidi/fribidi/releases/download/v${FRIBIDI_VERSION}/fribidi-${FRIBIDI_VERSION}.tar.xz" -xJ
fetch_tar pango "https://download.gnome.org/sources/pango/$(minor_version "$PANGO_VERSION")/pango-${PANGO_VERSION}.tar.xz" -xJ
fetch_tar librsvg "https://download.gnome.org/sources/librsvg/$(minor_version "$LIBRSVG_VERSION")/librsvg-${LIBRSVG_VERSION}.tar.xz" -xJ
fetch_tar libraw "https://www.libraw.org/data/LibRaw-${LIBRAW_VERSION}.tar.gz" -xz
fetch_tar vips "https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.xz" -xJ

if [ ! -f "$deps_dir/pcre2/configure" ]; then
  rm -rf "$deps_dir/pcre2"
  fetch_git pcre2 https://github.com/PCRE2Project/pcre2.git "pcre2-${PCRE2_VERSION}"
fi
