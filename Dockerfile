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
    curl \
    gettext \
    git \
    gperf \
    libimagequant-dev \
    libopenjp2-7-dev \
    libpoppler-glib-dev \
    libraw-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libtool \
    nasm \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    xz-utils \
  && if [ "$ENABLE_MAGICK" = "true" ]; then \
    apt-get install -y --no-install-recommends libmagickwand-dev; \
  fi \
  && /tmp/imagor-base/install-rust.sh \
  && python3 -m venv /root/.python \
  && /root/.python/bin/pip install --no-cache-dir meson ninja packaging 'cmake<4' \
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
    libgcc-s1 \
    libimagequant0 \
    libjemalloc2 \
    libopenjp2-7 \
    libpoppler-glib8 \
    libraw20 \
    libstdc++6 \
  && if [ "$ENABLE_MAGICK" = "true" ]; then \
    apt-get install -y --no-install-recommends libmagickwand-6.q16-6; \
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
