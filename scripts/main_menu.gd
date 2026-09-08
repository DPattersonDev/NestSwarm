extends Control


# =========================================================
# MAIN MENU SETTINGS
# =========================================================

# Button size used across the main menu.
const MENU_BUTTON_SIZE: Vector2 = Vector2(
	320,
	64
)


# =========================================================
# STARTUP
# =========================================================

func _ready() -> void:

	create_main_menu()


# =========================================================
# CREATE MAIN MENU
# =========================================================

func create_main_menu() -> void:

	# =====================================================
	# BACKGROUND
	# =====================================================

	var background = ColorRect.new()

	background.color = Color(
		0.035,
		0.045,
		0.035,
		1.0
	)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(
		background
	)


	# =====================================================
	# DECORATIVE TOP GLOW
	# =====================================================
	#
	# Temporary visual decoration until we add
	# the final NESTSWARM background artwork.

	var top_glow = ColorRect.new()

	top_glow.color = Color(
		0.18,
		0.20,
		0.11,
		0.55
	)

	top_glow.position = Vector2(
		0,
		0
	)

	top_glow.size = Vector2(
		1152,
		115
	)

	add_child(
		top_glow
	)


	# =====================================================
	# MENU PANEL
	# =====================================================

	var menu_panel = PanelContainer.new()

	menu_panel.position = Vector2(
		351,
		105
	)

	menu_panel.size = Vector2(
		450,
		500
	)


	var panel_style = StyleBoxFlat.new()

	panel_style.bg_color = Color(
		0.055,
		0.065,
		0.05,
		0.94
	)

	panel_style.border_color = Color(
		0.38,
		0.35,
		0.18,
		1.0
	)

	panel_style.set_border_width_all(
		2
	)

	panel_style.corner_radius_top_left = 18
	panel_style.corner_radius_top_right = 18
	panel_style.corner_radius_bottom_left = 18
	panel_style.corner_radius_bottom_right = 18

	panel_style.shadow_color = Color(
		0,
		0,
		0,
		0.6
	)

	panel_style.shadow_size = 18


	menu_panel.add_theme_stylebox_override(
		"panel",
		panel_style
	)


	add_child(
		menu_panel
	)


	# =====================================================
	# MENU CONTENT
	# =====================================================

	var menu_container = VBoxContainer.new()

	menu_container.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)

	menu_container.add_theme_constant_override(
		"separation",
		18
	)

	menu_panel.add_child(
		menu_container
	)


	# =====================================================
	# TITLE
	# =====================================================

	var title_label = Label.new()

	title_label.text = (
		"NESTSWARM"
	)

	title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title_label.add_theme_font_size_override(
		"font_size",
		52
	)

	title_label.add_theme_color_override(
		"font_color",
		Color(
			0.92,
			0.82,
			0.42,
			1.0
		)
	)

	menu_container.add_child(
		title_label
	)


	# =====================================================
	# TITLE DIVIDER
	# =====================================================

	var divider = ColorRect.new()

	divider.custom_minimum_size = Vector2(
		340,
		2
	)

	divider.color = Color(
		0.40,
		0.34,
		0.16,
		1.0
	)

	menu_container.add_child(
		divider
	)


	# =====================================================
	# TAGLINE
	# =====================================================

	var tagline_label = Label.new()

	tagline_label.text = (
		"BUILD YOUR SWARM. CONTROL THE BATTLE."
	)

	tagline_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	tagline_label.add_theme_font_size_override(
		"font_size",
		15
	)

	tagline_label.add_theme_color_override(
		"font_color",
		Color(
			0.70,
			0.70,
			0.62,
			1.0
		)
	)

	menu_container.add_child(
		tagline_label
	)


	# =====================================================
	# SPACER
	# =====================================================

	var spacer = Control.new()

	spacer.custom_minimum_size = Vector2(
		1,
		18
	)

	menu_container.add_child(
		spacer
	)


	# =====================================================
	# PLAY BUTTON
	# =====================================================

	var play_button = create_menu_button(
		"PLAY"
	)

	play_button.pressed.connect(
		_on_play_button_pressed
	)

	menu_container.add_child(
		play_button
	)


	# =====================================================
	# CHARACTERS BUTTON
	# =====================================================

	var character_button = create_menu_button(
		"CHARACTERS"
	)

	character_button.pressed.connect(
		_on_character_button_pressed
	)

	menu_container.add_child(
		character_button
	)


	# =====================================================
	# SETTINGS BUTTON
	# =====================================================

	var settings_button = create_menu_button(
		"SETTINGS"
	)

	settings_button.pressed.connect(
		_on_settings_button_pressed
	)

	menu_container.add_child(
		settings_button
	)


	# =====================================================
	# DEVELOPMENT LABEL
	# =====================================================
	#
	# Temporary small footer.
	# We can remove this before release.

	var development_label = Label.new()

	development_label.text = (
		"EARLY DEVELOPMENT BUILD"
	)

	development_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	development_label.add_theme_font_size_override(
		"font_size",
		11
	)

	development_label.add_theme_color_override(
		"font_color",
		Color(
			0.40,
			0.42,
			0.37,
			1.0
		)
	)

	menu_container.add_child(
		development_label
	)


# =========================================================
# CREATE MENU BUTTON
# =========================================================
#
# Creates one reusable styled button.
#
# This keeps PLAY, CHARACTERS, and SETTINGS
# visually consistent.

func create_menu_button(
	button_text: String
) -> Button:

	var button = Button.new()

	button.text = (
		button_text
	)

	button.custom_minimum_size = (
		MENU_BUTTON_SIZE
	)

	button.add_theme_font_size_override(
		"font_size",
		21
	)


	# =====================================================
	# NORMAL STYLE
	# =====================================================

	var normal_style = StyleBoxFlat.new()

	normal_style.bg_color = Color(
		0.10,
		0.11,
		0.08,
		1.0
	)

	normal_style.border_color = Color(
		0.32,
		0.29,
		0.15,
		1.0
	)

	normal_style.set_border_width_all(
		2
	)

	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8


	# =====================================================
	# HOVER STYLE
	# =====================================================

	var hover_style = StyleBoxFlat.new()

	hover_style.bg_color = Color(
		0.22,
		0.20,
		0.10,
		1.0
	)

	hover_style.border_color = Color(
		0.82,
		0.70,
		0.28,
		1.0
	)

	hover_style.set_border_width_all(
		2
	)

	hover_style.corner_radius_top_left = 8
	hover_style.corner_radius_top_right = 8
	hover_style.corner_radius_bottom_left = 8
	hover_style.corner_radius_bottom_right = 8


	# =====================================================
	# PRESSED STYLE
	# =====================================================

	var pressed_style = StyleBoxFlat.new()

	pressed_style.bg_color = Color(
		0.30,
		0.26,
		0.11,
		1.0
	)

	pressed_style.border_color = Color(
		0.95,
		0.82,
		0.34,
		1.0
	)

	pressed_style.set_border_width_all(
		2
	)

	pressed_style.corner_radius_top_left = 8
	pressed_style.corner_radius_top_right = 8
	pressed_style.corner_radius_bottom_left = 8
	pressed_style.corner_radius_bottom_right = 8


	# =====================================================
	# APPLY BUTTON STYLES
	# =====================================================

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


	button.add_theme_color_override(
		"font_color",
		Color(
			0.88,
			0.85,
			0.68,
			1.0
		)
	)

	button.add_theme_color_override(
		"font_hover_color",
		Color(
			1.0,
			0.91,
			0.48,
			1.0
		)
	)

	button.add_theme_color_override(
		"font_pressed_color",
		Color(
			1.0,
			0.95,
			0.68,
			1.0
		)
	)


	return button


# =========================================================
# PLAY
# =========================================================

# Starts a new game by opening
# the Character Select screen.

func _on_play_button_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://Scene/CharacterSelect.tscn"
	)


# =========================================================
# CHARACTERS
# =========================================================

# Character roster screen will be
# connected here when we build it.

func _on_character_button_pressed() -> void:

	print(
		"Characters pressed"
	)


# =========================================================
# SETTINGS
# =========================================================

# Settings screen will be
# connected here when we build it.

func _on_settings_button_pressed() -> void:

	print(
		"Settings pressed"
	)
