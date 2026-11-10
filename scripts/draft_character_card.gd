extends Button
## Reusable portrait card for opening draft and between-round replacement.
## Selection is visual only; the parent screen owns all gameplay decisions.

var _selected_overlay: ColorRect
var _border_normal: StyleBoxFlat
var _border_hover: StyleBoxFlat

func setup(character: CharacterData, card_size: Vector2 = Vector2(200, 202)) -> void:
	custom_minimum_size = card_size
	text = ""
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_build_styles()
	var portrait := TextureRect.new()
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.texture = character.battle_texture
	add_child(portrait)

	# This remains below all labels, so the highlight never hides stats.
	_selected_overlay = ColorRect.new()
	_selected_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_selected_overlay.color = Color(0.92, 0.95, 1.0, 0.0)
	_selected_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_selected_overlay)

	var header := ColorRect.new()
	header.color = Color(0.04, 0.06, 0.12, 0.76)
	header.anchor_right = 1.0
	header.offset_bottom = 49.0
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)

	var name_label := Label.new()
	name_label.text = character.character_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.anchor_right = 1.0
	name_label.offset_top = 5.0
	name_label.offset_bottom = 26.0
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_label)

	var role_label := Label.new()
	role_label.text = "%s  ·  %s" % [character.faction, character.class_role]
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_label.anchor_right = 1.0
	role_label.offset_top = 27.0
	role_label.offset_bottom = 45.0
	role_label.add_theme_font_size_override("font_size", 11)
	role_label.add_theme_color_override("font_color", Color(0.83, 0.90, 0.97))
	role_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(role_label)

	var stats_panel := ColorRect.new()
	stats_panel.color = Color(0.04, 0.06, 0.12, 0.89)
	stats_panel.anchor_top = 1.0
	stats_panel.anchor_bottom = 1.0
	stats_panel.anchor_right = 1.0
	stats_panel.offset_top = -64.0
	stats_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stats_panel)

	var stats := Label.new()
	stats.text = "HP %d   ATK %d   SPD %d\nRNG %d    CD %.2fs" % [
		character.max_health,
		character.damage,
		int(character.move_speed),
		int(character.attack_range),
		character.attack_cooldown
	]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats.anchor_top = 1.0
	stats.anchor_bottom = 1.0
	stats.anchor_right = 1.0
	stats.offset_top = -62.0
	stats.offset_bottom = -3.0
	stats.add_theme_font_size_override("font_size", 12)
	stats.add_theme_color_override("font_color", Color.WHITE)
	stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stats)

func _style(bg: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = edge
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	style.content_margin_left = 0.0
	style.content_margin_right = 0.0
	style.content_margin_top = 0.0
	style.content_margin_bottom = 0.0
	return style

func _build_styles() -> void:
	_border_normal = _style(Color(0.10, 0.13, 0.20), Color(0.27, 0.34, 0.43))
	_border_hover = _style(Color(0.12, 0.16, 0.23), Color(0.71, 0.82, 0.96))
	add_theme_stylebox_override("normal", _border_normal)
	add_theme_stylebox_override("hover", _border_hover)
	add_theme_stylebox_override("pressed", _border_hover)
	add_theme_stylebox_override("focus", _style(Color.TRANSPARENT, Color(0.96, 0.96, 1.0)))

func set_card_selected(is_selected: bool) -> void:
	if not is_instance_valid(_selected_overlay):
		return
	_selected_overlay.color = Color(0.89, 0.93, 1.0, 0.24 if is_selected else 0.0)
	var edge := Color(0.95, 0.97, 1.0) if is_selected else Color(0.27, 0.34, 0.43)
	_border_normal.border_color = edge
	_border_normal.set_border_width_all(4 if is_selected else 3)
	_border_hover.border_color = Color.WHITE if is_selected else Color(0.71, 0.82, 0.96)
	queue_redraw()
