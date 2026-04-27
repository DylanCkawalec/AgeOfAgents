# AgeOfAgents VM Layer

This folder defines the required Linux VM compatibility layer for AgeOfAgents on Apple Silicon.

## Goal

Provide a reproducible, iTerm2-accessible ARM64 Linux environment that can:

- build `openage`
- run or minimally validate the engine runtime path
- expose logs and control back to macOS

## Strategy

- Primary: Lima VM (`limactl`) on macOS M2.
- Fallback: UTM Ubuntu ARM64 VM if graphics/runtime validation blocks on Lima.

## Deliverables in this folder

- `setup_vm.md`: operator runbook
- `bootstrap_vm.sh`: installs/starts Lima instance
- `install_openage_deps.sh`: dependency install inside VM
- `run_engine.sh`: configure/build/run validation commands
- `expose_to_macos.sh`: host-visible log and control setup
- `healthcheck.sh`: Day 2 validation gate
- `vm.env.example`: configurable variables
- `TROUBLESHOOTING.md`: known failure modes and next actions

## Runtime gate

No game features or orchestration features should begin until:

1. VM boot is validated.
2. Host shell access into VM is validated.
3. Shared mount to host workspace is validated.
4. Openage configure/build path is validated or a reproducible failure is documented.
