extends SceneTree
const Layout = preload("res://scripts/board_layout.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func make_unit(name: String, team: int, cell: Vector2i):
	var unit = load("res://character/Character.tscn").instantiate()
	unit.character_data = load("res://Data/" + name + ".tres")
	unit.team_id = team
	unit.position = Layout.center(cell)
	unit.debug_combat_logs = false
	root.add_child(unit)
	unit.set_physics_process(false)
	return unit
func run() -> void:
	await process_frame
	var board = load("res://scripts/arena_board.gd").new()
	root.add_child(board)
	var tank = make_unit("Brontis", 1, Vector2i(0, 2))
	var near_enemy = make_unit("Kharvos", 2, Vector2i(0, 3))
	var far_enemy = make_unit("Scyrix", 2, Vector2i(2, 7))
	for unit in [tank, near_enemy, far_enemy]:
		board.register(unit)
	await process_frame
	await process_frame
	var health: int = tank.current_health
	var shield: int = tank.current_shield
	check(shield > 0, "Brontis must start shielded")
	tank.set_target(far_enemy)
	tank.set_physics_process(true)
	tank._physics_process(1.0 / 60.0)
	check(tank.target == near_enemy, "Frontliner ignored adjacent enemy to chase distant target")
	check(tank.attack_timer > 0, "Shielded tank did not initiate attack")
	await create_timer(0.2).timeout
	check(tank.attack_count > 0, "Tank never attacked without taking damage")
	check(tank.current_health == health and tank.current_shield == shield, "Fixture should not require incoming damage")
	tank.forced_target = far_enemy
	tank.forced_target_until = tank.combat_time() + 3.0
	tank._physics_process(1.0 / 60.0)
	check(tank.target == far_enemy, "Nearby fallback overrode forced target")
	for unit in [tank, near_enemy, far_enemy]:
		unit.queue_free()
	board.queue_free()
	await process_frame
	await create_timer(0.3).timeout
	print("Frontline engagement smoke: ", failures, " failures")
	quit(0 if failures == 0 else 1)
