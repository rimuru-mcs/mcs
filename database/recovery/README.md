# MSR Database Recovery

This folder is the controlled recovery area for the lost 5/20–5/23 database-side work.

## Rules of engagement

- Do not directly edit the full baseline dump to recover fixes.
- Restore the baseline dump into a local/dev database first.
- Run `audits/*.sql` to capture the current state.
- Apply `migrations_safe/*.sql` only after backup.
- Treat `migrations_pending/*.sql` as review material, not auto-apply material.
- Promote pending migrations into safe migrations only after they are confirmed against live database data and server behavior.

## Why this exists

The uploaded SQL archive is useful as a baseline, but it does not appear to be a later patch delta containing all lost updates. The changelog references work that must be reconstructed, including global buff consolidation, syncrosatchel fixes, sympathetic item/proc changes, and zone/waypoint/progression changes.

This structure keeps those recovery steps traceable and reversible.

## Script assumptions

The helper scripts expect one of these clients on PATH:

- `mariadb`
- `mysql`

Set `MSR_DB_PASSWORD` to avoid typing the password repeatedly:

```powershell
$env:MSR_DB_PASSWORD = "your-password"
```

or:

```bash
export MSR_DB_PASSWORD='your-password'
```
