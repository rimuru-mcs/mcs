#!/usr/bin/env python3
"""Audit MSR source code for the permanent/global server buff runtime path.

This script is read-only. It scans the repository for references that would be
needed before enabling Custom:PermanentServerBuffsEnabled at runtime.
"""

from __future__ import annotations

import json
import re
from collections import defaultdict
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
SCRIPT_NAME = "audit_global_buff_runtime_code.py"
OUTPUT_DIR = ROOT / "database" / "recovery" / "code_audit_output"
TEXT_OUTPUT = OUTPUT_DIR / "global_buff_runtime_code_audit.txt"
JSON_OUTPUT = OUTPUT_DIR / "global_buff_runtime_code_audit.json"

EXCLUDED_DIRS = {
    ".git",
    ".vs",
    ".vscode",
    "build",
    "bin",
    "obj",
    "perl",
    "vcpkg",
    "client_patches",
    "audit_output",
    "code_audit_output",
    "__pycache__",
}

SOURCE_SUFFIXES = {
    ".c",
    ".cc",
    ".cpp",
    ".cxx",
    ".h",
    ".hh",
    ".hpp",
    ".hxx",
    ".lua",
    ".pl",
    ".pm",
    ".quest",
    ".inc",
    ".sql",
    ".md",
    ".txt",
}

PATTERNS = {
    "custom_rule_exact": r"Custom:PermanentServerBuffsEnabled",
    "custom_rule_symbol": r"PermanentServerBuffsEnabled",
    "global_buff_ids": r"\b4400[0-7]\b",
    "echo_spell_names": r"Echo of (Experience|Power|Statistics|Speed|Mana|Haste|Health|Luck)",
    "global_or_permanent_buff_words": r"(?i)\b(global|permanent|server)\w*\s*buff\w*\b|\bbuff\w*\s*(global|permanent|server)\w*\b",
    "luck_hooks": r"(?i)Echo of Luck|Power Source|PowerSource|inventory upgrade|loot upgrade|Upgrade.*Loot|Loot.*Upgrade",
    "cast_candidates": r"\b(SpellFinished|CastSpell|BuffFade|BuffProcess|Apply.*Buff|Add.*Buff|MakeBuffsPacket|SendBuffs)\b",
}

MAX_MATCHES_PER_PATTERN = 300
MAX_LINE_LENGTH = 500


@dataclass
class MatchRecord:
    pattern: str
    path: str
    line: int
    text: str


def iter_source_files(root: Path) -> Iterable[Path]:
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        rel_parts = path.relative_to(root).parts
        if any(part in EXCLUDED_DIRS for part in rel_parts):
            continue
        if path.suffix.lower() not in SOURCE_SUFFIXES:
            continue
        yield path


def read_text_safely(path: Path) -> str | None:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None


def main() -> int:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    compiled = {name: re.compile(pattern) for name, pattern in PATTERNS.items()}
    matches: dict[str, list[MatchRecord]] = defaultdict(list)
    scanned_files = 0
    scanned_lines = 0

    for path in iter_source_files(ROOT):
        text = read_text_safely(path)
        if text is None:
            continue
        scanned_files += 1
        rel = path.relative_to(ROOT).as_posix()
        for line_number, line in enumerate(text.splitlines(), start=1):
            scanned_lines += 1
            compact = line.strip()
            if len(compact) > MAX_LINE_LENGTH:
                compact = compact[:MAX_LINE_LENGTH] + "..."
            for name, pattern in compiled.items():
                if len(matches[name]) >= MAX_MATCHES_PER_PATTERN:
                    continue
                if pattern.search(line):
                    matches[name].append(MatchRecord(name, rel, line_number, compact))

    summary = {
        "audited_at": datetime.now(timezone.utc).isoformat(),
        "root": str(ROOT),
        "scanned_files": scanned_files,
        "scanned_lines": scanned_lines,
        "pattern_counts": {name: len(records) for name, records in matches.items()},
        "readiness": {
            "custom_rule_reference_found": bool(matches.get("custom_rule_exact") or matches.get("custom_rule_symbol")),
            "global_buff_id_reference_found": bool(matches.get("global_buff_ids")),
            "echo_spell_name_reference_found": bool(matches.get("echo_spell_names")),
            "candidate_buff_runtime_references_found": bool(matches.get("global_or_permanent_buff_words") or matches.get("cast_candidates")),
            "luck_hook_reference_found": bool(matches.get("luck_hooks")),
        },
        "matches": {
            name: [asdict(record) for record in records]
            for name, records in sorted(matches.items())
        },
    }

    readiness = summary["readiness"]
    if not readiness["custom_rule_reference_found"]:
        conclusion = (
            "No direct source reference to Custom:PermanentServerBuffsEnabled was found. "
            "Do not enable the DB rule until the runtime buff application path is implemented or located."
        )
    elif not readiness["global_buff_id_reference_found"] and not readiness["echo_spell_name_reference_found"]:
        conclusion = (
            "A rule-like reference may exist, but no direct references to spell IDs 44000-44007 "
            "or Echo spell names were found. Runtime activation still needs code verification."
        )
    else:
        conclusion = (
            "Potential runtime references were found. Review the match list manually before enabling buffs."
        )
    summary["conclusion"] = conclusion

    JSON_OUTPUT.write_text(json.dumps(summary, indent=2, sort_keys=True), encoding="utf-8")

    lines: list[str] = []
    lines.append("MSR Global Buff Runtime Code Audit")
    lines.append(f"Script:     {SCRIPT_NAME}")
    lines.append("=================================")
    lines.append(f"Audited at: {summary['audited_at']}")
    lines.append(f"Root:       {summary['root']}")
    lines.append(f"Files:      {scanned_files}")
    lines.append(f"Lines:      {scanned_lines}")
    lines.append("")
    lines.append("Readiness")
    lines.append("---------")
    for key, value in readiness.items():
        lines.append(f"{key}: {value}")
    lines.append("")
    lines.append("Conclusion")
    lines.append("----------")
    lines.append(conclusion)
    lines.append("")
    lines.append("Pattern counts")
    lines.append("--------------")
    for name in sorted(PATTERNS):
        lines.append(f"{name}: {len(matches.get(name, []))}")
    lines.append("")

    for name in sorted(PATTERNS):
        records = matches.get(name, [])
        lines.append(f"Matches: {name}")
        lines.append("-" * (9 + len(name)))
        if not records:
            lines.append("(none)")
        else:
            for record in records:
                lines.append(f"{record.path}:{record.line}: {record.text}")
            if len(records) >= MAX_MATCHES_PER_PATTERN:
                lines.append(f"(truncated at {MAX_MATCHES_PER_PATTERN} matches)")
        lines.append("")

    TEXT_OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"Wrote {TEXT_OUTPUT.relative_to(ROOT)}")
    print(f"Wrote {JSON_OUTPUT.relative_to(ROOT)}")
    print(conclusion)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
