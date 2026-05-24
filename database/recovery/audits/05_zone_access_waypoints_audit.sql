-- MSR Recovery Audit 05: zone access, safe points, doors, and waypoint-adjacent data
-- Covers Nektulos, Lavastorm, Blackburrow, Crescent Reach, Rathe Mountains, starter cities/newbie areas,
-- and classic planes visibility/access candidates.

SELECT 'audit' AS section, '05_zone_access_waypoints' AS audit_name, NOW() AS audited_at;

SELECT
  id,
  zoneidnumber,
  version,
  short_name,
  long_name,
  min_expansion,
  max_expansion,
  expansion,
  min_level,
  max_level,
  bypass_expansion_check,
  safe_x,
  safe_y,
  safe_z,
  safe_heading,
  graveyard_id,
  flag_needed,
  canbind,
  cancombat
FROM zone
WHERE short_name IN (
  'nektulos', 'nektulosa', 'lavastorm', 'blackburrow', 'crescent', 'crescentreach',
  'rathemtn', 'rathemountains', 'qeynos', 'qeynos2', 'qrg', 'qeytoqrg', 'halas',
  'everfrost', 'gfaydark', 'felwithea', 'felwitheb', 'akanon', 'steamfont',
  'kaladima', 'kaladimb', 'butcher', 'freportw', 'freporte', 'freportn', 'commons',
  'grobb', 'innothule', 'oggok', 'feerrott', 'neriaka', 'neriakb', 'neriakc',
  'tox', 'erudnext', 'erudnint', 'paineel', 'sharvahl', 'shadeweaver',
  'airplane', 'fearplane', 'hateplane', 'growthplane', 'mischiefplane', 'skyshrine',
  'pofire', 'poair', 'poeartha', 'poearthb', 'powater', 'potactics', 'postorms',
  'pojustice', 'ponightmare', 'podisease', 'poinnovation', 'potorment', 'bothunder'
)
ORDER BY zoneidnumber, version, short_name;

SELECT
  id,
  zone,
  version,
  number,
  x,
  y,
  z,
  heading,
  target_zone_id,
  target_instance,
  target_x,
  target_y,
  target_z,
  target_heading,
  min_expansion,
  max_expansion,
  content_flags,
  content_flags_disabled,
  is_virtual,
  height,
  width
FROM zone_points
WHERE zone IN (
  'nektulos', 'nektulosa', 'lavastorm', 'blackburrow', 'crescent', 'crescentreach',
  'rathemtn', 'rathemountains', 'airplane', 'fearplane', 'hateplane', 'growthplane',
  'mischiefplane'
)
   OR target_zone_id IN (
      SELECT zoneidnumber FROM zone WHERE short_name IN (
        'nektulos', 'nektulosa', 'lavastorm', 'blackburrow', 'crescent', 'crescentreach',
        'rathemtn', 'rathemountains', 'airplane', 'fearplane', 'hateplane', 'growthplane',
        'mischiefplane'
      )
   )
ORDER BY zone, version, number;

SELECT
  id,
  doorid,
  zone,
  version,
  name,
  opentype,
  keyitem,
  lockpick,
  dest_zone,
  dest_x,
  dest_y,
  dest_z,
  min_expansion,
  max_expansion,
  content_flags,
  content_flags_disabled
FROM doors
WHERE zone IN ('blackburrow', 'nektulos', 'nektulosa', 'lavastorm')
ORDER BY zone, version, doorid;
