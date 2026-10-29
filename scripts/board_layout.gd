extends RefCounted
# Logical x is lane (top to bottom); logical y is depth (back to front).
const LANES: int = 4
const DEPTH: int = 5
const TILE_SIZE: Vector2 = Vector2(70, 70)
static func cell_center(cell: Vector2i, enemy: bool = false) -> Vector2:
	return Vector2(980.0 - cell.y * 75.0 if enemy else 100.0 + cell.y * 75.0, 150.0 + cell.x * 100.0)
static func cell_rect(cell: Vector2i, enemy: bool = false) -> Rect2:
	return Rect2(cell_center(cell, enemy) - TILE_SIZE * 0.5, TILE_SIZE)
