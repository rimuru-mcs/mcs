-- MSR Recovery Pending Migration 050: syncrosatchel candidates
-- DO NOT AUTO-RUN. Merchant IDs and item IDs must be confirmed by audit output.

-- Lost notes mention:
-- - syncrosatchel bags not working due to ID mismatch
-- - Expanded Syncrosatchels reduced to 5,000 platinum
-- - Transcendent Mage's Syncrosatchel 21-slot bag sold for 50,000 platinum
-- - 21-slot bag re-added

-- Candidate item price update once exact item IDs are confirmed:
-- UPDATE items
-- SET price = 5000
-- WHERE Name LIKE 'Expanded %Syncrosatchel%';

-- Candidate merchant class filter broadening once merchant ID is confirmed:
-- UPDATE merchantlist ml
-- JOIN items i ON i.id = ml.item
-- SET ml.classes_required = 65535, ml.min_expansion = -1, ml.max_expansion = -1
-- WHERE i.Name LIKE '%Syncrosatchel%';

-- Candidate ID mismatch repair requires comparing code constants against item IDs from audit 03.
-- Do not guess IDs here.
