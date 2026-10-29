extends Node2D
const Layout = preload("res://scripts/board_layout.gd")
var placement: bool = false
func _ready() -> void:
	z_index = 0 if placement else -5
	queue_redraw()
func _draw() -> void:
	# Keep the established arena artwork visible beneath the board.
	draw_style_box(_panel(Color(0.025, 0.045, 0.065, 0.72), Color(0.6, 0.52, 0.31, 0.7)), Rect2(48, 82, 984, 436))
	for enemy in [false, true]:
		var tint := Color("e59180") if enemy else Color("72d3c6")
		for lane in range(Layout.LANES):
			for depth in range(Layout.DEPTH):
				var rect: Rect2 = Layout.cell_rect(Vector2i(lane, depth), enemy)
				var fill := tint
				fill.a = 0.10 if placement else 0.045
				draw_style_box(_panel(fill, Color(tint, 0.55 if placement else 0.23)), rect)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(74, 105), "YOUR SIDE  →", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("9ce7da"))
	draw_string(font, Vector2(821, 105), "←  ENEMY SIDE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("f4a99a"))
	draw_string(font, Vector2(365, 505), "FRONT", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("9ce7da"))
	draw_string(font, Vector2(657, 505), "FRONT", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f4a99a"))
	draw_string(font, Vector2(484, 307), "NEUTRAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.9, 0.85, 0.7, 0.6))
static func _panel(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	return style
