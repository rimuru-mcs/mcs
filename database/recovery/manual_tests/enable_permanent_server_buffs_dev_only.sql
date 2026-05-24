-- MSR Recovery Manual Test
-- Enable Custom:PermanentServerBuffsEnabled for dev validation only.
--
-- This is intentionally NOT in migrations_safe because this switch is meant to be controlled
-- by Spire/operator tooling, not forced on forever by a baseline migration.

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES
  (
    1,
    'Custom:PermanentServerBuffsEnabled',
    'true',
    'MSR recovery Slice v14 dev test: enabled permanent server buffs for controlled runtime validation. Toggle back off with disable_permanent_server_buffs_dev_only.sql when done.'
  )
ON DUPLICATE KEY UPDATE
  `rule_value` = VALUES(`rule_value`),
  `notes` = CASE
    WHEN COALESCE(`notes`, '') LIKE '%MSR recovery Slice v14 dev test: enabled permanent server buffs%'
      THEN `notes`
    ELSE CONCAT(COALESCE(`notes`, ''), ' | MSR recovery Slice v14 dev test: enabled permanent server buffs for controlled runtime validation.')
  END;

SELECT
  `ruleset_id`,
  `rule_name`,
  `rule_value`,
  `notes`
FROM `rule_values`
WHERE `rule_name` = 'Custom:PermanentServerBuffsEnabled'
ORDER BY `ruleset_id`;
