extends Control
# A small, non-interactive reference; never reads enemy_placements.
var snapshot: Dictionary = {}
func _ready() -> void:
	tooltip_text = "Previous round only. The opponent can move every character before the next battle."
	queue_redraw()
func _draw() -> void:
	var style = preload("res://scripts/arena_board.gd")._panel(Color("282b31"), Color("60584c"))
	draw_style_box(style, Rect2(Vector2.ZERO, Vector2(220, 215)))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(14, 24), "Previous formation", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("d7c4ad"))
	draw_string(font, Vector2(14, 43), "Round %d • may change" % snapshot["round"] if not snapshot.is_empty() else "No previous round", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("999da6"))
	for lane in range(4):
		for depth in range(5):
			var center := mini_center(Vector2i(lane, depth))
			draw_rect(Rect2(center - Vector2(16, 16), Vector2(32, 32)), Color("35363a"))
			draw_rect(Rect2(center - Vector2(16, 16), Vector2(32, 32)), Color("655b51"), false, 1)
	if snapshot.is_empty():
		return
	for unit_name in snapshot["cells"]:
		var texture: Texture2D = snapshot["art"].get(unit_name)
		if texture == null:
			continue
		var dimensions := Vector2(texture.get_size()) * (28.0 / texture.get_height())
		var center := mini_center(snapshot["cells"][unit_name])
		draw_texture_rect(texture, Rect2(center - dimensions * 0.5, dimensions), false, Color(1, 1, 1, 0.75))
func mini_center(cell: Vector2i) -> Vector2:
	# Enemy front is left, matching the actual battlefield.
	return Vector2(38 + (4 - cell.y) * 36, 69 + cell.x * 36)
