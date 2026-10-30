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
	check(placement.grid_buttons.size() == 28, "Need twenty-eight clickable squares")
	for i in range(4):
		var cell := Vector2i(i, 3 if i < 2 else 0)
		placement._on_character_button_pressed(state.selected_team[i])
		placement._on_grid_button_pressed(cell)
		check(state.player_placements[state.selected_team[i].character_name] == cell, "Placement not saved")
		check(placement.grid_buttons[cell].position == Layout.cell_rect(cell).position, "Placement not using shared geometry")
		check(placement.grid_buttons[cell].get_node("CharacterArt").texture != null, "Placed art missing")
	check(not placement.start_round_button.disabled, "Four units must enable start")
	placement._on_character_button_pressed(state.selected_team[0])
	placement._on_grid_button_pressed(Vector2i(1, 3))
	check(state.player_placements[state.selected_team[0].character_name] == Vector2i(0, 3), "Occupied cell overwrote another character")
	placement._on_grid_button_pressed(Vector2i(0, 2))
	check(not placement.occupied_cells.has(Vector2i(0, 3)), "Old square not cleared")
	check(placement.occupied_cells.size() == 4, "Move duplicated unit")
	var game_script = load("res://game.gd").new()
	for lane in range(7):
		for depth in range(4):
			var cell := Vector2i(lane, depth)
			check(game_script.player_grid_to_world_position(cell) == Layout.cell_center(cell), "Player combat mapping mismatch")
			check(game_script.enemy_grid_to_world_position(cell) == Layout.cell_center(cell, true), "Enemy combat mapping mismatch")
	# New orientation: front rows meet at the center, back rows face away.
	check(Layout.cell_center(Vector2i(0, 0)).y > Layout.cell_center(Vector2i(0, 3)).y, "Player front must be above back")
	check(Layout.cell_center(Vector2i(0, 0), true).y < Layout.cell_center(Vector2i(0, 3), true).y, "Enemy front must be below back")
	for enemy in [false, true]:
		for depth in range(Layout.DEPTH):
			check(Layout.backline(Layout.cell_center(Vector2i(2, depth), enemy), enemy, 2) == (depth < 2), "Backline targeting uses wrong axis")
	var arena = load("res://scripts/arena_board.gd").new()
	root.add_child(arena)
	for cell in placement.grid_buttons:
		check(placement.grid_buttons[cell].global_position == Layout.cell_rect(cell).position, "Placement square moved away from combat tile")
	arena.queue_free()
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
