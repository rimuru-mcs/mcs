-- Recovery Slice v27 pending review: expansion-race starter envelopes.
--
-- This file is intentionally NOT applied by recovery/apply_db_migrations.sh.
-- It records the next review target after the immediate revamped-Freeport start fix.
--
-- Doctrine:
--   All races/classes are playable from server start, but expansion-origin characters should
--   receive only racial starter/sanctuary access until their broader expansion progression is unlocked.
--
-- Examples:
--   Iksar: Cabilis + Field of Bone + maybe Lake of Ill Omen; not Firiona Vie/Emerald Jungle/Dreadlands/etc.
--   Vah Shir: Shar Vahl + nearby starter envelope; not broad Luclin.
--   Froglok: likely Rathe Mountains in MSR/THJ-style progression, not a Grobb world-state takeover.
--   Drakkin: likely Crescent Reach/start envelope if enabled.
--
-- Review query only:

SELECT
  'pending_v27_expansion_race_start_envelope_review' AS section,
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
  sz.min_expansion,
  sz.max_expansion,
  sz.content_flags,
  sz.content_flags_disabled
FROM start_zones sz
LEFT JOIN zone zone_by_zone_id ON zone_by_zone_id.zoneidnumber = sz.zone_id
LEFT JOIN zone zone_by_start_zone ON zone_by_start_zone.zoneidnumber = sz.start_zone
WHERE zone_by_zone_id.short_name IN (
      'cabeast', 'cabwest', 'fieldofbone', 'lakeofillomen', 'firiona', 'emeraldjungle',
      'dreadlands', 'sharvahl', 'shadeweaver', 'rathemtn', 'grobb', 'gukta', 'crescent'
   )
   OR zone_by_start_zone.short_name IN (
      'cabeast', 'cabwest', 'fieldofbone', 'lakeofillomen', 'firiona', 'emeraldjungle',
      'dreadlands', 'sharvahl', 'shadeweaver', 'rathemtn', 'grobb', 'gukta', 'crescent'
   )
ORDER BY sz.player_race, sz.player_class, sz.player_deity, sz.zone_id, sz.start_zone, sz.x, sz.y, sz.z;
