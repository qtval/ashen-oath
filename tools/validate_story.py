#!/usr/bin/env python3
"""Validate Ashen Oath chapter JSON without requiring Godot."""

from __future__ import annotations

import json
import sys
from collections import Counter, deque
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CHAPTER_DIR = ROOT / "data" / "chapters"
START_NODES = {"chapter_01.json": "checkpoint_arrival"}


def error(errors: list[str], path: Path, message: str) -> None:
    errors.append(f"{path.relative_to(ROOT)}: {message}")


def validate_chapter(path: Path) -> list[str]:
    errors: list[str] = []
    try:
        document: Any = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        return [f"{path.relative_to(ROOT)}: cannot parse UTF-8 JSON: {exc}"]

    if not isinstance(document, dict):
        return [f"{path.relative_to(ROOT)}: root must be an object"]
    if not isinstance(document.get("chapter"), str) or not document["chapter"].strip():
        error(errors, path, "chapter must be a non-empty string")
    nodes = document.get("nodes")
    if not isinstance(nodes, list) or not nodes:
        error(errors, path, "nodes must be a non-empty array")
        return errors

    node_ids = [node.get("id") for node in nodes if isinstance(node, dict)]
    duplicate_ids = sorted(key for key, count in Counter(node_ids).items() if key and count > 1)
    if duplicate_ids:
        error(errors, path, f"duplicate node IDs: {', '.join(duplicate_ids)}")
    known_ids = {node_id for node_id in node_ids if isinstance(node_id, str)}
    graph: dict[str, set[str]] = {node_id: set() for node_id in known_ids}

    for index, node in enumerate(nodes):
        label = f"node #{index + 1}"
        if not isinstance(node, dict):
            error(errors, path, f"{label} must be an object")
            continue
        node_id = node.get("id")
        if not isinstance(node_id, str) or not node_id.strip():
            error(errors, path, f"{label} requires a non-empty string ID")
            continue
        label = f"node '{node_id}'"
        if not isinstance(node.get("text"), str):
            error(errors, path, f"{label} requires string text")
        choices = node.get("choices")
        if not isinstance(choices, list):
            error(errors, path, f"{label} choices must be an array")
            continue
        is_ending = "ending" in node
        if is_ending and choices:
            error(errors, path, f"{label} is an ending and cannot contain choices")
        if not is_ending and not choices:
            error(errors, path, f"{label} is a dead end without an ending")

        for choice_index, choice in enumerate(choices):
            choice_label = f"{label}, choice #{choice_index + 1}"
            if not isinstance(choice, dict):
                error(errors, path, f"{choice_label} must be an object")
                continue
            if not isinstance(choice.get("text"), str) or not choice["text"].strip():
                error(errors, path, f"{choice_label} requires non-empty text")
            target = choice.get("next")
            if not isinstance(target, str) or not target:
                error(errors, path, f"{choice_label} requires a target")
            elif target not in known_ids:
                error(errors, path, f"{choice_label} targets missing node '{target}'")
            else:
                graph[node_id].add(target)
            for field in ("effects", "requires"):
                if field in choice and not isinstance(choice[field], dict):
                    error(errors, path, f"{choice_label} {field} must be an object")

    start_id = START_NODES.get(path.name)
    if start_id is None:
        error(errors, path, "validator has no configured start node")
    elif start_id not in known_ids:
        error(errors, path, f"configured start node '{start_id}' is missing")
    else:
        reached: set[str] = set()
        queue = deque([start_id])
        while queue:
            current = queue.popleft()
            if current in reached:
                continue
            reached.add(current)
            queue.extend(graph.get(current, ()))
        unreachable = sorted(known_ids - reached)
        if unreachable:
            error(errors, path, f"unreachable nodes: {', '.join(unreachable)}")

    return errors


def main() -> int:
    chapters = sorted(CHAPTER_DIR.glob("*.json"))
    if not chapters:
        print("No chapter files found.", file=sys.stderr)
        return 1
    errors = [item for chapter in chapters for item in validate_chapter(chapter)]
    if errors:
        print("Story validation failed:", file=sys.stderr)
        for item in errors:
            print(f"- {item}", file=sys.stderr)
        return 1
    print(f"Story validation passed: {len(chapters)} chapter(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
