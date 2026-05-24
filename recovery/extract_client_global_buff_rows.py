#!/usr/bin/env python3
"""Extract MSR global buff spell rows from client spells_us.txt files.

This tool is read-only. It scans supplied patch ZIPs, unpacked directories, and
common MSR recovery locations for spells_us.txt files, then extracts rows with
spell IDs 44000-44007 plus nearby Echo-named rows.

Examples:
  python3 recovery/extract_client_global_buff_rows.py \
    --patch-zip /opt/msr/incoming/Multiclass-Patch_5-21-UPDATE-FILES.zip \
    --patch-zip /opt/msr/incoming/NMS_Client_Patch_5-23-2026.zip

  python3 recovery/extract_client_global_buff_rows.py
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import sys
import zipfile
from typing import Iterable, List, Dict, Tuple

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT_DIR = ROOT / "database" / "recovery" / "client_spell_extract"
TARGET_IDS = set(range(44000, 44008))


def iter_candidate_paths(extra_paths: Iterable[Path]) -> Iterable[Path]:
    seen = set()

    candidates = list(extra_paths)
    candidates.extend([
        ROOT / "client_patches",
        ROOT / "database" / "recovery",
        Path("/opt/msr/incoming"),
        Path("/opt/msr/client-patches"),
        Path("/opt/msr/db"),
    ])

    for candidate in candidates:
        if not candidate.exists():
            continue

        if candidate.is_file():
            key = candidate.resolve()
            if key not in seen:
                seen.add(key)
                yield candidate
            continue

        for pattern in ("**/spells_us.txt", "**/*.zip"):
            for path in candidate.glob(pattern):
                if path.is_file():
                    key = path.resolve()
                    if key not in seen:
                        seen.add(key)
                        yield path


def decode_bytes(data: bytes) -> str:
    for encoding in ("utf-8-sig", "cp1252", "latin-1"):
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            pass
    return data.decode("latin-1", errors="replace")


def should_capture(fields: List[str]) -> bool:
    if not fields:
        return False

    try:
        spell_id = int(fields[0])
    except ValueError:
        return False

    if spell_id in TARGET_IDS:
        return True

    name = fields[1] if len(fields) > 1 else ""
    return spell_id >= 43990 and spell_id <= 44020 and "Echo" in name


def parse_spell_text(source_label: str, text: str) -> List[Dict[str, object]]:
    rows: List[Dict[str, object]] = []
    for line_number, raw_line in enumerate(text.splitlines(), start=1):
        line = raw_line.rstrip("\r\n")
        if not line:
            continue

        fields = line.split("^")
        if not should_capture(fields):
            continue

        try:
            spell_id = int(fields[0])
        except ValueError:
            continue

        rows.append({
            "source": source_label,
            "line_number": line_number,
            "id": spell_id,
            "name": fields[1] if len(fields) > 1 else "",
            "field_count": len(fields),
            "raw": line,
        })
    return rows


def extract_from_zip(path: Path) -> List[Dict[str, object]]:
    rows: List[Dict[str, object]] = []
    with zipfile.ZipFile(path) as zf:
        for info in zf.infolist():
            if info.is_dir():
                continue
            if Path(info.filename).name.lower() != "spells_us.txt":
                continue
            data = zf.read(info)
            text = decode_bytes(data)
            rows.extend(parse_spell_text(f"{path.name}:{info.filename}", text))
    return rows


def extract_from_file(path: Path) -> List[Dict[str, object]]:
    data = path.read_bytes()
    text = decode_bytes(data)
    return parse_spell_text(str(path), text)


def write_outputs(rows: List[Dict[str, object]], output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)

    jsonl_path = output_dir / "global_buff_client_spell_rows.jsonl"
    tsv_path = output_dir / "global_buff_client_spell_rows.tsv"
    summary_path = output_dir / "global_buff_client_spell_rows_summary.txt"

    with jsonl_path.open("w", encoding="utf-8", newline="\n") as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=False, sort_keys=True) + "\n")

    with tsv_path.open("w", encoding="utf-8", newline="\n") as f:
        f.write("source\tline_number\tid\tname\tfield_count\traw\n")
        for row in rows:
            safe_raw = str(row["raw"]).replace("\t", "\\t")
            f.write(
                f"{row['source']}\t{row['line_number']}\t{row['id']}\t"
                f"{row['name']}\t{row['field_count']}\t{safe_raw}\n"
            )

    by_source: Dict[str, int] = {}
    by_id: Dict[int, int] = {}
    for row in rows:
        by_source[str(row["source"])] = by_source.get(str(row["source"]), 0) + 1
        by_id[int(row["id"])] = by_id.get(int(row["id"]), 0) + 1

    with summary_path.open("w", encoding="utf-8", newline="\n") as f:
        f.write("MSR client global buff spell row extraction\n")
        f.write(f"Rows extracted: {len(rows)}\n\n")
        f.write("Rows by source:\n")
        for source, count in sorted(by_source.items()):
            f.write(f"  {count:4d}  {source}\n")
        f.write("\nRows by spell id:\n")
        for spell_id, count in sorted(by_id.items()):
            f.write(f"  {spell_id}: {count}\n")

    print(f"Wrote: {jsonl_path}")
    print(f"Wrote: {tsv_path}")
    print(f"Wrote: {summary_path}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--patch-zip", action="append", default=[], help="Client patch ZIP to scan")
    parser.add_argument("--path", action="append", default=[], help="Additional file or directory to scan")
    parser.add_argument("--output-dir", default=str(DEFAULT_OUTPUT_DIR))
    args = parser.parse_args()

    extra_paths = [Path(p) for p in args.patch_zip + args.path]
    rows: List[Dict[str, object]] = []
    scanned: List[str] = []

    for path in iter_candidate_paths(extra_paths):
        try:
            if path.suffix.lower() == ".zip":
                extracted = extract_from_zip(path)
            elif path.name.lower() == "spells_us.txt":
                extracted = extract_from_file(path)
            else:
                continue
        except Exception as exc:  # keep scanning other files
            print(f"Warning: failed to scan {path}: {exc}", file=sys.stderr)
            continue

        if extracted:
            scanned.append(str(path))
            rows.extend(extracted)

    rows.sort(key=lambda row: (str(row["source"]), int(row["id"]), int(row["line_number"])))

    if not rows:
        print("No global buff spell rows found. Provide --patch-zip or --path if client patches are elsewhere.", file=sys.stderr)
        return 2

    write_outputs(rows, Path(args.output_dir))
    print(f"Scanned sources with matches: {len(scanned)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
