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
# ABILITY IDS
# =========================================================

# Automatic starting ability owned by the character.
# This is always active and never appears as an upgrade.
@export var basic_ability_id: String = ""


# Character-specific Special upgrade.
# This starts locked, can appear in the upgrade pool,
# and is non-repeatable once selected.
@export var special_ability_id: String = ""


# =========================================================
# BASIC COMBAT STATS
# =========================================================

@export var max_health: int = 100
@export var damage: int = 10
@export var move_speed: float = 100.0

# Actual distance from which this character can perform attacks.
@export var attack_range: float = 70.0

# Base seconds between basic attacks. Lower = faster.
@export var attack_cooldown: float = 1.0


# =========================================================
# ATTACK INFO
# =========================================================

# Temporary design information describing
# the character's basic attack style.
@export var basic_attack_style: String = ""
