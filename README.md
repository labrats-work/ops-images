# ops-images

Multi-architecture Docker images for DevOps and operations tooling. All images support both `linux/amd64` and `linux/arm64/v8` architectures.

[![GitHub Release](https://img.shields.io/github/v/release/labrats-work/ops-images)](https://github.com/labrats-work/ops-images/releases)
[![License](https://img.shields.io/github/license/labrats-work/ops-images)](LICENSE)

## Available Images

All images are published to GitHub Container Registry:

| Image | Description | Base | Pull Command |
|-------|-------------|------|--------------|
| **ansible** | Ansible with essential tools | Alpine 3.22 | `docker pull ghcr.io/labrats-work/ops-images/ansible:latest` |
| **terraform** | Terraform with essential tools | Alpine 3.22 | `docker pull ghcr.io/labrats-work/ops-images/terraform:latest` |
| **python** | Minimal Python with build tools | Python 3.12 | `docker pull ghcr.io/labrats-work/ops-images/python:latest` |
| **python-ffmpeg** | Python with ffmpeg support | Python 3.12 | `docker pull ghcr.io/labrats-work/ops-images/python-ffmpeg:latest` |
| **omnibus** | All-in-one operations image | Alpine 3.22 | `docker pull ghcr.io/labrats-work/ops-images/omnibus:latest` |

## Quick Start

### Using Pre-built Images

Pull and run any image from GitHub Container Registry:

```bash
# Pull the latest version
docker pull ghcr.io/labrats-work/ops-images/ansible:latest

# Run a command
docker run --rm ghcr.io/labrats-work/ops-images/ansible:latest ansible --version
```

### Multi-Architecture Support

All images automatically pull the correct architecture for your platform:

```bash
# Verify multi-arch support
docker buildx imagetools inspect ghcr.io/labrats-work/ops-images/ansible:latest

# Output shows both amd64 and arm64 manifests
```

## Image Details

### Ansible

Alpine-based image with Ansible and essential DevOps tools.

**Includes:**
- ansible
- git
- openssh
- jq
- yq

**Usage:**
```bash
# Run ansible playbook
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/labrats-work/ops-images/ansible:latest \
  ansible-playbook playbook.yml

# Interactive shell
docker run --rm -it ghcr.io/labrats-work/ops-images/ansible:latest sh
```

### Terraform

Alpine-based image with Terraform (default v1.13.4) and essential tools.

**Includes:**
- terraform (configurable version)
- git
- openssh
- jq
- yq
- xorriso

**Usage:**
```bash
# Run terraform commands
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/labrats-work/ops-images/terraform:latest \
  terraform init

# With AWS credentials
docker run --rm -v $(pwd):/workspace -w /workspace \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  ghcr.io/labrats-work/ops-images/terraform:latest \
  terraform plan
```

**Custom Terraform Version:**
```bash
# Build with specific Terraform version
docker build -f src/terraform/dockerfile \
  --build-arg TERRAFORM_VERSION=1.6.0 \
  -t terraform:1.6.0 \
  src/terraform
```

### Python

Debian-based minimal Python image with build tools for compiling packages.

**Includes:**
- Python 3.12
- pip (upgraded)
- build-essential (installed then removed)
- gcc (installed then removed)

**Usage:**
```bash
# Run Python script
docker run --rm -v $(pwd):/app -w /app \
  ghcr.io/labrats-work/ops-images/python:latest \
  python script.py

# Install packages and run
docker run --rm -v $(pwd):/app -w /app \
  ghcr.io/labrats-work/ops-images/python:latest \
  sh -c "pip install -r requirements.txt && python app.py"
```

### Python FFmpeg

Python image with ffmpeg for video/audio processing.

**Includes:**
- Python 3.12
- pip (upgraded)
- ffmpeg
- build-essential (installed then removed)
- gcc (installed then removed)

**Usage:**
```bash
# Process video with Python and ffmpeg
docker run --rm -v $(pwd):/app -w /app \
  ghcr.io/labrats-work/ops-images/python-ffmpeg:latest \
  python video_processor.py

# Use ffmpeg directly
docker run --rm -v $(pwd):/videos -w /videos \
  ghcr.io/labrats-work/ops-images/python-ffmpeg:latest \
  ffmpeg -i input.mp4 output.mp4
```

### Omnibus

All-in-one image combining Ansible, Terraform, Python, and networking tools.

**Includes:**
- ansible
- terraform (default v1.13.4)
- python3 with pip
- git, openssh
- jq, yq
- wireguard-tools
- iptables

**Usage:**
```bash
# Run multiple tools in one container
docker run --rm ghcr.io/labrats-work/ops-images/omnibus:latest \
  "terraform version && ansible --version && python --version"

# With Wireguard support (requires additional capabilities)
docker run --rm \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  --sysctl net.ipv4.conf.all.src_valid_mark=1 \
  ghcr.io/labrats-work/ops-images/omnibus:latest \
  "which wg && which wg-quick"
```

## Image Tags

Images are tagged using semantic versioning with multiple tag formats:

### Release Tags (Recommended for Production)

```bash
# Latest stable release (always recommended)
docker pull ghcr.io/labrats-work/ops-images/ansible:latest

# Specific version (pinned)
docker pull ghcr.io/labrats-work/ops-images/ansible:1.0.1

# Major.minor version (receives patch updates)
docker pull ghcr.io/labrats-work/ops-images/ansible:1.0

# Major version (receives minor and patch updates)
docker pull ghcr.io/labrats-work/ops-images/ansible:1
```

### Development Tags

```bash
# Main branch (latest main branch build)
docker pull ghcr.io/labrats-work/ops-images/ansible:main

# Pull Request builds (for testing)
docker pull ghcr.io/labrats-work/ops-images/ansible:pr-7

# Specific commit SHA
docker pull ghcr.io/labrats-work/ops-images/ansible:sha-abc1234
```

### Pre-release Tags

```bash
# Beta releases
docker pull ghcr.io/labrats-work/ops-images/ansible:1.1.0-beta

# Release candidates
docker pull ghcr.io/labrats-work/ops-images/ansible:1.1.0-rc.1
```

## Building Locally

### Build for Current Architecture

```bash
# Build any image
docker build -f src/ansible/dockerfile -t ansible:local src/ansible
docker build -f src/terraform/dockerfile -t terraform:local src/terraform
docker build -f src/python/dockerfile -t python:local src/python
docker build -f src/python-ffmpeg/dockerfile -t python-ffmpeg:local src/python-ffmpeg
docker build -f src/omnibus/dockerfile -t omnibus:local src/omnibus
```

### Build Multi-Architecture Images

Requires Docker Buildx:

```bash
# Create buildx builder if needed
docker buildx create --name multiarch --use

# Build for multiple architectures
docker buildx build --platform linux/amd64,linux/arm64/v8 \
  -f src/omnibus/dockerfile \
  -t omnibus:multi \
  --load \
  src/omnibus
```

### Custom Build Arguments

```bash
# Terraform with custom version
docker build -f src/terraform/dockerfile \
  --build-arg TERRAFORM_VERSION=1.6.0 \
  -t terraform:custom \
  src/terraform

# Omnibus with custom Terraform version
docker build -f src/omnibus/dockerfile \
  --build-arg TERRAFORM_VERSION=1.6.0 \
  -t omnibus:custom \
  src/omnibus
```

## Common Use Cases

### CI/CD Pipelines

Use these images in your CI/CD workflows:

**GitHub Actions:**
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/labrats-work/ops-images/terraform:latest
    steps:
      - uses: actions/checkout@v4
      - run: terraform init
      - run: terraform plan
```

**GitLab CI:**
```yaml
deploy:
  image: ghcr.io/labrats-work/ops-images/ansible:latest
  script:
    - ansible-playbook deploy.yml
```

### Docker Compose

```yaml
version: '3.8'
services:
  infrastructure:
    image: ghcr.io/labrats-work/ops-images/omnibus:latest
    volumes:
      - ./infrastructure:/workspace
    working_dir: /workspace
    command: terraform apply -auto-approve
```

### Local Development

```bash
# Create alias for convenience
alias tf='docker run --rm -v $(pwd):/workspace -w /workspace ghcr.io/labrats-work/ops-images/terraform:latest'

# Use like native command
tf init
tf plan
tf apply
```

## Version Information

| Component | Version |
|-----------|---------|
| Alpine Linux | 3.22 |
| Python | 3.12 (Debian Bookworm) |
| Terraform | 1.13.4 (default, configurable) |
| GitHub Actions | docker/build-push-action@v6 |

## Release Process

This repository uses automated releases via GitHub Actions:

1. **Create a version tag:**
   ```bash
   git tag -a v1.2.0 -m "Release description"
   git push origin v1.2.0
   ```

2. **Automated workflow:**
   - Builds all images for amd64 and arm64
   - Creates multi-arch manifests
   - Publishes to GitHub Container Registry
   - Creates GitHub Release with notes
   - Runs automated tests

3. **Images become available:**
   - `ghcr.io/labrats-work/ops-images/*:1.2.0`
   - `ghcr.io/labrats-work/ops-images/*:1.2`
   - `ghcr.io/labrats-work/ops-images/*:1`
   - `ghcr.io/labrats-work/ops-images/*:latest`

See [Releases](https://github.com/labrats-work/ops-images/releases) for all available versions.

## Architecture

All images support:
- **linux/amd64** - Intel/AMD 64-bit
- **linux/arm64/v8** - ARM 64-bit (Apple Silicon, AWS Graviton, etc.)

Docker automatically pulls the correct image for your platform.

## Contributing

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker
5. Submit a pull request

### Testing

Pull requests automatically trigger builds for both architectures. Images are tagged as `pr-<number>` for testing:

```bash
# Test PR build
docker pull ghcr.io/labrats-work/ops-images/ansible:pr-123
```

### Project Structure

```
ops-images/
├── .github/workflows/      # CI/CD workflows
│   ├── build.yml          # Main build workflow (all images, matrix-based)
│   ├── omnibus-tests.yml  # Omnibus testing workflow (reusable)
│   └── release.yml        # Release automation
├── src/                   # Dockerfile sources
│   ├── ansible/
│   ├── terraform/
│   ├── python/
│   ├── python-ffmpeg/
│   └── omnibus/
├── CLAUDE.md             # AI assistant guidance
└── README.md             # This file
```

### Workflow Architecture

The repository uses an efficient **matrix-based build system**:

- **Single workflow** (`build.yml`) builds all images in parallel
- **Matrix strategy** ensures consistency across all images
- **All images versioned together** - no version drift
- **Reduced duplication** - one workflow instead of five
- **Easier maintenance** - update once, apply everywhere

## License

See [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/labrats-work/ops-images/issues)
- **Releases**: [GitHub Releases](https://github.com/labrats-work/ops-images/releases)
- **Registry**: [GitHub Packages](https://github.com/orgs/labrats-work/packages?repo_name=ops-images)

## Acknowledgments

Built with:
- [Docker Buildx](https://docs.docker.com/buildx/) for multi-architecture builds
- [GitHub Actions](https://github.com/features/actions) for CI/CD
- [Alpine Linux](https://alpinelinux.org/) and [Debian](https://www.debian.org/) base images
