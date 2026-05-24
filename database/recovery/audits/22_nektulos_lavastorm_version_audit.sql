-- MSR Recovery Slice v18
-- Read-only audit for the lost 5/20-era Nektulos/Lavastorm version, zone-line,
-- PoK stone, safe-area, and spawn-version recovery work.
--
-- This audit intentionally avoids changing data. It captures the rows needed
-- to decide whether a later safe migration should pin these zones to older
-- version rows, repair zone lines, and/or repair safe coordinates.

SELECT
  'audit' AS section,
  '22_nektulos_lavastorm_version' AS audit_name,
  NOW() AS audited_at;

SELECT
  'audit_note' AS section,
  'Read-only: inspect zone rows, zone_points, doors/PoK stone style links, and spawn2 rows for nektulos/lavastorm before any recovery SQL is promoted.' AS note;

SELECT
  'zone_columns' AS section,
  COLUMN_NAME,
  COLUMN_TYPE,
  IS_NULLABLE,
  COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'zone'
ORDER BY ORDINAL_POSITION;

SELECT
  'zone_points_columns' AS section,
  COLUMN_NAME,
  COLUMN_TYPE,
  IS_NULLABLE,
  COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'zone_points'
ORDER BY ORDINAL_POSITION;

SELECT
  'doors_columns' AS section,
  COLUMN_NAME,
  COLUMN_TYPE,
  IS_NULLABLE,
  COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'doors'
ORDER BY ORDINAL_POSITION;

SELECT
  'spawn2_columns' AS section,
  COLUMN_NAME,
  COLUMN_TYPE,
  IS_NULLABLE,
  COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'spawn2'
ORDER BY ORDINAL_POSITION;

SELECT
  'target_zone_rows' AS section,
  z.*
FROM zone z
WHERE z.short_name IN ('nektulos', 'lavastorm')
ORDER BY z.short_name, z.version, z.min_expansion, z.max_expansion;

SELECT
  'target_zone_summary' AS section,
  short_name,
  COUNT(*) AS row_count,
  GROUP_CONCAT(CONCAT('version=', version, ',min=', min_expansion, ',max=', max_expansion, ',safe=(', safe_x, ',', safe_y, ',', safe_z, ')') ORDER BY version SEPARATOR ' | ') AS version_summary
FROM zone
WHERE short_name IN ('nektulos', 'lavastorm')
GROUP BY short_name
ORDER BY short_name;

SELECT
  'zone_points_from_target_zones' AS section,
  zp.*
FROM zone_points zp
WHERE zp.zone IN ('nektulos', 'lavastorm')
ORDER BY zp.zone
LIMIT 500;

SET @has_zone_points_target_zone_id := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'zone_points'
    AND COLUMN_NAME = 'target_zone_id'
);

SET @zone_points_target_sql := IF(
  @has_zone_points_target_zone_id > 0,
  "SELECT 'zone_points_to_target_zone_ids' AS section, zp.* FROM zone_points zp WHERE zp.target_zone_id IN (25, 27) ORDER BY zp.zone LIMIT 500",
  "SELECT 'zone_points_to_target_zone_ids' AS section, 'skipped: zone_points.target_zone_id column not present' AS note"
);

PREPARE zone_points_target_stmt FROM @zone_points_target_sql;
EXECUTE zone_points_target_stmt;
DEALLOCATE PREPARE zone_points_target_stmt;

SELECT
  'doors_from_or_to_target_zones' AS section,
  d.*
FROM doors d
WHERE d.zone IN ('nektulos', 'lavastorm')
   OR d.dest_zone IN ('nektulos', 'lavastorm')
ORDER BY d.zone, d.doorid
LIMIT 500;

SELECT
  'poknowledge_doors_to_targets' AS section,
  d.*
FROM doors d
WHERE d.zone IN ('poknowledge', 'poknowledgeb')
  AND d.dest_zone IN ('nektulos', 'lavastorm')
ORDER BY d.zone, d.doorid
LIMIT 200;

SELECT
  'spawn2_target_rows_sample' AS section,
  s.*
FROM spawn2 s
WHERE s.zone IN ('nektulos', 'lavastorm')
ORDER BY s.zone
LIMIT 500;

SET @has_spawn2_version := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'spawn2'
    AND COLUMN_NAME = 'version'
);

SET @spawn2_version_sql := IF(
  @has_spawn2_version > 0,
  "SELECT 'spawn2_version_summary' AS section, zone, version, COUNT(*) AS spawn2_rows FROM spawn2 WHERE zone IN ('nektulos', 'lavastorm') GROUP BY zone, version ORDER BY zone, version",
  "SELECT 'spawn2_version_summary' AS section, 'skipped: spawn2.version column not present' AS note"
);

PREPARE spawn2_version_stmt FROM @spawn2_version_sql;
EXECUTE spawn2_version_stmt;
DEALLOCATE PREPARE spawn2_version_stmt;

SELECT
  'candidate_followup' AS section,
  'If wrong-version routing is confirmed, v19 should patch zone min/max expansion, zone_points, PoK doors/stones, and safe coords together, with backup tables first.' AS note;
