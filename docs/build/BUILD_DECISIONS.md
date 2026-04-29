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

## Standalone game launch decisions

- **Decision:** Treat `assets/converted/engine` as an API/runtime dependency, not a playable game.
- **Why:** openage excludes `engine` when enumerating playable modpacks; full game launch requires a non-engine converted modpack.
- **Decision:** Add explicit `agectl assets` commands before further agent integration.
- **Why:** The launcher must verify asset readiness before starting openage so missing assets are reported as an operator action, not as a late runtime exception.
- **Decision:** Prefer native macOS first for the full launch gate.
- **Why:** Native macOS is the only currently validated path that can show an actual local window; OrbStack remains valuable for build, conversion, and smoke checks.
- **Decision:** Add a standalone engine demo verifier while preserving the full-game asset gate.
- **Why:** The demo proves the engine/window/input path can start, but it does not replace playable converted AoE/SWGB assets for real full-game launch.

## Native macOS Cocoa-Qt threading and render decisions

- **Decision:** Run the presenter on the process main thread and drive the simulation step inline each frame.
- **Why:** Cocoa Qt requires the GUI event loop on the main thread, and an inline simulation step matches the proven Pong demo pattern, removing all cross-thread access to `Clock`, `EventLoop`, and game state during render.
- **Decision:** Pre-call `GameSimulation::start()` synchronously in the engine constructor and make `start()` idempotent.
- **Why:** This guarantees `Game` (and its `GameState`) exist before any thread accesses them, so `simulation->attach_renderer()` cannot race a not-yet-constructed game.
- **Decision:** Drain Qt-internal GL errors after `setVisible(true)` and skip terrain `render_update` for empty-tile chunks.
- **Why:** macOS Core 4.1 is stricter than Linux drivers; ignoring Qt's harmless init errors and not indexing an empty terrain tile vector lets the renderer initialize cleanly with the starter modpack.
- **Decision:** Default `OPENAGE_SKIP_GUI=1` in the macOS launcher and runner.
- **Why:** Qt's legacy QtQuick QML pipeline ships `#version 120` shaders that macOS Core 4.1 cannot compile. Skipping the QML overlay keeps the engine/window/input/render stages working today; the QML overlay can be re-enabled when an `OpenGLRhi` or alternative QML path lands.
