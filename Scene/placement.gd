extends Control


# =========================================================
# GRID SETTINGS
# =========================================================

# Player placement area.
#
# Seven columns across, four deployment rows per team.
const GRID_COLUMNS: int = preload("res://scripts/board_layout.gd").LANES
const GRID_ROWS: int = preload("res://scripts/board_layout.gd").DEPTH

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
# Row 3 = FRONT
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

	RenderingServer.set_default_clear_color(Color("171e2b"))

	if GameState.selected_team.size() != 4:

		placement_timer_active = false

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


	if not placement_timer_active or get_viewport().gui_is_dragging():
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
	var layout = preload("res://scripts/board_layout.gd")
	var backdrop := TextureRect.new()
	backdrop.texture = preload("res://Art/Arenas/Vesper/vesper_hex_arena.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.position = layout.IMAGE_RECT.position
	backdrop.size = layout.IMAGE_RECT.size
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	_ui_label("ROUND %d • PLACE YOUR TEAM" % GameState.current_round, Vector2(720, 25), 22)
	_ui_label("Drag teammates onto your half of the arena.", Vector2(720, 65), 16)
	placement_timer_label = _ui_label("", Vector2(24, 85), 16)
	var pause := Button.new()
	pause.position = Vector2(24, 125)
	pause.size = Vector2(140, 32)
	pause.text = "Pause timer"
	pause.pressed.connect(func():
		placement_timer_active = not placement_timer_active
		pause.text = "Resume timer" if not placement_timer_active else "Pause timer"
	)
	add_child(pause)
	selected_label = _ui_label("", Vector2(24, 180), 16)
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_label.size = Vector2(150, 180)
	var mini = preload("res://scripts/formation_history.gd").new()
	mini.position = Vector2(745, 170)
	mini.size = Vector2(220, 215)
	mini.snapshot = GameState.get_visible_enemy_history()
	add_child(mini)
	_ui_label("YOUR TEAM ↑", Vector2(24, 630), 16)
	_ui_label("Your next move", Vector2(745, 425), 22)
	_ui_label("Drag a teammate onto an empty hex.\nYour four starting rows are below.\nFour hexes in every row.\nEnemy positions stay hidden.", Vector2(745, 465), 16)
	for cell in layout.all_cells():
		var button = preload("res://scripts/hex_placement_tile.gd").new()
		button.placement_ui = self
		button.cell = cell
		var rect: Rect2 = layout.cell_rect(cell)
		button.position = rect.position
		button.size = rect.size
		for point in layout.polygon(layout.to_global(cell)):
			button.points.append(point - rect.position)
		button.tooltip_text = "Row %d • Hex %d" % [cell.y + 1, cell.x + 1]
		button.pressed.connect(_on_grid_button_pressed.bind(cell))
		for state in ["normal", "hover", "pressed", "focus", "disabled"]:
			button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		add_child(button)
		grid_buttons[cell] = button
		var art := TextureRect.new()
		art.name = "CharacterArt"
		art.position = rect.size * 0.5 - Vector2(30, 34)
		art.size = Vector2(60, 60)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(art)
		var label := Label.new()
		label.name = "Name"
		label.position = Vector2(0, rect.size.y - 20)
		label.size = Vector2(rect.size.x, 16)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 10)
		label.add_theme_color_override("font_shadow_color", Color.BLACK)
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(label)
	placement_count_label = _ui_label("", Vector2(24, 675), 16)
	for index in range(GameState.selected_team.size()):
		var data: CharacterData = GameState.selected_team[index]
		var button = preload("res://scripts/hex_placement_tile.gd").new()
		button.placement_ui = self
		button.character_data = data
		button.position = Vector2(24 + index * 184, 700)
		button.size = Vector2(176, 46)
		button.icon = data.battle_texture
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 40)
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(_on_character_button_pressed.bind(data))
		add_child(button)
		character_buttons[data.character_name] = button
	start_round_button = Button.new()
	start_round_button.position = Vector2(790, 704)
	start_round_button.size = Vector2(270, 40)
	start_round_button.text = "START ROUND"
	start_round_button.pressed.connect(_on_start_round_pressed)
	add_child(start_round_button)
	trait_bar_label = _ui_label("", Vector2(745, 590), 13)
	create_character_ledger()
	var details := Button.new()
	details.position = Vector2(880, 110)
	details.size = Vector2(180, 34)
	details.text = "Character details"
	details.pressed.connect(func():
		get_node("CharacterLedger").visible = not get_node("CharacterLedger").visible
	)
	add_child(details)

func can_place(data: CharacterData, cell: Vector2i) -> bool:
	return not round_starting and data != null and data in GameState.selected_team and preload("res://scripts/board_layout.gd").is_valid(cell) and (not occupied_cells.has(cell) or occupied_cells[cell] == data)

func place_character(data: CharacterData, cell: Vector2i) -> void:
	if can_place(data, cell):
		selected_character = data
		_on_grid_button_pressed(cell)

func _ui_label(text: String, at: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)
	return label

func create_character_ledger() -> void:

	# =====================================================
	# OUTER PANEL
	# =====================================================

	var ledger_panel = PanelContainer.new()
	ledger_panel.name = "CharacterLedger"
	ledger_panel.visible = false

	add_child(
		ledger_panel
	)


	ledger_panel.position = Vector2(
		790,
		120
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

	if not preload("res://scripts/board_layout.gd").is_valid(cell_position):
		return

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


			if preload("res://scripts/board_layout.gd").is_valid(saved_position):
				occupied_cells[
					saved_position
				] = character


# =========================================================
# UPDATE PLACEMENT UI
# =========================================================

func update_placement_ui() -> void:
	update_trait_bar()
	for cell in grid_buttons:
		var button: Button = grid_buttons[cell]
		var data: CharacterData = occupied_cells.get(cell)
		button.text = ""
		button.get_node("CharacterArt").texture = data.battle_texture if data != null else null
		button.get_node("Name").text = data.character_name if data != null else "+" if selected_character != null else ""
		button.selected = data != null and data == selected_character
		button.available = selected_character != null and can_place(selected_character, cell)
		button.blocked = selected_character != null and not can_place(selected_character, cell)
		button.queue_redraw()
	for data in GameState.selected_team:
		var button: Button = character_buttons[data.character_name]
		var placed: bool = find_character_position(data) != Vector2i(-1, -1)
		button.text = data.character_name + "\n" + ("PLACED" if placed else data.class_role)
		button.modulate = Color("ffe1a1") if data == selected_character else Color.WHITE
	selected_label.text = "Choose a hex for " + selected_character.character_name if selected_character != null else "Drag a teammate from the bench onto an empty hex. Drag again to reposition."
	placement_count_label.text = "Placed: %d / 4  •  Same positions when combat begins" % occupied_cells.size()
	start_round_button.disabled = occupied_cells.size() != 4 or round_starting

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
		"TIME: "
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


	for cell in preload("res://scripts/board_layout.gd").all_cells():
		if not occupied_cells.has(cell):
			available_cells.append(cell)

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
