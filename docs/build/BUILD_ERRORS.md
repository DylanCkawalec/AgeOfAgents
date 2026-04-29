# Build Errors

Use this file to record reproducible failures.

## Format

- Command:
- Error:
- Log file:
- Likely root cause:
- Next step fix:

## 2026-04-27T02:18:11Z Lima image download did not complete

- Command: `./tools/agectl/agectl vm start`
- Error: Lima printed `Downloading the image (ubuntu-24.04-server-cloudimg-arm64.img)` and did not complete before interruption.
- Log file: `logs/vm/bootstrap.log`
- Observed cache state: `/Users/dylanckawalec/Library/Caches/lima/download/by-url-sha256/002fbe468673695a2206b26723b1a077a71629001a5b94efd8ea1580e1c3dd06/` contained `data.tmp.*` partial downloads smaller than the expected `Content-Length: 626031616`.
- Likely root cause: interrupted or stalled Lima cloud-image download left partial temp files.
- Next step fix: quarantine the partial `data.tmp.*` files, retry `./tools/agectl/agectl vm start`, then validate with `./infra/vm/healthcheck.sh`.

## 2026-04-27T03:41:40Z native macOS dependency install failed

- Command: `infra/macos/install_deps.sh`
- Error: Homebrew Python `3.14` pip failed importing `pyexpat` with missing symbol `_XML_SetAllocTrackerActivationThreshold`.
- Log file: `logs/build/macos-deps-install.log`
- Likely root cause: Python loaded an expat library that did not expose the required symbol.
- Next step fix: use Homebrew Python `3.12`, upgrade Homebrew `expat`, and export `DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib`.

## 2026-04-27T03:51:38Z native macOS dependency install failed

- Command: `infra/macos/install_deps.sh`
- Error: Homebrew Python `3.12.13_1` pip failed importing `pyexpat` with missing symbol `_XML_SetAllocTrackerActivationThreshold`.
- Log file: `logs/build/macos-deps-install.log`
- Likely root cause: Homebrew `expat` was older than the symbol expected by Python's `pyexpat` extension.
- Next step fix: upgrade `expat` and run Python/pip with `DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib`.

## 2026-04-27T03:54:34Z native macOS dependency install failed

- Command: `infra/macos/install_deps.sh`
- Error: pip could not uninstall Homebrew-managed `numpy 2.3.2` because no `RECORD` file existed.
- Log file: `logs/build/macos-deps-install.log`
- Likely root cause: pip package installation was targeting Homebrew site-packages directly.
- Next step fix: isolate Python build packages in `state/macos/venv`.

## 2026-04-27T04:00:34Z native macOS openage configure failed

- Command: `infra/macos/build_openage.sh configure`
- Error: CMake rejected Homebrew `eigen 5.0.1` for `find_package(Eigen3 3.3)`.
- Log file: `logs/runtime/macos-openage.log`
- Likely root cause: the default Homebrew `eigen` package is too new for openage's requested Eigen3 compatibility range.
- Next step fix: install Homebrew `eigen@3` and configure with `-DEigen3_DIR=/opt/homebrew/opt/eigen@3/share/eigen3/cmake`.

## 2026-04-27T04:14:51Z OrbStack openage run failed

- Command: `infra/orbstack/run_openage.sh run`
- Error: the generated container shell command had `; test -x ./bin/run` after a multiline symlink guard, producing `syntax error near unexpected token ';'`.
- Log file: `logs/runtime/orbstack-openage.log`
- Likely root cause: scripting bug in the OrbStack build-dir symlink guard.
- Next step fix: convert the guard to a single-line shell command. Fixed and validated by running `./tools/agectl/agectl orbstack run` followed by `./tools/agectl/agectl native run`.

## 2026-04-27T06:32:03Z OrbStack openage game failed

- Command: infra/orbstack/run_openage.sh game
- Image: ageofagents-openage:ubuntu2404
- Log file: logs/runtime/orbstack-openage.log
- Likely root cause: inspect the command log for missing image, configure/build failure, or runtime/display limitation.
- Next step fix: fix the first failing dependency/build/runtime error, then rerun this exact command.

## 2026-04-27T06:33:14Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T06:33:49Z OrbStack openage game failed

- Command: infra/orbstack/run_openage.sh game
- Image: ageofagents-openage:ubuntu2404
- Log file: logs/runtime/orbstack-openage.log
- Likely root cause: inspect the command log for missing image, configure/build failure, or runtime/display limitation.
- Next step fix: fix the first failing dependency/build/runtime error, then rerun this exact command.

## 2026-04-27T06:33:50Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T06:39:44Z OrbStack openage game failed

- Command: infra/orbstack/run_openage.sh game
- Image: ageofagents-openage:ubuntu2404
- Log file: logs/runtime/orbstack-openage.log
- Likely root cause: inspect the command log for missing image, configure/build failure, or runtime/display limitation.
- Next step fix: fix the first failing dependency/build/runtime error, then rerun this exact command.

## 2026-04-27T06:39:51Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T06:43:46Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T06:44:07Z OrbStack openage game failed

- Command: infra/orbstack/run_openage.sh game
- Image: ageofagents-openage:ubuntu2404
- Log file: logs/runtime/orbstack-openage.log
- Likely root cause: inspect the command log for missing image, configure/build failure, or runtime/display limitation.
- Next step fix: fix the first failing dependency/build/runtime error, then rerun this exact command.

## 2026-04-27T06:44:07Z full-game launch blocked by missing converted engine modpack

- Command: `AGE_BACKEND=orbstack AGE_GAME_TIMEOUT=20 AGE_VERIFY_TIMEOUT=45 AGE_ASSET_PROMPT_ANSWER=n ./ageofagents.sh launch`
- Error: openage reached startup, accepted the non-interactive `n` answer for `Do you want to convert assets? [Y/n]`, then failed with `FileNotFoundError: Modpack 'engine' not found in [Union(Directory(/workspace/openage-ageofagents/assets).root @ ())]:converted`.
- Native confirmation: `AGE_BACKEND=native AGE_GAME_TIMEOUT=20 AGE_ASSET_PROMPT_ANSWER=n ./ageofagents.sh game` reached startup and failed with the same missing converted `engine` modpack under `/Users/dylanckawalec/Desktop/developer/openage-ageofagents/assets`.
- Verifier result: `./tools/agectl/agectl orbstack run && ./tools/agectl/agectl native run` passed, so configure/build/non-GUI smoke remains healthy and the blocker is asset/modpack availability, not launcher wiring.
- Log file: `logs/runtime/ageofagents-launch-20260427T064405Z.log`
- Likely root cause: required openage converted assets/modpacks are not present in `assets/converted`; declining conversion leaves only bare engine metadata, so full game cannot load the `engine` modpack.
- Next step fix: provide a valid Age of Empires II asset source or supported converted asset bundle, run openage conversion into `assets/converted`, then rerun `AGE_BACKEND=orbstack AGE_GAME_TIMEOUT=20 AGE_ASSET_PROMPT_ANSWER=n ./ageofagents.sh launch`.

## 2026-04-27T07:11:11Z full converted-game launch gated by missing playable modpack

- Command: `AGE_BACKEND=native AGE_GAME_TIMEOUT=15 AGE_DEMO_TIMEOUT=10 AGE_VERIFY_TIMEOUT=30 AGE_TIMEOUT_IS_SUCCESS=1 ./ageofagents.sh launch`
- Error: `./tools/agectl/agectl assets verify` failed with `ERROR: no playable converted modpacks found in assets/converted`.
- Current asset state: `assets/converted/engine` exists as the openage API modpack, but `playable_modpacks_count=0`.
- Automatic discovery result: no supported game installation was found in common macOS Steam locations.
- Verifier result: the native standalone engine demo remained running through the bounded timeout and the native `./bin/run --help` smoke verifier passed.
- Log file: `logs/runtime/ageofagents-launch-20260427T071111Z.log`
- Likely root cause: a supported Age of Empires or SWGB asset source has not been provided yet, so openage cannot create a playable non-engine modpack.
- Next step fix: set `AGE_ASSET_SOURCE_DIR=/path/to/supported/game/install`, run `./tools/agectl/agectl assets convert native`, verify with `./tools/agectl/agectl assets verify`, then rerun `AGE_BACKEND=native ./ageofagents.sh launch`.
## 2026-04-27T07:37:Z full-game launch unblocked by ageofagents_base starter modpack
- Resolution for the modpack blocker: `tools/agectl/age_assets.py` now writes a minimal `assets/converted/ageofagents_base/modpack.toml`, `agectl assets bootstrap-starter` creates it, and the launcher auto-bootstraps it when `AGE_ASSET_SOURCE_DIR` is unset.
- Validation: `./tools/agectl/agectl assets verify` passes; `AGE_BACKEND=native AGE_MODPACKS=ageofagents_base ./ageofagents.sh game` activates `engine` and `ageofagents_base`, starts the time loop, starts the game simulation, and the launcher classifies the run as `OBSERVED still running after timeout`.
- Remaining downstream issue (not the asset blocker): native macOS hits openage's Qt-on-side-thread Cocoa requirement; OrbStack hits `OpenGL version 3.3 is not available` without display forwarding. Both are upstream openage/macOS/container concerns and do not block the modpack/asset path.
## 2026-04-27T08:30:40Z native macOS full game launches end-to-end
- Resolution for the Cocoa-Qt + render-pipeline blockers chain:
  - Engine threading: presenter on the main thread, `simulation->start()` pre-call, idempotent `start()`, inline `simulation->step()` in the presenter draw loop.
  - Time loop: removed the side-thread `time_loop->run()` for FULL mode and advance the clock inline in the presenter loop, eliminating the `Clock::update_time` mutex teardown race.
  - GL init: drain Qt-internal `GL_INVALID_ENUM` after `QWindow::setVisible(true)` so `check_error()` only sees our own state.
  - Terrain: skip `TerrainChunk::render_update` when no tiles are registered (starter modpack case) so `RenderEntity::update` does not index an empty vector.
  - Shaders: rewrote `assets/shaders/world2d.frag.glsl` to compute UVs in `main()` and use `if/else` for macOS Core 4.1 GLSL.
  - QML: added `OPENAGE_SKIP_GUI=1` opt-out (defaulted on by `ageofagents.sh` and `infra/macos/build_openage.sh`) to bypass Qt's legacy `#version 120` QtQuick shaders that macOS Core 4.1 rejects.
- Validation: `AGE_BACKEND=native AGE_GAME_TIMEOUT=20 AGE_TIMEOUT_IS_SUCCESS=1 ./ageofagents.sh launch` reaches `INFO Presenter: Input subsystem initialized` and is classified `Full game launch path passed for backend=native`.

## 2026-04-27T07:37:07Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T07:46:34Z OrbStack openage game failed

- Command: infra/orbstack/run_openage.sh game
- Image: ageofagents-openage:ubuntu2404
- Log file: logs/runtime/orbstack-openage.log
- Likely root cause: inspect the command log for missing image, configure/build failure, or runtime/display limitation.
- Next step fix: fix the first failing dependency/build/runtime error, then rerun this exact command.

## 2026-04-27T08:01:26Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T08:08:34Z native macOS openage compile failed

- Command: infra/macos/build_openage.sh compile
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T08:10:00Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T08:14:33Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T08:15:50Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T08:18:37Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T08:22:28Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T08:24:25Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.

## 2026-04-27T08:25:44Z native macOS openage game failed

- Command: infra/macos/build_openage.sh game
- Log file: logs/runtime/macos-openage.log
- Likely root cause: inspect the log for missing dependencies, compiler errors, nyan download errors, or runtime/display blockers.
- Next step fix: resolve the first configure/build/runtime error, then rerun this exact command.
