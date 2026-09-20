extends Control


# =========================================================
# DEV ENEMY SELECT
# =========================================================
#
# Development-only enemy selection screen.
#
# Layout:
#
#                 Vanguard   Fighter   Assassin   Marksman   Support
#
# Vesper
# Anttalope
# Lepidra
# Formicara
# Caraphex
# Scolyra
#
# This keeps factions grouped together while also lining
# up every class vertically for fast testing.
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
# DISPLAY ORDER
# =========================================================

const FACTION_ORDER: Array[String] = [
	"Vesper",
	"Anttalope",
	"Lepidra",
	"Formicara",
	"Caraphex",
	"Scolyra"
]


const CLASS_ORDER: Array[String] = [
	"Vanguard",
	"Fighter",
	"Assassin",
	"Marksman",
	"Support"
]


# =========================================================
# ROSTER
# =========================================================

var full_roster: Array[CharacterData] = []


# =========================================================
# SELECTION STATE
# =========================================================

var selected_enemies: Array[CharacterData] = []

# Stores:
# CharacterData -> Button
var button_by_character: Dictionary = {}


# =========================================================
# UI REFERENCES
# =========================================================

var selection_label: Label
var start_button: Button


# =========================================================
# STARTUP
# =========================================================

func _ready() -> void:

	create_roster()

	create_enemy_select_ui()


# =========================================================
# CREATE FULL ROSTER
# =========================================================

func create_roster() -> void:

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

func create_enemy_select_ui() -> void:

	var main_container = VBoxContainer.new()


	add_child(
		main_container
	)


	main_container.position = Vector2(
		35,
		15
	)


	main_container.size = Vector2(
		1080,
		625
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
		28
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
		15
	)


	main_container.add_child(
		description
	)


	# =====================================================
	# SELECTED COUNT
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
		18
	)


	main_container.add_child(
		selection_label
	)


	# =====================================================
	# CLASS HEADERS
	# =====================================================

	var header_row = HBoxContainer.new()


	header_row.custom_minimum_size = Vector2(
		1060,
		42
	)


	main_container.add_child(
		header_row
	)


	var blank_header = Label.new()


	blank_header.custom_minimum_size = Vector2(
		125,
		42
	)


	header_row.add_child(
		blank_header
	)


	for role_name in CLASS_ORDER:

		var class_header = Label.new()


		class_header.text = (
			role_name.to_upper()
		)


		class_header.custom_minimum_size = Vector2(
			184,
			42
		)


		class_header.horizontal_alignment = (
			HORIZONTAL_ALIGNMENT_CENTER
		)


		class_header.vertical_alignment = (
			VERTICAL_ALIGNMENT_CENTER
		)


		class_header.add_theme_font_size_override(
			"font_size",
			13
		)


		header_row.add_child(
			class_header
		)


	# =====================================================
	# SCROLL AREA
	# =====================================================

	var scroll_container = ScrollContainer.new()


	scroll_container.custom_minimum_size = Vector2(
		1060,
		420
	)


	scroll_container.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)


	main_container.add_child(
		scroll_container
	)


	# =====================================================
	# FACTION ROW CONTAINER
	# =====================================================

	var faction_container = VBoxContainer.new()


	faction_container.custom_minimum_size = Vector2(
		1040,
		0
	)


	scroll_container.add_child(
		faction_container
	)


	# =====================================================
	# CREATE EACH FACTION ROW
	# =====================================================

	for faction_name in FACTION_ORDER:

		create_faction_row(
			faction_container,
			faction_name
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
		52
	)


	start_button.disabled = true


	start_button.pressed.connect(
		_on_start_test_pressed
	)


	main_container.add_child(
		start_button
	)


# =========================================================
# CREATE FACTION ROW
# =========================================================

func create_faction_row(
	parent: VBoxContainer,
	faction_name: String
) -> void:

	var row = HBoxContainer.new()


	row.custom_minimum_size = Vector2(
		1040,
		82
	)


	parent.add_child(
		row
	)


	# =====================================================
	# FACTION LABEL
	# =====================================================

	var faction_label = Label.new()


	faction_label.text = (
		faction_name.to_upper()
	)


	faction_label.custom_minimum_size = Vector2(
		125,
		80
	)


	faction_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


	faction_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)


	faction_label.add_theme_font_size_override(
		"font_size",
		13
	)


	row.add_child(
		faction_label
	)


	# =====================================================
	# ONE CHARACTER PER CLASS
	# =====================================================

	for role_name in CLASS_ORDER:

		var character: CharacterData = (
			find_character(
				faction_name,
				role_name
			)
		)


		if character == null:

			var missing = Label.new()


			missing.text = (
				"MISSING"
			)


			missing.custom_minimum_size = Vector2(
				184,
				80
			)


			missing.horizontal_alignment = (
				HORIZONTAL_ALIGNMENT_CENTER
			)


			missing.vertical_alignment = (
				VERTICAL_ALIGNMENT_CENTER
			)


			row.add_child(
				missing
			)


			continue


		var button: Button = (
			create_character_button(
				character
			)
		)


		row.add_child(
			button
		)


# =========================================================
# FIND CHARACTER BY FACTION + CLASS
# =========================================================

func find_character(
	faction_name: String,
	role_name: String
) -> CharacterData:

	for character in full_roster:

		if character.faction != faction_name:
			continue


		if character.class_role != role_name:
			continue


		return character


	return null


# =========================================================
# CREATE CHARACTER BUTTON
# =========================================================

func create_character_button(
	character: CharacterData
) -> Button:

	var button = Button.new()


	button.custom_minimum_size = Vector2(
		184,
		80
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
			character
		)
	)


	button_by_character[
		character
	] = button


	return button


# =========================================================
# CHARACTER CARD TEXT
# =========================================================

func create_enemy_card_text(
	character: CharacterData
) -> String:

	return (
		character.character_name
		+ "\n"
		+ character.class_role
	)


# =========================================================
# ENEMY BUTTON PRESSED
# =========================================================

func _on_enemy_button_pressed(
	character: CharacterData
) -> void:

	if character == null:
		return


	if selected_enemies.has(
		character
	):

		selected_enemies.erase(
			character
		)


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


	for character in button_by_character.keys():

		var button: Button = (
			button_by_character[
				character
			]
		)


		if selected_enemies.has(
			character
		):

			button.text = (
				"SELECTED\n"
				+ character.character_name
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
