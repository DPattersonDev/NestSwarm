extends SceneTree
const Layout = preload("res://scripts/board_layout.gd")
var failures := 0
class Unit extends Node2D:
	var is_alive := true
	var velocity := Vector2.ZERO
	var character_data = preload("res://Data/Veyra.tres")
	func get_current_move_speed() -> float:
		return 90.0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func make_unit(board, cell: Vector2i):
	var unit := Unit.new()
	unit.position = Layout.center(cell)
	root.add_child(unit)
	board.register(unit)
	return unit
func run() -> void:
	await process_frame
	var board = preload("res://scripts/arena_board.gd").new()
	root.add_child(board)
	for cell in Layout.global_cells():
		for neighbor in Layout.neighbors(cell):
			check(cell in Layout.neighbors(neighbor), "Hex adjacency must be reciprocal")
	var mover = make_unit(board, Vector2i(0, 6))
	var blocker = make_unit(board, Vector2i(0, 5))
	var victim = make_unit(board, Vector2i(0, 3))
	var path: Array[Vector2i] = board.route(mover, victim, 1.0)
	check(path.size() > 2, "Need an actual route around blocking unit")
	check(not Vector2i(0, 5) in path and not Vector2i(0, 3) in path, "Path crossed an occupied hex")
	for i in range(1, path.size()):
		check(path[i] in Layout.neighbors(path[i - 1]), "Path skipped a hex")
	board.advance(mover, victim, 1.0, 0.01)
	var moving: Dictionary = board.units[mover.get_instance_id()]
	check(board.occupants[moving.cell] == mover.get_instance_id(), "Origin released before arrival")
	check(board.occupants[moving.destination] == mover.get_instance_id(), "Destination not reserved")
	var rival = make_unit(board, Vector2i(2, 6))
	for _frame in range(600):
		board.advance(mover, victim, 1.0, 1.0 / 60.0)
		board.advance(rival, victim, 1.0, 1.0 / 60.0)
		check(mover.position.distance_to(rival.position) > 0.1, "Two movers stacked")
		check(mover.position.distance_to(blocker.position) > 0.1, "Mover crossed blocker")
	check(board.can_attack(mover, victim, 1.0), "Melee never reached a neighboring attack hex")
	check(board.can_attack(rival, victim, 1.0), "Second melee never found a different attack hex")
	board.relocate(mover, victim.position, true)
	check(mover.position != victim.position, "Blink landed in occupied target hex")
	check(mover.position == Layout.center(board.units[mover.get_instance_id()].cell), "Displacement left unit between stones")
	var dead_id: int = blocker.get_instance_id()
	blocker.is_alive = false
	board.prune()
	check(not dead_id in board.occupants.values(), "Death did not release occupancy")
	# An enclosed unit must wait, never squeeze through other characters.
	for unit in [mover, rival, blocker, victim]:
		board.release(unit.get_instance_id())
		unit.queue_free()
	await process_frame
	mover = make_unit(board, Vector2i(0, 7))
	victim = make_unit(board, Vector2i(3, 0))
	var blockers: Array = []
	for cell in Layout.neighbors(Vector2i(0, 7)):
		blockers.append(make_unit(board, cell))
	var before: Vector2 = mover.position
	for _frame in range(60):
		board.advance(mover, victim, 1.0, 1.0 / 60.0)
	check(mover.position == before, "Enclosed unit walked through another unit")
	for unit in blockers + [mover, victim]:
		unit.queue_free()
	board.queue_free()
	await process_frame
	print("Hex navigation smoke: ", failures, " failures")
	quit(0 if failures == 0 else 1)
