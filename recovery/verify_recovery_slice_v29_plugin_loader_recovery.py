#!/usr/bin/env python3
from pathlib import Path
import sys

path = Path("/opt/msr/server/plugins/plugin.pl")
if len(sys.argv) > 1:
    path = Path(sys.argv[1])

if not path.exists():
    raise SystemExit(f"plugin.pl not found: {path}")

text = path.read_text(errors="replace")
required = [
    "MSR Recovery v29 plugin loader",
    '"plugins"',
    '"quests/plugins"',
    "package plugin;",
    "plugin::LoadMysql",
    "LoadMysqlServer",
]
missing = [s for s in required if s not in text]
if missing:
    raise SystemExit(f"plugin loader verification failed; missing: {missing}")

print(f"MSR Recovery Slice v29 plugin loader verification passed: {path}")
