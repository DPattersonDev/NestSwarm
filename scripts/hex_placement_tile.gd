extends Button
var placement_ui: Control
var cell := Vector2i(-1, -1)
var character_data: CharacterData
var points := PackedVector2Array()
var selected := false
var available := false
var blocked := false
func _ready() -> void:
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
func _has_point(point: Vector2) -> bool:
	if points.is_empty():
		return Rect2(Vector2.ZERO, size).has_point(point)
	return Geometry2D.is_point_in_polygon(point, points)
func _draw() -> void:
	if points.is_empty():
		return
	if is_hovered() or selected or available:
		var tint := Color("ef7c66") if blocked and is_hovered() else Color("ffe09a")
		draw_colored_polygon(points, Color(tint, 0.16 if is_hovered() or selected else 0.025))
		var outline := points.duplicate()
		outline.append(points[0])
		draw_polyline(outline, Color(tint, 1.0 if is_hovered() or selected else 0.38), 2 if is_hovered() or selected else 1, true)
func _get_drag_data(_at: Vector2):
	if placement_ui.round_starting:
		return null
	var data: CharacterData = character_data if points.is_empty() else placement_ui.occupied_cells.get(cell)
	if data == null:
		return null
	placement_ui._on_character_button_pressed(data)
	var preview := TextureRect.new()
	preview.texture = data.battle_texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(70, 70)
	preview.modulate.a = 0.85
	set_drag_preview(preview)
	return {"character": data, "source": placement_ui.get_instance_id()}
func _can_drop_data(_at: Vector2, data) -> bool:
	return not points.is_empty() and data is Dictionary and data.get("source") == placement_ui.get_instance_id() and placement_ui.can_place(data.get("character"), cell)
func _drop_data(_at: Vector2, data) -> void:
	placement_ui.place_character(data.character, cell)
