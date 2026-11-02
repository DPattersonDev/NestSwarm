extends SceneTree
const Rules = preload("res://scripts/pvp_rules.gd")
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	var team: Array = ["Veyra", "Aurex", "Melora", "Tharos"]
	var payload := {"team": team, "cells": [0, 1, 2, 3], "picks": {}}
	check(Rules.validate(payload, [], {}) == "", "Valid formation accepted")
	for cells in [[0, 0, 2, 3], [-1, 1, 2, 3], [16, 1, 2, 3], [0.0, 1, 2, 3], [0, 1]]:
		var invalid := payload.duplicate(true)
		invalid.cells = cells
		check(Rules.validate(invalid, [], {}) != "", "Invalid cells rejected")
	for names in [["Veyra", "Veyra", "Melora", "Tharos"], ["evil/../file", "Aurex", "Melora", "Tharos"], [12, "Aurex", "Melora", "Tharos"]]:
		var invalid := payload.duplicate(true)
		invalid.team = names
		check(Rules.validate(invalid, [], {}) != "", "Invalid names rejected before resource loading")
	check(Rules.validate(payload, ["Aurex", "Veyra", "Melora", "Tharos"], {}) != "", "Mid-match team changes rejected")
	var offers := {"Veyra": [{"id": "test"}]}
	check(Rules.validate(payload, [], offers) != "", "Missing upgrade rejected")
	payload.picks = {"Veyra": 0}
	check(Rules.validate(payload, [], offers) == "", "Offered index accepted")
	payload.picks.Veyra = 1
	check(Rules.validate(payload, [], offers) != "", "Unoffered index rejected")
	payload.picks = {"Other": 0}
	check(Rules.validate(payload, [], offers) != "", "Forged upgrade key rejected")
	# Both teams may field the same character with distinct loadouts.
	var state = root.get_node("GameState")
	state.reset_match()
	state.character_upgrades = {"Veyra": [{"name": "Host test", "id": "host_test", "health_bonus": 11, "effect_id": "host_effect"}]}
	state.enemy_character_upgrades = {"Veyra": [{"name": "Friend test", "id": "friend_test", "health_bonus": 23, "effect_id": "friend_effect"}]}
	var units: Array = []
	for slot in [1, 2]:
		var unit = load("res://character/Character.tscn").instantiate()
		unit.character_data = load("res://Data/Veyra.tres")
		unit.team_id = slot
		unit.debug_combat_logs = false
		root.add_child(unit)
		unit.set_physics_process(false)
		units.append(unit)
	check(units[0].max_health == units[0].character_data.max_health + 11, "Host stats upgraded")
	check(units[1].max_health == units[1].character_data.max_health + 23, "Friend stats upgraded independently")
	check(units[0].has_effect("host_effect") and not units[0].has_effect("friend_effect"), "Host effect isolated")
	check(units[1].has_effect("friend_effect") and not units[1].has_effect("host_effect"), "Friend effect isolated")
	for unit in units:
		unit.queue_free()
	await process_frame
	state.reset_match()
	check(state.enemy_character_upgrades.is_empty(), "Offline reset clears friend loadout")
	var screen = load("res://Scene/PrivatePvp.tscn").instantiate()
	root.add_child(screen)
	check(screen.phase == "lobby", "PVP screen opens")
	screen.is_host = true
	screen.phase = "planning"
	screen.epoch = 7
	screen._accept_ready(2, 6, {"team": team, "cells": [0, 1, 2, 3], "picks": {}})
	check(screen.ready_slots.is_empty(), "Stale round rejected")
	screen.phase = "battle"
	screen._accept_ready(2, 7, {"team": team, "cells": [0, 1, 2, 3], "picks": {}})
	check(screen.ready_slots.is_empty(), "Wrong phase rejected")
	screen.queue_free()
	await process_frame
	print("Private PVP smoke: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
