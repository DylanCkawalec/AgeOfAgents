# draft.md — AgeOfAgents Protocol: Full Execution Plan and Master Prompt

## Status

This document is the complete execution draft for **AgeOfAgents**.

AgeOfAgents is **not** an AgentCraft integration, not an AgentCraft clone, and not dependent on any external gamified-agent dashboard. Those projects are only loose category references showing that visual/gamified agent orchestration is an emerging interface pattern.

AgeOfAgents is an original system built by transforming an Age-of-Empires-style RTS engine into a local-first agent orchestration desktop.

The implementation center of gravity is:

1. `https://github.com/DylanCkawalec/openage`
2. `https://github.com/DylanCkawalec/aoc/tree/arch`
3. `/Users/dylanckawalec/Desktop/developer/QGoT/`
4. `/Users/dylanckawalec/Desktop/developer/opseeq/`

---

# Part I — Project Definition

## 1. Project Name

**AgeOfAgents**

## 2. Core Thesis

AgeOfAgents transforms an Age-of-Empires-style RTS game into a real-time, local-first command center for agent orchestration.

The game itself becomes the dashboard.

The RTS world becomes a spatial interface for managing:

- repositories
- folders
- services
- local models
- subagents
- reasoning sessions
- worktrees
- tasks
- quests
- memory
- agent progress
- terminal output
- QGoT reasoning
- opseeq orchestration state

The goal is to make software development and agent management feel like commanding a living empire.

## 3. What This Is Not

AgeOfAgents is not:

- an AgentCraft integration
- an AgentCraft clone
- an external SaaS dashboard wrapper
- a browser-only agent board
- a cosmetic Age of Empires mod
- a simple game skin over logs
- a toy visualization
- a cloud-first agent platform
- a non-executable design mockup

AgeOfAgents is a local-first, executable, game-native orchestration runtime.

## 4. Reference Examples: Inspiration Only

The following projects are only loose references for the broader category of visual or gamified agent orchestration:

- AgentCraft — category reference only; do not use as a dependency.
- Arcane Agents — reference only for local-first terminal-backed visual agents.
- Gas Town RTS — reference only for persistent RTS-like agent coordination.
- VibeCraft — reference only for game-like agent interaction patterns.

Do not clone them.
Do not depend on them.
Do not copy their architecture.
Do not treat them as source-of-truth.

The actual source-of-truth stack is:

```txt
openage fork
+ Agents of Chaos architecture
+ QGoT reasoning harness
+ opseeq orchestration layer
+ local VM runtime
+ iTerm2 CLI gateway
```

---

# Part II — Hardware and Execution Reality

## 5. Host Machine

Target machine:

```txt
Host: macOS on Apple Silicon M2
RAM: 32 GB
Drive: 1 TB
Terminal: iTerm2
Developer root: /Users/dylanckawalec/Desktop/developer/
```

## 6. Critical Runtime Constraint

The game/runtime is expected to fail if treated as a simple native macOS launch.

Therefore, the first required deliverable is a VM-based compatibility layer capable of:

- building the engine
- running the engine/emulator/runtime
- exposing the runtime back to macOS
- exposing shell access to iTerm2
- exposing logs and control surfaces for agents
- supporting future agent-driven control of the game runtime

The VM is not optional. It is the compatibility and accessibility gateway.

## 7. Mandatory Execution Order

The build agent must not jump directly into game features.

The required order is:

1. Inspect workspace.
2. Build VM/runtime layer.
3. Verify terminal access from iTerm2 into VM.
4. Verify shared folders between macOS and VM.
5. Install build dependencies.
6. Build openage inside the VM.
7. Launch or minimally execute the engine/runtime path.
8. Expose engine logs/control back to macOS.
9. Create `agectl` terminal gateway.
10. Scaffold event bus.
11. Connect game runtime to event bus.
12. Adapt Agents of Chaos architecture.
13. Replace discovered model/controller assumptions with QGoT.
14. Represent one subagent as one game unit.
15. Expose bridge for opseeq.
16. Expand into full RTS orchestration system.

No step may claim success without validation.

---

# Part III — System Architecture

## 8. Layered Architecture

```txt
macOS M2 Host
│
├── iTerm2 Operator Gateway
│   ├── agectl CLI
│   ├── logs
│   ├── runtime commands
│   ├── agent commands
│   └── VM access
│
├── Local Source Roots
│   ├── /Users/dylanckawalec/Desktop/developer/openage-ageofagents/
│   ├── /Users/dylanckawalec/Desktop/developer/aoc/
│   ├── /Users/dylanckawalec/Desktop/developer/QGoT/
│   └── /Users/dylanckawalec/Desktop/developer/opseeq/
│
├── VM Compatibility Layer
│   ├── Linux runtime
│   ├── C++20 toolchain
│   ├── Python tooling
│   ├── CMake / Ninja
│   ├── Qt dependencies
│   ├── OpenGL/display strategy
│   ├── nyan dependency path
│   ├── openage build
│   └── exposed logs/control
│
├── AgeOfAgents Engine Layer
│   ├── openage fork
│   ├── RTS simulation
│   ├── agent unit representation
│   ├── repository map
│   ├── resource model
│   ├── quest/campaign model
│   └── game-to-agent event bridge
│
├── Agent Runtime Layer
│   ├── adapted Agents of Chaos architecture
│   ├── subagent registry
│   ├── lifecycle manager
│   ├── sandbox/worktree manager
│   ├── memory/soul model
│   ├── Hall of Heroes
│   └── telemetry API
│
├── QGoT Reasoning Layer
│   ├── per-agent reasoning harness
│   ├── planning system
│   ├── decomposition logic
│   ├── advanced context engine
│   └── copilot intelligence
│
└── opseeq Integration Layer
    ├── dashboard bridge
    ├── map state API
    ├── agent state API
    ├── mission API
    ├── event stream
    └── QGoT copilot state
```

---

# Part IV — Source Paths

## 9. Primary Repositories and Folders

### openage fork

```bash
/Users/dylanckawalec/Desktop/developer/openage-ageofagents/
```

Source:

```bash
https://github.com/DylanCkawalec/openage
```

### Agents of Chaos / aoc architecture

```bash
/Users/dylanckawalec/Desktop/developer/aoc/
```

Source:

```bash
https://github.com/DylanCkawalec/aoc/tree/arch
```

### QGoT reasoning harness

```bash
/Users/dylanckawalec/Desktop/developer/QGoT/
```

### opseeq orchestrator

```bash
/Users/dylanckawalec/Desktop/developer/opseeq/
```

---

# Part V — Grounding Assumptions for openage

## 10. openage Technical Reality

The implementation must respect openage as a real engine project, not as a simple web app.

openage is an RTS engine with Age-of-Empires-style mechanics. It uses a technical stack that includes:

- C++ engine components
- Python package/tooling
- CMake build system
- Qt GUI dependencies
- OpenGL/GLSL rendering
- nyan configuration/modding dependency
- Cython/Python integration in the build path

Therefore, the first major risk is the build/runtime environment, especially on Apple Silicon.

The project must treat build reproducibility as a first-class deliverable.

## 11. Build Reality

The build pipeline must assume:

- CMake is central.
- `./configure` is a convenience wrapper around CMake.
- nyan may need to be downloaded/built if not present.
- C++20 compiler support is required.
- Python/Cython integration may be involved.
- Qt and graphics dependencies may be painful in VM contexts.
- display forwarding or remote rendering must be solved explicitly.

---

# Part VI — VM Runtime Plan

## 12. VM Strategy

Recommended first strategy:

```txt
Lima or UTM Linux VM on Apple Silicon
```

Reason:

- Apple Silicon needs an ARM64-compatible Linux runtime.
- The VM must be accessible from iTerm2.
- The VM must support normal Linux package management.
- The VM must expose shared folders.
- The VM must be able to compile C++/Python/CMake projects.
- The VM must eventually handle display/runtime output.

Fallback strategies:

1. UTM Ubuntu ARM64 VM if Lima graphics/display path is insufficient.
2. Colima/Docker only for build, not final runtime, unless display forwarding is proven.
3. Native macOS build only as an optional optimization, not the required path.

## 13. VM Directory Deliverables

Create:

```txt
infra/vm/
├── README.md
├── setup_vm.md
├── bootstrap_vm.sh
├── install_openage_deps.sh
├── run_engine.sh
├── expose_to_macos.sh
├── healthcheck.sh
├── vm.env.example
└── TROUBLESHOOTING.md
```

## 14. VM Healthcheck

`infra/vm/healthcheck.sh` must verify:

- VM exists.
- VM boots.
- iTerm2/macOS host can shell into it.
- shared project directory is mounted.
- compiler exists.
- CMake exists.
- Ninja exists.
- Python exists.
- pip exists.
- Qt dependencies are discoverable.
- OpenGL/display strategy is documented.
- nyan can be installed or downloaded.
- openage configure step can begin.
- logs are written to a host-visible directory.

## 15. VM Log Paths

Create host-visible logs:

```txt
logs/
├── vm/
├── build/
├── runtime/
├── agents/
├── qgot/
└── opseeq/
```

---

# Part VII — Build Plan

## 16. openage Build Deliverables

Create:

```txt
docs/build/
├── BUILD_LOG.md
├── BUILD_ERRORS.md
├── DEPENDENCY_MATRIX.md
├── MAC_M2_VM_NOTES.md
├── RUNBOOK.md
└── BUILD_DECISIONS.md
```

## 17. Required Build Commands

The system should eventually support:

```bash
agectl vm start
agectl vm status
agectl deps install
agectl build configure
agectl build compile
agectl run
agectl logs runtime
```

Internally, the VM may run commands equivalent to:

```bash
./configure --download-nyan
make
```

or the CMake/Ninja equivalent.

The exact commands must be discovered from the repository and documented before execution.

## 18. Build Validation Gate

Before any game transformation begins:

```bash
./infra/vm/healthcheck.sh
./infra/vm/install_openage_deps.sh
./infra/vm/run_engine.sh
```

must either:

1. launch the runtime successfully, or
2. produce a documented, reproducible error with next-step fixes.

No agent orchestration code should be implemented until this build/runtime path is known.

---

# Part VIII — iTerm2 Accessibility Gateway

## 19. CLI Gateway

Create:

```txt
tools/agectl/
├── agectl
├── README.md
├── commands.md
├── examples.md
└── completions/
```

`agectl` is the accessibility gateway for Dylan, iTerm2, scripts, and agents.

## 20. Minimum CLI Commands

```bash
agectl vm start
agectl vm stop
agectl vm status
agectl vm shell

agectl deps install
agectl build configure
agectl build compile
agectl build status

agectl run
agectl stop
agectl logs
agectl logs runtime
agectl logs agents

agectl agents list
agectl agents spawn <agent_type>
agectl agents pause <agent_id>
agectl agents resume <agent_id>
agectl agents kill <agent_id>
agectl agents inspect <agent_id>

agectl quest create "<description>"
agectl quest assign <quest_id> <agent_id>
agectl quest status
agectl quest inspect <quest_id>

agectl bridge qgot status
agectl bridge qgot test

agectl bridge opseeq status
agectl bridge opseeq test
```

## 21. CLI Rule

The game must never become a closed GUI-only system.

Every critical action must be controllable or inspectable through at least one of:

- CLI
- local API
- event stream
- socket
- log file
- structured state file

---

# Part IX — Game Transformation Model

## 22. Core Mapping

```txt
RTS / AoE Concept         AgeOfAgents Meaning
------------------------------------------------------------
Map                       Monorepo, repos, folders, services
Terrain                   Code topology / dependency structure
Units                     AI coding agents / subagents
Villagers                 General-purpose worker agents
Scouts                    Research/search/discovery agents
Monks                     Reasoning, memory, refactor agents
Military units            Specialist agents / reviewers / debuggers
Siege units               Heavy refactor/migration agents
Buildings                 Services, modules, repos, packages
Town Center               Main orchestrator / opseeq bridge
Castle                    QGoT strategic command citadel
Monastery                 Memory/soul refinement system
Blacksmith                Tool/model/capability upgrades
Market                    Resource exchange / model/tool allocation
Resources                 CPU, RAM, tokens, context, files, tools
Tech tree                 Agent capability upgrades
Ages                      Protocol/system evolution phases
Fog of war                Unknown or unanalyzed code territory
Campaigns                 Long-running engineering epics
Quests                    Tasks, issues, prompts, missions
Alliances                 Cooperating agent groups
Combat                    Tests, regressions, merge conflicts
Victory                   Passing tests, merged PR, completed epic
Relics                    Reusable discoveries / important insights
Hall of Heroes            Persistent agent legacy archive
Wonder                    Major milestone / release
```

## 23. Required Game Panels

Implement/scaffold:

- agent selection panel
- unit status overlay
- live terminal panel
- quest assignment panel
- QGoT copilot panel
- opseeq bridge panel
- memory/soul panel
- repository map panel
- resource meter panel
- review bundle panel
- Hall of Heroes panel

## 24. Required Game Events

```txt
game.unit.selected
game.unit.commanded
game.unit.spawned
game.unit.destroyed
game.building.created
game.resource.updated
game.fog.revealed
game.quest.created
game.quest.assigned
game.quest.completed
game.quest.failed
```

---

# Part X — Agent Runtime Plan

## 25. Agents of Chaos Adaptation

Use:

```bash
/Users/dylanckawalec/Desktop/developer/aoc/
```

The existing architecture must be inspected and adapted.

Rules:

- Preserve useful subagent concepts.
- Remove Jokuh-specific assumptions.
- Remove hardcoded old model/controller assumptions.
- Replace the reasoning/controller layer with QGoT.
- Ensure every subagent can be represented as a game unit.
- Ensure every subagent can be controlled through `agectl`.
- Ensure every subagent can emit events into the game.
- Ensure every subagent can be visible to opseeq.

## 26. Target Agent Runtime Structure

```txt
agent_runtime/
├── registry/
│   ├── agent_registry.*
│   ├── agent_manifest.schema.*
│   └── agent_types.*
├── lifecycle/
│   ├── spawn_agent.*
│   ├── pause_agent.*
│   ├── resume_agent.*
│   ├── terminate_agent.*
│   └── heartbeat.*
├── qgot_bridge/
│   ├── qgot_client.*
│   ├── qgot_session.*
│   ├── qgot_reasoning_adapter.*
│   └── qgot_prompt_contract.*
├── game_bridge/
│   ├── game_event_bus.*
│   ├── unit_state_adapter.*
│   ├── quest_adapter.*
│   └── telemetry_adapter.*
├── memory/
│   ├── soul_state.*
│   ├── memory_store.*
│   ├── hall_of_heroes.*
│   └── legacy_inheritance.*
├── sandbox/
│   ├── vm_sandbox.*
│   ├── worktree_manager.*
│   ├── permissions.*
│   └── rollback.*
└── api/
    ├── agent_api.*
    ├── quest_api.*
    ├── telemetry_api.*
    └── opseeq_api.*
```

## 27. Agent Lifecycle

Each agent must support:

```txt
created
spawned
planning
working
blocked
awaiting_input
reviewing
completed
failed
paused
terminated
archived
```

## 28. Agent Types

Initial agent types:

```txt
villager.worker       General code/task worker
scout.researcher      Repo discovery and research
monk.reasoner         QGoT-heavy reasoning/refactor agent
knight.implementer    Feature implementation agent
archer.reviewer       Code review and issue detection
siege.migrator        Heavy migration/refactor agent
merchant.optimizer    Resource/cost/context optimizer
librarian.memory      Memory/soul/Hall of Heroes manager
```

---

# Part XI — QGoT Integration Plan

## 29. QGoT Path

```bash
/Users/dylanckawalec/Desktop/developer/QGoT/
```

## 30. QGoT Role

QGoT becomes:

- the reasoning harness for each subagent
- the planning layer
- the decomposition engine
- the copilot intelligence layer
- the strategy layer inside the AgeOfAgents castle/citadel
- the intelligence exposed to opseeq

## 31. QGoT Bridge Structure

Create:

```txt
bridges/qgot/
├── README.md
├── qgot_contract.md
├── qgot_adapter.*
├── qgot_session_manager.*
├── qgot_agent_harness.*
├── qgot_healthcheck.*
├── qgot_mock_adapter.*
└── examples/
```

## 32. QGoT Contract

Minimum interface:

```txt
create_session(agent_id, mission_context) -> session_id
plan(session_id, objective, constraints) -> structured_plan
step(session_id, observation) -> next_action
summarize(session_id) -> summary
close_session(session_id) -> result
```

## 33. QGoT Validation Gate

Prove:

- QGoT path exists.
- QGoT can be inspected.
- An adapter contract is defined.
- A mock mission can be sent.
- A structured plan is returned.
- A subagent can consume the plan.
- AgeOfAgents can display the plan/status.

If real QGoT invocation is not yet available, use a mock adapter with the exact final interface.

---

# Part XII — opseeq Integration Plan

## 34. opseeq Path

```bash
/Users/dylanckawalec/Desktop/developer/opseeq/
```

## 35. opseeq Role

opseeq should eventually treat AgeOfAgents as:

- gamified orchestration dashboard
- agent state backend
- mission/task source
- QGoT copilot surface
- visual protocol operations layer

## 36. opseeq Bridge Structure

Create:

```txt
bridges/opseeq/
├── README.md
├── opseeq_contract.md
├── opseeq_api_adapter.*
├── opseeq_event_stream.*
├── opseeq_dashboard_bridge.*
├── opseeq_healthcheck.*
└── examples/
```

## 37. opseeq Exposed State

Expose:

- map state
- active agents
- agent health
- active quests
- quest progress
- logs
- terminal streams
- QGoT plans
- QGoT copilot state
- review bundles
- completed artifacts

---

# Part XIII — Event Bus

## 38. Event Bus Requirement

Create a local event bus that connects:

- game engine
- CLI
- subagents
- QGoT
- opseeq
- logs
- persistent storage

## 39. Minimum Event Types

```txt
agent.spawned
agent.started
agent.paused
agent.resumed
agent.blocked
agent.failed
agent.completed
agent.message
agent.terminal.output
agent.memory.updated

quest.created
quest.assigned
quest.started
quest.blocked
quest.completed
quest.failed

game.unit.selected
game.unit.commanded
game.building.created
game.resource.updated
game.fog.revealed

qgot.session.created
qgot.plan.created
qgot.plan.updated
qgot.reasoning.completed

opseeq.connected
opseeq.command.received
opseeq.dashboard.updated

system.healthcheck.passed
system.healthcheck.failed
system.error
```

## 40. Event Persistence

Use one simple durable store first:

- JSONL event log
- SQLite
- local file state

Recommended MVP:

```txt
state/
├── ageofagents.sqlite
├── events.jsonl
├── agents/
├── quests/
├── qgot/
└── opseeq/
```

---

# Part XIV — Security and Sandbox

## 41. Agent Safety Requirements

Because agents execute code, the system must include:

- per-agent working directories
- per-agent logs
- per-agent permissions
- per-agent sandbox options
- path allowlists
- rollbackable worktrees
- audit log
- no destructive commands without explicit approval
- no secret exfiltration
- no uncontrolled network calls unless configured
- clear operator override path

## 42. Security Documentation

Create:

```txt
docs/security/
├── SECURITY_MODEL.md
├── SANDBOXING.md
├── PERMISSIONS.md
├── AUDIT_LOGS.md
├── ROLLBACK.md
└── THREAT_MODEL.md
```

---

# Part XV — Configuration

## 43. Config Files

Create:

```txt
config/
├── ageofagents.yaml
├── vm.yaml
├── models.yaml
├── agents.yaml
├── qgot.yaml
├── opseeq.yaml
├── security.yaml
└── logging.yaml
```

## 44. Local-First Model Policy

Default policy:

- local Ollama/self-hosted models only
- local logs
- local storage
- local memory
- local VM sandboxes
- no required cloud dependency

Cloud APIs may exist only as optional providers, disabled by default.

---

# Part XVI — UX Direction

## 45. Creative Direction

AgeOfAgents should feel like:

```txt
Age of Empires
+ local AI command center
+ medieval-futurist software kingdom
+ terminal-native developer cockpit
+ strategic agent war room
```

## 46. UX Rule

Every magical/fantasy metaphor must map to a real capability.

Examples:

- Scout reveals fog -> research agent analyzed unknown repo
- Villager gathers wood -> worker agent collects context
- Blacksmith upgrade -> new tool/model/capability unlocked
- Castle strategy -> QGoT high-level planning
- Monastery -> memory/soul refinement
- Battle -> failing tests or merge conflicts
- Wonder -> completed release milestone
- Campaign victory -> completed epic

No decorative-only systems unless explicitly marked as visual polish.

---

# Part XVII — Two-Week Execution Plan

## Day 1 — Runtime Foundation

Deliver:

- inspect workspace
- inspect openage fork
- inspect aoc path
- inspect QGoT path
- inspect opseeq path
- choose VM strategy
- create VM folder structure
- create initial VM docs
- create healthcheck scaffold

Validation:

```bash
ls /Users/dylanckawalec/Desktop/developer/
test -d /Users/dylanckawalec/Desktop/developer/QGoT/
test -d /Users/dylanckawalec/Desktop/developer/opseeq/
```

## Day 2 — VM Bootstrap

Deliver:

- working VM start/stop/status
- shell access from iTerm2
- shared folder mount
- initial dependency install script

Validation:

```bash
./infra/vm/healthcheck.sh
```

## Day 3 — openage Dependencies

Deliver:

- compiler toolchain
- CMake
- Ninja
- Python
- Qt dependencies
- nyan strategy
- dependency matrix

Validation:

```bash
agectl deps install
agectl build configure
```

## Day 4 — openage Build

Deliver:

- configure openage
- compile openage
- record errors
- document fixes

Validation:

```bash
agectl build compile
```

## Day 5 — Runtime Launch

Deliver:

- launch runtime or reproducible failure
- runtime logs
- display strategy
- macOS/iTerm2 access

Validation:

```bash
agectl run
agectl logs runtime
```

## Day 6 — CLI Gateway

Deliver:

- `agectl` command scaffold
- VM commands
- build commands
- runtime commands
- logs commands

Validation:

```bash
agectl vm status
agectl build status
agectl logs
```

## Day 7 — Event Bus

Deliver:

- local event schema
- JSONL/SQLite persistence
- CLI event publishing
- game runtime event adapter scaffold

Validation:

```bash
agectl events tail
agectl events emit system.healthcheck.passed
```

## Day 8 — Agent Runtime Scaffold

Deliver:

- inspect and adapt aoc architecture
- create agent registry
- create lifecycle manager
- create dummy worker agent
- remove old model/controller assumptions

Validation:

```bash
agectl agents list
agectl agents spawn villager.worker
```

## Day 9 — QGoT Bridge

Deliver:

- QGoT adapter contract
- QGoT healthcheck
- mock adapter if needed
- one agent using QGoT-style plan

Validation:

```bash
agectl bridge qgot status
agectl bridge qgot test
```

## Day 10 — Game-Agent Bridge

Deliver:

- one subagent represented as RTS unit
- unit state updated by agent status
- quest assigned to agent
- logs visible through CLI

Validation:

```bash
agectl agents spawn scout.researcher
agectl quest create "Inspect repository structure"
agectl quest assign <quest_id> <agent_id>
```

## Day 11 — Repository Map

Deliver:

- map generator from repo/folder structure
- buildings for folders/services
- fog-of-war placeholder
- resource model placeholder

Validation:

```bash
agectl map generate /Users/dylanckawalec/Desktop/developer/opseeq/
agectl map status
```

## Day 12 — Memory / Soul / Hall of Heroes

Deliver:

- persistent memory scaffold
- soul metadata
- Hall of Heroes archive
- agent legacy state

Validation:

```bash
agectl agents inspect <agent_id>
agectl heroes list
```

## Day 13 — opseeq Bridge

Deliver:

- opseeq API/event contract
- state export
- dashboard bridge scaffold
- opseeq healthcheck

Validation:

```bash
agectl bridge opseeq status
agectl bridge opseeq test
```

## Day 14 — Full Demo Path

Deliver complete flow:

```txt
iTerm2
→ agectl
→ VM runtime
→ AgeOfAgents engine
→ visible RTS unit
→ subagent
→ QGoT reasoning harness
→ quest execution
→ logs/status
→ opseeq bridge state
```

Validation:

```bash
agectl vm status
agectl run
agectl agents spawn villager.worker
agectl quest create "Inspect AgeOfAgents build risks"
agectl bridge qgot test
agectl bridge opseeq test
agectl logs
```

---

# Part XVIII — Final Validation Criteria

The system is not considered successful unless these work or have documented reproducible failure states:

```bash
agectl vm status
agectl build configure
agectl build compile
agectl run
agectl logs
agectl agents list
agectl agents spawn villager.worker
agectl quest create "Inspect repository structure and summarize build risks"
agectl quest status
agectl bridge qgot status
agectl bridge opseeq status
```

Create:

```txt
FINAL_STATUS.md
```

with:

- completed features
- failed features
- exact commands run
- exact errors
- runtime logs
- architecture diagram
- next implementation priorities

---

# Part XIX — Failure Handling Rules

When something fails:

1. Capture the exact command.
2. Capture the exact error.
3. Save logs.
4. Add entry to relevant troubleshooting file.
5. Identify likely root cause.
6. Provide next concrete action.
7. Do not proceed as if the failed layer works.

Never hide build failures.
Never hallucinate missing documents.
Never skip runtime validation.
Never claim game integration works until a command path has been tested.

---

# Part XX — Master Execution Prompt

Use the following prompt to execute the full project logic.

```md
You are the lead build engineer, systems architect, game-engine engineer, and agent-runtime engineer for **AgeOfAgents**.

Your task is to execute the full AgeOfAgents plan in `draft.md`.

AgeOfAgents is a custom, local-first RTS command center created by transforming an Age-of-Empires-style openage engine fork into a real agent orchestration desktop.

This is not an AgentCraft integration.
This is not an AgentCraft clone.
AgentCraft, Arcane Agents, Gas Town RTS, and VibeCraft are only loose category references showing that gamified/visual agent orchestration is a design space. Do not clone them, depend on them, copy them, or use them as architectural sources of truth.

The actual implementation foundation is:

1. `https://github.com/DylanCkawalec/openage`
2. `https://github.com/DylanCkawalec/aoc/tree/arch`
3. `/Users/dylanckawalec/Desktop/developer/QGoT/`
4. `/Users/dylanckawalec/Desktop/developer/opseeq/`

The machine is:

- macOS on Apple Silicon M2
- 32 GB RAM
- 1 TB drive
- iTerm2 terminal
- development root: `/Users/dylanckawalec/Desktop/developer/`

Critical execution rule:

The game/runtime is expected to fail if treated as a simple native macOS launch. Therefore, your first job is to create the VM compatibility/runtime layer and prove the engine can build/run there. Do not start game features, UI features, or agent orchestration features until the VM/build/runtime path is validated or has a documented reproducible failure with next-step fixes.

Required execution order:

1. Inspect workspace and source paths.
2. Create the VM compatibility layer.
3. Make VM accessible from iTerm2.
4. Mount/share project folders.
5. Install openage dependencies.
6. Configure/build openage inside VM.
7. Launch or minimally validate runtime.
8. Expose logs/control back to macOS.
9. Create `agectl` CLI gateway.
10. Create local event bus.
11. Adapt Agents of Chaos architecture from `/Users/dylanckawalec/Desktop/developer/aoc/`.
12. Remove old model/controller assumptions.
13. Replace agent reasoning harness with QGoT from `/Users/dylanckawalec/Desktop/developer/QGoT/`.
14. Represent agents as RTS units.
15. Expose state and control to `/Users/dylanckawalec/Desktop/developer/opseeq/`.

Primary deliverables:

- `infra/vm/`
- `tools/agectl/`
- `docs/build/`
- `docs/security/`
- `config/`
- `state/`
- `agent_runtime/`
- `bridges/qgot/`
- `bridges/opseeq/`
- `FINAL_STATUS.md`

Mandatory VM deliverables:

```txt
infra/vm/
├── README.md
├── setup_vm.md
├── bootstrap_vm.sh
├── install_openage_deps.sh
├── run_engine.sh
├── expose_to_macos.sh
├── healthcheck.sh
├── vm.env.example
└── TROUBLESHOOTING.md
```

Mandatory CLI commands:

```bash
agectl vm start
agectl vm stop
agectl vm status
agectl vm shell
agectl deps install
agectl build configure
agectl build compile
agectl build status
agectl run
agectl stop
agectl logs
agectl agents list
agectl agents spawn <agent_type>
agectl agents pause <agent_id>
agectl agents resume <agent_id>
agectl agents kill <agent_id>
agectl quest create "<description>"
agectl quest assign <quest_id> <agent_id>
agectl quest status
agectl bridge qgot status
agectl bridge qgot test
agectl bridge opseeq status
agectl bridge opseeq test
```

Core game transformation mapping:

```txt
RTS Map             = monorepo/repo/folder/service topology
Units               = AI coding subagents
Villagers           = worker agents
Scouts              = discovery/research agents
Monks               = reasoning/memory agents
Military units      = specialist implementation/review/debug agents
Buildings           = repos/modules/packages/services
Town Center         = main orchestrator / opseeq bridge
Castle              = QGoT command citadel
Resources           = CPU, RAM, context, tokens, files, tools
Tech tree           = agent/model/tool capability upgrades
Ages                = protocol/system evolution phases
Fog of war          = unknown or unanalyzed code territory
Campaigns           = long-running engineering epics
Quests              = tasks/issues/prompts/missions
Combat              = tests, regressions, merge conflicts
Victory             = passing tests, merged PR, completed epic
Hall of Heroes      = persistent agent legacy archive
```

Rules:

- Do not hallucinate missing files.
- Do not hide build failures.
- Do not skip VM healthchecks.
- Do not proceed as though a broken layer works.
- Every subsystem must have a README.
- Every failure must be logged with exact command and exact error.
- Every major decision must be documented.
- Prefer simple durable local state first: SQLite, JSONL, or local files.
- Prefer local-first models and infrastructure.
- Cloud providers must be optional and disabled by default.
- Every magical RTS metaphor must map to a real agent-control function.

Start with **Day 1 — Runtime Foundation**.

Your first response/action must produce:

1. workspace inspection summary
2. VM strategy recommendation for macOS M2
3. directory structure to create
4. first shell commands to run
5. initial risk register
6. validation criteria before moving to Day 2

Then execute step by step, validating each phase before moving forward.

The Age of Agents begins now.
Build the substrate first.
Then build the empire.
```

---

# Part XXI — Immediate First Commands

The first executor should begin with:

```bash
cd /Users/dylanckawalec/Desktop/developer

pwd
ls -la

test -d ./QGoT && echo "QGoT exists" || echo "QGoT missing"
test -d ./opseeq && echo "opseeq exists" || echo "opseeq missing"
test -d ./aoc && echo "aoc exists" || echo "aoc missing"
test -d ./openage-ageofagents && echo "openage-ageofagents exists" || echo "openage-ageofagents missing"

mkdir -p openage-ageofagents
mkdir -p openage-ageofagents/infra/vm
mkdir -p openage-ageofagents/tools/agectl
mkdir -p openage-ageofagents/docs/build
mkdir -p openage-ageofagents/docs/security
mkdir -p openage-ageofagents/config
mkdir -p openage-ageofagents/state
mkdir -p openage-ageofagents/logs/{vm,build,runtime,agents,qgot,opseeq}
mkdir -p openage-ageofagents/bridges/{qgot,opseeq}
mkdir -p openage-ageofagents/agent_runtime
```

Then inspect and decide whether to clone or merge the openage fork into the working path:

```bash
cd /Users/dylanckawalec/Desktop/developer

if [ ! -d openage-ageofagents/.git ]; then
  git clone https://github.com/DylanCkawalec/openage openage-ageofagents
else
  cd openage-ageofagents
  git status
  git remote -v
fi
```

---

# Part XXII — Initial Risk Register

| Risk | Severity | Mitigation |
|---|---:|---|
| openage build fails on macOS native | High | Treat VM as required runtime path |
| Apple Silicon VM graphics/display issues | High | Separate build validation from runtime/display validation; document display strategy |
| nyan dependency mismatch | Medium | Use documented download/build path and pin versions |
| Qt dependency complexity | High | Dependency matrix and healthcheck |
| Agents of Chaos architecture incompatible with QGoT | Medium | Adapter layer, not direct rewrite first |
| opseeq expectations unclear | Medium | Define bridge contract before implementation |
| Agents executing unsafe commands | High | Sandbox, allowlists, audit logs, rollbackable worktrees |
| Scope explosion into game design before runtime works | High | Enforce phase gates |
| Missing reference docs | Medium | Create `MISSING_DOCS.md`, do not hallucinate |
| GUI-only system unusable by agents | High | Require `agectl` and event bus |

---

# Part XXIII — Definition of Day 1 Done

Day 1 is done only when:

- workspace paths are inspected
- missing paths are documented
- VM strategy is chosen
- `infra/vm/` exists
- initial VM docs exist
- healthcheck scaffold exists
- build docs folder exists
- `agectl` scaffold exists
- initial risk register exists
- next commands for Day 2 are written

Do not proceed to Day 2 until this is true.
