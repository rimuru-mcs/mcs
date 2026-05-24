SELECT
  'audit' AS section,
  '24_old_zone_route_fix_readiness' AS audit_name,
  NOW() AS audited_at;

SELECT
  'audit_note' AS section,
  'Read-only: focused old-zone route readiness audit. Confirms candidates that still require client /loc validation before SQL promotion.' AS note;

SELECT
  'classic_target_zone_rows' AS section,
  short_name,
  version,
  id,
  zoneidnumber,
  min_expansion,
  max_expansion,
  map_file_name,
  note,
  safe_x,
  safe_y,
  safe_z,
  safe_heading
FROM zone
WHERE short_name IN ('nektulos', 'lavastorm')
ORDER BY short_name, version;

SELECT
  'zone_points_targeting_new_versions' AS section,
  id,
  zone,
  version,
  number,
  target_zone_id,
  target_instance,
  target_x,
  target_y,
  target_z,
  target_heading,
  min_expansion,
  max_expansion,
  client_version_mask
FROM zone_points
WHERE target_zone_id IN (25, 27)
  AND target_instance <> 0
ORDER BY target_zone_id, zone, version, number, id;

SELECT
  'zone_points_from_old_target_zones' AS section,
  id,
  zone,
  version,
  number,
  target_zone_id,
  target_instance,
  target_x,
  target_y,
  target_z,
  target_heading,
  min_expansion,
  max_expansion,
  client_version_mask
FROM zone_points
WHERE zone IN ('nektulos', 'lavastorm', 'ecommons', 'commonlands', 'neriaka', 'najena', 'soldunga', 'soldungb', 'soltemple', 'poknowledge')
   OR target_zone_id IN (25, 27)
ORDER BY zone, version, number, id;

SELECT
  'doors_targeting_new_versions' AS section,
  id,
  doorid,
  zone,
  version,
  name,
  opentype,
  dest_zone,
  dest_instance,
  dest_x,
  dest_y,
  dest_z,
  dest_heading,
  client_version_mask,
  min_expansion,
  max_expansion
FROM doors
WHERE dest_zone IN ('nektulos', 'lavastorm')
  AND dest_instance <> 0
ORDER BY dest_zone, zone, version, doorid, id;

SELECT
  'poknowledge_target_doors' AS section,
  id,
  doorid,
  zone,
  version,
  name,
  opentype,
  dest_zone,
  dest_instance,
  dest_x,
  dest_y,
  dest_z,
  dest_heading,
  client_version_mask,
  min_expansion,
  max_expansion
FROM doors
WHERE LOWER(zone) = 'poknowledge'
  AND dest_zone IN ('nektulos', 'lavastorm')
ORDER BY dest_zone, min_expansion, max_expansion, id;

SELECT
  'spawn2_version_summary' AS section,
  zone,
  version,
  COUNT(*) AS spawn_count,
  MIN(min_expansion) AS min_min_expansion,
  MAX(max_expansion) AS max_max_expansion
FROM spawn2
WHERE zone IN ('nektulos', 'lavastorm')
GROUP BY zone, version
ORDER BY zone, version;

SELECT
  'manual_test_required' AS section,
  'Do not promote route SQL until PoK, zoneline, and druid/wizard/succor landing coordinates are validated on the intended old client zone files.' AS note;
