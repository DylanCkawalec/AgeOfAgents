# agectl Examples
## Day 1 and Day 2 substrate
Start or create the Lima VM:
```bash
./tools/agectl/agectl vm start
```
Check VM status:
```bash
./tools/agectl/agectl vm status
```
Run the healthcheck directly:
```bash
./infra/vm/healthcheck.sh
```
Install openage dependencies inside the VM:
```bash
./tools/agectl/agectl deps install
```
Configure and compile openage inside the VM:
```bash
./tools/agectl/agectl build configure
./tools/agectl/agectl build compile
```
Run the minimal runtime smoke check:
```bash
./tools/agectl/agectl run
```
Run the standalone engine/window/input demo:
```bash
AGE_BACKEND=native ./ageofagents.sh demo
```
## OrbStack fallback
Build the OrbStack Docker image:
```bash
./tools/agectl/agectl orbstack build-image
```
Run configure, compile, and non-GUI smoke test:
```bash
./tools/agectl/agectl orbstack configure
./tools/agectl/agectl orbstack compile
./tools/agectl/agectl orbstack run
```
## Native macOS fallback
Check native dependencies:
```bash
./tools/agectl/agectl native check-deps
```
Install missing native dependencies, then build:
```bash
./tools/agectl/agectl native install-deps
./tools/agectl/agectl native configure
./tools/agectl/agectl native compile
./tools/agectl/agectl native run
```
## Assets and full game gate
Inspect converted modpacks:
```bash
./tools/agectl/agectl assets status
./tools/agectl/agectl assets list
./tools/agectl/agectl assets verify
```
Discover common local game install paths:
```bash
./tools/agectl/agectl assets discover
```
Convert a supported game installation into `assets/converted`:
```bash
AGE_ASSET_SOURCE_DIR=/path/to/supported/game/install ./tools/agectl/agectl assets convert native
```
Launch the full game after a playable non-engine modpack exists:
```bash
AGE_BACKEND=native ./ageofagents.sh launch
```
## Local event bus
Initialize event storage:
```bash
./tools/agectl/agectl events init
```
Emit an event:
```bash
./tools/agectl/agectl events emit system.healthcheck.passed '{"component":"event_bus"}'
```
Inspect recent events:
```bash
./tools/agectl/agectl events status
./tools/agectl/agectl events list --limit 10
./tools/agectl/agectl events tail --lines 20
```
