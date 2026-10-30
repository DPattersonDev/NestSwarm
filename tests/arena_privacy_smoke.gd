extends SceneTree
var failures := 0
func check(ok: bool, message: String):
	if not ok:
		failures += 1
		push_error(message)
func _initialize():
	call_deferred("run")
func run():
	await process_frame
	var state = root.get_node("GameState")
	state.reset_match()
	check(state.get_visible_enemy_history().is_empty(), "First round must have no enemy history")
	state.enemy_team.append(load("res://Data/Brontis.tres"))
	state.enemy_placements["Brontis"] = Vector2i(0, 3)
	state.remember_enemy_formation()
	check(state.get_visible_enemy_history().is_empty(), "Current-round formation leaked")
	state.current_round = 2
	state.enemy_placements["Brontis"] = Vector2i(3, 0)
	var past: Dictionary = state.get_visible_enemy_history()
	check(past["cells"]["Brontis"] == Vector2i(0, 3), "History changed with secret current placement")
	past["cells"]["Brontis"] = Vector2i(1, 1)
	check(state.get_visible_enemy_history()["cells"]["Brontis"] == Vector2i(0, 3), "Returned snapshot aliases saved history")
	var board = load("res://scripts/arena_board.gd").new()
	check(not board.placement, "Battle must not draw setup markings")
	var layout = load("res://scripts/board_layout.gd")
	for enemy in [false, true]:
		for lane in range(7):
			for depth in range(4):
				check(board.FLOOR.encloses(layout.cell_rect(Vector2i(lane, depth), enemy)), "Tile extends beyond playable floor")
	root.add_child(board)
	var unit = load("res://character/Character.tscn").instantiate()
	unit.character_data = load("res://Data/Aurex.tres")
	unit.debug_combat_logs = false
	root.add_child(unit)
	unit.set_physics_process(false)
	await process_frame
	var bubble = unit.get_node("ShieldBubble")
	check(not bubble.visible, "Unshielded unit has shield bubble")
	unit.receive_shield(8, 2)
	await process_frame
	await process_frame
	check(bubble.visible, "Shield bubble missing while shield active")
	await create_timer(0.7).timeout
	check(bubble.visible, "Shield bubble vanished while shield was still active")
	unit.position = Vector2(-200, 900)
	board._physics_process(0.016)
	check(unit.position.x >= board.FLOOR.position.x + 32 and unit.position.y <= board.FLOOR.end.y - 32, "Unit left playable floor after knockback")
	unit.current_shield = 0
	await process_frame
	await process_frame
	check(not bubble.visible, "Shield bubble remains after depletion")
	unit.current_health -= 10
	unit.heal(7)
	var found := false
	for child in root.get_children():
		if child.get_script() == load("res://scripts/combat_fx.gd") and child.caption == "+7 HP":
			found = true
	check(found, "Actual healing must display +HP")
	unit.queue_free()
	board.queue_free()
	state.reset_match()
	check(state.last_enemy_formation.is_empty() and state.last_enemy_art.is_empty() and state.last_enemy_formation_round == 0, "New match retained enemy history")
	await create_timer(0.8).timeout
	print("Arena/privacy/status smoke: ", failures, " failures")
	quit(0 if failures == 0 else 1)
