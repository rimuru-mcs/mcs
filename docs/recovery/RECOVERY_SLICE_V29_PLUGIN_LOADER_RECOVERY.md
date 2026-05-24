# MSR Recovery Slice v29 — Plugin Loader / LoadMysql Recovery

## Purpose

Restore the runtime plugin loader so quest/progression scripts can call:

- `plugin::LoadMysql()`
- `plugin::LoadMysqlServer()`

The recovered runtime has `plugins/MySQL.pl`, but the existing `plugins/plugin.pl`
only loaded `quests/plugins`, so `cata_progression_utils.pl` crashed during
`EVENT_CLICKDOOR` with:

```text
Undefined subroutine &plugin::LoadMysql called at ./plugins/cata_progression_utils.pl line 607
```

That broke zonelines and left clients in safe-spot / immobile states.

## Files

- `plugins/plugin.pl`
- `apply_recovery_slice_v29_plugin_loader_recovery.sh`
- `recovery/verify_recovery_slice_v29_plugin_loader_recovery.py`

## Apply

```bash
bash apply_recovery_slice_v29_plugin_loader_recovery.sh /opt/msr/server
python3 recovery/verify_recovery_slice_v29_plugin_loader_recovery.py /opt/msr/server/plugins/plugin.pl
```

Then restart world/zones.

## Notes

This is a runtime/plugin fix, not a database migration. It is intended to keep
legacy plugin behavior permissive while loading both `plugins/` and
`quests/plugins/` when present.
