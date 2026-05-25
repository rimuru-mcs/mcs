#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-/opt/msr/repo/msr}"
AA_CPP="$REPO/zone/aa.cpp"

if [[ ! -f "$AA_CPP" ]]; then
  echo "ERROR: zone/aa.cpp not found at: $AA_CPP" >&2
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="$AA_CPP.v31_bazaar_back_return_backup_$STAMP"
cp "$AA_CPP" "$BACKUP"

python3 - "$AA_CPP" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

start_marker = "        // --- Custom handling for Origin AA ---"
end_marker = "        // --- End custom Origin handling ---"

# If v30 already changed the marker, support that too.
if start_marker not in text:
    start_marker = "        // --- Custom handling for Bazaar and Back / Origin AA ---"
if end_marker not in text:
    end_marker = "        // --- End custom Bazaar and Back / Origin handling ---"

start = text.find(start_marker)
if start == -1:
    raise SystemExit("ERROR: Could not find Origin/Bazaar AA custom handling start marker in zone/aa.cpp")

end = text.find(end_marker, start)
if end == -1:
    raise SystemExit("ERROR: Could not find Origin/Bazaar AA custom handling end marker in zone/aa.cpp")

end += len(end_marker)

replacement = r"""        // --- Custom handling for Bazaar and Back / Origin AA ---
        //
        // In this recovered MSR/NMS branch, the player-facing "Bazaar and Back"
        // button is implemented through the Origin AA rank. The aaOrigin constant
        // maps to rank id 1000, while the database ability id for Origin is 331.
        // Check both the rank id and ability id so this survives the recovered
        // schema mismatch.
        if (rank->id == aaOrigin || ability->id == aaOrigin || ability->id == 331) {
                std::string current_zone = zone->GetShortName();
                std::transform(current_zone.begin(), current_zone.end(), current_zone.begin(), ::tolower);

                auto bucket_to_float = [](const std::string& value, float fallback) -> float {
                        if (value.empty()) {
                                return fallback;
                        }

                        try {
                                return std::stof(value);
                        } catch (...) {
                                return fallback;
                        }
                };

                auto bucket_to_uint32 = [](const std::string& value, uint32 fallback) -> uint32 {
                        if (value.empty()) {
                                return fallback;
                        }

                        try {
                                return static_cast<uint32>(std::stoul(value));
                        } catch (...) {
                                return fallback;
                        }
                };

                if (current_zone == "bazaar") {
                        std::string return_zone = GetBucket("Return-Zone");
                        std::transform(return_zone.begin(), return_zone.end(), return_zone.begin(), ::tolower);

                        uint32 return_zone_id = return_zone.empty() ? 0 : ZoneID(return_zone.c_str());

                        if (return_zone_id != 0) {
                                float return_x = bucket_to_float(GetBucket("Return-X"), GetX());
                                float return_y = bucket_to_float(GetBucket("Return-Y"), GetY());
                                float return_z = bucket_to_float(GetBucket("Return-Z"), GetZ());
                                float return_h = bucket_to_float(GetBucket("Return-H"), GetHeading());
                                uint32 return_instance = bucket_to_uint32(GetBucket("Return-Instance"), 0);

                                MovePC(return_zone_id, return_instance, return_x, return_y, return_z, return_h);
                        }

                        return;
                }

                SetBucket("Return-Zone", current_zone, "0");
                SetBucket("Return-X", std::to_string(GetX()), "0");
                SetBucket("Return-Y", std::to_string(GetY()), "0");
                SetBucket("Return-Z", std::to_string(GetZ()), "0");
                SetBucket("Return-H", std::to_string(GetHeading()), "0");
                SetBucket("Return-Instance", std::to_string(zone->GetInstanceID()), "0");

                uint32 bazaar_id = ZoneID("bazaar");

                // Live/THJ-style recovery behavior: use one of two Bazaar landing
                // spots instead of dumping every player at 0,0,0.
                //
                // Landing A: /loc -151.44, 168.93, -16.25
                // Landing B: /loc -151.47, -177.88, -16.25
                //
                // Character id parity gives a stable split without depending on
                // additional RNG helpers in this older recovered source.
                if ((CharacterID() % 2) == 0) {
                        MovePC(bazaar_id, 0, -151.44f, 168.93f, -16.25f, 0.0f);
                } else {
                        MovePC(bazaar_id, 0, -151.47f, -177.88f, -16.25f, 0.0f);
                }

                return;
        }
        // --- End custom Bazaar and Back / Origin handling ---"""

new_text = text[:start] + replacement + text[end:]
path.write_text(new_text)
PY

echo "Patched: $AA_CPP"
echo "Backup:  $BACKUP"
