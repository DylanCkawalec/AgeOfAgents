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
- `agectl orbstack all`
- `agectl orbstack shell`
## Native macOS fallback
- `agectl native check-deps`
- `agectl native install-deps`
- `agectl native configure`
- `agectl native compile`
- `agectl native run`
- `agectl native all`
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
