# VM Setup Runbook (macOS M2)

## 1) Prerequisites on macOS

- Homebrew installed
- `limactl` installed (`brew install lima`)
- `qemu` installed (`brew install qemu`)

## 2) Bootstrap VM

From repo root:

```bash
./infra/vm/bootstrap_vm.sh
```

This creates and starts a Lima instance named `ageofagents`.

## 3) Verify iTerm2 access to VM

```bash
limactl shell ageofagents -- uname -a
```

## 4) Verify shared mount

```bash
limactl shell ageofagents -- ls -la /mnt/developer
```

## 5) Install dependencies in VM

```bash
./infra/vm/install_openage_deps.sh
```

## 6) Validate configure/build path

```bash
./infra/vm/run_engine.sh
```

## 7) Healthcheck gate

```bash
./infra/vm/healthcheck.sh
```

Proceed to Day 2 only when the healthcheck passes or emits a reproducible failure with next-step fixes.
