extends Resource
class_name CharacterData


# =========================================================
# IDENTITY
# =========================================================

@export var character_name: String = ""


# =========================================================
# CHARACTER ART
# =========================================================

# Temporary / final battle image used by the shared
# Character scene during combat.
#
# Characters without a texture assigned can continue
# using the current placeholder visual.
@export var battle_texture: Texture2D


# =========================================================
# SYNERGY TRAITS
# =========================================================

# Character's faction.
#
# Examples:
# Vesper
# Anttalope
# Lepidra
# Formicara
# Caraphex
# Scolyra
@export var faction: String = ""


# Character's combat class.
#
# Vanguard
# Fighter
# Assassin
# Marksman
# Support
@export var class_role: String = ""


# =========================================================
# BASIC COMBAT STATS
# =========================================================

@export var max_health: int = 100

@export var damage: int = 10

@export var move_speed: float = 100.0


# Actual distance from which this
# character can perform basic attacks.
#
# Range upgrades modify this value.
@export var attack_range: float = 70.0


# Base number of seconds between basic attacks.
#
# Lower number = faster attacks.
#
# Example:
# 1.00 = one attack every second
# 0.80 = one attack every 0.8 seconds
# 1.10 = one attack every 1.1 seconds
#
# Equipment and synergies can modify this value
# during the match.
@export var attack_cooldown: float = 1.0


# =========================================================
# ATTACK / ABILITY INFO
# =========================================================

# Temporary design information describing
# the character's basic attack style.
@export var basic_attack_style: String = ""


# Temporary design information describing
# the character's starting unique ability.
@export var unique_ability: String = ""
