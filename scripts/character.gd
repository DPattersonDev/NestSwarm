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

@onready var placeholder_visual: ColorRect = $ColorRect
@onready var battle_sprite: Sprite2D = $BattleSprite

# =========================================================
# GLOBAL COMBAT LIMITS
# =========================================================

const MIN_ATTACK_COOLDOWN: float = 0.25

# =========================================================
# BASIC CHARACTER STATE
# =========================================================

var current_health: int = 0

var target: CharacterBody2D = null

var previous_target: CharacterBody2D = null

var attack_timer: float = 0.0

var attack_count: int = 0

var same_target_attack_count: int = 0

var is_alive: bool = true

var spawn_position: Vector2

# =========================================================
# GENERIC ABILITY STATE
# =========================================================
#
# We use shared dictionaries instead of creating dozens
# of individual one-off variables.
#
# flags:
# one-time activations / boolean states
#
# counters:
# attack counters / activation counters
#
# cooldowns:
# ability name -> absolute time when ready again
# =========================================================

var ability_flags: Dictionary = {}

var ability_counters: Dictionary = {}

var cooldowns: Dictionary = {}

# =========================================================
# TEMPORARY BUFF STATE
# =========================================================

var move_speed_buffs: Dictionary = {}

var attack_speed_buffs: Dictionary = {}

var damage_buffs: Dictionary = {}

var damage_reduction_buffs: Dictionary = {}

var move_slow_effects: Dictionary = {}

var attack_slow_effects: Dictionary = {}

# =========================================================
# CROWD CONTROL STATE
# =========================================================

var stagger_until: float = 0.0

var untargetable_until: float = 0.0

var forced_target: CharacterBody2D = null

var forced_target_until: float = 0.0

# =========================================================
# SHIELD STATE
# =========================================================

var current_shield: int = 0

var shield_timer: float = 0.0

# =========================================================
# DAMAGE HISTORY
# =========================================================

var last_damage_time: float = -999.0

var last_damage_team: int = 0

var last_damage_attacker_id: int = 0

var last_formicara_damage_time: float = -999.0

var last_formicara_damage_team: int = 0

var last_formicara_attacker_id: int = 0

# =========================================================
# MARK / CORROSION STATE
# =========================================================

var marked_timer: float = 0.0

var marked_for_team: int = 0

var marked_bonus_damage: int = 0

var corrosion_timer: float = 0.0

var corrosion_team: int = 0

var corrosion_bonus_damage: int = 0

# =========================================================
# DAMAGE OVER TIME
# =========================================================
#
# key -> {
#     damage,
#     ticks,
#     timer,
#     interval
# }
# =========================================================

var active_dots: Dictionary = {}

# =========================================================
# TARGET / SPECIAL REFERENCES
# =========================================================

var initial_ability_target: CharacterBody2D = null

var marked_prey_target: CharacterBody2D = null

var toxic_guard_target: CharacterBody2D = null

# =========================================================
# FACTION SYNERGY STATE
# =========================================================

var faction_synergy_tier: int = 0

# =========================================================
# VESPER SYNERGY
# =========================================================

var hive_mind_heal_timer: float = 4.0

const HIVE_MIND_HEAL_INTERVAL: float = 4.0
const HIVE_MIND_HEAL_AMOUNT: int = 3

# =========================================================
# LEPIDRA SYNERGY
# =========================================================

var lepidra_protected_hits_remaining: int = 2

const LEPIDRA_SMALL_DAMAGE_MULTIPLIER: float = 0.85
const LEPIDRA_FULL_DAMAGE_MULTIPLIER: float = 0.75

const LUNAR_VEIL_SPEED_BONUS: float = 15.0
const LUNAR_VEIL_SPEED_DURATION: float = 2.0

# =========================================================
# FORMICARA SYNERGY
# =========================================================

const FORMICARA_SMALL_DAMAGE_REDUCTION: int = 2
const FORMICARA_FULL_DAMAGE_REDUCTION: int = 3

const UNITED_COLONY_DEATH_DAMAGE_BONUS: int = 2

var united_colony_damage_bonus: int = 0

# =========================================================
# CARAPHEX SYNERGY
# =========================================================

const CARAPHEX_SMALL_HEALTH_MULTIPLIER: float = 1.15
const CARAPHEX_FULL_HEALTH_MULTIPLIER: float = 1.25

const CARAPHEX_LAST_SHELL_TRIGGER: float = 0.30
const CARAPHEX_LAST_SHELL_SHIELD_PERCENT: float = 0.20
const CARAPHEX_LAST_SHELL_DURATION: float = 4.0

var last_shell_used: bool = false

# =========================================================
# SCOLYRA SYNERGY
# =========================================================

const SCOLYRA_MAX_VENOM_STACKS: int = 5

const SCOLYRA_SMALL_DAMAGE_PER_STACK: int = 1
const SCOLYRA_FULL_DAMAGE_PER_STACK: int = 2

const SCOLYRA_FULL_ATTACK_SPEED_MULTIPLIER: float = 0.85

# =========================================================
# CLASS SYNERGY STATE
# =========================================================

var class_synergy_tier: int = 0

var class_synergy_active: bool = false

var support_synergy_tier: int = 0

var support_synergy_active: bool = false

# =========================================================
# VANGUARD SYNERGY
# =========================================================

const VANGUARD_SMALL_HEALTH_BONUS: int = 25
const VANGUARD_SMALL_DAMAGE_REDUCTION: int = 2

const VANGUARD_FULL_HEALTH_BONUS: int = 50
const VANGUARD_FULL_DAMAGE_REDUCTION: int = 4

const VANGUARD_FORTRESS_TRIGGER: float = 0.40
const VANGUARD_FORTRESS_SHIELD: int = 30
const VANGUARD_FORTRESS_SHIELD_DURATION: float = 4.0

var fortress_shield_used: bool = false

# =========================================================
# FIGHTER SYNERGY
# =========================================================

var fighter_momentum_timer: float = 3.0

var fighter_momentum_bonus: int = 0

const FIGHTER_MOMENTUM_INTERVAL: float = 3.0

const FIGHTER_SMALL_MOMENTUM_PER_STACK: int = 1
const FIGHTER_SMALL_MOMENTUM_MAX: int = 5

const FIGHTER_FULL_MOMENTUM_PER_STACK: int = 2
const FIGHTER_FULL_MOMENTUM_MAX: int = 10

const FIGHTER_WAR_MACHINE_SPEED_MULTIPLIER: float = 0.85

# =========================================================
# ASSASSIN SYNERGY
# =========================================================

const ASSASSIN_SMALL_MOVE_SPEED_BONUS: float = 20.0
const ASSASSIN_SMALL_NEW_TARGET_DAMAGE_BONUS: int = 4

const ASSASSIN_FULL_MOVE_SPEED_BONUS: float = 30.0
const ASSASSIN_FULL_NEW_TARGET_DAMAGE_BONUS: int = 8

const ASSASSIN_EXECUTION_HEALTH_THRESHOLD: float = 0.30
const ASSASSIN_EXECUTION_DAMAGE_MULTIPLIER: float = 1.25

# =========================================================
# MARKSMAN SYNERGY
# =========================================================

var steady_aim_stacks: int = 0

var entrenched_stationary_timer: float = 0.0

const STEADY_AIM_MAX_STACKS: int = 4

const STEADY_AIM_SMALL_SPEED_PER_STACK: float = 0.05
const STEADY_AIM_FULL_SPEED_PER_STACK: float = 0.075

const DEADEYE_DAMAGE_MULTIPLIER: float = 1.20

# =========================================================
# SUPPORT SYNERGY
# =========================================================

const SUPPORT_SMALL_TEAM_ATTACK_SPEED_MULTIPLIER: float = 0.95
const SUPPORT_SMALL_EFFECT_MULTIPLIER: float = 1.25

const SUPPORT_FULL_TEAM_ATTACK_SPEED_MULTIPLIER: float = 0.90
const SUPPORT_FULL_EFFECT_MULTIPLIER: float = 1.50

const SUPPORT_FULL_SHIELD_INTERVAL: float = 5.0
const SUPPORT_FULL_SHIELD_AMOUNT: int = 15
const SUPPORT_FULL_SHIELD_DURATION: float = 4.0

var support_full_shield_timer: float = 5.0

# =========================================================
# TIME HELPER
# =========================================================

func combat_time() -> float:

	return (
		float(
			Time.get_ticks_msec()
		)
		/ 1000.0
	)

# =========================================================
# STARTUP
# =========================================================

func _ready() -> void:

	spawn_position = global_position

	if character_data != null:

		max_health = character_data.max_health
		damage = character_data.damage
		move_speed = character_data.move_speed
		attack_range = character_data.attack_range
		attack_cooldown = character_data.attack_cooldown

		name = character_data.character_name

	setup_battle_visual()

	if team_id == 1:

		apply_saved_upgrades()

	apply_faction_synergy()

	apply_class_synergy()

	current_health = max_health

	await get_tree().process_frame

	set_target(
		find_closest_enemy()
	)

	activate_combat_start_basic()

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

	if target != null:

		debug_log(
			str(name)
			+ " found enemy: "
			+ str(target.name)
		)

# =========================================================
# SETUP BATTLE VISUAL
# =========================================================

func setup_battle_visual() -> void:

	if character_data == null:

		battle_sprite.texture = null
		battle_sprite.visible = false
		placeholder_visual.visible = true

		return

	if character_data.battle_texture != null:

		battle_sprite.texture = (
			character_data.battle_texture
		)

		battle_sprite.visible = true
		placeholder_visual.visible = false

		battle_sprite.scale = Vector2(
			0.05,
			0.05
		)

	else:

		battle_sprite.texture = null
		battle_sprite.visible = false
		placeholder_visual.visible = true

# =========================================================
# ABILITY HELPERS
# =========================================================

func get_basic_ability_id() -> String:

	if character_data == null:
		return ""

	return character_data.basic_ability_id

func has_effect(
	effect_id: String
) -> bool:

	# Current dev enemy team has no upgrade loadout.
	#
	# When PvP is added, both teams will eventually
	# read their upgrades from their own player state.
	if team_id != 1:
		return false

	var character_name: String = (
		get_character_name()
	)

	if not GameState.character_upgrades.has(
		character_name
	):

		return false

	for upgrade in GameState.character_upgrades[
		character_name
	]:

		if not upgrade.has(
			"effect_id"
		):
			continue

		if (
			str(
				upgrade["effect_id"]
			)
			== effect_id
		):

			return true

	return false

func flag_used(
	key: String
) -> bool:

	return bool(
		ability_flags.get(
			key,
			false
		)
	)

func set_flag(
	key: String
) -> void:

	ability_flags[key] = true

func get_counter(
	key: String
) -> int:

	return int(
		ability_counters.get(
			key,
			0
		)
	)

func add_counter(
	key: String,
	amount: int = 1
) -> int:

	var new_value: int = (
		get_counter(key)
		+ amount
	)

	ability_counters[key] = (
		new_value
	)

	return new_value

func reset_counter(
	key: String
) -> void:

	ability_counters[key] = 0

func ability_ready(
	key: String
) -> bool:

	return (
		combat_time()
		>= float(
			cooldowns.get(
				key,
				0.0
			)
		)
	)

func start_cooldown(
	key: String,
	duration: float
) -> void:

	cooldowns[key] = (
		combat_time()
		+ duration
	)

# =========================================================
# GENERIC BUFF HELPERS
# =========================================================

func add_move_speed_buff(
	key: String,
	bonus: float,
	duration: float
) -> void:

	move_speed_buffs[key] = {
		"bonus": bonus,
		"end": combat_time() + duration
	}

func add_attack_speed_buff(
	key: String,
	multiplier: float,
	duration: float
) -> void:

	attack_speed_buffs[key] = {
		"multiplier": multiplier,
		"end": combat_time() + duration
	}

func add_damage_buff(
	key: String,
	bonus: int,
	duration: float
) -> void:

	damage_buffs[key] = {
		"bonus": bonus,
		"end": combat_time() + duration
	}

func add_damage_reduction_buff(
	key: String,
	reduction: float,
	duration: float
) -> void:

	damage_reduction_buffs[key] = {
		"reduction": reduction,
		"end": combat_time() + duration
	}

func add_move_slow(
	key: String,
	multiplier: float,
	duration: float
) -> void:

	move_slow_effects[key] = {
		"multiplier": multiplier,
		"end": combat_time() + duration
	}

func add_attack_slow(
	key: String,
	multiplier: float,
	duration: float
) -> void:

	attack_slow_effects[key] = {
		"multiplier": multiplier,
		"end": combat_time() + duration
	}

# =========================================================
# CLEAN EXPIRED BUFFS
# =========================================================

func clean_expired_effects() -> void:

	var now: float = combat_time()

	for key in move_speed_buffs.keys():

		if now >= float(
			move_speed_buffs[key]["end"]
		):

			move_speed_buffs.erase(
				key
			)

	for key in attack_speed_buffs.keys():

		if now >= float(
			attack_speed_buffs[key]["end"]
		):

			attack_speed_buffs.erase(
				key
			)

	for key in damage_buffs.keys():

		if now >= float(
			damage_buffs[key]["end"]
		):

			damage_buffs.erase(
				key
			)

	for key in damage_reduction_buffs.keys():

		if now >= float(
			damage_reduction_buffs[key]["end"]
		):

			damage_reduction_buffs.erase(
				key
			)

	for key in move_slow_effects.keys():

		if now >= float(
			move_slow_effects[key]["end"]
		):

			move_slow_effects.erase(
				key
			)

	for key in attack_slow_effects.keys():

		if now >= float(
			attack_slow_effects[key]["end"]
		):

			attack_slow_effects.erase(
				key
			)

# =========================================================
# FACTION SYNERGY
# =========================================================

func apply_faction_synergy() -> void:

	if character_data == null:
		return

	var faction_name: String = (
		character_data.faction
	)

	if faction_name == "":
		return

	faction_synergy_tier = (
		SynergyManager.get_unit_faction_tier(
			team_id,
			faction_name
		)
	)

	match faction_name:

		"Vesper":

			if faction_synergy_tier >= 4:

				attack_cooldown *= 0.90

				debug_log(
					str(name)
					+ " received Hive Mind! Attack Speed +10%."
				)

			elif faction_synergy_tier >= 2:

				attack_cooldown *= 0.95

				debug_log(
					str(name)
					+ " received Hive Bond! Attack Speed +5%."
				)

		"Anttalope":

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

		"Lepidra":

			if faction_synergy_tier >= 4:

				debug_log(
					str(name)
					+ " received Lunar Veil!"
				)

			elif faction_synergy_tier >= 2:

				debug_log(
					str(name)
					+ " received Veil of Dust!"
				)

		"Formicara":

			if faction_synergy_tier >= 4:

				debug_log(
					str(name)
					+ " received United Colony!"
				)

			elif faction_synergy_tier >= 2:

				debug_log(
					str(name)
					+ " received Colony Discipline!"
				)

		"Caraphex":

			if faction_synergy_tier >= 4:

				max_health = int(
					round(
						max_health
						* CARAPHEX_FULL_HEALTH_MULTIPLIER
					)
				)

				debug_log(
					str(name)
					+ " received Last Shell!"
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
					+ " received Reinforced Carapace!"
				)

		"Scolyra":

			if faction_synergy_tier >= 4:

				debug_log(
					str(name)
					+ " received Predatory Frenzy!"
				)

			elif faction_synergy_tier >= 2:

				debug_log(
					str(name)
					+ " received Venomous Assault!"
				)

# =========================================================
# CLASS SYNERGY
# =========================================================

func apply_class_synergy() -> void:

	if character_data == null:
		return

	var role_name: String = (
		character_data.class_role
	)

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

	elif support_synergy_tier >= 2:

		attack_cooldown *= (
			SUPPORT_SMALL_TEAM_ATTACK_SPEED_MULTIPLIER
		)

	if not class_synergy_active:
		return

	match role_name:

		"Vanguard":

			if class_synergy_tier >= 4:

				max_health += (
					VANGUARD_FULL_HEALTH_BONUS
				)

				debug_log(
					str(name)
					+ " received Fortress!"
				)

			else:

				max_health += (
					VANGUARD_SMALL_HEALTH_BONUS
				)

				debug_log(
					str(name)
					+ " received Bulwark!"
				)

		"Fighter":

			if class_synergy_tier >= 4:

				debug_log(
					str(name)
					+ " received War Machine!"
				)

			else:

				debug_log(
					str(name)
					+ " received Battle Momentum!"
				)

		"Assassin":

			if class_synergy_tier >= 4:

				move_speed += (
					ASSASSIN_FULL_MOVE_SPEED_BONUS
				)

			else:

				move_speed += (
					ASSASSIN_SMALL_MOVE_SPEED_BONUS
				)

		"Marksman":

			if class_synergy_tier >= 4:

				debug_log(
					str(name)
					+ " received Deadeye!"
				)

			else:

				debug_log(
					str(name)
					+ " received Steady Aim!"
				)

		"Support":

			if class_synergy_tier >= 4:

				debug_log(
					str(name)
					+ " empowered by Overwhelming Presence!"
				)

			else:

				debug_log(
					str(name)
					+ " empowered by Inspiring Presence!"
				)

# =========================================================
# COMBAT START BASIC ABILITIES
# =========================================================

func activate_combat_start_basic() -> void:

	match get_basic_ability_id():

		"predator_sting":

			var farthest_enemy = (
				find_farthest_enemy()
			)

			if farthest_enemy != null:

				set_target(
					farthest_enemy
				)

				initial_ability_target = (
					farthest_enemy
				)

				add_move_speed_buff(
					"predator_sting",
					20.0,
					999.0
				)

				set_flag(
					"predator_sting_pending_hit"
				)

				debug_log(
					str(name)
					+ " activated Predator Sting!"
				)

		"horn_charge":

			if target != null:

				initial_ability_target = (
					target
				)

				var direction: Vector2 = (
					global_position.direction_to(
						target.global_position
					)
				)

				var charge_distance: float = min(
					120.0,
					global_position.distance_to(
						target.global_position
					)
				)

				global_position += (
					direction
					* charge_distance
				)

				target.take_damage(
					3,
					self,
					false
				)

				target.apply_stagger(
					0.5,
					self
				)

				debug_log(
					str(name)
					+ " activated Horn Charge!"
				)

		"ambush_leap":

			var leap_target = (
				find_backline_enemy(
					2,
					true
				)
			)

			if leap_target != null:

				set_target(
					leap_target
				)

				initial_ability_target = (
					leap_target
				)

				# Syrra now rushes toward the enemy backline instead of
				# teleporting across the battlefield at combat start.
				add_move_speed_buff(
					"ambush_leap_rush",
					30.0,
					999.0
				)

				set_flag(
					"ambush_leap_pending_hit"
				)

				debug_log(
					str(name)
					+ " activated Ambush Leap rush!"
				)

		"heavy_shell":

			receive_shield(
				20,
				8.0
			)

			debug_log(
				str(name)
				+ " activated Heavy Shell!"
			)

		"flashstep":

			var flash_target = (
				find_lowest_health_backline_enemy(
					3
				)
			)

			if flash_target != null:

				set_target(
					flash_target
				)

				initial_ability_target = (
					flash_target
				)

				dash_toward_target(
					flash_target,
					140.0
				)

				set_flag(
					"flashstep_recovery"
				)

				debug_log(
					str(name)
					+ " activated Flashstep!"
				)

# =========================================================
# PHYSICS PROCESS
# =========================================================

func _physics_process(
	delta: float
) -> void:

	if not is_alive:
		return

	clean_expired_effects()

	update_dot_effects(
		delta
	)

	update_synergy_timers(
		delta
	)

	update_support_upgrade_timers(
		delta
	)

	check_team_threshold_abilities()

	check_royal_guard()

	check_droven_territorial_guard()

	check_offensive_threshold_specials()

	check_wing_rush()

	if attack_timer > 0.0:

		attack_timer -= delta

	if combat_time() < stagger_until:

		velocity = Vector2.ZERO
		return

	# =====================================================
	# FORCED TARGET
	# =====================================================

	if (
		forced_target != null
		and combat_time() < forced_target_until
		and is_instance_valid(forced_target)
		and forced_target.is_alive
	):

		set_target(
			forced_target
		)

	elif combat_time() >= forced_target_until:

		forced_target = null

	# =====================================================
	# TARGET VALIDATION
	# =====================================================

	if (
		target == null
		or not is_instance_valid(target)
	):

		set_target(
			find_closest_enemy()
		)

	elif not target.is_alive:

		var dead_target = target

		handle_target_death(
			dead_target
		)

		set_target(
			find_closest_enemy()
		)

	if target == null:

		velocity = Vector2.ZERO
		return

	var current_range: float = (
		get_current_attack_range()
	)

	var movement_stop_range: float = (
		get_movement_stop_range()
	)

	var distance_to_target: float = (
		global_position.distance_to(
			target.global_position
		)
	)

	if distance_to_target > movement_stop_range:

		reset_steady_aim_if_moving()

		entrenched_stationary_timer = 0.0

		var direction: Vector2 = (
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

		entrenched_stationary_timer += (
			delta
		)

		# Recalculate after increasing the stationary timer.
		# Entrenched Position can become active while the unit
		# is holding at its setup distance.
		current_range = (
			get_current_attack_range()
		)

		if (
			distance_to_target <= current_range
			and attack_timer <= 0.0
		):

			attack_target()

# =========================================================
# TARGET SETTER
# =========================================================

func set_target(
	new_target: CharacterBody2D
) -> void:

	if new_target == target:
		return

	var old_target = target

	# Remember the unit we were targeting before the switch.
	# Droven's Territorial Guard uses this to detect an enemy
	# changing away from Droven to one of his allies.
	if (
		old_target != null
		and is_instance_valid(old_target)
	):

		ability_flags["last_target_id"] = (
			old_target.get_instance_id()
		)

	target = new_target

	if old_target != null:

		if (
			is_instance_valid(old_target)
			and not old_target.is_alive
		):

			handle_target_death(
				old_target
			)

	if new_target != null:

		handle_target_changed(
			new_target
		)

# =========================================================
# TARGET CHANGED ABILITIES
# =========================================================

func handle_target_changed(
	new_target: CharacterBody2D
) -> void:

	if new_target == null:
		return

	if get_basic_ability_id() == "weak_point":

		if (
			get_health_percent(
				new_target
			)
			< 0.50
			and ability_ready(
				"weak_point"
			)
		):

			add_move_speed_buff(
				"weak_point",
				20.0,
				2.0
			)

			start_cooldown(
				"weak_point",
				4.0
			)

			debug_log(
				str(name)
				+ " activated Weak Point!"
			)

	if has_effect(
		"shadow_momentum"
	):

		add_attack_speed_buff(
			"shadow_momentum",
			0.88,
			2.5
		)

		debug_log(
			str(name)
			+ " activated Shadow Momentum!"
		)

# =========================================================
# BASIC ATTACK
# =========================================================

func attack_target() -> void:

	if target == null:
		return

	if not is_instance_valid(
		target
	):
		return

	if not target.is_alive:
		return

	var attacked_target = target

	var is_new_target: bool = (
		attacked_target
		!= previous_target
	)

	if is_new_target:

		previous_target = (
			attacked_target
		)

		same_target_attack_count = 0

	same_target_attack_count += 1

	attack_count += 1

	# =====================================================
	# SYRRA - AMBUSH LEAP ARRIVAL
	# =====================================================

	if flag_used(
		"ambush_leap_pending_hit"
	):

		ability_flags.erase(
			"ambush_leap_pending_hit"
		)

		move_speed_buffs.erase(
			"ambush_leap_rush"
		)

		add_attack_speed_buff(
			"ambush_leap",
			0.90,
			2.0
		)

		debug_log(
			str(name)
			+ " reached the Ambush Leap target!"
		)

	var final_damage: int = (
		damage
		+ fighter_momentum_bonus
		+ united_colony_damage_bonus
		+ get_temporary_damage_bonus()
	)

	final_damage = (
		apply_basic_attack_damage(
			final_damage,
			is_new_target
		)
	)

	final_damage = (
		apply_class_upgrade_attack_damage(
			final_damage,
			is_new_target
		)
	)

	final_damage = (
		apply_special_attack_damage(
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

	if (
		attacked_target.marked_for_team
		== team_id
	):

		final_damage += (
			attacked_target.marked_bonus_damage
		)

	# =====================================================
	# VIREX - SHATTERSTRIKE
	# =====================================================
	# Shatterstrike must run before Shellbreaker so the
	# unlocked Special gets first priority on shielded
	# targets. It removes up to 15 shield and adds 30%
	# of the shield removed as bonus damage to this hit.

	final_damage += (
		try_shatterstrike(
			attacked_target
		)
	)

	# =====================================================
	# VIREX - SHELLBREAKER
	# =====================================================

	if (
		get_basic_ability_id()
		== "shellbreaker"
		and attacked_target.current_shield > 0
		and ability_ready(
			"shellbreaker"
		)
	):

		attacked_target.damage_shield_directly(
			6
		)

		start_cooldown(
			"shellbreaker",
			3.0
		)

		debug_log(
			str(name)
			+ " activated Shellbreaker!"
		)

	var target_was_alive: bool = (
		attacked_target.is_alive
	)

	# Log the actual firing distance once whenever this unit
	# begins attacking a new target. This makes range upgrades
	# easy to verify without guessing from the screen.
	if is_new_target:

		debug_log(
			str(name)
			+ " opened fire at "
			+ str(
				round(
					global_position.distance_to(
						attacked_target.global_position
					)
				)
			)
			+ " px (range "
			+ str(
				round(
					get_current_attack_range()
				)
			)
			+ " px)."
		)

	attacked_target.take_damage(
		final_damage,
		self,
		true
	)

	debug_log(
		str(name)
		+ " attacked "
		+ str(attacked_target.name)
		+ " for "
		+ str(final_damage)
		+ " damage"
	)

	after_basic_attack(
		attacked_target,
		is_new_target
	)

	gain_steady_aim_stack()

	if (
		target_was_alive
		and not attacked_target.is_alive
	):

		handle_kill(
			attacked_target
		)

		handle_target_death(
			attacked_target
		)

	# =====================================================
	# NYZARA - FLASHSTEP RECOVERY
	# =====================================================

	attack_timer = (
		get_current_attack_cooldown()
	)

	if flag_used(
		"flashstep_recovery"
	):

		attack_timer *= 0.80

		ability_flags.erase(
			"flashstep_recovery"
		)

# =========================================================
# BASIC ATTACK DAMAGE ABILITIES
# =========================================================

func apply_basic_attack_damage(
	final_damage: int,
	is_new_target: bool
) -> int:

	match get_basic_ability_id():

		"predator_sting":

			if flag_used(
				"predator_sting_pending_hit"
			):

				final_damage += 4

				move_speed_buffs.erase(
					"predator_sting"
				)

				ability_flags.erase(
					"predator_sting_pending_hit"
				)

				debug_log(
					str(name)
					+ " Predator Sting dealt +4 damage!"
				)

		"chain_work":

			if (
				target.last_formicara_damage_team
				== team_id
				and target.last_formicara_attacker_id
				!= get_instance_id()
				and (
					combat_time()
					- target.last_formicara_damage_time
				)
				<= 2.0
				and ability_ready(
					"chain_work"
				)
			):

				final_damage += 3

				start_cooldown(
					"chain_work",
					2.0
				)

				var activation_count: int = (
					add_counter(
						"chain_work_activations"
					)
				)

				debug_log(
					str(name)
					+ " activated Chain Work!"
				)

				if (
					has_effect(
						"swarm_assault"
					)
					and activation_count % 3 == 0
				):

					activate_swarm_assault()

		"coordinated_fire":

			if (
				target.last_damage_team
				== team_id
				and target.last_damage_attacker_id
				!= get_instance_id()
				and (
					combat_time()
					- target.last_damage_time
				)
				<= 1.5
			):

				final_damage += 3

				var activation_count: int = (
					add_counter(
						"coordinated_fire_activations"
					)
				)

				debug_log(
					str(name)
					+ " activated Coordinated Fire!"
				)

				if (
					has_effect(
						"suppression_volley"
					)
					and activation_count % 4 == 0
					and ability_ready(
						"suppression_volley"
					)
				):

					set_flag(
						"suppression_volley_pending"
					)

		"toxic_guard":

			if (
				toxic_guard_target != null
				and target
				== toxic_guard_target
				and combat_time()
				<= float(
					ability_flags.get(
						"toxic_guard_expires",
						0.0
					)
				)
			):

				final_damage += 2

	return final_damage

# =========================================================
# CLASS UPGRADE ATTACK DAMAGE
# =========================================================

func apply_class_upgrade_attack_damage(
	final_damage: int,
	_is_new_target: bool
) -> int:

	# =====================================================
	# VANGUARD - RETALIATION PROTOCOL
	# =====================================================

	if (
		has_effect(
			"retaliation_protocol"
		)
		and flag_used(
			"retaliation_ready"
		)
	):

		final_damage += 5

		ability_flags.erase(
			"retaliation_ready"
		)

		if target != null:

			target.force_target(
				self,
				1.5
			)

		debug_log(
			str(name)
			+ " activated Retaliation Protocol!"
		)

	# =====================================================
	# FIGHTER - COMBO BREAKER
	# =====================================================

	if (
		has_effect(
			"combo_breaker"
		)
		and same_target_attack_count % 4 == 0
	):

		final_damage += 6

		debug_log(
			str(name)
			+ " activated Combo Breaker!"
		)

	# =====================================================
	# FIGHTER - BATTLE PURSUIT
	# =====================================================

	if flag_used(
		"battle_pursuit_bonus_hit"
	):

		final_damage += 3

		ability_flags.erase(
			"battle_pursuit_bonus_hit"
		)

	# =====================================================
	# MARKSMAN - LONGSHOT CALIBRATION
	# =====================================================

	if (
		has_effect(
			"longshot_calibration"
		)
		and target != null
		and global_position.distance_to(
			target.global_position
		)
		>= 180.0
	):

		final_damage += 3

	return final_damage

# =========================================================
# SPECIAL ATTACK DAMAGE
# =========================================================

func apply_special_attack_damage(
	final_damage: int,
	_is_new_target: bool
) -> int:

	# =====================================================
	# ZEKRIN - PREDATOR'S DIVE
	# =====================================================

	if flag_used(
		"predators_dive_bonus"
	):

		final_damage += 8

		ability_flags.erase(
			"predators_dive_bonus"
		)

	# =====================================================
	# VEXIRA - COLONY EXECUTION
	# =====================================================

	if (
		has_effect(
			"colony_execution"
		)
		and target != null
		and get_health_percent(
			target
		)
		< 0.25
		and ability_ready(
			"colony_execution"
		)
	):

		final_damage += 8

		start_cooldown(
			"colony_execution",
			5.0
		)

		set_flag(
			"colony_execution_active"
		)

	# =====================================================
	# SOLVYR - MOONSHOT
	# =====================================================

	if flag_used(
		"moonshot_ready"
	):

		final_damage = int(
			round(
				final_damage
				* 1.50
			)
		)

		ability_flags.erase(
			"moonshot_ready"
		)

		start_cooldown(
			"moonshot",
			6.0
		)

		debug_log(
			str(name)
			+ " fired Moonshot!"
		)

	# =====================================================
	# IGNIVAR - SIEGE CANNON
	# =====================================================

	if (
		has_effect(
			"siege_cannon"
		)
		and attack_count % 10 == 0
	):

		final_damage = int(
			round(
				final_damage
				* 1.40
			)
		)

	return final_damage

# =========================================================
# AFTER BASIC ATTACK
# =========================================================

func after_basic_attack(
	attacked_target: CharacterBody2D,
	is_new_target: bool
) -> void:

	if attacked_target == null:
		return

	activate_basic_after_attack(
		attacked_target,
		is_new_target
	)

	activate_class_after_attack(
		attacked_target,
		is_new_target
	)

	activate_special_after_attack(
		attacked_target,
		is_new_target
	)

	check_moonshot_progress()

# =========================================================
# BASIC AFTER ATTACK EFFECTS
# =========================================================

func activate_basic_after_attack(
	attacked_target: CharacterBody2D,
	is_new_target: bool
) -> void:

	match get_basic_ability_id():

		"royal_nectar":

			if attack_count % 5 == 0:

				var ally = (
					find_lowest_health_ally()
				)

				if ally != null:

					var heal_amount: int = (
						scale_support_amount(
							7
						)
					)

					ally.heal(
						heal_amount
					)

					debug_log(
						str(name)
						+ " activated Royal Nectar on "
						+ str(ally.name)
						+ " for "
						+ str(heal_amount)
						+ " HP!"
					)

		"needle_line":

			if attack_count % 4 == 0:

				var secondary = (
					find_enemy_behind_target(
						attacked_target,
						110.0
					)
				)

				if secondary != null:

					var secondary_damage: int = max(
						1,
						int(
							round(
								damage
								* 0.40
							)
						)
					)

					secondary.take_damage(
						secondary_damage,
						self,
						true
					)

					debug_log(
						str(name)
						+ " activated Needle Line!"
					)

		"acid_shot":

			if attack_count % 5 == 0:

				apply_corrosion(
					attacked_target
				)

				var acid_count: int = (
					add_counter(
						"acid_shot_activations"
					)
				)

				if (
					has_effect(
						"corrosive_volley"
					)
					and acid_count % 2 == 0
				):

					activate_corrosive_volley(
						attacked_target
					)

		"marked_prey":

			if not flag_used(
				"marked_prey_used"
			):

				set_flag(
					"marked_prey_used"
				)

				marked_prey_target = (
					attacked_target
				)

				attacked_target.receive_mark(
					team_id,
					1,
					5.0
				)

				debug_log(
					str(name)
					+ " activated Marked Prey!"
				)

		"shadow_slip":

			if (
				is_new_target
				and ability_ready(
					"shadow_slip"
				)
			):

				blink_behind_target(
					attacked_target,
					45.0
				)

				add_move_speed_buff(
					"shadow_slip",
					15.0,
					1.5
				)

				start_cooldown(
					"shadow_slip",
					5.0
				)

				var slip_count: int = (
					add_counter(
						"shadow_slip_activations"
					)
				)

				debug_log(
					str(name)
					+ " activated Shadow Slip!"
				)

				if (
					has_effect(
						"eclipse_dance"
					)
					and slip_count >= 3
					and not flag_used(
						"eclipse_dance_used"
					)
				):

					activate_eclipse_dance(
						attacked_target
					)

		"wingstep":

			if same_target_attack_count % 3 == 0:

				perform_sidestep(
					attacked_target,
					40.0
				)

				add_move_speed_buff(
					"wingstep",
					15.0,
					2.0
				)

				var wingstep_count: int = (
					add_counter(
						"wingstep_activations"
					)
				)

				debug_log(
					str(name)
					+ " activated Wingstep!"
				)

				if (
					has_effect(
						"phantom_assault"
					)
					and wingstep_count % 2 == 0
					and ability_ready(
						"phantom_assault"
					)
				):

					activate_phantom_assault(
						attacked_target
					)

		"groundbreaker":

			if attack_count % 4 == 0:

				attacked_target.add_move_slow(
					"groundbreaker_"
					+ str(
						get_instance_id()
					),
					0.75,
					2.0
				)

				var groundbreaker_count: int = (
					add_counter(
						"groundbreaker_activations"
					)
				)

				debug_log(
					str(name)
					+ " activated Groundbreaker!"
				)

				if (
					has_effect(
						"seismic_breaker"
					)
					and groundbreaker_count % 2 == 0
					and ability_ready(
						"seismic_breaker"
					)
				):

					activate_seismic_breaker(
						attacked_target
					)

		"heavy_bolt":

			if attack_count % 5 == 0:

				if (
					has_effect(
						"siege_cannon"
					)
					and attack_count % 10 == 0
				):

					activate_siege_cannon(
						attacked_target
					)

				else:

					var push_distance: float = 55.0

					if (
						attacked_target.character_data
						!= null
						and attacked_target.character_data.class_role
						== "Vanguard"
					):

						push_distance = 30.0

					attacked_target.apply_knockback(
						self,
						push_distance
					)

					debug_log(
						str(name)
						+ " activated Heavy Bolt!"
					)

		"colony_signal":

			if attack_count % 5 == 0:

				var ally = (
					find_lowest_health_ally()
				)

				if ally != null:

					ally.add_move_speed_buff(
						"colony_signal_"
						+ str(
							get_instance_id()
						),
						20.0,
						2.5
					)

					ally.add_damage_reduction_buff(
						"colony_signal_"
						+ str(
							get_instance_id()
						),
						0.10,
						2.5
					)

					debug_log(
						str(name)
						+ " activated Colony Signal on "
						+ str(ally.name)
						+ "!"
					)

		"shell_mend":

			if attack_count % 5 == 0:

				var ally = (
					find_lowest_health_ally()
				)

				if ally != null:

					ally.receive_shield(
						scale_support_amount(
							10
						),
						5.0
					)

					debug_log(
						str(name)
						+ " activated Shell Mend!"
					)

		"blood_rush":

			# Blood Rush activates when Scyrix reaches three
			# consecutive attacks on the same target. Further
			# attacks on that target refresh the 3-second buff
			# without counting as brand-new activations. Switching
			# targets resets same_target_attack_count, so reaching
			# three hits on a new target becomes the next activation.
			if same_target_attack_count >= 3:

				add_attack_speed_buff(
					"blood_rush",
					0.88,
					3.0
				)

				if same_target_attack_count == 3:

					var activations: int = (
						add_counter(
							"blood_rush_activations"
						)
					)

					debug_log(
						str(name)
						+ " activated Blood Rush!"
					)

					if (
						has_effect(
							"blood_frenzy"
						)
						and activations >= 2
						and not flag_used(
							"blood_frenzy_used"
						)
					):

						set_flag(
							"blood_frenzy_used"
						)

						add_attack_speed_buff(
							"blood_frenzy",
							0.80,
							4.0
						)

						add_damage_buff(
							"blood_frenzy",
							3,
							4.0
						)

						debug_log(
							str(name)
							+ " activated Blood Frenzy!"
						)

		"venom_shot":

			if attack_count % 4 == 0:

				attacked_target.apply_dot(
					"venom_shot_"
					+ str(
						get_instance_id()
					),
					2,
					2,
					1.0
				)

				var venom_shot_count: int = (
					add_counter(
						"venom_shot_activations"
					)
				)

				debug_log(
					str(name)
					+ " activated Venom Shot!"
				)

				if (
					has_effect(
						"toxic_barrage"
					)
					and venom_shot_count % 3 == 0
				):

					activate_toxic_barrage(
						attacked_target
					)

		"adrenal_venom":

			if attack_count % 5 == 0:

				var ally = (
					find_lowest_health_ally()
				)

				if ally != null:

					ally.add_attack_speed_buff(
						"adrenal_venom_"
						+ str(
							get_instance_id()
						),
						0.85,
						3.0
					)

					debug_log(
						str(name)
						+ " activated Adrenal Venom!"
					)

# =========================================================
# CLASS AFTER ATTACK EFFECTS
# =========================================================

func activate_class_after_attack(
	attacked_target: CharacterBody2D,
	is_new_target: bool
) -> void:

	# =====================================================
	# VANGUARD - SHIELD BASH
	# =====================================================

	if (
		has_effect(
			"shield_bash"
		)
		and attack_count % 5 == 0
	):

		var bash_key: String = (
			"shield_bash_from_"
			+ str(
				get_instance_id()
			)
		)

		if attacked_target.ability_ready(
			bash_key
		):

			attacked_target.apply_stagger(
				0.5,
				self
			)

			attacked_target.start_cooldown(
				bash_key,
				4.0
			)

			debug_log(
				str(name)
				+ " activated Shield Bash!"
			)

	# =====================================================
	# FIGHTER - SWEEPING STRIKE
	# =====================================================

	if (
		has_effect(
			"sweeping_strike"
		)
		and attack_count % 5 == 0
	):

		var secondary = (
			find_nearest_other_enemy(
				attacked_target,
				70.0
			)
		)

		if secondary != null:

			var sweep_damage: int = max(
				1,
				int(
					round(
						damage
						* 0.40
					)
				)
			)

			secondary.take_damage(
				sweep_damage,
				self,
				true
			)

			debug_log(
				str(name)
				+ " activated Sweeping Strike!"
			)

	# =====================================================
	# ASSASSIN - SERRATED EDGE
	# =====================================================

	if (
		has_effect(
			"serrated_edge"
		)
		and is_new_target
	):

		attacked_target.apply_dot(
			"serrated_edge_"
			+ str(
				get_instance_id()
			),
			2,
			2,
			1.0
		)

	# =====================================================
	# MARKSMAN - RICOCHET ROUND
	# =====================================================

	if (
		has_effect(
			"ricochet_round"
		)
		and attack_count % 4 == 0
	):

		var bounce_target = (
			find_nearest_other_enemy(
				attacked_target,
				100.0
			)
		)

		if bounce_target != null:

			var ricochet_damage: int = max(
				1,
				int(
					round(
						damage
						* 0.35
					)
				)
			)

			bounce_target.take_damage(
				ricochet_damage,
				self,
				true
			)

	# =====================================================
	# MARKSMAN - SUPPRESSING FIRE
	# =====================================================

	if (
		has_effect(
			"suppressing_fire"
		)
		and same_target_attack_count >= 4
	):

		attacked_target.add_attack_slow(
			"suppressing_fire_"
			+ str(
				get_instance_id()
			),
			1.10,
			3.0
		)

	# =====================================================
	# SUPPORT - RALLY PULSE
	# =====================================================

	if (
		has_effect(
			"rally_pulse"
		)
		and attack_count % 6 == 0
	):

		add_attack_speed_buff(
			"rally_pulse_self",
			0.90,
			3.0
		)

		var ally = (
			find_nearest_ally()
		)

		if ally != null:

			ally.add_attack_speed_buff(
				"rally_pulse_"
				+ str(
					get_instance_id()
				),
				0.90,
				3.0
			)

# =========================================================
# SPECIAL AFTER ATTACK EFFECTS
# =========================================================

func activate_special_after_attack(
	attacked_target: CharacterBody2D,
	_is_new_target: bool
) -> void:

	# =====================================================
	# AUREX - GOLDEN BARRAGE
	# =====================================================

	if (
		has_effect(
			"golden_barrage"
		)
		and attack_count % 8 == 0
	):

		var secondary = (
			find_enemy_behind_target(
				attacked_target,
				130.0
			)
		)

		if secondary != null:

			secondary.take_damage(
				max(
					1,
					int(
						round(
							damage
							* 0.70
						)
					)
				),
				self,
				true
			)

			var third = (
				find_enemy_behind_target(
					secondary,
					130.0
				)
			)

			if (
				third != null
				and third != attacked_target
			):

				third.take_damage(
					max(
						1,
						int(
							round(
								damage
								* 0.45
							)
						)
					),
					self,
					true
				)

		debug_log(
			str(name)
			+ " activated Golden Barrage!"
		)

	# =====================================================
	# MELORA - ROYAL BLOOM
	# =====================================================

	if (
		has_effect(
			"royal_bloom"
		)
		and attack_count % 10 == 0
		and ability_ready(
			"royal_bloom"
		)
	):

		start_cooldown(
			"royal_bloom",
			8.0
		)

		var lowest_ally = (
			find_lowest_health_ally()
		)

		for ally in get_living_allies():

			ally.heal(
				scale_support_amount(
					8
				)
			)

		if lowest_ally != null:

			lowest_ally.heal(
				scale_support_amount(
					8
				)
			)

		debug_log(
			str(name)
			+ " activated Royal Bloom!"
		)

	# =====================================================
	# TARSIK - SUPPRESSION VOLLEY
	# =====================================================

	if flag_used(
		"suppression_volley_pending"
	):

		ability_flags.erase(
			"suppression_volley_pending"
		)

		start_cooldown(
			"suppression_volley",
			7.0
		)

		var secondary_targets = (
			find_nearest_enemies_to_target(
				attacked_target,
				2
			)
		)

		for secondary in secondary_targets:

			if secondary == attacked_target:
				continue

			secondary.take_damage(
				max(
					1,
					int(
						round(
							damage
							* 0.70
						)
					)
				),
				self,
				true
			)

		debug_log(
			str(name)
			+ " activated Suppression Volley!"
		)

# =========================================================
# CLASS SYNERGY ATTACK EFFECTS
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

			var bonus: int = (
				ASSASSIN_SMALL_NEW_TARGET_DAMAGE_BONUS
			)

			if class_synergy_tier >= 4:

				bonus = (
					ASSASSIN_FULL_NEW_TARGET_DAMAGE_BONUS
				)

			final_damage += bonus

		if (
			class_synergy_tier >= 4
			and target != null
			and get_health_percent(
				target
			)
			<= ASSASSIN_EXECUTION_HEALTH_THRESHOLD
		):

			final_damage = int(
				round(
					final_damage
					* ASSASSIN_EXECUTION_DAMAGE_MULTIPLIER
				)
			)

	# =====================================================
	# MARKSMAN
	# =====================================================

	if (
		character_data.class_role
		== "Marksman"
		and class_synergy_tier >= 4
		and steady_aim_stacks
		>= STEADY_AIM_MAX_STACKS
	):

		final_damage = int(
			round(
				final_damage
				* DEADEYE_DAMAGE_MULTIPLIER
			)
		)

	return final_damage

# =========================================================
# FACTION ATTACK EFFECTS
# =========================================================

func apply_faction_attack_synergy(
	final_damage: int,
	is_new_target: bool
) -> int:

	if character_data == null:
		return final_damage

	match character_data.faction:

		"Anttalope":

			if faction_synergy_tier >= 4:

				if is_new_target:

					final_damage += 4

				elif same_target_attack_count >= 2:

					final_damage += 4

			elif faction_synergy_tier >= 2:

				if same_target_attack_count >= 2:

					final_damage += 2

		"Scolyra":

			if faction_synergy_tier >= 2:

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

				final_damage += (
					venom_stacks
					* damage_per_stack
				)

	return final_damage

# =========================================================
# TARGET DEATH EFFECTS
# =========================================================

func handle_target_death(
	dead_target: CharacterBody2D
) -> void:

	if dead_target == null:
		return

	# =====================================================
	# KAELOR - STAMPEDE
	# =====================================================

	# Stampede triggers once when Kaelor's original Horn Charge
	# target is defeated. He immediately charges toward the next
	# closest living enemy, damaging and staggering enemies crossed.
	if (
		has_effect(
			"stampede"
		)
		and dead_target == initial_ability_target
		and not flag_used(
			"stampede_used"
		)
	):

		var stampede_target = (
			find_closest_enemy()
		)

		if stampede_target != null:

			set_flag(
				"stampede_used"
			)

			var charge_start: Vector2 = (
				global_position
			)

			var charge_direction: Vector2 = (
				global_position.direction_to(
					stampede_target.global_position
				)
			)

			var charge_distance: float = min(
				160.0,
				global_position.distance_to(
					stampede_target.global_position
				)
			)

			var charge_end: Vector2 = (
				charge_start
				+ charge_direction
				* charge_distance
			)

			global_position = charge_end

			for enemy in get_living_enemies():

				if not is_instance_valid(
					enemy
				):
					continue

				if (
					distance_to_line_segment(
						enemy.global_position,
						charge_start,
						charge_end
					)
					> 35.0
				):
					continue

				enemy.take_damage(
					6,
					self,
					true
				)

				enemy.apply_stagger(
					0.4,
					self
				)

			debug_log(
				str(name)
				+ " activated Stampede!"
			)

	# =====================================================
	# FIGHTER - BATTLE PURSUIT
	# =====================================================

	if has_effect(
		"battle_pursuit"
	):

		add_move_speed_buff(
			"battle_pursuit",
			25.0,
			2.5
		)

		set_flag(
			"battle_pursuit_bonus_hit"
		)

	# =====================================================
	# ASSASSIN - QUICK EXIT
	# =====================================================

	if has_effect(
		"quick_exit"
	):

		var new_target = (
			find_lowest_health_enemy()
		)

		if new_target != null:

			set_target(
				new_target
			)

		add_move_speed_buff(
			"quick_exit",
			30.0,
			2.0
		)

	# =====================================================
	# NYZARA - VENOM FLASH
	# =====================================================

	if (
		has_effect(
			"venom_flash"
		)
		and not flag_used(
			"venom_flash_used"
		)
	):

		set_flag(
			"venom_flash_used"
		)

		var new_target = (
			find_lowest_health_enemy()
		)

		if new_target != null:

			dash_toward_target(
				new_target,
				180.0
			)

			var flash_damage: int = max(
				1,
				int(
					round(
						damage
						* 0.80
					)
				)
			)

			new_target.take_damage(
				flash_damage,
				self,
				true
			)

			set_target(
				new_target
			)

			debug_log(
				str(name)
				+ " activated Venom Flash!"
			)

	# =====================================================
	# VELKARA - GRAND HUNT
	# =====================================================

	if (
		has_effect(
			"grand_hunt"
		)
		and dead_target
		== marked_prey_target
		and not flag_used(
			"grand_hunt_used"
		)
	):

		set_flag(
			"grand_hunt_used"
		)

		var hunt_target = (
			find_lowest_health_enemy()
		)

		if hunt_target != null:

			marked_prey_target = (
				hunt_target
			)

			hunt_target.receive_mark(
				team_id,
				2,
				5.0
			)

			debug_log(
				str(name)
				+ " activated Grand Hunt!"
			)

# =========================================================
# KILL EFFECTS
# =========================================================

func handle_kill(
	defeated_target: CharacterBody2D
) -> void:

	if defeated_target == null:
		return

	if (
		has_effect(
			"colony_execution"
		)
		and flag_used(
			"colony_execution_active"
		)
	):

		ability_flags.erase(
			"colony_execution_active"
		)

		add_move_speed_buff(
			"colony_execution",
			25.0,
			3.0
		)

		var wounded = (
			find_lowest_health_enemy()
		)

		if wounded != null:

			set_target(
				wounded
			)

# =========================================================
# SELF / TEAM THRESHOLD SPECIALS
# =========================================================

func check_team_threshold_abilities() -> void:

	if character_data == null:
		return

	# =====================================================
	# SUPPORT CLASS - EMERGENCY AID
	# =====================================================

	if (
		has_effect(
			"emergency_aid"
		)
		and not flag_used(
			"emergency_aid_used"
		)
	):

		var ally = (
			find_ally_below_health(
				0.30
			)
		)

		if ally != null:

			set_flag(
				"emergency_aid_used"
			)

			ally.heal(
				scale_support_amount(
					8
				)
			)

			debug_log(
				str(name)
				+ " activated Emergency Aid!"
			)

	# =====================================================
	# LUNARA - LUNAR SANCTUARY
	# =====================================================

	if (
		has_effect(
			"lunar_sanctuary"
		)
		and not flag_used(
			"lunar_sanctuary_used"
		)
	):

		var ally = (
			find_ally_below_health(
				0.30
			)
		)

		if ally != null:

			set_flag(
				"lunar_sanctuary_used"
			)

			ally.add_damage_reduction_buff(
				"lunar_sanctuary_"
				+ str(
					get_instance_id()
				),
				0.40,
				3.0
			)

			ally.heal(
				scale_support_amount(
					6
				)
			)

			debug_log(
				str(name)
				+ " activated Lunar Sanctuary!"
			)

	# =====================================================
	# MYRAXA - COLONY COMMAND
	# =====================================================

	if (
		has_effect(
			"colony_command"
		)
		and not flag_used(
			"colony_command_used"
		)
	):

		var endangered = (
			find_ally_below_health(
				0.35
			)
		)

		if endangered != null:

			set_flag(
				"colony_command_used"
			)

			for ally in get_living_allies():

				var speed_bonus: float = 15.0

				if ally == endangered:

					speed_bonus = 20.0

				ally.add_move_speed_buff(
					"colony_command_"
						+ str(
							get_instance_id()
						),
					speed_bonus,
					3.0
				)

				ally.add_damage_reduction_buff(
					"colony_command_"
						+ str(
							get_instance_id()
						),
					0.10,
					3.0
				)

			debug_log(
				str(name)
				+ " activated Colony Command!"
			)

	# =====================================================
	# AURELIA - CITADEL SHELL
	# =====================================================

	if (
		has_effect(
			"citadel_shell"
		)
		and not flag_used(
			"citadel_shell_used"
		)
	):

		var injured_count: int = 0

		for ally in get_living_allies():

			if get_health_percent(
				ally
			) < 0.50:

				injured_count += 1

		if injured_count >= 2:

			set_flag(
				"citadel_shell_used"
			)

			var lowest = (
				find_lowest_health_ally()
			)

			for ally in get_living_allies():

				var amount: int = 8

				if ally == lowest:

					amount = 18

				ally.receive_shield(
					scale_support_amount(
						amount
					),
					5.0
				)

			debug_log(
				str(name)
				+ " activated Citadel Shell!"
			)

	# =====================================================
	# THESIRA - FRENZY INJECTION
	# =====================================================

	if (
		has_effect(
			"frenzy_injection"
		)
		and not flag_used(
			"frenzy_injection_used"
		)
	):

		var endangered = (
			find_ally_below_health(
				0.35
			)
		)

		if endangered != null:

			set_flag(
				"frenzy_injection_used"
			)

			for ally in get_living_allies():

				var multiplier: float = 0.85

				if ally == endangered:

					multiplier = 0.80

				ally.add_attack_speed_buff(
					"frenzy_injection_"
						+ str(
							get_instance_id()
						),
					multiplier,
					4.0
				)

			debug_log(
				str(name)
				+ " activated Frenzy Injection!"
			)

# =========================================================
# OFFENSIVE THRESHOLD SPECIALS
# =========================================================

func check_offensive_threshold_specials() -> void:

	if target == null:
		return

	if not is_instance_valid(
		target
	):
		return

	# =====================================================
	# ZEKRIN - PREDATOR'S DIVE
	# =====================================================

	if (
		has_effect(
			"predators_dive"
		)
		and not flag_used(
			"predators_dive_used"
		)
		and get_health_percent(
			target
		) < 0.50
	):

		set_flag(
			"predators_dive_used"
		)

		blink_behind_target(
			target,
			45.0
		)

		set_flag(
			"predators_dive_bonus"
		)

		add_attack_speed_buff(
			"predators_dive",
			0.80,
			3.0
		)

		debug_log(
			str(name)
			+ " activated Predator's Dive!"
		)

	# =====================================================
	# SYRRA - APEX POUNCE
	# =====================================================

	if (
		has_effect(
			"apex_pounce"
		)
		and not flag_used(
			"apex_pounce_used"
		)
		and initial_ability_target != null
		and is_instance_valid(
			initial_ability_target
		)
		and initial_ability_target.is_alive
		and get_health_percent(
			initial_ability_target
		) <= 0.50
	):

		set_flag(
			"apex_pounce_used"
		)

		set_target(
			initial_ability_target
		)

		untargetable_until = (
			combat_time()
			+ 0.5
		)

		blink_behind_target(
			initial_ability_target,
			45.0
		)

		initial_ability_target.take_damage(
			7,
			self,
			false
		)

		debug_log(
			str(name)
			+ " activated Apex Pounce!"
		)

# =========================================================
# ROYAL GUARD
# =========================================================

func check_royal_guard() -> void:

	if get_basic_ability_id() != "royal_guard":
		return

	if flag_used(
		"royal_guard_used"
	):
		return

	for enemy in get_living_enemies():

		if enemy.target == null:
			continue

		if not is_instance_valid(
			enemy.target
		):
			continue

		if enemy.target.team_id != team_id:
			continue

		if not is_backline_unit(
			enemy.target,
			2
		):
			continue

		if global_position.distance_to(
			enemy.global_position
		) > 220.0:
			continue

		set_flag(
			"royal_guard_used"
		)

		set_target(
			enemy
		)

		receive_shield(
			15,
			4.0
		)

		debug_log(
			str(name)
			+ " activated Royal Guard!"
		)

		return

# =========================================================
# DROVEN - TERRITORIAL GUARD
# =========================================================

func check_droven_territorial_guard() -> void:

	if get_basic_ability_id() != "territorial_guard":
		return

	if not ability_ready(
		"territorial_guard"
	):
		return

	for enemy in get_living_enemies():

		if enemy.target == null:
			continue

		if not is_instance_valid(
			enemy.target
		):
			continue

		# Droven can only intervene against nearby enemies.
		if global_position.distance_to(
			enemy.global_position
		) > 100.0:
			continue

		# Ignore enemies that are already attacking Droven.
		if enemy.target == self:
			continue

		# The nearby enemy must currently be attacking
		# one of Droven's living allies.
		if enemy.target.team_id != team_id:
			continue

		if not enemy.target.is_alive:
			continue

		enemy.force_target(
			self,
			2.0
		)

		start_cooldown(
			"territorial_guard",
			6.0
		)

		debug_log(
			str(name)
			+ " activated Territorial Guard on "
			+ str(enemy.name)
			+ "!"
		)

		return

# =========================================================
# UPDATE SYNERGY TIMERS
# =========================================================

func update_synergy_timers(
	delta: float
) -> void:

	# =====================================================
	# HIVE MIND
	# =====================================================

	if (
		character_data != null
		and character_data.faction == "Vesper"
		and faction_synergy_tier >= 4
	):

		hive_mind_heal_timer -= delta

		if hive_mind_heal_timer <= 0.0:

			hive_mind_heal_timer = (
				HIVE_MIND_HEAL_INTERVAL
			)

			if current_health < max_health:

				heal(
					HIVE_MIND_HEAL_AMOUNT
				)

	# =====================================================
	# FIGHTER MOMENTUM
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

			if fighter_momentum_timer <= 0.0:

				fighter_momentum_timer = (
					FIGHTER_MOMENTUM_INTERVAL
				)

				fighter_momentum_bonus = min(
					momentum_max,
					fighter_momentum_bonus
					+ momentum_per_stack
				)

				debug_log(
					"Fighter momentum! "
					+ str(name)
					+ " now has +"
					+ str(fighter_momentum_bonus)
					+ " damage."
				)

	# =====================================================
	# SUPPORT 4 SHIELD
	# =====================================================

	if (
		character_data != null
		and character_data.class_role == "Support"
		and class_synergy_tier >= 4
	):

		support_full_shield_timer -= delta

		if support_full_shield_timer <= 0.0:

			support_full_shield_timer = (
				SUPPORT_FULL_SHIELD_INTERVAL
			)

			# Overwhelming Presence is a TEAM synergy.
			# Only one living Support acts as the shield controller
			# so four Supports do not create four shields at once.
			if is_support_full_shield_controller():

				var ally = (
					find_lowest_health_ally()
				)

				if ally != null:

					ally.receive_shield(
						SUPPORT_FULL_SHIELD_AMOUNT,
						SUPPORT_FULL_SHIELD_DURATION
					)

					debug_log(
						"Overwhelming Presence shielded "
						+ str(ally.name)
						+ " for "
						+ str(SUPPORT_FULL_SHIELD_AMOUNT)
						+ " shield."
					)

# =========================================================
# SUPPORT 4 SHIELD CONTROLLER
# =========================================================

func is_support_full_shield_controller() -> bool:

	if (
		character_data == null
		or character_data.class_role != "Support"
		or class_synergy_tier < 4
	):

		return false

	var controller_id: int = (
		get_instance_id()
	)

	for ally in get_living_allies():

		if ally.character_data == null:
			continue

		if ally.character_data.class_role != "Support":
			continue

		if ally.class_synergy_tier < 4:
			continue

		controller_id = min(
			controller_id,
			ally.get_instance_id()
		)

	return (
		get_instance_id()
		== controller_id
	)

# =========================================================
# SUPPORT CLASS UPGRADE TIMERS
# =========================================================

func update_support_upgrade_timers(
	_delta: float
) -> void:

	if character_data == null:
		return

	if character_data.class_role != "Support":
		return

	# =====================================================
	# PROTECTIVE FIELD
	# =====================================================

	if has_effect(
		"protective_field"
	):

		if ability_ready(
			"protective_field"
		):

			var ally = (
				find_lowest_health_ally()
			)

			if ally != null:

				ally.receive_shield(
					scale_support_amount(
						8
					),
					4.0
				)

			start_cooldown(
				"protective_field",
				7.0
			)

	# =====================================================
	# PURIFYING PULSE
	# =====================================================

	if has_effect(
		"purifying_pulse"
	):

		if ability_ready(
			"purifying_pulse"
		):

			var affected = (
				find_lowest_health_debuffed_ally()
			)

			if affected != null:

				affected.remove_one_debuff()

				affected.add_move_speed_buff(
					"purifying_pulse_"
						+ str(
							get_instance_id()
						),
					15.0,
					2.0
				)

				start_cooldown(
					"purifying_pulse",
					8.0
				)

				debug_log(
					str(name)
					+ " activated Purifying Pulse!"
				)

			else:

				start_cooldown(
					"purifying_pulse",
					2.0
				)

# =========================================================
# DAMAGE OVER TIME
# =========================================================

func apply_dot(
	key: String,
	tick_damage: int,
	ticks: int,
	interval: float
) -> void:

	active_dots[key] = {
		"damage": tick_damage,
		"ticks": ticks,
		"timer": interval,
		"interval": interval
	}

func update_dot_effects(
	delta: float
) -> void:

	var keys_to_remove: Array = []

	for key in active_dots.keys():

		var dot: Dictionary = (
			active_dots[key]
		)

		dot["timer"] = (
			float(
				dot["timer"]
			)
			- delta
		)

		if float(
			dot["timer"]
		) <= 0.0:

			var dot_damage: int = (
				int(
					dot["damage"]
				)
			)

			take_damage(
				dot_damage,
				null,
				false
			)

			dot["ticks"] = (
				int(
					dot["ticks"]
				)
				- 1
			)

			dot["timer"] = (
				float(
					dot["interval"]
				)
			)

			if int(
				dot["ticks"]
			) <= 0:

				keys_to_remove.append(
					key
				)

		active_dots[key] = (
			dot
		)

	for key in keys_to_remove:

		active_dots.erase(
			key
		)

# =========================================================
# CORROSION
# =========================================================

func apply_corrosion(
	corrosion_target: CharacterBody2D
) -> void:

	if corrosion_target == null:
		return

	corrosion_target.corrosion_team = (
		team_id
	)

	corrosion_target.corrosion_bonus_damage = 4

	corrosion_target.corrosion_timer = 4.0

	debug_log(
		str(name)
		+ " activated Acid Shot!"
	)

func activate_corrosive_volley(
	main_target: CharacterBody2D
) -> void:

	apply_corrosion(
		main_target
	)

	var extras = (
		find_nearest_enemies_to_target(
			main_target,
			2
		)
	)

	for enemy in extras:

		if enemy == main_target:
			continue

		apply_corrosion(
			enemy
		)

	debug_log(
		str(name)
		+ " activated Corrosive Volley!"
	)

# =========================================================
# TAKE DAMAGE
# =========================================================

func take_damage(
	amount: int,
	attacker: CharacterBody2D = null,
	is_basic_attack: bool = false
) -> void:

	if not is_alive:
		return

	var final_damage: int = amount

	# =====================================================
	# MOON VEIL
	# =====================================================

	final_damage = (
		apply_moon_veil_reduction(
			final_damage
		)
	)

	# =====================================================
	# GUARDIAN'S REACH
	# =====================================================

	if is_basic_attack:

		if has_guardians_reach_protection():

			final_damage = int(
				round(
					final_damage
					* 0.90
				)
			)

	# =====================================================
	# VANGUARD SYNERGY
	# =====================================================

	if (
		character_data != null
		and character_data.class_role == "Vanguard"
		and class_synergy_active
	):

		var reduction: int = (
			VANGUARD_SMALL_DAMAGE_REDUCTION
		)

		if class_synergy_tier >= 4:

			reduction = (
				VANGUARD_FULL_DAMAGE_REDUCTION
			)

		final_damage -= reduction

	# =====================================================
	# LEPIDRA SYNERGY
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

			add_move_speed_buff(
				"lunar_veil",
				LUNAR_VEIL_SPEED_BONUS,
				LUNAR_VEIL_SPEED_DURATION
			)

		else:

			final_damage = int(
				round(
					final_damage
					* LEPIDRA_SMALL_DAMAGE_MULTIPLIER
				)
			)

		lepidra_protected_hits_remaining -= 1

	# =====================================================
	# FORMICARA SYNERGY
	# =====================================================

	if (
		character_data != null
		and character_data.faction == "Formicara"
		and faction_synergy_tier >= 2
	):

		var reduction: int = (
			FORMICARA_SMALL_DAMAGE_REDUCTION
		)

		if faction_synergy_tier >= 4:

			reduction = (
				FORMICARA_FULL_DAMAGE_REDUCTION
			)

		final_damage -= reduction

	# =====================================================
	# ASSASSIN - EVASIVE STEP
	# =====================================================

	if (
		has_effect(
			"evasive_step"
		)
		and get_health_percent(
			self
		) < 0.40
		and ability_ready(
			"evasive_step"
		)
	):

		final_damage = int(
			round(
				final_damage
				* 0.60
			)
		)

		start_cooldown(
			"evasive_step",
			7.0
		)

		if attacker != null:

			dash_away_from(
				attacker,
				60.0
			)

		debug_log(
			str(name)
			+ " activated Evasive Step!"
		)

	# =====================================================
	# TEMPORARY DAMAGE REDUCTION BUFFS
	# =====================================================

	for buff in damage_reduction_buffs.values():

		final_damage = int(
			round(
				final_damage
				* (
					1.0
					- float(
						buff["reduction"]
					)
				)
			)
		)

	final_damage = max(
		0,
		final_damage
	)

	# =====================================================
	# CORROSION
	# =====================================================

	if corrosion_timer > 0.0:

		corrosion_timer -= 0.0

		if (
			attacker != null
			and attacker.team_id
			== corrosion_team
		):

			final_damage += (
				corrosion_bonus_damage
			)

			corrosion_timer = 0.0
			corrosion_team = 0
			corrosion_bonus_damage = 0

			debug_log(
				str(name)
				+ "'s Corroded effect was consumed!"
			)

	# =====================================================
	# SHIELD
	# =====================================================

	if current_shield > 0:

		var absorbed: int = min(
			current_shield,
			final_damage
		)

		current_shield -= absorbed

		final_damage -= absorbed

		if current_shield <= 0:

			shield_timer = 0.0

			check_fortress_shell_special()

	# =====================================================
	# HEALTH DAMAGE
	# =====================================================

	current_health -= (
		final_damage
	)

	current_health = max(
		0,
		current_health
	)

	debug_log(
		str(name)
		+ " HP: "
		+ str(current_health)
		+ "/"
		+ str(max_health)
	)

	# =====================================================
	# DAMAGE HISTORY
	# =====================================================

	if (
		attacker != null
		and final_damage > 0
	):

		last_damage_time = (
			combat_time()
		)

		last_damage_team = (
			attacker.team_id
		)

		last_damage_attacker_id = (
			attacker.get_instance_id()
		)

		if (
			attacker.character_data != null
			and attacker.character_data.faction
			== "Formicara"
		):

			last_formicara_damage_time = (
				combat_time()
			)

			last_formicara_damage_team = (
				attacker.team_id
			)

			last_formicara_attacker_id = (
				attacker.get_instance_id()
			)

	# =====================================================
	# RETALIATION PROTOCOL
	# =====================================================

	if (
		is_basic_attack
		and final_damage > 0
		and has_effect(
			"retaliation_protocol"
		)
	):

		var hit_count: int = (
			add_counter(
				"retaliation_hits_taken"
			)
		)

		if hit_count >= 4:

			reset_counter(
				"retaliation_hits_taken"
			)

			set_flag(
				"retaliation_ready"
			)

	# =====================================================
	# TOXIC GUARD
	# =====================================================

	if (
		get_basic_ability_id()
		== "toxic_guard"
		and attacker != null
		and toxic_guard_target == null
	):

		toxic_guard_target = (
			attacker
		)

		ability_flags[
			"toxic_guard_expires"
		] = (
			combat_time()
			+ 5.0
		)

		debug_log(
			str(name)
			+ " activated Toxic Guard on "
			+ str(attacker.name)
			+ "!"
		)

	# =====================================================
	# TOXIC RETRIBUTION
	# =====================================================

	if (
		has_effect(
			"toxic_retribution"
		)
		and attacker != null
		and attacker == toxic_guard_target
		and combat_time()
		<= float(
			ability_flags.get(
				"toxic_guard_expires",
				0.0
			)
		)
	):

		var retaliation_count: int = (
			add_counter(
				"toxic_retribution_hits"
			)
		)

		if retaliation_count >= 4:

			reset_counter(
				"toxic_retribution_hits"
			)

			var key: String = (
				"toxic_retribution_on_"
				+ str(
					attacker.get_instance_id()
				)
			)

			if not flag_used(
				key
			):

				set_flag(
					key
				)

				attacker.apply_dot(
					"toxic_retribution_"
					+ str(
						get_instance_id()
					),
					2,
					4,
					1.0
				)

				attacker.add_attack_slow(
					"toxic_retribution_"
					+ str(
						get_instance_id()
					),
					1.10,
					4.0
				)

				debug_log(
					str(name)
					+ " activated Toxic Retribution!"
				)

	check_health_threshold_effects(
		attacker
	)

	if current_health <= 0:

		die()

# =========================================================
# HEALTH THRESHOLD EFFECTS
# =========================================================

func check_health_threshold_effects(
	_attacker: CharacterBody2D
) -> void:

	if current_health <= 0:
		return

	var hp_percent: float = (
		get_health_percent(
			self
		)
	)

	# =====================================================
	# VANGUARD 4 - FORTRESS
	# =====================================================

	if (
		character_data != null
		and character_data.class_role == "Vanguard"
		and class_synergy_tier >= 4
		and not fortress_shield_used
		and hp_percent <= VANGUARD_FORTRESS_TRIGGER
	):

		fortress_shield_used = true

		receive_shield(
			VANGUARD_FORTRESS_SHIELD,
			VANGUARD_FORTRESS_SHIELD_DURATION
		)

	# =====================================================
	# CARAPHEX 4 - LAST SHELL
	# =====================================================

	if (
		character_data != null
		and character_data.faction == "Caraphex"
		and faction_synergy_tier >= 4
		and not last_shell_used
		and hp_percent <= CARAPHEX_LAST_SHELL_TRIGGER
	):

		last_shell_used = true

		var shell_amount: int = int(
			round(
				max_health
				* CARAPHEX_LAST_SHELL_SHIELD_PERCENT
			)
		)

		receive_shield(
			shell_amount,
			CARAPHEX_LAST_SHELL_DURATION
		)

	# =====================================================
	# VANGUARD CLASS - LAST STAND
	# =====================================================

	if (
		has_effect(
			"last_stand"
		)
		and not flag_used(
			"last_stand_used"
		)
		and hp_percent <= 0.30
	):

		set_flag(
			"last_stand_used"
		)

		add_damage_reduction_buff(
			"last_stand",
			0.25,
			3.0
		)

		debug_log(
			str(name)
			+ " activated Last Stand!"
		)

	# =====================================================
	# FIGHTER CLASS - ADRENAL SURGE
	# =====================================================

	if (
		has_effect(
			"adrenal_surge"
		)
		and not flag_used(
			"adrenal_surge_used"
		)
		and hp_percent <= 0.50
	):

		set_flag(
			"adrenal_surge_used"
		)

		add_attack_speed_buff(
			"adrenal_surge",
			0.85,
			4.0
		)

		debug_log(
			str(name)
			+ " activated Adrenal Surge!"
		)

	# =====================================================
	# VORREN - PHASE STEP
	# =====================================================

	if (
		get_basic_ability_id()
		== "phase_step"
		and not flag_used(
			"phase_step_used"
		)
		and hp_percent <= 0.50
	):

		set_flag(
			"phase_step_used"
		)

		var old_position: Vector2 = (
			global_position
		)

		if target != null:

			dash_away_from(
				target,
				70.0
			)

		add_move_speed_buff(
			"phase_step",
			20.0,
			2.0
		)

		debug_log(
			str(name)
			+ " activated Phase Step!"
		)

		if has_effect(
			"phantom_bulwark"
		):

			activate_phantom_bulwark(
				old_position
			)

	# =====================================================
	# THAROS - FRENZY TEMPEST
	# =====================================================

	if (
		has_effect(
			"frenzy_tempest"
		)
		and not flag_used(
			"frenzy_tempest_used"
		)
		and hp_percent <= 0.50
	):

		set_flag(
			"frenzy_tempest_used"
		)

		add_attack_speed_buff(
			"frenzy_tempest",
			0.80,
			4.0
		)

		add_move_speed_buff(
			"frenzy_tempest",
			20.0,
			4.0
		)

		add_damage_buff(
			"frenzy_tempest",
			4,
			4.0
		)

		debug_log(
			str(name)
			+ " activated Frenzy Tempest!"
		)

	# =====================================================
	# VEYRA - QUEEN'S BASTION
	# =====================================================

	if (
		has_effect(
			"queens_bastion"
		)
		and not flag_used(
			"queens_bastion_used"
		)
		and hp_percent < 0.40
	):

		set_flag(
			"queens_bastion_used"
		)

		receive_shield(
			30,
			5.0
		)

		for ally in get_living_allies():

			if ally == self:
				continue

			ally.receive_shield(
				12,
				4.0
			)

		debug_log(
			str(name)
			+ " activated Queen's Bastion!"
		)

	# =====================================================
	# DROVEN - DOMINANT TERRITORY
	# =====================================================

	if (
		has_effect(
			"dominant_territory"
		)
		and not flag_used(
			"dominant_territory_used"
		)
		and hp_percent < 0.50
	):

		set_flag(
			"dominant_territory_used"
		)

		add_damage_reduction_buff(
			"dominant_territory",
			0.20,
			2.5
		)

		for enemy in get_living_enemies():

			if global_position.distance_to(
				enemy.global_position
			) <= 120.0:

				enemy.force_target(
					self,
					2.5
				)

		debug_log(
			str(name)
			+ " activated Dominant Territory!"
		)

	# =====================================================
	# KARNYX - UNBREAKABLE LINE
	# =====================================================

	if (
		has_effect(
			"unbreakable_line"
		)
		and not flag_used(
			"unbreakable_line_used"
		)
		and hp_percent < 0.40
	):

		set_flag(
			"unbreakable_line_used"
		)

		ability_flags[
			"unbreakable_until"
		] = (
			combat_time()
			+ 4.0
		)

		receive_shield(
			20,
			4.0
		)

		for ally in get_living_allies():

			if global_position.distance_to(
				ally.global_position
			) <= 80.0:

				ally.add_damage_reduction_buff(
					"unbreakable_line_"
						+ str(
							get_instance_id()
						),
					0.10,
					4.0
				)

		debug_log(
			str(name)
			+ " activated Unbreakable Line!"
		)

# =========================================================
# MOON VEIL
# =========================================================

func apply_moon_veil_reduction(
	incoming_damage: int
) -> int:

	var lowest = (
		find_lowest_health_ally()
	)

	if lowest != self:
		return incoming_damage

	for ally in get_living_allies():

		if ally == self:
			continue

		if ally.get_basic_ability_id() != "moon_veil":
			continue

		if not ally.ability_ready(
			"moon_veil"
		):
			continue

		ally.start_cooldown(
			"moon_veil",
			7.0
		)

		ally.debug_log(
			str(ally.name)
			+ " activated Moon Veil on "
			+ str(name)
			+ "!"
		)

		return int(
			round(
				incoming_damage
				* 0.70
			)
		)

	return incoming_damage

# =========================================================
# GUARDIAN'S REACH
# =========================================================

func has_guardians_reach_protection() -> bool:

	for ally in get_living_allies():

		if ally == self:
			continue

		if not ally.has_effect(
			"guardians_reach"
		):
			continue

		if global_position.distance_to(
			ally.global_position
		) <= 90.0:

			return true

	return false

# =========================================================
# CROWD CONTROL
# =========================================================

func apply_stagger(
	duration: float,
	_source: CharacterBody2D = null
) -> void:

	if get_basic_ability_id() == "hold_the_line":

		if not flag_used(
			"hold_the_line_used"
		):

			set_flag(
				"hold_the_line_used"
			)

			receive_shield(
				8,
				4.0
			)

			debug_log(
				str(name)
				+ " activated Hold the Line!"
			)

			return

	if (
		get_basic_ability_id()
		== "heavy_shell"
		and current_shield > 0
	):

		return

	if (
		float(
			ability_flags.get(
				"unbreakable_until",
				0.0
			)
		)
		> combat_time()
	):

		return

	stagger_until = max(
		stagger_until,
		combat_time()
		+ duration
	)

func apply_knockback(
	source: CharacterBody2D,
	distance: float
) -> void:

	if source == null:
		return

	if get_basic_ability_id() == "hold_the_line":

		if not flag_used(
			"hold_the_line_used"
		):

			set_flag(
				"hold_the_line_used"
			)

			receive_shield(
				8,
				4.0
			)

			debug_log(
				str(name)
				+ " activated Hold the Line!"
			)

			return

	if (
		get_basic_ability_id()
		== "heavy_shell"
		and current_shield > 0
	):

		return

	if (
		float(
			ability_flags.get(
				"unbreakable_until",
				0.0
			)
		)
		> combat_time()
	):

		return

	var direction: Vector2 = (
		source.global_position.direction_to(
			global_position
		)
	)

	global_position += (
		direction
		* distance
	)

# =========================================================
# FORCE TARGET
# =========================================================

func force_target(
	new_target: CharacterBody2D,
	duration: float
) -> void:

	if new_target == null:
		return

	forced_target = (
		new_target
	)

	forced_target_until = (
		combat_time()
		+ duration
	)

	set_target(
		new_target
	)

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

func damage_shield_directly(
	amount: int
) -> int:

	if current_shield <= 0:
		return 0

	var removed: int = min(
		current_shield,
		amount
	)

	current_shield -= removed

	if current_shield <= 0:

		shield_timer = 0.0

		check_fortress_shell_special()

	return removed

# =========================================================
# BRONTIS - FORTRESS SHELL
# =========================================================

func check_fortress_shell_special() -> void:

	if not has_effect(
		"fortress_shell"
	):
		return

	if flag_used(
		"fortress_shell_used"
	):
		return

	if get_basic_ability_id() != "heavy_shell":
		return

	set_flag(
		"fortress_shell_used"
	)

	receive_shield(
		25,
		3.0
	)

	add_damage_reduction_buff(
		"fortress_shell",
		0.25,
		3.0
	)

	debug_log(
		str(name)
		+ " activated Fortress Shell!"
	)

# =========================================================
# VIREX - SHATTERSTRIKE
# =========================================================

func try_shatterstrike(
	shielded_target: CharacterBody2D
) -> int:

	if not has_effect(
		"shatterstrike"
	):
		return 0

	if not ability_ready(
		"shatterstrike"
	):
		return 0

	if shielded_target.current_shield <= 0:
		return 0

	var removed: int = (
		shielded_target.damage_shield_directly(
			15
		)
	)

	start_cooldown(
		"shatterstrike",
		5.0
	)

	var bonus_damage: int = int(
		floor(
			float(
				removed
			)
			* 0.30
		)
	)

	debug_log(
		str(name)
		+ " activated Shatterstrike!"
	)

	return bonus_damage

# =========================================================
# SPECIAL HELPERS
# =========================================================

func activate_eclipse_dance(
	dance_target: CharacterBody2D
) -> void:

	if dance_target == null:
		return

	if not dance_target.is_alive:
		return

	set_flag(
		"eclipse_dance_used"
	)

	for i in range(3):

		if not is_instance_valid(
			dance_target
		):
			break

		if not dance_target.is_alive:
			break

		blink_behind_target(
			dance_target,
			35.0
		)

		dance_target.take_damage(
			max(
				1,
				int(
					round(
						damage
						* 0.60
					)
				)
			),
			self,
			true
		)

	debug_log(
		str(name)
		+ " activated Eclipse Dance!"
	)

func activate_phantom_assault(
	assault_target: CharacterBody2D
) -> void:

	if assault_target == null:
		return

	start_cooldown(
		"phantom_assault",
		7.0
	)

	for i in range(2):

		if not assault_target.is_alive:
			break

		assault_target.take_damage(
			max(
				1,
				int(
					round(
						damage
						* 0.50
					)
				)
			),
			self,
			true
		)

	debug_log(
		str(name)
		+ " activated Phantom Assault!"
	)

func activate_swarm_assault() -> void:

	add_attack_speed_buff(
		"swarm_assault",
		0.85,
		3.0
	)

	var ally = (
		find_recent_formicara_ally_on_target()
	)

	if ally != null:

		ally.add_attack_speed_buff(
			"swarm_assault_"
				+ str(
					get_instance_id()
				),
			0.85,
			3.0
		)

	debug_log(
		str(name)
		+ " activated Swarm Assault!"
	)

func activate_seismic_breaker(
	center_target: CharacterBody2D
) -> void:

	start_cooldown(
		"seismic_breaker",
		6.0
	)

	for enemy in get_living_enemies():

		if enemy.global_position.distance_to(
			center_target.global_position
		) > 90.0:
			continue

		enemy.take_damage(
			max(
				1,
				int(
					round(
						damage
						* 0.60
					)
				)
			),
			self,
			true
		)

		enemy.add_move_slow(
			"seismic_breaker_"
				+ str(
					get_instance_id()
				),
			0.70,
			2.0
		)

	debug_log(
		str(name)
		+ " activated Seismic Breaker!"
	)

func activate_siege_cannon(
	main_target: CharacterBody2D
) -> void:

	if main_target == null:
		return

	var push_distance: float = 100.0

	if (
		main_target.character_data != null
		and main_target.character_data.class_role
		== "Vanguard"
	):

		push_distance = 60.0

	var old_position: Vector2 = (
		main_target.global_position
	)

	main_target.apply_knockback(
		self,
		push_distance
	)

	for enemy in get_living_enemies():

		if enemy == main_target:
			continue

		if enemy.global_position.distance_to(
			old_position
		) <= 55.0:

			enemy.take_damage(
				4,
				self,
				false
			)

			enemy.apply_knockback(
				self,
				30.0
			)

	debug_log(
		str(name)
		+ " activated Siege Cannon!"
	)

func activate_toxic_barrage(
	main_target: CharacterBody2D
) -> void:

	main_target.apply_dot(
		"toxic_barrage_"
			+ str(
				get_instance_id()
			),
		3,
		2,
		1.0
	)

	var secondary = (
		find_nearest_other_enemy(
			main_target,
			100.0
		)
	)

	if secondary != null:

		secondary.apply_dot(
			"toxic_barrage_"
				+ str(
					get_instance_id()
				),
			3,
			2,
			1.0
		)

	debug_log(
		str(name)
		+ " activated Toxic Barrage!"
	)

func activate_phantom_bulwark(
	_old_position: Vector2
) -> void:

	# We are implementing the gameplay effect without
	# creating a visible phantom scene yet.
	#
	# Nearby enemies temporarily lose Vorren as an easy
	# target by redirecting them toward a harmless delay.
	#
	# A visual phantom scene can replace this later.

	untargetable_until = (
		combat_time()
		+ 0.75
	)

	debug_log(
		str(name)
		+ " activated Phantom Bulwark!"
	)

# =========================================================
# THAROS - WING RUSH
# =========================================================

func check_wing_rush() -> void:

	if get_basic_ability_id() != "wing_rush":
		return

	if target == null:
		return

	if not ability_ready(
		"wing_rush"
	):
		return

	var distance: float = (
		global_position.distance_to(
			target.global_position
		)
	)

	if distance > (
		get_current_attack_range()
		+ 90.0
	):

		add_move_speed_buff(
			"wing_rush",
			25.0,
			2.0
		)

		start_cooldown(
			"wing_rush",
			4.0
		)

		debug_log(
			str(name)
			+ " activated Wing Rush!"
		)

# =========================================================
# SOLVYR - LUNAR SIGHT / MOONSHOT
# =========================================================

func check_moonshot_progress() -> void:

	if not has_effect(
		"moonshot"
	):
		return

	if target == null:
		return

	if not is_target_isolated(
		target
	):
		reset_counter(
			"moonshot_isolated_hits"
		)

		return

	var count: int = (
		add_counter(
			"moonshot_isolated_hits"
		)
	)

	if (
		count >= 4
		and ability_ready(
			"moonshot"
		)
	):

		reset_counter(
			"moonshot_isolated_hits"
		)

		set_flag(
			"moonshot_ready"
		)

# =========================================================
# TARGETING
# =========================================================

func find_closest_enemy() -> CharacterBody2D:

	var best_enemy: CharacterBody2D = null

	var best_score: float = INF

	for enemy in get_living_enemies():

		if enemy.is_untargetable():
			continue

		var distance: float = (
			global_position.distance_to(
				enemy.global_position
			)
		)

		var score: float = (
			distance
		)

		# Marked Prey increases targeting priority.
		if enemy.marked_for_team == team_id:

			score *= 0.75

		# Solvyr prefers isolated targets.
		if (
			get_basic_ability_id()
			== "lunar_sight"
			and is_target_isolated(
				enemy
			)
		):

			score -= 100.0

		# Vexira prefers wounded targets.
		if (
			get_basic_ability_id()
			== "weak_point"
			and get_health_percent(
				enemy
			) < 0.50
		):

			score -= 100.0

		# Virex prefers shielded targets.
		if (
			get_basic_ability_id()
			== "shellbreaker"
			and enemy.current_shield > 0
		):

			score -= 80.0

		if score < best_score:

			best_score = score

			best_enemy = enemy

	return best_enemy

func find_farthest_enemy() -> CharacterBody2D:

	var farthest: CharacterBody2D = null

	var farthest_distance: float = -1.0

	for enemy in get_living_enemies():

		var distance: float = (
			global_position.distance_to(
				enemy.global_position
			)
		)

		if distance > farthest_distance:

			farthest_distance = distance

			farthest = enemy

	return farthest

func find_lowest_health_enemy() -> CharacterBody2D:

	var lowest: CharacterBody2D = null

	var lowest_percent: float = INF

	for enemy in get_living_enemies():

		var health_percent: float = (
			get_health_percent(
				enemy
			)
		)

		if health_percent < lowest_percent:

			lowest_percent = health_percent

			lowest = enemy

	return lowest

func find_backline_enemy(
	rows: int,
	prioritize_support_or_marksman: bool
) -> CharacterBody2D:

	var preferred: Array = []

	var fallback: Array = []

	for enemy in get_living_enemies():

		if not is_backline_unit(
			enemy,
			rows
		):
			continue

		fallback.append(
			enemy
		)

		if (
			prioritize_support_or_marksman
			and enemy.character_data != null
			and (
				enemy.character_data.class_role
				== "Support"
				or enemy.character_data.class_role
				== "Marksman"
			)
		):

			preferred.append(
				enemy
			)

	if preferred.size() > 0:

		return preferred[
			randi()
			% preferred.size()
		]

	if fallback.size() > 0:

		return fallback[
			randi()
			% fallback.size()
		]

	return null

func find_lowest_health_backline_enemy(
	rows: int
) -> CharacterBody2D:

	var lowest: CharacterBody2D = null

	var lowest_percent: float = INF

	for enemy in get_living_enemies():

		if not is_backline_unit(
			enemy,
			rows
		):
			continue

		var percent: float = (
			get_health_percent(
				enemy
			)
		)

		if percent < lowest_percent:

			lowest_percent = percent

			lowest = enemy

	return lowest

func is_backline_unit(
	unit: CharacterBody2D,
	rows: int
) -> bool:

	if unit == null:
		return false

	if unit.team_id == 1:

		if rows <= 2:

			return (
				unit.spawn_position.x
				<= 175.0
			)

		return (
			unit.spawn_position.x
			<= 250.0
		)

	if rows <= 2:

		return (
			unit.spawn_position.x
			>= 905.0
		)

	return (
		unit.spawn_position.x
		>= 830.0
	)

# =========================================================
# FIND ALLIES / ENEMIES
# =========================================================

func get_living_allies() -> Array:

	var allies: Array = []

	for node in get_tree().get_nodes_in_group(
		"Characters"
	):

		if node.team_id != team_id:
			continue

		if not node.is_alive:
			continue

		allies.append(
			node
		)

	return allies

func get_living_enemies() -> Array:

	var enemies: Array = []

	for node in get_tree().get_nodes_in_group(
		"Characters"
	):

		if node == self:
			continue

		if node.team_id == team_id:
			continue

		if not node.is_alive:
			continue

		enemies.append(
			node
		)

	return enemies

func find_lowest_health_ally() -> CharacterBody2D:

	var lowest: CharacterBody2D = null

	var lowest_percent: float = INF

	for ally in get_living_allies():

		var percent: float = (
			get_health_percent(
				ally
			)
		)

		if percent < lowest_percent:

			lowest_percent = percent

			lowest = ally

	return lowest

func find_ally_below_health(
	threshold: float
) -> CharacterBody2D:

	var lowest = (
		find_lowest_health_ally()
	)

	if lowest == null:
		return null

	if get_health_percent(
		lowest
	) < threshold:

		return lowest

	return null

func find_nearest_ally() -> CharacterBody2D:

	var nearest: CharacterBody2D = null

	var nearest_distance: float = INF

	for ally in get_living_allies():

		if ally == self:
			continue

		var distance: float = (
			global_position.distance_to(
				ally.global_position
			)
		)

		if distance < nearest_distance:

			nearest_distance = distance

			nearest = ally

	return nearest

func find_lowest_health_debuffed_ally() -> CharacterBody2D:

	var best: CharacterBody2D = null

	var best_percent: float = INF

	for ally in get_living_allies():

		if not ally.has_removable_debuff():
			continue

		var percent: float = (
			get_health_percent(
				ally
			)
		)

		if percent < best_percent:

			best_percent = percent

			best = ally

	return best

# =========================================================
# SECONDARY TARGET HELPERS
# =========================================================

func find_nearest_other_enemy(
	main_target: CharacterBody2D,
	max_distance: float
) -> CharacterBody2D:

	var nearest: CharacterBody2D = null

	var nearest_distance: float = INF

	for enemy in get_living_enemies():

		if enemy == main_target:
			continue

		var distance: float = (
			main_target.global_position.distance_to(
				enemy.global_position
			)
		)

		if distance > max_distance:
			continue

		if distance < nearest_distance:

			nearest_distance = distance

			nearest = enemy

	return nearest

func find_nearest_enemies_to_target(
	main_target: CharacterBody2D,
	count: int
) -> Array:

	var results: Array = []

	for i in range(
		count
	):

		var best: CharacterBody2D = null

		var best_distance: float = INF

		for enemy in get_living_enemies():

			if enemy == main_target:
				continue

			if results.has(
				enemy
			):
				continue

			var distance: float = (
				main_target.global_position.distance_to(
					enemy.global_position
				)
			)

			if distance < best_distance:

				best_distance = distance

				best = enemy

		if best != null:

			results.append(
				best
			)

	return results

func find_enemy_behind_target(
	main_target: CharacterBody2D,
	max_distance: float
) -> CharacterBody2D:

	if main_target == null:
		return null

	var attack_direction: Vector2 = (
		global_position.direction_to(
			main_target.global_position
		)
	)

	var best: CharacterBody2D = null

	var best_distance: float = INF

	for enemy in get_living_enemies():

		if enemy == main_target:
			continue

		var offset: Vector2 = (
			enemy.global_position
			- main_target.global_position
		)

		var distance: float = (
			offset.length()
		)

		if distance > max_distance:
			continue

		if distance <= 0.0:
			continue

		var direction: Vector2 = (
			offset.normalized()
		)

		var alignment: float = (
			attack_direction.dot(
				direction
			)
		)

		if alignment < 0.65:
			continue

		if distance < best_distance:

			best_distance = distance

			best = enemy

	return best

# =========================================================
# FORMICARA HELPER
# =========================================================

func find_recent_formicara_ally_on_target() -> CharacterBody2D:

	if target == null:
		return null

	var attacker_id: int = (
		target.last_formicara_attacker_id
	)

	for ally in get_living_allies():

		if ally.get_instance_id() == attacker_id:

			return ally

	return null

# =========================================================
# ISOLATION
# =========================================================

func is_target_isolated(
	check_target: CharacterBody2D
) -> bool:

	if check_target == null:
		return false

	for enemy in get_living_enemies():

		if enemy == check_target:
			continue

		if enemy.global_position.distance_to(
			check_target.global_position
		) <= 100.0:

			return false

	return true

# =========================================================
# GEOMETRY HELPERS
# =========================================================

func distance_to_line_segment(
	point: Vector2,
	segment_start: Vector2,
	segment_end: Vector2
) -> float:

	var segment: Vector2 = (
		segment_end
		- segment_start
	)

	var segment_length_squared: float = (
		segment.length_squared()
	)

	if segment_length_squared <= 0.0001:
		return point.distance_to(
			segment_start
		)

	var projection: float = clamp(
		(
			point
			- segment_start
		).dot(
			segment
		)
		/ segment_length_squared,
		0.0,
		1.0
	)

	var closest_point: Vector2 = (
		segment_start
		+ segment
		* projection
	)

	return point.distance_to(
		closest_point
	)

# =========================================================
# MOVEMENT HELPERS
# =========================================================

func dash_toward_target(
	dash_target: CharacterBody2D,
	distance: float
) -> void:

	if dash_target == null:
		return

	var direction: Vector2 = (
		global_position.direction_to(
			dash_target.global_position
		)
	)

	var actual_distance: float = min(
		distance,
		global_position.distance_to(
			dash_target.global_position
		)
	)

	global_position += (
		direction
		* actual_distance
	)

func dash_away_from(
	source: CharacterBody2D,
	distance: float
) -> void:

	if source == null:
		return

	var direction: Vector2 = (
		source.global_position.direction_to(
			global_position
		)
	)

	global_position += (
		direction
		* distance
	)

func jump_near_target(
	jump_target: CharacterBody2D,
	distance_from_target: float
) -> void:

	if jump_target == null:
		return

	var direction: Vector2 = (
		jump_target.global_position.direction_to(
			global_position
		)
	)

	if direction == Vector2.ZERO:

		direction = Vector2.LEFT

	global_position = (
		jump_target.global_position
		+ direction
		* distance_from_target
	)

func blink_behind_target(
	blink_target: CharacterBody2D,
	distance: float
) -> void:

	if blink_target == null:
		return

	var direction: Vector2 = (
		global_position.direction_to(
			blink_target.global_position
		)
	)

	global_position = (
		blink_target.global_position
		+ direction
		* distance
	)

func perform_sidestep(
	step_target: CharacterBody2D,
	distance: float
) -> void:

	if step_target == null:
		return

	var toward_target: Vector2 = (
		global_position.direction_to(
			step_target.global_position
		)
	)

	var perpendicular: Vector2 = Vector2(
		-toward_target.y,
		toward_target.x
	)

	global_position += (
		perpendicular
		* distance
	)

# =========================================================
# MARKSMAN STEADY AIM
# =========================================================

func reset_steady_aim_if_moving() -> void:

	if steady_aim_stacks <= 0:
		return

	steady_aim_stacks = 0

func gain_steady_aim_stack() -> void:

	if character_data == null:
		return

	if character_data.class_role != "Marksman":
		return

	if not class_synergy_active:
		return

	steady_aim_stacks = min(
		STEADY_AIM_MAX_STACKS,
		steady_aim_stacks + 1
	)

# =========================================================
# CURRENT MOVE SPEED
# =========================================================

func get_current_move_speed() -> float:

	var result: float = (
		move_speed
	)

	for buff in move_speed_buffs.values():

		result += float(
			buff["bonus"]
		)

	for slow in move_slow_effects.values():

		result *= float(
			slow["multiplier"]
		)

	return max(
		0.0,
		result
	)

# =========================================================
# MOVEMENT STOP RANGE
# =========================================================
#
# Normal units stop as soon as they reach their true attack
# range, including permanent range upgrades.
#
# Entrenched Position is different: a Marksman may stop at
# the future +25 setup range, stand still for 2 seconds, and
# then begin firing once Entrenched becomes active.
# =========================================================

func get_movement_stop_range() -> float:

	var result: float = (
		get_current_attack_range()
	)

	if (
		has_effect(
			"entrenched_position"
		)
		and entrenched_stationary_timer < 2.0
	):

		result = max(
			result,
			attack_range + 25.0
		)

	return result

# =========================================================
# CURRENT ATTACK RANGE
# =========================================================

func get_current_attack_range() -> float:

	var result: float = (
		attack_range
	)

	# Solvyr - Lunar Sight.
	if (
		get_basic_ability_id()
		== "lunar_sight"
		and target != null
		and is_target_isolated(
			target
		)
	):

		result += 25.0

	# Marksman class - Entrenched Position.
	if (
		has_effect(
			"entrenched_position"
		)
		and entrenched_stationary_timer >= 2.0
	):

		result += 25.0

	# Moonshot effectively has battlefield-wide range.
	if flag_used(
		"moonshot_ready"
	):

		result = 5000.0

	return result

# =========================================================
# CURRENT ATTACK COOLDOWN
# =========================================================

func get_current_attack_cooldown() -> float:

	var final_cooldown: float = (
		attack_cooldown
	)

	for buff in attack_speed_buffs.values():

		final_cooldown *= float(
			buff["multiplier"]
		)

	for slow in attack_slow_effects.values():

		final_cooldown *= float(
			slow["multiplier"]
		)

	# =====================================================
	# MARKSMAN SYNERGY
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

		final_cooldown *= (
			1.0
			- steady_aim_stacks
			* speed_per_stack
		)

	# =====================================================
	# FIGHTER 4
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
	# SCOLYRA 4
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

	return max(
		MIN_ATTACK_COOLDOWN,
		final_cooldown
	)

# =========================================================
# TEMPORARY DAMAGE BONUS
# =========================================================

func get_temporary_damage_bonus() -> int:

	var total: int = 0

	for buff in damage_buffs.values():

		total += int(
			buff["bonus"]
		)

	return total

# =========================================================
# HEAL
# =========================================================

func heal(
	amount: int
) -> void:

	if not is_alive:
		return

	current_health += amount

	current_health = min(
		current_health,
		max_health
	)

# =========================================================
# SUPPORT SCALING
# =========================================================

func scale_support_amount(
	base_amount: int
) -> int:

	if support_synergy_tier >= 4:

		return int(
			round(
				base_amount
				* SUPPORT_FULL_EFFECT_MULTIPLIER
			)
		)

	if support_synergy_tier >= 2:

		return int(
			round(
				base_amount
				* SUPPORT_SMALL_EFFECT_MULTIPLIER
			)
		)

	return base_amount

# =========================================================
# MARK
# =========================================================

func receive_mark(
	marking_team: int,
	bonus_damage: int,
	duration: float
) -> void:

	marked_for_team = (
		marking_team
	)

	marked_bonus_damage = (
		bonus_damage
	)

	marked_timer = (
		duration
	)

# =========================================================
# DEBUFF HELPERS
# =========================================================

func has_removable_debuff() -> bool:

	if move_slow_effects.size() > 0:
		return true

	if attack_slow_effects.size() > 0:
		return true

	if marked_timer > 0.0:
		return true

	if corrosion_timer > 0.0:
		return true

	if active_dots.size() > 0:
		return true

	return false

func remove_one_debuff() -> void:

	if move_slow_effects.size() > 0:

		var key = (
			move_slow_effects.keys()[0]
		)

		move_slow_effects.erase(
			key
		)

		return

	if attack_slow_effects.size() > 0:

		var key = (
			attack_slow_effects.keys()[0]
		)

		attack_slow_effects.erase(
			key
		)

		return

	if marked_timer > 0.0:

		marked_timer = 0.0
		marked_for_team = 0
		marked_bonus_damage = 0

		return

	if corrosion_timer > 0.0:

		corrosion_timer = 0.0
		corrosion_team = 0
		corrosion_bonus_damage = 0

		return

	if active_dots.size() > 0:

		var key = (
			active_dots.keys()[0]
		)

		active_dots.erase(
			key
		)

# =========================================================
# HEALTH PERCENT
# =========================================================

func get_health_percent(
	unit: CharacterBody2D
) -> float:

	if unit == null:
		return 0.0

	if unit.max_health <= 0:
		return 0.0

	return (
		float(
			unit.current_health
		)
		/ float(
			unit.max_health
		)
	)

# =========================================================
# UNTARGTABLE
# =========================================================

func is_untargetable() -> bool:

	return (
		combat_time()
		< untargetable_until
	)

# =========================================================
# APPLY SAVED UPGRADES
# =========================================================

func apply_saved_upgrades() -> void:

	if character_data == null:
		return

	var character_name: String = (
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
		+ str(
			upgrades.size()
		)
		+ " upgrade(s) to "
		+ character_name
	)

	for upgrade in upgrades:

		if upgrade.has(
			"health_bonus"
		):

			max_health += int(
				upgrade[
					"health_bonus"
				]
			)

		if upgrade.has(
			"damage_bonus"
		):

			damage += int(
				upgrade[
					"damage_bonus"
				]
			)

		if upgrade.has(
			"move_speed_bonus"
		):

			move_speed += float(
				upgrade[
					"move_speed_bonus"
				]
			)

		if upgrade.has(
			"range_bonus"
		):

			attack_range += float(
				upgrade[
					"range_bonus"
				]
			)

		if upgrade.has(
			"cooldown_reduction"
		):

			attack_cooldown -= float(
				upgrade[
					"cooldown_reduction"
				]
			)

			attack_cooldown = max(
				MIN_ATTACK_COOLDOWN,
				attack_cooldown
			)

		debug_log(
			character_name
			+ " gained upgrade: "
			+ str(
				upgrade["name"]
			)
		)

# =========================================================
# UNITED COLONY
# =========================================================

func trigger_united_colony_death_bonus() -> void:

	for ally in get_living_allies():

		if ally == self:
			continue

		if ally.character_data == null:
			continue

		if ally.character_data.faction != "Formicara":
			continue

		ally.united_colony_damage_bonus += (
			UNITED_COLONY_DEATH_DAMAGE_BONUS
		)

		ally.debug_log(
			"United Colony! "
			+ str(
				ally.name
			)
			+ " gained +2 ATK because "
			+ str(name)
			+ " was defeated."
		)

# =========================================================
# CHARACTER NAME
# =========================================================

func get_character_name() -> String:

	if character_data != null:

		return (
			character_data.character_name
		)

	return str(
		name
	)

# =========================================================
# DEBUG LOG
# =========================================================

func debug_log(
	message: String
) -> void:

	if debug_combat_logs:

		print(
			message
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
