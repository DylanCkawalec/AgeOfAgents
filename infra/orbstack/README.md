# OrbStack Fallback Runtime
This folder provides the fallback Linux build path for AgeOfAgents using OrbStack's Docker runtime.
## Scope
OrbStack is a fallback for proving the openage configure/build/runtime-smoke path when the Lima VM bootstrap is blocked. It is not considered the final GUI runtime path until display forwarding or a native window path is explicitly validated.
## Commands
Build the Ubuntu 24.04 development image:
```bash
./infra/orbstack/build_image.sh
```
Check Docker/OrbStack status:
```bash
./infra/orbstack/run_openage.sh status
```
Configure, compile, and smoke-test openage:
```bash
./infra/orbstack/run_openage.sh configure
./infra/orbstack/run_openage.sh compile
./infra/orbstack/run_openage.sh run
```
Run all three steps:
```bash
./infra/orbstack/run_openage.sh all
```
Open a shell in the container:
```bash
./infra/orbstack/run_openage.sh shell
```
## Logs
- Build image log: `logs/build/orbstack-image.log`
- Runtime/build command log: `logs/runtime/orbstack-openage.log`
- Reproducible failures: `docs/build/BUILD_ERRORS.md`
