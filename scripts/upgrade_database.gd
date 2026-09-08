extends Node


# =========================================================
# UPGRADE DATABASE
# =========================================================
#
# This script stores every upgrade currently available.
#
# CURRENT UPGRADE TYPES:
#
# "Equipment"
# Shared stat-based upgrades available to everyone.
#
# "Ability"
# Temporary character-specific upgrade system.
#
# Later this will be reorganized into:
#
# - Equipment
# - Class Upgrades
# - Character Specials
#
# Equipment will eventually be repeatable.
# Class upgrades and Specials will not.
# =========================================================


# =========================================================
# GENERIC EQUIPMENT
# =========================================================
#
# These replace the original placeholder weapons.
#
# Equipment is available to every character.
#
# IMPORTANT:
# Cooldown equipment now uses:
#
# "cooldown_reduction"
#
# instead of:
#
# "cooldown_multiplier"
#
# Character.gd will be updated during Task 2
# to actually apply these flat reductions.
# =========================================================

var equipment = [

	# =====================================================
	# BASIC STAT EQUIPMENT
	# =====================================================

	{
		"name": "Up-Armored",
		"type": "Equipment",
		"description": "+35 Maximum Health",
		"health_bonus": 35
	},

	{
		"name": "Kinetic Overcharge",
		"type": "Equipment",
		"description": "+5 Damage",
		"damage_bonus": 5
	},

	{
		"name": "Quantum Thrusters",
		"type": "Equipment",
		"description": "+25 Move Speed",
		"move_speed_bonus": 25
	},

	{
		"name": "Targeting System",
		"type": "Equipment",
		"description": "+20 Attack Range",
		"range_bonus": 20
	},

	{
		"name": "Rapid Cycle Mechanism",
		"type": "Equipment",
		"description": "-0.15s Attack Cooldown",
		"cooldown_reduction": 0.15
	},


	# =====================================================
	# COMBINATION EQUIPMENT
	# =====================================================

	{
		"name": "Fragmentation Plating",
		"type": "Equipment",
		"description": "+25 Maximum Health\n+2 Damage",
		"health_bonus": 25,
		"damage_bonus": 2
	},

	{
		"name": "Reactive Exoframe",
		"type": "Equipment",
		"description": "+25 Maximum Health\n+12 Move Speed",
		"health_bonus": 25,
		"move_speed_bonus": 12
	},

	{
		"name": "Overdrive Ignition",
		"type": "Equipment",
		"description": "+3 Damage\n+12 Move Speed",
		"damage_bonus": 3,
		"move_speed_bonus": 12
	},

	{
		"name": "Long-Barrel Conversion",
		"type": "Equipment",
		"description": "+3 Damage\n+10 Attack Range",
		"damage_bonus": 3,
		"range_bonus": 10
	},

	{
		"name": "Rapid Chamber",
		"type": "Equipment",
		"description": "+2 Damage\n-0.10s Attack Cooldown",
		"damage_bonus": 2,
		"cooldown_reduction": 0.10
	}
]


# =========================================================
# CHARACTER ABILITIES
# =========================================================
#
# These are the OLD temporary character-specific
# upgrade abilities.
#
# We are keeping them intact for now so the
# current game continues functioning.
#
# Once the new Class Upgrade and Special Ability
# systems are finalized, this section will be
# replaced/reorganized.
#
# effect_id is used for abilities requiring
# special combat behavior.
# =========================================================

var abilities = {


	# =====================================================
	# VESPER
	# =====================================================


	# =========================
	# VEYRA
	# =========================

	"Veyra": [

		{
			"name": "Reinforced Wax",
			"type": "Ability",
			"description": "+30 Maximum Health",
			"health_bonus": 30
		},

		{
			"name": "Hive Defender",
			"type": "Ability",
			"description": "Basic attacks against Veyra deal 2 less damage.",
			"effect_id": "damage_reduction_2"
		},

		{
			"name": "Spear Wall",
			"type": "Ability",
			"description": "+2 Damage\n+20 Attack Range",
			"damage_bonus": 2,
			"range_bonus": 20
		}
	],


	# =========================
	# ZEKRIN
	# =========================

	"Zekrin": [

		{
			"name": "Serrated Stinger",
			"type": "Ability",
			"description": "+5 Damage against enemies below 50% HP.",
			"effect_id": "execute_damage_5"
		},

		{
			"name": "Hunter Wings",
			"type": "Ability",
			"description": "+25 Move Speed",
			"move_speed_bonus": 25
		},

		{
			"name": "Rapid Sting",
			"type": "Ability",
			"description": "+20% Attack Speed",
			"cooldown_multiplier": 0.80
		}
	],


	# =========================
	# MELORA
	# =========================

	"Melora": [

		{
			"name": "Rich Nectar",
			"type": "Ability",
			"description": "Royal Nectar heals an additional 5 HP.",
			"effect_id": "nectar_heal_plus_5"
		},

		{
			"name": "Energizing Honey",
			"type": "Ability",
			"description": "Royal Nectar briefly increases the ally's attack speed.",
			"effect_id": "nectar_attack_speed"
		},

		{
			"name": "Nectar Reserve",
			"type": "Ability",
			"description": "Melora heals herself for 4 HP when Royal Nectar activates.",
			"effect_id": "nectar_self_heal"
		}
	],


	# =========================
	# THAROS
	# =========================

	"Tharos": [

		{
			"name": "Blood Frenzy",
			"type": "Ability",
			"description": "After taking damage, temporarily gain +3 Damage.",
			"effect_id": "blood_frenzy"
		},

		{
			"name": "Hardened Carapace",
			"type": "Ability",
			"description": "+20 Maximum Health",
			"health_bonus": 20
		},

		{
			"name": "Relentless Wings",
			"type": "Ability",
			"description": "Frenzy Wings becomes stronger and lasts longer.",
			"effect_id": "better_frenzy_wings"
		}
	],


	# =========================
	# AUREX
	# =========================

	"Aurex": [

		{
			"name": "Sharpened Needle",
			"type": "Ability",
			"description": "+4 Damage",
			"damage_bonus": 4
		},

		{
			"name": "Longshot",
			"type": "Ability",
			"description": "+50 Attack Range",
			"range_bonus": 50
		},

		{
			"name": "Needle Barrage",
			"type": "Ability",
			"description": "Every fourth basic attack fires an additional weaker attack.",
			"effect_id": "needle_barrage"
		}
	],


	# =====================================================
	# ANTTALOPE
	# =====================================================


	# =========================
	# KAELOR
	# =========================

	"Kaelor": [

		{
			"name": "Perfect Cut",
			"type": "Ability",
			"description": "First Cut deals additional opening damage.",
			"effect_id": "perfect_cut"
		},

		{
			"name": "Duelist Rhythm",
			"type": "Ability",
			"description": "Repeated attacks against the same target increase attack speed.",
			"effect_id": "duelist_rhythm"
		},

		{
			"name": "Blade Guard",
			"type": "Ability",
			"description": "After attacking, reduce damage from the next incoming hit.",
			"effect_id": "blade_guard"
		}
	],


	# =========================
	# SYRRA
	# =========================

	"Syrra": [

		{
			"name": "Killing Leap",
			"type": "Ability",
			"description": "First attack after reaching an enemy deals +7 Damage.",
			"effect_id": "killing_leap"
		},

		{
			"name": "Ghost Wings",
			"type": "Ability",
			"description": "+30 Move Speed",
			"move_speed_bonus": 30
		},

		{
			"name": "Razor Limbs",
			"type": "Ability",
			"description": "+4 Damage",
			"damage_bonus": 4
		}
	],


	# =========================
	# DROVEN
	# =========================

	"Droven": [

		{
			"name": "Iron Carapace",
			"type": "Ability",
			"description": "+35 Maximum Health",
			"health_bonus": 35
		},

		{
			"name": "Reinforced Guard",
			"type": "Ability",
			"description": "Guarded Stance blocks additional damage.",
			"effect_id": "reinforced_guard"
		},

		{
			"name": "Heavy Blades",
			"type": "Ability",
			"description": "+4 Damage\n-10 Move Speed",
			"damage_bonus": 4,
			"move_speed_bonus": -10
		}
	],


	# =========================
	# NYXIS
	# =========================

	"Nyxis": [

		{
			"name": "Potent Acid",
			"type": "Ability",
			"description": "Corrosive Shot deals additional damage.",
			"effect_id": "potent_acid"
		},

		{
			"name": "Acid Volley",
			"type": "Ability",
			"description": "Every fifth basic attack strikes twice.",
			"effect_id": "acid_volley"
		},

		{
			"name": "Extended Glands",
			"type": "Ability",
			"description": "+45 Attack Range",
			"range_bonus": 45
		}
	],


	# =========================
	# VELKARA
	# =========================

	"Velkara": [

		{
			"name": "Hunter's Mark",
			"type": "Ability",
			"description": "Marked Prey lasts longer.",
			"effect_id": "longer_mark"
		},

		{
			"name": "Exposed Prey",
			"type": "Ability",
			"description": "Allies deal additional damage to Velkara's marked target.",
			"effect_id": "stronger_mark"
		},

		{
			"name": "Crescent Storm",
			"type": "Ability",
			"description": "+20% Attack Speed",
			"cooldown_multiplier": 0.80
		}
	]
}


# =========================================================
# GET UPGRADE POOL
# =========================================================
#
# Returns every upgrade currently available
# to a character.
#
# CURRENT TEMPORARY SYSTEM:
#
# - All 10 Equipment options
# - That character's three old abilities
#
# The future version will instead combine:
#
# - Equipment
# - Class upgrades
# - Character Special
# =========================================================

func get_upgrade_pool(
	character_name: String
) -> Array:

	var upgrade_pool = []


	# =====================================================
	# ADD GENERIC EQUIPMENT
	# =====================================================

	for item in equipment:

		upgrade_pool.append(
			item
		)


	# =====================================================
	# ADD CHARACTER ABILITIES
	# =====================================================

	if abilities.has(
		character_name
	):

		for ability in abilities[
			character_name
		]:

			upgrade_pool.append(
				ability
			)


	return upgrade_pool


# =========================================================
# RANDOM THREE
# =========================================================
#
# Returns three random upgrade choices.
#
# Because the entire current pool is shuffled,
# the result could still contain:
#
# - 3 Equipment
# - 3 Abilities
# - 2 Equipment + 1 Ability
# - 1 Equipment + 2 Abilities
#
# We will replace this draw logic later when
# the final upgrade architecture is implemented.
# =========================================================

func get_random_three(
	character_name: String
) -> Array:

	var upgrade_pool = (
		get_upgrade_pool(
			character_name
		)
	)


	# Shuffle the temporary pool.
	upgrade_pool.shuffle()


	var choices = []


	# Safety prevents trying to take
	# more options than exist.
	var choice_count: int = min(
		3,
		upgrade_pool.size()
	)


	for i in range(
		choice_count
	):

		choices.append(
			upgrade_pool[i]
		)


	return choices
