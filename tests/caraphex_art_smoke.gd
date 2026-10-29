extends SceneTree

# Check every Caraphex resource, assigned texture, and shared animation opt-in.
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run() -> void:
	await process_frame
	var preview_scene: PackedScene = load("res://Scene/CaraphexAnimationPreview.tscn")
	var preview = preview_scene.instantiate()
	root.add_child(preview)
	await process_frame
	for index in range(preview.preview_roster.size()):
		preview.select_character(index)
		await process_frame
		var unit = preview.character
		var name: String = preview.preview_roster[index]
		var data: CharacterData = unit.character_data
		var controller = unit.character_animation
		var player: AnimationPlayer = unit.get_node("AnimationPlayer")
		check(data.character_name == name, "Wrong resource selected for " + name)
		check(data.battle_texture != null, "Missing artwork: " + name)
		check(controller.enabled, "Animation disabled: " + name)
		check(unit.battle_sprite.visible and not unit.placeholder_visual.visible, "Placeholder visible: " + name)
		var height: float = float(data.battle_texture.get_height()) * unit.battle_sprite.scale.y
		check(is_equal_approx(height, 70.0), "Inconsistent sprite height: " + name)
		var alpha_image: Image = data.battle_texture.get_image()
		check(alpha_image.detect_alpha() != Image.ALPHA_NONE, "Missing transparency: " + name)
		preview.show_clip(&"walk")
		check(player.current_animation == "walk", "Walk failed: " + name)
		preview.show_clip(&"attack")
		check(controller.action == &"attack", "Attack failed: " + name)
		player.advance(0.3)
		await process_frame
		check(controller.action == &"", "Attack did not finish: " + name)
		preview.show_clip(&"hit")
		player.advance(0.2)
		await process_frame
		check(unit.battle_sprite.modulate == Color.WHITE, "Hit flash did not clear: " + name)
		preview.show_clip(&"death")
		check(not unit.is_alive and not unit.is_queued_for_deletion(), "Death timing incorrect: " + name)
		player.advance(0.6)
		check(unit.is_queued_for_deletion(), "Death did not remove sprite: " + name)
		await process_frame
		preview.show_clip(&"idle")
		check(is_instance_valid(preview.character), "Preview could not recreate " + name)
	preview.queue_free()
	await process_frame
	print("Caraphex artwork/animation smoke: ", failures, " failures")
	quit(0 if failures == 0 else 1)
