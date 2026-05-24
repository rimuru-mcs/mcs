# Old-zone Client File Checklist — Nektulos/Lavastorm

Before route SQL is changed, confirm the test client is actually using the intended old/classic zone files.

## Required checks

- Confirm the client can load classic/old `nektulos` without showing empty/missing geometry.
- Confirm the client can load classic/old `lavastorm` without missing terrain, lava placement issues, or invisible-wall issues.
- Confirm the test client is not accidentally using a newer `nektulos.eqg` / `lavastorm.eqg` layout when the DB is routing players to classic version `0` rows.
- Confirm any patched client distribution notes explicitly say whether old or new zone assets are expected.

## Record these values

```text
Client build/name:
Client patch version:
Old Nektulos confirmed: yes/no
Old Lavastorm confirmed: yes/no
Files removed/renamed, if any:
Tester:
Date:
Notes:
```

## Warnings

Do not mix a classic route database with a newer client zone layout. If the client uses the wrong layout, even correct DB coordinates may appear wrong.
