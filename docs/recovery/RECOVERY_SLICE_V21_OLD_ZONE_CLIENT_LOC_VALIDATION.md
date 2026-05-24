# Recovery Slice v21 — Old Nektulos/Lavastorm Client `/loc` Validation

## Purpose

Slice v20 confirmed the database has mixed classic/revamped Nektulos and Lavastorm routing candidates. MSR is intended to use the older/classic versions of these zones, so the next step is a controlled client validation pass before any SQL route migration is promoted.

This slice is read-only. It does not change zone, door, zone point, spell, or spawn data.

## Why this slice exists

Nektulos and Lavastorm are risky because route data, client zone files, and zone versions must agree. A migration based only on inferred coordinates can land players below terrain, in lava, behind geometry, or in the wrong era of the zone.

The validation pass should prove which old-zone route rows are correct and which new-version rows should be disabled, version-gated, or retargeted.

## Current evidence from v20 audit

Classic zone rows:

- `nektulos` version `0`, `map_file_name = nektulos_v0`, note `Original classic Nektulos`.
- `nektulos` version `1`, `map_file_name = nektulos_v1`, note `DoDH Nektulos`.
- `lavastorm` version `0`, `map_file_name = lavastorm_v0`, note `Original classic lavastorm`.
- `lavastorm` version `1`, `map_file_name = lavastorm_v1`, note `Dragons of Norrath Lavastorm`.

Problem route families observed:

- `PoKnowledge` has both version `0` and version `1` Nektulos targets.
- `zone_points` still have several `target_instance = 1` Nektulos candidates.
- `doors` still have Nektulos candidates with `dest_instance = 1`.
- Lavastorm has both version `0` and version `1` route rows for neighboring zones.

## Files added

- `database/recovery/manual_tests/old_nektulos_lavastorm_route_validation.tsv`
- `database/recovery/manual_tests/old_zone_client_file_checklist.md`
- `database/recovery/migrations_pending/160_review_old_zone_route_fix_after_validation_report.sql`
- `recovery/verify_recovery_slice_v21.py`

## How to validate

Use a GM/test account on the dev server only.

For each row in `old_nektulos_lavastorm_route_validation.tsv`:

1. Start from the listed route/source.
2. Travel normally through the door, stone, zone line, or port/succor route.
3. Run `/loc` after landing.
4. Record the destination zone/version if visible.
5. Record whether the landing point is safe.
6. Record whether the geometry/NPC layout matches the intended classic zone.
7. Test the return route when applicable.

Do not edit route SQL until the validation TSV has been filled in.

## What v22 should do after validation

Only after the validation sheet is filled in, v22 can promote a targeted migration that:

1. backs up affected `zone`, `zone_points`, and `doors` rows;
2. routes ordinary Nektulos/Lavastorm travel to version `0`;
3. disables or gates version `1` route rows for normal MSR travel;
4. preserves revamped rows for possible future review;
5. uses confirmed old-zone coordinates only.
