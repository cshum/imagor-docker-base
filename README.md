# imagor-base

Shared Docker base images for imagor-family projects.

This repository owns the native dependency build for libvips and related codecs. It is intended to publish reusable GHCR images that downstream projects such as imagor and imagorvideo can consume.

## Images

The GitHub Actions workflow publishes these variants:

- `ghcr.io/cshum/imagor-base:ubuntu22.04-vips<vips>`
- `ghcr.io/cshum/imagor-base:ubuntu22.04-vips<vips>-magick`
- `ghcr.io/cshum/imagor-base:ubuntu22.04-vips<vips>-mozjpeg`

`latest`, `latest-magick`, and `latest-mozjpeg` are also published from the `main` branch.

This keeps the public tag focused on the compatibility boundary that matters most: distro baseline, libvips version, and feature variant. More detailed dependency versions can live in labels or release notes.

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
- `versions.sh`: pinned native dependency versions
- `download-deps.sh`: source fetch stage
- `build-deps.sh`: native compilation stage
- `.github/workflows/docker.yml`: GHCR publishing workflow

## Notes

- Rust is required only for building modern librsvg.
- The produced image installs the native stack under `/opt/imagor`.
- Downstream app images should build against `/opt/imagor` rather than distro-provided `-dev` packages.
