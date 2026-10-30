extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func unit(name: String, team: int, at: Vector2):
	var result = load("res://character/Character.tscn").instantiate()
	result.character_data = load("res://Data/" + name + ".tres")
	result.team_id = team
	result.position = at
	result.debug_combat_logs = false
	root.add_child(result)
	result.set_physics_process(false)
	return result
func run() -> void:
	await process_frame
	# Cover every class and characters that previously weighted target scores.
	for name in ["Brontis", "Scyrix", "Zekrin", "Aurex", "Melora", "Solvyr", "Vexira", "Virex"]:
		var actor = unit(name, 1, Vector2(100, 200))
		var near_enemy = unit("Veyra", 2, Vector2(160, 200))
		var far_enemy = unit("Kharvos", 2, Vector2(450, 200))
		await process_frame
		await process_frame
		far_enemy.current_shield = 30
		far_enemy.current_health = 5
		far_enemy.marked_for_team = 1
		actor.set_target(far_enemy)
		actor.attack_timer = 5
		actor._physics_process(0.016)
		check(actor.target == near_enemy, name + " stayed locked on a distant target")
		near_enemy.position = Vector2(650, 200)
		actor._physics_process(0.016)
		check(actor.target == far_enemy, name + " did not redirect to the newly closest enemy")
		near_enemy.position = Vector2(150, 200)
		actor.forced_target = far_enemy
		actor.forced_target_until = actor.combat_time() + 2
		actor._physics_process(0.016)
		check(actor.target == far_enemy, name + " ignored explicit taunt")
		actor.forced_target_until = 0
		actor._physics_process(0.016)
		check(actor.target == near_enemy, name + " kept target after taunt expired")
		near_enemy.untargetable_until = near_enemy.combat_time() + 2
		actor._physics_process(0.016)
		check(actor.target == far_enemy, name + " chose an untargetable enemy")
		for character in [actor, near_enemy, far_enemy]:
			character.queue_free()
		await process_frame
	await create_timer(0.3).timeout
	print("Closest-target smoke: ", failures, " failures")
	quit(0 if failures == 0 else 1)
