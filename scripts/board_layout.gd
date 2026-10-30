extends RefCounted
# Calibrated to the actual stones in vesper_hex_arena.png (1024 x 1536).
# Global cells use image row 0..7; setup cells use depth 0 (back)..3 (front).
const LANES := 4
const DEPTH := 4
const IMAGE_RECT := Rect2(200, 0, 460, 690)
const FLOOR := Rect2(300, 120, 270, 490)
const TILE_SIZE := Vector2(90, 78)
const INVALID := Vector2i(-1, -1)
const ROW_X := [[320, 449, 576, 705], [314, 446, 576, 708], [310, 445, 578, 713], [307, 444, 579, 717], [303, 443, 580, 721], [297, 441, 583, 729], [293, 439, 586, 735], [286, 437, 589, 741]]
const ROW_Y := [324, 439, 563, 688, 823, 966, 1119, 1272]
const ROW_WIDTH := [100, 103, 105, 107, 110, 112, 114, 116]
const ROW_HEIGHT := [108, 114, 120, 124, 130, 136, 142, 146]
static func to_global(cell: Vector2i, enemy: bool = false) -> Vector2i:
	return Vector2i(cell.x, cell.y if enemy else 7 - cell.y)
static func from_global(cell: Vector2i, enemy: bool = false) -> Vector2i:
	return Vector2i(cell.x, cell.y if enemy else 7 - cell.y)
static func valid_global(cell: Vector2i) -> bool:
	return cell.y >= 0 and cell.y < 8 and cell.x >= 0 and cell.x < ROW_X[cell.y].size()
static func is_valid(cell: Vector2i, enemy: bool = false) -> bool:
	return cell.y >= 0 and cell.y < DEPTH and valid_global(to_global(cell, enemy))
static func all_cells(enemy: bool = false) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for depth in range(DEPTH):
		for col in range(LANES):
			var cell := Vector2i(col, depth)
			if is_valid(cell, enemy):
				result.append(cell)
	return result
static func global_cells() -> Array[Vector2i]:
	var result := all_cells(true)
	for cell in all_cells():
		result.append(to_global(cell))
	return result
static func center(cell: Vector2i) -> Vector2:
	return IMAGE_RECT.position + Vector2(ROW_X[cell.y][cell.x], ROW_Y[cell.y]) * IMAGE_RECT.size / Vector2(1024, 1536)
static func cell_center(cell: Vector2i, enemy: bool = false) -> Vector2:
	return center(to_global(cell, enemy))
static func polygon(cell: Vector2i) -> PackedVector2Array:
	var c := center(cell)
	var half := Vector2(ROW_WIDTH[cell.y], ROW_HEIGHT[cell.y]) * IMAGE_RECT.size / Vector2(1024, 1536) * 0.5
	return PackedVector2Array([c + Vector2(0, -half.y), c + Vector2(half.x, -half.y * 0.5), c + Vector2(half.x, half.y * 0.5), c + Vector2(0, half.y), c + Vector2(-half.x, half.y * 0.5), c + Vector2(-half.x, -half.y * 0.5)])
static func cell_rect(cell: Vector2i, enemy: bool = false) -> Rect2:
	var points := polygon(to_global(cell, enemy))
	var result := Rect2(points[0], Vector2.ZERO)
	for point in points:
		result = result.expand(point)
	return result
static func nearest(position: Vector2) -> Vector2i:
	var best := INVALID
	var distance := INF
	for cell in global_cells():
		var d := position.distance_squared_to(center(cell))
		if d < distance:
			distance = d
			best = cell
	return best
static func neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for other in global_cells():
		if other == cell or absi(other.y - cell.y) > 1:
			continue
		if other.y == cell.y:
			if absi(other.x - cell.x) == 1:
				result.append(other)
		elif (cell.y % 2 == 0 and other.x in [cell.x - 1, cell.x]) or (cell.y % 2 == 1 and other.x in [cell.x, cell.x + 1]):
			result.append(other)
	return result
static func backline(position: Vector2, enemy: bool, rows: int) -> bool:
	return from_global(nearest(position), enemy).y < rows
