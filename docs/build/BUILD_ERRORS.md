# Build Errors

Use this file to record reproducible failures.

## Format

- Command:
- Error:
- Log file:
- Likely root cause:
- Next step fix:

## 2026-04-27T02:18:11Z Lima image download did not complete

- Command: `./tools/agectl/agectl vm start`
- Error: Lima printed `Downloading the image (ubuntu-24.04-server-cloudimg-arm64.img)` and did not complete before interruption.
- Log file: `logs/vm/bootstrap.log`
- Observed cache state: `/Users/dylanckawalec/Library/Caches/lima/download/by-url-sha256/002fbe468673695a2206b26723b1a077a71629001a5b94efd8ea1580e1c3dd06/` contained `data.tmp.*` partial downloads smaller than the expected `Content-Length: 626031616`.
- Likely root cause: interrupted or stalled Lima cloud-image download left partial temp files.
- Next step fix: quarantine the partial `data.tmp.*` files, retry `./tools/agectl/agectl vm start`, then validate with `./infra/vm/healthcheck.sh`.

## 2026-04-27T03:41:40Z native macOS dependency install failed

- Command: `infra/macos/install_deps.sh`
- Error: Homebrew Python `3.14` pip failed importing `pyexpat` with missing symbol `_XML_SetAllocTrackerActivationThreshold`.
- Log file: `logs/build/macos-deps-install.log`
- Likely root cause: Python loaded an expat library that did not expose the required symbol.
- Next step fix: use Homebrew Python `3.12`, upgrade Homebrew `expat`, and export `DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib`.

## 2026-04-27T03:51:38Z native macOS dependency install failed

- Command: `infra/macos/install_deps.sh`
- Error: Homebrew Python `3.12.13_1` pip failed importing `pyexpat` with missing symbol `_XML_SetAllocTrackerActivationThreshold`.
- Log file: `logs/build/macos-deps-install.log`
- Likely root cause: Homebrew `expat` was older than the symbol expected by Python's `pyexpat` extension.
- Next step fix: upgrade `expat` and run Python/pip with `DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib`.

## 2026-04-27T03:54:34Z native macOS dependency install failed

- Command: `infra/macos/install_deps.sh`
- Error: pip could not uninstall Homebrew-managed `numpy 2.3.2` because no `RECORD` file existed.
- Log file: `logs/build/macos-deps-install.log`
- Likely root cause: pip package installation was targeting Homebrew site-packages directly.
- Next step fix: isolate Python build packages in `state/macos/venv`.

## 2026-04-27T04:00:34Z native macOS openage configure failed

- Command: `infra/macos/build_openage.sh configure`
- Error: CMake rejected Homebrew `eigen 5.0.1` for `find_package(Eigen3 3.3)`.
- Log file: `logs/runtime/macos-openage.log`
- Likely root cause: the default Homebrew `eigen` package is too new for openage's requested Eigen3 compatibility range.
- Next step fix: install Homebrew `eigen@3` and configure with `-DEigen3_DIR=/opt/homebrew/opt/eigen@3/share/eigen3/cmake`.

## 2026-04-27T04:14:51Z OrbStack openage run failed

- Command: `infra/orbstack/run_openage.sh run`
- Error: the generated container shell command had `; test -x ./bin/run` after a multiline symlink guard, producing `syntax error near unexpected token ';'`.
- Log file: `logs/runtime/orbstack-openage.log`
- Likely root cause: scripting bug in the OrbStack build-dir symlink guard.
- Next step fix: convert the guard to a single-line shell command. Fixed and validated by running `./tools/agectl/agectl orbstack run` followed by `./tools/agectl/agectl native run`.
