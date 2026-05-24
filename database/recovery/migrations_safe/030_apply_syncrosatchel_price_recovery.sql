-- MSR Recovery Safe Migration 030
-- Applies the Bag Merchant Tunk price recovery for Expanded Syncrosatchels.
--
-- Lost 5/21 notes state:
--   "The Bag Merchant has reduced the price of Expanded Syncrosatchels to 5k platinum for all classes!"
--
-- EQEmu item prices are normally stored in copper:
--   5,000 platinum = 5,000,000 copper
--
-- This migration updates only existing Expanded Syncrosatchel item prices.
-- It does NOT synthesize the missing 21-slot Transcendent Mage's Syncrosatchel yet,
-- because the exact recovered item row/id still needs confirmation.

SET @msr_expanded_syncrosatchel_rows := (
  SELECT COUNT(*)
  FROM `items`
  WHERE `Name` LIKE 'Expanded %Syncrosatchel%'
);

UPDATE `items`
SET `price` = 5000000
WHERE `Name` LIKE 'Expanded %Syncrosatchel%';

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `notes`)
VALUES
  (
    '030_apply_syncrosatchel_price_recovery.sql',
    CONCAT(
      'Set ',
      @msr_expanded_syncrosatchel_rows,
      ' Expanded Syncrosatchel item price row(s) to 5,000,000 copper / 5,000 platinum. 21-slot Transcendent bag remains pending exact row confirmation.'
    )
  )
ON DUPLICATE KEY UPDATE
  `applied_at` = current_timestamp(),
  `applied_by` = current_user(),
  `notes` = VALUES(`notes`);
