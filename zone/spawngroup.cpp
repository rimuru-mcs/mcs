/*	EQEMu: Everquest Server Emulator
	Copyright (C) 2001-2002 EQEMu Development Team (http://eqemu.org)

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; version 2 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY except by those people which sell it, which
	are required to give you total support for your newly bought product;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR
	A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#include <fmt/format.h>
#include "../common/global_define.h"
#include "../common/types.h"

#include "entity.h"
#include "spawngroup.h"
#include "zone.h"
#include "zonedb.h"
#include "../common/repositories/criteria/content_filter_criteria.h"

extern EntityList entity_list;
extern Zone       *zone;

SpawnEntry::SpawnEntry(uint32 in_NPCType, int in_chance, uint16 in_filter, uint8 in_npc_spawn_limit, uint8 in_min_time, uint8 in_max_time) {
	NPCType                = in_NPCType;
	chance                 = in_chance;
	condition_value_filter = in_filter;
	npc_spawn_limit        = in_npc_spawn_limit;
	min_time               = in_min_time;
	max_time               = in_max_time;
}

SpawnGroup::SpawnGroup(
	uint32 in_id,
	char *name,
	int in_group_spawn_limit,
	float dist,
	float maxx,
	float minx,
	float maxy,
	float miny,
	int delay_in,
	int despawn_in,
	uint32 despawn_timer_in,
	int min_delay_in,
	bool wp_spawns_in
)
{
	id = in_id;
	strn0cpy(name_, name, 120);
	group_spawn_limit = in_group_spawn_limit;
	roambox[0] = maxx;
	roambox[1] = minx;
	roambox[2] = maxy;
	roambox[3] = miny;
	roamdist      = dist;
	min_delay     = min_delay_in;
	delay         = delay_in;
	despawn       = despawn_in;
	despawn_timer = despawn_timer_in;
	wp_spawns = wp_spawns_in;
}

uint32 SpawnGroup::GetNPCType(uint16 in_filter)
{
	int totalchance = 0;

	// kraqur: --- Group spawn limit check ---
	if (!entity_list.LimitCheckGroup(id, group_spawn_limit)) {
		return 0;
	}

	// Kraqur: --- Build candidate list ---
	// Consolidated formatting and removed duplicate variable declaration. 
	// Each SpawnEntry is checked against type limits, time windows, and filters.
	std::list<SpawnEntry*> possible;
	for (auto& it : list_) {
		auto se = it.get();

		if (!entity_list.LimitCheckType(se->NPCType, se->npc_spawn_limit)) {
			continue;
		}

		if (se->min_time != 0 && se->max_time != 0 && se->min_time <= 24 && se->max_time <= 24) {
			if (!zone->zone_time.IsInbetweenTime(se->min_time, se->max_time)) {
				continue;
			}
		}

		if (se->condition_value_filter != in_filter) {
			continue;
		}

		totalchance += se->chance;
		possible.push_back(se);
	}

	if (totalchance == 0) {
		return 0;
	}

	// Kraqur: Custom spawn override logic.
	// Applies special spawn behavior inside static and farming expeditions.
	// Static expeditions force the lowest-chance entry (boss).
	// Farming expeditions exclude the lowest-chance entry (raid) and block
	// single-entry groups from spawning.

	if (zone) {
		const int static_ver = RuleI(Custom, StaticInstanceVersion);   // now 101
		const int farming_ver = RuleI(Custom, FarmingInstanceVersion);  // now 100

		const bool static_on = RuleB(Custom, StaticInstanceMode);
		const bool farming_on = RuleB(Custom, FarmingInstanceMode);

		const int cur_ver = zone->GetInstanceVersion();

		//Kraqur: Static expedition logic.
		// When inside a static expedition, always spawn the lowest-chance entry.
		// This forces named or boss mobs to appear instead of trash.
		// If multiple entries share the same lowest chance, pick one at random.

		if (cur_ver == static_ver && static_on) {
			int lowestChance = INT_MAX;
			std::vector<SpawnEntry*> lowestEntries;

			for (auto se : possible) {
				if (se->chance < lowestChance) {
					lowestChance = se->chance;
					lowestEntries.clear();
					lowestEntries.push_back(se);
				}
				else if (se->chance == lowestChance) {
					lowestEntries.push_back(se);
				}
			}

			if (!lowestEntries.empty()) {
				auto it = lowestEntries.begin();
				std::advance(it, zone->random.Int(0, static_cast<int>(lowestEntries.size()) - 1));
				return (*it)->NPCType;
			}
		}

		// Kraqur: Farming expedition logic.
		// When inside a farming expedition:
		// - Block single-entry spawn groups (return no spawn).
		// - Identify the lowest-chance entry (usually raid or named).
		// - Remove the lowest-chance entry from the candidate list.
		// - If all remaining entries have equal chance, pick one at random.
		// - Otherwise, perform a weighted roll using the filtered list.
		else if (cur_ver == farming_ver && farming_on) {
			if (possible.size() == 1) {
				return 0; // no spawn
			}

			int lowestChance = INT_MAX;
			for (auto se : possible) {
				if (se->chance < lowestChance) {
					lowestChance = se->chance;
				}
			}

			std::vector<SpawnEntry*> filtered;
			int totalchanceFiltered = 0;
			for (auto se : possible) {
				if (se->chance != lowestChance) {
					filtered.push_back(se);
					totalchanceFiltered += se->chance;
				}
			}

			if (!filtered.empty()) {
				bool allEqual = true;
				int firstChance = filtered.front()->chance;
				for (auto se : filtered) {
					if (se->chance != firstChance) {
						allEqual = false;
						break;
					}
				}

				if (allEqual) {
					auto it = filtered.begin();
					std::advance(it, zone->random.Int(0, static_cast<int>(filtered.size()) - 1));
					return (*it)->NPCType;
				}

				int32 roll = zone->random.Int(0, totalchanceFiltered - 1);
				for (auto se : filtered) {
					if (roll < se->chance) {
						return se->NPCType;
					}
					roll -= se->chance;
				}
			}
		}
		// Any other instance version or flags disabled  fall through
	}

	// Normal zone or non-expedition fallback.
	// If no special expedition rules apply, perform the standard weighted roll
	// across all possible entries.

	int32 roll = zone->random.Int(0, totalchance - 1);
	for (auto se : possible) {
		if (roll < se->chance) {
			return se->NPCType;
		}
		roll -= se->chance;
	}

	return 0;
}

void SpawnGroup::AddSpawnEntry(std::unique_ptr<SpawnEntry> &newEntry)
{
	list_.push_back(std::move(newEntry));
}

SpawnGroup::~SpawnGroup()
{
	list_.clear();
}

SpawnGroupList::~SpawnGroupList()
{
	m_spawn_groups.clear();
}

void SpawnGroupList::AddSpawnGroup(std::unique_ptr<SpawnGroup> &new_group)
{
	if (new_group == nullptr) {
		return;
	}

	m_spawn_groups[new_group->id] = std::move(new_group);
}

SpawnGroup *SpawnGroupList::GetSpawnGroup(uint32 in_id)
{
	if (m_spawn_groups.count(in_id) != 1) {
		return nullptr;
	}

	return (m_spawn_groups[in_id].get());
}

void SpawnGroupList::ReloadSpawnGroups()
{
	ClearSpawnGroups();
	content_db.LoadSpawnGroups(zone->GetShortName(), zone->GetInstanceVersion(), &zone->spawn_group_list);
}

void SpawnGroupList::ClearSpawnGroups()
{
	m_spawn_groups.clear();
}

bool ZoneDatabase::LoadSpawnGroups(const char *zone_name, uint16 version, SpawnGroupList *spawn_group_list)
{
	std::string query = fmt::format(
		SQL(
			SELECT
			DISTINCT(spawngroupID),
			spawngroup.name,
			spawngroup.spawn_limit,
			spawngroup.dist,
			spawngroup.max_x,
			spawngroup.min_x,
			spawngroup.max_y,
			spawngroup.min_y,
			spawngroup.delay,
			spawngroup.despawn,
			spawngroup.despawn_timer,
			spawngroup.mindelay,
			spawngroup.wp_spawns
				FROM
				spawn2,
			spawngroup
				WHERE
				spawn2.spawngroupID = spawngroup.ID
				AND
				(spawn2.version = {} OR version = -1)
				AND zone = '{}'
				{}
		),
		version,
		zone_name,
		ContentFilterCriteria::apply()
	);

	auto results = QueryDatabase(query);
	if (!results.Success()) {
		return false;
	}

	for (auto row = results.begin(); row != results.end(); ++row) {
		auto new_spawn_group = std::make_unique<SpawnGroup>(
			Strings::ToInt(row[0]),
			row[1],
			Strings::ToInt(row[2]),
			Strings::ToFloat(row[3]),
			Strings::ToFloat(row[4]),
			Strings::ToFloat(row[5]),
			Strings::ToFloat(row[6]),
			Strings::ToFloat(row[7]),
			Strings::ToInt(row[8]),
			Strings::ToInt(row[9]),
			Strings::ToInt(row[10]),
			Strings::ToInt(row[11]),
			Strings::ToInt(row[12])
		);

		spawn_group_list->AddSpawnGroup(new_spawn_group);
	}

	LogInfo("Loaded [{}] spawn group(s)", Strings::Commify(results.RowCount()));

	query = fmt::format(
		SQL(
			SELECT
				DISTINCT
			spawnentry.spawngroupID,
			npcid,
			chance,
			condition_value_filter,
			npc_types.spawn_limit
				AS sl,
				min_time,
				max_time
				FROM
				spawnentry,
			spawn2,
			npc_types
				WHERE
				spawnentry.npcID = npc_types.id
				AND
				spawnentry.spawngroupID = spawn2.spawngroupID
				AND
				zone = '{}'
				{}
					),
		zone_name,
		ContentFilterCriteria::apply("spawnentry")
	);

	results = QueryDatabase(query);
	if (!results.Success()) {
		return false;
	}

	for (auto row = results.begin(); row != results.end(); ++row) {
		auto new_spawn_entry = std::make_unique<SpawnEntry>(
			Strings::ToInt(row[1]),
			Strings::ToInt(row[2]),
			Strings::ToInt(row[3]),
			(row[4] ? Strings::ToInt(row[4]) : 0),
			Strings::ToInt(row[5]),
			Strings::ToInt(row[6])
		);

		SpawnGroup *spawn_group = spawn_group_list->GetSpawnGroup(Strings::ToInt(row[0]));

		if (!spawn_group) {
			continue;
		}

		spawn_group->AddSpawnEntry(new_spawn_entry);
	}

	LogInfo("Loaded [{}] spawn entries", Strings::Commify(results.RowCount()));


	return true;
}

/**
 * @param spawn_group_id
 * @param spawn_group_list
 * @return
 */
bool ZoneDatabase::LoadSpawnGroupsByID(int spawn_group_id, SpawnGroupList *spawn_group_list)
{
	std::string query = fmt::format(
		SQL(
			SELECT DISTINCT
			(spawngroup.id),
			spawngroup.name,
			spawngroup.spawn_limit,
			spawngroup.dist,
			spawngroup.max_x,
			spawngroup.min_x,
			spawngroup.max_y,
			spawngroup.min_y,
			spawngroup.delay,
			spawngroup.despawn,
			spawngroup.despawn_timer,
			spawngroup.mindelay,
			spawngroup.wp_spawns
				FROM
					spawngroup
				WHERE
				spawngroup.ID = '{}'
		),
		spawn_group_id
	);

	auto results = QueryDatabase(query);
	if (!results.Success()) {
		return false;
	}

	for (auto row = results.begin(); row != results.end(); ++row) {
		LogSpawnsDetail(
			"Loading spawn_group spawn_group_id [{}] name [{}] spawn_limit [{}] dist [{}]",
			row[0],
			row[1],
			row[2],
			row[3]
		);

		auto new_spawn_group = std::make_unique<SpawnGroup>(
			Strings::ToInt(row[0]),
			row[1],
			Strings::ToInt(row[2]),
			Strings::ToFloat(row[3]),
			Strings::ToFloat(row[4]),
			Strings::ToFloat(row[5]),
			Strings::ToFloat(row[6]),
			Strings::ToFloat(row[7]),
			Strings::ToInt(row[8]),
			Strings::ToInt(row[9]),
			Strings::ToInt(row[10]),
			Strings::ToInt(row[11]),
			Strings::ToInt(row[12])
		);

		spawn_group_list->AddSpawnGroup(new_spawn_group);
	}

	query   = fmt::format(
		SQL(
			SELECT DISTINCT
			(spawnentry.spawngroupID),
			spawnentry.npcid,
			spawnentry.chance,
			spawnentry.condition_value_filter,
			spawngroup.spawn_limit,
			spawnentry.min_time,
			spawnentry.max_time
				FROM
				spawnentry,
			spawngroup
				WHERE
				spawnentry.spawngroupID = '{}'
				AND spawngroup.spawn_limit = '0'
				ORDER BY chance),
		spawn_group_id
	);

	results = QueryDatabase(query);
	if (!results.Success()) {
		return false;
	}

	for (auto row = results.begin(); row != results.end(); ++row) {
		auto new_spawn_entry = std::make_unique<SpawnEntry>(
			Strings::ToInt(row[1]),
			Strings::ToInt(row[2]),
			Strings::ToInt(row[3]),
			(row[4] ? Strings::ToInt(row[4]) : 0),
			Strings::ToInt(row[5]),
			Strings::ToInt(row[6])
		);

		LogSpawnsDetail(
			"Loading spawn_entry spawn_group_id [{}] npc_id [{}] chance [{}] condition_value_filter [{}] spawn_limit [{}] min_time [{}] max_time [{}] ",
			row[0],
			row[1],
			row[2],
			row[3],
			row[4],
			row[5],
			row[6]
		);

		SpawnGroup *spawn_group = spawn_group_list->GetSpawnGroup(Strings::ToInt(row[0]));
		if (!spawn_group) {
			continue;
		}

		spawn_group->AddSpawnEntry(new_spawn_entry);
	}

	return true;
}
