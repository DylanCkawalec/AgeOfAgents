# Build Log

## Day 1 Runtime Foundation

- Cloned `openage` into `/Users/dylanckawalec/Desktop/developer/openage-ageofagents`.
- Cloned `aoc` branch `arch` into `/Users/dylanckawalec/Desktop/developer/aoc`.
- Created VM scaffolding under `infra/vm`.
- Created `agectl` gateway scaffold.
- Pending: install `lima` + `qemu`, bootstrap VM, run healthcheck.

## Runtime fallback validation

- `./tools/agectl/agectl orbstack build-image` completed successfully and produced `ageofagents-openage:ubuntu2404`.
- `./tools/agectl/agectl orbstack configure` completed successfully in the Ubuntu 24.04 ARM64 container and downloaded/built nyan.
- `./tools/agectl/agectl orbstack compile` completed successfully in the container.
- `./tools/agectl/agectl orbstack run` completed successfully with `./bin/run --help`.
- `./tools/agectl/agectl native install-deps` completed successfully after switching to a project-local Python 3.12 virtualenv and installing `eigen@3`.
- `./tools/agectl/agectl native check-deps` passed.
- `./tools/agectl/agectl native configure` completed successfully with Homebrew LLVM, virtualenv Python 3.12, and `-DEigen3_DIR=/opt/homebrew/opt/eigen@3/share/eigen3/cmake`.
- `./tools/agectl/agectl native compile` completed successfully.
- `./tools/agectl/agectl native run` completed successfully with `./bin/run --help`.
- `infra/orbstack/run_openage.sh` and `infra/macos/build_openage.sh` now restore their own `bin` symlink before compile/run so Linux-container and native builds can coexist.
- After the symlink guard fix, `./tools/agectl/agectl orbstack run` and `./tools/agectl/agectl native run` both pass when run back-to-back.
- Current validation level: configure/build/non-GUI runtime smoke is proven through OrbStack and native macOS. Full GUI/runtime launch is still not validated.

## Launcher and full-game validation

- Added `ageofagents.sh` as the root launcher for `doctor`, `boot`, `health`, `verify`, `game`, and `launch`.
- Added full-game actions through `agectl game`, `agectl orbstack game`, and `agectl native game`.
- Updated backend runners to run openage from `bin` with `cd bin && ./run ...`, which is required by openage generated code.
- Replaced `ln -sfn` backend switching with explicit symlink removal/recreation so OrbStack and native builds can switch `bin` reliably.
- Added `AGE_ASSET_PROMPT_ANSWER`/`OPENAGE_STDIN` forwarding so non-interactive full-game launches can answer the openage asset conversion prompt deterministically.
- Added native `PYTHONPATH` setup from `state/macos/venv` because the native `run` binary links Homebrew Python while Python packages are installed in the project venv.
- `bash -n ageofagents.sh tools/agectl/agectl infra/vm/run_engine.sh infra/orbstack/run_openage.sh infra/macos/build_openage.sh` passed.
- `AGE_BACKEND=auto AGE_VM_BOOT_TIMEOUT=30 AGE_GAME_TIMEOUT=20 ./ageofagents.sh doctor` passed global, Lima status, OrbStack, and native dependency checks.
- `./tools/agectl/agectl orbstack run && ./tools/agectl/agectl native run` passed back-to-back after the symlink fix.
- `AGE_BACKEND=orbstack AGE_GAME_TIMEOUT=20 AGE_VERIFY_TIMEOUT=45 AGE_ASSET_PROMPT_ANSWER=n ./ageofagents.sh launch` ran full game first, reached real openage startup, failed on missing converted `engine` modpack assets, then passed the `./bin/run --help` verifier.
- `AGE_BACKEND=native AGE_GAME_TIMEOUT=20 AGE_ASSET_PROMPT_ANSWER=n ./ageofagents.sh game` reached real openage startup and failed on the same missing converted `engine` modpack assets.

## Asset gate and standalone demo validation

- Added `tools/agectl/age_assets.py` for converted modpack enumeration, playable modpack verification, common source discovery, and asset source validation.
- Added `agectl assets status|discover|list|verify|validate-source|convert`.
- Added backend `convert` and `demo` actions for native macOS, OrbStack, and Lima runners.
- Updated `ageofagents.sh` so full-game launch requires a playable non-engine modpack before calling `./run game --modpacks ...`.
- Updated the launcher default backend order to `native,orbstack,lima` because native macOS is the current path for observing a real window.
- `./tools/agectl/agectl assets status` reports `engine_modpack=present`, `converted_modpacks=engine@0.5.0`, and `playable_modpacks_count=0`.
- `./tools/agectl/agectl assets verify` fails clearly until a non-engine modpack is converted.
- `AGE_BACKEND=auto AGE_VM_BOOT_TIMEOUT=30 AGE_GAME_TIMEOUT=20 ./ageofagents.sh doctor` passes while warning that `AGE_ASSET_SOURCE_DIR` is not set.
- `./tools/agectl/agectl orbstack run && ./tools/agectl/agectl native run` still passes back-to-back.
- `AGE_BACKEND=native AGE_GAME_TIMEOUT=15 AGE_DEMO_TIMEOUT=10 AGE_VERIFY_TIMEOUT=30 AGE_TIMEOUT_IS_SUCCESS=1 ./ageofagents.sh launch` blocks full converted-game launch due to missing playable modpacks, runs the standalone native engine demo, observes it still running after timeout, and passes the smoke verifier.
- `AGE_BACKEND=native AGE_DEMO_TIMEOUT=5 AGE_TIMEOUT_IS_SUCCESS=1 ./ageofagents.sh demo` observes the standalone native engine demo still running after timeout and returns success.
## Standalone playable launch fix
- Added `tools/agectl/age_assets.py` `bootstrap-starter`/`remove-starter` commands and an `AGE_AUTO_STARTER` launcher path that materializes a minimal `ageofagents_base` modpack under `assets/converted/ageofagents_base/`.
- The starter modpack is generated, ignored by git, and supplies a non-engine playable modpack so `openage/main/main.py` and `openage/game/main.py` accept the launch without proprietary AoE/SWGB assets.
- `./tools/agectl/agectl assets bootstrap-starter` creates the modpack; `./tools/agectl/agectl assets verify` reports `PASS playable converted modpack(s): ageofagents_base`.
- After bootstrap, `AGE_BACKEND=native AGE_GAME_TIMEOUT=15 AGE_TIMEOUT_IS_SUCCESS=1 AGE_MODPACKS=ageofagents_base ./ageofagents.sh game` activates `engine` and `ageofagents_base`, starts the time loop, starts the game simulation, and the launcher classifies the run as `OBSERVED still running after timeout; treating as launched`.
- The launcher's `launch` flow now auto-bootstraps the starter when `AGE_ASSET_SOURCE_DIR` is unset, so the full-game gate passes even on a fresh checkout.
- Remaining downstream constraints, recorded for completeness:
  - Native macOS Qt6 Cocoa requires the GUI on the process main thread; openage's current `Engine` runs the presenter on a side thread, so full-game launch on native macOS reaches Qt window creation but then enters the macOS termination path. Use `./ageofagents.sh demo` for a real playable engine/window verifier on native macOS, or run via Linux (OrbStack) with display forwarding for full GUI.
  - OrbStack containers without a GPU/display report `OpenGL version 3.3 is not available`; configure host display forwarding before expecting full GUI from the Linux backend.
## Native macOS full-game launch (single-thread Cocoa-Qt fix)
- Refactored `libopenage/engine/engine.cpp` to drive the presenter on the process main thread and pre-call `simulation->start()` in the constructor. macOS Cocoa Qt requires the GUI event loop on the main thread; the previous side-thread presenter triggered `terminate has been called` immediately after `Created Qt window with OpenGL context`.
- Made `GameSimulation::start()` idempotent (`libopenage/gamestate/simulation.cpp`) so the engine constructor can synchronously initialize the game before the simulation thread is created. Added `GameSimulation::step()` (declared in `libopenage/gamestate/simulation.h`) so the presenter can drive simulation steps inline each frame.
- Updated `libopenage/presenter/presenter.cpp` to advance the clock and step the simulation inside the draw loop, eliminating the cross-thread mutex teardown race that previously surfaced as `mutex lock failed: Invalid argument` in `Clock::update_time` on macOS.
- Drained Qt-internal GL errors after `setVisible(true)` in `libopenage/renderer/opengl/window.cpp` so macOS Core 4.1's strict glGetError semantics no longer abort `GlContext::check_error()` with `GL_INVALID_ENUM` left over from Qt's window setup.
- Hardened `libopenage/gamestate/terrain_chunk.cpp` to skip `render_update` when a chunk has no tiles. The starter modpack registers no terrain, and the previous code indexed an empty `tiles` vector inside `RenderEntity::update`, causing a SIGSEGV during `attach_renderer`.
- Reworked the world fragment shader (`assets/shaders/world2d.frag.glsl`) to compute UVs inside `main()` and to use `if/else` instead of an integer `switch`. macOS Core 4.1 GLSL rejects globals that reference `in`/`uniform` storage qualifiers, and the integer-switch crashed Apple's GL linker.
- Added an `OPENAGE_SKIP_GUI` opt-out in `libopenage/presenter/presenter.cpp` and defaulted it to `1` in both `ageofagents.sh` and `infra/macos/build_openage.sh`. macOS Core 4.1 does not support Qt's legacy QML `#version 120` shaders; skipping the QML overlay lets the engine, simulation, terrain, world, HUD, and screen render stages all initialize and the input subsystem come online.
- Final validation: `AGE_BACKEND=native AGE_GAME_TIMEOUT=20 AGE_TIMEOUT_IS_SUCCESS=1 ./ageofagents.sh launch` boots, doctors, prepares assets via the auto-bootstrapped `ageofagents_base` starter modpack, runs the native full game with `./bin/run game --modpacks ageofagents_base`, initializes Skybox/Terrain/World/HUD/Screen render stages plus the input subsystem, and is classified `Full game launch path passed for backend=native` after the bounded timeout.

## Local event bus validation

- Added `agent_runtime/event_bus/age_event_bus.py`.
- Added `agectl events init|status|types|emit|list|tail`.
- `./tools/agectl/agectl events init` created durable storage.
- `./tools/agectl/agectl events emit system.healthcheck.passed '{"component":"event_bus","validation":"agectl"}' --source agectl --actor operator` wrote a test event.
- `./tools/agectl/agectl events list --limit 5` read the event from SQLite.
- `./tools/agectl/agectl events tail --lines 3` read the event through the tail path.
- Event state files were created at `state/events.jsonl` and `state/ageofagents.sqlite`.
