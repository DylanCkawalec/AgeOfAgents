# VM Troubleshooting

## limactl missing

- Symptom: `limactl: command not found`
- Fix: `brew install lima`

## qemu missing

- Symptom: `qemu-system-aarch64: command not found`
- Fix: `brew install qemu`

## VM start fails on image pull

- Symptom: timeout or HTTP errors during `limactl start`
- Fix: retry with stable network, then inspect `logs/vm/bootstrap.log`
- If the log stops at `Downloading the image (...)`, inspect `/Users/dylanckawalec/Library/Caches/lima/download/` for `data.tmp.*` files smaller than the expected image `Content-Length`.
- Quarantine confirmed partial files before retrying; do not delete unknown cache files blindly.

## VM shell unavailable

- Symptom: `limactl shell ageofagents` fails
- Fix: `limactl start ageofagents`; if still failing run `limactl stop ageofagents && limactl start ageofagents`

## Mount missing inside VM

- Symptom: `/mnt/developer` absent
- Fix: recreate VM with valid host path and mount config in `bootstrap_vm.sh`

## openage configure fails

- Symptom: dependency or nyan errors
- Fix: rerun `install_openage_deps.sh`, capture exact command and exact error in `docs/build/BUILD_ERRORS.md`

## Qt/OpenGL runtime issues

- Symptom: build passes, runtime fails due to graphics
- Fix: document reproducible failure and switch runtime validation to UTM fallback while keeping Lima for build.
