-- MSR Recovery Pending Migration 060: Sympathetic item candidates
-- DO NOT AUTO-RUN except for statements promoted to migrations_safe.

-- Lost 5/23 notes mention:
--   Fixed Sympathetic items now proc at all levels not just level 70
--   Added Sympathetic Strike I on Simple Ring of the Hero

-- PROMOTED TO SAFE MIGRATION IN SLICE V8:
--   Remove proc/worn/focus level gates from item effects attached to spells whose name contains
--   "Sympathetic".
--
-- See:
--   database/recovery/migrations_safe/060_apply_sympathetic_level_gate_recovery.sql
--   database/recovery/audits/12_sympathetic_level_gate_recovery_audit.sql

-- Still pending:
--   Simple Ring of the Hero needs a separate targeted audit/migration because the restored baseline
--   audit did not yet confirm the exact item row and intended Sympathetic Strike I effect pairing.
--   Do not guess the effect ID here.
