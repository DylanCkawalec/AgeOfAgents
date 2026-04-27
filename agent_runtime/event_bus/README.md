# AgeOfAgents Event Bus
This subsystem provides the local durable event bus used by `agectl`, future agent runtime code, QGoT bridges, opseeq bridges, and game-runtime adapters.
## Storage
- JSONL append log: `state/events.jsonl`
- SQLite database: `state/ageofagents.sqlite`
## Event shape
Each event has:
- `event_id`
- `timestamp`
- `type`
- `source`
- `actor`
- `correlation_id`
- `payload`
- `known_type`
- `schema_version`
## CLI
Use the `agectl` gateway:
```bash
./tools/agectl/agectl events init
./tools/agectl/agectl events status
./tools/agectl/agectl events emit system.healthcheck.passed '{"component":"event_bus"}'
./tools/agectl/agectl events list --limit 10
./tools/agectl/agectl events tail --lines 20
./tools/agectl/agectl events types
```
The bus accepts known AgeOfAgents event types and future dotted event types that match the local event naming convention.
