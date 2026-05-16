# imagor-base

Shared Docker base images for imagor-family projects.

This repository owns the native dependency build for libvips and related codecs. It is intended to publish reusable GHCR images that downstream projects such as imagor and imagorvideo can consume.

## Images

The GitHub Actions workflow publishes these variants:

- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-magick`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-mozjpeg`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-ffmpeg`
- `ghcr.io/cshum/imagor-base:vips<vips>-r<rev>-magick-ffmpeg`

`latest`, `latest-magick`, and `latest-mozjpeg` are also published from the `main` branch.

This keeps the public tag focused on the compatibility boundary that matters most: libvips version and feature variant. The distro baseline can live in labels, release notes, or the Dockerfile history.

The default build baseline is `ubuntu:noble`, though callers can still override `BASE_IMAGE` at build time.

`r<rev>` is the base-image revision line for cases where the native capability surface changes while the upstream libvips version stays the same.

`default`, `magick`, and `mozjpeg` are built as independent native-stack variants. `ffmpeg` is layered on top of `default`, and `magick-ffmpeg` is layered on top of `magick`.

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

Build the MozJPEG variant:

```bash
docker build --build-arg ENABLE_MOZJPEG=true -t imagor-base:mozjpeg .
```

## Repository layout

- `Dockerfile`: multi-stage base image build
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
