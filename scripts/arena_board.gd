extends Node2D
const Layout = preload("res://scripts/board_layout.gd")
const FLOOR: Rect2 = Layout.FLOOR
var placement := false
# Both ends of a moving unit's step remain reserved until it arrives.
var occupants: Dictionary = {}
var units: Dictionary = {}
func _ready() -> void:
	name = "HexBattlefield"
	z_index = 0 if placement else -5
	set_physics_process(not placement)
func _draw() -> void:
	# The artwork IS the battlefield. No opaque board covers the stone floor.
	pass
func _physics_process(_delta: float) -> void:
	prune()
func prune() -> void:
	for id in units.keys():
		var unit = units[id].ref.get_ref()
		if not is_instance_valid(unit) or not unit.is_alive:
			release(id)
func release(id: int) -> void:
	for cell in occupants.keys():
		if occupants[cell] == id:
			occupants.erase(cell)
	units.erase(id)
func register(unit) -> void:
	var id: int = unit.get_instance_id()
	if units.has(id):
		return
	var cell := Layout.nearest(unit.position)
	if occupants.has(cell):
		var best := INF
		for candidate in Layout.global_cells():
			var d: float = unit.position.distance_squared_to(Layout.center(candidate))
			if not occupants.has(candidate) and d < best:
				best = d
				cell = candidate
	occupants[cell] = id
	units[id] = {"ref": weakref(unit), "cell": cell, "destination": Layout.INVALID, "recent": [cell]}
	unit.position = Layout.center(cell)
func free_for(cell: Vector2i, id: int) -> bool:
	return not occupants.has(cell) or occupants[cell] == id
func in_range(unit, victim, position: Vector2, cell: Vector2i, distance: float) -> bool:
	if position.distance_to(victim.position) <= distance:
		return true
	# Melee reaches an adjacent hex even when perspective widens a stone.
	if unit.character_data.class_role not in ["Marksman", "Support"]:
		var target_cell := Layout.nearest(victim.position)
		return target_cell in Layout.neighbors(cell)
	return false
func route(unit, victim, distance: float) -> Array[Vector2i]:
	var id: int = unit.get_instance_id()
	var start: Vector2i = units[id].cell
	var frontier: Array[Vector2i] = [start]
	var previous := {start: Layout.INVALID}
	var cost := {start: 0.0}
	var recent: Array = units[id].recent
	var goal := Layout.INVALID
	var closest := start
	var closest_distance: float = Layout.center(start).distance_squared_to(victim.position)
	while not frontier.is_empty():
		# Dijkstra: a recently visited stone costs more than a fresh detour.
		# Reversing is still legal when it is the only available route.
		var best_index := 0
		for i in range(1, frontier.size()):
			if cost[frontier[i]] < cost[frontier[best_index]]:
				best_index = i
		var cell: Vector2i = frontier[best_index]
		frontier.remove_at(best_index)
		if in_range(unit, victim, Layout.center(cell), cell, distance):
			goal = cell
			break
		var d := Layout.center(cell).distance_squared_to(victim.position)
		if d < closest_distance - 1:
			closest_distance = d
			closest = cell
		for next in Layout.neighbors(cell):
			if not free_for(next, id):
				continue
			var next_cost: float = cost[cell] + 1.0 + (4.0 if next in recent else 0.0)
			if not cost.has(next) or next_cost < cost[next]:
				cost[next] = next_cost
				previous[next] = cell
				if not next in frontier:
					frontier.append(next)
	if goal == Layout.INVALID:
		goal = closest
	var result: Array[Vector2i] = [goal]
	while goal != start:
		goal = previous[goal]
		result.push_front(goal)
	return result
# Returns true only when settled on a hex in attack range.
func advance(unit, victim, distance: float, delta: float) -> bool:
	prune()
	register(unit)
	var id: int = unit.get_instance_id()
	var state: Dictionary = units[id]
	if state.destination == Layout.INVALID:
		if in_range(unit, victim, unit.position, state.cell, distance):
			unit.velocity = Vector2.ZERO
			return true
		var path := route(unit, victim, distance)
		if path.size() < 2:
			unit.velocity = Vector2.ZERO
			return false
		state.destination = path[1]
		occupants[path[1]] = id
	var destination := Layout.center(state.destination)
	var old: Vector2 = unit.position
	unit.position = old.move_toward(destination, unit.get_current_move_speed() * delta)
	unit.velocity = (unit.position - old) / maxf(delta, 0.00001)
	if unit.position.is_equal_approx(destination):
		occupants.erase(state.cell)
		state.cell = state.destination
		state.recent.append(state.cell)
		if state.recent.size() > 6:
			state.recent.pop_front()
		state.destination = Layout.INVALID
		unit.velocity = Vector2.ZERO
		return in_range(unit, victim, unit.position, state.cell, distance)
	return false
func can_attack(unit, victim, distance: float) -> bool:
	register(unit)
	var state: Dictionary = units[unit.get_instance_id()]
	return state.destination == Layout.INVALID and in_range(unit, victim, unit.position, state.cell, distance)
# Displacements must also finish on a free stone. Ordinary charges/knockbacks
# stop at the first blocked hex; explicit blinks/leaps may cross units.
func relocate(unit, desired: Vector2, teleport := false) -> void:
	prune()
	register(unit)
	var id: int = unit.get_instance_id()
	var state: Dictionary = units[id]
	var start: Vector2i = state.cell
	var chosen := start
	var best := Layout.center(start).distance_squared_to(desired)
	if teleport:
		for cell in Layout.global_cells():
			var d := Layout.center(cell).distance_squared_to(desired)
			if free_for(cell, id) and d < best:
				chosen = cell
				best = d
	else:
		# Follow a chain of improving neighboring cells; never cross an occupant.
		for _step in range(8):
			var next_cell := chosen
			for cell in Layout.neighbors(chosen):
				var d := Layout.center(cell).distance_squared_to(desired)
				if free_for(cell, id) and d < best - 1:
					next_cell = cell
					best = d
			if next_cell == chosen:
				break
			chosen = next_cell
	for cell in occupants.keys():
		if occupants[cell] == id:
			occupants.erase(cell)
	occupants[chosen] = id
	state.cell = chosen
	state.destination = Layout.INVALID
	state.recent = [chosen]
	unit.position = Layout.center(chosen)
	unit.velocity = Vector2.ZERO
static func _panel(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	return style
