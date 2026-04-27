#!/usr/bin/env python3
"""Local durable event bus for AgeOfAgents."""

from __future__ import annotations

import argparse
import json
import re
import sqlite3
import sys
import time
import uuid
from dataclasses import asdict, dataclass
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


SCHEMA_VERSION = 1
EVENT_TYPE_PATTERN = re.compile(r"^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$")

KNOWN_EVENT_TYPES = {
    "agent.spawned",
    "agent.started",
    "agent.paused",
    "agent.resumed",
    "agent.blocked",
    "agent.failed",
    "agent.completed",
    "agent.message",
    "agent.terminal.output",
    "agent.memory.updated",
    "quest.created",
    "quest.assigned",
    "quest.started",
    "quest.blocked",
    "quest.completed",
    "quest.failed",
    "game.unit.selected",
    "game.unit.commanded",
    "game.unit.spawned",
    "game.unit.destroyed",
    "game.building.created",
    "game.resource.updated",
    "game.fog.revealed",
    "game.quest.created",
    "game.quest.assigned",
    "game.quest.completed",
    "game.quest.failed",
    "qgot.session.created",
    "qgot.plan.created",
    "qgot.plan.updated",
    "qgot.reasoning.completed",
    "opseeq.connected",
    "opseeq.command.received",
    "opseeq.dashboard.updated",
    "system.healthcheck.passed",
    "system.healthcheck.failed",
    "system.error",
    "runtime.started",
    "runtime.stopped",
    "runtime.log",
    "build.configure.started",
    "build.configure.completed",
    "build.configure.failed",
    "build.compile.started",
    "build.compile.completed",
    "build.compile.failed",
}


@dataclass(frozen=True)
class Event:
    event_id: str
    timestamp: str
    type: str
    source: str
    actor: str | None
    correlation_id: str | None
    payload: dict[str, Any]
    known_type: bool
    schema_version: int = SCHEMA_VERSION


class EventBus:
    def __init__(self, repo_root: Path) -> None:
        self.repo_root = repo_root
        self.state_dir = repo_root / "state"
        self.events_jsonl = self.state_dir / "events.jsonl"
        self.sqlite_path = self.state_dir / "ageofagents.sqlite"

    def init(self) -> None:
        self.state_dir.mkdir(parents=True, exist_ok=True)
        for subdir in ("agents", "quests", "qgot", "opseeq"):
            (self.state_dir / subdir).mkdir(parents=True, exist_ok=True)
        self.events_jsonl.touch(exist_ok=True)
        with self._connect() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS events (
                    event_id TEXT PRIMARY KEY,
                    timestamp TEXT NOT NULL,
                    type TEXT NOT NULL,
                    source TEXT NOT NULL,
                    actor TEXT,
                    correlation_id TEXT,
                    payload_json TEXT NOT NULL,
                    event_json TEXT NOT NULL,
                    known_type INTEGER NOT NULL,
                    schema_version INTEGER NOT NULL
                )
                """
            )
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp)"
            )
            conn.execute("CREATE INDEX IF NOT EXISTS idx_events_type ON events(type)")
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_events_correlation ON events(correlation_id)"
            )

    def emit(
        self,
        event_type: str,
        payload: dict[str, Any] | None = None,
        source: str = "agectl",
        actor: str | None = None,
        correlation_id: str | None = None,
        strict_type: bool = False,
    ) -> Event:
        self.init()
        event_type = event_type.strip()
        if not EVENT_TYPE_PATTERN.match(event_type):
            raise ValueError(
                f"invalid event type {event_type!r}; use dotted lowercase names like system.healthcheck.passed"
            )

        known_type = event_type in KNOWN_EVENT_TYPES
        if strict_type and not known_type:
            raise ValueError(f"unknown event type {event_type!r}")

        event = Event(
            event_id=str(uuid.uuid4()),
            timestamp=datetime.now(UTC).isoformat(timespec="milliseconds").replace(
                "+00:00", "Z"
            ),
            type=event_type,
            source=source,
            actor=actor,
            correlation_id=correlation_id,
            payload=payload or {},
            known_type=known_type,
        )
        self._persist(event)
        return event

    def list_events(
        self,
        limit: int,
        event_type: str | None = None,
        source: str | None = None,
        since: str | None = None,
    ) -> list[dict[str, Any]]:
        self.init()
        where: list[str] = []
        params: list[Any] = []
        if event_type:
            where.append("type = ?")
            params.append(event_type)
        if source:
            where.append("source = ?")
            params.append(source)
        if since:
            where.append("timestamp >= ?")
            params.append(since)

        query = "SELECT event_json FROM events"
        if where:
            query += " WHERE " + " AND ".join(where)
        query += " ORDER BY timestamp DESC LIMIT ?"
        params.append(limit)

        with self._connect() as conn:
            rows = conn.execute(query, params).fetchall()
        events = [json.loads(row[0]) for row in rows]
        events.reverse()
        return events

    def tail_events(
        self,
        lines: int,
        event_type: str | None = None,
        source: str | None = None,
    ) -> list[dict[str, Any]]:
        return self.list_events(limit=lines, event_type=event_type, source=source)

    def status(self) -> dict[str, Any]:
        self.init()
        with self._connect() as conn:
            event_count = conn.execute("SELECT COUNT(*) FROM events").fetchone()[0]
            last_row = conn.execute(
                "SELECT event_json FROM events ORDER BY timestamp DESC LIMIT 1"
            ).fetchone()

        return {
            "state_dir": str(self.state_dir),
            "events_jsonl": str(self.events_jsonl),
            "sqlite": str(self.sqlite_path),
            "event_count": event_count,
            "last_event": json.loads(last_row[0]) if last_row else None,
            "schema_version": SCHEMA_VERSION,
            "known_event_type_count": len(KNOWN_EVENT_TYPES),
        }

    def _connect(self) -> sqlite3.Connection:
        return sqlite3.connect(self.sqlite_path)

    def _persist(self, event: Event) -> None:
        event_dict = asdict(event)
        event_json = json.dumps(event_dict, sort_keys=True, separators=(",", ":"))
        payload_json = json.dumps(
            event.payload, sort_keys=True, separators=(",", ":")
        )

        with self._connect() as conn:
            conn.execute(
                """
                INSERT INTO events (
                    event_id,
                    timestamp,
                    type,
                    source,
                    actor,
                    correlation_id,
                    payload_json,
                    event_json,
                    known_type,
                    schema_version
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    event.event_id,
                    event.timestamp,
                    event.type,
                    event.source,
                    event.actor,
                    event.correlation_id,
                    payload_json,
                    event_json,
                    int(event.known_type),
                    event.schema_version,
                ),
            )

        with self.events_jsonl.open("a", encoding="utf-8") as handle:
            handle.write(event_json + "\n")


def repo_root_from_script() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_payload(value: str | None, payload_file: str | None) -> dict[str, Any]:
    if value and payload_file:
        raise ValueError("provide either inline payload JSON or --payload-file, not both")
    if payload_file:
        raw = Path(payload_file).read_text(encoding="utf-8")
    elif value:
        raw = value
    else:
        return {}

    parsed = json.loads(raw)
    if not isinstance(parsed, dict):
        raise ValueError("event payload must be a JSON object")
    return parsed


def print_events(events: list[dict[str, Any]], as_json: bool) -> None:
    for event in events:
        if as_json:
            print(json.dumps(event, sort_keys=True))
        else:
            payload = json.dumps(event["payload"], sort_keys=True)
            print(
                f"{event['timestamp']} {event['type']} "
                f"id={event['event_id']} source={event['source']} payload={payload}"
            )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="AgeOfAgents local event bus")
    parser.add_argument(
        "--repo-root",
        default=str(repo_root_from_script()),
        help="repository root containing state/",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("init", help="initialize event bus storage")

    status_parser = subparsers.add_parser("status", help="show event bus status")
    status_parser.add_argument("--json", action="store_true", help="print JSON")

    types_parser = subparsers.add_parser("types", help="list known event types")
    types_parser.add_argument("--json", action="store_true", help="print JSON")

    emit_parser = subparsers.add_parser("emit", help="emit an event")
    emit_parser.add_argument("type", help="event type, e.g. system.healthcheck.passed")
    emit_parser.add_argument("payload", nargs="?", help="payload JSON object")
    emit_parser.add_argument("--payload-file", help="read payload JSON from file")
    emit_parser.add_argument("--source", default="agectl", help="event source")
    emit_parser.add_argument("--actor", help="event actor")
    emit_parser.add_argument("--correlation-id", help="correlation id")
    emit_parser.add_argument(
        "--strict-type",
        action="store_true",
        help="reject event types outside the built-in AgeOfAgents event set",
    )
    emit_parser.add_argument("--quiet", action="store_true", help="print only event id")

    list_parser = subparsers.add_parser("list", help="list recent events")
    list_parser.add_argument("--limit", type=int, default=20, help="max events")
    list_parser.add_argument("--type", dest="event_type", help="filter by type")
    list_parser.add_argument("--source", help="filter by source")
    list_parser.add_argument("--since", help="minimum timestamp")
    list_parser.add_argument("--json", action="store_true", help="print JSON lines")

    tail_parser = subparsers.add_parser("tail", help="tail recent events")
    tail_parser.add_argument("--lines", type=int, default=20, help="number of lines")
    tail_parser.add_argument("--type", dest="event_type", help="filter by type")
    tail_parser.add_argument("--source", help="filter by source")
    tail_parser.add_argument("--json", action="store_true", help="print JSON lines")
    tail_parser.add_argument(
        "--follow", "-f", action="store_true", help="follow events"
    )
    tail_parser.add_argument(
        "--interval", type=float, default=1.0, help="follow poll interval"
    )

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    bus = EventBus(Path(args.repo_root))

    try:
        if args.command == "init":
            bus.init()
            print(f"initialized event bus at {bus.state_dir}")
            return 0

        if args.command == "status":
            status = bus.status()
            if args.json:
                print(json.dumps(status, sort_keys=True))
            else:
                print(f"state_dir={status['state_dir']}")
                print(f"events_jsonl={status['events_jsonl']}")
                print(f"sqlite={status['sqlite']}")
                print(f"event_count={status['event_count']}")
                print(f"schema_version={status['schema_version']}")
                if status["last_event"]:
                    last = status["last_event"]
                    print(
                        f"last_event={last['timestamp']} {last['type']} {last['event_id']}"
                    )
            return 0

        if args.command == "types":
            types = sorted(KNOWN_EVENT_TYPES)
            if args.json:
                print(json.dumps(types))
            else:
                print("\n".join(types))
            return 0

        if args.command == "emit":
            payload = parse_payload(args.payload, args.payload_file)
            event = bus.emit(
                args.type,
                payload=payload,
                source=args.source,
                actor=args.actor,
                correlation_id=args.correlation_id,
                strict_type=args.strict_type,
            )
            if args.quiet:
                print(event.event_id)
            else:
                print(json.dumps(asdict(event), sort_keys=True))
            return 0

        if args.command == "list":
            events = bus.list_events(
                limit=max(1, args.limit),
                event_type=args.event_type,
                source=args.source,
                since=args.since,
            )
            print_events(events, args.json)
            return 0

        if args.command == "tail":
            seen: set[str] = set()
            while True:
                events = bus.tail_events(
                    lines=max(1, args.lines),
                    event_type=args.event_type,
                    source=args.source,
                )
                new_events = [
                    event for event in events if event["event_id"] not in seen
                ]
                print_events(new_events, args.json)
                for event in new_events:
                    seen.add(event["event_id"])
                if not args.follow:
                    return 0
                sys.stdout.flush()
                time.sleep(args.interval)

    except (json.JSONDecodeError, OSError, sqlite3.Error, ValueError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    parser.error(f"unhandled command {args.command}")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
