extends Node2D
var pulse: float = 0.0
func _ready() -> void:
	z_index = 3
	visible = false
func _process(delta: float) -> void:
	pulse += delta
	visible = get_parent().is_alive and get_parent().current_shield > 0
	if visible:
		queue_redraw()
func _draw() -> void:
	if not visible:
		return
	var radius: float = 36.0 + sin(pulse * 3.0)
	draw_circle(Vector2.ZERO, radius, Color(0.35, 0.75, 1.0, 0.09))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(0.5, 0.85, 1.0, 0.58), 1.5, true)
	draw_arc(Vector2.ZERO, radius - 3, -2.6, -1.5, 12, Color(0.8, 0.95, 1.0, 0.65), 1.5, true)
