extends Node2D
## Visual-only client proxy. No combat, targeting, RNG, or damage runs here.
var destination := Vector2.ZERO
var title: Label
var sprite: Sprite2D
var shield: bool = false
var hp := 0
var max_hp := 1
var character_name := ""
var team := 1
var sequence := -1

func setup(data: Dictionary) -> void:
	character_name = data.character
	team = data.team
	sprite = Sprite2D.new()
	var resource := load("res://Data/%s.tres" % character_name) as CharacterData
	sprite.texture = resource.battle_texture
	sprite.scale = Vector2.ONE * 56.0 / sprite.texture.get_height()
	add_child(sprite)
	title = Label.new()
	title.position = Vector2(-54, 34)
	title.size.x = 108
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color("7de3ff") if team == 1 else Color("ffb580"))
	add_child(title)
	position = data.position
	destination = position
	apply(data)

func apply(data: Dictionary) -> void:
	destination = data.position
	hp = data.hp
	max_hp = data.max_hp
	shield = data.shield > 0
	visible = data.alive
	title.text = "%s\n%d / %d" % [character_name, hp, max_hp]
	sprite.flip_h = data.facing < 0
	# Small attack pulse reflects host animation state, without simulating attacks.
	sprite.modulate = Color("ffe8aa") if data.pose == "attack" else Color.WHITE
	queue_redraw()

func _process(delta: float) -> void:
	position = position.lerp(destination, minf(delta * 22.0, 1.0))

func _draw() -> void:
	if shield:
		draw_circle(Vector2.ZERO, 32.0, Color(0.3, 0.8, 1.0, 0.12))
		draw_arc(Vector2.ZERO, 32.0, 0, TAU, 32, Color("80dfff"), 1.5)
