-- MSR Recovery Manual Test
-- Disable Custom:PermanentServerBuffsEnabled after dev validation.
--
-- Use this to return the DB to the safe/off state after runtime testing.

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES
  (
    1,
    'Custom:PermanentServerBuffsEnabled',
    'false',
    'MSR recovery Slice v14: disabled permanent server buffs after controlled runtime validation.'
  )
ON DUPLICATE KEY UPDATE
  `rule_value` = VALUES(`rule_value`),
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v14: disabled permanent server buffs after controlled runtime validation%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v14: disabled permanent server buffs after controlled runtime validation.')
  END;

SELECT
  `ruleset_id`,
  `rule_name`,
  `rule_value`,
  `notes`
FROM `rule_values`
WHERE `rule_name` = 'Custom:PermanentServerBuffsEnabled'
ORDER BY `ruleset_id`;
