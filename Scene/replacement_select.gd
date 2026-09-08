extends Control


# =========================================================
# FULL CHARACTER ROSTER
# =========================================================


# =========================================================
# VESPER
# =========================================================

var veyra = preload("res://Data/Veyra.tres")
var zekrin = preload("res://Data/Zekrin.tres")
var melora = preload("res://Data/Melora.tres")
var tharos = preload("res://Data/Tharos.tres")
var aurex = preload("res://Data/Aurex.tres")


# =========================================================
# ANTTALOPE
# =========================================================

var kaelor = preload("res://Data/Kaelor.tres")
var syrra = preload("res://Data/Syrra.tres")
var droven = preload("res://Data/Droven.tres")
var nyxis = preload("res://Data/Nyxis.tres")
var velkara = preload("res://Data/Velkara.tres")


# =========================================================
# LEPIDRA
# =========================================================

var lunara = preload("res://Data/Lunara.tres")
var vorren = preload("res://Data/Vorren.tres")
var noctren = preload("res://Data/Noctren.tres")
var solvyr = preload("res://Data/Solvyr.tres")
var mavros = preload("res://Data/Mavros.tres")


# =========================================================
# FORMICARA
# =========================================================

var karnyx = preload("res://Data/Karnyx.tres")
var raxen = preload("res://Data/Raxen.tres")
var vexira = preload("res://Data/Vexira.tres")
var tarsik = preload("res://Data/Tarsik.tres")
var myraxa = preload("res://Data/Myraxa.tres")


# =========================================================
# CARAPHEX
# =========================================================

var brontis = preload("res://Data/Brontis.tres")
var kharvos = preload("res://Data/Kharvos.tres")
var virex = preload("res://Data/Virex.tres")
var ignivar = preload("res://Data/Ignivar.tres")
var aurelia = preload("res://Data/Aurelia.tres")


# =========================================================
# SCOLYRA
# =========================================================

var mordrax = preload("res://Data/Mordrax.tres")
var scyrix = preload("res://Data/Scyrix.tres")
var nyzara = preload("res://Data/Nyzara.tres")
var veltrix = preload("res://Data/Veltrix.tres")
var thesira = preload("res://Data/Thesira.tres")


# =========================================================
# FULL ROSTER
# =========================================================

var full_roster: Array[CharacterData] = []


# =========================================================
# REPLACEMENT STATE
# =========================================================

var selected_sacrifice_index: int = -1

var replacement_choices: Array[CharacterData] = []

var sacrifice_confirmed: bool = false

var timer_finished: bool = false


# =========================================================
# UI REFERENCES
# =========================================================

var title_label: Label
var timer_label: Label
var instruction_label: Label

var character_container: HBoxContainer
var action_container: HBoxContainer

var skip_button: Button
var confirm_button: Button


# =========================================================
# STARTUP
# =========================================================

func _ready() -> void:

	create_full_roster()

	create_ui()

	show_sacrifice_choices()


# =========================================================
# PROCESS
# =========================================================

func _process(
	_delta: float
) -> void:

	update_timer_display()


	if timer_finished:
		return


	if GameState.between_round_time_left > 0.0:
		return


	timer_finished = true


	handle_timer_expired()


# =========================================================
# CREATE FULL ROSTER
# =========================================================

func create_full_roster() -> void:

	full_roster = [

		# Vesper
		veyra,
		zekrin,
		melora,
		tharos,
		aurex,

		# Anttalope
		kaelor,
		syrra,
		droven,
		nyxis,
		velkara,

		# Lepidra
		lunara,
		vorren,
		noctren,
		solvyr,
		mavros,

		# Formicara
		karnyx,
		raxen,
		vexira,
		tarsik,
		myraxa,

		# Caraphex
		brontis,
		kharvos,
		virex,
		ignivar,
		aurelia,

		# Scolyra
		mordrax,
		scyrix,
		nyzara,
		veltrix,
		thesira
	]


# =========================================================
# CREATE UI
# =========================================================

func create_ui() -> void:

	var main_container = VBoxContainer.new()

	add_child(
		main_container
	)


	main_container.position = Vector2(
		120,
		45
	)


	main_container.size = Vector2(
		900,
		560
	)


	# =====================================================
	# TITLE
	# =====================================================

	title_label = Label.new()


	title_label.text = (
		"PREPARE FOR ROUND "
		+ str(
			GameState.get_next_round_number()
		)
	)


	title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	title_label.add_theme_font_size_override(
		"font_size",
		30
	)


	main_container.add_child(
		title_label
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
		24
	)


	main_container.add_child(
		timer_label
	)


	# =====================================================
	# INSTRUCTIONS
	# =====================================================

	instruction_label = Label.new()


	instruction_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	instruction_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)


	instruction_label.custom_minimum_size = Vector2(
		850,
		60
	)


	instruction_label.add_theme_font_size_override(
		"font_size",
		17
	)


	main_container.add_child(
		instruction_label
	)


	# =====================================================
	# CHARACTER CHOICES
	# =====================================================

	character_container = HBoxContainer.new()


	character_container.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)


	main_container.add_child(
		character_container
	)


	# =====================================================
	# ACTION BUTTONS
	# =====================================================

	action_container = HBoxContainer.new()


	action_container.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)


	main_container.add_child(
		action_container
	)


	# =====================================================
	# SKIP BUTTON
	# =====================================================

	skip_button = Button.new()


	skip_button.text = (
		"SKIP REPLACEMENT"
	)


	skip_button.custom_minimum_size = Vector2(
		250,
		60
	)


	skip_button.pressed.connect(
		_on_skip_pressed
	)


	action_container.add_child(
		skip_button
	)


	# =====================================================
	# CONFIRM BUTTON
	# =====================================================

	confirm_button = Button.new()


	confirm_button.text = (
		"CONFIRM SACRIFICE"
	)


	confirm_button.custom_minimum_size = Vector2(
		250,
		60
	)


	confirm_button.disabled = true


	confirm_button.pressed.connect(
		_on_confirm_sacrifice_pressed
	)


	action_container.add_child(
		confirm_button
	)


	update_timer_display()


# =========================================================
# CLEAR CHARACTER BUTTONS
# =========================================================

func clear_character_buttons() -> void:

	for child in character_container.get_children():

		child.queue_free()


# =========================================================
# SHOW SACRIFICE CHOICES
# =========================================================

func show_sacrifice_choices() -> void:

	clear_character_buttons()


	instruction_label.text = (
		"Replace one character or skip. "
		+ "Once you confirm a sacrifice, "
		+ "that character is permanently removed "
		+ "from your team for this match."
	)


	for i in range(
		GameState.selected_team.size()
	):

		var character = (
			GameState.selected_team[i]
		)


		var button = Button.new()


		button.custom_minimum_size = Vector2(
			205,
			150
		)


		button.text = (
			create_character_text(
				character
			)
		)


		button.pressed.connect(
			_on_sacrifice_character_pressed.bind(
				i
			)
		)


		character_container.add_child(
			button
		)


# =========================================================
# CHARACTER TEXT
# =========================================================

func create_character_text(
	character: CharacterData
) -> String:

	return (
		character.character_name
		+ "\n"
		+ character.faction
		+ "\n"
		+ character.class_role
		+ "\n\n"
		+ "HP: "
		+ str(character.max_health)
		+ "\n"
		+ "ATK: "
		+ str(character.damage)
		+ "\n"
		+ "CD: "
		+ "%.2f" % character.attack_cooldown
		+ "s"
	)


# =========================================================
# SELECT SACRIFICE
# =========================================================

func _on_sacrifice_character_pressed(
	index: int
) -> void:

	if sacrifice_confirmed:
		return


	if index < 0:
		return


	if index >= GameState.selected_team.size():
		return


	selected_sacrifice_index = (
		index
	)


	var character = (
		GameState.selected_team[
			index
		]
	)


	instruction_label.text = (
		character.character_name
		+ " selected for replacement.\n"
		+ "Press CONFIRM SACRIFICE to continue."
	)


	confirm_button.disabled = false


# =========================================================
# CONFIRM SACRIFICE
# =========================================================

func _on_confirm_sacrifice_pressed() -> void:

	if sacrifice_confirmed:
		return


	if selected_sacrifice_index < 0:
		return


	if selected_sacrifice_index >= GameState.selected_team.size():
		return


	sacrifice_confirmed = true


	skip_button.disabled = true

	confirm_button.disabled = true


	var old_character = (
		GameState.selected_team[
			selected_sacrifice_index
		]
	)


	var old_name: String = (
		old_character.character_name
	)


	GameState.sacrificed_character_name = (
		old_name
	)


	# =====================================================
	# REMOVE OLD UPGRADES
	# =====================================================

	if GameState.character_upgrades.has(
		old_name
	):

		GameState.character_upgrades.erase(
			old_name
		)


	# =====================================================
	# REMOVE OLD PLACEMENT
	# =====================================================

	if GameState.player_placements.has(
		old_name
	):

		GameState.player_placements.erase(
			old_name
		)


	# =====================================================
	# RETIRE CHARACTER FOR MATCH
	# =====================================================

	if not GameState.retired_character_names.has(
		old_name
	):

		GameState.retired_character_names.append(
			old_name
		)


	create_replacement_choices()


# =========================================================
# CREATE RANDOM REPLACEMENT CHOICES
# =========================================================

func create_replacement_choices() -> void:

	replacement_choices.clear()


	var available: Array[CharacterData] = []


	for candidate in full_roster:

		var candidate_name: String = (
			candidate.character_name
		)


		# =================================================
		# DO NOT OFFER CURRENT TEAM MEMBERS
		# =================================================

		var already_on_team: bool = false


		for teammate in GameState.selected_team:

			if (
				teammate.character_name
				== candidate_name
			):

				already_on_team = true

				break


		if already_on_team:
			continue


		# =================================================
		# DO NOT OFFER RETIRED CHARACTERS
		# =================================================

		if GameState.retired_character_names.has(
			candidate_name
		):

			continue


		available.append(
			candidate
		)


	available.shuffle()


	var amount_to_offer: int = min(
		4,
		available.size()
	)


	for i in range(
		amount_to_offer
	):

		replacement_choices.append(
			available[i]
		)


	show_replacement_choices()


# =========================================================
# SHOW REPLACEMENT CHOICES
# =========================================================

func show_replacement_choices() -> void:

	clear_character_buttons()


	instruction_label.text = (
		"Sacrifice confirmed. "
		+ "You cannot go back.\n"
		+ "Choose one replacement."
	)


	for i in range(
		replacement_choices.size()
	):

		var character = (
			replacement_choices[i]
		)


		var button = Button.new()


		button.custom_minimum_size = Vector2(
			205,
			150
		)


		button.text = (
			create_character_text(
				character
			)
		)


		button.pressed.connect(
			_on_replacement_pressed.bind(
				i
			)
		)


		character_container.add_child(
			button
		)


# =========================================================
# CHOOSE REPLACEMENT
# =========================================================

func _on_replacement_pressed(
	index: int
) -> void:

	if not sacrifice_confirmed:
		return


	if index < 0:
		return


	if index >= replacement_choices.size():
		return


	var replacement = (
		replacement_choices[
			index
		]
	)


	complete_replacement(
		replacement
	)


# =========================================================
# COMPLETE REPLACEMENT
# =========================================================

func complete_replacement(
	replacement: CharacterData
) -> void:

	if selected_sacrifice_index < 0:
		return


	if selected_sacrifice_index >= GameState.selected_team.size():
		return


	var old_name: String = (
		GameState.sacrificed_character_name
	)


	# =====================================================
	# REPLACE CHARACTER IN TEAM
	# =====================================================

	GameState.selected_team[
		selected_sacrifice_index
	] = replacement


	# =====================================================
	# RECORD REPLACEMENT
	# =====================================================

	GameState.record_replacement(
		old_name,
		replacement.character_name
	)


	print("====================")
	print("CHARACTER REPLACED")
	print("====================")


	print(
		old_name,
		" -> ",
		replacement.character_name
	)


	print(
		replacement.character_name,
		" receives ",
		GameState.replacement_upgrade_picks_remaining,
		" catch-up upgrade pick(s)."
	)


	print("====================")


	go_to_upgrade_screen()


# =========================================================
# SKIP REPLACEMENT
# =========================================================

func _on_skip_pressed() -> void:

	if sacrifice_confirmed:
		return


	print(
		"Replacement skipped."
	)


	go_to_upgrade_screen()


# =========================================================
# TIMER EXPIRED
# =========================================================

func handle_timer_expired() -> void:

	print(
		"Between-round timer expired on replacement screen."
	)


	# =====================================================
	# NO SACRIFICE CONFIRMED
	# =====================================================
	#
	# Automatically skip replacement.
	if not sacrifice_confirmed:

		print(
			"Auto-skipping replacement."
		)


		go_to_upgrade_screen()

		return


	# =====================================================
	# SACRIFICE CONFIRMED
	# =====================================================
	#
	# The player cannot back out after sacrifice.
	# Choose one replacement automatically.
	if replacement_choices.size() > 0:

		var random_index: int = (
			randi()
			% replacement_choices.size()
		)


		var replacement = (
			replacement_choices[
				random_index
			]
		)


		print(
			"Automatically selected replacement: ",
			replacement.character_name
		)


		complete_replacement(
			replacement
		)

		return


# =========================================================
# GO TO UPGRADE SCREEN
# =========================================================

func go_to_upgrade_screen() -> void:

	get_tree().change_scene_to_file(
		"res://Scene/UpgradeSelect.tscn"
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
