extends Node

# Each prepared character can reuse these whole-sprite animations.
# Layered art or sprite frames can replace the clips later.
@onready var character = get_parent()
@onready var player: AnimationPlayer = character.get_node("AnimationPlayer")
@onready var pivot: Node2D = character.get_node("VisualPivot")
@onready var sprite: Sprite2D = pivot.get_node("BattleSprite")

var frame_sprite: Sprite2D
var pose_time: float = 0.0
var current_pose: StringName = &"idle"

var enabled: bool = false
var action: StringName = &""
var facing: float = 1.0
var arena_scale: float = 1.0

func setup() -> void:
	arena_scale = 0.8 if character.hex_battlefield() != null else 1.0
	pivot.scale = Vector2.ONE * arena_scale

	enabled = (
		character.character_data != null
		and character.character_data.sprite_animations_enabled
		and sprite.texture != null
	)
	if enabled:
		var atlas_path: String = "res://Art/Animations/" + character.character_data.character_name + ".png"
		if ResourceLoader.exists(atlas_path):
			frame_sprite = Sprite2D.new()
			frame_sprite.texture = load(atlas_path)
			frame_sprite.hframes = 4
			frame_sprite.vframes = 2
			var factor: float = 70.0 / (float(frame_sprite.texture.get_height()) / 2.0)
			frame_sprite.scale = Vector2(factor, factor)
			frame_sprite.visible = false
			pivot.add_child(frame_sprite)
		player.animation_finished.connect(_on_animation_finished)
		play_pose(&"idle")

# Read actual movement without changing targeting, damage, or attack timers.
func _process(_delta: float) -> void:
	pose_time += _delta
	_update_frame_pose()

	if not enabled or not character.is_alive or action != &"":
		return
	face_target()
	if character.velocity.length_squared() > 1.0:
		play_pose(&"walk")
	else:
		play_pose(&"idle")

func face_target() -> void:

	if is_instance_valid(character.target):
		var offset: float = character.target.global_position.x - character.global_position.x
		if absf(offset) > 1.0:
			facing = signf(offset)
	# The sprite and its local lunge mirror together toward the opponent.
	pivot.scale.x = facing * arena_scale

# Reset every animated property when changing states to avoid leftover flashes
# or a partially completed attack pose after an interruption.
func play_pose(animation: StringName, restart: bool = false) -> void:

	if not restart and player.current_animation == animation and player.is_playing():
		return
	current_pose = animation
	pose_time = 0.0
	player.stop()
	sprite.position = Vector2.ZERO
	sprite.rotation = 0.0
	sprite.modulate = Color.WHITE
	player.play(animation)
	player.advance(0.0)
	_update_frame_pose()

func attack() -> void:

	if not enabled or not character.is_alive:
		return
	face_target()
	action = &"attack"
	# Keep the visual shorter than the fastest supported basic attack cooldown.
	player.speed_scale = 1.0
	play_pose(action, true)

func hit() -> void:

	if not enabled or not character.is_alive or action == &"attack":
		return
	action = &"hit"
	play_pose(action, true)

# The caller marks the unit dead immediately; only its removal is delayed.
func death() -> bool:

	if not enabled:
		return false
	action = &"death"
	play_pose(action, true)
	return true

func _on_animation_finished(animation: StringName) -> void:

	if animation == &"death":
		character.queue_free()
	elif animation == action:
		action = &""
		play_pose(&"idle")

# Two prototype atlases: real alternating legs and weapon poses, not a rotated card.
func _update_frame_pose() -> void:
	if not is_instance_valid(frame_sprite):
		return
	var use_frames: bool = current_pose in [&"walk", &"attack"]
	frame_sprite.visible = use_frames
	sprite.visible = not use_frames
	if current_pose == &"walk":
		frame_sprite.frame = int(pose_time / 0.15) % 4
	elif current_pose == &"attack":
		frame_sprite.frame = 4 + mini(3, int(pose_time / 0.055))
