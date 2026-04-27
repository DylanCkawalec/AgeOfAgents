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

## Local event bus

1. `./tools/agectl/agectl events init`
2. `./tools/agectl/agectl events status`
3. `./tools/agectl/agectl events emit system.healthcheck.passed '{"component":"event_bus"}'`
4. `./tools/agectl/agectl events list --limit 10`
5. `./tools/agectl/agectl events tail --lines 20`

Event storage is local-only under `state/events.jsonl` and `state/ageofagents.sqlite`.
