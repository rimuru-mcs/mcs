# Recovery Slice v22 — Old-zone Nektulos/Lavastorm/Najena route recovery

This slice promotes the first targeted old-zone route recovery migration based on:

- MSR progression design: classic/old Nektulos and Lavastorm must remain active until the expansion unlocks their revamped versions.
- DB route audits from slices v18-v21.
- Client `/loc` validation in old Lavastorm/Nektulos/Najena.
- `old_zone_route_debug.tsv` route row extraction.

## Design rule

Do **not** globally remove or rewrite version-1/revamped zone data.

This server intentionally keeps both old and later zone versions because player progression starts in Classic and unlocks later expansion content by defeating raid bosses. Therefore this slice fixes the classic/version-0 route rows and the duplicate PoK stone entry that was forcing `dest_instance = 1`, while preserving version-1 zone rows for later expansion use.

## What this slice changes

Safe migration added:

```text
database/recovery/migrations_safe/100_fix_old_lavastorm_nektulos_najena_routes.sql
```

It backs up and updates these route families:

- Lavastorm v0 → Najena: move trigger off `0,0,0` and align destination with observed old Najena entry point.
- Najena → Lavastorm: fix bad outside-map target and make duplicate rows consistent.
- Lavastorm v0 → Nektulos: align trigger with observed old Lavastorm zone line.
- Nektulos v0 → Lavastorm: make duplicate classic rows consistent with observed old Lavastorm arrival.
- PoKnowledge → Nektulos duplicate stone: set the `dest_instance = 1` row to classic instance `0`, matching the already-classic duplicate row.

## What this slice does not change

- Does not delete version-1 Nektulos or Lavastorm data.
- Does not delete route rows.
- Does not change spawn tables.
- Does not alter expansion unlock logic.
- Does not fix every possible PoK/port/zone-line route yet.

## Post-apply testing checklist

After applying v22, test with a progression-appropriate character/context, not a GM state that forces "All Expansions" unless specifically testing post-unlock behavior.

Minimum checks:

1. Lavastorm → Najena fires from the old Lavastorm Najena entrance.
2. Najena → Lavastorm lands near the old Lavastorm Najena entrance, not outside the map.
3. Lavastorm → Nektulos fires from the old Lavastorm Nektulos zone line.
4. Nektulos → Lavastorm lands near the old Lavastorm Nektulos zone line.
5. PoK → Nektulos lands in classic Nektulos instance/version behavior, not the newer instance.

If any route still misbehaves, capture `/loc` immediately before zoning and immediately after landing.
