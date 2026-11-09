extends SceneTree

# Run: godot --headless --path . --script res://tests/roster_motion_smoke.gd
# Checks all 30 motion signatures without modifying combat or resource stats.
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	await process_frame
	var packed: PackedScene = load("res://character/Character.tscn")
	var preview: PackedScene = load("res://Scene/AllCharactersAnimationPreview.tscn")
	var roster_holder = preview.instantiate()
	var signatures: Dictionary = {}
	for character_name in roster_holder.preview_roster:
		var data: CharacterData = load("res://Data/" + character_name + ".tres")
		var unit = packed.instantiate()
		unit.character_data = data
		unit.debug_combat_logs = false
		unit.team_id = 1
		unit.position = Vector2(1000, 1000)
		root.add_child(unit)
		unit.set_physics_process(false)
		await process_frame
		var motion = unit.character_animation
		check(motion.enabled, "Animation disabled: " + character_name)
		check(motion.stride_frequency > 0.0, "Invalid stride: " + character_name)
		check(motion.stride_height > 0.0, "Invalid stride height: " + character_name)
		var signature: String = str(snappedf(motion.stride_frequency, 0.001)) + "|" + str(snappedf(motion.stride_height, 0.001))
		signatures[signature] = true
		unit.velocity = Vector2(70, 0)
		motion._process(0.2)
		check(motion.current_pose == &"walk", "Walk not selected: " + character_name)
		motion._process(0.2)
		check(motion.pivot.position.y < 0.0, "Missing walking motion: " + character_name)
		motion.attack()
		check(motion.action == &"attack", "Attack not started: " + character_name)
		check(is_equal_approx(motion.player.speed_scale, 1.0), "Attack timing changed: " + character_name)
		unit.velocity = Vector2.ZERO
		motion._process(0.1)
		check(is_equal_approx(motion.pivot.position.y, 0.0), "Action motion not isolated: " + character_name)
		unit.queue_free()
		await process_frame
	check(signatures.size() >= 10, "Roster motion lacks character variation")
	roster_holder.free()
	print("Roster motion smoke: ", failures, " failures")
	quit(0 if failures == 0 else 1)
