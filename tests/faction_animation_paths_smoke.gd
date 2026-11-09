extends SceneTree

# Verify both faction-folder animation atlases resolve after relocation.
const GROUPS := {
	"Vesper": ["Veyra", "Aurex", "Melora", "Tharos", "Zekrin"],
	"Anttalope": ["Droven", "Kaelor", "Nyxis", "Syrra", "Velkara"]
}
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	var packed: PackedScene = load("res://character/Character.tscn")
	for faction in GROUPS:
		for character_name in GROUPS[faction]:
			var data: CharacterData = load("res://Data/%s.tres" % character_name)
			var path: String = "res://Art/Animations/%s/%s.png" % [faction, character_name]
			if not ResourceLoader.exists(path):
				push_error("Missing faction atlas: " + path)
				failures += 1
				continue
			var unit = packed.instantiate()
			unit.character_data = data
			unit.team_id = 1
			unit.debug_combat_logs = false
			unit.position = Vector2(1800, 1800)
			root.add_child(unit)
			unit.set_physics_process(false)
			await process_frame
			if not is_instance_valid(unit.character_animation.frame_sprite):
				push_error("Animation not loaded: " + character_name)
				failures += 1
			else:
				unit.character_animation.play_pose(&"walk", true)
				if not unit.character_animation.frame_sprite.visible:
					push_error("Walk frames not visible: " + character_name)
					failures += 1
			unit.queue_free()
			await process_frame
	print("Faction animation path smoke: ", failures, " failures")
	quit(0 if failures == 0 else 1)
