#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
source "$script_dir/versions.sh"

deps_dir=/root/deps
prefix=/opt/imagor

mkdir -p "$prefix"

configure_make_install() {
  local src="$1"
  shift
  cd "$deps_dir/$src"
  ./configure --prefix="$prefix" "$@"
  make -j"$(nproc)"
  make install-strip
}

meson_install() {
  local src="$1"
  shift
  cd "$deps_dir/$src"
  meson setup _build \
    --buildtype=release \
    --strip \
    --wrap-mode=nofallback \
    --prefix="$prefix" \
    --libdir=lib \
    "$@"
  ninja -C _build
  ninja -C _build install
}

cmake_install() {
  local src="$1"
  shift
  cd "$deps_dir/$src"
  mkdir -p _build
  cd _build
  cmake \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$prefix" \
    "$@" \
    ..
  ninja install/strip
}

cd "$deps_dir/zlib"
cmake_install zlib \
  -DBUILD_SHARED_LIBS=TRUE \
  -DZLIB_COMPAT=TRUE \
  -DWITH_GTEST=FALSE

cmake_install brotli \
  -DBUILD_SHARED_LIBS=TRUE \
  -DBROTLI_DISABLE_TESTS=TRUE

cd "$deps_dir/ffi"
./configure \
  --prefix="$prefix" \
  --enable-shared \
  --disable-static \
  --disable-dependency-tracking \
  --disable-multi-os-directory
make -j"$(nproc)"
make install-strip

cmake_install pcre2 \
  -DBUILD_SHARED_LIBS=TRUE \
  -DBUILD_STATIC_LIBS=OFF \
  -DPCRE2_SUPPORT_JIT=ON

meson_install glib \
  -Dlibmount=disabled \
  -Dtests=false \
  -Dintrospection=disabled \
  -Dnls=disabled \
  -Dsysprof=disabled \
  -Dlibelf=disabled \
  -Dinstalled_tests=false \
  -Dglib_debug=disabled

cmake_install highway \
  -DBUILD_SHARED_LIBS=TRUE \
  -DHWY_ENABLE_EXAMPLES=FALSE \
  -DHWY_ENABLE_TESTS=FALSE \
  -DHWY_ENABLE_CONTRIB=FALSE

configure_make_install expat \
  --enable-shared \
  --disable-static \
  --disable-dependency-tracking \
  --without-xmlwf

meson_install libxml2 -Dminimum=true

cd "$deps_dir/libexif"
autoreconf -i
configure_make_install libexif \
  --enable-shared \
  --disable-static \
  --disable-dependency-tracking

cd "$deps_dir/lcms2"
./configure \
  --prefix="$prefix" \
  --enable-shared \
  --disable-static \
  --disable-dependency-tracking
make -j"$(nproc)"
make install-strip

if [ "${ENABLE_MOZJPEG:-false}" = "true" ]; then
  cd "$deps_dir/mozjpeg"
  mkdir -p _build
  cd _build
  cmake \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$prefix" \
    -DENABLE_SHARED=TRUE \
    -DPNG_SUPPORTED=FALSE \
    -DWITH_JPEG8=TRUE \
    ..
  ninja install/strip
else
  cmake_install libjpeg-turbo \
    -DENABLE_SHARED=TRUE \
    -DENABLE_STATIC=FALSE \
    -DWITH_TURBOJPEG=FALSE \
    -DWITH_JPEG8=TRUE \
    -DPNG_SUPPORTED=FALSE
fi

cmake_install libjxl \
  -DJPEGXL_STATIC=FALSE \
  -DBUILD_TESTING=OFF \
  -DJPEGXL_ENABLE_FUZZERS=FALSE \
  -DJPEGXL_ENABLE_DEVTOOLS=FALSE \
  -DJPEGXL_ENABLE_TOOLS=FALSE \
  -DJPEGXL_ENABLE_JPEGLI=FALSE \
  -DJPEGXL_ENABLE_JPEGLI_LIBJPEG=FALSE \
  -DJPEGXL_ENABLE_DOXYGEN=FALSE \
  -DJPEGXL_ENABLE_MANPAGES=FALSE \
  -DJPEGXL_ENABLE_BENCHMARK=FALSE \
  -DJPEGXL_ENABLE_EXAMPLES=FALSE \
  -DJPEGXL_BUNDLE_LIBPNG=FALSE \
  -DJPEGXL_ENABLE_JNI=FALSE \
  -DJPEGXL_ENABLE_SKCMS=FALSE \
  -DJPEGXL_ENABLE_SJPEG=FALSE

configure_make_install libpng \
  --enable-shared \
  --disable-static \
  --disable-dependency-tracking

configure_make_install libwebp \
  --enable-shared \
  --disable-static \
  --disable-dependency-tracking \
  --enable-libwebpmux \
  --enable-libwebpdemux

cmake_install libtiff \
  -DBUILD_SHARED_LIBS=TRUE \
  -Dtiff-tools=FALSE \
  -Dtiff-tests=FALSE \
  -Dtiff-contrib=FALSE \
  -Dtiff-docs=FALSE \
  -Dtiff-deprecated=FALSE

meson_install cgif

cd "$deps_dir/libde265"
mkdir -p _build
cd _build
cmake \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$prefix" \
  --preset=release \
  -DBUILD_SHARED_LIBS=1 \
  ..
ninja install/strip

cd "$deps_dir/kvazaar"
./autogen.sh
./configure \
  --prefix="$prefix" \
  --enable-shared \
  --disable-static
make -j"$(nproc)"
make install-strip

meson_install dav1d

cmake_install aom \
  -DBUILD_SHARED_LIBS=1 \
  -DENABLE_DOCS=0 \
  -DENABLE_TESTS=0 \
  -DENABLE_TESTDATA=0 \
  -DENABLE_TOOLS=0 \
  -DENABLE_EXAMPLES=0 \
  -DCONFIG_WEBM_IO=0

cd "$deps_dir/libheif"
mkdir -p _build
cd _build
cmake \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$prefix" \
  --preset=release-noplugins \
  -DBUILD_SHARED_LIBS=1 \
  -DWITH_EXAMPLES=0 \
  -DWITH_KVAZAAR=1 \
  -DWITH_DAV1D=1 \
  -DWITH_DAV1D_PLUGIN=0 \
  -DWITH_AOM_DECODER=0 \
  ..
ninja install/strip

meson_install freetype \
  -Dzlib=enabled \
  -Dpng=disabled \
  -Dharfbuzz=disabled \
  -Dbrotli=disabled \
  -Dbzip2=disabled

meson_install fontconfig \
  -Ddoc=disabled \
  -Dnls=disabled \
  -Dtests=disabled \
  -Dtools=disabled \
  -Dcache-build=disabled

meson_install harfbuzz \
  -Dgobject=disabled \
  -Dicu=disabled \
  -Dtests=disabled \
  -Dintrospection=disabled \
  -Ddocs=disabled \
  -Dbenchmark=disabled \
  -Dgpu=disabled \
  -Dgpu_demo=disabled
rm -f "$prefix"/lib/libharfbuzz-subset*

meson_install pixman \
  -Dlibpng=disabled \
  -Dgtk=disabled \
  -Dopenmp=disabled \
  -Ddemos=disabled \
  -Dtests=disabled

meson_install cairo \
  -Dfontconfig=enabled \
  -Dquartz=disabled \
  -Dtee=disabled \
  -Dxcb=disabled \
  -Dxlib=disabled \
  -Dzlib=disabled \
  -Dtests=disabled \
  -Dspectre=disabled \
  -Dsymbol-lookup=disabled

cd "$deps_dir/fribidi"
autoreconf -fiv
configure_make_install fribidi \
  --enable-shared \
  --disable-static \
  --disable-dependency-tracking

meson_install pango \
  -Dgtk_doc=false \
  -Dintrospection=disabled \
  -Dfontconfig=enabled

cd "$deps_dir/librsvg"
sed -i.bak "/cairo-rs = /s/, \"pdf\", \"ps\"//" {librsvg-c,rsvg}/Cargo.toml
sed -i.bak "/subdir('rsvg_convert')/d" meson.build
meson_install librsvg \
  -Dintrospection=disabled \
  -Dpixbuf=disabled \
  -Dpixbuf-loader=disabled \
  -Ddocs=disabled \
  -Dvala=disabled \
  -Dtests=false \
  -Davif=enabled

cd "$deps_dir/vips"
magick_args=()
system_pkg_config_path="$(env -u PKG_CONFIG_LIBDIR -u PKG_CONFIG_PATH pkg-config --variable pc_path pkg-config)"
vips_pkg_config_libdir="$PKG_CONFIG_LIBDIR:$system_pkg_config_path"
vips_pkg_config_path="$PKG_CONFIG_PATH:$system_pkg_config_path"
if [ "${ENABLE_MAGICK:-false}" = "true" ]; then
  magick_pkg="$(env PKG_CONFIG_LIBDIR="$vips_pkg_config_libdir" PKG_CONFIG_PATH="$vips_pkg_config_path" pkg-config --list-all | awk '/^MagickCore/ { print $1; exit } /^ImageMagick/ { print $1; exit }')"
  if [ -z "$magick_pkg" ]; then
    echo "unable to locate an ImageMagick pkg-config package" >&2
    exit 1
  fi
  magick_args=(
    -Dmagick=enabled
    "-Dmagick-package=$magick_pkg"
  )
else
  magick_args=(-Dmagick=disabled)
fi

PKG_CONFIG_LIBDIR="$vips_pkg_config_libdir" PKG_CONFIG_PATH="$vips_pkg_config_path" \
meson setup _build \
  --buildtype=release \
  --strip \
  --wrap-mode=nofallback \
  --prefix="$prefix" \
  --libdir=lib \
  -Ddocs=false \
  -Dintrospection=disabled \
  -Dmodules=disabled \
  "${magick_args[@]}"
ninja -C _build
ninja -C _build install

rm -f "$prefix"/lib/libvips-cpp.*
rm -rf "$prefix"/lib/cmake
find "$prefix"/lib -name '*.a' -delete
find "$prefix"/lib -name '*.la' -delete
