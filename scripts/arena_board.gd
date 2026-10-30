extends Node2D
const Layout = preload("res://scripts/board_layout.gd")
var placement: bool = false
const FLOOR := Rect2(48, 110, 984, 400)
func _ready() -> void:
	z_index = 0 if placement else -5
	set_physics_process(not placement)
	queue_redraw()
func _physics_process(_delta: float) -> void:
	# Keep knockbacks and dashes on the playable floor, not the decorative walls.
	var safe := FLOOR.grow(-35)
	for unit in get_tree().get_nodes_in_group("Characters"):
		if unit.get_parent() == get_parent() and unit.is_alive:
			unit.position = unit.position.clamp(safe.position, safe.end)
func _draw() -> void:
	# An actual opaque floor covers holes/walls in the old background illustration.
	draw_style_box(_panel(Color("2d2821"), Color("aa8950")), Rect2(32, 80, 440 if placement else 1016, 460))
	var shown_floor := Rect2(48, 110, 400, 400) if placement else FLOOR
	draw_style_box(_panel(Color("423b2d"), Color("786b47")), shown_floor)
	for row in range(5):
		for col in range(13):
			var center := Vector2(86 + col * 75 + (37 if row % 2 else 0), 145 + row * 76)
			if not shown_floor.grow(-25).has_point(center):
				continue
			var hex := PackedVector2Array()
			for i in range(7):
				hex.append(center + Vector2(34, 0).rotated(i * TAU / 6))
			draw_polyline(hex, Color(0.7, 0.6, 0.36, 0.13), 1, true)
	# Combat has no setup grid, labels, neutral panel or formation ghosts.
	if not placement:
		return
	var tint := Color("72d3c6")
	for lane in range(Layout.LANES):
		for depth in range(Layout.DEPTH):
			var rect: Rect2 = Layout.cell_rect(Vector2i(lane, depth))
			draw_style_box(_panel(Color(tint, 0.08), Color(tint, 0.4)), rect)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(74, 104), "YOUR PLACEMENT  →", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("9ce7da"))
	draw_string(font, Vector2(365, 528), "FRONT →", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("9ce7da"))
static func _panel(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	return style
