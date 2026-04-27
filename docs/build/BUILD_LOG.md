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

## Local event bus validation

- Added `agent_runtime/event_bus/age_event_bus.py`.
- Added `agectl events init|status|types|emit|list|tail`.
- `./tools/agectl/agectl events init` created durable storage.
- `./tools/agectl/agectl events emit system.healthcheck.passed '{"component":"event_bus","validation":"agectl"}' --source agectl --actor operator` wrote a test event.
- `./tools/agectl/agectl events list --limit 5` read the event from SQLite.
- `./tools/agectl/agectl events tail --lines 3` read the event through the tail path.
- Event state files were created at `state/events.jsonl` and `state/ageofagents.sqlite`.
