extends Node2D
# Cosmetic effects live under the combat scene, never under a dying unit.
var kind: String = "hit"
var tint: Color = Color("ffd278")
var age: float = 0.0
var lifetime: float = 0.35
var from: Vector2
var destination: Vector2
var target_unit: WeakRef
var caption: String = ""

static func burst(unit: Node2D, effect: String, amount: int = 0) -> void:
	if not is_instance_valid(unit) or not unit.is_inside_tree():
		return
	var fx = load("res://scripts/combat_fx.gd").new()
	fx.kind = effect
	fx.position = unit.position
	fx.tint = Color("7df4b0") if effect == "heal" else Color("8ee1ff") if effect == "shield" else Color("ec7a7a") if effect == "bleed" else Color("b0e950") if effect == "poison" else Color("ffe0a0")
	fx.lifetime = 0.65 if effect in ["heal", "shield", "poison", "bleed"] else 0.22
	fx.caption = "+%d" % amount if effect == "heal" else ""
	unit.get_parent().add_child(fx)

static func projectile(source: Node2D, victim: Node2D) -> void:
	var fx = load("res://scripts/combat_fx.gd").new()
	var data = source.character_data
	fx.kind = "needle"
	if data.character_name == "Solvyr":
		fx.kind = "arrow"
	elif data.character_name == "Ignivar":
		fx.kind = "shell"
	elif data.character_name in ["Nyxis", "Veltrix"]:
		fx.kind = "venom"
	elif data.class_role == "Support":
		fx.kind = "spark"
	fx.tint = Color("9de5ff") if data.faction == "Lepidra" else Color("b2ef62") if fx.kind in ["venom", "needle"] else Color("ffd179")
	fx.from = source.position + Vector2(18 if victim.position.x >= source.position.x else -18, -6)
	fx.destination = victim.position
	fx.target_unit = weakref(victim)
	fx.lifetime = 0.12
	fx.position = fx.from
	source.get_parent().add_child(fx)
	await source.get_tree().create_timer(fx.lifetime).timeout

static func melee(source: Node2D, victim: Node2D) -> void:
	var fx = load("res://scripts/combat_fx.gd").new()
	fx.kind = "slash"
	fx.position = victim.position
	fx.rotation = source.position.angle_to_point(victim.position)
	fx.lifetime = 0.16
	source.get_parent().add_child(fx)

func _ready() -> void:
	z_index = 20

func _process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	var t := age / lifetime
	if kind in ["needle", "arrow", "shell", "venom", "spark"]:
		if target_unit != null and is_instance_valid(target_unit.get_ref()):
			destination = target_unit.get_ref().position
		position = from.lerp(destination, t)
		rotation = from.angle_to_point(destination)
	else:
		modulate.a = 1.0 - t
	queue_redraw()

func _draw() -> void:
	var t := age / lifetime
	match kind:
		"needle", "arrow":
			draw_line(Vector2(-17, 0), Vector2(5, 0), tint, 2.0, true)
			draw_colored_polygon(PackedVector2Array([Vector2(9, 0), Vector2(0, -4), Vector2(0, 4)]), tint)
			if kind == "arrow":
				draw_line(Vector2(-17, -4), Vector2(-10, 0), tint, 2)
				draw_line(Vector2(-17, 4), Vector2(-10, 0), tint, 2)
		"shell", "venom", "spark":
			draw_circle(Vector2.ZERO, 5.0 if kind == "shell" else 3.5, tint)
			draw_line(Vector2(-18, 0), Vector2.ZERO, Color(tint, 0.5), 3)
		"heal":
			for i in range(3):
				var at := Vector2((i - 1) * 15, -10 - t * 30 - i * 4)
				draw_line(at - Vector2(4, 0), at + Vector2(4, 0), tint, 2.5)
				draw_line(at - Vector2(0, 4), at + Vector2(0, 4), tint, 2.5)
			draw_string(ThemeDB.fallback_font, Vector2(-9, -28 - 20 * t), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, tint)
		"shield":
			draw_arc(Vector2.ZERO, 32 + 6 * t, 0, TAU, 40, tint, 2, true)
		"poison", "bleed":
			for i in range(4):
				draw_circle(Vector2(sin(i * 2.1) * 16, -12 - t * 20 + i * 4), 2.5, tint)
		"slash":
			draw_arc(Vector2(-12, 0), 25, -1.1 + t, 1.1 + t, 16, tint, 3, true)
		_:
			for i in range(6):
				var ray := Vector2.RIGHT.rotated(i * TAU / 6)
				draw_line(ray * (3 + t * 5), ray * (8 + t * 15), tint, 2, true)
