extends SceneTree
const Layout = preload("res://scripts/board_layout.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	await process_frame
	var state = root.get_node("GameState")
	state.selected_team.clear()
	for name in ["Veyra", "Aurex", "Melora", "Zekrin"]:
		state.selected_team.append(load("res://Data/" + name + ".tres"))
	state.player_placements.clear()
	var placement = load("res://Scene/Placement.tscn").instantiate()
	root.add_child(placement)
	placement.placement_timer_active = false
	await process_frame
	check(placement.grid_buttons.size() == 16, "Need sixteen player hexes")
	var spots := [Vector2i(0, 3), Vector2i(1, 3), Vector2i(1, 0), Vector2i(2, 0)]
	for i in range(4):
		var cell: Vector2i = spots[i]
		placement.place_character(state.selected_team[i], cell)
		check(state.player_placements[state.selected_team[i].character_name] == cell, "Placement not saved")
		check(placement.grid_buttons[cell].position == Layout.cell_rect(cell).position, "Placement not using shared geometry")
		check(placement.grid_buttons[cell].get_node("CharacterArt").texture != null, "Placed art missing")
	check(not placement.start_round_button.disabled, "Four units must enable start")
	placement.place_character(state.selected_team[0], Vector2i(1, 3))
	check(state.player_placements[state.selected_team[0].character_name] == Vector2i(0, 3), "Occupied hex overwritten")
	placement.place_character(state.selected_team[0], Vector2i(0, 2))
	check(not placement.occupied_cells.has(Vector2i(0, 3)), "Old hex not cleared")
	check(placement.occupied_cells.size() == 4, "Move duplicated unit")
	check(placement.can_place(state.selected_team[0], Vector2i(3, 0)), "Fourth back-row slot must be available")
	var game_script = load("res://game.gd").new()
	for enemy in [false, true]:
		for cell in Layout.all_cells(enemy):
			var world: Vector2 = game_script.enemy_grid_to_world_position(cell) if enemy else game_script.player_grid_to_world_position(cell)
			check(world == Layout.cell_center(cell, enemy), "Setup and combat mapping differ")
	for enemy in [false, true]:
		for cell in Layout.all_cells(enemy):
			check(Layout.backline(Layout.cell_center(cell, enemy), enemy, 2) == (cell.y < 2), "Backline targeting uses wrong row")
	var tile = placement.grid_buttons[Vector2i(0, 0)]
	check(not tile._has_point(Vector2.ZERO), "Rectangular corner must not accept hex drops")
	check(tile._has_point(tile.size * 0.5), "Hex center should be interactive")
	var own_drag := {"character": state.selected_team[0], "source": placement.get_instance_id()}
	check(tile._can_drop_data(tile.size * 0.5, own_drag), "Valid drag rejected")
	tile._drop_data(tile.size * 0.5, own_drag)
	check(state.player_placements[state.selected_team[0].character_name] == Vector2i(0, 0), "Drag drop did not save placement")
	check(not tile._can_drop_data(Vector2.ZERO, {"character": state.selected_team[0], "source": -1}), "Foreign drag accepted")
	state.player_placements["Veyra"] = Vector2i(6, 4)
	game_script.repair_player_formation(state.selected_team)
	check(game_script.formation_valid(state.selected_team, state.player_placements, false), "Previous-board placements were not repaired")
	check(game_script.formation_valid(state.selected_team, {"Veyra": Vector2i(0, 0), "Aurex": Vector2i(1, 0), "Melora": Vector2i(2, 0), "Zekrin": Vector2i(3, 0)}, true), "Enemy back row must accept four units")
	placement.occupied_cells.clear()
	state.player_placements.clear()
	for depth in range(4):
		for i in range(4):
			placement.place_character(state.selected_team[i], Vector2i(i, depth))
		check(placement.occupied_cells.size() == 4, "Full-row placement duplicated units")
		for i in range(4):
			check(state.player_placements[state.selected_team[i].character_name] == Vector2i(i, depth), "Could not place all four characters in a row")
	game_script.free()
	placement.queue_free()
	await process_frame
	var packed = load("res://character/Character.tscn")
	var attacker = packed.instantiate()
	var victim = packed.instantiate()
	attacker.character_data = load("res://Data/Aurex.tres")
	victim.character_data = load("res://Data/Brontis.tres")
	attacker.team_id = 1
	victim.team_id = 2
	attacker.debug_combat_logs = false
	victim.debug_combat_logs = false
	attacker.position = Vector2(100, 200)
	victim.position = Vector2(200, 200)
	root.add_child(attacker)
	root.add_child(victim)
	# Keep physics enabled for valid attacks, but suspend autonomous combat.
	attacker.set_physics_process(false)
	victim.set_physics_process(false)
	await process_frame
	attacker.target = victim
	attacker.set_physics_process(true)
	attacker.attack_timer = 0
	var hp: int = victim.current_health
	var shield: int = victim.current_shield
	attacker.attack_target()
	check(attacker.attack_timer > 0, "Attack cooldown must reserve immediately before await")
	check(victim.current_health == hp and victim.current_shield == shield, "Damage occurred before release/projectile arrival")
	await create_timer(0.22).timeout
	check(victim.current_health < hp or victim.current_shield < shield, "Projectile did not deliver damage")
	check(attacker.attack_count == 1, "Async attack fired repeatedly before cooldown")
	attacker.set_physics_process(false)
	var anim = attacker.character_animation
	check(anim.frame_sprite != null, "Aurex frame prototype missing")
	anim.action = &""
	anim.play_pose(&"walk", true)
	anim.pose_time = 0.31
	anim._update_frame_pose()
	check(anim.frame_sprite.visible and anim.frame_sprite.frame == 2, "Walk must use alternating atlas frames")
	anim.attack()
	anim.pose_time = 0.12
	anim._update_frame_pose()
	check(anim.frame_sprite.frame == 6, "Attack must show weapon-release frame")
	victim.current_shield = 0
	victim.current_health -= 20
	var injured: int = victim.current_health
	victim.heal(7)
	check(victim.current_health == injured + 7, "Healing semantics changed")
	victim.receive_shield(8, 2)
	check(victim.current_shield == 8, "Shield semantics changed")
	# A round ending during anticipation must cancel pending damage.
	attacker.set_physics_process(true)
	attacker.attack_target()
	attacker.set_physics_process(false)
	var before_cancel: int = victim.current_health
	var shield_before_cancel: int = victim.current_shield
	await create_timer(0.25).timeout
	check(victim.current_health == before_cancel and victim.current_shield == shield_before_cancel, "Pending attack damaged after round stop")
	attacker.queue_free()
	victim.queue_free()
	await create_timer(0.8).timeout
	print("Board/combat smoke: ", failures, " failures")
	quit(0 if failures == 0 else 1)
