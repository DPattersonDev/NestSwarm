extends SceneTree
const Layout = preload("res://scripts/board_layout.gd")
var failures := 0
func _initialize():
	call_deferred("run")
func run():
	await process_frame
	var state = root.get_node("GameState")
	state.reset_match()
	for n in ["Scyrix", "Kharvos", "Lunara", "Velkara"]:
		state.selected_team.append(load("res://Data/" + n + ".tres"))
	for n in ["Brontis", "Noctren", "Droven", "Virex"]:
		state.enemy_team.append(load("res://Data/" + n + ".tres"))
	state.player_placements = {"Scyrix": Vector2i(0, 3), "Kharvos": Vector2i(2, 2), "Lunara": Vector2i(1, 1), "Velkara": Vector2i(2, 1)}
	state.enemy_placements = {"Brontis": Vector2i(0, 0), "Noctren": Vector2i(3, 2), "Droven": Vector2i(1, 0), "Virex": Vector2i(0, 3)}
	var game = load("res://game.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	var board = game.get_node("HexBattlefield")
	for unit in get_nodes_in_group("Characters"):
		unit.debug_combat_logs = false
	var initial_hp := {}
	for unit in get_nodes_in_group("Characters"):
		initial_hp[unit.get_instance_id()] = unit.current_health
	var damaged := false
	var last_cell := Vector2i(-1, -1)
	var visited := {}
	var engaged := false
	for _frame in range(480):
		await physics_frame
		if not is_instance_valid(board):
			break
		var brontis = game.get_node_or_null("Brontis")
		if brontis != null and board.units.has(brontis.get_instance_id()):
			var cell: Vector2i = board.units[brontis.get_instance_id()].cell
			if brontis.attack_count > 0:
				engaged = true
				break
			if cell != last_cell:
				if visited.has(cell):
					failures += 1
					push_error("Brontis revisited a hex before engaging")
				visited[cell] = true
				last_cell = cell
		var live: Array = []
		for id in board.units:
			var unit = board.units[id].ref.get_ref()
			if not is_instance_valid(unit) or not unit.is_alive:
				continue
			if unit.current_health < initial_hp.get(id, unit.current_health):
				damaged = true
			for other in live:
				if unit.position.distance_to(other.position) < 0.1:
					failures += 1
					push_error("Live characters stacked")
			live.append(unit)
	if not engaged:
		failures += 1
		push_error("Brontis failed to engage within eight seconds")
	if not damaged:
		failures += 1
		push_error("No combat damage delivered")
	print("Brontis routing regression: ", failures, " failures")
	game.queue_free()
	await process_frame
	await create_timer(0.3).timeout
	quit(0 if failures == 0 else 1)
