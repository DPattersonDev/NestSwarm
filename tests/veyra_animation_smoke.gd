extends SceneTree

# Run from the project directory:
# godot --headless --path . --script res://tests/veyra_animation_smoke.gd
var failures: int = 0
var packed: PackedScene

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func make_character(data: CharacterData, team: int, point: Vector2):
	var unit = packed.instantiate()
	unit.character_data = data
	unit.team_id = team
	unit.position = point
	unit.debug_combat_logs = false
	root.add_child(unit)
	unit.set_physics_process(false)
	return unit

func run() -> void:
	await process_frame
	packed = load("res://character/Character.tscn")
	var data: CharacterData = load("res://Data/Veyra.tres")
	var unit = make_character(data, 1, Vector2.ZERO)
	var enemy = make_character(data, 2, Vector2(-100, 0))
	await process_frame
	await process_frame
	var anim = unit.character_animation
	var player: AnimationPlayer = unit.get_node("AnimationPlayer")
	var sprite: Sprite2D = unit.battle_sprite
	check(player.current_animation == "idle", "Veyra must start idle")
	player.advance(1.25)
	check(player.is_playing(), "Idle must continue after one loop")
	unit.velocity = Vector2(64, 0)
	await process_frame
	check(player.current_animation == "walk", "Movement must select walk")
	unit.velocity = Vector2.ZERO
	await process_frame
	check(player.current_animation == "idle", "Stopping must select idle")
	unit.target = enemy
	unit.attack_target()
	check(anim.action == "attack", "Basic attack must trigger animation")
	check(anim.pivot.scale.x == -1, "Attack must face a target on the left")
	check(sprite.position.x > 0, "Thrust must apply a local forward offset")
	check(enemy.current_health < enemy.max_health, "Attack must still damage enemy")
	anim.hit()
	check(anim.action == "attack", "Hit must not cancel a visible attack")
	player.advance(0.3)
	await process_frame
	check(anim.action == &"", "Attack must unlock when finished")
	check(player.current_animation == "idle", "Attack must return to idle")
	unit.take_damage(1)
	check(anim.action == "hit", "Health damage must trigger hit")
	player.advance(0.2)
	await process_frame
	check(sprite.modulate == Color.WHITE, "Hit flash must reset")
	check(sprite.rotation == 0, "Hit rotation must reset")
	unit.take_damage(0)
	check(anim.action == &"", "Zero damage must not trigger hit")
	unit.target = null
	unit.velocity = Vector2.ZERO
	unit.die()
	check(not unit.is_alive, "Death must immediately exclude unit from combat")
	check(not unit.is_queued_for_deletion(), "Death must preserve the sprite until clip finishes")
	check(player.current_animation == "death", "Death must override every pose")
	player.advance(0.6)
	check(unit.is_queued_for_deletion(), "Death clip must remove unit when finished")
	var other_data: CharacterData = data.duplicate()
	other_data.character_name = "Other character"
	other_data.sprite_animations_enabled = false
	var other = make_character(other_data, 1, Vector2(500, 0))
	check(not other.character_animation.enabled, "Other characters must not opt in automatically")
	other.die()
	check(other.is_queued_for_deletion(), "Other characters must keep immediate removal")
	enemy.queue_free()
	await process_frame
	print("Veyra animation smoke: ", failures, " failures")
	quit(0 if failures == 0 else 1)
