extends Control


# =========================================================
# GRID SETTINGS
# =========================================================

# Player placement area.
#
# 4 columns wide
# 5 rows deep.
const GRID_COLUMNS: int = 4
const GRID_ROWS: int = 5

const TOTAL_GRID_SPACES: int = (
	GRID_COLUMNS
	* GRID_ROWS
)


# =========================================================
# PLACEMENT TIMER
# =========================================================

# Players have 15 seconds to adjust
# their formation before combat begins.
const PLACEMENT_TIME_LIMIT: float = 15.0


var placement_time_left: float = (
	PLACEMENT_TIME_LIMIT
)


var placement_timer_active: bool = true


# Prevents the timer and START ROUND
# button from launching combat twice.
var round_starting: bool = false


# =========================================================
# COOLDOWN SETTINGS
# =========================================================

# Equipment and attack-speed effects can never
# reduce the final cooldown below this amount.
const MIN_ATTACK_COOLDOWN: float = 0.25


# =========================================================
# PLACEMENT STATE
# =========================================================

var selected_character: CharacterData = null


# Stores which character occupies each LOGICAL grid cell.
#
# Logical rows:
#
# Row 0 = BACK
# Row 1
# Row 2
# Row 3
# Row 4 = FRONT
#
# The display is flipped so FRONT appears
# visually at the top of the screen.
var occupied_cells: Dictionary = {}


# Stores grid buttons using their
# logical battlefield positions.
var grid_buttons: Dictionary = {}


# Stores the four bench buttons.
var character_buttons: Dictionary = {}


# =========================================================
# UI REFERENCES
# =========================================================

var selected_label: Label
var placement_count_label: Label
var start_round_button: Button

var trait_bar_label: Label

var placement_timer_label: Label


# Character ledger.
var ledger_title: Label
var ledger_info: Label
var ledger_traits: Label
var ledger_upgrades: Label


# =========================================================
# STARTUP
# =========================================================

func _ready() -> void:

	if GameState.selected_team.size() != 4:

		print(
			"Placement Error: Player does not have 4 characters."
		)

		return


	placement_time_left = (
		PLACEMENT_TIME_LIMIT
	)

	placement_timer_active = true

	round_starting = false


	create_placement_ui()

	load_saved_placement()

	update_placement_ui()

	update_placement_timer_display()


# =========================================================
# PROCESS
# =========================================================

func _process(
	delta: float
) -> void:

	if round_starting:
		return


	if not placement_timer_active:
		return


	placement_time_left -= delta


	if placement_time_left <= 0.0:

		placement_time_left = 0.0

		placement_timer_active = false


		update_placement_timer_display()


		handle_placement_timeout()

		return


	update_placement_timer_display()


# =========================================================
# CREATE PLACEMENT UI
# =========================================================

func create_placement_ui() -> void:

	# =====================================================
	# LEFT SIDE - PLACEMENT
	# =====================================================

	var main_container = VBoxContainer.new()

	add_child(
		main_container
	)


	# Move the entire placement UI closer
	# to the top of the screen.
	main_container.position = Vector2(
		30,
		5
	)


	main_container.size = Vector2(
		740,
		625
	)


	# =========================
	# TITLE
	# =========================

	var title = Label.new()

	title.text = (
		"ROUND "
		+ str(GameState.current_round)
		+ " - PLACE YOUR TEAM"
	)

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		25
	)

	main_container.add_child(
		title
	)


	# =========================
	# SCORE
	# =========================

	var score_label = Label.new()

	score_label.text = (
		"SCORE: "
		+ str(GameState.player_round_wins)
		+ " - "
		+ str(GameState.enemy_round_wins)
	)

	score_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	score_label.add_theme_font_size_override(
		"font_size",
		17
	)

	main_container.add_child(
		score_label
	)


	# =========================
	# PLACEMENT TIMER
	# =========================

	placement_timer_label = Label.new()

	placement_timer_label.text = (
		"PLACEMENT TIME: 15s"
	)

	placement_timer_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	placement_timer_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main_container.add_child(
		placement_timer_label
	)


	# =========================
	# SELECTED CHARACTER
	# =========================

	selected_label = Label.new()

	selected_label.text = (
		"Select a character"
	)

	selected_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	selected_label.add_theme_font_size_override(
		"font_size",
		16
	)

	main_container.add_child(
		selected_label
	)


	# =========================
	# ACTIVE TRAITS
	# =========================

	trait_bar_label = Label.new()

	trait_bar_label.text = (
		"ACTIVE TRAITS: None"
	)

	trait_bar_label.custom_minimum_size = Vector2(
		720,
		26
	)

	trait_bar_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	trait_bar_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	trait_bar_label.add_theme_font_size_override(
		"font_size",
		14
	)

	main_container.add_child(
		trait_bar_label
	)


	# =========================
	# FRONT LABEL
	# =========================

	var front_label = Label.new()

	front_label.text = (
		"FRONT"
	)

	front_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	front_label.add_theme_font_size_override(
		"font_size",
		13
	)

	main_container.add_child(
		front_label
	)


	# =====================================================
	# PLACEMENT GRID
	# =====================================================

	var grid = GridContainer.new()

	grid.columns = GRID_COLUMNS

	main_container.add_child(
		grid
	)


	# =====================================================
	# FLIPPED DISPLAY ORDER
	# =====================================================

	for display_row in range(
		GRID_ROWS
	):

		var logical_row: int = (
			GRID_ROWS
			- 1
			- display_row
		)


		for column in range(
			GRID_COLUMNS
		):

			var cell_position = Vector2i(
				column,
				logical_row
			)


			var grid_button = Button.new()


			# Reduced height so all five rows
			# fit comfortably on-screen.
			grid_button.custom_minimum_size = Vector2(
				175,
				48
			)


			grid_button.text = (
				"EMPTY"
			)


			grid_button.pressed.connect(
				_on_grid_button_pressed.bind(
					cell_position
				)
			)


			grid.add_child(
				grid_button
			)


			grid_buttons[
				cell_position
			] = grid_button


	# =========================
	# BACK LABEL
	# =========================

	var back_label = Label.new()

	back_label.text = (
		"BACK"
	)

	back_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	back_label.add_theme_font_size_override(
		"font_size",
		13
	)

	main_container.add_child(
		back_label
	)


	# =========================
	# PLACEMENT COUNT
	# =========================

	placement_count_label = Label.new()

	placement_count_label.text = (
		"Placed: 0 / 4"
	)

	placement_count_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	placement_count_label.add_theme_font_size_override(
		"font_size",
		15
	)

	main_container.add_child(
		placement_count_label
	)


	# =========================
	# CHARACTER BENCH
	# =========================

	var bench_title = Label.new()

	bench_title.text = (
		"YOUR TEAM"
	)

	bench_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	bench_title.add_theme_font_size_override(
		"font_size",
		16
	)

	main_container.add_child(
		bench_title
	)


	var bench_container = HBoxContainer.new()

	main_container.add_child(
		bench_container
	)


	for character in GameState.selected_team:

		var character_button = Button.new()


		# Slightly shorter to save vertical space.
		character_button.custom_minimum_size = Vector2(
			175,
			48
		)


		character_button.text = (
			character.character_name
			+ "\n"
			+ character.class_role
		)


		character_button.pressed.connect(
			_on_character_button_pressed.bind(
				character
			)
		)


		bench_container.add_child(
			character_button
		)


		character_buttons[
			character.character_name
		] = character_button


	# =========================
	# START ROUND BUTTON
	# =========================

	start_round_button = Button.new()

	start_round_button.text = (
		"START ROUND"
	)

	start_round_button.custom_minimum_size = Vector2(
		250,
		38
	)

	start_round_button.disabled = true


	start_round_button.pressed.connect(
		_on_start_round_pressed
	)


	main_container.add_child(
		start_round_button
	)


	# =====================================================
	# RIGHT SIDE - CHARACTER LEDGER
	# =====================================================

	create_character_ledger()


# =========================================================
# CREATE CHARACTER LEDGER
# =========================================================

func create_character_ledger() -> void:

	# =====================================================
	# OUTER PANEL
	# =====================================================

	var ledger_panel = PanelContainer.new()

	add_child(
		ledger_panel
	)


	ledger_panel.position = Vector2(
		790,
		30
	)

	ledger_panel.size = Vector2(
		330,
		565
	)


	# =====================================================
	# OUTER CONTAINER
	# =====================================================

	var outer_ledger_container = VBoxContainer.new()

	ledger_panel.add_child(
		outer_ledger_container
	)


	# =====================================================
	# FIXED HEADER
	# =====================================================

	var panel_header = Label.new()

	panel_header.text = (
		"CHARACTER LEDGER"
	)

	panel_header.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	panel_header.add_theme_font_size_override(
		"font_size",
		22
	)

	outer_ledger_container.add_child(
		panel_header
	)


	# =====================================================
	# SCROLL CONTAINER
	# =====================================================

	var ledger_scroll = ScrollContainer.new()


	ledger_scroll.custom_minimum_size = Vector2(
		315,
		515
	)


	ledger_scroll.horizontal_scroll_mode = (
		ScrollContainer.SCROLL_MODE_DISABLED
	)


	ledger_scroll.vertical_scroll_mode = (
		ScrollContainer.SCROLL_MODE_AUTO
	)


	outer_ledger_container.add_child(
		ledger_scroll
	)


	# =====================================================
	# SCROLLABLE CONTENT
	# =====================================================

	var ledger_container = VBoxContainer.new()


	ledger_container.custom_minimum_size = Vector2(
		295,
		0
	)


	ledger_scroll.add_child(
		ledger_container
	)


	# =====================================================
	# CHARACTER NAME
	# =====================================================

	ledger_title = Label.new()

	ledger_title.text = (
		"Select a character"
	)

	ledger_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	ledger_title.add_theme_font_size_override(
		"font_size",
		20
	)

	ledger_container.add_child(
		ledger_title
	)


	# =========================
	# BASIC STATS
	# =========================

	var stats_header = Label.new()

	stats_header.text = (
		"STATS"
	)

	stats_header.add_theme_font_size_override(
		"font_size",
		16
	)

	ledger_container.add_child(
		stats_header
	)


	ledger_info = Label.new()

	ledger_info.text = (
		"Click a character to view stats."
	)


	ledger_info.custom_minimum_size = Vector2(
		285,
		135
	)


	ledger_info.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)


	ledger_info.add_theme_font_size_override(
		"font_size",
		15
	)

	ledger_container.add_child(
		ledger_info
	)


	# =========================
	# TRAITS
	# =========================

	var traits_header = Label.new()

	traits_header.text = (
		"ACTIVE TRAITS"
	)

	traits_header.add_theme_font_size_override(
		"font_size",
		16
	)

	ledger_container.add_child(
		traits_header
	)


	ledger_traits = Label.new()

	ledger_traits.text = (
		"None"
	)


	ledger_traits.custom_minimum_size = Vector2(
		285,
		95
	)


	ledger_traits.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)


	ledger_traits.add_theme_font_size_override(
		"font_size",
		14
	)

	ledger_container.add_child(
		ledger_traits
	)


	# =========================
	# UPGRADES
	# =========================

	var upgrades_header = Label.new()

	upgrades_header.text = (
		"UPGRADES"
	)

	upgrades_header.add_theme_font_size_override(
		"font_size",
		16
	)

	ledger_container.add_child(
		upgrades_header
	)


	ledger_upgrades = Label.new()

	ledger_upgrades.text = (
		"None"
	)


	ledger_upgrades.custom_minimum_size = Vector2(
		285,
		95
	)


	ledger_upgrades.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)


	ledger_upgrades.add_theme_font_size_override(
		"font_size",
		14
	)

	ledger_container.add_child(
		ledger_upgrades
	)


# =========================================================
# UPDATE CHARACTER LEDGER
# =========================================================

func update_character_ledger(
	character: CharacterData
) -> void:

	if character == null:
		return


	ledger_title.text = (
		character.character_name
	)


	var preview_health: int = (
		character.max_health
	)

	var preview_damage: int = (
		character.damage
	)

	var preview_speed: float = (
		character.move_speed
	)

	var preview_range: float = (
		character.attack_range
	)

	var preview_cooldown: float = (
		character.attack_cooldown
	)


	var upgrades: Array = []


	if GameState.character_upgrades.has(
		character.character_name
	):

		upgrades = (
			GameState.character_upgrades[
				character.character_name
			]
		)


		for upgrade in upgrades:

			if upgrade.has(
				"health_bonus"
			):

				preview_health += (
					upgrade[
						"health_bonus"
					]
				)


			if upgrade.has(
				"damage_bonus"
			):

				preview_damage += (
					upgrade[
						"damage_bonus"
					]
				)


			if upgrade.has(
				"move_speed_bonus"
			):

				preview_speed += (
					upgrade[
						"move_speed_bonus"
					]
				)


			if upgrade.has(
				"range_bonus"
			):

				preview_range += (
					upgrade[
						"range_bonus"
					]
				)


			if upgrade.has(
				"cooldown_reduction"
			):

				preview_cooldown -= (
					upgrade[
						"cooldown_reduction"
					]
				)


				preview_cooldown = max(
					MIN_ATTACK_COOLDOWN,
					preview_cooldown
				)


			if upgrade.has(
				"cooldown_multiplier"
			):

				preview_cooldown *= (
					upgrade[
						"cooldown_multiplier"
					]
				)


				preview_cooldown = max(
					MIN_ATTACK_COOLDOWN,
					preview_cooldown
				)


	preview_cooldown = max(
		MIN_ATTACK_COOLDOWN,
		preview_cooldown
	)


	ledger_info.text = (
		"Faction: "
		+ character.faction
		+ "\n"
		+ "Class: "
		+ character.class_role
		+ "\n\n"
		+ "HP: "
		+ str(preview_health)
		+ " / "
		+ str(preview_health)
		+ "\n"
		+ "ATK: "
		+ str(preview_damage)
		+ "\n"
		+ "Move Speed: "
		+ str(preview_speed)
		+ "\n"
		+ "Range: "
		+ str(preview_range)
		+ "\n"
		+ "Attack Cooldown: "
		+ "%.2f" % preview_cooldown
		+ " sec"
	)


	ledger_traits.text = (
		get_character_trait_text(
			character
		)
	)


	if upgrades.size() == 0:

		ledger_upgrades.text = (
			"None"
		)

	else:

		var upgrade_lines: Array[String] = []


		for upgrade in upgrades:

			if upgrade.has(
				"name"
			):

				upgrade_lines.append(
					"• "
					+ str(
						upgrade[
							"name"
						]
					)
				)


		ledger_upgrades.text = (
			"\n".join(
				upgrade_lines
			)
		)


# =========================================================
# CHARACTER TRAIT TEXT
# =========================================================

func get_character_trait_text(
	character: CharacterData
) -> String:

	var lines: Array[String] = []


	# =====================================================
	# FACTION COUNT
	# =====================================================

	var faction_count: int = 0


	for teammate in GameState.selected_team:

		if teammate.faction == character.faction:

			faction_count += 1


	# =====================================================
	# VESPER
	# =====================================================

	if (
		character.faction == "Vesper"
		and faction_count >= 4
	):

		lines.append(
			"• Hive Mind"
		)

		lines.append(
			"  +10% Attack Speed"
		)

		lines.append(
			"  Heal 3 HP every 4 sec"
		)


	elif (
		character.faction == "Vesper"
		and faction_count >= 2
	):

		lines.append(
			"• Hive Bond"
		)

		lines.append(
			"  +5% Attack Speed"
		)


	# =====================================================
	# ANTTALOPE
	# =====================================================

	elif (
		character.faction == "Anttalope"
		and faction_count >= 4
	):

		lines.append(
			"• Perfect Hunt"
		)

		lines.append(
			"  +4 damage on new targets"
		)

		lines.append(
			"  +4 sustained-target damage"
		)


	elif (
		character.faction == "Anttalope"
		and faction_count >= 2
	):

		lines.append(
			"• Hunter's Focus"
		)

		lines.append(
			"  +2 sustained-target damage"
		)


	# =====================================================
	# LEPIDRA
	# =====================================================

	elif (
		character.faction == "Lepidra"
		and faction_count >= 4
	):

		lines.append(
			"• Lunar Veil"
		)

		lines.append(
			"  First 2 hits take 25% less damage"
		)

		lines.append(
			"  Protected hit grants +15 Move Speed"
		)


	elif (
		character.faction == "Lepidra"
		and faction_count >= 2
	):

		lines.append(
			"• Veil of Dust"
		)

		lines.append(
			"  First 2 hits take 15% less damage"
		)


	# =====================================================
	# FORMICARA
	# =====================================================

	elif (
		character.faction == "Formicara"
		and faction_count >= 4
	):

		lines.append(
			"• United Colony"
		)

		lines.append(
			"  -3 incoming damage"
		)

		lines.append(
			"  +2 ATK when a Formicara ally dies"
		)


	elif (
		character.faction == "Formicara"
		and faction_count >= 2
	):

		lines.append(
			"• Colony Discipline"
		)

		lines.append(
			"  -2 incoming damage"
		)


	# =====================================================
	# CARAPHEX
	# =====================================================

	elif (
		character.faction == "Caraphex"
		and faction_count >= 4
	):

		lines.append(
			"• Last Shell"
		)

		lines.append(
			"  +25% Max HP"
		)

		lines.append(
			"  Below 30% HP: gain 20% Max HP shield"
		)


	elif (
		character.faction == "Caraphex"
		and faction_count >= 2
	):

		lines.append(
			"• Reinforced Carapace"
		)

		lines.append(
			"  +15% Max HP"
		)


	# =====================================================
	# SCOLYRA
	# =====================================================

	elif (
		character.faction == "Scolyra"
		and faction_count >= 4
	):

		lines.append(
			"• Predatory Frenzy"
		)

		lines.append(
			"  +2 damage per Venom stack"
		)

		lines.append(
			"  Max 5 stacks / +15% Attack Speed"
		)


	elif (
		character.faction == "Scolyra"
		and faction_count >= 2
	):

		lines.append(
			"• Venomous Assault"
		)

		lines.append(
			"  +1 damage per Venom stack"
		)

		lines.append(
			"  Maximum 5 stacks"
		)


	# =====================================================
	# CLASS COUNT
	# =====================================================

	var class_count: int = 0


	for teammate in GameState.selected_team:

		if (
			teammate.class_role
			== character.class_role
		):

			class_count += 1


	# =====================================================
	# VANGUARD
	# =====================================================

	if (
		character.class_role == "Vanguard"
		and class_count >= 4
	):

		lines.append(
			"• Fortress"
		)

		lines.append(
			"  +50 Max HP / -4 Damage"
		)

		lines.append(
			"  Below 40% HP: gain 30 Shield"
		)


	elif (
		character.class_role == "Vanguard"
		and class_count >= 2
	):

		lines.append(
			"• Bulwark"
		)

		lines.append(
			"  +25 HP / -2 Damage"
		)


	# =====================================================
	# FIGHTER
	# =====================================================

	elif (
		character.class_role == "Fighter"
		and class_count >= 4
	):

		lines.append(
			"• War Machine"
		)

		lines.append(
			"  +2 ATK every 3 sec"
		)

		lines.append(
			"  Maximum +10 ATK"
		)

		lines.append(
			"  At max stacks: +15% Attack Speed"
		)


	elif (
		character.class_role == "Fighter"
		and class_count >= 2
	):

		lines.append(
			"• Battle Momentum"
		)

		lines.append(
			"  +1 ATK every 3 sec"
		)

		lines.append(
			"  Maximum +5 ATK"
		)


	# =====================================================
	# ASSASSIN
	# =====================================================

	elif (
		character.class_role == "Assassin"
		and class_count >= 4
	):

		lines.append(
			"• Execution Protocol"
		)

		lines.append(
			"  +30 Move Speed"
		)

		lines.append(
			"  +8 damage against new targets"
		)

		lines.append(
			"  +25% damage below 30% enemy HP"
		)


	elif (
		character.class_role == "Assassin"
		and class_count >= 2
	):

		lines.append(
			"• Shadow Rush"
		)

		lines.append(
			"  +20 Move Speed"
		)

		lines.append(
			"  +4 damage against new targets"
		)


	# =====================================================
	# MARKSMAN
	# =====================================================

	elif (
		character.class_role == "Marksman"
		and class_count >= 4
	):

		lines.append(
			"• Deadeye"
		)

		lines.append(
			"  Up to +30% Attack Speed"
		)

		lines.append(
			"  Max stacks: +20% basic attack damage"
		)


	elif (
		character.class_role == "Marksman"
		and class_count >= 2
	):

		lines.append(
			"• Steady Aim"
		)

		lines.append(
			"  Up to +20% Attack Speed"
		)


	# =====================================================
	# SUPPORT
	# =====================================================

	elif (
		character.class_role == "Support"
		and class_count >= 4
	):

		lines.append(
			"• Overwhelming Presence"
		)

		lines.append(
			"  Support effects +50%"
		)

		lines.append(
			"  Periodically shield lowest-HP ally"
		)


	elif (
		character.class_role == "Support"
		and class_count >= 2
	):

		lines.append(
			"• Inspiring Presence"
		)

		lines.append(
			"  Support effects +25%"
		)


	# =====================================================
	# TEAM SUPPORT BUFF
	# =====================================================

	var support_count: int = 0


	for teammate in GameState.selected_team:

		if teammate.class_role == "Support":

			support_count += 1


	if support_count >= 4:

		lines.append(
			"• Overwhelming Presence Team Buff"
		)

		lines.append(
			"  +10% Attack Speed"
		)


	elif support_count >= 2:

		lines.append(
			"• Inspiring Presence Team Buff"
		)

		lines.append(
			"  +5% Attack Speed"
		)


	if lines.size() == 0:

		return (
			"None"
		)


	return (
		"\n".join(
			lines
		)
	)


# =========================================================
# UPDATE TRAIT BAR
# =========================================================

func update_trait_bar() -> void:

	if trait_bar_label == null:
		return


	# =====================================================
	# FACTION COUNTS
	# =====================================================

	var faction_counts: Dictionary = {}


	for character in GameState.selected_team:

		var faction_name: String = (
			character.faction
		)


		if faction_name == "":
			continue


		if not faction_counts.has(
			faction_name
		):

			faction_counts[
				faction_name
			] = 0


		faction_counts[
			faction_name
		] += 1


	# =====================================================
	# CLASS COUNTS
	# =====================================================

	var class_counts: Dictionary = {}


	for character in GameState.selected_team:

		var role_name: String = (
			character.class_role
		)


		if role_name == "":
			continue


		if not class_counts.has(
			role_name
		):

			class_counts[
				role_name
			] = 0


		class_counts[
			role_name
		] += 1


	var active_traits: Array[String] = []


	# =====================================================
	# FACTION TRAIT DISPLAY
	# =====================================================

	for faction_name in faction_counts:

		var faction_count: int = (
			faction_counts[
				faction_name
			]
		)


		if faction_count >= 2:

			active_traits.append(
				str(faction_name)
				+ " "
				+ str(faction_count)
				+ "/4"
			)


	# =====================================================
	# CLASS TRAIT DISPLAY
	# =====================================================

	for role_name in class_counts:

		var role_count: int = (
			class_counts[
				role_name
			]
		)


		if role_count >= 2:

			active_traits.append(
				str(role_name)
				+ " "
				+ str(role_count)
				+ "/4"
			)


	if active_traits.size() == 0:

		trait_bar_label.text = (
			"ACTIVE TRAITS: None"
		)

		return


	var trait_text: String = (
		"   |   ".join(
			active_traits
		)
	)


	trait_bar_label.text = (
		"ACTIVE TRAITS: "
		+ trait_text
	)


# =========================================================
# SELECT CHARACTER FROM BENCH
# =========================================================

func _on_character_button_pressed(
	character: CharacterData
) -> void:

	if round_starting:
		return


	selected_character = (
		character
	)


	selected_label.text = (
		"Placing: "
		+ character.character_name
	)


	update_character_ledger(
		character
	)


	update_placement_ui()


# =========================================================
# GRID BUTTON PRESSED
# =========================================================

func _on_grid_button_pressed(
	cell_position: Vector2i
) -> void:

	if round_starting:
		return


	if selected_character == null:

		if occupied_cells.has(
			cell_position
		):

			var occupant: CharacterData = (
				occupied_cells[
					cell_position
				]
			)


			selected_character = (
				occupant
			)


			selected_label.text = (
				"Placing: "
				+ occupant.character_name
			)


			update_character_ledger(
				occupant
			)


			update_placement_ui()

			return


		selected_label.text = (
			"Select a character first."
		)

		return


	if occupied_cells.has(
		cell_position
	):

		var occupant = (
			occupied_cells[
				cell_position
			]
		)


		if occupant == selected_character:

			update_character_ledger(
				occupant
			)

			return


		selected_label.text = (
			"That space is already occupied."
		)

		return


	var old_position = (
		find_character_position(
			selected_character
		)
	)


	if old_position != Vector2i(
		-1,
		-1
	):

		occupied_cells.erase(
			old_position
		)


	occupied_cells[
		cell_position
	] = selected_character


	GameState.player_placements[
		selected_character.character_name
	] = cell_position


	update_character_ledger(
		selected_character
	)


	selected_label.text = (
		selected_character.character_name
		+ " placed."
	)


	selected_character = null


	update_placement_ui()


# =========================================================
# FIND CHARACTER POSITION
# =========================================================

func find_character_position(
	character: CharacterData
) -> Vector2i:

	for cell_position in occupied_cells.keys():

		if (
			occupied_cells[
				cell_position
			]
			== character
		):

			return cell_position


	return Vector2i(
		-1,
		-1
	)


# =========================================================
# RESTORE SAVED FORMATION
# =========================================================

func load_saved_placement() -> void:

	for character in GameState.selected_team:

		var character_name = (
			character.character_name
		)


		if GameState.player_placements.has(
			character_name
		):

			var saved_position = (
				GameState.player_placements[
					character_name
				]
			)


			occupied_cells[
				saved_position
			] = character


# =========================================================
# UPDATE PLACEMENT UI
# =========================================================

func update_placement_ui() -> void:

	update_trait_bar()


	for cell_position in grid_buttons.keys():

		var button = (
			grid_buttons[
				cell_position
			]
		)


		if occupied_cells.has(
			cell_position
		):

			var character = (
				occupied_cells[
					cell_position
				]
			)


			button.text = (
				character.character_name
				+ "\n"
				+ character.class_role
			)


		else:

			button.text = (
				"EMPTY"
			)


	for character in GameState.selected_team:

		var button = (
			character_buttons[
				character.character_name
			]
		)


		var character_position = (
			find_character_position(
				character
			)
		)


		if character_position != Vector2i(
			-1,
			-1
		):

			button.text = (
				character.character_name
				+ "\nPLACED"
			)


		else:

			button.text = (
				character.character_name
				+ "\n"
				+ character.class_role
			)


	if selected_character != null:

		selected_label.text = (
			"Placing: "
			+ selected_character.character_name
		)


	var placed_count = (
		occupied_cells.size()
	)


	placement_count_label.text = (
		"Placed: "
		+ str(placed_count)
		+ " / 4"
	)


	start_round_button.disabled = (
		placed_count != 4
		or round_starting
	)


# =========================================================
# PLACEMENT TIMER DISPLAY
# =========================================================

func update_placement_timer_display() -> void:

	if placement_timer_label == null:
		return


	var seconds_left: int = (
		int(
			ceil(
				placement_time_left
			)
		)
	)


	placement_timer_label.text = (
		"PLACEMENT TIME: "
		+ str(seconds_left)
		+ "s"
	)


# =========================================================
# PLACEMENT TIMER EXPIRED
# =========================================================

func handle_placement_timeout() -> void:

	if round_starting:
		return


	print("====================")
	print("PLACEMENT TIMER EXPIRED")
	print("====================")


	# Only characters who are not already placed
	# will be assigned automatically.
	auto_place_unplaced_characters()


	update_placement_ui()


	start_round()


# =========================================================
# AUTO-PLACE UNPLACED CHARACTERS
# =========================================================

func auto_place_unplaced_characters() -> void:

	var available_cells: Array[Vector2i] = []


	for row in range(
		GRID_ROWS
	):

		for column in range(
			GRID_COLUMNS
		):

			var cell_position = Vector2i(
				column,
				row
			)


			if not occupied_cells.has(
				cell_position
			):

				available_cells.append(
					cell_position
				)


	available_cells.shuffle()


	var available_index: int = 0


	for character in GameState.selected_team:

		var current_position = (
			find_character_position(
				character
			)
		)


		if current_position != Vector2i(
			-1,
			-1
		):

			continue


		if available_index >= available_cells.size():
			break


		var selected_cell: Vector2i = (
			available_cells[
				available_index
			]
		)


		available_index += 1


		occupied_cells[
			selected_cell
		] = character


		GameState.player_placements[
			character.character_name
		] = selected_cell


		print(
			"Auto-placed ",
			character.character_name,
			" at ",
			selected_cell
		)


# =========================================================
# START ROUND BUTTON
# =========================================================

func _on_start_round_pressed() -> void:

	if round_starting:
		return


	if occupied_cells.size() != 4:
		return


	start_round()


# =========================================================
# START ROUND
# =========================================================

func start_round() -> void:

	if round_starting:
		return


	if occupied_cells.size() != 4:

		auto_place_unplaced_characters()


	if occupied_cells.size() != 4:

		print(
			"Placement Error: Could not place all 4 characters."
		)

		return


	round_starting = true

	placement_timer_active = false


	start_round_button.disabled = true


	print("====================")
	print("PLAYER FORMATION")
	print("====================")


	for character_name in GameState.player_placements:

		print(
			character_name,
			" placed at ",
			GameState.player_placements[
				character_name
			]
		)


	# =====================================================
	# DEV ENEMY SELECT
	# =====================================================

	if GameState.current_round == 1:

		get_tree().change_scene_to_file(
			"res://enemy_select.tscn"
		)


	else:

		get_tree().change_scene_to_file(
			"res://game.tscn"
		)
