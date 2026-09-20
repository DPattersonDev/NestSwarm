extends Control


# =========================================================
# UPGRADE SCREEN STATE
# =========================================================

var current_character_index: int = 0

var current_choices: Array = []

var choices_by_character: Dictionary = {}

var upgraded_this_round: Dictionary = {}

var selected_this_round: Dictionary = {}

var upgrade_buttons: Array[Button] = []

# One moving shine strip per upgrade button.
# Only visible when that button is showing a Special.
var upgrade_shines: Array[ColorRect] = []


# =========================================================
# REPLACEMENT CATCH-UP STATE
# =========================================================

var catchup_mode: bool = false

var catchup_character_index: int = -1

var timer_finished: bool = false


# Prevents the upgrade phase from being
# completed more than once.
var upgrade_phase_finished: bool = false


# =========================================================
# COOLDOWN LIMIT
# =========================================================

const MIN_ATTACK_COOLDOWN: float = 0.25


# =========================================================
# CARD COLORS
# =========================================================
#
# Special = Gold
# Class   = Green
# Item    = Crimson / Red
# =========================================================

const SPECIAL_NORMAL_COLOR: Color = Color(0.24, 0.18, 0.05, 1.0)
const SPECIAL_HOVER_COLOR: Color = Color(0.32, 0.24, 0.07, 1.0)
const SPECIAL_PRESSED_COLOR: Color = Color(0.18, 0.13, 0.04, 1.0)
const SPECIAL_BORDER_COLOR: Color = Color(0.92, 0.73, 0.22, 1.0)

const CLASS_NORMAL_COLOR: Color = Color(0.07, 0.20, 0.10, 1.0)
const CLASS_HOVER_COLOR: Color = Color(0.09, 0.27, 0.13, 1.0)
const CLASS_PRESSED_COLOR: Color = Color(0.05, 0.15, 0.07, 1.0)
const CLASS_BORDER_COLOR: Color = Color(0.25, 0.78, 0.38, 1.0)

const ITEM_NORMAL_COLOR: Color = Color(0.22, 0.07, 0.07, 1.0)
const ITEM_HOVER_COLOR: Color = Color(0.30, 0.09, 0.09, 1.0)
const ITEM_PRESSED_COLOR: Color = Color(0.16, 0.05, 0.05, 1.0)
const ITEM_BORDER_COLOR: Color = Color(0.78, 0.24, 0.24, 1.0)

const NEUTRAL_NORMAL_COLOR: Color = Color(0.16, 0.16, 0.16, 1.0)
const NEUTRAL_HOVER_COLOR: Color = Color(0.20, 0.20, 0.20, 1.0)
const NEUTRAL_PRESSED_COLOR: Color = Color(0.12, 0.12, 0.12, 1.0)
const NEUTRAL_BORDER_COLOR: Color = Color(0.33, 0.33, 0.33, 1.0)


# =========================================================
# UI REFERENCES
# =========================================================

var character_name_label: Label
var progress_label: Label
var timer_label: Label

var upgrade_container: VBoxContainer

var previous_character_button: Button
var next_character_button: Button

var ledger_panel: PanelContainer
var ledger_name_label: Label
var ledger_stats_label: Label
var ledger_ability_label: Label
var ledger_upgrades_label: Label


# =========================================================
# STARTUP
# =========================================================

func _ready() -> void:

	if GameState.selected_team.size() != 4:

		print(
			"Upgrade Error: Player does not have 4 characters."
		)

		return


	create_upgrade_ui()

	check_for_replacement_catchup()

	show_current_character()


# =========================================================
# PROCESS
# =========================================================

func _process(
	_delta: float
) -> void:

	update_timer_display()


	if upgrade_phase_finished:
		return


	if timer_finished:
		return


	if GameState.between_round_time_left > 0.0:
		return


	timer_finished = true

	auto_complete_remaining_upgrades()


# =========================================================
# CHECK REPLACEMENT CATCH-UP
# =========================================================

func check_for_replacement_catchup() -> void:

	catchup_mode = false

	catchup_character_index = -1


	if GameState.replacement_character_name == "":
		return


	if GameState.replacement_upgrade_picks_remaining <= 0:
		return


	for i in range(
		GameState.selected_team.size()
	):

		var character = (
			GameState.selected_team[i]
		)


		if (
			character.character_name
			== GameState.replacement_character_name
		):

			catchup_character_index = i
			current_character_index = i
			catchup_mode = true

			return


# =========================================================
# UI CREATION
# =========================================================

func create_upgrade_ui() -> void:

	var main_container = VBoxContainer.new()

	add_child(
		main_container
	)


	main_container.position = Vector2(
		80,
		20
	)


	main_container.size = Vector2(
		720,
		625
	)


	# =====================================================
	# TITLE
	# =====================================================

	var title = Label.new()

	title.text = (
		"CHOOSE AN UPGRADE"
	)


	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	title.add_theme_font_size_override(
		"font_size",
		30
	)


	main_container.add_child(
		title
	)


	# =====================================================
	# TIMER
	# =====================================================

	timer_label = Label.new()


	timer_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	timer_label.add_theme_font_size_override(
		"font_size",
		20
	)


	main_container.add_child(
		timer_label
	)


	# =====================================================
	# CHARACTER NAVIGATION
	# =====================================================

	var navigation_container = HBoxContainer.new()

	navigation_container.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)


	main_container.add_child(
		navigation_container
	)


	# =========================
	# PREVIOUS CHARACTER
	# =========================

	previous_character_button = Button.new()

	previous_character_button.text = (
		"<"
	)


	previous_character_button.custom_minimum_size = Vector2(
		65,
		50
	)


	previous_character_button.add_theme_font_size_override(
		"font_size",
		25
	)


	previous_character_button.pressed.connect(
		_on_previous_character_pressed
	)


	navigation_container.add_child(
		previous_character_button
	)


	# =========================
	# CHARACTER NAME
	# =========================

	character_name_label = Label.new()


	character_name_label.custom_minimum_size = Vector2(
		470,
		50
	)


	character_name_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	character_name_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)


	character_name_label.add_theme_font_size_override(
		"font_size",
		25
	)


	navigation_container.add_child(
		character_name_label
	)


	# =========================
	# NEXT CHARACTER
	# =========================

	next_character_button = Button.new()

	next_character_button.text = (
		">"
	)


	next_character_button.custom_minimum_size = Vector2(
		65,
		50
	)


	next_character_button.add_theme_font_size_override(
		"font_size",
		25
	)


	next_character_button.pressed.connect(
		_on_next_character_pressed
	)


	navigation_container.add_child(
		next_character_button
	)


	# =====================================================
	# PROGRESS
	# =====================================================

	progress_label = Label.new()


	progress_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	progress_label.add_theme_font_size_override(
		"font_size",
		16
	)


	main_container.add_child(
		progress_label
	)


	# =====================================================
	# UPGRADE CONTAINER
	# =====================================================

	upgrade_container = VBoxContainer.new()


	upgrade_container.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)


	main_container.add_child(
		upgrade_container
	)


	for i in range(3):

		var button = Button.new()


		button.custom_minimum_size = Vector2(
			650,
			120
		)


		button.add_theme_font_size_override(
			"font_size",
			16
		)


		# Keep long upgrade descriptions inside the card instead of
		# forcing the Button/VBoxContainer to grow wider than the layout.
		button.autowrap_mode = (
			TextServer.AUTOWRAP_WORD_SMART
		)


		# Without this, Godot makes the Button wide enough to fit the
		# longest line of text. That was stretching the entire upgrade
		# screen across the ledger again.
		button.clip_text = true


		button.clip_contents = true


		button.pressed.connect(
			_on_upgrade_button_pressed.bind(
				i
			)
		)


		upgrade_container.add_child(
			button
		)


		upgrade_buttons.append(
			button
		)


		# =================================================
		# SPECIAL CARD SHINE
		# =================================================

		var shine = ColorRect.new()

		shine.color = Color(
			1.0,
			0.92,
			0.58,
			0.12
		)


		shine.size = Vector2(
			75,
			180
		)


		shine.position = Vector2(
			-100,
			-30
		)


		shine.rotation_degrees = 12.0

		shine.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		shine.visible = false


		button.add_child(
			shine
		)


		upgrade_shines.append(
			shine
		)


		start_special_shine_animation(
			shine
		)


	create_upgrade_ledger()

	update_timer_display()


# =========================================================
# SPECIAL SHINE ANIMATION
# =========================================================

func start_special_shine_animation(
	shine: ColorRect
) -> void:

	var tween = (
		create_tween()
	)


	tween.set_loops()


	tween.tween_interval(
		0.7
	)


	tween.tween_property(
		shine,
		"position:x",
		720.0,
		1.0
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)


	tween.tween_interval(
		1.2
	)


	tween.tween_callback(
		func():
			shine.position.x = -100.0
	)


# =========================================================
# CREATE UPGRADE LEDGER
# =========================================================

func create_upgrade_ledger() -> void:

	ledger_panel = PanelContainer.new()


	add_child(
		ledger_panel
	)


	ledger_panel.position = Vector2(
		890,
		105
	)


	ledger_panel.size = Vector2(
		230,
		470
	)


	var ledger_container = VBoxContainer.new()


	ledger_panel.add_child(
		ledger_container
	)


	# =========================
	# HEADER
	# =========================

	var ledger_header = Label.new()


	ledger_header.text = (
		"CURRENT BUILD"
	)


	ledger_header.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	ledger_header.add_theme_font_size_override(
		"font_size",
		15
	)


	ledger_container.add_child(
		ledger_header
	)


	# =========================
	# NAME
	# =========================

	ledger_name_label = Label.new()


	ledger_name_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	ledger_name_label.add_theme_font_size_override(
		"font_size",
		14
	)


	ledger_container.add_child(
		ledger_name_label
	)


	# =========================
	# STATS HEADER
	# =========================

	var stats_header = Label.new()


	stats_header.text = (
		"STATS"
	)


	stats_header.add_theme_font_size_override(
		"font_size",
		11
	)


	ledger_container.add_child(
		stats_header
	)


	# =========================
	# STATS
	# =========================

	ledger_stats_label = Label.new()


	ledger_stats_label.custom_minimum_size = Vector2(
		205,
		102
	)


	ledger_stats_label.add_theme_font_size_override(
		"font_size",
		10
	)


	ledger_container.add_child(
		ledger_stats_label
	)


	# =========================
	# STARTING ABILITY HEADER
	# =========================

	var ability_header = Label.new()


	ability_header.text = (
		"STARTING ABILITY"
	)


	ability_header.add_theme_font_size_override(
		"font_size",
		11
	)


	ledger_container.add_child(
		ability_header
	)


	# =========================
	# STARTING ABILITY
	# =========================

	ledger_ability_label = Label.new()


	ledger_ability_label.custom_minimum_size = Vector2(
		205,
		120
	)


	ledger_ability_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)


	ledger_ability_label.add_theme_font_size_override(
		"font_size",
		9
	)


	ledger_container.add_child(
		ledger_ability_label
	)


	# =========================
	# UPGRADES HEADER
	# =========================

	var upgrades_header = Label.new()


	upgrades_header.text = (
		"CURRENT UPGRADES"
	)


	upgrades_header.add_theme_font_size_override(
		"font_size",
		11
	)


	ledger_container.add_child(
		upgrades_header
	)


	# =========================
	# CURRENT UPGRADES
	# =========================

	ledger_upgrades_label = Label.new()


	ledger_upgrades_label.custom_minimum_size = Vector2(
		205,
		120
	)


	ledger_upgrades_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)


	ledger_upgrades_label.add_theme_font_size_override(
		"font_size",
		9
	)


	ledger_container.add_child(
		ledger_upgrades_label
	)


# =========================================================
# CURRENT CHARACTER
# =========================================================

func show_current_character() -> void:

	if GameState.selected_team.size() == 0:
		return


	if catchup_mode:

		current_character_index = (
			catchup_character_index
		)


	if current_character_index < 0:

		current_character_index = (
			GameState.selected_team.size()
			- 1
		)


	if current_character_index >= GameState.selected_team.size():

		current_character_index = 0


	var character = (
		GameState.selected_team[
			current_character_index
		]
	)


	var character_name: String = (
		character.character_name
	)


	character_name_label.text = (
		character_name
	)


	# =====================================================
	# CATCH-UP MODE
	# =====================================================

	if catchup_mode:

		previous_character_button.disabled = true

		next_character_button.disabled = true


		progress_label.text = (
			"REPLACEMENT CATCH-UP"
			+ "   |   "
			+ str(
				GameState.replacement_upgrade_picks_remaining
			)
			+ " Pick(s) Remaining"
		)


		if current_choices.size() == 0:

			current_choices = (
				UpgradeDatabase.get_random_three(
					character_name
				)
			)


	else:

		previous_character_button.disabled = false

		next_character_button.disabled = false


		var completed_count: int = (
			upgraded_this_round.size()
		)


		var status_text: String = ""


		if upgraded_this_round.has(
			character_name
		):

			status_text = (
				"   -   UPGRADED THIS ROUND"
			)


		progress_label.text = (
			"Character "
			+ str(current_character_index + 1)
			+ " of "
			+ str(GameState.selected_team.size())
			+ "   |   "
			+ str(completed_count)
			+ " / 4 Complete"
			+ status_text
		)


		if not choices_by_character.has(
			character_name
		):

			choices_by_character[
				character_name
			] = (
				UpgradeDatabase.get_random_three(
					character_name
				)
			)


		current_choices = (
			choices_by_character[
				character_name
			]
		)


	# =====================================================
	# DISPLAY CHOICES
	# =====================================================

	for i in range(
		upgrade_buttons.size()
	):

		var button = (
			upgrade_buttons[i]
		)


		var shine = (
			upgrade_shines[i]
		)


		if i >= current_choices.size():

			button.text = (
				"NO UPGRADE"
			)

			button.disabled = true

			shine.visible = false

			apply_upgrade_button_style(
				button,
				"Neutral"
			)

			continue


		var upgrade = (
			current_choices[i]
		)


		button.text = (
			create_upgrade_text(
				upgrade
			)
		)


		var upgrade_type: String = (
			str(
				upgrade.get(
					"type",
					""
				)
			)
		)


		apply_upgrade_button_style(
			button,
			upgrade_type
		)


		shine.visible = (
			upgrade_type == "Special"
		)


		if catchup_mode:

			button.disabled = false


		else:

			button.disabled = (
				upgraded_this_round.has(
					character_name
				)
			)


	update_upgrade_ledger(
		character
	)


# =========================================================
# BUTTON STYLE
# =========================================================

func apply_upgrade_button_style(
	button: Button,
	upgrade_type: String
) -> void:

	var normal_color: Color = (
		NEUTRAL_NORMAL_COLOR
	)

	var hover_color: Color = (
		NEUTRAL_HOVER_COLOR
	)

	var pressed_color: Color = (
		NEUTRAL_PRESSED_COLOR
	)

	var border_color: Color = (
		NEUTRAL_BORDER_COLOR
	)


	if upgrade_type == "Special":

		normal_color = (
			SPECIAL_NORMAL_COLOR
		)

		hover_color = (
			SPECIAL_HOVER_COLOR
		)

		pressed_color = (
			SPECIAL_PRESSED_COLOR
		)

		border_color = (
			SPECIAL_BORDER_COLOR
		)


	elif upgrade_type == "Class":

		normal_color = (
			CLASS_NORMAL_COLOR
		)

		hover_color = (
			CLASS_HOVER_COLOR
		)

		pressed_color = (
			CLASS_PRESSED_COLOR
		)

		border_color = (
			CLASS_BORDER_COLOR
		)


	elif upgrade_type == "Item":

		normal_color = (
			ITEM_NORMAL_COLOR
		)

		hover_color = (
			ITEM_HOVER_COLOR
		)

		pressed_color = (
			ITEM_PRESSED_COLOR
		)

		border_color = (
			ITEM_BORDER_COLOR
		)


	var normal_style = (
		create_card_style(
			normal_color,
			border_color
		)
	)


	var hover_style = (
		create_card_style(
			hover_color,
			border_color
		)
	)


	var pressed_style = (
		create_card_style(
			pressed_color,
			border_color
		)
	)


	var disabled_style = (
		create_card_style(
			normal_color.darkened(
				0.35
			),
			border_color.darkened(
				0.30
			)
		)
	)


	button.add_theme_stylebox_override(
		"normal",
		normal_style
	)


	button.add_theme_stylebox_override(
		"hover",
		hover_style
	)


	button.add_theme_stylebox_override(
		"pressed",
		pressed_style
	)


	button.add_theme_stylebox_override(
		"disabled",
		disabled_style
	)


# =========================================================
# CREATE CARD STYLE
# =========================================================

func create_card_style(
	background_color: Color,
	border_color: Color
) -> StyleBoxFlat:

	var style = StyleBoxFlat.new()


	style.bg_color = (
		background_color
	)


	style.border_color = (
		border_color
	)


	style.set_border_width_all(
		2
	)


	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6


	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0


	return style


# =========================================================
# PREVIOUS CHARACTER
# =========================================================

func _on_previous_character_pressed() -> void:

	if catchup_mode:
		return


	current_character_index -= 1


	if current_character_index < 0:

		current_character_index = (
			GameState.selected_team.size()
			- 1
		)


	show_current_character()


# =========================================================
# NEXT CHARACTER
# =========================================================

func _on_next_character_pressed() -> void:

	if catchup_mode:
		return


	current_character_index += 1


	if current_character_index >= GameState.selected_team.size():

		current_character_index = 0


	show_current_character()


# =========================================================
# UPGRADE TEXT
# =========================================================

func create_upgrade_text(
	upgrade: Dictionary
) -> String:

	var text: String = ""


	if upgrade.has(
		"name"
	):

		text += str(
			upgrade["name"]
		)


	text += "\n"


	if upgrade.has(
		"type"
	):

		text += (
			str(
				upgrade["type"]
			)
			+ "\n"
		)


	if upgrade.has(
		"description"
	):

		text += (
			str(
				upgrade["description"]
			)
		)


	return text


# =========================================================
# UPGRADE SELECTION
# =========================================================

func _on_upgrade_button_pressed(
	choice_index: int
) -> void:

	if upgrade_phase_finished:
		return


	if choice_index < 0:
		return


	if choice_index >= current_choices.size():
		return


	if current_character_index < 0:
		return


	if current_character_index >= GameState.selected_team.size():
		return


	var character = (
		GameState.selected_team[
			current_character_index
		]
	)


	var character_name: String = (
		character.character_name
	)


	# =====================================================
	# REPLACEMENT CATCH-UP PICK
	# =====================================================

	if catchup_mode:

		var catchup_upgrade = (
			current_choices[
				choice_index
			]
		)


		print(
			character_name,
			" selected catch-up upgrade ",
			catchup_upgrade["name"]
		)


		save_character_upgrade(
			character_name,
			catchup_upgrade
		)


		GameState.replacement_upgrade_picks_remaining -= 1


		current_choices.clear()


		if GameState.replacement_upgrade_picks_remaining > 0:

			show_current_character()

			return


		# =================================================
		# CATCH-UP COMPLETE
		# =================================================

		catchup_mode = false


		GameState.replacement_completed_this_phase = true


		upgraded_this_round[
			character_name
		] = true


		print(
			character_name,
			" finished replacement catch-up."
		)


		move_to_next_unfinished_character()

		return


	# =====================================================
	# NORMAL UPGRADE
	# =====================================================

	if upgraded_this_round.has(
		character_name
	):

		return


	var normal_upgrade = (
		current_choices[
			choice_index
		]
	)


	print(
		character_name,
		" selected ",
		normal_upgrade["name"]
	)


	if normal_upgrade.has(
		"effect_id"
	):

		print(
			"Effect ID: ",
			normal_upgrade[
				"effect_id"
			]
		)


	save_character_upgrade(
		character_name,
		normal_upgrade
	)


	upgraded_this_round[
		character_name
	] = true


	selected_this_round[
		character_name
	] = (
		selected_upgrade_copy(
			normal_upgrade
		)
	)


	if upgraded_this_round.size() >= GameState.selected_team.size():

		finish_upgrade_phase()

		return


	move_to_next_unfinished_character()


# =========================================================
# MOVE TO NEXT UNFINISHED CHARACTER
# =========================================================

func move_to_next_unfinished_character() -> void:

	if upgrade_phase_finished:
		return


	var team_size: int = (
		GameState.selected_team.size()
	)


	for offset in range(
		1,
		team_size + 1
	):

		var test_index: int = (
			(
				current_character_index
				+ offset
			)
			% team_size
		)


		var test_character = (
			GameState.selected_team[
				test_index
			]
		)


		if not upgraded_this_round.has(
			test_character.character_name
		):

			current_character_index = (
				test_index
			)


			current_choices.clear()


			show_current_character()

			return


	finish_upgrade_phase()


# =========================================================
# SAVE UPGRADE
# =========================================================

func save_character_upgrade(
	character_name: String,
	upgrade: Dictionary
) -> void:

	if not GameState.character_upgrades.has(
		character_name
	):

		GameState.character_upgrades[
			character_name
		] = []


	GameState.character_upgrades[
		character_name
	].append(
		selected_upgrade_copy(
			upgrade
		)
	)


# =========================================================
# COPY UPGRADE
# =========================================================

func selected_upgrade_copy(
	upgrade: Dictionary
) -> Dictionary:

	return upgrade.duplicate(
		true
	)


# =========================================================
# AUTO COMPLETE ON TIMER EXPIRATION
# =========================================================

func auto_complete_remaining_upgrades() -> void:

	if upgrade_phase_finished:
		return


	print(
		"Between-round timer expired."
	)


	# =====================================================
	# FINISH REPLACEMENT CATCH-UP
	# =====================================================

	if catchup_mode:

		var replacement = (
			GameState.selected_team[
				catchup_character_index
			]
		)


		var replacement_name: String = (
			replacement.character_name
		)


		while (
			GameState.replacement_upgrade_picks_remaining
			> 0
		):

			var random_choices = (
				UpgradeDatabase.get_random_three(
					replacement_name
				)
			)


			if random_choices.size() == 0:
				break


			var random_upgrade = (
				random_choices[
					randi()
					% random_choices.size()
				]
			)


			save_character_upgrade(
				replacement_name,
				random_upgrade
			)


			print(
				"Auto-selected catch-up upgrade for ",
				replacement_name,
				": ",
				random_upgrade["name"]
			)


			GameState.replacement_upgrade_picks_remaining -= 1


		upgraded_this_round[
			replacement_name
		] = true


		GameState.replacement_completed_this_phase = true


		catchup_mode = false


	# =====================================================
	# FINISH NORMAL CHARACTER UPGRADES
	# =====================================================

	for character in GameState.selected_team:

		var character_name: String = (
			character.character_name
		)


		if upgraded_this_round.has(
			character_name
		):

			continue


		var random_choices = (
			UpgradeDatabase.get_random_three(
				character_name
			)
		)


		if random_choices.size() == 0:

			upgraded_this_round[
				character_name
			] = true

			continue


		var random_upgrade = (
			random_choices[
				randi()
				% random_choices.size()
			]
		)


		save_character_upgrade(
			character_name,
			random_upgrade
		)


		upgraded_this_round[
			character_name
		] = true


		print(
			"Auto-selected upgrade for ",
			character_name,
			": ",
			random_upgrade["name"]
		)


	finish_upgrade_phase()


# =========================================================
# UPDATE UPGRADE LEDGER
# =========================================================

func update_upgrade_ledger(
	character: CharacterData
) -> void:

	if character == null:
		return


	var character_name: String = (
		character.character_name
	)


	ledger_name_label.text = (
		character_name
	)


	# =====================================================
	# BASE STATS
	# =====================================================

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


	# =====================================================
	# APPLY SAVED UPGRADES
	# =====================================================

	if GameState.character_upgrades.has(
		character_name
	):

		var upgrades = (
			GameState.character_upgrades[
				character_name
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


	# =====================================================
	# STATS TEXT
	# =====================================================

	ledger_stats_label.text = (
		"Faction: "
		+ character.faction
		+ "\n"
		+ "Class: "
		+ character.class_role
		+ "\n"
		+ "HP: "
		+ str(preview_health)
		+ "\n"
		+ "ATK: "
		+ str(preview_damage)
		+ "\n"
		+ "Speed: "
		+ str(
			snapped(
				preview_speed,
				0.1
			)
		)
		+ "\n"
		+ "Range: "
		+ str(
			snapped(
				preview_range,
				0.1
			)
		)
		+ "\n"
		+ "CD: "
		+ str(
			snapped(
				preview_cooldown,
				0.01
			)
		)
		+ "s"
	)


	# =====================================================
	# STARTING ABILITY
	# =====================================================

	ledger_ability_label.text = (
		get_starting_ability_text(
			character
		)
	)


	# =====================================================
	# OWNED UPGRADES
	# =====================================================

	ledger_upgrades_label.text = (
		get_owned_upgrade_text(
			character_name
		)
	)


# =========================================================
# STARTING ABILITY TEXT
# =========================================================

func get_starting_ability_text(
	character: CharacterData
) -> String:

	if character == null:

		return (
			"No starting ability assigned."
		)


	var ability_id: String = (
		character.basic_ability_id
	)


	if ability_id == "":

		return (
			"No starting ability assigned."
		)


	var ability: Dictionary = (
		UpgradeDatabase.get_basic_ability(
			ability_id
		)
	)


	if ability.size() == 0:

		return (
			"Unknown ability: "
			+ ability_id
		)


	var ability_name: String = (
		str(
			ability.get(
				"name",
				ability_id
			)
		)
	)


	var ability_description: String = (
		str(
			ability.get(
				"description",
				""
			)
		)
	)


	return (
		ability_name
		+ "\n"
		+ ability_description
	)


# =========================================================
# OWNED UPGRADE TEXT
# =========================================================

func get_owned_upgrade_text(
	character_name: String
) -> String:

	if not GameState.character_upgrades.has(
		character_name
	):

		return (
			"None"
		)


	var upgrades = (
		GameState.character_upgrades[
			character_name
		]
	)


	if upgrades.size() == 0:

		return (
			"None"
		)


	var upgrade_counts: Dictionary = {}


	for upgrade in upgrades:

		if not upgrade.has(
			"name"
		):

			continue


		var upgrade_name: String = (
			str(
				upgrade[
					"name"
				]
			)
		)


		if not upgrade_counts.has(
			upgrade_name
		):

			upgrade_counts[
				upgrade_name
			] = 0


		upgrade_counts[
			upgrade_name
		] += 1


	var upgrade_lines: Array[String] = []


	for upgrade_name in upgrade_counts:

		var count: int = (
			upgrade_counts[
				upgrade_name
			]
		)


		if count > 1:

			upgrade_lines.append(
				"• "
				+ str(upgrade_name)
				+ " x"
				+ str(count)
			)


		else:

			upgrade_lines.append(
				"• "
				+ str(upgrade_name)
			)


	if upgrade_lines.size() == 0:

		return (
			"None"
		)


	return (
		"\n".join(
			upgrade_lines
		)
	)


# =========================================================
# TIMER DISPLAY
# =========================================================

func update_timer_display() -> void:

	if timer_label == null:
		return


	var seconds_left: int = (
		int(
			ceil(
				GameState.between_round_time_left
			)
		)
	)


	timer_label.text = (
		"TIME REMAINING: "
		+ str(seconds_left)
		+ "s"
	)


# =========================================================
# FINISH UPGRADE PHASE
# =========================================================

func finish_upgrade_phase() -> void:

	if upgrade_phase_finished:
		return


	upgrade_phase_finished = true


	print(
		"All required upgrades have been selected."
	)


	GameState.end_between_round_phase()


	GameState.current_round += 1


	print(
		"Preparing Round ",
		GameState.current_round
	)


	get_tree().change_scene_to_file(
		"res://Scene/Placement.tscn"
	)
