-- MSR Recovery Pending Migration 040: zone/waypoint candidates
-- DO NOT AUTO-RUN. Coordinates and intended unlock model must be confirmed.

-- Crescent Reach special bypass from active expansion check.
-- Candidate, if short_name is confirmed as crescent or crescentreach:
-- UPDATE zone
-- SET bypass_expansion_check = 1
-- WHERE short_name IN ('crescent', 'crescentreach');

-- Nektulos/Lavastorm wrong NPC version/safe area/zoneline fix:
-- Use audit 05 to compare zone rows and zone_points versions.
-- Do not update versions blindly. These zones often have multiple era/version layouts.

-- Blackburrow doors set to Jaggedpine/progression-locked opentype:
-- Use audit 05 doors output before changing opentype/keyitem/min_expansion/max_expansion.
-- Candidate shape only:
-- UPDATE doors
-- SET opentype = <confirmed_open_type>, keyitem = 0, min_expansion = -1, max_expansion = -1
-- WHERE zone = 'blackburrow' AND doorid IN (<confirmed_door_ids>);

-- Rathe Mountains waypoint and starter city/newbie waypoints:
-- Requires waypoint schema/table confirmation. Not enough evidence to write a safe UPDATE yet.

-- Classic Planes visible at level 46:
-- Requires the waypoint/teleport source table and client-side map behavior confirmation.
