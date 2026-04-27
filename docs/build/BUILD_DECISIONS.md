# Build Decisions

## Day 1

- **Decision:** Use Lima ARM64 VM as the primary runtime compatibility layer on macOS M2.
- **Why:** Best CLI automation and iTerm2 shell accessibility with shared host mounts.
- **Fallback:** Use OrbStack Docker first for Linux configure/build/runtime smoke if Lima image bootstrap is blocked. Use native macOS as a secondary build/smoke path with Homebrew LLVM and a project-local Python virtualenv.
- **Gate:** No game/runtime feature work until VM healthcheck and build path are validated or a reproducible failure is logged.

## Runtime fallback decisions

- **Decision:** Use the repo-provided `packaging/docker/devenv/Dockerfile.ubuntu.2404` for OrbStack instead of duplicating dependency logic.
- **Why:** It is the upstream-supported Ubuntu 24.04 dependency image for openage.
- **Decision:** Use `state/macos/venv` for native Python packages.
- **Why:** Homebrew site-packages caused pip/package conflicts and Python/expat linkage issues; the local virtualenv isolates Cython, numpy, mako, lz4, pillow, pygments, setuptools, and toml.
- **Decision:** Use Homebrew `eigen@3` and pass `-DEigen3_DIR=/opt/homebrew/opt/eigen@3/share/eigen3/cmake` for native configure.
- **Why:** Homebrew `eigen` is version `5.0.1`, which does not satisfy openage's `find_package(Eigen3 3.3)` requirement.

## Event bus decisions

- **Decision:** Keep AgeOfAgents orchestration events in `agent_runtime/event_bus` instead of `openage/event` or `libopenage/event`.
- **Why:** openage already has an internal engine event system; AgeOfAgents needs a separate operator/agent/orchestration event stream.
- **Decision:** Use both JSONL and SQLite for the first durable local bus.
- **Why:** JSONL is easy to inspect and append; SQLite supports indexed CLI queries for `agectl events list` and future bridge APIs.
