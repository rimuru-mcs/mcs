-- Recovery Slice v27 audit: start-zone/progression alignment.
-- Purpose:
--   Identify start rows that route new characters into revamped Freeport/new-era zones too early,
--   while preserving the MSR/THJ rule that expansion-native races/classes may still start in
--   their racial sanctuary areas without unlocking the whole expansion.
--
-- This audit is read-only.

SELECT
  'v27_relevant_zone_rows' AS section,
  z.zoneidnumber,
  z.short_name,
  z.long_name,
  z.version,
  z.min_expansion,
  z.max_expansion
FROM zone z
WHERE z.zoneidnumber IN (8, 9, 10, 82, 383, 384, 385, 386, 387, 388, 389, 390, 391)
   OR z.short_name IN (
      'freportn', 'freportw', 'freporte',
      'freeportwest', 'freeporteast', 'freeportsewers', 'freeportacademy',
      'freeporttemple', 'freeportmilitia', 'freeportarena', 'freeportcityhall', 'freeporttheater',
      'crescent', 'cabeast', 'cabwest', 'fieldofbone', 'lakeofillomen',
      'sharvahl', 'shadeweaver', 'rathemtn', 'grobb', 'gukta'
   )
ORDER BY z.zoneidnumber, z.version, z.short_name;

SELECT
  'v27_revamped_freeport_start_rows' AS section,
  sz.player_choice,
  sz.player_class,
  sz.player_deity,
  sz.player_race,
  sz.zone_id,
  zone_by_zone_id.short_name AS zone_short_name,
  sz.start_zone,
  zone_by_start_zone.short_name AS start_zone_short_name,
  sz.x,
  sz.y,
  sz.z,
  sz.heading,
  sz.bind_id,
  sz.bind_x,
  sz.bind_y,
  sz.bind_z,
  sz.min_expansion,
  sz.max_expansion,
  sz.content_flags,
  sz.content_flags_disabled
FROM start_zones sz
LEFT JOIN zone zone_by_zone_id ON zone_by_zone_id.zoneidnumber = sz.zone_id
LEFT JOIN zone zone_by_start_zone ON zone_by_start_zone.zoneidnumber = sz.start_zone
WHERE sz.zone_id IN (383, 384, 385, 386, 387, 388, 389, 390, 391)
   OR sz.start_zone IN (383, 384, 385, 386, 387, 388, 389, 390, 391)
   OR zone_by_zone_id.short_name IN (
      'freeportwest', 'freeporteast', 'freeportsewers', 'freeportacademy',
      'freeporttemple', 'freeportmilitia', 'freeportarena', 'freeportcityhall', 'freeporttheater'
   )
   OR zone_by_start_zone.short_name IN (
      'freeportwest', 'freeporteast', 'freeportsewers', 'freeportacademy',
      'freeporttemple', 'freeportmilitia', 'freeportarena', 'freeportcityhall', 'freeporttheater'
   )
ORDER BY sz.player_race, sz.player_class, sz.player_deity, sz.zone_id, sz.start_zone, sz.x, sz.y, sz.z;

SELECT
  'v27_old_freeport_default_start_rows' AS section,
  sz.player_choice,
  sz.player_class,
  sz.player_deity,
  sz.player_race,
  sz.zone_id,
  zone_by_zone_id.short_name AS zone_short_name,
  sz.start_zone,
  zone_by_start_zone.short_name AS start_zone_short_name,
  sz.x,
  sz.y,
  sz.z,
  sz.heading,
  sz.min_expansion,
  sz.max_expansion,
  sz.content_flags,
  sz.content_flags_disabled
FROM start_zones sz
LEFT JOIN zone zone_by_zone_id ON zone_by_zone_id.zoneidnumber = sz.zone_id
LEFT JOIN zone zone_by_start_zone ON zone_by_start_zone.zoneidnumber = sz.start_zone
WHERE sz.zone_id IN (8, 9, 10)
   OR sz.start_zone IN (8, 9, 10)
   OR zone_by_zone_id.short_name IN ('freportn', 'freportw', 'freporte')
   OR zone_by_start_zone.short_name IN ('freportn', 'freportw', 'freporte')
ORDER BY sz.player_race, sz.player_class, sz.player_deity, sz.zone_id, sz.start_zone, sz.x, sz.y, sz.z;

SELECT
  'v27_crescent_reach_start_rows' AS section,
  sz.player_choice,
  sz.player_class,
  sz.player_deity,
  sz.player_race,
  sz.zone_id,
  zone_by_zone_id.short_name AS zone_short_name,
  sz.start_zone,
  zone_by_start_zone.short_name AS start_zone_short_name,
  sz.x,
  sz.y,
  sz.z,
  sz.heading,
  sz.min_expansion,
  sz.max_expansion,
  sz.content_flags,
  sz.content_flags_disabled
FROM start_zones sz
LEFT JOIN zone zone_by_zone_id ON zone_by_zone_id.zoneidnumber = sz.zone_id
LEFT JOIN zone zone_by_start_zone ON zone_by_start_zone.zoneidnumber = sz.start_zone
WHERE zone_by_zone_id.short_name = 'crescent'
   OR zone_by_start_zone.short_name = 'crescent'
ORDER BY sz.player_race, sz.player_class, sz.player_deity, sz.zone_id, sz.start_zone, sz.x, sz.y, sz.z;

SELECT
  'v27_expansion_race_sanctuary_candidate_rows' AS section,
  sz.player_choice,
  sz.player_class,
  sz.player_deity,
  sz.player_race,
  sz.zone_id,
  zone_by_zone_id.short_name AS zone_short_name,
  sz.start_zone,
  zone_by_start_zone.short_name AS start_zone_short_name,
  sz.x,
  sz.y,
  sz.z,
  sz.heading,
  sz.min_expansion,
  sz.max_expansion,
  sz.content_flags,
  sz.content_flags_disabled
FROM start_zones sz
LEFT JOIN zone zone_by_zone_id ON zone_by_zone_id.zoneidnumber = sz.zone_id
LEFT JOIN zone zone_by_start_zone ON zone_by_start_zone.zoneidnumber = sz.start_zone
WHERE zone_by_zone_id.short_name IN (
      'cabeast', 'cabwest', 'fieldofbone', 'lakeofillomen',
      'sharvahl', 'shadeweaver', 'rathemtn', 'crescent'
   )
   OR zone_by_start_zone.short_name IN (
      'cabeast', 'cabwest', 'fieldofbone', 'lakeofillomen',
      'sharvahl', 'shadeweaver', 'rathemtn', 'crescent'
   )
ORDER BY sz.player_race, sz.player_class, sz.player_deity, sz.zone_id, sz.start_zone, sz.x, sz.y, sz.z;

SELECT
  'v27_characters_in_revamped_freeport' AS section,
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
WHERE cd.zone_id IN (383, 384, 385, 386, 387, 388, 389, 390, 391)
   OR z.short_name IN (
      'freeportwest', 'freeporteast', 'freeportsewers', 'freeportacademy',
      'freeporttemple', 'freeportmilitia', 'freeportarena', 'freeportcityhall', 'freeporttheater'
   )
ORDER BY cd.name;

SELECT
  'v27_post_migration_active_revamped_freeport_check' AS section,
  COUNT(*) AS revamped_freeport_rows_total,
  SUM(CASE WHEN sz.content_flags = 'msr_revamped_freeport_unlocked' THEN 1 ELSE 0 END) AS gated_by_v27_count,
  SUM(CASE WHEN sz.content_flags IS NULL OR sz.content_flags = '' THEN 1 ELSE 0 END) AS still_ungated_blank_content_flags_count
FROM start_zones sz
LEFT JOIN zone zone_by_zone_id ON zone_by_zone_id.zoneidnumber = sz.zone_id
LEFT JOIN zone zone_by_start_zone ON zone_by_start_zone.zoneidnumber = sz.start_zone
WHERE sz.zone_id IN (383, 384, 385, 386, 387, 388, 389, 390, 391)
   OR sz.start_zone IN (383, 384, 385, 386, 387, 388, 389, 390, 391)
   OR zone_by_zone_id.short_name IN (
      'freeportwest', 'freeporteast', 'freeportsewers', 'freeportacademy',
      'freeporttemple', 'freeportmilitia', 'freeportarena', 'freeportcityhall', 'freeporttheater'
   )
   OR zone_by_start_zone.short_name IN (
      'freeportwest', 'freeporteast', 'freeportsewers', 'freeportacademy',
      'freeporttemple', 'freeportmilitia', 'freeportarena', 'freeportcityhall', 'freeporttheater'
   );
