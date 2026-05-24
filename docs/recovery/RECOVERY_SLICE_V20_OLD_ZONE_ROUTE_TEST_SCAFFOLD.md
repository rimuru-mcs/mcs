# Recovery Slice v20 — Old Nektulos/Lavastorm Route Test Scaffold

## Purpose

Slice v19 confirmed the restored MSR database has both classic and revamped Nektulos/Lavastorm rows and mixed routing candidates. Because MSR is intended to use the older/classic versions of these zones, we need one controlled route-test pass before promoting any route-fix SQL.

This slice is read-only. It does not change zone, door, zone point, spell, or spawn data.

## Why this is not an immediate migration

The hotfix target is risky because a wrong destination coordinate can place players under the world, in lava, behind geometry, or at the wrong safe point. The next migration must be based on confirmed old-zone route coordinates, not inferred coordinates.

## Confirmed from v19

- `nektulos` version `0` is the original/classic row.
- `nektulos` version `1` is the DoDH/newer row.
- `lavastorm` version `0` is the original/classic row.
- `lavastorm` version `1` is the DoN/newer row.
- PoK/Nektulos has both classic and newer target candidates.
- Some zone points and doors still route to target instance/version `1`.
- `spawn2` includes both version `0` and version `1` spawn sets.

## Manual route test checklist

Use a GM/test character on the dev server only.

For every route below, capture:

- source zone
- source approximate `/loc`
- destination zone
- destination `/loc`
- destination version if visible/known
- whether player lands safely
- whether mobs/NPC set looks classic or revamped
- whether return zone line works

### Nektulos routes

Test and record:

- PoK stone/door to Nektulos
- Commonlands/East Commons to Nektulos
- Neriak to Nektulos
- Nektulos to Commonlands/East Commons
- Nektulos to Neriak
- Nektulos to Lavastorm if available
- any wizard/druid/succor/evac style route that lands in or near Nektulos

### Lavastorm routes

Test and record:

- Nektulos to Lavastorm
- Lavastorm to Nektulos
- Lavastorm to Najena
- Lavastorm to Solusek A
- Lavastorm to Solusek B
- Lavastorm to Solusek Temple
- PoK stone/door to Lavastorm if present
- druid/wizard port-in route to Lavastorm
- evac/succor route in Lavastorm

## Expected next step

After test output is captured, promote a targeted migration that:

1. backs up touched `zone`, `zone_points`, `doors`, and possibly `spells_new` rows;
2. routes normal world travel to version `0` for Nektulos/Lavastorm;
3. keeps revamped version rows available but not selected for ordinary travel;
4. uses confirmed safe old-zone destination coordinates.
