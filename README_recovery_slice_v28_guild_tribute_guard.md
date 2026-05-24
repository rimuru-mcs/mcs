# MSR Recovery Slice v28 — Guild Tribute Zone-entry Crash Guard

## Purpose

GDB identified the zone-entry crash in:

```text
Client::SendGuildTributes()
__strcpy_chk(... src="Aura of Preservation", destlen=0)
*** buffer overflow detected ***
```

This slice adds a temporary recovery guard at the start of `Client::SendGuildTributes()` so players can test entering world while we isolate the proper packet/client-struct fix.

This is a diagnostic/stabilization guard, not the final guild tribute implementation.

## Apply

```bash
cd /opt/msr/repo/msr
bash /path/to/apply_recovery_slice_v28_guild_tribute_guard.sh /opt/msr/repo/msr
python3 recovery/verify_recovery_slice_v28_guild_tribute_guard.py
```

If the verify script is not copied into `recovery/` automatically by your extraction process, copy it there first:

```bash
cp /path/to/verify_recovery_slice_v28_guild_tribute_guard.py /opt/msr/repo/msr/recovery/
```

## Build

```bash
cd /opt/msr/repo/msr
cmake --build build/linux-release --target zone -j"$(nproc)"
```

If the explicit target fails:

```bash
cmake --build build/linux-release -j"$(nproc)"
```

## Deploy

```bash
pkill -f 'eqlaunch' || true
pkill -f '/zone' || true
sleep 2

cp /opt/msr/repo/msr/build/linux-release/bin/zone /opt/msr/server/bin/zone.new
chmod +x /opt/msr/server/bin/zone.new
mv -f /opt/msr/server/bin/zone.new /opt/msr/server/bin/zone
```

## Test

Start zones again from `/opt/msr/server`, then attempt to enter world.

If the character enters world, the crash is confirmed as guild tribute packet/struct compatibility and the permanent fix should inspect `zone/tribute.cpp` plus the RoF/NMS patch struct definitions.
