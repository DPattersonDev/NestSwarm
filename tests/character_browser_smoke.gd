extends SceneTree

var failures: int = 0

func _initialize() -> void:
 call_deferred("run")

func check(condition: bool, message: String) -> void:
 if not condition:
  push_error(message)
  failures += 1

func text_in(node: Node) -> String:
 var result := ""
 if node is Label or node is Button:
  result += node.text + "\n"
 for child in node.get_children():
  result += text_in(child)
 return result

func run() -> void:
 var state := root.get_node("GameState")
 var team_before: Array = state.selected_team.duplicate()
 var placements_before: Dictionary = state.player_placements.duplicate(true)
 var round_before: int = state.current_round
 var browser = load("res://Scene/CharacterBrowser.tscn").instantiate()
 root.add_child(browser)
 await process_frame
 check(browser.roster.size() == 30, "All 30 characters must be loaded")
 check(browser.current_character().character_name == "Veyra", "Veyra opens first")
 browser.next_button.pressed.emit()
 check(browser.current_character().character_name == "Aurex", "Aurex follows Veyra")
 browser._select_index(0)
 browser.previous_button.pressed.emit()
 check(browser.selected_index == 29, "Previous wraps to last character")
 browser.next_button.pressed.emit()
 check(browser.selected_index == 0, "Next wraps to first character")
 for i in browser.roster.size():
  browser._select_index(i)
  var data: CharacterData = browser.current_character()
  check(browser.portrait.texture != null, "%s portrait" % data.character_name)
  check(not root.get_node("UpgradeDatabase").get_basic_ability(data.basic_ability_id).is_empty(), "%s basic ability" % data.character_name)
  check(not root.get_node("UpgradeDatabase").get_special(data.character_name).is_empty(), "%s special ability" % data.character_name)
  check(text_in(browser.overview).contains(str(data.max_health)), "%s current base HP" % data.character_name)
  check(browser.stories.has(data.character_name), "%s story" % data.character_name)
  browser.story_button.pressed.emit()
  check(browser.story.visible and not browser.overview.visible, "Story page opens")
  check(text_in(browser.story).contains(browser.stories[data.character_name].biography), "Correct story rendered")
  browser.overview_button.pressed.emit()
  check(browser.overview.visible and not browser.story.visible, "Overview page opens")
  # Find both ability cards by their expandable description, then exercise signals.
  var found: int = 0
  for card in browser.overview.get_children():
   if card is VBoxContainer and card.get_child_count() == 3 and card.get_child(1) is Button:
    var description = card.get_child(2)
    check(not description.visible, "Ability starts collapsed")
    card.get_child(1).pressed.emit()
    check(description.visible and not description.text.is_empty(), "Ability details expand")
    card.get_child(1).pressed.emit()
    check(not description.visible, "Ability details collapse")
    found += 1
  check(found == 2, "Two expandable abilities per character")
 for clan in browser.Catalog.CLANS:
  browser._all_clans()
  browser.clan_buttons[clan].pressed.emit()
  check(browser.filtered.size() == 5, "%s has five members" % clan)
  for data in browser.filtered:
   check(data.faction == clan, "Clan filter excludes other members")
 browser._all_clans()
 browser._toggle_clan("Vesper")
 browser._toggle_clan("Lepidra")
 check(browser.filtered.size() == 10, "Multiple clan filters combine")
 browser._toggle_clan("Vesper")
 check(browser.filtered.size() == 5 and browser.current_character().faction == "Lepidra", "Unchecking clan updates roster")
 browser._toggle_clan("Lepidra")
 check(browser.filtered.size() == 30, "Clearing final filter restores all")
 browser._select_index(0)
 var gesture := InputEventScreenTouch.new()
 gesture.index = 0
 gesture.position = Vector2(200, 200)
 gesture.pressed = true
 browser._portrait_input(gesture)
 gesture.pressed = false
 gesture.position = Vector2(100, 200)
 browser._portrait_input(gesture)
 check(browser.current_character().character_name == "Aurex", "Touch swipe navigates once")
 var mouse := InputEventMouseButton.new()
 mouse.device = InputEvent.DEVICE_ID_EMULATION
 mouse.button_index = MOUSE_BUTTON_LEFT
 mouse.pressed = true
 browser._portrait_input(mouse)
 mouse.pressed = false
 browser._portrait_input(mouse)
 check(browser.current_character().character_name == "Aurex", "Synthetic mouse must not repeat touch")
 browser._set_page(false)
 gesture.position = Vector2(100, 200)
 gesture.pressed = true
 browser._portrait_input(gesture)
 gesture.pressed = false
 browser._portrait_input(gesture)
 check(browser.story_open, "Portrait tap opens story")
 # Keyboard navigation should work even after a button receives focus.
 browser.next_button.grab_focus()
 var key := InputEventKey.new()
 key.keycode = KEY_RIGHT
 key.pressed = true
 browser._input(key)
 check(browser.current_character().character_name == "Melora", "Keyboard arrow navigates")
 check(state.selected_team == team_before, "Browsing never changes team")
 check(state.player_placements == placements_before, "Browsing never changes placements")
 check(state.current_round == round_before, "Browsing never changes round")
 browser.queue_free()
 await process_frame
 # Verify the real main-menu entry and browser Back action.
 change_scene_to_file("res://Scene/MainMenu.tscn")
 await process_frame
 current_scene._on_character_button_pressed()
 await process_frame
 check(current_scene.name == "CharacterBrowser", "Menu opens browser")
 current_scene._go_back()
 await process_frame
 check(current_scene.name == "MainMenu", "Back returns to menu")
 print("Character browser smoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
 quit(0 if failures == 0 else 1)
