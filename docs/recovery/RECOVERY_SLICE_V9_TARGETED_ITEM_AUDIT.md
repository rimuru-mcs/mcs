# MSR Recovery Slice v9 — Targeted Item Candidate Audit

This slice adds a read-only audit for two lost 5/23 recovery notes:

- Add **Sympathetic Strike I** to **Simple Ring of the Hero**.
- Re-add the **21-slot Transcendent Mage's Syncrosatchel** to Bag Merchant Tunk at **50,000 platinum**.

No data is changed by this slice.

## Why this is audit-only

Previous recovery slices intentionally avoided these fixes because the exact item and spell rows were not confirmed. This slice gathers those exact candidates before a migration is promoted.

## Added files

```text
database/recovery/audits/13_targeted_item_recovery_candidates_audit.sql
database/recovery/migrations_pending/080_review_targeted_hero_ring_and_transcendent_bag_candidates.sql
recovery/verify_recovery_slice_v9.py
docs/recovery/RECOVERY_SLICE_V9_TARGETED_ITEM_AUDIT.md
```

## Expected workflow

```bash
python3 recovery/verify_recovery_slice_v9.py

export MSR_DB_HOST=localhost
export MSR_DB_NAME=msr_world_recovery
export MSR_DB_USER=msr_audit
export MSR_DB_PASSWORD='your_audit_password_here'

bash recovery/run_db_audit.sh
tar -czf /opt/msr/logs/msr_db_audit_$(date +%Y%m%d_%H%M%S).tar.gz database/recovery
```

Then review `database/recovery/audit_output/13_targeted_item_recovery_candidates_audit.txt`.
