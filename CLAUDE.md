# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains multi-architecture Docker images for operations/DevOps tooling. Images are published to GitHub Container Registry (ghcr.io/labrats-work/ops-images).

## Architecture

### Image Structure

The repository maintains five specialized container images under `src/`:

- **ansible**: Alpine-based image with Ansible, git, openssh, jq, yq
- **terraform**: Alpine-based image with Terraform (configurable version), git, openssh, jq, yq, xorriso
- **python**: Debian-based (python:3.12-slim-bookworm) minimal Python image with build tools
- **python-ffmpeg**: Python image with ffmpeg support and build tools
- **omnibus**: Multi-arch Alpine image combining Ansible, Terraform, Python, Wireguard tools, and iptables

### Multi-Architecture Build System

All images support multi-architecture builds (linux/amd64, linux/arm64/v8) using Docker Buildx with the following workflow pattern:

1. **Build job**: Builds for each platform in parallel, pushes by digest
2. **Merge job**: Creates manifest list combining all platform digests
3. **Tests job**: Validates the merged image (omnibus only currently)

The omnibus image uses `TARGETPLATFORM` and `BUILDPLATFORM` build arguments to conditionally download architecture-specific binaries (e.g., Terraform for arm64 vs amd64).

### GitHub Actions Workflows

The repository uses a consolidated matrix-based build system in `.github/workflows/`:

**build.yml** - Main build workflow:
- Uses matrix strategy to build all 5 images in parallel
- Builds each image for both amd64 and arm64 platforms
- Triggered on push to main, tags, PRs, and workflow_dispatch
- Uses digest-based pushing strategy for multi-arch support
- Images tagged with: branch name, PR reference, semver patterns, and commit SHA
- Calls omnibus-tests workflow after merge job completes
- All images are kept on the same version

**omnibus-tests.yml** - Reusable testing workflow:
- Called from build.yml after omnibus image is merged
- Validates tool availability using `which` and version checks
- Requires special container options: `--cap-add NET_ADMIN --cap-add SYS_MODULE --sysctl net.ipv4.conf.all.src_valid_mark=1` for Wireguard support

**release.yml** - Automated release workflow:
- Triggers on version tags (v*.*.*)
- Creates GitHub releases with automated notes
- Includes pull commands and version information for all images
- Runs in parallel with build.yml when tags are pushed

## Build Commands

### Local Development

Build a specific image locally:
```bash
# Build for current architecture
docker build -f src/ansible/dockerfile -t ansible:local src/ansible
docker build -f src/terraform/dockerfile -t terraform:local src/terraform
docker build -f src/python/dockerfile -t python:local src/python
docker build -f src/python-ffmpeg/dockerfile -t python-ffmpeg:local src/python-ffmpeg
docker build -f src/omnibus/dockerfile -t omnibus:local src/omnibus
```

Build multi-architecture image locally (requires buildx):
```bash
# Example for omnibus
docker buildx build --platform linux/amd64,linux/arm64/v8 \
  -f src/omnibus/dockerfile \
  -t omnibus:multi \
  src/omnibus
```

### Terraform Version Override

For terraform and omnibus images, override the Terraform version at build time (default is 1.13.4):
```bash
docker build -f src/terraform/dockerfile \
  --build-arg TERRAFORM_VERSION=1.14.0 \
  -t terraform:1.14.0 \
  src/terraform
```

### Testing Omnibus Image Locally

Test the omnibus image with Wireguard support:
```bash
docker run --rm \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  --sysctl net.ipv4.conf.all.src_valid_mark=1 \
  omnibus:local \
  "terraform -v && ansible --version && python --version && which wg && which wg-quick"
```

## Image Registry

All images are published to GitHub Container Registry:
- `ghcr.io/labrats-work/ops-images/ansible`
- `ghcr.io/labrats-work/ops-images/terraform`
- `ghcr.io/labrats-work/ops-images/python`
- `ghcr.io/labrats-work/ops-images/python-ffmpeg`
- `ghcr.io/labrats-work/ops-images/omnibus`

## Current Versions

- **Alpine**: 3.22
- **Python**: 3.12-slim-bookworm (Debian 12 Bookworm)
- **Terraform**: 1.13.4 (configurable via build arg)
- **GitHub Actions**: docker/build-push-action@v6

## Release Process

### Semantic Versioning

This repository uses semantic versioning (semver) for releases. All images are tagged following the semver pattern.

### Creating a Release

To create a new release, push a semantic version tag:

```bash
# Create and push a version tag
git tag -a v1.2.3 -m "Release description"
git push origin v1.2.3
```

This triggers:
1. **Image builds** (all 5 workflows) - Builds multi-arch images for amd64 and arm64
2. **Release workflow** - Creates a GitHub release with:
   - Automated release notes
   - Pull commands for all images
   - Architecture support information
   - Changelog since previous release

### Image Tag Strategy

Images are tagged based on the trigger event:

**Pull Request builds:**
- `pr-<number>` (e.g., `pr-7`)
- `sha-<commit>` (e.g., `sha-abc1234`)

**Main branch builds:**
- `main` (branch name)
- `latest` (always points to latest main)
- `sha-<commit>` (e.g., `sha-abc1234`)

**Release builds (version tags):**
- `<major>.<minor>.<patch>` (e.g., `1.2.3`)
- `<major>.<minor>` (e.g., `1.2`)
- `<major>` (e.g., `1`)
- `latest` (always points to newest release)
- `sha-<commit>` (e.g., `sha-abc1234`)

**Pre-release builds:**
- Tags like `v1.2.3-beta`, `v1.2.3-rc.1` are marked as pre-releases

### Example: Pulling Images

```bash
# Pull latest stable release
docker pull ghcr.io/labrats-work/ops-images/ansible:latest

# Pull specific version
docker pull ghcr.io/labrats-work/ops-images/terraform:1.0.1

# Pull from PR for testing
docker pull ghcr.io/labrats-work/ops-images/python:pr-7

# Verify multi-arch manifest
docker buildx imagetools inspect ghcr.io/labrats-work/ops-images/omnibus:1.0.1
```

## Important Conventions

- All images use empty ENTRYPOINT and CMD to allow flexible usage (except omnibus)
- Omnibus image sets ENTRYPOINT to `["/bin/sh", "-c"]` for shell command execution
- All images include OCI labels for author and source repository
- Workflow CONTEXT env var points to the source directory for each image
- REGISTRY_IMAGE env var defines the target registry path in workflows
- Release workflow automatically creates GitHub releases for version tags
