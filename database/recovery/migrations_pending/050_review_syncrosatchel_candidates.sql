-- MSR Recovery Pending Migration 050: syncrosatchel candidates
-- DO NOT AUTO-RUN. Merchant IDs and item IDs must be confirmed by audit output.
-- Updated in Slice v2.1 after audit 03 confirmed current item/merchant state.

-- Lost notes mention:
-- - syncrosatchel bags not working due to ID mismatch
-- - Expanded Syncrosatchels reduced to 5,000 platinum
-- - Transcendent Mage's Syncrosatchel 21-slot bag sold for 50,000 platinum
-- - 21-slot bag re-added

-- Audit 03 confirmed the current baseline has 16 Syncrosatchel items sold by merchant 151044 / Bag Merchant Tunk.
-- Current Expanded Syncrosatchel item prices are 500,000,000.
-- EQEmu item prices are normally stored in copper, so:
--   5,000 platinum  = 5,000,000 copper
--   50,000 platinum = 50,000,000 copper
-- Do not use 5000 here unless code/database confirms this server stores merchant prices differently.

-- Candidate item price update once price-unit convention is confirmed:
-- UPDATE items
-- SET price = 5000000
-- WHERE Name LIKE 'Expanded %Syncrosatchel%';

-- Candidate merchant class/expansion broadening confirmed by audit 03 as already broadly available,
-- but left here for repair if a later DB differs.
-- UPDATE merchantlist ml
-- JOIN items i ON i.id = ml.item
-- SET ml.classes_required = 65535, ml.min_expansion = -1, ml.max_expansion = -1
-- WHERE i.Name LIKE '%Syncrosatchel%';

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
