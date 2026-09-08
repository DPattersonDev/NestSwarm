extends CharacterBody2D


# =========================================================
# DEBUG SETTINGS
# =========================================================

@export var debug_combat_logs: bool = true


# =========================================================
# BASIC CHARACTER STATS
# =========================================================

@export var max_health: int = 100
@export var damage: int = 10
@export var move_speed: float = 100.0

# Team 1 = Player
# Team 2 = Opponent
@export var team_id: int = 0

@export var attack_range: float = 70.0

# Smaller number = faster attacks.
@export var attack_cooldown: float = 1.0

@export var character_data: CharacterData


# =========================================================
# CHARACTER VISUAL REFERENCES
# =========================================================

# Blue placeholder currently used by characters that
# do not have battle artwork assigned yet.
@onready var placeholder_visual: ColorRect = $ColorRect

# Character artwork Sprite2D. The texture is loaded
# automatically from CharacterData.battle_texture.
@onready var battle_sprite: Sprite2D = $BattleSprite


# =========================================================
# COOLDOWN LIMIT
# =========================================================

# Nothing in the game can reduce the final
# attack cooldown below this amount.
const MIN_ATTACK_COOLDOWN: float = 0.25


# =========================================================
# BASIC CHARACTER STATE
# =========================================================

var current_health: int
var target: CharacterBody2D = null

var attack_timer: float = 0.0
var is_alive: bool = true


# =========================================================
# SHIELD STATE
# =========================================================

# Temporary shield health.
#
# Shields absorb incoming damage before
# normal health is damaged.
var current_shield: int = 0

# Time remaining before the current
# temporary shield disappears.
var shield_timer: float = 0.0


# =========================================================
# ATTACK / ABILITY COUNTERS
# =========================================================

var attack_count: int = 0

# Tracks the previous target.
var previous_target: CharacterBody2D = null

# Counts attacks against the same target.
var same_target_attack_count: int = 0


# =========================================================
# DEFENSIVE ABILITY STATE
# =========================================================

# Veyra - Wax Guard.
var wax_guard_available: bool = true

# Droven - Guarded Stance.
var guarded_hits_remaining: int = 3

# Kaelor - Blade Guard.
var blade_guard_ready: bool = false


# =========================================================
# TEMPORARY BUFF STATE
# =========================================================

# Tharos movement buff.
var frenzy_wings_timer: float = 0.0
var frenzy_wings_bonus: float = 0.0

# Tharos damage buff.
var blood_frenzy_timer: float = 0.0
var blood_frenzy_bonus: int = 0

# Melora attack-speed buff.
var temporary_attack_speed_timer: float = 0.0
var temporary_attack_speed_multiplier: float = 1.0


# =========================================================
# FACTION SYNERGY STATE
# =========================================================

# 0 = none
# 2 = small faction bonus
# 4 = full faction bonus
var faction_synergy_tier: int = 0


# =========================================================
# VESPER - HIVE MIND
# =========================================================

var hive_mind_heal_timer: float = 4.0

const HIVE_MIND_HEAL_INTERVAL: float = 4.0
const HIVE_MIND_HEAL_AMOUNT: int = 3


# =========================================================
# LEPIDRA - VEIL OF DUST / LUNAR VEIL
# =========================================================

var lepidra_protected_hits_remaining: int = 2

const LEPIDRA_SMALL_DAMAGE_MULTIPLIER: float = 0.85
const LEPIDRA_FULL_DAMAGE_MULTIPLIER: float = 0.75

var lunar_veil_speed_timer: float = 0.0
var lunar_veil_speed_bonus: float = 0.0

const LUNAR_VEIL_SPEED_BONUS: float = 15.0
const LUNAR_VEIL_SPEED_DURATION: float = 2.0


# =========================================================
# FORMICARA - COLONY DISCIPLINE / UNITED COLONY
# =========================================================

const FORMICARA_SMALL_DAMAGE_REDUCTION: int = 2
const FORMICARA_FULL_DAMAGE_REDUCTION: int = 3

const UNITED_COLONY_DEATH_DAMAGE_BONUS: int = 2

var united_colony_damage_bonus: int = 0


# =========================================================
# CARAPHEX - REINFORCED CARAPACE / LAST SHELL
# =========================================================

# 2 Caraphex:
# +15% Max HP.
const CARAPHEX_SMALL_HEALTH_MULTIPLIER: float = 1.15

# 4 Caraphex:
# +25% Max HP.
const CARAPHEX_FULL_HEALTH_MULTIPLIER: float = 1.25

# At 4 Caraphex, the first time the character
# drops below 30% HP, it gains a shield equal
# to 20% of Max HP for 4 seconds.
const CARAPHEX_LAST_SHELL_TRIGGER: float = 0.30
const CARAPHEX_LAST_SHELL_SHIELD_PERCENT: float = 0.20
const CARAPHEX_LAST_SHELL_DURATION: float = 4.0

var last_shell_used: bool = false


# =========================================================
# SCOLYRA - VENOMOUS ASSAULT / PREDATORY FRENZY
# =========================================================

# Consecutive attacks against the same target
# build Venom stacks.
const SCOLYRA_MAX_VENOM_STACKS: int = 5

# 2 Scolyra:
# +1 damage per Venom stack.
const SCOLYRA_SMALL_DAMAGE_PER_STACK: int = 1

# 4 Scolyra:
# +2 damage per Venom stack.
const SCOLYRA_FULL_DAMAGE_PER_STACK: int = 2

# At 5 stacks, 4 Scolyra gain 15%
# Attack Speed against that target.
const SCOLYRA_FULL_ATTACK_SPEED_MULTIPLIER: float = 0.85


# =========================================================
# CLASS SYNERGY STATE
# =========================================================

# 0 = no class synergy
# 2 = small class synergy
# 4 = full class synergy
var class_synergy_tier: int = 0

var class_synergy_active: bool = false

# Tracks the team's Support synergy separately
# because Support bonuses affect the whole team.
var support_synergy_tier: int = 0
var support_synergy_active: bool = false


# =========================================================
# VANGUARD - BULWARK / FORTRESS
# =========================================================

# 2 Vanguard - Bulwark.
const VANGUARD_SMALL_HEALTH_BONUS: int = 25
const VANGUARD_SMALL_DAMAGE_REDUCTION: int = 2

# 4 Vanguard - Fortress.
const VANGUARD_FULL_HEALTH_BONUS: int = 50
const VANGUARD_FULL_DAMAGE_REDUCTION: int = 4

# First time below 40% HP:
# gain a 30 HP temporary shield.
const VANGUARD_FORTRESS_TRIGGER: float = 0.40
const VANGUARD_FORTRESS_SHIELD: int = 30
const VANGUARD_FORTRESS_SHIELD_DURATION: float = 4.0

var fortress_shield_used: bool = false


# =========================================================
# FIGHTER - BATTLE MOMENTUM / WAR MACHINE
# =========================================================

var fighter_momentum_timer: float = 3.0
var fighter_momentum_bonus: int = 0

const FIGHTER_MOMENTUM_INTERVAL: float = 3.0

# 2 Fighter.
const FIGHTER_SMALL_MOMENTUM_PER_STACK: int = 1
const FIGHTER_SMALL_MOMENTUM_MAX: int = 5

# 4 Fighter.
const FIGHTER_FULL_MOMENTUM_PER_STACK: int = 2
const FIGHTER_FULL_MOMENTUM_MAX: int = 10

# When War Machine reaches maximum stacks,
# Fighters gain 15% Attack Speed.
const FIGHTER_WAR_MACHINE_SPEED_MULTIPLIER: float = 0.85


# =========================================================
# ASSASSIN - SHADOW RUSH / EXECUTION PROTOCOL
# =========================================================

# 2 Assassin.
const ASSASSIN_SMALL_MOVE_SPEED_BONUS: float = 20.0
const ASSASSIN_SMALL_NEW_TARGET_DAMAGE_BONUS: int = 4

# 4 Assassin.
const ASSASSIN_FULL_MOVE_SPEED_BONUS: float = 30.0
const ASSASSIN_FULL_NEW_TARGET_DAMAGE_BONUS: int = 8

# Attacks against enemies below 30% HP
# deal 25% more damage.
const ASSASSIN_EXECUTION_HEALTH_THRESHOLD: float = 0.30
const ASSASSIN_EXECUTION_DAMAGE_MULTIPLIER: float = 1.25


# =========================================================
# MARKSMAN - STEADY AIM / DEADEYE
# =========================================================

var steady_aim_stacks: int = 0

const STEADY_AIM_MAX_STACKS: int = 4

# 2 Marksman:
# +5% Attack Speed per stationary attack.
const STEADY_AIM_SMALL_SPEED_PER_STACK: float = 0.05

# 4 Marksman:
# +7.5% Attack Speed per stationary attack.
# Four stacks = +30%.
const STEADY_AIM_FULL_SPEED_PER_STACK: float = 0.075

# At maximum Deadeye stacks:
# +20% basic attack damage.
const DEADEYE_DAMAGE_MULTIPLIER: float = 1.20


# =========================================================
# SUPPORT - INSPIRING / OVERWHELMING PRESENCE
# =========================================================

# 2 Support.
const SUPPORT_SMALL_TEAM_ATTACK_SPEED_MULTIPLIER: float = 0.95
const SUPPORT_SMALL_EFFECT_MULTIPLIER: float = 1.25

# 4 Support.
const SUPPORT_FULL_TEAM_ATTACK_SPEED_MULTIPLIER: float = 0.90
const SUPPORT_FULL_EFFECT_MULTIPLIER: float = 1.50

# Every Support periodically shields the
# lowest-health living ally.
const SUPPORT_FULL_SHIELD_INTERVAL: float = 5.0
const SUPPORT_FULL_SHIELD_AMOUNT: int = 15
const SUPPORT_FULL_SHIELD_DURATION: float = 4.0

var support_full_shield_timer: float = 5.0


# =========================================================
# MARKED PREY STATE
# =========================================================

var marked_timer: float = 0.0
var marked_for_team: int = 0
var marked_bonus_damage: int = 0


# =========================================================
# STARTUP
# =========================================================

func _ready() -> void:

	if character_data:

		max_health = character_data.max_health
		damage = character_data.damage
		move_speed = character_data.move_speed
		attack_range = character_data.attack_range
		attack_cooldown = character_data.attack_cooldown

		name = character_data.character_name


	# Load the character-specific battle artwork when one
	# has been assigned in CharacterData. Characters without
	# artwork keep the existing blue placeholder.
	setup_battle_visual()


	if team_id == 1:
		apply_saved_upgrades()


	apply_faction_synergy()
	apply_class_synergy()


	current_health = max_health


	if get_character_name() == "Syrra":
		move_speed += 20


	debug_log(
		str(name)
		+ " ready - HP: "
		+ str(current_health)
		+ " Damage: "
		+ str(damage)
		+ " Speed: "
		+ str(move_speed)
		+ " Range: "
		+ str(attack_range)
		+ " Cooldown: "
		+ str(attack_cooldown)
	)


	await get_tree().process_frame


	target = find_closest_enemy()


	if target:

		debug_log(
			str(name)
			+ " found enemy: "
			+ str(target.name)
		)


# =========================================================
# SETUP BATTLE VISUAL
# =========================================================

func setup_battle_visual() -> void:

	# No CharacterData means there is no character-specific
	# artwork to load, so keep the placeholder visible.
	if character_data == null:

		battle_sprite.texture = null
		battle_sprite.visible = false
		placeholder_visual.visible = true

		return


	# If this character has artwork assigned in its .tres
	# resource, use it and hide the old blue square.
	if character_data.battle_texture != null:

		battle_sprite.texture = (
			character_data.battle_texture
		)


		battle_sprite.visible = true
		placeholder_visual.visible = false


		# Temporary scale for the large concept-art placeholder.
		# We can tune this after seeing Veyra in an actual fight.
		battle_sprite.scale = Vector2(
			0.05,
			0.05
		)


	else:

		battle_sprite.texture = null
		battle_sprite.visible = false
		placeholder_visual.visible = true


# =========================================================
# APPLY FACTION SYNERGY
# =========================================================

func apply_faction_synergy() -> void:

	if character_data == null:
		return


	var faction_name: String = character_data.faction


	if faction_name == "":
		return


	faction_synergy_tier = (
		SynergyManager.get_unit_faction_tier(
			team_id,
			faction_name
		)
	)


	# =====================================================
	# VESPER
	# =====================================================

	if faction_name == "Vesper":

		if faction_synergy_tier >= 4:

			attack_cooldown *= 0.90

			debug_log(
				str(name)
				+ " received Hive Mind! "
				+ "Attack Speed +10%."
			)


		elif faction_synergy_tier >= 2:

			attack_cooldown *= 0.95

			debug_log(
				str(name)
				+ " received Hive Bond! "
				+ "Attack Speed +5%."
			)


	# =====================================================
	# ANTTALOPE
	# =====================================================

	elif faction_name == "Anttalope":

		if faction_synergy_tier >= 4:

			debug_log(
				str(name)
				+ " received Perfect Hunt!"
			)


		elif faction_synergy_tier >= 2:

			debug_log(
				str(name)
				+ " received Hunter's Focus!"
			)


	# =====================================================
	# LEPIDRA
	# =====================================================

	elif faction_name == "Lepidra":

		if faction_synergy_tier >= 4:

			debug_log(
				str(name)
				+ " received Lunar Veil! "
				+ "First 2 hits take 25% less damage "
				+ "and grant +15 Move Speed."
			)


		elif faction_synergy_tier >= 2:

			debug_log(
				str(name)
				+ " received Veil of Dust! "
				+ "First 2 hits take 15% less damage."
			)


	# =====================================================
	# FORMICARA
	# =====================================================

	elif faction_name == "Formicara":

		if faction_synergy_tier >= 4:

			debug_log(
				str(name)
				+ " received United Colony! "
				+ "-3 incoming damage for the round. "
				+ "+2 ATK whenever a Formicara ally dies."
			)


		elif faction_synergy_tier >= 2:

			debug_log(
				str(name)
				+ " received Colony Discipline! "
				+ "-2 incoming damage for the round."
			)


	# =====================================================
	# CARAPHEX
	# =====================================================

	elif faction_name == "Caraphex":

		if faction_synergy_tier >= 4:

			max_health = int(
				round(
					max_health
					* CARAPHEX_FULL_HEALTH_MULTIPLIER
				)
			)


			debug_log(
				str(name)
				+ " received Last Shell! "
				+ "+25% Max HP and emergency shell enabled."
			)


		elif faction_synergy_tier >= 2:

			max_health = int(
				round(
					max_health
					* CARAPHEX_SMALL_HEALTH_MULTIPLIER
				)
			)


			debug_log(
				str(name)
				+ " received Reinforced Carapace! "
				+ "+15% Max HP."
			)


	# =====================================================
	# SCOLYRA
	# =====================================================

	elif faction_name == "Scolyra":

		if faction_synergy_tier >= 4:

			debug_log(
				str(name)
				+ " received Predatory Frenzy! "
				+ "+2 damage per Venom stack, "
				+ "maximum 5 stacks. "
				+ "At maximum stacks gain "
				+ "15% Attack Speed."
			)


		elif faction_synergy_tier >= 2:

			debug_log(
				str(name)
				+ " received Venomous Assault! "
				+ "+1 damage per Venom stack, "
				+ "maximum 5 stacks."
			)


# =========================================================
# APPLY CLASS SYNERGY
# =========================================================

func apply_class_synergy() -> void:

	if character_data == null:
		return


	var role_name: String = character_data.class_role


	if role_name == "":
		return


	var team = (
		SynergyManager.get_team_from_id(
			team_id
		)
	)


	class_synergy_tier = (
		SynergyManager.get_class_tier(
			team,
			role_name
		)
	)


	class_synergy_active = (
		class_synergy_tier >= 2
	)


	support_synergy_tier = (
		SynergyManager.get_class_tier(
			team,
			"Support"
		)
	)


	support_synergy_active = (
		support_synergy_tier >= 2
	)


	# =====================================================
	# TEAM SUPPORT BONUS
	# =====================================================

	if support_synergy_tier >= 4:

		attack_cooldown *= (
			SUPPORT_FULL_TEAM_ATTACK_SPEED_MULTIPLIER
		)


		debug_log(
			str(name)
			+ " received Overwhelming Presence! "
			+ "Team Attack Speed +10%."
		)


	elif support_synergy_tier >= 2:

		attack_cooldown *= (
			SUPPORT_SMALL_TEAM_ATTACK_SPEED_MULTIPLIER
		)


		debug_log(
			str(name)
			+ " received Inspiring Presence! "
			+ "Team Attack Speed +5%."
		)


	if not class_synergy_active:
		return


	# =====================================================
	# VANGUARD
	# =====================================================

	if role_name == "Vanguard":

		if class_synergy_tier >= 4:

			max_health += (
				VANGUARD_FULL_HEALTH_BONUS
			)


			debug_log(
				str(name)
				+ " received Fortress! "
				+ "+50 Max HP, "
				+ "4 Damage Reduction, "
				+ "and emergency shield enabled."
			)


		else:

			max_health += (
				VANGUARD_SMALL_HEALTH_BONUS
			)


			debug_log(
				str(name)
				+ " received Bulwark! "
				+ "+25 Max HP and "
				+ "2 Damage Reduction."
			)


	# =====================================================
	# FIGHTER
	# =====================================================

	elif role_name == "Fighter":

		if class_synergy_tier >= 4:

			debug_log(
				str(name)
				+ " received War Machine! "
				+ "+2 Damage every 3 seconds, "
				+ "maximum +10. "
				+ "At maximum stacks gain "
				+ "15% Attack Speed."
			)


		else:

			debug_log(
				str(name)
				+ " received Battle Momentum! "
				+ "+1 Damage every 3 seconds, "
				+ "maximum +5."
			)


	# =====================================================
	# ASSASSIN
	# =====================================================

	elif role_name == "Assassin":

		if class_synergy_tier >= 4:

			move_speed += (
				ASSASSIN_FULL_MOVE_SPEED_BONUS
			)


			debug_log(
				str(name)
				+ " received Execution Protocol! "
				+ "+30 Move Speed, "
				+ "+8 Damage against new targets, "
				+ "and +25% damage against enemies "
				+ "below 30% HP."
			)


		else:

			move_speed += (
				ASSASSIN_SMALL_MOVE_SPEED_BONUS
			)


			debug_log(
				str(name)
				+ " received Shadow Rush! "
				+ "+20 Move Speed and "
				+ "+4 Damage against new targets."
			)


	# =====================================================
	# MARKSMAN
	# =====================================================

	elif role_name == "Marksman":

		if class_synergy_tier >= 4:

			debug_log(
				str(name)
				+ " received Deadeye! "
				+ "+7.5% Attack Speed per stationary attack, "
				+ "maximum +30%. "
				+ "At maximum stacks gain "
				+ "+20% basic attack damage."
			)


		else:

			debug_log(
				str(name)
				+ " received Steady Aim! "
				+ "+5% Attack Speed per attack "
				+ "while stationary, maximum +20%."
			)


	# =====================================================
	# SUPPORT
	# =====================================================

	elif role_name == "Support":

		if class_synergy_tier >= 4:

			debug_log(
				str(name)
				+ " empowered by Overwhelming Presence! "
				+ "Support effects +50% "
				+ "and periodic ally shields enabled."
			)


		else:

			debug_log(
				str(name)
				+ " empowered by Inspiring Presence! "
				+ "Support effects +25%."
			)


# =========================================================
# COMBAT LOOP
# =========================================================

func _physics_process(delta: float) -> void:

	if not is_alive:
		return


	if attack_timer > 0:
		attack_timer -= delta


	update_temporary_effects(delta)


	if target == null or not is_instance_valid(target):
		target = find_closest_enemy()


	if target == null:
		velocity = Vector2.ZERO
		return


	if not target.is_alive:
		target = find_closest_enemy()
		return


	var distance_to_target = (
		global_position.distance_to(
			target.global_position
		)
	)


	if distance_to_target > attack_range:

		reset_steady_aim_if_moving()


		var direction = (
			global_position.direction_to(
				target.global_position
			)
		)


		velocity = (
			direction
			* get_current_move_speed()
		)


		move_and_slide()


	else:

		velocity = Vector2.ZERO


		if attack_timer <= 0:
			attack_target()


# =========================================================
# TEMPORARY / TIMED EFFECTS
# =========================================================

func update_temporary_effects(delta: float) -> void:

	if frenzy_wings_timer > 0:

		frenzy_wings_timer -= delta

		if frenzy_wings_timer <= 0:
			frenzy_wings_bonus = 0.0


	if blood_frenzy_timer > 0:

		blood_frenzy_timer -= delta

		if blood_frenzy_timer <= 0:
			blood_frenzy_bonus = 0


	if temporary_attack_speed_timer > 0:

		temporary_attack_speed_timer -= delta

		if temporary_attack_speed_timer <= 0:
			temporary_attack_speed_multiplier = 1.0


	if marked_timer > 0:

		marked_timer -= delta

		if marked_timer <= 0:
			marked_for_team = 0
			marked_bonus_damage = 0


	if lunar_veil_speed_timer > 0:

		lunar_veil_speed_timer -= delta

		if lunar_veil_speed_timer <= 0:
			lunar_veil_speed_bonus = 0.0


	# =====================================================
	# TEMPORARY SHIELD TIMER
	# =====================================================

	if shield_timer > 0:

		shield_timer -= delta


		if shield_timer <= 0:

			if current_shield > 0:

				debug_log(
					str(name)
					+ "'s shield expired."
				)


			current_shield = 0


	# =====================================================
	# VESPER - HIVE MIND HEAL
	# =====================================================

	if (
		character_data != null
		and character_data.faction == "Vesper"
		and faction_synergy_tier >= 4
	):

		hive_mind_heal_timer -= delta


		if hive_mind_heal_timer <= 0:

			hive_mind_heal_timer = (
				HIVE_MIND_HEAL_INTERVAL
			)


			if current_health < max_health:

				var health_before = current_health


				heal(
					HIVE_MIND_HEAL_AMOUNT
				)


				var actual_heal = (
					current_health
					- health_before
				)


				if actual_heal > 0:

					debug_log(
						"Hive Mind healed "
						+ str(name)
						+ " for "
						+ str(actual_heal)
						+ " HP!"
					)


	# =====================================================
	# FIGHTER - BATTLE MOMENTUM / WAR MACHINE
	# =====================================================

	if (
		character_data != null
		and character_data.class_role == "Fighter"
		and class_synergy_active
	):

		var momentum_max: int = (
			FIGHTER_SMALL_MOMENTUM_MAX
		)


		var momentum_per_stack: int = (
			FIGHTER_SMALL_MOMENTUM_PER_STACK
		)


		if class_synergy_tier >= 4:

			momentum_max = (
				FIGHTER_FULL_MOMENTUM_MAX
			)

			momentum_per_stack = (
				FIGHTER_FULL_MOMENTUM_PER_STACK
			)


		if fighter_momentum_bonus < momentum_max:

			fighter_momentum_timer -= delta


			if fighter_momentum_timer <= 0:

				fighter_momentum_timer = (
					FIGHTER_MOMENTUM_INTERVAL
				)


				fighter_momentum_bonus += (
					momentum_per_stack
				)


				fighter_momentum_bonus = min(
					fighter_momentum_bonus,
					momentum_max
				)


				debug_log(
					"Fighter momentum! "
					+ str(name)
					+ " now has +"
					+ str(fighter_momentum_bonus)
					+ " damage."
				)


	# =====================================================
	# SUPPORT 4 - PERIODIC SHIELD
	# =====================================================

	if (
		character_data != null
		and character_data.class_role == "Support"
		and class_synergy_tier >= 4
	):

		support_full_shield_timer -= delta


		if support_full_shield_timer <= 0:

			support_full_shield_timer = (
				SUPPORT_FULL_SHIELD_INTERVAL
			)


			var shield_target = (
				find_lowest_health_ally()
			)


			if shield_target != null:

				shield_target.receive_shield(
					SUPPORT_FULL_SHIELD_AMOUNT,
					SUPPORT_FULL_SHIELD_DURATION
				)


				debug_log(
					"Overwhelming Presence! "
					+ str(name)
					+ " gave "
					+ str(shield_target.name)
					+ " a "
					+ str(SUPPORT_FULL_SHIELD_AMOUNT)
					+ " HP shield."
				)


# =========================================================
# MARKSMAN - STEADY AIM / DEADEYE
# =========================================================

func reset_steady_aim_if_moving() -> void:

	if character_data == null:
		return

	if character_data.class_role != "Marksman":
		return

	if not class_synergy_active:
		return

	if steady_aim_stacks <= 0:
		return


	steady_aim_stacks = 0


	debug_log(
		"Steady Aim reset! "
		+ str(name)
		+ " moved."
	)


func gain_steady_aim_stack() -> void:

	if character_data == null:
		return

	if character_data.class_role != "Marksman":
		return

	if not class_synergy_active:
		return

	if steady_aim_stacks >= STEADY_AIM_MAX_STACKS:
		return


	steady_aim_stacks += 1


	var speed_per_stack: float = (
		STEADY_AIM_SMALL_SPEED_PER_STACK
	)


	if class_synergy_tier >= 4:

		speed_per_stack = (
			STEADY_AIM_FULL_SPEED_PER_STACK
		)


	var attack_speed_percent: int = int(
		round(
			steady_aim_stacks
			* speed_per_stack
			* 100
		)
	)


	debug_log(
		"Steady Aim! "
		+ str(name)
		+ " now has "
		+ str(steady_aim_stacks)
		+ " stack(s) - +"
		+ str(attack_speed_percent)
		+ "% Attack Speed."
	)


# =========================================================
# TARGETING
# =========================================================

func find_closest_enemy() -> CharacterBody2D:

	var closest_enemy: CharacterBody2D = null
	var closest_distance: float = INF


	for node in get_tree().get_nodes_in_group(
		"Characters"
	):

		if node == self:
			continue

		if node.team_id == team_id:
			continue

		if not node.is_alive:
			continue


		var distance = (
			global_position.distance_to(
				node.global_position
			)
		)


		if distance < closest_distance:

			closest_distance = distance
			closest_enemy = node


	return closest_enemy


# =========================================================
# BASIC ATTACK
# =========================================================

func attack_target() -> void:

	if target == null:
		return

	if not is_instance_valid(target):
		return

	if not target.is_alive:
		return


	var is_new_target: bool = (
		target != previous_target
	)


	if is_new_target:

		previous_target = target
		same_target_attack_count = 0


	same_target_attack_count += 1
	attack_count += 1


	var final_damage: int = (
		damage
		+ blood_frenzy_bonus
		+ fighter_momentum_bonus
		+ united_colony_damage_bonus
	)


	final_damage = (
		apply_starting_attack_ability(
			final_damage,
			is_new_target
		)
	)


	final_damage = (
		apply_attack_upgrade_effects(
			final_damage,
			is_new_target
		)
	)


	final_damage = (
		apply_faction_attack_synergy(
			final_damage,
			is_new_target
		)
	)


	final_damage = (
		apply_class_attack_synergy(
			final_damage,
			is_new_target
		)
	)


	if target.marked_for_team == team_id:

		final_damage += (
			target.marked_bonus_damage
		)


	target.take_damage(
		final_damage
	)


	debug_log(
		str(name)
		+ " attacked "
		+ str(target.name)
		+ " for "
		+ str(final_damage)
		+ " damage"
	)


	after_basic_attack(
		is_new_target
	)


	gain_steady_aim_stack()


	attack_timer = (
		get_current_attack_cooldown()
	)


# =========================================================
# CLASS ATTACK SYNERGIES
# =========================================================

func apply_class_attack_synergy(
	final_damage: int,
	is_new_target: bool
) -> int:

	if character_data == null:
		return final_damage

	if not class_synergy_active:
		return final_damage


	# =====================================================
	# ASSASSIN
	# =====================================================

	if character_data.class_role == "Assassin":

		if is_new_target:

			var new_target_bonus: int = (
				ASSASSIN_SMALL_NEW_TARGET_DAMAGE_BONUS
			)


			if class_synergy_tier >= 4:

				new_target_bonus = (
					ASSASSIN_FULL_NEW_TARGET_DAMAGE_BONUS
				)


			final_damage += (
				new_target_bonus
			)


			debug_log(
				"Assassin opening strike! "
				+ str(name)
				+ " gained +"
				+ str(new_target_bonus)
				+ " damage against "
				+ str(target.name)
				+ "!"
			)


		# 4 Assassin - Execution Protocol.
		if (
			class_synergy_tier >= 4
			and target != null
			and is_instance_valid(target)
			and target.max_health > 0
		):

			var target_health_percent: float = (
				float(target.current_health)
				/ float(target.max_health)
			)


			if (
				target_health_percent
				<= ASSASSIN_EXECUTION_HEALTH_THRESHOLD
			):

				final_damage = int(
					round(
						final_damage
						* ASSASSIN_EXECUTION_DAMAGE_MULTIPLIER
					)
				)


				debug_log(
					"Execution Protocol activated! "
					+ str(name)
					+ " dealt 25% increased damage."
				)


	# =====================================================
	# MARKSMAN 4 - DEADEYE
	# =====================================================

	if (
		character_data.class_role == "Marksman"
		and class_synergy_tier >= 4
		and steady_aim_stacks >= STEADY_AIM_MAX_STACKS
	):

		final_damage = int(
			round(
				final_damage
				* DEADEYE_DAMAGE_MULTIPLIER
			)
		)


		debug_log(
			"Deadeye activated! "
			+ str(name)
			+ " dealt 20% increased basic attack damage."
		)


	return final_damage


# =========================================================
# FACTION ATTACK SYNERGIES
# =========================================================

func apply_faction_attack_synergy(
	final_damage: int,
	is_new_target: bool
) -> int:

	if character_data == null:
		return final_damage


	var faction_name: String = (
		character_data.faction
	)


	# =====================================================
	# ANTTALOPE
	# =====================================================

	if faction_name == "Anttalope":

		if faction_synergy_tier >= 4:

			if is_new_target:

				final_damage += 4


				debug_log(
					"Perfect Hunt opening strike! "
					+ str(name)
					+ " gained +4 damage."
				)


			elif same_target_attack_count >= 2:

				final_damage += 4


				debug_log(
					"Perfect Hunt focused strike! "
					+ str(name)
					+ " gained +4 damage."
				)


		elif faction_synergy_tier >= 2:

			if same_target_attack_count >= 2:

				final_damage += 2


				debug_log(
					"Hunter's Focus activated! "
					+ str(name)
					+ " gained +2 damage."
				)


	# =====================================================
	# SCOLYRA
	# =====================================================

	elif (
		faction_name == "Scolyra"
		and faction_synergy_tier >= 2
	):

		# First attack against a target has zero
		# Venom stacks.
		#
		# Each following attack adds one stack.
		var venom_stacks: int = clamp(
			same_target_attack_count - 1,
			0,
			SCOLYRA_MAX_VENOM_STACKS
		)


		var damage_per_stack: int = (
			SCOLYRA_SMALL_DAMAGE_PER_STACK
		)


		if faction_synergy_tier >= 4:

			damage_per_stack = (
				SCOLYRA_FULL_DAMAGE_PER_STACK
			)


		var venom_bonus: int = (
			venom_stacks
			* damage_per_stack
		)


		final_damage += venom_bonus


		if venom_bonus > 0:

			debug_log(
				"Scolyra Venom! "
				+ str(name)
				+ " has "
				+ str(venom_stacks)
				+ " Venom stack(s) and gained +"
				+ str(venom_bonus)
				+ " damage."
			)


	return final_damage


# =========================================================
# STARTING UNIQUE ATTACK ABILITIES
# =========================================================

func apply_starting_attack_ability(
	final_damage: int,
	is_new_target: bool
) -> int:

	var character_name = (
		get_character_name()
	)


	if (
		character_name == "Zekrin"
		and is_new_target
	):

		final_damage += 5


		debug_log(
			"Predator Sting activated!"
		)


	elif character_name == "Aurex":

		if attack_count % 4 == 0:

			final_damage += 4


			debug_log(
				"Piercing Needle activated!"
			)


	if (
		character_name == "Kaelor"
		and is_new_target
	):

		var first_cut_bonus: int = 4


		if has_effect("perfect_cut"):
			first_cut_bonus = 8


		final_damage += first_cut_bonus


		debug_log(
			"First Cut activated!"
		)


	if (
		character_name == "Syrra"
		and attack_count == 1
	):

		move_speed -= 20


		debug_log(
			"Ambush Instinct completed!"
		)


	if character_name == "Nyxis":

		if attack_count % 5 == 0:

			var acid_bonus: int = 5


			if has_effect("potent_acid"):
				acid_bonus = 10


			final_damage += acid_bonus


			debug_log(
				"Corrosive Shot activated!"
			)


	return final_damage


# =========================================================
# SPECIAL ATTACK UPGRADES
# =========================================================

func apply_attack_upgrade_effects(
	final_damage: int,
	is_new_target: bool
) -> int:

	var character_name = (
		get_character_name()
	)


	if has_effect("execute_damage_5"):

		if (
			target.current_health
			<= target.max_health * 0.5
		):

			final_damage += 5


			debug_log(
				"Serrated Stinger activated!"
			)


	if character_name == "Syrra":

		if (
			has_effect("killing_leap")
			and is_new_target
		):

			final_damage += 7


			debug_log(
				"Killing Leap activated!"
			)


	return final_damage


# =========================================================
# AFTER ATTACK EFFECTS
# =========================================================

func after_basic_attack(
	_is_new_target: bool
) -> void:

	var character_name = (
		get_character_name()
	)


	if character_name == "Melora":

		if attack_count % 5 == 0:
			activate_royal_nectar()


	if character_name == "Aurex":

		if has_effect("needle_barrage"):

			if attack_count % 4 == 0:

				if (
					target != null
					and is_instance_valid(target)
				):

					if target.is_alive:

						var barrage_damage: int = max(
							1,
							int(damage * 0.5)
						)


						target.take_damage(
							barrage_damage
						)


						debug_log(
							"Needle Barrage dealt "
							+ str(barrage_damage)
							+ " extra damage!"
						)


	if character_name == "Kaelor":

		if has_effect("blade_guard"):
			blade_guard_ready = true


	if character_name == "Velkara":
		apply_marked_prey()


	if character_name == "Nyxis":

		if has_effect("acid_volley"):

			if attack_count % 5 == 0:

				if (
					target != null
					and is_instance_valid(target)
				):

					if target.is_alive:

						target.take_damage(
							damage
						)


						debug_log(
							"Acid Volley hit again for "
							+ str(damage)
							+ " damage!"
						)


# =========================================================
# MELORA - ROYAL NECTAR
# =========================================================

func activate_royal_nectar() -> void:

	var ally = (
		find_lowest_health_ally()
	)


	if ally == null:
		return


	var heal_amount: int = 8


	if has_effect("nectar_heal_plus_5"):
		heal_amount += 5


	if support_synergy_active:

		heal_amount = int(
			round(
				heal_amount
				* get_support_effect_multiplier()
			)
		)


		debug_log(
			"Support synergy strengthened "
			+ "Royal Nectar!"
		)


	ally.heal(
		heal_amount
	)


	debug_log(
		"Royal Nectar healed "
		+ str(ally.name)
		+ " for "
		+ str(heal_amount)
		+ " HP!"
	)


	if has_effect("nectar_attack_speed"):

		ally.receive_attack_speed_buff(
			0.80,
			2.0
		)


		debug_log(
			str(ally.name)
			+ " received Energizing Honey!"
		)


	if has_effect("nectar_self_heal"):

		heal(4)


		debug_log(
			"Nectar Reserve healed Melora!"
		)


# =========================================================
# FIND LOWEST HEALTH ALLY
# =========================================================

func find_lowest_health_ally() -> CharacterBody2D:

	var lowest_ally: CharacterBody2D = null
	var lowest_health_percent: float = INF


	for node in get_tree().get_nodes_in_group(
		"Characters"
	):

		if node.team_id != team_id:
			continue

		if not node.is_alive:
			continue


		var health_percent = (
			float(node.current_health)
			/ float(node.max_health)
		)


		if health_percent < lowest_health_percent:

			lowest_health_percent = health_percent
			lowest_ally = node


	return lowest_ally


# =========================================================
# SUPPORT EFFECT MULTIPLIER
# =========================================================

func get_support_effect_multiplier() -> float:

	if support_synergy_tier >= 4:

		return (
			SUPPORT_FULL_EFFECT_MULTIPLIER
		)


	if support_synergy_tier >= 2:

		return (
			SUPPORT_SMALL_EFFECT_MULTIPLIER
		)


	return 1.0


# =========================================================
# VELKARA - MARKED PREY
# =========================================================

func apply_marked_prey() -> void:

	if attack_count != 1:
		return

	if target == null:
		return

	if not is_instance_valid(target):
		return


	var mark_duration: float = 4.0
	var bonus_damage: int = 1


	if has_effect("longer_mark"):
		mark_duration = 7.0


	if has_effect("stronger_mark"):
		bonus_damage = 2


	if support_synergy_active:

		mark_duration *= (
			get_support_effect_multiplier()
		)


		debug_log(
			"Support synergy strengthened "
			+ "Marked Prey!"
		)


	target.receive_mark(
		team_id,
		bonus_damage,
		mark_duration
	)


	debug_log(
		"Velkara marked "
		+ str(target.name)
		+ " for "
		+ str(mark_duration)
		+ " seconds!"
	)


func receive_mark(
	marking_team: int,
	bonus_damage: int,
	duration: float
) -> void:

	marked_for_team = marking_team
	marked_bonus_damage = bonus_damage
	marked_timer = duration


# =========================================================
# SHIELDS
# =========================================================

func receive_shield(
	amount: int,
	duration: float
) -> void:

	if not is_alive:
		return


	current_shield += amount


	# Reset the duration whenever a new
	# temporary shield is added.
	shield_timer = max(
		shield_timer,
		duration
	)


	debug_log(
		str(name)
		+ " gained "
		+ str(amount)
		+ " shield. Total Shield: "
		+ str(current_shield)
	)


# =========================================================
# HEALTH / DAMAGE
# =========================================================

func take_damage(amount: int) -> void:

	if not is_alive:
		return


	var final_damage: int = amount


	var character_name = (
		get_character_name()
	)


	# =====================================================
	# VANGUARD DAMAGE REDUCTION
	# =====================================================

	if (
		character_data != null
		and character_data.class_role == "Vanguard"
		and class_synergy_active
	):

		var vanguard_reduction: int = (
			VANGUARD_SMALL_DAMAGE_REDUCTION
		)


		if class_synergy_tier >= 4:

			vanguard_reduction = (
				VANGUARD_FULL_DAMAGE_REDUCTION
			)


		final_damage -= (
			vanguard_reduction
		)


		debug_log(
			"Vanguard synergy reduced damage to "
			+ str(name)
			+ " by "
			+ str(vanguard_reduction)
			+ "!"
		)


	# =====================================================
	# LEPIDRA
	# =====================================================

	if (
		character_data != null
		and character_data.faction == "Lepidra"
		and faction_synergy_tier >= 2
		and lepidra_protected_hits_remaining > 0
	):

		if faction_synergy_tier >= 4:

			final_damage = int(
				round(
					final_damage
					* LEPIDRA_FULL_DAMAGE_MULTIPLIER
				)
			)


			lunar_veil_speed_bonus = (
				LUNAR_VEIL_SPEED_BONUS
			)


			lunar_veil_speed_timer = (
				LUNAR_VEIL_SPEED_DURATION
			)


			debug_log(
				"Lunar Veil activated on "
				+ str(name)
				+ "! Damage reduced by 25% "
				+ "and +15 Move Speed for 2 seconds."
			)


		else:

			final_damage = int(
				round(
					final_damage
					* LEPIDRA_SMALL_DAMAGE_MULTIPLIER
				)
			)


			debug_log(
				"Veil of Dust activated on "
				+ str(name)
				+ "! Damage reduced by 15%."
			)


		lepidra_protected_hits_remaining -= 1


		debug_log(
			str(name)
			+ " has "
			+ str(lepidra_protected_hits_remaining)
			+ " protected Lepidra hit(s) remaining."
		)


	# =====================================================
	# FORMICARA
	# =====================================================

	if (
		character_data != null
		and character_data.faction == "Formicara"
		and faction_synergy_tier >= 2
	):

		var colony_reduction: int = (
			FORMICARA_SMALL_DAMAGE_REDUCTION
		)


		if faction_synergy_tier >= 4:

			colony_reduction = (
				FORMICARA_FULL_DAMAGE_REDUCTION
			)


		final_damage -= colony_reduction


		debug_log(
			"Formicara colony defense reduced damage "
			+ "to "
			+ str(name)
			+ " by "
			+ str(colony_reduction)
			+ "!"
		)


	# =====================================================
	# VEYRA
	# =====================================================

	if character_name == "Veyra":

		if wax_guard_available:

			final_damage = int(
				final_damage * 0.5
			)


			wax_guard_available = false


			debug_log(
				"Wax Guard activated!"
			)


		if has_effect("damage_reduction_2"):

			final_damage -= 2


	# =====================================================
	# DROVEN
	# =====================================================

	if character_name == "Droven":

		if guarded_hits_remaining > 0:

			var reduction: int = 3


			if has_effect("reinforced_guard"):
				reduction = 5


			final_damage -= reduction
			guarded_hits_remaining -= 1


			debug_log(
				"Guarded Stance activated! "
				+ str(guarded_hits_remaining)
				+ " guarded hits remaining."
			)


	# =====================================================
	# KAELOR
	# =====================================================

	if character_name == "Kaelor":

		if blade_guard_ready:

			final_damage -= 3
			blade_guard_ready = false


			debug_log(
				"Blade Guard activated!"
			)


	final_damage = max(
		0,
		final_damage
	)


	# =====================================================
	# SHIELD DAMAGE
	# =====================================================

	if current_shield > 0:

		var absorbed_damage: int = min(
			current_shield,
			final_damage
		)


		current_shield -= (
			absorbed_damage
		)


		final_damage -= (
			absorbed_damage
		)


		debug_log(
			str(name)
			+ "'s shield absorbed "
			+ str(absorbed_damage)
			+ " damage. Shield Remaining: "
			+ str(current_shield)
		)


		if current_shield <= 0:
			shield_timer = 0.0


	current_health -= final_damage


	if current_health < 0:
		current_health = 0


	debug_log(
		str(name)
		+ " HP: "
		+ str(current_health)
		+ "/"
		+ str(max_health)
	)


	# =====================================================
	# VANGUARD 4 - FORTRESS
	# =====================================================

	if (
		is_alive
		and current_health > 0
		and character_data != null
		and character_data.class_role == "Vanguard"
		and class_synergy_tier >= 4
		and not fortress_shield_used
	):

		var health_percent: float = (
			float(current_health)
			/ float(max_health)
		)


		if health_percent <= VANGUARD_FORTRESS_TRIGGER:

			fortress_shield_used = true


			receive_shield(
				VANGUARD_FORTRESS_SHIELD,
				VANGUARD_FORTRESS_SHIELD_DURATION
			)


			debug_log(
				"Fortress activated on "
				+ str(name)
				+ "!"
			)


	# =====================================================
	# CARAPHEX 4 - LAST SHELL
	# =====================================================

	if (
		is_alive
		and current_health > 0
		and character_data != null
		and character_data.faction == "Caraphex"
		and faction_synergy_tier >= 4
		and not last_shell_used
	):

		var caraphex_health_percent: float = (
			float(current_health)
			/ float(max_health)
		)


		if (
			caraphex_health_percent
			<= CARAPHEX_LAST_SHELL_TRIGGER
		):

			last_shell_used = true


			var last_shell_amount: int = int(
				round(
					max_health
					* CARAPHEX_LAST_SHELL_SHIELD_PERCENT
				)
			)


			receive_shield(
				last_shell_amount,
				CARAPHEX_LAST_SHELL_DURATION
			)


			debug_log(
				"Last Shell activated on "
				+ str(name)
				+ " for "
				+ str(last_shell_amount)
				+ " shield!"
			)


	# =====================================================
	# THAROS
	# =====================================================

	if (
		character_name == "Tharos"
		and final_damage > 0
	):

		activate_frenzy_wings()


		if has_effect("blood_frenzy"):

			blood_frenzy_bonus = 3
			blood_frenzy_timer = 2.0


			debug_log(
				"Blood Frenzy activated!"
			)


	if current_health <= 0:
		die()


# =========================================================
# THAROS - FRENZY WINGS
# =========================================================

func activate_frenzy_wings() -> void:

	frenzy_wings_bonus = 15
	frenzy_wings_timer = 2.0


	if has_effect(
		"better_frenzy_wings"
	):

		frenzy_wings_bonus = 25
		frenzy_wings_timer = 3.0


	debug_log(
		"Frenzy Wings activated!"
	)


# =========================================================
# HEALING
# =========================================================

func heal(amount: int) -> void:

	if not is_alive:
		return


	current_health += amount


	if current_health > max_health:
		current_health = max_health


# =========================================================
# TEMPORARY ATTACK SPEED
# =========================================================

func receive_attack_speed_buff(
	multiplier: float,
	duration: float
) -> void:

	temporary_attack_speed_multiplier = multiplier
	temporary_attack_speed_timer = duration


# =========================================================
# CURRENT MOVEMENT SPEED
# =========================================================

func get_current_move_speed() -> float:

	return (
		move_speed
		+ frenzy_wings_bonus
		+ lunar_veil_speed_bonus
	)


# =========================================================
# CURRENT ATTACK COOLDOWN
# =========================================================

func get_current_attack_cooldown() -> float:

	var final_cooldown: float = (
		attack_cooldown
		* temporary_attack_speed_multiplier
	)


	# =====================================================
	# MARKSMAN - STEADY AIM / DEADEYE
	# =====================================================

	if (
		character_data != null
		and character_data.class_role == "Marksman"
		and class_synergy_active
		and steady_aim_stacks > 0
	):

		var speed_per_stack: float = (
			STEADY_AIM_SMALL_SPEED_PER_STACK
		)


		if class_synergy_tier >= 4:

			speed_per_stack = (
				STEADY_AIM_FULL_SPEED_PER_STACK
			)


		var steady_aim_bonus: float = (
			steady_aim_stacks
			* speed_per_stack
		)


		final_cooldown *= (
			1.0
			- steady_aim_bonus
		)


	# =====================================================
	# FIGHTER 4 - WAR MACHINE
	# =====================================================

	if (
		character_data != null
		and character_data.class_role == "Fighter"
		and class_synergy_tier >= 4
		and fighter_momentum_bonus
		>= FIGHTER_FULL_MOMENTUM_MAX
	):

		final_cooldown *= (
			FIGHTER_WAR_MACHINE_SPEED_MULTIPLIER
		)


	# =====================================================
	# SCOLYRA 4 - PREDATORY FRENZY
	# =====================================================

	if (
		character_data != null
		and character_data.faction == "Scolyra"
		and faction_synergy_tier >= 4
	):

		var venom_stacks: int = clamp(
			same_target_attack_count - 1,
			0,
			SCOLYRA_MAX_VENOM_STACKS
		)


		if venom_stacks >= SCOLYRA_MAX_VENOM_STACKS:

			final_cooldown *= (
				SCOLYRA_FULL_ATTACK_SPEED_MULTIPLIER
			)


	# =====================================================
	# KAELOR - DUELIST RHYTHM
	# =====================================================

	if has_effect("duelist_rhythm"):

		var rhythm_bonus: float = min(
			same_target_attack_count * 0.05,
			0.20
		)


		final_cooldown *= (
			1.0
			- rhythm_bonus
		)


	# =====================================================
	# FINAL COOLDOWN CAP
	# =====================================================

	return max(
		MIN_ATTACK_COOLDOWN,
		final_cooldown
	)


# =========================================================
# APPLY SAVED STAT UPGRADES
# =========================================================

func apply_saved_upgrades() -> void:

	if character_data == null:
		return


	var character_name = (
		character_data.character_name
	)


	if not GameState.character_upgrades.has(
		character_name
	):

		return


	var upgrades = (
		GameState.character_upgrades[
			character_name
		]
	)


	debug_log(
		"Applying "
		+ str(upgrades.size())
		+ " upgrade(s) to "
		+ character_name
	)


	for upgrade in upgrades:


		# =========================
		# HEALTH
		# =========================

		if upgrade.has("health_bonus"):

			max_health += (
				upgrade["health_bonus"]
			)


		# =========================
		# DAMAGE
		# =========================

		if upgrade.has("damage_bonus"):

			damage += (
				upgrade["damage_bonus"]
			)


		# =========================
		# MOVEMENT SPEED
		# =========================

		if upgrade.has(
			"move_speed_bonus"
		):

			move_speed += (
				upgrade[
					"move_speed_bonus"
				]
			)


		# =========================
		# RANGE
		# =========================

		if upgrade.has("range_bonus"):

			attack_range += (
				upgrade["range_bonus"]
			)


		# =================================================
		# FLAT COOLDOWN EQUIPMENT
		# =================================================

		if upgrade.has(
			"cooldown_reduction"
		):

			attack_cooldown -= (
				upgrade[
					"cooldown_reduction"
				]
			)


			attack_cooldown = max(
				MIN_ATTACK_COOLDOWN,
				attack_cooldown
			)


		# =================================================
		# OLD PERCENTAGE ATTACK-SPEED ABILITIES
		# =================================================

		if upgrade.has(
			"cooldown_multiplier"
		):

			attack_cooldown *= (
				upgrade[
					"cooldown_multiplier"
				]
			)


			attack_cooldown = max(
				MIN_ATTACK_COOLDOWN,
				attack_cooldown
			)


		debug_log(
			character_name
			+ " gained upgrade: "
			+ str(upgrade["name"])
		)


# =========================================================
# CHECK SPECIAL UPGRADE
# =========================================================

func has_effect(
	effect_id: String
) -> bool:

	if team_id != 1:
		return false


	var character_name = (
		get_character_name()
	)


	if not GameState.character_upgrades.has(
		character_name
	):

		return false


	for upgrade in GameState.character_upgrades[
		character_name
	]:

		if upgrade.has("effect_id"):

			if (
				upgrade["effect_id"]
				== effect_id
			):

				return true


	return false


# =========================================================
# CHARACTER NAME HELPER
# =========================================================

func get_character_name() -> String:

	if character_data:

		return (
			character_data.character_name
		)


	return str(name)


# =========================================================
# DEBUG LOGGING
# =========================================================

func debug_log(
	message: String
) -> void:

	if debug_combat_logs:
		print(message)


# =========================================================
# UNITED COLONY DEATH BONUS
# =========================================================

func trigger_united_colony_death_bonus() -> void:

	for node in get_tree().get_nodes_in_group(
		"Characters"
	):

		if node == self:
			continue

		if not is_instance_valid(node):
			continue

		if not node.is_alive:
			continue

		if node.team_id != team_id:
			continue

		if node.character_data == null:
			continue

		if node.character_data.faction != "Formicara":
			continue


		node.united_colony_damage_bonus += (
			UNITED_COLONY_DEATH_DAMAGE_BONUS
		)


		node.debug_log(
			"United Colony! "
			+ str(node.name)
			+ " gained +"
			+ str(
				UNITED_COLONY_DEATH_DAMAGE_BONUS
			)
			+ " ATK because "
			+ str(name)
			+ " was defeated."
		)


# =========================================================
# DEATH
# =========================================================

func die() -> void:

	if not is_alive:
		return


	is_alive = false
	velocity = Vector2.ZERO


	debug_log(
		str(name)
		+ " has been defeated!"
	)


	if (
		character_data != null
		and character_data.faction == "Formicara"
		and faction_synergy_tier >= 4
	):

		trigger_united_colony_death_bonus()


	queue_free()
