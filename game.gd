extends Node2D


# =========================================================
# CHARACTER SCENE
# =========================================================

var character_scene = preload(
	"res://character/Character.tscn"
)


# =========================================================
# CHARACTER DATA
# =========================================================


# =========================================================
# VESPER
# =========================================================

var veyra_data = preload("res://Data/Veyra.tres")
var zekrin_data = preload("res://Data/Zekrin.tres")
var melora_data = preload("res://Data/Melora.tres")
var tharos_data = preload("res://Data/Tharos.tres")
var aurex_data = preload("res://Data/Aurex.tres")


# =========================================================
# ANTTALOPE
# =========================================================

var kaelor_data = preload("res://Data/Kaelor.tres")
var syrra_data = preload("res://Data/Syrra.tres")
var droven_data = preload("res://Data/Droven.tres")
var nyxis_data = preload("res://Data/Nyxis.tres")
var velkara_data = preload("res://Data/Velkara.tres")


# =========================================================
# LEPIDRA
# =========================================================

var lunara_data = preload("res://Data/Lunara.tres")
var vorren_data = preload("res://Data/Vorren.tres")
var noctren_data = preload("res://Data/Noctren.tres")
var solvyr_data = preload("res://Data/Solvyr.tres")
var mavros_data = preload("res://Data/Mavros.tres")


# =========================================================
# FORMICARA
# =========================================================

var karnyx_data = preload("res://Data/Karnyx.tres")
var raxen_data = preload("res://Data/Raxen.tres")
var vexira_data = preload("res://Data/Vexira.tres")
var tarsik_data = preload("res://Data/Tarsik.tres")
var myraxa_data = preload("res://Data/Myraxa.tres")


# =========================================================
# CARAPHEX
# =========================================================

var brontis_data = preload("res://Data/Brontis.tres")
var kharvos_data = preload("res://Data/Kharvos.tres")
var virex_data = preload("res://Data/Virex.tres")
var ignivar_data = preload("res://Data/Ignivar.tres")
var aurelia_data = preload("res://Data/Aurelia.tres")


# =========================================================
# SCOLYRA
# =========================================================

var mordrax_data = preload("res://Data/Mordrax.tres")
var scyrix_data = preload("res://Data/Scyrix.tres")
var nyzara_data = preload("res://Data/Nyzara.tres")
var veltrix_data = preload("res://Data/Veltrix.tres")
var thesira_data = preload("res://Data/Thesira.tres")


# =========================================================
# FULL ROSTER
# =========================================================

var full_roster: Array[CharacterData] = []


# =========================================================
# PLACEMENT GRID SETTINGS
# =========================================================

const GRID_COLUMNS: int = 4
const GRID_ROWS: int = 5


# =========================================================
# PLAYER BATTLEFIELD GRID
# =========================================================

const PLAYER_GRID_ORIGIN: Vector2 = Vector2(
	100,
	150
)

const PLAYER_DEPTH_SPACING: float = 75.0
const PLAYER_LANE_SPACING: float = 100.0


# =========================================================
# OPPONENT BATTLEFIELD GRID
# =========================================================

const ENEMY_GRID_ORIGIN: Vector2 = Vector2(
	980,
	150
)

const ENEMY_DEPTH_SPACING: float = 75.0
const ENEMY_LANE_SPACING: float = 100.0


# =========================================================
# FALLBACK POSITIONS
# =========================================================

var fallback_player_positions = [
	Vector2(100, 150),
	Vector2(100, 250),
	Vector2(100, 350),
	Vector2(100, 450)
]


var fallback_enemy_positions = [
	Vector2(980, 150),
	Vector2(980, 250),
	Vector2(980, 350),
	Vector2(980, 450)
]


# =========================================================
# GAME STATE
# =========================================================

var combat_over: bool = false

var winner_label: Label
var score_label: Label


# =========================================================
# BATTLE LEDGER STATE
# =========================================================

var selected_battle_character: Node = null

const CHARACTER_CLICK_RADIUS: float = 80.0

var ledger_panel: PanelContainer
var ledger_title_label: Label
var ledger_stats_label: Label
var ledger_effects_label: Label

var last_ledger_title: String = ""
var last_ledger_stats: String = ""
var last_ledger_effects: String = ""

var selected_character_was_defeated: bool = false


# =========================================================
# GAME START
# =========================================================

func _ready() -> void:

	create_full_roster()


	print("====================")
	print("ROUND ", GameState.current_round)
	print("====================")


	create_battle_ui()


	var player_team = (
		GameState.selected_team
	)


	# =====================================================
	# FALLBACK PLAYER TEAM
	# =====================================================

	if player_team.size() != 4:

		player_team = [
			veyra_data,
			zekrin_data,
			melora_data,
			aurex_data
		]


	# =====================================================
	# CREATE OPPONENT TEAM
	# =====================================================

	if GameState.enemy_team.size() != 4:

		GameState.enemy_team = (
			create_random_enemy_team(
				player_team
			)
		)


	var enemy_team = (
		GameState.enemy_team
	)


	# =====================================================
	# CREATE OPPONENT FORMATION
	# =====================================================

	if GameState.enemy_placements.size() != 4:

		create_random_enemy_placement(
			enemy_team
		)


	# =====================================================
	# DEBUG TEAM INFO
	# =====================================================

	print("PLAYER TEAM:")


	for character in player_team:

		print(
			character.character_name
		)


	print("ENEMY TEAM:")


	for character in enemy_team:

		print(
			character.character_name
		)


	# =====================================================
	# SCORE
	# =====================================================

	update_score_label()


	# =====================================================
	# SPAWN PLAYER
	# =====================================================

	spawn_player_team(
		player_team
	)


	# =====================================================
	# SPAWN OPPONENT
	# =====================================================

	spawn_enemy_team(
		enemy_team
	)


# =========================================================
# CREATE FULL ROSTER
# =========================================================

func create_full_roster() -> void:

	full_roster = [

		# Vesper
		veyra_data,
		zekrin_data,
		melora_data,
		tharos_data,
		aurex_data,

		# Anttalope
		kaelor_data,
		syrra_data,
		droven_data,
		nyxis_data,
		velkara_data,

		# Lepidra
		lunara_data,
		vorren_data,
		noctren_data,
		solvyr_data,
		mavros_data,

		# Formicara
		karnyx_data,
		raxen_data,
		vexira_data,
		tarsik_data,
		myraxa_data,

		# Caraphex
		brontis_data,
		kharvos_data,
		virex_data,
		ignivar_data,
		aurelia_data,

		# Scolyra
		mordrax_data,
		scyrix_data,
		nyzara_data,
		veltrix_data,
		thesira_data
	]


# =========================================================
# GAME LOOP
# =========================================================

func _process(
	_delta: float
) -> void:

	update_battle_ledger()


	if combat_over:
		return


	check_for_winner()


# =========================================================
# BATTLEFIELD CLICK DETECTION
# =========================================================

func _input(
	event: InputEvent
) -> void:

	if not event is InputEventMouseButton:
		return


	if event.button_index != MOUSE_BUTTON_LEFT:
		return


	if not event.pressed:
		return


	select_character_at_mouse()


# =========================================================
# SELECT CHARACTER AT MOUSE
# =========================================================

func select_character_at_mouse() -> void:

	var mouse_position: Vector2 = (
		get_global_mouse_position()
	)


	var closest_character: Node = null

	var closest_distance: float = (
		CHARACTER_CLICK_RADIUS
	)


	for character in get_tree().get_nodes_in_group(
		"Characters"
	):

		if not is_instance_valid(
			character
		):
			continue


		if not character.is_alive:
			continue


		var distance: float = (
			mouse_position.distance_to(
				character.global_position
			)
		)


		if distance <= closest_distance:

			closest_distance = (
				distance
			)

			closest_character = (
				character
			)


	if closest_character == null:

		selected_battle_character = null

		selected_character_was_defeated = false

		ledger_panel.visible = false

		return


	selected_battle_character = (
		closest_character
	)


	selected_character_was_defeated = false

	ledger_panel.visible = true

	update_battle_ledger()


# =========================================================
# PLAYER TEAM SPAWNING
# =========================================================

func spawn_player_team(
	roster: Array
) -> void:

	for i in range(
		roster.size()
	):

		var character_data = (
			roster[i]
		)


		var character = (
			character_scene.instantiate()
		)


		character.character_data = (
			character_data
		)

		character.team_id = 1


		character.name = (
			"Team1_Character"
			+ str(i + 1)
		)


		if GameState.player_placements.has(
			character_data.character_name
		):

			var grid_position: Vector2i = (
				GameState.player_placements[
					character_data.character_name
				]
			)


			character.position = (
				player_grid_to_world_position(
					grid_position
				)
			)


			print(
				character_data.character_name,
				" spawning at player grid ",
				grid_position,
				" -> battlefield ",
				character.position
			)


		else:

			character.position = (
				fallback_player_positions[i]
			)


			print(
				character_data.character_name,
				" has no saved player placement. ",
				"Using fallback position."
			)


		add_child(
			character
		)


# =========================================================
# OPPONENT TEAM SPAWNING
# =========================================================

func spawn_enemy_team(
	roster: Array
) -> void:

	for i in range(
		roster.size()
	):

		var character_data = (
			roster[i]
		)


		var character = (
			character_scene.instantiate()
		)


		character.character_data = (
			character_data
		)

		character.team_id = 2


		character.name = (
			"Team2_Character"
			+ str(i + 1)
		)


		if GameState.enemy_placements.has(
			character_data.character_name
		):

			var grid_position: Vector2i = (
				GameState.enemy_placements[
					character_data.character_name
				]
			)


			character.position = (
				enemy_grid_to_world_position(
					grid_position
				)
			)


			print(
				character_data.character_name,
				" spawning at opponent grid ",
				grid_position,
				" -> battlefield ",
				character.position
			)


		else:

			character.position = (
				fallback_enemy_positions[i]
			)


			print(
				character_data.character_name,
				" has no saved opponent placement. ",
				"Using fallback position."
			)


		add_child(
			character
		)


# =========================================================
# PLAYER GRID TO WORLD
# =========================================================

func player_grid_to_world_position(
	grid_position: Vector2i
) -> Vector2:

	var world_x: float = (
		PLAYER_GRID_ORIGIN.x
		+ (
			grid_position.y
			* PLAYER_DEPTH_SPACING
		)
	)


	var world_y: float = (
		PLAYER_GRID_ORIGIN.y
		+ (
			grid_position.x
			* PLAYER_LANE_SPACING
		)
	)


	return Vector2(
		world_x,
		world_y
	)


# =========================================================
# OPPONENT GRID TO WORLD
# =========================================================

func enemy_grid_to_world_position(
	grid_position: Vector2i
) -> Vector2:

	var world_x: float = (
		ENEMY_GRID_ORIGIN.x
		- (
			grid_position.y
			* ENEMY_DEPTH_SPACING
		)
	)


	var world_y: float = (
		ENEMY_GRID_ORIGIN.y
		+ (
			grid_position.x
			* ENEMY_LANE_SPACING
		)
	)


	return Vector2(
		world_x,
		world_y
	)


# =========================================================
# RANDOM OPPONENT PLACEMENT
# =========================================================

func create_random_enemy_placement(
	enemy_team: Array
) -> void:

	GameState.enemy_placements.clear()


	var available_cells: Array[Vector2i] = []


	for row in range(
		GRID_ROWS
	):

		for column in range(
			GRID_COLUMNS
		):

			available_cells.append(
				Vector2i(
					column,
					row
				)
			)


	available_cells.shuffle()


	for i in range(
		enemy_team.size()
	):

		var character_data = (
			enemy_team[i]
		)


		var selected_cell: Vector2i = (
			available_cells[i]
		)


		GameState.enemy_placements[
			character_data.character_name
		] = selected_cell


	print("====================")
	print("OPPONENT FORMATION")
	print("====================")


	for character_name in GameState.enemy_placements:

		print(
			character_name,
			" placed at ",
			GameState.enemy_placements[
				character_name
			]
		)


	print("====================")


# =========================================================
# RANDOM ENEMY TEAM CREATION
# =========================================================

func create_random_enemy_team(
	player_team: Array
) -> Array:

	var available_characters = (
		full_roster.duplicate()
	)


	for character in player_team:

		available_characters.erase(
			character
		)


	available_characters.shuffle()


	var enemy_team: Array = []


	for i in range(4):

		enemy_team.append(
			available_characters[i]
		)


	return enemy_team


# =========================================================
# WINNER CHECK
# =========================================================

func check_for_winner() -> void:

	var team_1_alive: int = 0
	var team_2_alive: int = 0


	for character in get_tree().get_nodes_in_group(
		"Characters"
	):

		if not is_instance_valid(
			character
		):
			continue


		if not character.is_alive:
			continue


		if character.team_id == 1:

			team_1_alive += 1


		elif character.team_id == 2:

			team_2_alive += 1


	if (
		team_2_alive == 0
		and team_1_alive > 0
	):

		end_round(
			1
		)


	elif (
		team_1_alive == 0
		and team_2_alive > 0
	):

		end_round(
			2
		)


# =========================================================
# STOP ALL COMBAT PROCESSING
# =========================================================
#
# This runs immediately when a round ends.
#
# It prevents:
#
# - attacks after the winner is decided
# - poison ticks after the winner is decided
# - bleed ticks after the winner is decided
# - movement during the result screen
#
# This fixes the extra HP/DOT lines that were appearing
# after ROUND WIN / MATCH WIN was already printed.
# =========================================================

func stop_all_combat_processing() -> void:

	for character in get_tree().get_nodes_in_group(
		"Characters"
	):

		if not is_instance_valid(
			character
		):
			continue


		# Stop movement.
		character.velocity = Vector2.ZERO


		# Remove any DOT effects that were waiting
		# to activate after combat already ended.
		character.active_dots.clear()


		# Completely stop the character's combat loop.
		character.set_physics_process(
			false
		)


# =========================================================
# END ROUND
# =========================================================

func end_round(
	winning_team: int
) -> void:

	if combat_over:
		return


	# Lock the round immediately.
	combat_over = true


	# Stop all characters before anything else happens.
	stop_all_combat_processing()


	GameState.record_round_winner(
		winning_team
	)


	update_score_label()


	print("====================")


	print(
		"TEAM ",
		winning_team,
		" WINS ROUND ",
		GameState.current_round,
		"!"
	)


	print(
		"SCORE: ",
		GameState.player_round_wins,
		" - ",
		GameState.enemy_round_wins
	)


	print("====================")


	# =====================================================
	# MATCH COMPLETE
	# =====================================================

	if GameState.is_match_over():

		end_match()

		return


	# =====================================================
	# ROUND COMPLETE
	# =====================================================

	winner_label.text = (
		"TEAM "
		+ str(winning_team)
		+ " WINS ROUND "
		+ str(GameState.current_round)
		+ "!"
	)


	winner_label.visible = true


	await get_tree().create_timer(
		2.0
	).timeout


	# =====================================================
	# START BETWEEN-ROUND DECISION PHASE
	# =====================================================

	GameState.start_between_round_phase()


	get_tree().change_scene_to_file(
		"res://Scene/ReplacementSelect.tscn"
	)


# =========================================================
# END MATCH
# =========================================================

func end_match() -> void:

	var match_winner = (
		GameState.get_match_winner()
	)


	print("====================")


	print(
		"TEAM ",
		match_winner,
		" WINS THE MATCH!"
	)


	print("====================")


	winner_label.text = (
		"TEAM "
		+ str(match_winner)
		+ " WINS THE MATCH!\n\n"
		+ str(GameState.player_round_wins)
		+ " - "
		+ str(GameState.enemy_round_wins)
	)


	winner_label.visible = true


	await get_tree().create_timer(
		4.0
	).timeout


	get_tree().change_scene_to_file(
		"res://Scene/MainMenu.tscn"
	)


# =========================================================
# CREATE BATTLE UI
# =========================================================

func create_battle_ui() -> void:

	winner_label = Label.new()

	add_child(
		winner_label
	)


	winner_label.visible = false
	winner_label.text = ""


	winner_label.position = Vector2(
		350,
		60
	)

	winner_label.size = Vector2(
		500,
		140
	)


	winner_label.add_theme_font_size_override(
		"font_size",
		32
	)


	winner_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	winner_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)


	score_label = Label.new()

	add_child(
		score_label
	)


	score_label.position = Vector2(
		430,
		10
	)

	score_label.size = Vector2(
		300,
		50
	)


	score_label.add_theme_font_size_override(
		"font_size",
		22
	)


	score_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	create_battle_ledger()


# =========================================================
# CREATE BATTLE LEDGER
# =========================================================

func create_battle_ledger() -> void:

	ledger_panel = PanelContainer.new()

	add_child(
		ledger_panel
	)


	ledger_panel.position = Vector2(
		320,
		470
	)

	ledger_panel.size = Vector2(
		520,
		155
	)


	ledger_panel.visible = false


	ledger_panel.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)


	var ledger_container = VBoxContainer.new()


	ledger_container.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)


	ledger_panel.add_child(
		ledger_container
	)


	ledger_title_label = Label.new()

	ledger_title_label.text = ""

	ledger_title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	ledger_title_label.add_theme_font_size_override(
		"font_size",
		17
	)

	ledger_title_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	ledger_container.add_child(
		ledger_title_label
	)


	var ledger_columns = HBoxContainer.new()

	ledger_columns.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	ledger_container.add_child(
		ledger_columns
	)


	ledger_stats_label = Label.new()

	ledger_stats_label.text = ""

	ledger_stats_label.custom_minimum_size = Vector2(
		250,
		115
	)

	ledger_stats_label.add_theme_font_size_override(
		"font_size",
		13
	)

	ledger_stats_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	ledger_columns.add_child(
		ledger_stats_label
	)


	ledger_effects_label = Label.new()

	ledger_effects_label.text = ""

	ledger_effects_label.custom_minimum_size = Vector2(
		250,
		115
	)

	ledger_effects_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	ledger_effects_label.add_theme_font_size_override(
		"font_size",
		12
	)

	ledger_effects_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	ledger_columns.add_child(
		ledger_effects_label
	)


# =========================================================
# UPDATE BATTLE LEDGER
# =========================================================

func update_battle_ledger() -> void:

	if selected_battle_character == null:
		return


	if not is_instance_valid(
		selected_battle_character
	):

		if not selected_character_was_defeated:

			selected_character_was_defeated = true


			ledger_title_label.text = (
				last_ledger_title
				+ " - DEFEATED"
			)


			ledger_stats_label.text = (
				last_ledger_stats
			)


			ledger_effects_label.text = (
				last_ledger_effects
			)


		return


	var character = (
		selected_battle_character
	)


	if character.character_data == null:
		return


	var team_text: String = (
		"PLAYER"
	)


	if character.team_id == 2:

		team_text = (
			"OPPONENT"
		)


	var character_name: String = (
		character.get_character_name()
	)


	var title_text: String = (
		character_name
		+ " - "
		+ team_text
	)


	if not character.is_alive:

		title_text += (
			" - DEFEATED"
		)


	ledger_title_label.text = (
		title_text
	)


	# =====================================================
	# CURRENT DAMAGE
	# =====================================================

	var current_damage: int = (
		character.damage
		+ character.fighter_momentum_bonus
		+ character.united_colony_damage_bonus
		+ character.get_temporary_damage_bonus()
	)


	# =====================================================
	# TARGET
	# =====================================================

	var target_name: String = (
		"None"
	)


	if (
		character.target != null
		and is_instance_valid(
			character.target
		)
	):

		if character.target.is_alive:

			target_name = (
				character.target.get_character_name()
			)


	# =====================================================
	# LIVE STATS
	# =====================================================

	var stats_text: String = (
		"Faction: "
		+ character.character_data.faction
		+ "\n"
		+ "Class: "
		+ character.character_data.class_role
		+ "\n"
		+ "HP: "
		+ str(character.current_health)
		+ " / "
		+ str(character.max_health)
		+ "\n"
		+ "Shield: "
		+ str(character.current_shield)
		+ "\n"
		+ "ATK: "
		+ str(current_damage)
		+ "\n"
		+ "Move Speed: "
		+ str(
			snapped(
				character.get_current_move_speed(),
				0.1
			)
		)
		+ "\n"
		+ "Range: "
		+ str(character.attack_range)
		+ "\n"
		+ "Cooldown: "
		+ str(
			snapped(
				character.get_current_attack_cooldown(),
				0.01
			)
		)
		+ " sec"
		+ "\n"
		+ "Target: "
		+ target_name
	)


	ledger_stats_label.text = (
		stats_text
	)


	var effects_text: String = (
		get_live_effect_text(
			character
		)
	)


	ledger_effects_label.text = (
		effects_text
	)


	last_ledger_title = (
		title_text
	)

	last_ledger_stats = (
		stats_text
	)

	last_ledger_effects = (
		effects_text
	)


# =========================================================
# LIVE EFFECT TEXT
# =========================================================

func get_live_effect_text(
	character: Node
) -> String:

	var lines: Array[String] = []


	var faction_name: String = (
		character.character_data.faction
	)


	# =====================================================
	# BASIC STARTING ABILITY
	# =====================================================

	var basic_id: String = (
		character.character_data.basic_ability_id
	)


	if basic_id != "":

		var basic_ability: Dictionary = (
			UpgradeDatabase.get_basic_ability(
				basic_id
			)
		)


		if not basic_ability.is_empty():

			if basic_ability.has(
				"name"
			):

				lines.append(
					"BASIC: "
					+ str(
						basic_ability["name"]
					)
				)


	# =====================================================
	# FACTION SYNERGY
	# =====================================================

	if faction_name == "Vesper":

		if character.faction_synergy_tier >= 4:

			lines.append(
				"TRAIT: Hive Mind"
			)

		elif character.faction_synergy_tier >= 2:

			lines.append(
				"TRAIT: Hive Bond"
			)


	elif faction_name == "Anttalope":

		if character.faction_synergy_tier >= 4:

			lines.append(
				"TRAIT: Perfect Hunt"
			)

		elif character.faction_synergy_tier >= 2:

			lines.append(
				"TRAIT: Hunter's Focus"
			)


	elif faction_name == "Lepidra":

		if character.faction_synergy_tier >= 4:

			lines.append(
				"TRAIT: Lunar Veil"
			)

		elif character.faction_synergy_tier >= 2:

			lines.append(
				"TRAIT: Veil of Dust"
			)


	elif faction_name == "Formicara":

		if character.faction_synergy_tier >= 4:

			lines.append(
				"TRAIT: United Colony"
			)

		elif character.faction_synergy_tier >= 2:

			lines.append(
				"TRAIT: Colony Discipline"
			)


	elif faction_name == "Caraphex":

		if character.faction_synergy_tier >= 4:

			lines.append(
				"TRAIT: Last Shell"
			)

		elif character.faction_synergy_tier >= 2:

			lines.append(
				"TRAIT: Reinforced Carapace"
			)


	elif faction_name == "Scolyra":

		if character.faction_synergy_tier >= 4:

			lines.append(
				"TRAIT: Predatory Frenzy"
			)

		elif character.faction_synergy_tier >= 2:

			lines.append(
				"TRAIT: Venomous Assault"
			)


	# =====================================================
	# CLASS SYNERGY
	# =====================================================

	if character.class_synergy_tier >= 2:

		var role_name: String = (
			character.character_data.class_role
		)


		if role_name == "Vanguard":

			if character.class_synergy_tier >= 4:

				lines.append(
					"CLASS: Fortress"
				)

			else:

				lines.append(
					"CLASS: Bulwark"
				)


		elif role_name == "Fighter":

			if character.class_synergy_tier >= 4:

				lines.append(
					"CLASS: War Machine"
				)

			else:

				lines.append(
					"CLASS: Battle Momentum"
				)


		elif role_name == "Assassin":

			if character.class_synergy_tier >= 4:

				lines.append(
					"CLASS: Execution Protocol"
				)

			else:

				lines.append(
					"CLASS: Shadow Rush"
				)


		elif role_name == "Marksman":

			if character.class_synergy_tier >= 4:

				lines.append(
					"CLASS: Deadeye"
				)

			else:

				lines.append(
					"CLASS: Steady Aim"
				)


		elif role_name == "Support":

			if character.class_synergy_tier >= 4:

				lines.append(
					"CLASS: Overwhelming Presence"
				)

			else:

				lines.append(
					"CLASS: Inspiring Presence"
				)


	# =====================================================
	# SUPPORT TEAM BUFF
	# =====================================================

	if character.support_synergy_tier >= 4:

		lines.append(
			"BUFF: Overwhelming Presence +10% AS"
		)


	elif character.support_synergy_tier >= 2:

		lines.append(
			"BUFF: Inspiring Presence +5% AS"
		)


	# =====================================================
	# FIGHTER MOMENTUM
	# =====================================================

	if character.fighter_momentum_bonus > 0:

		var momentum_name: String = (
			"Battle Momentum"
		)


		if character.class_synergy_tier >= 4:

			momentum_name = (
				"War Machine"
			)


		lines.append(
			momentum_name
			+ ": +"
			+ str(
				character.fighter_momentum_bonus
			)
			+ " ATK"
		)


	# =====================================================
	# MARKSMAN STACKS
	# =====================================================

	if character.steady_aim_stacks > 0:

		var aim_name: String = (
			"Steady Aim"
		)


		if character.class_synergy_tier >= 4:

			aim_name = (
				"Deadeye"
			)


		lines.append(
			aim_name
			+ ": "
			+ str(
				character.steady_aim_stacks
			)
			+ "/4 stacks"
		)


	# =====================================================
	# SHIELD
	# =====================================================

	if character.current_shield > 0:

		lines.append(
			"Shield: "
			+ str(
				character.current_shield
			)
			+ " HP"
		)


	# =====================================================
	# GENERIC DAMAGE BUFFS
	# =====================================================

	if character.damage_buffs.size() > 0:

		lines.append(
			"Temporary Damage Buff Active"
		)


	# =====================================================
	# GENERIC MOVE SPEED BUFFS
	# =====================================================

	if character.move_speed_buffs.size() > 0:

		lines.append(
			"Movement Speed Buff Active"
		)


	# =====================================================
	# GENERIC ATTACK SPEED BUFFS
	# =====================================================

	if character.attack_speed_buffs.size() > 0:

		lines.append(
			"Attack Speed Buff Active"
		)


	# =====================================================
	# DAMAGE REDUCTION BUFFS
	# =====================================================

	if character.damage_reduction_buffs.size() > 0:

		lines.append(
			"Damage Reduction Active"
		)


	# =====================================================
	# MOVEMENT SLOW
	# =====================================================

	if character.move_slow_effects.size() > 0:

		lines.append(
			"Movement Slow Active"
		)


	# =====================================================
	# ATTACK SPEED SLOW
	# =====================================================

	if character.attack_slow_effects.size() > 0:

		lines.append(
			"Attack Speed Slow Active"
		)


	# =====================================================
	# DAMAGE OVER TIME
	# =====================================================

	if character.active_dots.size() > 0:

		lines.append(
			"Damage Over Time Active"
		)


	# =====================================================
	# CORRODED
	# =====================================================

	if character.corrosion_timer > 0:

		lines.append(
			"Corroded"
		)


	# =====================================================
	# MARKED
	# =====================================================

	if character.marked_timer > 0:

		lines.append(
			"Marked"
		)


	# =====================================================
	# UNITED COLONY
	# =====================================================

	if character.united_colony_damage_bonus > 0:

		lines.append(
			"United Colony: +"
			+ str(
				character.united_colony_damage_bonus
			)
			+ " ATK"
		)


	# =====================================================
	# PLAYER UPGRADES
	# =====================================================

	if character.team_id == 1:

		var character_name: String = (
			character.get_character_name()
		)


		if GameState.character_upgrades.has(
			character_name
		):

			var upgrades = (
				GameState.character_upgrades[
					character_name
				]
			)


			if upgrades.size() > 0:

				var upgrade_names: Array[String] = []


				for upgrade in upgrades:

					if upgrade.has(
						"name"
					):

						upgrade_names.append(
							str(
								upgrade["name"]
							)
						)


				if upgrade_names.size() > 0:

					lines.append(
						"UPGRADES: "
						+ ", ".join(
							upgrade_names
						)
					)


	else:

		lines.append(
			"UPGRADES: None"
		)


	if lines.size() == 0:

		return (
			"No active effects."
		)


	return (
		"\n".join(
			lines
		)
	)


# =========================================================
# SCORE DISPLAY
# =========================================================

func update_score_label() -> void:

	score_label.text = (
		"ROUND "
		+ str(GameState.current_round)
		+ "     "
		+ str(GameState.player_round_wins)
		+ " - "
		+ str(GameState.enemy_round_wins)
	)
