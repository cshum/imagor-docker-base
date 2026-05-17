ARG BASE_IMAGE=ubuntu:noble

FROM ${BASE_IMAGE} AS builder

ARG ENABLE_MAGICK=false
ARG ENABLE_MOZJPEG=false

COPY . /tmp/imagor-base

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    autoconf \
    autopoint \
    automake \
    bash \
    bison \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    gettext \
    git \
    gperf \
    libcfitsio-dev \
    libfftw3-dev \
    libgsf-1-dev \
    libimagequant-dev \
    libmatio-dev \
    libopenjp2-7-dev \
    libopenslide-dev \
    liborc-0.4-dev \
    libpoppler-glib-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libtool \
    meson \
    nasm \
    ninja-build \
    pkg-config \
    python3 \
    python3-packaging \
    xz-utils \
  && if [ "$ENABLE_MAGICK" = "true" ]; then \
    apt-get install -y --no-install-recommends libmagickwand-dev; \
  fi \
  && /tmp/imagor-base/install-rust.sh \
  && /tmp/imagor-base/build-env.sh > /etc/profile.d/imagor-base.sh \
  && chmod +x /tmp/imagor-base/*.sh \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV BASH_ENV=/etc/profile.d/imagor-base.sh
ENV ENABLE_MAGICK=${ENABLE_MAGICK}
ENV ENABLE_MOZJPEG=${ENABLE_MOZJPEG}

RUN /tmp/imagor-base/download-deps.sh \
  && /tmp/imagor-base/build-deps.sh \
  && rm -rf /root/deps /tmp/imagor-base

FROM ${BASE_IMAGE} AS final

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    fontconfig-config \
    fonts-dejavu-core \
    libcfitsio10t64 \
    libfftw3-double3 \
    libgcc-s1 \
    libgsf-1-114 \
    libimagequant0 \
    libjemalloc2 \
    libmatio11 \
    libopenjp2-7 \
    libopenslide0 \
    liborc-0.4-0t64 \
    libpoppler-glib8t64 \
    libstdc++6 \
  && if [ "$ENABLE_MAGICK" = "true" ]; then \
    apt-get install -y --no-install-recommends libmagickwand-6.q16-7t64; \
  fi \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/imagor /opt/imagor
COPY --from=builder /etc/profile.d/imagor-base.sh /etc/profile.d/imagor-base.sh

ENV PKG_CONFIG_PATH=/opt/imagor/lib/pkgconfig
ENV CGO_CFLAGS=-I/opt/imagor/include
ENV CGO_LDFLAGS="-L/opt/imagor/lib -Wl,-rpath,/opt/imagor/lib"
ENV LD_LIBRARY_PATH=/opt/imagor/lib
ENV FONTCONFIG_PATH=/etc/fonts

WORKDIR /src
CMD ["bash"]
