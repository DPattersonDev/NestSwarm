extends Control

const BACKGROUND := preload("res://Art/Menu/veyra_melora.webp")
const BUTTON_SIZE := Vector2(236, 46)


func _ready() -> void:
	var background := TextureRect.new()
	background.name = "Background"
	background.texture = BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var frame := Panel.new()
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame_style := StyleBoxFlat.new()
	frame_style.draw_center = false
	frame_style.border_color = Color("#d9b27755")
	frame_style.set_border_width_all(1)
	frame.add_theme_stylebox_override("panel", frame_style)
	add_child(frame)
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = 18
	frame.offset_top = 18
	frame.offset_right = -18
	frame.offset_bottom = -18

	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_top = 12

	var menu := VBoxContainer.new()
	menu.name = "Menu"
	menu.alignment = BoxContainer.ALIGNMENT_CENTER
	menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_theme_constant_override("separation", 10)
	center.add_child(menu)

	var title := Label.new()
	title.text = "NESTSWARM"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var title_font := SystemFont.new()
	title_font.font_names = PackedStringArray(["Georgia", "Nimbus Roman", "Noto Serif"])
	title_font.font_weight = 700
	title.add_theme_font_override("font", title_font)
	title.add_theme_font_size_override("font_size", 50)
	title.add_theme_color_override("font_color", Color("#ffe4ae"))
	title.add_theme_color_override("font_shadow_color", Color("#190e16"))
	title.add_theme_constant_override("shadow_offset_y", 3)
	menu.add_child(title)

	var divider := ColorRect.new()
	divider.color = Color("#c39860aa")
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	divider.custom_minimum_size = Vector2(118, 1)
	divider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu.add_child(divider)

	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 9)
	menu.add_child(buttons)
	buttons.add_child(_menu_button("PLAY", _on_play_button_pressed, true))
	buttons.add_child(_menu_button("PRIVATE PVP TEST", _on_pvp_button_pressed))
	buttons.add_child(_menu_button("CHARACTERS", _on_character_button_pressed))
	buttons.add_child(_menu_button("SETTINGS", _on_settings_button_pressed))


func _menu_button(text: String, action: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = BUTTON_SIZE
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 16)

	var normal := _button_style(
		Color("#d6a66c") if primary else Color("#19131cee"),
		Color("#f2c689") if primary else Color("#836347")
	)
	var hover := _button_style(
		Color("#f2c992") if primary else Color("#332334"), Color("#e4b677")
	)
	var pressed := _button_style(
		Color("#bf8d56") if primary else Color("#412d3b"), Color("#ffe4ae")
	)
	var focus := _button_style(Color.TRANSPARENT, Color("#ffe4ae"))
	focus.draw_center = false
	focus.set_border_width_all(2)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", focus)
	var text_color := Color("#23150e") if primary else Color("#f2dcb8")
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.add_theme_color_override("font_focus_color", text_color)
	button.add_theme_color_override("font_pressed_color", text_color)
	button.pressed.connect(action)
	return button


func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	return style


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/CharacterSelect.tscn")


func _on_pvp_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/PrivatePvp.tscn")


func _on_character_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/CharacterBrowser.tscn")


func _on_settings_button_pressed() -> void:
	print("Settings pressed")
