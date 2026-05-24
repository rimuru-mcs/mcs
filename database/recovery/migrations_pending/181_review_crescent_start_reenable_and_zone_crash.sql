-- MSR Recovery Slice v27a pending review notes
-- Do NOT apply blindly.
--
-- Crescent Reach is expected to be valid on live for some new characters, but
-- recovered dev currently crashes after client handoff into zone 394. Once the
-- zone-entry crash is fixed and tested, review one of these re-enable options.

-- Option A: re-enable by adding/enabling the content flag, if the server uses
-- content_flags table for runtime unlocks.
-- INSERT INTO content_flags (flag_name, enabled, notes)
-- VALUES ('msr_crescent_start_unlocked', 1, 'Recovery: Crescent Reach starts re-enabled after zone-entry crash fix')
-- ON DUPLICATE KEY UPDATE enabled = 1;

-- Option B: remove the recovery-only flag from Crescent start rows.
-- UPDATE start_zones
-- SET content_flags = TRIM(BOTH ',' FROM REPLACE(CONCAT(',', content_flags, ','), ',msr_crescent_start_unlocked,', ','))
-- WHERE zone_id = 394 OR start_zone = 394;

-- Option C: keep Crescent gated and offer only racial default city starts until
-- progression/racial-start doctrine is fully audited.
