# Dependency Matrix (VM Path)

## Host (macOS M2)

- Homebrew
- Lima
- QEMU
- iTerm2

## VM (Ubuntu ARM64)

- build-essential
- cmake
- ninja-build
- python3, python3-pip, python3-venv, python3-dev
- cython3
- qt6-base-dev, qt6-declarative-dev
- libsdl2-dev
- libpng-dev, libepoxy-dev, libfreetype6-dev
- libopusfile-dev, libharfbuzz-dev, libfontconfig1-dev

## OrbStack fallback

- OrbStack `2.1.1`
- Docker client/server `29.4.0`
- Image: `ageofagents-openage:ubuntu2404`
- Base: `ubuntu:24.04`
- Dockerfile: `packaging/docker/devenv/Dockerfile.ubuntu.2404`

## Native macOS fallback

- Homebrew CMake
- Homebrew LLVM clang++
- Homebrew Python `3.12`
- Project-local virtualenv: `state/macos/venv`
- Homebrew `qt6`
- Homebrew `eigen@3`
- Homebrew `libepoxy`, `freetype`, `fontconfig`, `harfbuzz`, `opus`, `opusfile`, `libogg`, `libpng`, `toml11`, `flex`, `make`
- Homebrew `expat` with `DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib` for Python pyexpat compatibility
