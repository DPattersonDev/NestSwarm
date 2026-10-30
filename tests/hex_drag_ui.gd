extends SceneTree
const Layout = preload("res://scripts/board_layout.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func mouse(at: Vector2, held: bool, press := -1) -> void:
	var event: InputEventMouse
	if press >= 0:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = press == 1
		event = click
	else:
		var motion := InputEventMouseMotion.new()
		motion.relative = Vector2(30, 30)
		event = motion
	event.position = at
	event.global_position = at
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if held else 0
	root.push_input(event, true)
	await process_frame
	await process_frame
func drag(from: Vector2, to: Vector2) -> void:
	await mouse(from, false)
	await mouse(from, true, 1)
	await mouse(from + Vector2(30, -20), true)
	check(root.gui_is_dragging(), "Native drag never started")
	await mouse(to, true)
	await mouse(to, false, 0)
	await process_frame
func run() -> void:
	root.size = Vector2i(1152, 760)
	await process_frame
	var state = root.get_node("GameState")
	state.reset_match()
	for n in ["Veyra", "Aurex", "Melora", "Zekrin"]:
		state.selected_team.append(load("res://Data/" + n + ".tres"))
	var placement = load("res://Scene/Placement.tscn").instantiate()
	root.add_child(placement)
	placement.placement_timer_active = false
	await process_frame
	var a := Vector2i(0, 0)
	var b := Vector2i(1, 1)
	await drag(Vector2(100, 725), Layout.cell_center(a))
	check(state.player_placements.get("Veyra") == a, "Bench-to-hex drop failed")
	await drag(Layout.cell_center(a), Layout.cell_center(b))
	check(state.player_placements.get("Veyra") == b, "Placed character could not be dragged")
	await drag(Layout.cell_center(b), Layout.cell_center(Vector2i(0, 0), true))
	check(state.player_placements.get("Veyra") == b, "Enemy half accepted placement")
	await drag(Vector2(280, 725), Layout.cell_center(a))
	await drag(Layout.cell_center(b), Layout.cell_center(a))
	check(state.player_placements.get("Veyra") == b and state.player_placements.get("Aurex") == a, "Occupied drop moved or stacked characters")
	await drag(Layout.cell_center(b), Vector2(1100, 600))
	check(state.player_placements.get("Veyra") == b, "Off-board drop lost character")
	placement.queue_free()
	await process_frame
	print("Native hex drag UI: ", failures, " failures")
	quit(0 if failures == 0 else 1)
