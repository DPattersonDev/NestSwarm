extends Control
## A read-only codex: it never writes GameState or modifies CharacterData.
const Catalog = preload("res://scripts/character_catalog.gd")
const CANVAS := Vector2(1440, 900)
const GOLD := Color("e9b95d")
const INK := Color("0c1015")
const MUTED := Color("aeb0b5")
const PAPER := Color("f2e7d2")

var roster: Array[CharacterData] = []
var filtered: Array[CharacterData] = []
var stories: Dictionary = {}
var selected_clans: Array[String] = []
var selected_index: int = 0
var story_open: bool = false
var canvas: Control
var clan_buttons: Dictionary = {}
var all_button: Button
var portrait: TextureRect
var portrait_title: Label
var portrait_subtitle: Label
var count_label: Label
var identity_label: Label
var role_label: Label
var details_scroll: ScrollContainer
var overview: VBoxContainer
var story: VBoxContainer
var overview_button: Button
var story_button: Button
var thumbnail_strip: HBoxContainer
var previous_button: Button
var next_button: Button
var swipe_start := Vector2.ZERO
var swiping: bool = false
var swipe_touch: int = -1

func _ready() -> void:
 roster = Catalog.roster()
 filtered.assign(roster)
 stories = Catalog.stories()
 _build()
 resized.connect(_fit)
 _fit()
 _show_character()

func current_character() -> CharacterData:
 if filtered.is_empty():
  return null
 return filtered[selected_index]

func _fit() -> void:
 if canvas == null:
  return
 var factor: float = minf(size.x / CANVAS.x, size.y / CANVAS.y)
 canvas.scale = Vector2.ONE * factor
 canvas.position = (size - CANVAS * factor) * 0.5

func _box(bg: Color, border: Color = Color("665139"), padding: int = 14) -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color = bg
 style.border_color = border
 style.set_border_width_all(1)
 style.set_corner_radius_all(7)
 style.content_margin_left = padding
 style.content_margin_right = padding
 style.content_margin_top = padding
 style.content_margin_bottom = padding
 return style

func _label(text_value: String, font_size: int = 19, color: Color = PAPER) -> Label:
 var label := Label.new()
 label.text = text_value
 label.add_theme_font_size_override("font_size", font_size)
 label.add_theme_color_override("font_color", color)
 label.mouse_filter = Control.MOUSE_FILTER_IGNORE
 return label

func _body(text_value: String, font_size: int = 19, color: Color = PAPER) -> Label:
 var label := _label(text_value, font_size, color)
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 return label

func _button(text_value: String, callback: Callable, minimum: Vector2 = Vector2(0, 46)) -> Button:
 var button := Button.new()
 button.text = text_value
 button.custom_minimum_size = minimum
 button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
 button.add_theme_font_size_override("font_size", 18)
 button.add_theme_color_override("font_color", PAPER)
 button.add_theme_color_override("font_hover_color", GOLD)
 button.add_theme_color_override("font_pressed_color", GOLD)
 button.add_theme_stylebox_override("normal", _box(Color("12171ef2")))
 button.add_theme_stylebox_override("hover", _box(Color("302719"), GOLD))
 button.add_theme_stylebox_override("pressed", _box(Color("49351b"), GOLD))
 button.add_theme_stylebox_override("focus", _box(Color("00000000"), GOLD, 0))
 button.pressed.connect(callback)
 return button

func _selected(button: Button, active: bool) -> void:
 button.add_theme_stylebox_override("normal", _box(Color("49351b") if active else Color("12171ef2"), GOLD if active else Color("665139")))
 button.add_theme_color_override("font_color", GOLD if active else PAPER)

func _panel(parent: Node, pos: Vector2, dimensions: Vector2) -> PanelContainer:
 var panel := PanelContainer.new()
 panel.position = pos
 panel.size = dimensions
 panel.add_theme_stylebox_override("panel", _box(Color("0e131bef")))
 parent.add_child(panel)
 return panel

func _build() -> void:
 var background := ColorRect.new()
 background.color = Color("070a10")
 background.mouse_filter = Control.MOUSE_FILTER_IGNORE
 background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(background)
 canvas = Control.new()
 canvas.name = "BrowserCanvas"
 canvas.size = CANVAS
 add_child(canvas)
 # Existing world artwork supplies atmosphere without changing any battle asset.
 var backdrop := TextureRect.new()
 backdrop.texture = load("res://Art/Arenas/Vesper/vesper_hex_arena.png")
 backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
 backdrop.size = CANVAS
 backdrop.modulate = Color(0.42, 0.37, 0.30, 0.45)
 backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
 canvas.add_child(backdrop)
 var shade := ColorRect.new()
 shade.color = Color(0.02, 0.03, 0.05, 0.66)
 shade.size = CANVAS
 shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
 canvas.add_child(shade)
 var header := _panel(canvas, Vector2(18, 16), Vector2(1404, 68))
 var header_row := HBoxContainer.new()
 header_row.add_theme_constant_override("separation", 26)
 header.add_child(header_row)
 header_row.add_child(_label("N E S T S W A R M", 25, GOLD))
 header_row.add_child(_label("/  CHARACTERS", 25))
 var spacer := Control.new()
 spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 header_row.add_child(spacer)
 count_label = _label("", 17, MUTED)
 header_row.add_child(count_label)
 var back := _button("←  Back", _go_back, Vector2(116, 40))
 back.name = "BackButton"
 header_row.add_child(back)

 var sidebar := _panel(canvas, Vector2(18, 100), Vector2(194, 782))
 var clans := VBoxContainer.new()
 clans.add_theme_constant_override("separation", 12)
 sidebar.add_child(clans)
 clans.add_child(_label("C L A N S", 20, GOLD))
 clans.add_child(_body("Choose one or more", 15, MUTED))
 all_button = _button("All Clans", _all_clans)
 all_button.name = "AllClans"
 clans.add_child(all_button)
 for clan in Catalog.CLANS:
  var button := _button(clan, _toggle_clan.bind(clan))
  button.name = clan + "Filter"
  button.tooltip_text = "Show or hide %s characters" % clan
  clan_buttons[clan] = button
  clans.add_child(button)
 var sidebar_space := Control.new()
 sidebar_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
 clans.add_child(sidebar_space)
 clans.add_child(_body("30 champions\n6 clans\nOne swarm.", 19, GOLD))
 clans.add_child(_body("← →  Browse\nS  Switch page\nEsc  Back", 15, MUTED))

 var portrait_panel := _panel(canvas, Vector2(228, 100), Vector2(542, 600))
 portrait_panel.add_theme_stylebox_override("panel", _box(Color("1118245c"), Color("8b6b37"), 0))
 portrait = TextureRect.new()
 portrait.name = "CharacterPortrait"
 portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 portrait.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
 portrait.tooltip_text = "Tap for overview / story. Swipe left or right to browse."
 portrait.gui_input.connect(_portrait_input)
 portrait_panel.add_child(portrait)
 # Title is outside the art frame so every source silhouette remains visible.
 portrait_title = _label("", 27, GOLD)
 portrait_title.position = Vector2(230, 710)
 portrait_title.size = Vector2(536, 36)
 portrait_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 canvas.add_child(portrait_title)
 portrait_subtitle = _label("", 17, MUTED)
 portrait_subtitle.position = Vector2(230, 748)
 portrait_subtitle.size = Vector2(536, 26)
 portrait_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 canvas.add_child(portrait_subtitle)
 var nav := HBoxContainer.new()
 nav.position = Vector2(228, 784)
 nav.size = Vector2(542, 76)
 nav.add_theme_constant_override("separation", 7)
 canvas.add_child(nav)
 previous_button = _button("‹", _navigate.bind(-1), Vector2(35, 72))
 previous_button.name = "PreviousCharacter"
 nav.add_child(previous_button)
 thumbnail_strip = HBoxContainer.new()
 thumbnail_strip.name = "Thumbnails"
 thumbnail_strip.add_theme_constant_override("separation", 7)
 thumbnail_strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 nav.add_child(thumbnail_strip)
 next_button = _button("›", _navigate.bind(1), Vector2(35, 72))
 next_button.name = "NextCharacter"
 nav.add_child(next_button)
 var hint := _label("Swipe portrait · Tap for story", 14, MUTED)
 hint.position = Vector2(228, 863)
 hint.size.x = 542
 hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 canvas.add_child(hint)

 var detail_panel := _panel(canvas, Vector2(786, 100), Vector2(636, 782))
 var detail_column := VBoxContainer.new()
 detail_column.add_theme_constant_override("separation", 14)
 detail_panel.add_child(detail_column)
 var tabs := HBoxContainer.new()
 tabs.add_theme_constant_override("separation", 12)
 detail_column.add_child(tabs)
 overview_button = _button("O V E R V I E W", _set_page.bind(false))
 overview_button.name = "OverviewTab"
 overview_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 tabs.add_child(overview_button)
 story_button = _button("S T O R Y", _set_page.bind(true))
 story_button.name = "StoryTab"
 story_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 tabs.add_child(story_button)
 identity_label = _label("", 40)
 detail_column.add_child(identity_label)
 role_label = _label("", 20, GOLD)
 detail_column.add_child(role_label)
 details_scroll = ScrollContainer.new()
 details_scroll.name = "DetailsScroll"
 details_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 detail_column.add_child(details_scroll)
 var contents := VBoxContainer.new()
 contents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 details_scroll.add_child(contents)
 overview = VBoxContainer.new()
 overview.name = "Overview"
 overview.add_theme_constant_override("separation", 13)
 contents.add_child(overview)
 story = VBoxContainer.new()
 story.name = "Story"
 story.add_theme_constant_override("separation", 20)
 contents.add_child(story)

func _clear(parent: Node) -> void:
 for child in parent.get_children():
  parent.remove_child(child)
  child.queue_free()

func _show_character() -> void:
 var data := current_character()
 for clan in clan_buttons:
  _selected(clan_buttons[clan], selected_clans.has(clan))
 _selected(all_button, selected_clans.is_empty())
 previous_button.disabled = filtered.size() < 2
 next_button.disabled = filtered.size() < 2
 if data == null:
  return
 count_label.text = "%02d / %02d" % [selected_index + 1, filtered.size()]
 portrait.texture = data.battle_texture
 portrait_title.text = data.character_name.to_upper()
 portrait_subtitle.text = "%s  ·  %s" % [data.faction, data.class_role]
 identity_label.text = data.character_name
 role_label.text = "%s  ·  %s" % [data.faction, data.class_role]
 _clear(overview)
 _clear(story)
 _create_overview(data)
 _create_story(data)
 _create_thumbnails()
 _set_page(story_open)

func _create_overview(data: CharacterData) -> void:
 overview.add_child(_label("TARGETING", 16, GOLD))
 overview.add_child(_body("Closest living, targetable enemy", 21))
 overview.add_child(_body("Reassesses during combat. Ability effects can temporarily override targeting.", 16, MUTED))
 overview.add_child(_label("BASE STATS", 16, GOLD))
 var stats := GridContainer.new()
 stats.columns = 3
 stats.add_theme_constant_override("h_separation", 8)
 stats.add_theme_constant_override("v_separation", 8)
 overview.add_child(stats)
 var values: Array = [["HP", str(data.max_health)], ["ATK", str(data.damage)], ["MOVE", str(data.move_speed)], ["RANGE", str(data.attack_range)], ["ATTACK INTERVAL", "%.2f s" % data.attack_cooldown], ["CLASS", data.class_role]]
 for entry in values:
  var card := PanelContainer.new()
  card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  card.add_theme_stylebox_override("panel", _box(Color("181d25"), Color("443d31"), 10))
  stats.add_child(card)
  var column := VBoxContainer.new()
  card.add_child(column)
  column.add_child(_label(entry[0], 13, MUTED))
  column.add_child(_label(entry[1], 22, PAPER))
 overview.add_child(_body("Before upgrades and team bonuses. Range and move use game units.", 14, MUTED))
 overview.add_child(_body("Basic attack: " + data.basic_attack_style.strip_edges(), 17))
 overview.add_child(_label("A B I L I T I E S", 19, GOLD))
 _ability(UpgradeDatabase.get_basic_ability(data.basic_ability_id), "BASIC  ·  Always available")
 _ability(UpgradeDatabase.get_special(data.character_name), "SPECIAL  ·  Unlock through an upgrade")
 overview.add_child(_label("F A C T I O N   B O N U S E S", 19, GOLD))
 overview.add_child(_body("Applies to clan members. The 4-member tier replaces the 2-member tier.", 15, MUTED))
 var bonuses: Array = Catalog.BONUSES.get(data.faction, [])
 for i in bonuses.size():
  var bonus: Array = bonuses[i]
  var card := PanelContainer.new()
  card.add_theme_stylebox_override("panel", _box(Color("171b21"), Color("665139"), 12))
  overview.add_child(card)
  var column := VBoxContainer.new()
  column.add_theme_constant_override("separation", 7)
  card.add_child(column)
  column.add_child(_label("%d %s  ·  %s" % [2 if i == 0 else 4, data.faction, bonus[0]], 19, GOLD))
  column.add_child(_body(bonus[1], 17))
 overview.add_child(_button("Open Story  →", _set_page.bind(true)))

func _ability(definition: Dictionary, category: String) -> void:
 var card := VBoxContainer.new()
 card.add_theme_constant_override("separation", 7)
 overview.add_child(card)
 card.add_child(_label(category, 13, MUTED))
 var description := _body(str(definition.get("description", "Details unavailable.")), 18)
 description.visible = false
 var title: String = str(definition.get("name", "Ability unavailable"))
 var button := _button(title + "   +", func() -> void:
  description.visible = not description.visible
  (card.get_child(1) as Button).text = title + ("   −" if description.visible else "   +")
 )
 button.alignment = HORIZONTAL_ALIGNMENT_LEFT
 button.tooltip_text = "Show ability details"
 card.add_child(button)
 card.add_child(description)

func _create_story(data: CharacterData) -> void:
 var entry: Dictionary = stories.get(data.character_name, {})
 story.add_child(_body(str(entry.get("title", data.character_name)), 30, GOLD))
 story.add_child(_body(str(entry.get("personality", "")), 20, MUTED))
 var quote := _body('“%s”' % str(entry.get("quote", "")), 25)
 quote.add_theme_color_override("font_color", GOLD)
 story.add_child(quote)
 story.add_child(_body(str(entry.get("biography", "This character's story is yet to be told.")), 23))
 story.add_child(_button("←  Back to Overview", _set_page.bind(false)))

func _create_thumbnails() -> void:
 _clear(thumbnail_strip)
 if filtered.is_empty():
  return
 # Keep the current five-member clan together when all clans are visible.
 var page_start: int = (selected_index / 5) * 5
 for i in range(page_start, mini(page_start + 5, filtered.size())):
  var data: CharacterData = filtered[i]
  var button := _button("", _select_index.bind(i), Vector2(80, 72))
  button.name = data.character_name + "Thumbnail"
  button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  button.tooltip_text = "%s · %s" % [data.character_name, data.class_role]
  _selected(button, i == selected_index)
  thumbnail_strip.add_child(button)
  var column := VBoxContainer.new()
  column.mouse_filter = Control.MOUSE_FILTER_IGNORE
  column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  column.offset_left = 4
  column.offset_right = -4
  column.offset_top = 4
  column.offset_bottom = -4
  button.add_child(column)
  var art := TextureRect.new()
  art.texture = data.battle_texture
  art.custom_minimum_size = Vector2(0, 46)
  art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  art.mouse_filter = Control.MOUSE_FILTER_IGNORE
  column.add_child(art)
  var title := _label(data.character_name, 13, GOLD if i == selected_index else PAPER)
  title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  column.add_child(title)

func _set_page(show_story: bool) -> void:
 story_open = show_story
 overview.visible = not story_open
 story.visible = story_open
 _selected(overview_button, not story_open)
 _selected(story_button, story_open)
 details_scroll.scroll_vertical = 0

func _select_index(index: int) -> void:
 if filtered.is_empty():
  return
 selected_index = posmod(index, filtered.size())
 _show_character()

func _navigate(direction: int) -> void:
 _select_index(selected_index + direction)

func _all_clans() -> void:
 selected_clans.clear()
 _apply_filters()

func _toggle_clan(clan: String) -> void:
 if selected_clans.has(clan):
  selected_clans.erase(clan)
 else:
  selected_clans.append(clan)
 _apply_filters()

func _apply_filters() -> void:
 var previous := current_character()
 filtered.clear()
 for data in roster:
  if selected_clans.is_empty() or selected_clans.has(data.faction):
   filtered.append(data)
 selected_index = maxi(filtered.find(previous), 0)
 _show_character()

func _portrait_input(event: InputEvent) -> void:
 if event is InputEventScreenTouch:
  if event.pressed and not swiping:
   swipe_touch = event.index
   swipe_start = event.position
   swiping = true
  elif not event.pressed and swiping and event.index == swipe_touch:
   _finish_swipe(event.position)
  accept_event()
 elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
  # Touch devices can emit synthetic mouse events; one gesture must act only once.
  if event.device == InputEvent.DEVICE_ID_EMULATION:
   return
  if event.pressed:
   swipe_start = event.position
   swipe_touch = -1
   swiping = true
  elif swiping and swipe_touch == -1:
   _finish_swipe(event.position)
  accept_event()

func _finish_swipe(end_position: Vector2) -> void:
 var distance := end_position - swipe_start
 swiping = false
 swipe_touch = -1
 if absf(distance.x) >= 55.0 and absf(distance.x) > absf(distance.y):
  _navigate(1 if distance.x < 0 else -1)
 elif distance.length() < 18.0:
  _set_page(not story_open)

func _input(event: InputEvent) -> void:
 if not event.is_pressed() or event.is_echo():
  return
 if event.is_action_pressed("ui_left"):
  _navigate(-1)
 elif event.is_action_pressed("ui_right"):
  _navigate(1)
 elif event is InputEventKey and event.keycode == KEY_S:
  _set_page(not story_open)
 elif event.is_action_pressed("ui_cancel"):
  _go_back()
 else:
  return
 get_viewport().set_input_as_handled()

func _go_back() -> void:
 get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")
