# agectl Commands
`agectl` is the iTerm2/operator gateway for the AgeOfAgents substrate.
## VM
- `agectl vm start`
- `agectl vm stop`
- `agectl vm status`
- `agectl vm shell`
## Dependencies
- `agectl deps install`
## Build
- `agectl build configure`
- `agectl build compile`
- `agectl build status`
## Runtime
- `agectl run`
- `agectl game`
- `agectl demo`
- `agectl logs`
- `agectl logs runtime`
- `agectl logs build`
- `agectl logs vm`
## OrbStack fallback
- `agectl orbstack status`
- `agectl orbstack build-image`
- `agectl orbstack configure`
- `agectl orbstack compile`
- `agectl orbstack run`
- `agectl orbstack game`
- `agectl orbstack convert`
- `agectl orbstack demo`
- `agectl orbstack all`
- `agectl orbstack shell`
## Native macOS fallback
- `agectl native check-deps`
- `agectl native install-deps`
- `agectl native configure`
- `agectl native compile`
- `agectl native run`
- `agectl native game`
- `agectl native convert`
- `agectl native demo`
- `agectl native all`
## Assets
- `agectl assets status`
- `agectl assets discover`
- `agectl assets list`
- `agectl assets list --playable --names-only`
- `agectl assets verify`
- `agectl assets validate-source [source_dir]`
- `agectl assets bootstrap-starter`
- `agectl assets bootstrap-starter --force`
- `agectl assets remove-starter`
- `AGE_ASSET_SOURCE_DIR=/path/to/game ./tools/agectl/agectl assets convert native`
- `AGE_ASSET_SOURCE_DIR=/path/to/game ./tools/agectl/agectl assets convert orbstack`
## Events
- `agectl events init`
- `agectl events status`
- `agectl events types`
- `agectl events emit <event_type> [payload_json]`
- `agectl events list [--limit N] [--type event.type]`
- `agectl events tail [--lines N] [--follow]`
## Not implemented until the runtime gate passes
- `agectl agents ...`
- `agectl quest ...`
- `agectl bridge qgot ...`
- `agectl bridge opseeq ...`
