# Runtime Foundation Runbook

1. `./infra/vm/expose_to_macos.sh`
2. `./infra/vm/bootstrap_vm.sh`
3. `./infra/vm/healthcheck.sh`
4. `./infra/vm/install_openage_deps.sh`
5. `./infra/vm/run_engine.sh`

If step 4 or 5 fails, capture command and exact error in `BUILD_ERRORS.md` and do not proceed as if successful.

## OrbStack fallback path

1. `./tools/agectl/agectl orbstack status`
2. `./tools/agectl/agectl orbstack build-image`
3. `./tools/agectl/agectl orbstack configure`
4. `./tools/agectl/agectl orbstack compile`
5. `./tools/agectl/agectl orbstack run`

The current OrbStack validation target is `./bin/run --help`, not a full GUI launch.

## Native macOS fallback path

1. `./tools/agectl/agectl native install-deps`
2. `./tools/agectl/agectl native check-deps`
3. `./tools/agectl/agectl native configure`
4. `./tools/agectl/agectl native compile`
5. `./tools/agectl/agectl native run`

The native path uses Homebrew LLVM, Homebrew `eigen@3`, Homebrew Python 3.12 as the virtualenv base, and project-local Python packages in `state/macos/venv`.

## Asset and full-game launch gate

1. `./tools/agectl/agectl assets status`
2. `./tools/agectl/agectl assets discover`
3. `./tools/agectl/agectl assets verify`
4. If no playable modpack exists, set `AGE_ASSET_SOURCE_DIR=/path/to/supported/game/install`.
5. `AGE_ASSET_SOURCE_DIR=/path/to/supported/game/install ./tools/agectl/agectl assets convert native`
6. `./tools/agectl/agectl assets verify`
7. `AGE_BACKEND=native ./ageofagents.sh launch`

`assets/converted/engine` is only the openage API modpack and is not playable. Full converted-game launch requires at least one non-engine modpack in `assets/converted`.

## Standalone engine demo verifier

Use this when a supported game asset source is not available yet:

1. `AGE_BACKEND=native AGE_DEMO_TIMEOUT=10 ./ageofagents.sh demo`

This validates that the native engine/window/input path can start and remain alive under a bounded timeout. It does not replace the full converted-game launch gate.
## Starter modpack (no proprietary assets required)
1. `./tools/agectl/agectl assets bootstrap-starter`
2. `./tools/agectl/agectl assets verify`
3. `AGE_BACKEND=native AGE_MODPACKS=ageofagents_base ./ageofagents.sh game`
`./ageofagents.sh launch` will auto-bootstrap the starter when `AGE_ASSET_SOURCE_DIR` is not set, so a fresh checkout can clear the modpack gate without a supported game install. Run `./tools/agectl/agectl assets remove-starter` to remove it before converting real assets.

## Local event bus

1. `./tools/agectl/agectl events init`
2. `./tools/agectl/agectl events status`
3. `./tools/agectl/agectl events emit system.healthcheck.passed '{"component":"event_bus"}'`
4. `./tools/agectl/agectl events list --limit 10`
5. `./tools/agectl/agectl events tail --lines 20`

Event storage is local-only under `state/events.jsonl` and `state/ageofagents.sqlite`.
