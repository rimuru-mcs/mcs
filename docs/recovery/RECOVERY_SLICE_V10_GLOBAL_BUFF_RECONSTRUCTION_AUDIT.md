# MSR Recovery Slice v10 — Global Buff Reconstruction Audit

This slice prepares the next recovery target: the lost server/global buff work
from the 5/21 and 5/23 notes.

It is audit/extraction only. It does not enable permanent server buffs and does
not insert spell rows.

## Why this is audit-only

The restored DB does not contain spell IDs `44000-44007`, while the lost notes
describe those IDs as server/global buffs. The 5/23 client patch also changed
spell data and is associated with a crashy `dinput8.dll`, so spell data must be
reconstructed without trusting the 5/23 DLL.

## Added files

```text
database/recovery/audits/14_global_buff_reconstruction_audit.sql
database/recovery/migrations_pending/090_review_global_buff_reconstruction_candidates.sql
recovery/extract_client_global_buff_rows.py
recovery/verify_recovery_slice_v10.py
docs/recovery/RECOVERY_SLICE_V10_GLOBAL_BUFF_RECONSTRUCTION_AUDIT.md
```

## Workflow

Verify the slice:

```bash
python3 recovery/verify_recovery_slice_v10.py
```

Run the DB audit:

```bash
export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='your_audit_password_here'

bash recovery/run_db_audit.sh
```

Extract client spell rows from the uploaded patch ZIPs:

```bash
python3 recovery/extract_client_global_buff_rows.py \
  --patch-zip /opt/msr/incoming/Multiclass-Patch_5-21-UPDATE-FILES.zip \
  --patch-zip /opt/msr/incoming/NMS_Client_Patch_5-23-2026.zip
```

Package the output:

```bash
tar -czf /opt/msr/logs/msr_global_buff_recon_$(date +%Y%m%d_%H%M%S).tar.gz \
  database/recovery/audit_output \
  database/recovery/client_spell_extract
```

## Expected next step

Review:

```text
database/recovery/audit_output/14_global_buff_reconstruction_audit.txt
database/recovery/client_spell_extract/global_buff_client_spell_rows.tsv
```

Then promote a narrow spell-row reconstruction migration only after the client
rows and DB schema mapping are confirmed.
