-- MSR Recovery Slice v27a hotfix 2
-- Crescent Reach start-zone hold / zone-entry crash audit.
--
-- Purpose:
--   v27 successfully gated revamped Freeport starts. New character creation then
--   selected Crescent Reach (zone 394), which boots but crashes shortly after
--   client handoff during AA table send. This audit records Crescent start rows
--   and currently stranded characters without mutating data.
--
-- Compatibility:
--   This recovered start_zones schema may not have an `id` column, so this audit
--   intentionally avoids selecting or ordering by start_zones.id.

SELECT
  'crescent_zone_rows' AS section,
  zoneidnumber,
  short_name,
  long_name,
  version,
  min_expansion,
  max_expansion,
  content_flags,
  content_flags_disabled
FROM zone
WHERE zoneidnumber = 394
   OR short_name = 'crescent'
   OR long_name LIKE '%Crescent%Reach%'
ORDER BY zoneidnumber, version, short_name;

SELECT
  'crescent_start_rows' AS section,
  player_choice,
  player_class,
  player_deity,
  player_race,
  zone_id,
  start_zone,
  x,
  y,
  z,
  heading,
  bind_id,
  bind_x,
  bind_y,
  bind_z,
  min_expansion,
  max_expansion,
  content_flags,
  content_flags_disabled
FROM start_zones
WHERE zone_id = 394
   OR start_zone = 394
ORDER BY player_race, player_class, player_deity, zone_id, start_zone, x, y, z
LIMIT 500;

SELECT
  'crescent_start_gate_summary' AS section,
  COUNT(*) AS crescent_start_rows_total,
  SUM(CASE
        WHEN CONCAT(',', COALESCE(content_flags, ''), ',') LIKE '%,msr_crescent_start_unlocked,%'
        THEN 1 ELSE 0
      END) AS gated_by_v27a_count,
  SUM(CASE
        WHEN COALESCE(content_flags, '') = ''
        THEN 1 ELSE 0
      END) AS still_ungated_blank_content_flags_count
FROM start_zones
WHERE zone_id = 394
   OR start_zone = 394;

SELECT
  'characters_currently_in_crescent' AS section,
  cd.id,
  cd.name,
  cd.zone_id,
  z.short_name,
  z.long_name,
  cd.x,
  cd.y,
  cd.z
FROM character_data cd
LEFT JOIN zone z ON z.zoneidnumber = cd.zone_id
WHERE cd.zone_id = 394
ORDER BY cd.id
LIMIT 200;
