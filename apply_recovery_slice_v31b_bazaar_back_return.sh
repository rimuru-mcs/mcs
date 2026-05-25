#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-/opt/msr/repo/msr}"
AA_CPP="$REPO/zone/aa.cpp"

if [[ ! -f "$AA_CPP" ]]; then
  echo "ERROR: zone/aa.cpp not found at: $AA_CPP" >&2
  exit 1
fi

python3 - "$AA_CPP" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()

func_sig = "void Client::ActivateAlternateAdvancementAbility(int rank_id, int target_id) {"
func_start = text.find(func_sig)
if func_start < 0:
    raise SystemExit("ERROR: Could not find Client::ActivateAlternateAdvancementAbility in zone/aa.cpp")

ability_block = re.search(
    r"\n(\s*if\s*\(!ability\)\s*\{\s*return;\s*\}\s*)",
    text[func_start:],
    flags=re.DOTALL,
)
if not ability_block:
    raise SystemExit("ERROR: Could not find the !ability guard inside ActivateAlternateAdvancementAbility")

insert_at = func_start + ability_block.end()

generic_marker = text.find("\n\tif (!IsValidSpell(rank->spell))", insert_at)
if generic_marker < 0:
    generic_marker = text.find("\n        if (!IsValidSpell(rank->spell))", insert_at)
if generic_marker < 0:
    raise SystemExit("ERROR: Could not find IsValidSpell marker after AA custom block")

new_block = r'''
	// --- Custom handling for Bazaar and Back / Origin AA ---
	// MSR recovery:
	// The recovered DB uses aa_ability.id = 331 for Origin and aa_ranks.id = 1000.
	// zone/aa.h defines aaOrigin = 1000, so check both ability and rank shapes.
	//
	// Outside Bazaar:
	//   save the current location into character buckets and move to one of the
	//   two known Bazaar landing spots used by the live server/THJ behavior.
	//
	// Inside Bazaar:
	//   read Return-* buckets and move the player back to the saved location.
	if (rank->id == aaOrigin || ability->id == aaOrigin || ability->id == 331) {
		std::string current_zone = zone->GetShortName();
		std::transform(current_zone.begin(), current_zone.end(), current_zone.begin(), ::tolower);

		auto bucket_to_float = [](const std::string& value, float fallback) -> float {
			if (value.empty()) {
				return fallback;
			}

			char* end = nullptr;
			const float parsed = std::strtof(value.c_str(), &end);
			return (end && end != value.c_str()) ? parsed : fallback;
		};

		auto bucket_to_uint32 = [](const std::string& value, uint32 fallback) -> uint32 {
			if (value.empty()) {
				return fallback;
			}

			char* end = nullptr;
			const unsigned long parsed = std::strtoul(value.c_str(), &end, 10);
			return (end && end != value.c_str()) ? static_cast<uint32>(parsed) : fallback;
		};

		if (current_zone == "bazaar") {
			std::string return_zone = GetBucket("Return-Zone");
			std::transform(return_zone.begin(), return_zone.end(), return_zone.begin(), ::tolower);

			if (!return_zone.empty()) {
				uint32 return_zone_id = ZoneID(return_zone.c_str());

				if (return_zone_id != 0) {
					float return_x = bucket_to_float(GetBucket("Return-X"), 0.0f);
					float return_y = bucket_to_float(GetBucket("Return-Y"), 0.0f);
					float return_z = bucket_to_float(GetBucket("Return-Z"), 0.0f);
					float return_h = bucket_to_float(GetBucket("Return-H"), 0.0f);
					uint32 return_instance = bucket_to_uint32(GetBucket("Return-Instance"), 0);

					MovePC(return_zone_id, return_instance, return_x, return_y, return_z, return_h);
					return;
				}
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

		if ((CharacterID() % 2) == 0) {
			MovePC(bazaar_id, 0, -151.44f, 168.93f, -16.25f, 0.0f);
		} else {
			MovePC(bazaar_id, 0, -151.47f, -177.88f, -16.25f, 0.0f);
		}

		return;
	}
	// --- End custom handling for Bazaar and Back / Origin AA ---
'''

patched = text[:insert_at] + new_block + text[generic_marker:]

if patched == text:
    raise SystemExit("ERROR: Patch produced no changes")

backup = path.with_suffix(path.suffix + ".v31b_bazaar_back_return.bak")
if not backup.exists():
    backup.write_text(text)

path.write_text(patched)
print(f"Patched {path}")
print(f"Backup: {backup}")
PY
