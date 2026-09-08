extends Control


# =========================================================
# DEV ENEMY SELECT
# =========================================================
#
# This screen is used for development/testing.
#
# It allows us to choose the exact four characters
# that the opponent will use during the match.
#
# The selected opponent team is saved into:
#
# GameState.enemy_team
#
# Once selected, the same enemy team remains
# for the entire match.
# =========================================================


# =========================================================
# VESPER
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
# ANTTALOPE
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
# LEPIDRA
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
# FORMICARA
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
# CARAPHEX
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
# SCOLYRA
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
# ROSTER
# =========================================================

var full_roster: Array[CharacterData] = []


# =========================================================
# SELECTION STATE
# =========================================================

var selected_enemies: Array[CharacterData] = []

var enemy_buttons: Array[Button] = []


# =========================================================
# UI REFERENCES
# =========================================================

var selection_label: Label
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


	create_enemy_select_ui()


# =========================================================
# CREATE UI
# =========================================================

func create_enemy_select_ui() -> void:

	var main_container = VBoxContainer.new()


	add_child(
		main_container
	)


	main_container.position = Vector2(
		70,
		20
	)


	main_container.size = Vector2(
		1020,
		620
	)


	# =====================================================
	# TITLE
	# =====================================================

	var title = Label.new()


	title.text = (
		"DEV ENEMY SELECT"
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
	# DESCRIPTION
	# =====================================================

	var description = Label.new()


	description.text = (
		"Choose the exact 4 opponents for this test match."
	)


	description.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	description.add_theme_font_size_override(
		"font_size",
		16
	)


	main_container.add_child(
		description
	)


	# =====================================================
	# SELECTION COUNT
	# =====================================================

	selection_label = Label.new()


	selection_label.text = (
		"Selected Enemies: 0 / 4"
	)


	selection_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	selection_label.add_theme_font_size_override(
		"font_size",
		20
	)


	main_container.add_child(
		selection_label
	)


	# =====================================================
	# SCROLL AREA
	# =====================================================

	var scroll_container = ScrollContainer.new()


	scroll_container.custom_minimum_size = Vector2(
		1020,
		430
	)


	scroll_container.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)


	main_container.add_child(
		scroll_container
	)


	# =====================================================
	# CHARACTER GRID
	# =====================================================

	var enemy_grid = GridContainer.new()


	enemy_grid.columns = 5


	enemy_grid.custom_minimum_size = Vector2(
		1000,
		0
	)


	scroll_container.add_child(
		enemy_grid
	)


	# =====================================================
	# CHARACTER BUTTONS
	# =====================================================

	for i in range(
		full_roster.size()
	):

		var character: CharacterData = (
			full_roster[i]
		)


		var button = Button.new()


		button.custom_minimum_size = Vector2(
			195,
			100
		)


		button.text = (
			create_enemy_card_text(
				character
			)
		)


		button.add_theme_font_size_override(
			"font_size",
			13
		)


		button.pressed.connect(
			_on_enemy_button_pressed.bind(
				i
			)
		)


		enemy_grid.add_child(
			button
		)


		enemy_buttons.append(
			button
		)


	# =====================================================
	# START TEST BUTTON
	# =====================================================

	start_button = Button.new()


	start_button.text = (
		"START TEST BATTLE"
	)


	start_button.custom_minimum_size = Vector2(
		300,
		55
	)


	start_button.disabled = true


	start_button.pressed.connect(
		_on_start_test_pressed
	)


	main_container.add_child(
		start_button
	)


# =========================================================
# CHARACTER CARD TEXT
# =========================================================

func create_enemy_card_text(
	character: CharacterData
) -> String:

	return (
		character.character_name
		+ "\n"
		+ character.faction
		+ "\n"
		+ character.class_role
	)


# =========================================================
# ENEMY BUTTON PRESSED
# =========================================================

func _on_enemy_button_pressed(
	index: int
) -> void:

	if index < 0:
		return


	if index >= full_roster.size():
		return


	var character: CharacterData = (
		full_roster[
			index
		]
	)


	# =====================================================
	# REMOVE CHARACTER
	# =====================================================

	if selected_enemies.has(
		character
	):

		selected_enemies.erase(
			character
		)


	# =====================================================
	# ADD CHARACTER
	# =====================================================

	elif selected_enemies.size() < 4:

		selected_enemies.append(
			character
		)


	update_enemy_select_ui()


# =========================================================
# UPDATE UI
# =========================================================

func update_enemy_select_ui() -> void:

	selection_label.text = (
		"Selected Enemies: "
		+ str(
			selected_enemies.size()
		)
		+ " / 4"
	)


	for i in range(
		enemy_buttons.size()
	):

		var button: Button = (
			enemy_buttons[i]
		)


		var character: CharacterData = (
			full_roster[i]
		)


		if selected_enemies.has(
			character
		):

			button.text = (
				"SELECTED\n"
				+ create_enemy_card_text(
					character
				)
			)


		else:

			button.text = (
				create_enemy_card_text(
					character
				)
			)


	start_button.disabled = (
		selected_enemies.size()
		!= 4
	)


# =========================================================
# START TEST BATTLE
# =========================================================

func _on_start_test_pressed() -> void:

	if selected_enemies.size() != 4:
		return


	GameState.enemy_team = (
		selected_enemies.duplicate()
	)


	GameState.enemy_placements.clear()


	print("====================")
	print("DEV ENEMY TEAM")
	print("====================")


	for character in GameState.enemy_team:

		print(
			character.character_name
		)


	print("====================")


	get_tree().change_scene_to_file(
		"res://game.tscn"
	)
