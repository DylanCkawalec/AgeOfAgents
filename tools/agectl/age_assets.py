#!/usr/bin/env python3
"""AgeOfAgents asset source and converted modpack checks."""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import sys
from typing import Any

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - Python < 3.11 fallback
    import toml as tomllib  # type: ignore


SOURCE_MARKERS = (
    "resources/_common/dat/empires2_x2_p1.dat",
    "resources/_common/dat/empires2_x1_p1.dat",
    "resources/_common/dat/empires.dat",
    "resources/_common/drs/graphics.drs",
    "resources/_common/drs/interfac.drs",
    "AGE2_X1/Data/empires2_x1_p1.dat",
    "age2_x1/Data/empires2_x1_p1.dat",
    "Data/empires2_x1_p1.dat",
    "Data/empires.dat",
    "gamedata/empires.dat",
)


def repo_root(path: str | None) -> Path:
    if path:
        return Path(path).expanduser().resolve()
    return Path(__file__).resolve().parents[2]


def asset_dir(root: Path) -> Path:
    return root / "assets"


def converted_dir(root: Path) -> Path:
    return asset_dir(root) / "converted"


def load_toml(path: Path) -> dict[str, Any]:
    with path.open("rb") as fileobj:
        return tomllib.load(fileobj)


def enumerate_modpacks(root: Path) -> list[dict[str, str]]:
    modpacks: list[dict[str, str]] = []
    converted = converted_dir(root)
    if not converted.is_dir():
        return modpacks

    for candidate in sorted(converted.iterdir()):
        if not candidate.is_dir():
            continue

        modpack_file = candidate / "modpack.toml"
        if not modpack_file.is_file():
            continue

        try:
            data = load_toml(modpack_file)
        except Exception:
            continue

        info = data.get("info", {})
        name = str(info.get("name") or info.get("packagename") or candidate.name)
        version = str(info.get("version") or "unknown")
        repo = str(info.get("repo") or "local")
        modpacks.append({
            "name": name,
            "version": version,
            "repo": repo,
            "path": str(candidate),
            "playable": "no" if name == "engine" else "yes",
        })

    return modpacks


def playable_modpacks(root: Path) -> list[dict[str, str]]:
    return [modpack for modpack in enumerate_modpacks(root) if modpack["name"] != "engine"]


def common_source_candidates() -> list[Path]:
    home = Path.home()
    return [
        home / "Library/Application Support/Steam/steamapps/common/Age2HD",
        home / "Library/Application Support/Steam/steamapps/common/Age of Empires II Definitive Edition",
        home / "Library/Application Support/Steam/steamapps/common/AoE2DE",
        home / "Library/Application Support/Steam/steamapps/common/Age of Empires II",
        home / "Library/Application Support/Steam/steamapps/common/Age of Empires 2",
        home / "Library/Application Support/Steam/steamapps/common/Age of Empires II HD",
        home / ".steam/steam/steamapps/common/Age2HD",
        home / ".steam/steam/steamapps/common/Age of Empires II Definitive Edition",
    ]


def marker_hits(source: Path) -> list[str]:
    if not source.is_dir():
        return []
    hits = []
    for marker in SOURCE_MARKERS:
        if (source / marker).is_file():
            hits.append(marker)
    return hits


def validate_source_path(source: Path) -> tuple[bool, list[str]]:
    source = source.expanduser()
    if not source.exists():
        return False, [f"path does not exist: {source}"]
    if not source.is_dir():
        return False, [f"path is not a directory: {source}"]

    hits = marker_hits(source)
    if hits:
        return True, hits

    return False, [
        "directory exists, but no known openage-supported game data markers were found",
        "pass the root install directory for Age of Empires II/HD/DE, Age of Empires I/RoR/DE, or SWGB",
    ]


def discover_sources() -> list[tuple[Path, bool, list[str]]]:
    env_source = os.environ.get("AGE_ASSET_SOURCE_DIR")
    candidates = []
    if env_source:
        candidates.append(Path(env_source).expanduser())
    candidates.extend(common_source_candidates())

    seen: set[Path] = set()
    discovered = []
    for candidate in candidates:
        candidate = candidate.expanduser()
        if candidate in seen:
            continue
        seen.add(candidate)
        valid, details = validate_source_path(candidate)
        if candidate.exists() or valid:
            discovered.append((candidate, valid, details))

    return discovered


def cmd_status(args: argparse.Namespace) -> int:
    root = repo_root(args.repo_root)
    modpacks = enumerate_modpacks(root)
    playable = [modpack for modpack in modpacks if modpack["name"] != "engine"]
    engine = [modpack for modpack in modpacks if modpack["name"] == "engine"]
    env_source = os.environ.get("AGE_ASSET_SOURCE_DIR", "")

    print(f"asset_dir={asset_dir(root)}")
    print(f"converted_dir={converted_dir(root)}")
    print(f"engine_modpack={'present' if engine else 'missing'}")
    print(f"converted_modpacks_count={len(modpacks)}")
    print("converted_modpacks=" + ",".join(f"{item['name']}@{item['version']}" for item in modpacks))
    print(f"playable_modpacks_count={len(playable)}")
    print("playable_modpacks=" + ",".join(f"{item['name']}@{item['version']}" for item in playable))
    print(f"AGE_ASSET_SOURCE_DIR={env_source}")

    if env_source:
        valid, details = validate_source_path(Path(env_source))
        print(f"asset_source_valid={'yes' if valid else 'no'}")
        print("asset_source_details=" + " | ".join(details))
    else:
        discovered = discover_sources()
        valid_sources = [str(path) for path, valid, _ in discovered if valid]
        print(f"discovered_source_count={len(valid_sources)}")
        print("discovered_sources=" + ",".join(valid_sources))

    return 0


def cmd_list(args: argparse.Namespace) -> int:
    root = repo_root(args.repo_root)
    modpacks = playable_modpacks(root) if args.playable else enumerate_modpacks(root)

    for modpack in modpacks:
        if args.names_only:
            print(modpack["name"])
        else:
            print(
                f"{modpack['name']} version={modpack['version']} "
                f"repo={modpack['repo']} playable={modpack['playable']} path={modpack['path']}"
            )

    return 0


def cmd_verify(args: argparse.Namespace) -> int:
    root = repo_root(args.repo_root)
    playable = playable_modpacks(root)
    if playable:
        print("PASS playable converted modpack(s): " + ", ".join(item["name"] for item in playable))
        return 0

    print("ERROR: no playable converted modpacks found in assets/converted", file=sys.stderr)
    print("Only the openage engine/API modpack is present or assets have not been converted.", file=sys.stderr)
    print("Set AGE_ASSET_SOURCE_DIR=/path/to/supported/game/install and run:", file=sys.stderr)
    print("  ./tools/agectl/agectl assets convert native", file=sys.stderr)
    return 1


def cmd_discover(args: argparse.Namespace) -> int:
    discovered = discover_sources()
    valid_count = 0
    for path, valid, details in discovered:
        if valid:
            valid_count += 1
        status = "valid" if valid else "present-but-unverified"
        print(f"{status}: {path}")
        for detail in details:
            print(f"  - {detail}")

    if valid_count == 0:
        print("No supported asset source was discovered automatically.")
        print("Set AGE_ASSET_SOURCE_DIR to a supported game installation root before conversion.")

    return 0 if valid_count > 0 or not args.require else 1


def cmd_validate_source(args: argparse.Namespace) -> int:
    source = Path(args.source_dir or os.environ.get("AGE_ASSET_SOURCE_DIR", ""))
    if not str(source):
        print("ERROR: AGE_ASSET_SOURCE_DIR is not set and no source directory was provided", file=sys.stderr)
        return 1

    valid, details = validate_source_path(source)
    if valid:
        print(f"PASS asset source: {source.expanduser()}")
        for detail in details:
            print(f"  - {detail}")
        return 0

    print(f"ERROR: invalid asset source: {source.expanduser()}", file=sys.stderr)
    for detail in details:
        print(f"  - {detail}", file=sys.stderr)
    return 1


STARTER_MODPACK_NAME = "ageofagents_base"
STARTER_MODPACK_VERSION = "0.1.0"
STARTER_MODPACK_README = (
    "# AgeOfAgents Starter Modpack\n\n"
    "This is a generated minimal modpack that satisfies openage's playable-modpack\n"
    "requirement so the engine can launch standalone without proprietary AoE assets.\n\n"
    "It is regenerated by `agectl assets bootstrap-starter` and is intentionally empty.\n"
    "Replace it with a real converted modpack once a supported game install is available.\n"
)
STARTER_MODPACK_TOML = (
    '# openage modpack definition file\n'
    '# generated by agectl assets bootstrap-starter\n'
    '\n'
    'file_version = "2"\n'
    '\n'
    '[info]\n'
    f'name = "{STARTER_MODPACK_NAME}"\n'
    f'version = "{STARTER_MODPACK_VERSION}"\n'
    f'versionstr = "{STARTER_MODPACK_VERSION}-starter"\n'
    'repo = "local"\n'
    'alias = "ageofagents_base"\n'
    'title = "AgeOfAgents Starter"\n'
    '\n'
    '[assets]\n'
    'include = [ "data/**" ]\n'
    'exclude = []\n'
    '\n'
    '[dependency]\n'
    'modpacks = []\n'
    '\n'
    '[conflict]\n'
    'modpacks = []\n'
    '\n'
    '[authors]\n'
    '\n'
    '[authorgroups]\n'
)


def starter_modpack_dir(root: Path) -> Path:
    return converted_dir(root) / STARTER_MODPACK_NAME


def bootstrap_starter(root: Path, force: bool = False) -> tuple[bool, str]:
    """
    Materialize the AgeOfAgents starter modpack on disk.

    Returns (created, message). Creates the modpack only when it is missing
    or when `force` is set.
    """
    converted = converted_dir(root)
    starter_dir = starter_modpack_dir(root)
    modpack_file = starter_dir / "modpack.toml"
    data_dir = starter_dir / "data"
    readme_file = starter_dir / "README.md"

    converted.mkdir(parents=True, exist_ok=True)

    if modpack_file.exists() and not force:
        return False, f"starter modpack already present at {starter_dir}"

    starter_dir.mkdir(parents=True, exist_ok=True)
    data_dir.mkdir(parents=True, exist_ok=True)
    modpack_file.write_text(STARTER_MODPACK_TOML, encoding="utf-8")
    if not readme_file.exists():
        readme_file.write_text(STARTER_MODPACK_README, encoding="utf-8")

    return True, f"starter modpack written to {starter_dir}"


def cmd_bootstrap_starter(args: argparse.Namespace) -> int:
    root = repo_root(args.repo_root)
    created, message = bootstrap_starter(root, force=args.force)
    if created:
        print(f"PASS bootstrap-starter: {message}")
    else:
        print(f"SKIP bootstrap-starter: {message}")
    return 0


def cmd_remove_starter(args: argparse.Namespace) -> int:
    root = repo_root(args.repo_root)
    starter_dir = starter_modpack_dir(root)
    if not starter_dir.exists():
        print(f"SKIP remove-starter: {starter_dir} does not exist")
        return 0

    import shutil

    shutil.rmtree(starter_dir)
    print(f"PASS remove-starter: removed {starter_dir}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="AgeOfAgents asset helper")
    parser.add_argument("--repo-root", default=None)
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("status").set_defaults(func=cmd_status)

    list_parser = subparsers.add_parser("list")
    list_parser.add_argument("--playable", action="store_true")
    list_parser.add_argument("--names-only", action="store_true")
    list_parser.set_defaults(func=cmd_list)

    subparsers.add_parser("verify").set_defaults(func=cmd_verify)

    discover_parser = subparsers.add_parser("discover")
    discover_parser.add_argument("--require", action="store_true")
    discover_parser.set_defaults(func=cmd_discover)

    validate_parser = subparsers.add_parser("validate-source")
    validate_parser.add_argument("source_dir", nargs="?")
    validate_parser.set_defaults(func=cmd_validate_source)

    bootstrap_parser = subparsers.add_parser("bootstrap-starter")
    bootstrap_parser.add_argument("--force", action="store_true")
    bootstrap_parser.set_defaults(func=cmd_bootstrap_starter)

    subparsers.add_parser("remove-starter").set_defaults(func=cmd_remove_starter)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
