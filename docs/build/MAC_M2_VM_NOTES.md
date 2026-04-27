# macOS M2 VM Notes

- Native macOS runtime is not treated as the primary path.
- ARM64 Linux VM is the compatibility baseline.
- Lima is selected for CLI-first automation and iTerm2 access.
- OrbStack is validated as a Linux container fallback for configure/build/non-GUI runtime smoke.
- Native macOS is validated for configure/build/non-GUI runtime smoke after installing Homebrew dependencies, `eigen@3`, and a project-local Python 3.12 virtualenv.
- UTM remains fallback for full GUI/runtime display troubleshooting if Lima or native display launch is blocked.
