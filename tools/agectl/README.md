# agectl

`agectl` is the host operator gateway for AgeOfAgents.

## Current scope (Day 1)

- VM lifecycle wrappers
- dependency install wrapper
- build/run wrapper
- log directory access
- OrbStack fallback wrappers
- native macOS fallback wrappers
- asset source and converted modpack checks
- local event bus gateway

## Usage

```bash
./tools/agectl/agectl vm start
./tools/agectl/agectl vm status
./tools/agectl/agectl deps install
./tools/agectl/agectl build compile
./tools/agectl/agectl logs runtime
./tools/agectl/agectl orbstack status
./tools/agectl/agectl native check-deps
./tools/agectl/agectl assets status
./tools/agectl/agectl assets verify
./tools/agectl/agectl events status
```

Day 2+ expands this command surface to full agent, quest, QGoT, and opseeq controls.
