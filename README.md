# imagor-base

Shared Docker base images for imagor-family projects.

This repository owns the native dependency build for libvips and related codecs. It is intended to publish reusable GHCR images that downstream projects such as imagor and imagorvideo can consume.

## Images

The GitHub Actions workflow publishes these variants:

- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-dev`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-magick`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-magick-dev`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-mozjpeg`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-mozjpeg-dev`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-ffmpeg`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-ffmpeg-dev`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-magick-ffmpeg`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-magick-ffmpeg-dev`

`latest`, `latest-dev`, `latest-magick`, `latest-magick-dev`, `latest-mozjpeg`, `latest-mozjpeg-dev`, `latest-ffmpeg`, `latest-ffmpeg-dev`, `latest-magick-ffmpeg`, and `latest-magick-ffmpeg-dev` are also published from the `main` branch.

This keeps the public tag focused on the compatibility boundary that matters most: libvips version and feature variant. The distro baseline can live in labels, release notes, or the Dockerfile history.

The default build baseline is `ubuntu:noble`, though callers can still override `BASE_IMAGE` at build time.

`r<rev>` is the base-image revision line for cases where the native capability surface changes while the upstream libvips version stays the same.

`default`, `magick`, and `mozjpeg` are built as independent native-stack variants. Their `-dev` companions add the system `-dev` packages needed to compile downstream CGO applications against `/opt/imagor`. `ffmpeg` is layered on top of `default`, `magick-ffmpeg` is layered on top of `magick`, and their `-dev` variants are built from those published runtime tags.

If the computed version tag already exists in GHCR with a complete `linux/amd64` and `linux/arm64` manifest, the workflow skips rebuilding it by default. If the tag is missing or only partially published, the workflow builds again. Use the `force_build` workflow-dispatch input when you want to rebuild anyway.

## Local build

Build the default variant:

```bash
docker build -t imagor-base .
```

Build the ImageMagick variant:

```bash
docker build --build-arg ENABLE_MAGICK=true -t imagor-base:magick .
```

Build the default dev variant:

```bash
docker build --target dev -t imagor-base:dev .
```

Build the MozJPEG variant:

```bash
docker build --build-arg ENABLE_MOZJPEG=true -t imagor-base:mozjpeg .
```

Build the FFmpeg variant from the default base image:

```bash
docker build -f Dockerfile.ffmpeg --build-arg SOURCE_TAG=vips<vips>-r<rev> -t imagor-base:ffmpeg .
```

Build the FFmpeg dev variant from the published FFmpeg image:

```bash
docker build -f Dockerfile.dev --build-arg SOURCE_TAG=vips<vips>-r<rev>-ffmpeg -t imagor-base:ffmpeg-dev .
```

## Repository layout

- `Dockerfile`: multi-stage base image build
- `Dockerfile.dev`: additive dev-package layer for downstream CGO builders
- `Dockerfile.ffmpeg`: additive FFmpeg layer for ffmpeg-capable variants
- `versions.sh`: pinned native dependency versions
- `download-deps.sh`: source fetch stage
- `build-deps.sh`: native compilation stage
- `build-ffmpeg.sh`: FFmpeg compilation stage for layered variants
- `.github/workflows/docker.yml`: GHCR publishing workflow

## Notes

- Rust is required only for building modern librsvg.
- The produced image installs the native stack under `/opt/imagor`.
- Downstream app images should build against `/opt/imagor` rather than distro-provided `-dev` packages.
