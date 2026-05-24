#!/usr/bin/env python3
from pathlib import Path

checks = {
    'recovery/patch_lua_safe_call_bool_compat.py': 'Lua_Safe_Call_Bool(false)',
    'docs/recovery/RECOVERY_SLICE_V26_LINUX_LUA_SAFE_CALL_BOOL_COMPAT.md': 'Lua_Safe_Call_Bool()',
}

missing = []
for rel, needle in checks.items():
    path = Path(rel)
    if not path.exists():
        missing.append(f'missing file: {rel}')
        continue
    text = path.read_text(encoding='utf-8', errors='replace')
    if needle not in text:
        missing.append(f'{rel} missing required text: {needle}')

lua_client = Path('zone/lua_client.cpp')
if lua_client.exists():
    text = lua_client.read_text(encoding='utf-8', errors='replace')
    if 'Lua_Safe_Call_Bool(false);' in text:
        missing.append('zone/lua_client.cpp still contains Lua_Safe_Call_Bool(false); run recovery/patch_lua_safe_call_bool_compat.py')
    if 'bool Lua_Client::AddExtraClass' in text and 'Lua_Safe_Call_Bool();' not in text:
        missing.append('zone/lua_client.cpp AddExtraClass path does not appear to contain Lua_Safe_Call_Bool();')

if missing:
    print('Recovery Slice v26 verification failed:')
    for item in missing:
        print(f' - {item}')
    raise SystemExit(1)

print('Recovery Slice v26 verification passed.')
