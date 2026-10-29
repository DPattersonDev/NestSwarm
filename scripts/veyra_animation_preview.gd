extends Node2D

# Run this scene with F6 to inspect each clip without playing a round.
@export var preview_roster: PackedStringArray = PackedStringArray(["Veyra"])
var selected_character: String = "Veyra"
var character
var status: Label
var scene: PackedScene = preload("res://character/Character.tscn")

func _ready() -> void:

	RenderingServer.set_default_clear_color(Color("171e2b"))
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	var panel: VBoxContainer = VBoxContainer.new()
	panel.position = Vector2(24, 24)
	layer.add_child(panel)
	var title: Label = Label.new()
	title.text = "VESPER — Animation preview" if preview_roster.size() > 1 else "VEYRA — Animation preview"
	title.add_theme_font_size_override("font_size", 26)
	panel.add_child(title)
	status = Label.new()
	status.text = "Existing sprite art • enlarged 4× for inspection"
	panel.add_child(status)
	var selector: OptionButton = OptionButton.new()
	for character_name in preview_roster:
		selector.add_item(character_name)
	selector.item_selected.connect(select_character)
	panel.add_child(selector)
	selected_character = preview_roster[0]
	var row: HBoxContainer = HBoxContainer.new()
	panel.add_child(row)
	for clip in [&"idle", &"walk", &"attack", &"hit", &"death"]:
		var button: Button = Button.new()
		button.text = str(clip).capitalize()
		button.pressed.connect(show_clip.bind(clip))
		row.add_child(button)
	var flip_button: Button = Button.new()
	flip_button.text = "Face other direction"
	flip_button.pressed.connect(flip)
	panel.add_child(flip_button)
	var reset_button: Button = Button.new()
	reset_button.text = "Reset character"
	reset_button.pressed.connect(reset_character)
	panel.add_child(reset_button)
	reset_character()

func reset_character() -> void:

	if is_instance_valid(character):
		remove_child(character)
		character.queue_free()
	character = scene.instantiate()
	character.character_data = load("res://Data/" + selected_character + ".tres")
	character.debug_combat_logs = false
	character.position = Vector2(550, 360)
	character.scale = Vector2(4, 4)
	add_child(character)
	character.set_physics_process(false)
	status.text = selected_character + " • " + character.character_data.class_role + " • Idle"

func show_clip(clip: StringName) -> void:

	if not is_instance_valid(character) or not character.is_alive:
		reset_character()
	status.text = selected_character + " • " + str(clip).capitalize()
	var animation = character.character_animation
	character.velocity = Vector2.ZERO
	animation.action = &""
	if clip == &"walk":
		character.velocity = Vector2(64, 0)
		animation.play_pose(&"walk", true)
	elif clip == &"attack":
		animation.attack()
	elif clip == &"hit":
		# Reset a previous attack so the requested preview is always visible.
		animation.action = &""
		animation.hit()
	elif clip == &"death":
		character.die()
	else:
		animation.action = &""
		animation.play_pose(&"idle", true)

func flip() -> void:

	if is_instance_valid(character):
		var animation = character.character_animation
		animation.facing *= -1.0
		animation.pivot.scale.x = animation.facing

# Recreate only the preview unit; its real combat data stays unchanged.
func select_character(index: int) -> void:

	selected_character = preview_roster[index]
	reset_character()
