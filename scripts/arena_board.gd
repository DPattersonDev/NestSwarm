extends Node2D
const Layout = preload("res://scripts/board_layout.gd")
var placement: bool = false
const FLOOR: Rect2 = Layout.FLOOR
func _ready() -> void:
	z_index = 0 if placement else -5
	set_physics_process(not placement)
	queue_redraw()
func _physics_process(_delta: float) -> void:
	# Keep knockbacks and dashes on the playable floor, not the decorative walls.
	var safe := FLOOR.grow(-32)
	for unit in get_tree().get_nodes_in_group("Characters"):
		if unit.get_parent() == get_parent() and unit.is_alive:
			unit.position = unit.position.clamp(safe.position, safe.end)
func _draw() -> void:
	# Same tile floor in planning and combat; the hive illustration frames it.
	draw_style_box(_panel(Color("241b13"), Color("cda453")), FLOOR.grow(18))
	draw_style_box(_panel(Color("3a2a18"), Color("765431")), FLOOR.grow(7))
	for enemy in [true, false]:
		for column in range(Layout.LANES):
			for depth in range(Layout.DEPTH):
				var rect: Rect2 = Layout.cell_rect(Vector2i(column, depth), enemy)
				var fill := Color("382c20") if enemy else Color("55402a")
				var edge := Color("685236") if enemy else Color("b18b48")
				if (column + depth) % 2 == 0:
					fill = fill.lightened(0.035)
				draw_style_box(_panel(fill, edge), rect)
	# A central gold seam separates the two deployment halves.
	draw_line(Vector2(202, 366), Vector2(674, 366), Color("f3cf78"), 3, true)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(320, 92), "VESPER • HIVE ARENA", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("f3cf78"))
	if placement:
		draw_string(font, Vector2(344, 265), "ENEMY POSITIONS HIDDEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("c3ad88"))
		draw_string(font, Vector2(378, 673), "YOUR TEAM  ↑", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ffe1a1"))
static func _panel(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	return style
