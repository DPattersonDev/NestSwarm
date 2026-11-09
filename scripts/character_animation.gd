extends Node

# Each prepared character can reuse these whole-sprite animations.
# Layered art or sprite frames can replace the clips later.
@onready var character = get_parent()
@onready var player: AnimationPlayer = character.get_node("AnimationPlayer")
@onready var pivot: Node2D = character.get_node("VisualPivot")
@onready var sprite: Sprite2D = pivot.get_node("BattleSprite")

# Cache the visible figure height instead of using the whole sprite-cell height.
# Generated animation atlases may have generous transparent margins.
static var visible_height_cache: Dictionary = {}
var frame_sprite: Sprite2D
var pose_time: float = 0.0
var current_pose: StringName = &"idle"

var enabled: bool = false
var action: StringName = &""
var facing: float = 1.0
var arena_scale: float = 1.0

# Per-character animation signature. Deterministic so clients preview the
# same cadence without affecting movement, targeting, or attack timings.
var stride_frequency: float = 8.0
var stride_height: float = 2.0
var body_sway: float = 0.025
var motion_clock: float = 0.0
var motion_weight: float = 0.0

func setup() -> void:
	arena_scale = 0.8 if character.hex_battlefield() != null else 1.0
	pivot.scale = Vector2.ONE * arena_scale
	_setup_motion_signature()

	enabled = (
		character.character_data != null
		and character.character_data.sprite_animations_enabled
		and sprite.texture != null
	)
	if enabled:
		var atlas_path: String = _find_animation_atlas()
		if atlas_path != "":
			frame_sprite = Sprite2D.new()
			frame_sprite.texture = load(atlas_path)
			frame_sprite.hframes = 4
			frame_sprite.vframes = 2
			var visible_height: float = _measure_walk_figure_height(atlas_path, frame_sprite.texture)
			var factor: float = 70.0 / visible_height
			frame_sprite.scale = Vector2(factor, factor)
			frame_sprite.visible = false
			pivot.add_child(frame_sprite)
		player.animation_finished.connect(_on_animation_finished)
		play_pose(&"idle")

# Search the character's faction folder first, then support the original
# flat layout so older sprite sheets and new factions both keep working.
func _find_animation_atlas() -> String:
	if character.character_data == null:
		return ""
	var character_name: String = character.character_data.character_name
	var faction: String = character.character_data.faction
	var candidates: Array[String] = [
		"res://Art/Animations/%s/%s.png" % [faction, character_name],
		"res://Art/Animations/%s.png" % character_name
	]
	for path in candidates:
		if ResourceLoader.exists(path):
			return path
	return ""

# Read actual movement without changing targeting, damage, or attack timers.
func _process(_delta: float) -> void:
	pose_time += _delta
	_update_frame_pose()
	_update_body_motion(_delta)

	if not enabled or not character.is_alive or action != &"":
		return
	face_target()
	if character.velocity.length_squared() > 1.0:
		play_pose(&"walk")
	else:
		play_pose(&"idle")

# This changes visual motion only. The CharacterBody2D position and
# collision shape remain authoritative for navigation and hit detection.
func _setup_motion_signature() -> void:
	if character.character_data == null:
		return
	var name_hash: int = absi(character.character_data.character_name.hash())
	var variation: float = float(name_hash % 9) / 8.0
	match character.character_data.class_role:
		"Vanguard":
			stride_frequency = 5.5 + variation
			stride_height = 1.4
			body_sway = 0.018
		"Fighter":
			stride_frequency = 7.0 + variation
			stride_height = 2.2
			body_sway = 0.035
		"Assassin":
			stride_frequency = 10.0 + variation
			stride_height = 1.2
			body_sway = 0.045
		"Marksman":
			stride_frequency = 6.5 + variation
			stride_height = 1.6
			body_sway = 0.018
		"Support":
			stride_frequency = 6.0 + variation
			stride_height = 2.5
			body_sway = 0.022
		_:
			stride_frequency = 7.0 + variation
	# Slight individual variation keeps same-class combatants from marching
	# with synchronized, identical motion.
	stride_height *= 0.85 + variation * 0.3

func _update_body_motion(delta: float) -> void:
	if not enabled or not character.is_alive or action == &"death":
		pivot.position = Vector2.ZERO
		pivot.rotation = 0.0
		return
	if action != &"":
		motion_weight = 0.0
		pivot.position = Vector2.ZERO
		pivot.rotation = 0.0
		player.speed_scale = 1.0
		return
	var walking: bool = character.velocity.length_squared() > 1.0
	var target_weight: float = 1.0 if walking else 0.0
	motion_weight = move_toward(motion_weight, target_weight, delta * 9.0)
	if walking:
		motion_clock += delta * stride_frequency
	var footfall: float = absf(sin(motion_clock))
	pivot.position.y = -stride_height * footfall * motion_weight
	pivot.rotation = sin(motion_clock * 0.5) * body_sway * motion_weight
	# Attack/hit are still owned by AnimationPlayer. Do not scale their
	# duration because damage release timings are governed by combat logic.
	if action == &"" and current_pose == &"walk":
		player.speed_scale = clampf(stride_frequency / 8.0, 0.75, 1.4)
	else:
		player.speed_scale = 1.0

# Match the visual height of the idle portrait (70 px in setup_battle_visual).
# Walk frames are used rather than attack frames because effects and lunges
# should not alter the apparent body size. Ignore low-alpha background residue.
func _measure_walk_figure_height(atlas_path: String, atlas: Texture2D) -> float:
	if visible_height_cache.has(atlas_path):
		return float(visible_height_cache[atlas_path])
	var cell_height: int = maxi(1, atlas.get_height() / 2)
	var cell_width: int = maxi(1, atlas.get_width() / 4)
	var result: float = float(cell_height)
	var img: Image = atlas.get_image()
	if img != null and not img.is_empty():
		var heights: Array[int] = []
		for frame in range(4):
			var top: int = cell_height
			var bottom: int = -1
			for y in range(0, cell_height, 2):
				for x in range(frame * cell_width, mini((frame + 1) * cell_width, img.get_width()), 2):
					if img.get_pixel(x, y).a > 0.80:
						top = mini(top, y)
						bottom = maxi(bottom, y)
			if bottom >= top:
				heights.append(bottom - top + 1)
		if not heights.is_empty():
			# Maximum figure extent prevents unwanted per-frame zooming.
			result = float(heights.max())
	visible_height_cache[atlas_path] = maxf(result, 1.0)
	return float(visible_height_cache[atlas_path])

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
	player.speed_scale = 1.0
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
