extends SceneTree
## Run with a rendering display (not --headless). Captures go to user:// by default.
## Pass -- --output-dir=/absolute/path to select a scratch capture directory.
var failures: int = 0
var output_dir: String = "user://character-browser-captures"

func _initialize() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--output-dir="):
   output_dir = arg.trim_prefix("--output-dir=")
 call_deferred("run")

func check(condition: bool, message: String) -> void:
 if not condition:
  push_error(message)
  failures += 1

func settle() -> void:
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw

func capture(filename: String) -> void:
 await settle()
 root.get_texture().get_image().save_png(output_dir.path_join(filename))

func click(point: Vector2) -> void:
 var motion := InputEventMouseMotion.new()
 motion.position = point
 motion.global_position = point
 root.push_input(motion, true)
 for pressed in [true, false]:
  var event := InputEventMouseButton.new()
  event.button_index = MOUSE_BUTTON_LEFT
  event.position = point
  event.pressed = pressed
  event.global_position = point
  event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
  root.push_input(event, true)
  await process_frame

func run() -> void:
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
 root.size = Vector2i(1440, 900)
 var browser = load("res://Scene/CharacterBrowser.tscn").instantiate()
 root.add_child(browser)
 await settle()
 await capture("overview.png")
 await click(browser.story_button.get_global_rect().get_center())
 check(browser.story_open, "Native Story tab click")
 await capture("story.png")
 await click(browser.portrait.get_global_rect().get_center())
 check(not browser.story_open, "Native portrait click returns to overview")
 # Expand both actual buttons and inspect the bottom of the scrollable panel.
 for card in browser.overview.get_children():
  if card is VBoxContainer and card.get_child_count() == 3 and card.get_child(1) is Button:
   card.get_child(1).pressed.emit()
 await settle()
 browser.details_scroll.scroll_vertical = 10000
 await capture("details.png")
 check(browser.details_scroll.scroll_vertical > 0, "Ability and faction panel scrolls")
 for clan in browser.Catalog.CLANS:
  browser._all_clans()
  browser._toggle_clan(clan)
  for i in browser.filtered.size():
   browser._select_index(i)
   await settle()
   var portrait_rect: Rect2 = browser.portrait.get_global_rect()
   check(root.get_visible_rect().encloses(portrait_rect), "Portrait stays in viewport")
   check(browser.details_scroll.size.x > 0 and browser.details_scroll.size.y > 0, "Details remain visible")
 browser._all_clans()
 await click(browser.clan_buttons["Caraphex"].get_global_rect().get_center())
 check(browser.filtered.size() == 5, "Native clan-filter click")
 root.size = Vector2i(1152, 760)
 await capture("small.png")
 # Actual arrow and thumbnail hit testing after the canvas has scaled.
 await click(browser.next_button.get_global_rect().get_center())
 check(browser.current_character().character_name == "Kharvos", "Scaled next-arrow click")
 await click(browser.thumbnail_strip.get_child(0).get_global_rect().get_center())
 check(browser.current_character().character_name == "Brontis", "Scaled thumbnail click")
 root.size = Vector2i(1280, 720)
 await capture("wide.png")
 print("Character browser native UI: %s" % ("PASS" if failures == 0 else "FAIL"))
 quit(0 if failures == 0 else 1)
