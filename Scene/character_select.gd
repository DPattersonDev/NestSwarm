extends Control


# =========================================================
# CHARACTER SELECT TIMER
# =========================================================

# Maximum amount of time the player has
# to choose their starting team.
const CHARACTER_SELECT_TIME_LIMIT: float = 30.0


var character_select_time_left: float = (
	CHARACTER_SELECT_TIME_LIMIT
)


var character_select_timer_active: bool = true


# Prevents the timer and Continue button
# from starting the match at the same time.
var match_starting: bool = false


# =========================================================
# FULL CHARACTER ROSTER
# =========================================================


# =========================================================
# VESPER KINGDOM
# =========================================================

var veyra = preload(
	"res://Data/Veyra.tres"
)

var zekrin = preload(
	"res://Data/Zekrin.tres"
)

var melora = preload(
	"res://Data/Melora.tres"
)

var tharos = preload(
	"res://Data/Tharos.tres"
)

var aurex = preload(
	"res://Data/Aurex.tres"
)


# =========================================================
# ANTTALOPE KINGDOM
# =========================================================

var kaelor = preload(
	"res://Data/Kaelor.tres"
)

var syrra = preload(
	"res://Data/Syrra.tres"
)

var droven = preload(
	"res://Data/Droven.tres"
)

var nyxis = preload(
	"res://Data/Nyxis.tres"
)

var velkara = preload(
	"res://Data/Velkara.tres"
)


# =========================================================
# LEPIDRA KINGDOM - MOTHS
# =========================================================

var lunara = preload(
	"res://Data/Lunara.tres"
)

var vorren = preload(
	"res://Data/Vorren.tres"
)

var noctren = preload(
	"res://Data/Noctren.tres"
)

var solvyr = preload(
	"res://Data/Solvyr.tres"
)

var mavros = preload(
	"res://Data/Mavros.tres"
)


# =========================================================
# FORMICARA DOMINION - ANTS
# =========================================================

var karnyx = preload(
	"res://Data/Karnyx.tres"
)

var raxen = preload(
	"res://Data/Raxen.tres"
)

var vexira = preload(
	"res://Data/Vexira.tres"
)

var tarsik = preload(
	"res://Data/Tarsik.tres"
)

var myraxa = preload(
	"res://Data/Myraxa.tres"
)


# =========================================================
# CARAPHEX - BEETLES
# =========================================================

var brontis = preload(
	"res://Data/Brontis.tres"
)

var kharvos = preload(
	"res://Data/Kharvos.tres"
)

var virex = preload(
	"res://Data/Virex.tres"
)

var ignivar = preload(
	"res://Data/Ignivar.tres"
)

var aurelia = preload(
	"res://Data/Aurelia.tres"
)


# =========================================================
# SCOLYRA - CENTIPEDES
# =========================================================

var mordrax = preload(
	"res://Data/Mordrax.tres"
)

var scyrix = preload(
	"res://Data/Scyrix.tres"
)

var nyzara = preload(
	"res://Data/Nyzara.tres"
)

var veltrix = preload(
	"res://Data/Veltrix.tres"
)

var thesira = preload(
	"res://Data/Thesira.tres"
)


# =========================================================
# FULL ROSTER
# =========================================================

var full_roster: Array[CharacterData] = []


# =========================================================
# DRAFT STATE
# =========================================================

var offered_characters: Array[CharacterData] = []

var selected_characters: Array[CharacterData] = []

var character_buttons: Array[Button] = []


# =========================================================
# UI REFERENCES
# =========================================================

var selection_label: Label

var character_select_timer_label: Label

var start_button: Button


# =========================================================
# STARTUP
# =========================================================

func _ready() -> void:

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


	character_select_time_left = (
		CHARACTER_SELECT_TIME_LIMIT
	)

	character_select_timer_active = true

	match_starting = false


	create_random_offer()

	create_selection_ui()

	update_character_select_timer_display()


# =========================================================
# PROCESS
# =========================================================

func _process(
	delta: float
) -> void:

	if match_starting:
		return


	if not character_select_timer_active:
		return


	character_select_time_left -= delta


	if character_select_time_left <= 0.0:

		character_select_time_left = 0.0

		character_select_timer_active = false


		update_character_select_timer_display()


		handle_character_select_timeout()

		return


	update_character_select_timer_display()


# =========================================================
# RANDOM CHARACTER OFFER
# =========================================================

func create_random_offer() -> void:

	offered_characters.clear()


	var shuffled_roster = (
		full_roster.duplicate()
	)


	shuffled_roster.shuffle()


	for i in range(8):

		offered_characters.append(
			shuffled_roster[i]
		)


# =========================================================
# UI CREATION
# =========================================================

func create_selection_ui() -> void:

	var main_container = VBoxContainer.new()

	add_child(
		main_container
	)


	# Moved upward to make room for timer.
	main_container.position = Vector2(
		150,
		15
	)


	main_container.size = Vector2(
		850,
		610
	)


	# =====================================================
	# TITLE
	# =====================================================

	var title = Label.new()


	title.text = (
		"CHOOSE YOUR TEAM"
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
	# CHARACTER SELECT TIMER
	# =====================================================

	character_select_timer_label = Label.new()


	character_select_timer_label.text = (
		"SELECTION TIME: 30s"
	)


	character_select_timer_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	character_select_timer_label.add_theme_font_size_override(
		"font_size",
		20
	)


	main_container.add_child(
		character_select_timer_label
	)


	# =====================================================
	# SELECTION COUNT
	# =====================================================

	selection_label = Label.new()


	selection_label.text = (
		"Selected: 0 / 4"
	)


	selection_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	selection_label.add_theme_font_size_override(
		"font_size",
		18
	)


	main_container.add_child(
		selection_label
	)


	# =====================================================
	# CHARACTER GRID
	# =====================================================

	var character_grid = GridContainer.new()


	character_grid.columns = 4


	main_container.add_child(
		character_grid
	)


	# =====================================================
	# CHARACTER BUTTONS
	# =====================================================

	for i in range(
		offered_characters.size()
	):

		var character = (
			offered_characters[i]
		)


		var button = Button.new()


		# Reduced slightly so both rows fit
		# comfortably with the new timer.
		button.custom_minimum_size = Vector2(
			200,
			160
		)


		button.text = (
			create_character_card_text(
				character
			)
		)


		button.pressed.connect(
			_on_character_button_pressed.bind(
				i
			)
		)


		character_grid.add_child(
			button
		)


		character_buttons.append(
			button
		)


	# =====================================================
	# CONTINUE TO PLACEMENT
	# =====================================================

	start_button = Button.new()


	start_button.text = (
		"CONTINUE TO PLACEMENT"
	)


	start_button.custom_minimum_size = Vector2(
		250,
		50
	)


	start_button.disabled = true


	start_button.pressed.connect(
		_on_start_battle_pressed
	)


	main_container.add_child(
		start_button
	)


# =========================================================
# CHARACTER CARD TEXT
# =========================================================

func create_character_card_text(
	character: CharacterData
) -> String:

	var card_text: String = ""


	# =====================================================
	# IDENTITY
	# =====================================================

	card_text += (
		character.character_name
	)


	card_text += "\n"


	card_text += (
		character.faction
	)


	card_text += "\n"


	card_text += (
		character.class_role
	)


	card_text += "\n\n"


	# =====================================================
	# HEALTH
	# =====================================================

	card_text += (
		"HP: "
		+ str(
			character.max_health
		)
	)


	card_text += "\n"


	# =====================================================
	# ATTACK DAMAGE
	# =====================================================

	card_text += (
		"ATK: "
		+ str(
			character.damage
		)
	)


	card_text += "\n"


	# =====================================================
	# MOVEMENT SPEED
	# =====================================================

	card_text += (
		"SPEED: "
		+ str(
			character.move_speed
		)
	)


	card_text += "\n"


	# =====================================================
	# ATTACK RANGE
	# =====================================================

	card_text += (
		"RANGE: "
		+ str(
			character.attack_range
		)
	)


	card_text += "\n"


	# =====================================================
	# ATTACK COOLDOWN
	# =====================================================

	card_text += (
		"COOLDOWN: "
		+ "%.2f" % character.attack_cooldown
		+ "s"
	)


	return card_text


# =========================================================
# CHARACTER SELECTION
# =========================================================

func _on_character_button_pressed(
	index: int
) -> void:

	if match_starting:
		return


	if index < 0:
		return


	if index >= offered_characters.size():
		return


	var character = (
		offered_characters[
			index
		]
	)


	# =====================================================
	# REMOVE CHARACTER
	# =====================================================

	if selected_characters.has(
		character
	):

		selected_characters.erase(
			character
		)


	# =====================================================
	# ADD CHARACTER
	# =====================================================

	elif selected_characters.size() < 4:

		selected_characters.append(
			character
		)


	update_selection_ui()


# =========================================================
# UPDATE CHARACTER SELECT UI
# =========================================================

func update_selection_ui() -> void:

	selection_label.text = (
		"Selected: "
		+ str(
			selected_characters.size()
		)
		+ " / 4"
	)


	for i in range(
		character_buttons.size()
	):

		var button = (
			character_buttons[i]
		)


		var character = (
			offered_characters[i]
		)


		if selected_characters.has(
			character
		):

			button.text = (
				"SELECTED\n"
				+ create_character_card_text(
					character
				)
			)


		else:

			button.text = (
				create_character_card_text(
					character
				)
			)


	start_button.disabled = (
		selected_characters.size()
		!= 4
		or match_starting
	)


# =========================================================
# TIMER DISPLAY
# =========================================================

func update_character_select_timer_display() -> void:

	if character_select_timer_label == null:
		return


	var seconds_left: int = (
		int(
			ceil(
				character_select_time_left
			)
		)
	)


	character_select_timer_label.text = (
		"SELECTION TIME: "
		+ str(seconds_left)
		+ "s"
	)


# =========================================================
# CHARACTER SELECT TIMER EXPIRED
# =========================================================

func handle_character_select_timeout() -> void:

	if match_starting:
		return


	print("====================")
	print("CHARACTER SELECT TIMER EXPIRED")
	print("====================")


	auto_fill_remaining_characters()


	update_selection_ui()


	start_new_match()


# =========================================================
# AUTO-FILL REMAINING CHARACTERS
# =========================================================

func auto_fill_remaining_characters() -> void:

	if selected_characters.size() >= 4:
		return


	var available_choices: Array[CharacterData] = []


	for character in offered_characters:

		if not selected_characters.has(
			character
		):

			available_choices.append(
				character
			)


	available_choices.shuffle()


	for character in available_choices:

		if selected_characters.size() >= 4:
			break


		selected_characters.append(
			character
		)


		print(
			"Auto-selected ",
			character.character_name
		)


# =========================================================
# CONTINUE BUTTON
# =========================================================

func _on_start_battle_pressed() -> void:

	if match_starting:
		return


	if selected_characters.size() != 4:
		return


	start_new_match()


# =========================================================
# START NEW MATCH
# =========================================================

func start_new_match() -> void:

	if match_starting:
		return


	if selected_characters.size() != 4:

		auto_fill_remaining_characters()


	if selected_characters.size() != 4:

		print(
			"Character Select Error: Could not create a 4-character team."
		)

		return


	match_starting = true

	character_select_timer_active = false


	start_button.disabled = true


	# =====================================================
	# RESET PREVIOUS MATCH
	# =====================================================

	GameState.reset_match()


	# =====================================================
	# SAVE PLAYER TEAM
	# =====================================================

	GameState.selected_team = (
		selected_characters.duplicate()
	)


	print("====================")
	print("NEW MATCH")
	print("====================")

	print("Selected Team:")


	for character in GameState.selected_team:

		print(
			character.character_name
		)


	print("====================")


	# =====================================================
	# SYNERGY TEST
	# =====================================================

	SynergyManager.print_team_synergies(
		GameState.selected_team
	)


	# =====================================================
	# GO TO PLACEMENT
	# =====================================================

	get_tree().change_scene_to_file(
		"res://Scene/Placement.tscn"
	)
