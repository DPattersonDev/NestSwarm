extends Control
## A two-peer, host-authoritative private playtest. ENet over LAN or Tailscale.
const Rules = preload("res://scripts/pvp_rules.gd")
const Catalog = preload("res://scripts/character_catalog.gd")
const Battle = preload("res://scripts/pvp_battle.gd")
const Ghost = preload("res://scripts/pvp_ghost.gd")
const PORT := 24567
const SNAPSHOT_INTERVAL := 0.05
const OFFLINE_FIELDS := ["selected_team", "enemy_team", "character_upgrades", "enemy_character_upgrades", "player_placements", "enemy_placements", "current_round", "player_round_wins", "enemy_round_wins", "last_enemy_formation", "last_enemy_art", "last_enemy_formation_round", "between_round_time_left", "between_round_phase_active", "sacrificed_character_name", "replacement_character_name", "replacement_upgrade_picks_remaining", "replacement_completed_this_phase", "retired_character_names"]
var phase := "lobby"
var is_host := false
var guest_id := 0
var authenticated := false
var connected := false
var round_number := 1
var epoch := 0
var wins := [0, 0]
var ready_slots := {}
var rematch_slots := {}
var teams := {1: [], 2: []}
var placements := {1: [], 2: []}
var loadouts := {1: {}, 2: {}}
var offers := {1: {}, 2: {}}
var local_team: Array = []
var local_cells: Array = [0, 1, 2, 3]
var local_offers := {}
var local_locked := false
var selected_slot := 0
var status: Label
var body: VBoxContainer
var address: LineEdit
var port_input: SpinBox
var pickers: Array[OptionButton] = []
var upgrade_pickers := {}
var cell_buttons: Array[Button] = []
var ready_button: Button
var battle: Node2D
var ghosts := {}
var snapshot_timer := 0.0
var snapshot_sequence := 0
var last_sequence := -1
var remote_view := Node2D.new()
var offline_backup := {}
var connect_started := 0
var handshake_started := 0
var result_deadline := 0
var result_winner := 0
var last_snapshot: Array = []
var battle_roster: Label
var ui_scroll: ScrollContainer

func _ready() -> void:
	name = "PrivatePvp"
	for field in OFFLINE_FIELDS:
		var value = GameState.get(field)
		offline_backup[field] = value.duplicate(true) if value is Array or value is Dictionary else value
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)
	add_child(remote_view)
	_build_shell()
	_show_lobby()

func _exit_tree() -> void:
	_close_network()
	for field in offline_backup:
		GameState.set(field, offline_backup[field])

func _build_shell() -> void:
	var bg := ColorRect.new()
	bg.color = Color("0b1019")
	bg.z_index = -100
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	move_child(bg, 0)
	ui_scroll = ScrollContainer.new()
	ui_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_scroll.offset_left = 24
	ui_scroll.offset_top = 12
	ui_scroll.offset_right = -24
	ui_scroll.offset_bottom = -12
	add_child(ui_scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	ui_scroll.add_child(body)

func _clear_ui() -> void:
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	pickers.clear()
	upgrade_pickers.clear()
	cell_buttons.clear()
	ui_scroll.offset_left = 680 if phase in ["battle", "result", "match_over"] else 24
	status = _text("")
	status.add_theme_color_override("font_color", Color("e9b95d"))

func _text(value: String, parent: Node = body) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 18)
	parent.add_child(label)
	return label

func _button(value: String, callback: Callable, parent: Node = body) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 42
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _show_lobby(message: String = "") -> void:
	phase = "lobby"
	_clear_ui()
	status.text = "NESTSWARM  •  PRIVATE PVP TEST"
	_text("Two Windows PCs • Host and Join • Same game version required")
	_text("Across different Wi-Fi networks: connect through Tailscale first. Enter the host’s Tailscale IP below. No public matchmaking is included.")
	address = LineEdit.new()
	address.placeholder_text = "Host Tailscale IP (100.x.x.x) or LAN IP"
	address.text = "127.0.0.1" if OS.has_feature("editor") else ""
	body.add_child(address)
	port_input = SpinBox.new()
	port_input.min_value = 1024
	port_input.max_value = 65535
	port_input.value = PORT
	body.add_child(port_input)
	_button("Host Match", func(): host_match(int(port_input.value)))
	_button("Join Match", func(): join_match(address.text.strip_edges(), int(port_input.value)))
	_text("Default UDP port: 24567. Allow the game through Windows Firewall on your trusted network. Both players keep Tailscale running.")
	if not message.is_empty():
		_text(message)
	_button("Back to Main Menu", _leave)

func host_match(port: int = PORT) -> void:
	_close_network()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port, 1)
	if error != OK:
		_show_lobby("Cannot host on that port (%s). Try another port." % error_string(error))
		return
	is_host = true
	multiplayer.multiplayer_peer = peer
	phase = "waiting"
	_clear_ui()
	status.text = "Hosting on UDP %d. Waiting for your friend…" % port
	_text("Give your friend your Tailscale IP and this port. Keep this window open.")
	_button("Cancel Hosting", func(): _abort("Hosting cancelled."))

func join_match(host_address: String, port: int = PORT) -> void:
	if host_address.is_empty() or host_address.length() > 253:
		status.text = "Enter the host’s Tailscale or LAN address."
		return
	_close_network()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(host_address, port)
	if error != OK:
		_show_lobby("Cannot connect: %s" % error_string(error))
		return
	is_host = false
	multiplayer.multiplayer_peer = peer
	connect_started = Time.get_ticks_msec()
	phase = "connecting"
	_clear_ui()
	status.text = "Connecting to %s:%d…" % [host_address, port]
	_button("Cancel", func(): _abort("Connection cancelled."))

func _close_network() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	guest_id = 0
	connected = false
	authenticated = false
	connect_started = 0
	handshake_started = 0

func _peer_connected(id: int) -> void:
	if is_host:
		guest_id = id
		handshake_started = Time.get_ticks_msec()

func _connected_to_server() -> void:
	connected = true
	_handshake.rpc_id(1, Rules.BUILD)

@rpc("any_peer", "call_remote", "reliable")
func _handshake(build: String) -> void:
	if not is_host or multiplayer.get_remote_sender_id() != guest_id or authenticated:
		return
	if build != Rules.BUILD:
		_rejected.rpc_id(guest_id, "Game versions do not match. Both players need the same PVP build.")
		return
	authenticated = true
	connected = true
	handshake_started = 0
	_new_match()

@rpc("authority", "call_remote", "reliable")
func _rejected(message: String) -> void:
	_abort(message)

func _new_match() -> void:
	_remove_battle()
	round_number = 1
	wins = [0, 0]
	teams = {1: [], 2: []}
	placements = {1: [], 2: []}
	loadouts = {1: {}, 2: {}}
	offers = {1: {}, 2: {}}
	ready_slots.clear()
	rematch_slots.clear()
	_begin_planning()

func _begin_planning() -> void:
	_remove_battle()
	epoch += 1
	phase = "planning"
	ready_slots.clear()
	for slot in [1, 2]:
		var message := {"round": round_number, "epoch": epoch, "wins": wins, "team": teams[slot], "cells": placements[slot], "offers": offers[slot]}
		if slot == 1:
			_open_planning(message)
		else:
			_open_planning.rpc_id(guest_id, message)

@rpc("authority", "call_remote", "reliable")
func _open_planning(message: Dictionary) -> void:
	_remove_battle()
	phase = "planning"
	round_number = message.round
	epoch = message.epoch
	wins = message.wins
	local_locked = false
	local_team = message.team.duplicate()
	local_cells = message.cells.duplicate() if message.cells.size() == 4 else [0, 1, 2, 3]
	local_offers = message.offers
	if local_team.is_empty():
		local_team = Rules.names().slice(0 if is_host else 5, 4 if is_host else 9)
	_clear_ui()
	status.text = "Round %d  •  Host %d – Friend %d  •  %s" % [round_number, wins[0], wins[1], "You are HOST (lower side)" if is_host else "You are FRIEND (upper side)"]
	_text("Choose four unique characters and four different hexes. Your formation stays private until both players lock in. Teams stay fixed after Round 1.")
	var all_names := Rules.names()
	for i in range(4):
		var row := HBoxContainer.new()
		body.add_child(row)
		var art := TextureRect.new()
		art.custom_minimum_size = Vector2(52, 64)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.texture = UpgradeDatabase.get_character_data(local_team[i]).battle_texture
		row.add_child(art)
		var picker := OptionButton.new()
		picker.custom_minimum_size.x = 290
		for n in all_names:
			picker.add_item(n)
		picker.select(all_names.find(local_team[i]))
		picker.disabled = round_number > 1
		picker.item_selected.connect(func(index: int):
			local_team[i] = all_names[index]
			art.texture = UpgradeDatabase.get_character_data(local_team[i]).battle_texture
		)
		row.add_child(picker)
		pickers.append(picker)
		var cell := OptionButton.new()
		for position_index in range(16):
			cell.add_item("Lane %d  •  %s" % [position_index % 4 + 1, ["Back", "Rear", "Forward", "Front"][position_index / 4]])
		cell.select(local_cells[i])
		cell.item_selected.connect(func(index: int): local_cells[i] = index)
		row.add_child(cell)
		cell_buttons.append(cell)
		if local_offers.has(local_team[i]):
			var upgrade := OptionButton.new()
			upgrade.custom_minimum_size.x = 300
			for choice in local_offers[local_team[i]]:
				upgrade.add_item(choice.name)
				upgrade.set_item_tooltip(upgrade.item_count - 1, choice.description)
			row.add_child(upgrade)
			upgrade_pickers[local_team[i]] = upgrade
	_text("Lane numbers run left to right on the battle screen. Depth runs from your back edge toward the opponent. Matching characters on opposite teams are allowed.")
	if round_number > 1:
		_text("Choose one upgrade for EACH character. Hover over an upgrade for its effect. Reposition before locking in.")
	ready_button = _button("Lock In and Ready", submit_ready)
	_button("Leave Match", _leave)

func submit_ready() -> void:
	if phase != "planning" or local_locked:
		return
	var picks := {}
	for character_name in upgrade_pickers:
		picks[character_name] = upgrade_pickers[character_name].selected
	var payload := {"team": local_team.duplicate(), "cells": local_cells.duplicate(), "picks": picks}
	if is_host:
		_accept_ready(1, epoch, payload)
	else:
		_submit_ready.rpc_id(1, epoch, payload)

@rpc("any_peer", "call_remote", "reliable")
func _submit_ready(submitted_epoch: int, payload: Dictionary) -> void:
	if is_host and authenticated and multiplayer.get_remote_sender_id() == guest_id:
		_accept_ready(2, submitted_epoch, payload)

func _accept_ready(slot: int, submitted_epoch: int, payload: Dictionary) -> void:
	if phase != "planning" or submitted_epoch != epoch or ready_slots.has(slot):
		return
	var problem := Rules.validate(payload, teams[slot], offers[slot])
	if not problem.is_empty():
		if slot == 1:
			_submission_error(problem)
		else:
			_submission_error.rpc_id(guest_id, problem)
		return
	teams[slot] = payload.team.duplicate()
	placements[slot] = payload.cells.duplicate()
	for character_name in offers[slot]:
		if not loadouts[slot].has(character_name):
			loadouts[slot][character_name] = []
		loadouts[slot][character_name].append(offers[slot][character_name][payload.picks[character_name]].duplicate(true))
	ready_slots[slot] = true
	if slot == 1:
		_ready_ack()
	else:
		_ready_ack.rpc_id(guest_id)
	if ready_slots.size() == 2:
		_start_battle.call_deferred()

@rpc("authority", "call_remote", "reliable")
func _submission_error(message: String) -> void:
	status.text = message

@rpc("authority", "call_remote", "reliable")
func _ready_ack() -> void:
	local_locked = true
	ready_button.disabled = true
	for picker in pickers:
		picker.disabled = true
	for picker in cell_buttons:
		picker.disabled = true
	for picker in upgrade_pickers.values():
		picker.disabled = true
	status.text = "Locked in. Waiting for the other player…"

func _start_battle() -> void:
	if phase != "planning" or ready_slots.size() != 2 or not connected:
		return
	phase = "battle"
	GameState.reset_match()
	GameState.current_round = round_number
	GameState.player_round_wins = wins[0]
	GameState.enemy_round_wins = wins[1]
	for n in teams[1]:
		GameState.selected_team.append(UpgradeDatabase.get_character_data(n))
	for n in teams[2]:
		GameState.enemy_team.append(UpgradeDatabase.get_character_data(n))
	GameState.player_placements = Rules.formation(teams[1], placements[1])
	GameState.enemy_placements = Rules.formation(teams[2], placements[2])
	GameState.character_upgrades = loadouts[1].duplicate(true)
	GameState.enemy_character_upgrades = loadouts[2].duplicate(true)
	_show_battle.rpc_id(guest_id, epoch, round_number, wins)
	_battle_ui()
	battle = load("res://game.tscn").instantiate()
	battle.set_script(Battle)
	battle.round_finished.connect(_round_finished)
	add_child(battle)
	move_child(battle, 1)
	# The private mode owns score and result UI.
	battle.score_label.hide()
	battle.winner_label.hide()
	battle.ledger_panel.hide()
	snapshot_sequence = 0
	snapshot_timer = SNAPSHOT_INTERVAL

@rpc("authority", "call_remote", "reliable")
func _show_battle(new_epoch: int, new_round: int, score: Array) -> void:
	_remove_battle()
	phase = "battle"
	epoch = new_epoch
	round_number = new_round
	wins = score
	last_sequence = -1
	var background := TextureRect.new()
	background.position = Vector2(200, 0)
	background.size = Vector2(460, 690)
	background.texture = preload("res://Art/Arenas/Vesper/vesper_hex_arena.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	remote_view.add_child(background)
	_battle_ui()

func _battle_ui() -> void:
	_clear_ui()
	status.text = "Round %d  •  Host %d – Friend %d" % [round_number, wins[0], wins[1]]
	_text("HOST: lower team (blue labels)\nFRIEND: upper team (orange labels)\nYou are %s." % ("HOST" if is_host else "FRIEND"))
	_text("The host runs combat. Both players watch the same positions, health, shields and result.")
	battle_roster = _text("")
	_button("Leave Match", _leave)

func _snapshot() -> Array:
	var result: Array = []
	if not is_instance_valid(battle):
		return result
	for unit in get_tree().get_nodes_in_group("Characters"):
		if unit.get_parent() != battle:
			continue
		result.append({"id": "%d:%s" % [unit.team_id, unit.get_character_name()], "character": unit.get_character_name(), "team": unit.team_id, "position": unit.position, "hp": unit.current_health, "max_hp": unit.max_health, "shield": unit.current_shield, "alive": unit.is_alive, "facing": unit.character_animation.facing, "pose": String(unit.character_animation.current_pose)})
	return result

@rpc("authority", "call_remote", "unreliable_ordered", 1)
func _battle_snapshot(new_epoch: int, sequence: int, units: Array) -> void:
	if phase != "battle" or new_epoch != epoch or sequence <= last_sequence:
		return
	last_sequence = sequence
	last_snapshot = units
	_update_roster(units)
	var active: Array = []
	for unit in units:
		active.append(unit.id)
		if not ghosts.has(unit.id):
			var ghost := Ghost.new()
			remote_view.add_child(ghost)
			ghost.setup(unit)
			ghosts[unit.id] = ghost
		else:
			ghosts[unit.id].apply(unit)
	for id in ghosts.keys():
		if id not in active:
			ghosts[id].queue_free()
			ghosts.erase(id)

func _update_roster(units: Array) -> void:
	if not is_instance_valid(battle_roster):
		return
	var lines: Array[String] = []
	for slot in [1, 2]:
		lines.append("HOST" if slot == 1 else "FRIEND")
		for unit in units:
			if unit.team == slot:
				lines.append("%s: %d / %d HP%s" % [unit.character, unit.hp, unit.max_hp, " + shield" if unit.shield > 0 else ""])
	battle_roster.text = "\n".join(lines)

func _round_finished(winner: int) -> void:
	if phase != "battle":
		return
	if winner > 0:
		wins[winner - 1] += 1
	var units := _snapshot()
	_result.rpc_id(guest_id, epoch, winner, wins, units)
	_result(epoch, winner, wins, units)
	result_deadline = Time.get_ticks_msec() + 3000

@rpc("authority", "call_remote", "reliable")
func _result(new_epoch: int, winner: int, score: Array, units: Array) -> void:
	if new_epoch != epoch or phase != "battle":
		return
	if not is_host:
		_battle_snapshot(epoch, last_sequence + 1, units)
	wins = score
	phase = "match_over" if maxi(wins[0], wins[1]) >= 3 else "result"
	result_winner = winner
	_clear_ui()
	status.text = ("Draw — no point awarded" if winner == 0 else "%s wins %s!" % ["Host" if winner == 1 else "Friend", "the match" if phase == "match_over" else "the round"])
	_text("Host %d – Friend %d" % [wins[0], wins[1]])
	if phase == "match_over":
		_button("Ready for Rematch", request_rematch)
	else:
		_text("Next: upgrades and formation. Both players must lock in again.")
	_button("Leave Match", _leave)

func _next_round() -> void:
	round_number += 1
	var previous_upgrades: Dictionary = GameState.character_upgrades
	for slot in [1, 2]:
		offers[slot] = {}
		GameState.character_upgrades = loadouts[slot]
		for character_name in teams[slot]:
			offers[slot][character_name] = UpgradeDatabase.get_random_three(character_name)
	GameState.character_upgrades = previous_upgrades
	_begin_planning()

func request_rematch() -> void:
	if phase != "match_over":
		return
	if is_host:
		_accept_rematch(1, epoch)
	else:
		_rematch.rpc_id(1, epoch)

@rpc("any_peer", "call_remote", "reliable")
func _rematch(submitted_epoch: int) -> void:
	if is_host and multiplayer.get_remote_sender_id() == guest_id:
		_accept_rematch(2, submitted_epoch)

func _accept_rematch(slot: int, submitted_epoch: int) -> void:
	if phase != "match_over" or submitted_epoch != epoch:
		return
	rematch_slots[slot] = true
	if rematch_slots.size() == 2:
		_new_match()

func _process(delta: float) -> void:
	var now := Time.get_ticks_msec()
	if phase == "connecting" and now - connect_started > 15000:
		_abort("Connection timed out. Check Tailscale, host IP, UDP port and Windows Firewall.")
	if is_host and handshake_started > 0 and now - handshake_started > 10000:
		_abort("Connection handshake timed out. Use the same PVP build on both PCs.")
	if is_host and phase == "battle":
		snapshot_timer += delta
		if snapshot_timer >= SNAPSHOT_INTERVAL:
			snapshot_timer = 0
			snapshot_sequence += 1
			var units := _snapshot()
			_update_roster(units)
			_battle_snapshot.rpc_id(guest_id, epoch, snapshot_sequence, units)
	if is_host and phase == "result" and now >= result_deadline:
		_next_round()

func _remove_battle() -> void:
	if is_instance_valid(battle):
		remove_child(battle)
		battle.queue_free()
	battle = null
	for child in remote_view.get_children():
		remote_view.remove_child(child)
		child.queue_free()
	ghosts.clear()
	last_snapshot.clear()

func _abort(message: String) -> void:
	_close_network()
	_remove_battle()
	_show_lobby(message)

func _peer_disconnected(id: int) -> void:
	if is_host and id == guest_id:
		_abort("Your friend disconnected. The match was cancelled. Host again to restart.")

func _connection_failed() -> void:
	_abort("Could not reach the host. Check Tailscale, address, port and Windows Firewall.")

func _server_disconnected() -> void:
	if not is_host:
		_abort("The host disconnected. The match was cancelled. Join again to restart.")

func _leave() -> void:
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")
