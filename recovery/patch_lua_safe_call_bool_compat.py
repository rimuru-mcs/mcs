#!/usr/bin/env python3
from pathlib import Path

path = Path('zone/lua_client.cpp')
if not path.exists():
    raise SystemExit(f'Missing expected file: {path}')

text = path.read_text(encoding='utf-8', errors='replace')
old = 'Lua_Safe_Call_Bool(false);'
new = 'Lua_Safe_Call_Bool();'

if old not in text:
    if new in text:
        print('lua_client.cpp already uses Lua_Safe_Call_Bool() with no arguments.')
        raise SystemExit(0)
    raise SystemExit('Could not find expected Lua_Safe_Call_Bool(false); call in zone/lua_client.cpp')

count = text.count(old)
if count != 1:
    raise SystemExit(f'Expected exactly one {old!r} occurrence, found {count}')

path.write_text(text.replace(old, new), encoding='utf-8')
print('Patched zone/lua_client.cpp: Lua_Safe_Call_Bool(false) -> Lua_Safe_Call_Bool()')
