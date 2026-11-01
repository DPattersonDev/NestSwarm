extends RefCounted
## Read-only presentation data. Character resources and upgrade definitions remain authoritative.

const CLANS: Array[String] = ["Vesper", "Anttalope", "Caraphex", "Scolyra", "Formicara", "Lepidra"]
const MEMBERS: Dictionary = {
 "Vesper": ["Veyra", "Aurex", "Melora", "Tharos", "Zekrin"],
 "Anttalope": ["Droven", "Kaelor", "Nyxis", "Syrra", "Velkara"],
 "Caraphex": ["Brontis", "Kharvos", "Ignivar", "Virex", "Aurelia"],
 "Scolyra": ["Mordrax", "Scyrix", "Nyzara", "Veltrix", "Thesira"],
 "Formicara": ["Karnyx", "Raxen", "Vexira", "Tarsik", "Myraxa"],
 "Lepidra": ["Vorren", "Mavros", "Noctren", "Solvyr", "Lunara"]
}
const BONUSES: Dictionary = {
 "Vesper": [["Hive Bond", "Basic attack interval reduced by 5%."], ["Hive Mind", "Basic attack interval reduced by 10%. Heal 3 HP every 4 seconds."]],
 "Anttalope": [["Hunter's Focus", "+2 sustained-target damage."], ["Perfect Hunt", "+4 damage on new targets and +4 sustained-target damage."]],
 "Caraphex": [["Reinforced Carapace", "+15% max HP."], ["Last Shell", "+25% max HP. At or below 30% HP, gain a shield worth 20% max HP for 4 seconds, once per round."]],
 "Scolyra": [["Venomous Assault", "+1 damage per Venom stack, up to 5 stacks."], ["Predatory Frenzy", "+2 damage per Venom stack, up to 5 stacks. At 5 stacks, basic attack interval is reduced by 15%."]],
 "Formicara": [["Colony Discipline", "Reduce incoming damage by 2."], ["United Colony", "Reduce incoming damage by 3. Gain +2 ATK when a Formicara ally dies."]],
 "Lepidra": [["Veil of Dust", "First 2 hits take 15% less damage."], ["Lunar Veil", "First 2 hits take 25% less damage. A protected hit grants +15 move speed for 2 seconds."]]
}

static func roster() -> Array[CharacterData]:
 var result: Array[CharacterData] = []
 for clan in CLANS:
  for character_name in MEMBERS[clan]:
   var data := load("res://Data/%s.tres" % character_name) as CharacterData
   if data != null:
    result.append(data)
 return result

static func stories() -> Dictionary:
 return preload("res://scripts/character_lore.gd").ENTRIES
