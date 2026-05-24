-- MSR Recovery Slice v9
-- Targeted candidate audit for:
--   1) "Simple Ring of the Hero" + "Sympathetic Strike I"
--   2) 21-slot "Transcendent Mage's Syncrosatchel" merchant recovery
--
-- This file is READ ONLY. It does not modify database state.

SELECT
  'audit' AS `section`,
  '13_targeted_item_recovery_candidates' AS `audit_name`,
  NOW() AS `audited_at`;

SELECT
  'items' AS `section`,
  'Simple Ring / Hero item candidates' AS `candidate_group`,
  `id`,
  `Name`,
  `price`,
  `bagslots`,
  `bagtype`,
  `itemclass`,
  `classes`,
  `slots`,
  `reqlevel`,
  `reclevel`,
  `proceffect`,
  `proclevel`,
  `worneffect`,
  `wornlevel`,
  `focuseffect`,
  `focuslevel`
FROM `items`
WHERE
  `Name` LIKE '%Simple Ring%Hero%'
  OR `Name` LIKE '%Ring%Hero%'
  OR `Name` LIKE '%Hero%Ring%'
ORDER BY
  CASE
    WHEN `Name` = 'Simple Ring of the Hero' THEN 0
    WHEN `Name` LIKE '%Simple Ring%Hero%' THEN 1
    ELSE 2
  END,
  `id`
LIMIT 100;

SELECT
  'spells' AS `section`,
  'Sympathetic Strike I spell candidates' AS `candidate_group`,
  `id`,
  `name`,
  `classes1`,
  `classes2`,
  `classes3`,
  `classes4`,
  `classes5`,
  `classes6`,
  `classes7`,
  `classes8`,
  `classes9`,
  `classes10`,
  `classes11`,
  `classes12`,
  `classes13`,
  `effectid1`,
  `effectid2`,
  `effectid3`,
  `effect_base_value1`,
  `effect_base_value2`,
  `effect_base_value3`,
  `buffduration`,
  `goodEffect`
FROM `spells_new`
WHERE
  `name` = 'Sympathetic Strike I'
  OR `name` LIKE 'Sympathetic Strike I %'
  OR `name` LIKE 'Sympathetic Strike of % I'
ORDER BY
  CASE WHEN `name` = 'Sympathetic Strike I' THEN 0 ELSE 1 END,
  `id`
LIMIT 100;

SELECT
  'spells' AS `section`,
  'Nearby low-rank Sympathetic Strike spell context' AS `candidate_group`,
  `id`,
  `name`,
  `effectid1`,
  `effectid2`,
  `effectid3`,
  `effect_base_value1`,
  `effect_base_value2`,
  `effect_base_value3`,
  `classes1`,
  `classes2`,
  `classes3`,
  `classes4`,
  `classes5`,
  `classes6`,
  `classes7`,
  `classes8`,
  `classes9`,
  `classes10`,
  `classes11`,
  `classes12`,
  `classes13`
FROM `spells_new`
WHERE
  `name` LIKE 'Sympathetic Strike%'
ORDER BY `id`
LIMIT 150;

SELECT
  'items' AS `section`,
  'Transcendent Syncrosatchel item candidates' AS `candidate_group`,
  `id`,
  `Name`,
  `price`,
  `bagslots`,
  `bagtype`,
  `itemclass`,
  `classes`,
  `slots`,
  `loregroup`,
  `reqlevel`,
  `reclevel`
FROM `items`
WHERE
  `Name` LIKE '%Transcendent%Syncrosatchel%'
  OR `Name` LIKE '%Transcendent%Mage%Syncrosatchel%'
  OR (`Name` LIKE '%Syncrosatchel%' AND `bagslots` >= 20)
ORDER BY
  CASE
    WHEN `Name` = 'Transcendent Mage''s Syncrosatchel' THEN 0
    WHEN `Name` LIKE '%Transcendent%Mage%Syncrosatchel%' THEN 1
    WHEN `Name` LIKE '%Transcendent%Syncrosatchel%' THEN 2
    ELSE 3
  END,
  `id`
LIMIT 100;

SELECT
  'merchant' AS `section`,
  'Bag Merchant Tunk current inventory' AS `candidate_group`,
  n.`id` AS `npc_id`,
  n.`name` AS `npc_name`,
  n.`merchant_id`,
  ml.`slot`,
  ml.`item` AS `item_id`,
  i.`Name` AS `item_name`,
  i.`price`,
  i.`bagslots`,
  i.`bagtype`,
  i.`itemclass`,
  i.`classes`,
  i.`loregroup`
FROM `npc_types` n
JOIN `merchantlist` ml
  ON ml.`merchantid` = n.`merchant_id`
LEFT JOIN `items` i
  ON i.`id` = ml.`item`
WHERE n.`name` LIKE '%Bag Merchant Tunk%'
ORDER BY n.`id`, ml.`slot`, ml.`item`;

SELECT
  'summary' AS `section`,
  (SELECT COUNT(*) FROM `items` WHERE `Name` = 'Simple Ring of the Hero') AS `simple_ring_exact_count`,
  (SELECT COUNT(*) FROM `spells_new` WHERE `name` = 'Sympathetic Strike I') AS `sympathetic_strike_i_exact_count`,
  (SELECT COUNT(*) FROM `items` WHERE `Name` = 'Transcendent Mage''s Syncrosatchel') AS `transcendent_mage_syncrosatchel_exact_count`,
  (SELECT COUNT(*) FROM `items` WHERE `Name` LIKE '%Transcendent%Syncrosatchel%') AS `transcendent_syncrosatchel_like_count`,
  (
    SELECT COUNT(*)
    FROM `npc_types` n
    JOIN `merchantlist` ml ON ml.`merchantid` = n.`merchant_id`
    WHERE n.`name` LIKE '%Bag Merchant Tunk%'
  ) AS `bag_merchant_tunk_rows`,
  (
    SELECT COUNT(*)
    FROM `npc_types` n
    JOIN `merchantlist` ml ON ml.`merchantid` = n.`merchant_id`
    JOIN `items` i ON i.`id` = ml.`item`
    WHERE n.`name` LIKE '%Bag Merchant Tunk%'
      AND i.`Name` LIKE '%Transcendent%Syncrosatchel%'
  ) AS `bag_merchant_tunk_transcendent_rows`;
