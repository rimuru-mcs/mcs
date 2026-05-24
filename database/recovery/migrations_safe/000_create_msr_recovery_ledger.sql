-- MSR Recovery Safe Migration 000
-- Creates a small ledger table so recovery migrations can be tracked without editing the baseline dump.

CREATE TABLE IF NOT EXISTS `msr_recovery_migration_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `migration_name` varchar(160) NOT NULL,
  `applied_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `applied_by` varchar(128) NOT NULL DEFAULT current_user(),
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `migration_name` (`migration_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

INSERT INTO `msr_recovery_migration_log` (`migration_name`, `notes`)
VALUES ('000_create_msr_recovery_ledger.sql', 'Created recovery migration ledger table.')
ON DUPLICATE KEY UPDATE
  `applied_at` = current_timestamp(),
  `applied_by` = current_user(),
  `notes` = VALUES(`notes`);
