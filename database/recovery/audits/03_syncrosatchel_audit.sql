-- MSR Recovery Audit 03: syncrosatchel item and merchant state
-- This audits the pet-gear bags and any merchant entries that sell them.

SELECT 'audit' AS section, '03_syncrosatchel' AS audit_name, NOW() AS audited_at;

SELECT
  id,
  Name,
  price,
  classes,
  slots,
  bagslots,
  bagtype,
  bagwr,
  itemclass,
  nodrop,
  attuneable,
  loregroup,
  scriptfileid
FROM items
WHERE Name LIKE '%Syncrosatchel%'
ORDER BY id;

SELECT
  ml.merchantid,
  nt.name AS merchant_npc_name,
  ml.slot,
  ml.item,
  i.Name AS item_name,
  i.price AS item_price,
  ml.level_required,
  ml.classes_required,
  ml.min_status,
  ml.max_status,
  ml.min_expansion,
  ml.max_expansion
FROM merchantlist ml
JOIN items i ON i.id = ml.item
LEFT JOIN npc_types nt ON nt.merchant_id = ml.merchantid
WHERE i.Name LIKE '%Syncrosatchel%'
ORDER BY ml.merchantid, ml.slot, ml.item;

SELECT
  merchantid,
  COUNT(*) AS syncrosatchel_count
FROM merchantlist ml
JOIN items i ON i.id = ml.item
WHERE i.Name LIKE '%Syncrosatchel%'
GROUP BY merchantid
ORDER BY syncrosatchel_count DESC, merchantid;
