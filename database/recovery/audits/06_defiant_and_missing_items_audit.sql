-- MSR Recovery Audit 06: defiant gear, merchant expansion visibility, and missing item candidates

SELECT 'audit' AS section, '06_defiant_and_missing_items' AS audit_name, NOW() AS audited_at;

SELECT
  id,
  Name,
  minstatus,
  price,
  reqlevel,
  reclevel,
  classes,
  slots,
  artifactflag,
  nodrop,
  attuneable
FROM items
WHERE Name LIKE '%Defiant%'
ORDER BY id
LIMIT 500;

SELECT
  COUNT(*) AS defiant_item_count
FROM items
WHERE Name LIKE '%Defiant%';

SELECT
  ml.merchantid,
  nt.name AS merchant_npc_name,
  COUNT(*) AS expansion_gated_items,
  MIN(ml.min_expansion) AS min_min_expansion,
  MAX(ml.max_expansion) AS max_max_expansion
FROM merchantlist ml
LEFT JOIN npc_types nt ON nt.merchant_id = ml.merchantid
WHERE ml.min_expansion <> -1 OR ml.max_expansion <> -1
GROUP BY ml.merchantid, nt.name
ORDER BY expansion_gated_items DESC, ml.merchantid
LIMIT 200;

SELECT
  ml.merchantid,
  nt.name AS merchant_npc_name,
  ml.slot,
  ml.item,
  i.Name AS item_name,
  ml.min_expansion,
  ml.max_expansion,
  ml.level_required,
  ml.classes_required
FROM merchantlist ml
LEFT JOIN items i ON i.id = ml.item
LEFT JOIN npc_types nt ON nt.merchant_id = ml.merchantid
WHERE ml.min_expansion <> -1 OR ml.max_expansion <> -1
ORDER BY ml.merchantid, ml.slot
LIMIT 500;
