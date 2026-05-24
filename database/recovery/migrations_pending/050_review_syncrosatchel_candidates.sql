-- MSR Recovery Pending Migration 050: syncrosatchel candidates
-- DO NOT AUTO-RUN. Merchant IDs and item IDs must be confirmed by audit output.
-- Updated in Slice v2.1 after audit 03 confirmed current item/merchant state.
-- Updated in Slice v4 after Expanded Syncrosatchel pricing was promoted.

-- Lost notes mention:
-- - syncrosatchel bags not working due to ID mismatch
-- - Expanded Syncrosatchels reduced to 5,000 platinum
-- - Transcendent Mage's Syncrosatchel 21-slot bag sold for 50,000 platinum
-- - 21-slot bag re-added

-- PROMOTED TO SAFE MIGRATION IN SLICE V4:
--   Expanded Syncrosatchel item prices are set to 5,000,000 copper / 5,000 platinum.
--
-- See:
--   database/recovery/migrations_safe/030_apply_syncrosatchel_price_recovery.sql

-- Audit 03 confirmed the current baseline has 16 Syncrosatchel items sold by merchant 151044 / Bag Merchant Tunk.
-- Current Expanded Syncrosatchel item prices were 500,000,000 before Slice v4.
-- EQEmu item prices are normally stored in copper, so:
--   5,000 platinum  = 5,000,000 copper
--   50,000 platinum = 50,000,000 copper

-- Remaining pending work:
-- Candidate 21-slot Transcendent Mage's Syncrosatchel restore requires exact intended item ID and source row.
-- Do not synthesize this item from scratch until we compare client/server item files or recover the missing row.

-- Candidate ID mismatch repair requires comparing source-code constants against item IDs from audit 03:
--   Mage base/expanded:         147495 / 147496
--   Bard base/expanded:         147510 / 147511
--   Necromancer base/expanded:  147520 / 147521
--   Druid base/expanded:        147530 / 147531
--   Shadowknight base/expanded: 147540 / 147541
--   Enchanter base/expanded:    147550 / 147551
--   Beastlord base/expanded:    147560 / 147561
--   Shaman base/expanded:       147570 / 147571
