# Native macOS Build Helper
This folder provides a controlled secondary path for building openage directly on macOS.
## Scope
Native macOS is not the primary AgeOfAgents runtime path. Use it when Lima/OrbStack validation is blocked or when a local host build is explicitly desired.
## Commands
Check required tools and packages:
```bash
./infra/macos/check_deps.sh
```
Install documented dependencies:
```bash
./infra/macos/install_deps.sh
```
Configure, compile, and smoke-test:
```bash
./infra/macos/build_openage.sh configure
./infra/macos/build_openage.sh compile
./infra/macos/build_openage.sh run
```
## Logs
- Dependency check log: `logs/build/macos-deps.log`
- Build/runtime log: `logs/runtime/macos-openage.log`
- Reproducible failures: `docs/build/BUILD_ERRORS.md`
