# Recovery Slice v27 — Start-zone recovery and progression-start doctrine

This slice fixes the immediate recovered-runtime blocker where new characters can be created but may be sent into revamped Freeport (`freeportwest` / zone 383) before that route is usable, producing client-side "That zone is unavailable" behavior.

## Why this slice exists

The recovered server now boots, accepts login, reaches server select, and creates characters. The next blocker is start-zone selection. A Human class-13 test character was routed to `freeportwest` / zone `383`, then the zone boot failed.

The live/community behavior described for MSR/THJ-style progression is more nuanced than "Classic only":

- Players start in their default racial cities or Crescent Reach.
- All races/classes are playable from the beginning, even if their origin expansion is not globally unlocked.
- Expansion-native races/classes receive limited starter/sanctuary access, not full expansion access.
- Iksar may use Cabilis plus nearby starter zones like Field of Bone and possibly Lake of Ill Omen, but not Firiona Vie, Emerald Jungle, or broad Kunark.
- Frogloks are special: MSR/THJ-style progression should not model the live Grobb takeover. Rathe Mountains is the likely starter solution unless DB/source truth proves otherwise.

## Files added

```text
database/recovery/audits/26_start_zone_progression_alignment_audit.sql
database/recovery/migrations_safe/110_gate_revamped_freeport_start_zones.sql
database/recovery/migrations_pending/180_review_expansion_race_start_envelopes.sql
recovery/verify_recovery_slice_v27.py
docs/recovery/RECOVERY_SLICE_V27_START_ZONE_RECOVERY.md
```

## Safe migration behavior

`110_gate_revamped_freeport_start_zones.sql`:

1. Backs up affected `start_zones` rows into `msr_recovery_start_zone_v27_backup`.
2. Gates revamped Freeport start rows behind the explicit content flag:

```text
msr_revamped_freeport_unlocked
```

This prevents early selection of unusable new-Freeport starts without deleting those rows.

## What this slice does not do

- Does not delete revamped Freeport zone data.
- Does not globally disable expansion-origin races/classes.
- Does not force Iksar/Vah Shir/Froglok/Drakkin into Classic human starts.
- Does not solve the full expansion starter-envelope model yet.
- Does not migrate existing player characters out of bad zones automatically.
- Does not touch item quality, Simple Ring of the Hero, Echo buffs, Bazaar item variants, or DLL/client-auth systems.

## Manual test-character rescue

If a dev/test character is already trapped in `freeportwest` / zone 383, move that character manually after applying this slice. Example for character `Rimuru`:

```sql
UPDATE character_data
SET zone_id = 9,
    x = -747,
    y = 146,
    z = 31.75
WHERE name = 'Rimuru'
  AND zone_id = 383;
```

Adjust the target city/coordinates for other race/class/deity tests.

## Post-apply testing checklist

1. Run `python3 recovery/verify_recovery_slice_v27.py`.
2. Run DB audit and confirm the v27 audit output exists.
3. Apply safe migration with `bash recovery/apply_db_migrations.sh`.
4. Restart world and zones.
5. Create a Human/class-13 test character again.
6. Confirm it no longer selects `freeportwest` / zone 383 during world entry.
7. Confirm default city or Crescent Reach behavior is preserved.
8. Later, audit expansion-race starts separately before opening the server.

## Future follow-up

The pending review file records the next design-safe DB pass:

```text
database/recovery/migrations_pending/180_review_expansion_race_start_envelopes.sql
```

That review should define exact starter envelopes for Iksar, Vah Shir, Froglok, Drakkin, and any custom race/class combinations without unlocking broad expansion progression or level caps.
