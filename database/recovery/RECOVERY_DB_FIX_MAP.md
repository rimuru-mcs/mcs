# MSR Database Recovery Fix Map

This file maps the lost update notes to database audit/recovery areas. It is intentionally conservative: entries marked `pending` need live database confirmation before they become auto-applied migrations.

| Date | Changelog item | Likely DB area | Status in this slice |
|---|---|---|---|
| 5/20 | Prevent corpse runs | `rule_values` character corpse/death rules | Pending candidate SQL |
| 5/20 | Remove TutorialB option from character create | `rule_values` world tutorial rules and/or client patch | Pending candidate SQL |
| 5/20 | Defiant gear should not spawn | `items`, `lootdrop_entries`, loot tables | Audit only |
| 5/20 | Nektulos version/zonelines/safe areas | `zone`, `zone_points`, possibly doors | Audit only |
| 5/20 | Lavastorm version/zonelines/safe areas | `zone`, `zone_points`, possibly doors | Audit only |
| 5/20 | Server buff prices lowered | NPC/merchant/quest data, possibly items | Audit later after NPC identified |
| 5/21 | Implied healing rule | `rule_values`: `Spells:UseSpellImpliedTargeting` | Pending candidate SQL |
| 5/21 | Blackburrow doors wrong opentype/progression lockout | `doors` | Audit only |
| 5/21 | Syncrosatchel ID mismatch | `items`, `merchantlist`, possibly code item IDs | Audit/pending candidate SQL |
| 5/21 | Zone access and progression max level | `zone`, `rule_values`, progression tables/buckets | Audit/pending candidate SQL |
| 5/21 | Global buffs 44000–44007 | `spells_new`, `rule_values`, item/spell scripts | Audit only |
| 5/21 | Crescent Reach bypass + waypoint | `zone.bypass_expansion_check`, waypoint data | Pending candidate SQL after coordinates confirmed |
| 5/21 | Rathe Mountains waypoint | waypoint data | Pending candidate SQL after coordinates confirmed |
| 5/21 | Starter cities/newbie waypoint unlocks | waypoint data / zone access | Audit only |
| 5/21 | Classic Planes revealed at level 46 | waypoint/teleport/progression data | Audit only |
| 5/23 | Global buff toggle | `rule_values`: `Custom:PermanentServerBuffsEnabled` | Safe placeholder only, default false |
| 5/23 | Global buffs reduced to 4 and combined into Echo of Power | `spells_new` IDs 44000–44007 and client spell file alignment | Audit/pending only |
| 5/23 | 21-slot bag restored | `items`, `merchantlist` | Audit only |
| 5/23 | Missing items / lower expansion merchant visibility | `merchantlist.min_expansion/max_expansion`, `items` | Audit only |
| 5/23 | Sympathetic items proc at all levels | `items.proclevel`, `items.proclevel2`, spell refs | Audit/pending only |
| 5/23 | Simple Ring of the Hero gets Sympathetic Strike I | `items`, `spells_new` | Audit/pending only |

## Promotion rule

A pending migration can move into `migrations_safe` only after:

1. the matching audit output has been captured,
2. IDs/coordinates/NPCs/items are confirmed,
3. a backup exists,
4. the change is idempotent,
5. the server boots after application.
