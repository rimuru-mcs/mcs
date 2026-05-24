# MSR Recovery Slice v19 — Old Nektulos/Lavastorm Route Reference Audit

## Purpose

MSR intentionally uses the older/classic versions of Nektulos Forest and Lavastorm Mountains. The lost hotfix notes say those zones were loading the wrong NPC version and that zone lines, PoK routing, and safe areas were corrected.

This slice is read-only. It does not alter database rows.

## Added files

- `database/recovery/audits/23_old_nektulos_lavastorm_route_reference_audit.sql`
- `database/recovery/migrations_pending/140_review_old_nektulos_lavastorm_route_recovery.sql`
- `recovery/verify_recovery_slice_v19.py`
- `docs/recovery/RECOVERY_SLICE_V19_OLD_NEKTULOS_LAVASTORM_ROUTE_REFERENCE_AUDIT.md`

## What this audit captures

- Version 0/classic and version 1/newer zone rows for Nektulos/Lavastorm
- Zone-point routes from and to zone IDs 25 and 27
- Candidate zone points that route into non-zero target instances or expansion-gated routes
- Doors and PoK doors that target Nektulos/Lavastorm
- Candidate doors targeting non-zero destination instances or expansion-gated routes
- Teleport spell candidates whose names or `teleport_zone` point at Nektulos/Lavastorm
- Spawn2 version counts for both zones

## How to run

```bash
cd /opt/msr/repo/msr
python3 recovery/verify_recovery_slice_v19.py

export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='msrtest'

bash recovery/run_db_audit.sh
tar -czf /opt/msr/logs/msr_db_audit_$(date +%Y%m%d_%H%M%S).tar.gz database/recovery
```

## Expected next step

Review the audit output before writing any migration. Old-zone route repair needs exact destination coordinates for physical zone lines, wizard/druid ports, PoK stones, and safe points. If those are not confidently present in the DB audit, validate them through client `/loc` testing or a trusted old-zone reference database before promoting SQL.
