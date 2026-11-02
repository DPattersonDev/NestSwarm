extends RefCounted
## Network input validation. Never deserialize Resources or trust client stats.
const Catalog = preload("res://scripts/character_catalog.gd")
const Layout = preload("res://scripts/board_layout.gd")
const BUILD := "nestswarm-private-pvp-v1"

static func names() -> Array[String]:
	var result: Array[String] = []
	for data in Catalog.roster():
		result.append(data.character_name)
	return result

static func validate(payload: Dictionary, fixed_team: Array, offers: Dictionary) -> String:
	if payload.size() != 3 or not payload.get("team") is Array or not payload.get("cells") is Array or not payload.get("picks") is Dictionary:
		return "Invalid team submission."
	var team: Array = payload.team
	var cells: Array = payload.cells
	var picks: Dictionary = payload.picks
	if team.size() != 4 or cells.size() != 4 or picks.size() != offers.size():
		return "Choose four characters, four cells and every offered upgrade."
	var allowed := names()
	var seen_names: Array = []
	var seen_cells: Array = []
	for i in range(4):
		if not team[i] is String or team[i] not in allowed or team[i] in seen_names:
			return "Choose four different characters from the roster."
		if not cells[i] is int or cells[i] < 0 or cells[i] >= 16 or cells[i] in seen_cells:
			return "Each character needs its own valid hex."
		seen_names.append(team[i])
		seen_cells.append(cells[i])
	if not fixed_team.is_empty() and team != fixed_team:
		return "Teams stay fixed for this private test match."
	for character_name in offers:
		if not picks.get(character_name) is int:
			return "Choose an upgrade for each character."
		var index: int = picks[character_name]
		if index < 0 or index >= offers[character_name].size():
			return "Invalid upgrade choice."
	return ""

static func formation(team: Array, cells: Array) -> Dictionary:
	var result := {}
	for i in range(team.size()):
		result[team[i]] = Vector2i(int(cells[i]) % 4, int(cells[i]) / 4)
	return result
