-- MSR Recovery Slice v19
-- Read-only old-zone route reference audit for Nektulos/Lavastorm.
--
-- Context:
--   MSR intentionally uses the older/classic versions of Nektulos Forest and Lavastorm Mountains.
--   The lost hotfix notes say those zones were loading the wrong NPC version and that zone lines,
--   PoK stone routing, and safe areas were corrected.
--
-- Purpose:
--   Capture enough DB evidence to build a later targeted migration without guessing old port-in,
--   wizard/druid teleport, or zone-line coordinates.
--
-- This audit intentionally changes nothing.

SELECT
  'audit' AS section,
  '23_old_nektulos_lavastorm_route_reference' AS audit_name,
  NOW() AS audited_at;

SELECT
  'audit_note' AS section,
  'Read-only: old/classic Nektulos/Lavastorm route evidence. Do not promote a routing migration until port-in/zone-line coordinates are confirmed.' AS note;

SELECT
  'old_zone_policy' AS section,
  'MSR should route ordinary players to version 0/classic Nektulos and Lavastorm unless a future design explicitly unlocks newer versions.' AS note;

SELECT
  'target_zone_version_summary' AS section,
  short_name,
  version,
  id,
  zoneidnumber,
  min_expansion,
  max_expansion,
  expansion,
  map_file_name,
  note,
  safe_x,
  safe_y,
  safe_z,
  safe_heading,
  canbind,
  ruleset,
  underworld,
  minclip,
  maxclip,
  bypass_expansion_check
FROM zone
WHERE short_name IN ('nektulos', 'lavastorm')
ORDER BY short_name, version, min_expansion, max_expansion;

SELECT
  'candidate_wrong_version_zone_rows' AS section,
  short_name,
  version,
  id,
  zoneidnumber,
  min_expansion,
  max_expansion,
  expansion,
  map_file_name,
  note,
  safe_x,
  safe_y,
  safe_z
FROM zone
WHERE short_name IN ('nektulos', 'lavastorm')
  AND version <> 0
ORDER BY short_name, version;

SELECT
  'classic_version_zero_rows' AS section,
  short_name,
  version,
  id,
  zoneidnumber,
  min_expansion,
  max_expansion,
  expansion,
  map_file_name,
  note,
  safe_x,
  safe_y,
  safe_z
FROM zone
WHERE short_name IN ('nektulos', 'lavastorm')
  AND version = 0
ORDER BY short_name;

SELECT
  'zone_points_from_old_target_zones' AS section,
  zp.id,
  zp.zone,
  zp.version,
  zp.number,
  zp.y,
  zp.x,
  zp.z,
  zp.heading,
  zp.target_y,
  zp.target_x,
  zp.target_z,
  zp.target_heading,
  zp.target_zone_id,
  zp.target_instance,
  zp.client_version_mask,
  zp.min_expansion,
  zp.max_expansion,
  zp.is_virtual,
  zp.height,
  zp.width
FROM zone_points zp
WHERE zp.zone IN ('nektulos', 'lavastorm')
ORDER BY zp.zone, zp.version, zp.number, zp.id;

SELECT
  'zone_points_to_old_target_zoneids' AS section,
  zp.id,
  zp.zone,
  zp.version,
  zp.number,
  zp.y,
  zp.x,
  zp.z,
  zp.heading,
  zp.target_y,
  zp.target_x,
  zp.target_z,
  zp.target_heading,
  zp.target_zone_id,
  zp.target_instance,
  zp.client_version_mask,
  zp.min_expansion,
  zp.max_expansion,
  zp.is_virtual,
  zp.height,
  zp.width
FROM zone_points zp
WHERE zp.target_zone_id IN (25, 27)
ORDER BY zp.target_zone_id, zp.target_instance, zp.zone, zp.version, zp.number, zp.id;

SELECT
  'candidate_zone_points_routing_to_new_instances' AS section,
  zp.id,
  zp.zone,
  zp.version,
  zp.number,
  zp.target_zone_id,
  zp.target_instance,
  zp.target_y,
  zp.target_x,
  zp.target_z,
  zp.target_heading,
  zp.min_expansion,
  zp.max_expansion,
  zp.client_version_mask
FROM zone_points zp
WHERE zp.target_zone_id IN (25, 27)
  AND (zp.target_instance <> 0 OR zp.min_expansion >= 9)
ORDER BY zp.target_zone_id, zp.zone, zp.version, zp.number, zp.id;

SELECT
  'doors_from_or_to_old_target_zones' AS section,
  d.id,
  d.doorid,
  d.zone,
  d.version,
  d.name,
  d.pos_y,
  d.pos_x,
  d.pos_z,
  d.heading,
  d.opentype,
  d.dest_zone,
  d.dest_instance,
  d.dest_x,
  d.dest_y,
  d.dest_z,
  d.dest_heading,
  d.client_version_mask,
  d.min_expansion,
  d.max_expansion
FROM doors d
WHERE d.zone IN ('nektulos', 'lavastorm')
   OR d.dest_zone IN ('nektulos', 'lavastorm')
ORDER BY d.dest_zone, d.dest_instance, d.zone, d.version, d.doorid, d.id;

SELECT
  'candidate_doors_routing_to_new_instances' AS section,
  d.id,
  d.doorid,
  d.zone,
  d.version,
  d.name,
  d.dest_zone,
  d.dest_instance,
  d.dest_x,
  d.dest_y,
  d.dest_z,
  d.dest_heading,
  d.client_version_mask,
  d.min_expansion,
  d.max_expansion
FROM doors d
WHERE d.dest_zone IN ('nektulos', 'lavastorm')
  AND (d.dest_instance <> 0 OR d.min_expansion >= 9)
ORDER BY d.dest_zone, d.dest_instance, d.zone, d.version, d.doorid, d.id;

SELECT
  'poknowledge_target_doors' AS section,
  d.id,
  d.doorid,
  d.zone,
  d.version,
  d.name,
  d.pos_y,
  d.pos_x,
  d.pos_z,
  d.heading,
  d.opentype,
  d.dest_zone,
  d.dest_instance,
  d.dest_x,
  d.dest_y,
  d.dest_z,
  d.dest_heading,
  d.client_version_mask,
  d.min_expansion,
  d.max_expansion
FROM doors d
WHERE d.zone IN ('poknowledge', 'poknowledgeb')
  AND d.dest_zone IN ('nektulos', 'lavastorm')
ORDER BY d.dest_zone, d.dest_instance, d.doorid, d.id;

SELECT
  'teleport_spell_candidates' AS section,
  s.id,
  s.name,
  s.teleport_zone,
  s.targettype,
  s.effectid1,
  s.effectid2,
  s.effectid3,
  s.effectid4,
  s.effect_base_value1,
  s.effect_base_value2,
  s.effect_base_value3,
  s.effect_base_value4,
  s.max1,
  s.max2,
  s.max3,
  s.max4,
  s.classes5 AS druid_level,
  s.classes13 AS wizard_level
FROM spells_new s
WHERE s.teleport_zone IN ('nektulos', 'lavastorm')
   OR s.name REGEXP '(^|[[:space:]])(Nektulos|Nek|Lavastorm|Lava)([[:space:]]|$)'
   OR s.name REGEXP '^(Circle|Ring|Portal|Translocate|Translocate:|Evacuate|Succor|Abscond).*?(Nektulos|Nek|Lavastorm|Lava)'
ORDER BY s.teleport_zone, s.id
LIMIT 300;

SELECT
  'spawn2_version_summary' AS section,
  zone,
  version,
  COUNT(*) AS spawn2_rows,
  MIN(min_expansion) AS min_spawn_expansion,
  MAX(max_expansion) AS max_spawn_expansion
FROM spawn2
WHERE zone IN ('nektulos', 'lavastorm')
GROUP BY zone, version
ORDER BY zone, version;

SELECT
  'candidate_followup' AS section,
  'Next migration should be old-zone-only and should back up zone, zone_points, doors, and any touched spell rows. Do not apply until port-in coordinates are validated from client testing or a trusted reference DB.' AS note;
