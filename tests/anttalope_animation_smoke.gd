extends SceneTree

# Run after importing Art/Animations/{Droven,Kaelor,Nyxis,Syrra,Velkara}.png
# godot --headless --path . --editor --import --quit
# godot --headless --path . --script res://tests/anttalope_animation_smoke.gd

const NAMES := ["Droven", "Kaelor", "Nyxis", "Syrra", "Velkara"]
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _run() -> void:
	await process_frame
	var character_scene: PackedScene = load("res://character/Character.tscn")
	for name in NAMES:
		var atlas_path := "res://Art/Animations/%s.png" % name
		_check(ResourceLoader.exists(atlas_path), "Missing Anttalope atlas: " + atlas_path)
		if not ResourceLoader.exists(atlas_path):
			continue
		var atlas := load(atlas_path) as Texture2D
		_check(atlas != null, "Invalid atlas texture for " + name)
		if atlas == null:
			continue
		_check(atlas.get_width() == 1774 and atlas.get_height() == 887, "Unexpected atlas dimensions for " + name)
		var data := load("res://Data/%s.tres" % name) as CharacterData
		_check(data != null and data.faction == "Anttalope", "Wrong character data for " + name)
		if data == null:
			continue
		var unit = character_scene.instantiate()
		unit.character_data = data
		unit.debug_combat_logs = false
		unit.team_id = 1
		unit.position = Vector2(2000, 2000)
		root.add_child(unit)
		unit.set_physics_process(false)
		await process_frame
		var animator = unit.character_animation
		_check(is_instance_valid(animator.frame_sprite), "No animation frame sprite for " + name)
		if is_instance_valid(animator.frame_sprite):
			animator.play_pose(&"walk", true)
			_check(animator.frame_sprite.visible and animator.frame_sprite.frame < 4, "Walk atlas playback failed: " + name)
			animator.attack()
			_check(animator.frame_sprite.visible and animator.frame_sprite.frame >= 4, "Attack atlas playback failed: " + name)
		unit.queue_free()
		await process_frame
	print("Anttalope sprite atlas smoke: ", failures, " failures")
	quit(0 if failures == 0 else 1)
