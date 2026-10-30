extends RefCounted
# Logical x is column; y is depth, from back (0) to front (3).
const LANES: int = 7
const DEPTH: int = 4
const TILE_SIZE := Vector2(64, 64)
const PITCH: float = 68.0
const FLOOR := Rect2(200, 94, 476, 544)
static func cell_center(cell: Vector2i, enemy: bool = false) -> Vector2:
	var row := cell.y if enemy else 7 - cell.y
	return FLOOR.position + Vector2(34 + cell.x * PITCH, 34 + row * PITCH)
static func cell_rect(cell: Vector2i, enemy: bool = false) -> Rect2:
	return Rect2(cell_center(cell, enemy) - TILE_SIZE * 0.5, TILE_SIZE)
static func is_valid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < LANES and cell.y >= 0 and cell.y < DEPTH
static func backline(position: Vector2, enemy: bool, rows: int) -> bool:
	var depth := (position.y - 128.0) / PITCH if enemy else (604.0 - position.y) / PITCH
	return depth < rows - 0.5
