# MSR Recovery Slice v27a — Crescent Start Hold

## Purpose

Slice v27 successfully gated revamped Freeport starts. After that, test character entry selected Crescent Reach:

- zone short name: `crescent`
- zone id: `394`

The zone booted, world sent the client to the dynamic zone port, and the client connected. The zone then crashed shortly after `SendAlternateAdvancementTable`, with a Linux buffer-overflow termination in the observed logs.

This slice temporarily gates Crescent Reach start rows so recovery testing can continue through default/racial city starts while the Crescent/AA-table crash is handled as a separate recovery item.

## Files

- `database/recovery/audits/27_crescent_start_and_zone_entry_audit.sql`
- `database/recovery/migrations_safe/111_gate_crescent_start_zones_for_recovery.sql`
- `database/recovery/migrations_pending/181_review_crescent_start_reenable_and_zone_crash.sql`
- `docs/recovery/RECOVERY_SLICE_V27A_CRESCENT_START_HOLD.md`
- `recovery/verify_recovery_slice_v27a.py`

## Safety

The safe migration:

1. Creates `msr_recovery_start_zones_crescent_backup_v27a`.
2. Copies affected Crescent start rows into that backup table.
3. Adds the content flag `msr_crescent_start_unlocked` to rows where `zone_id = 394` or `start_zone = 394`.

It does not delete rows and it does not move existing characters.

## Expected audit result after apply

`27_crescent_start_and_zone_entry_audit.sql` should report:

- `crescent_start_rows_total > 0`
- `gated_by_v27a_count = crescent_start_rows_total`
- `still_ungated_blank_content_flags_count = 0`

## Existing test characters

Existing characters already stored in Crescent Reach are not moved by this migration.

For a disposable test character, deleting/remaking is fine.

Manual rescue example:

```sql
UPDATE character_data
SET zone_id = 9,
    x = -747,
    y = 146,
    z = 31.75
WHERE name = 'Rimuru';
```

That places the character in old West Freeport.

## Notes

Live behavior may allow Crescent Reach starts. This slice is a recovery hold, not a final design decision. Crescent should be re-enabled only after the zone-entry crash is fixed and smoke-tested.
