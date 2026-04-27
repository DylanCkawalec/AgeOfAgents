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
