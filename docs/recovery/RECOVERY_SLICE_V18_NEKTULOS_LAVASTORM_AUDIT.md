# MSR Recovery Slice v18 — Nektulos/Lavastorm Version Audit

## Purpose

This slice audits the lost-update claim that Nektulos Forest and Lavastorm Mountains were loading the wrong NPC version and that their versions, zone lines, PoK stone routing, and safe areas were fixed later.

This is an audit-only slice. It does not change the database.

## Added files

- `database/recovery/audits/22_nektulos_lavastorm_version_audit.sql`
- `database/recovery/migrations_pending/130_review_nektulos_lavastorm_version_and_zoneline_recovery.sql`
- `recovery/verify_recovery_slice_v18.py`
- `docs/recovery/RECOVERY_SLICE_V18_NEKTULOS_LAVASTORM_AUDIT.md`

## How to run

```bash
cd /opt/msr/repo/msr
python3 recovery/verify_recovery_slice_v18.py

export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='msrtest'

bash recovery/run_db_audit.sh
tar -czf /opt/msr/logs/msr_db_audit_$(date +%Y%m%d_%H%M%S).tar.gz database/recovery
```

## Expected next step

Review `database/recovery/audit_output/22_nektulos_lavastorm_version_audit.txt`.

If the audit confirms wrong version routing, the next slice should promote a targeted migration that backs up and repairs only the affected Nektulos/Lavastorm zone rows, zone points, PoK doors/stones, and safe coordinates.
