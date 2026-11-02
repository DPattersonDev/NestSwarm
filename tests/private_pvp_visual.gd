extends SceneTree
var screen
var output := "user://pvp-captures"
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output-dir="):
			output = arg.trim_prefix("--output-dir=")
	call_deferred("run")
func capture(file_name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(file_name))
func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(1280, 800)
	change_scene_to_file("res://Scene/MainMenu.tscn")
	await process_frame
	await capture("main.png")
	change_scene_to_file("res://Scene/PrivatePvp.tscn")
	await process_frame
	while current_scene == null:
		await process_frame
	screen = current_scene
	await capture("lobby.png")
	screen.is_host = true
	screen._open_planning({"round":1,"epoch":1,"wins":[0,0],"team":[],"cells":[],"offers":{}})
	await capture("planning.png")
	screen.local_cells = [12,13,14,15]
	screen.teams = {1:screen.local_team.duplicate(),2:["Droven","Kaelor","Nyxis","Syrra"]}
	screen.placements = {1:[12,13,14,15],2:[12,13,14,15]}
	screen.ready_slots = {1:true,2:true}
	screen.connected = true
	# Build only the host simulation here, without sending network RPCs.
	var state = root.get_node("GameState")
	state.reset_match()
	for n in screen.teams[1]:state.selected_team.append(load("res://Data/%s.tres" % n))
	for n in screen.teams[2]:state.enemy_team.append(load("res://Data/%s.tres" % n))
	state.player_placements=screen.Rules.formation(screen.teams[1],screen.placements[1])
	state.enemy_placements=screen.Rules.formation(screen.teams[2],screen.placements[2])
	screen.phase="battle"
	screen._battle_ui()
	screen.battle=load("res://game.tscn").instantiate()
	screen.battle.set_script(screen.Battle)
	screen.add_child(screen.battle)
	screen.move_child(screen.battle,1)
	screen.battle.score_label.hide()
	screen.battle.ledger_panel.hide()
	screen.set_process(false)
	await create_timer(2).timeout
	var snapshot=screen._snapshot()
	screen._update_roster(snapshot)
	await capture("host_battle.png")
	screen._remove_battle()
	screen.is_host=false
	screen._show_battle(1,1,[0,0])
	screen._battle_snapshot(1,1,snapshot)
	await capture("friend_battle.png")
	var choices={}
	for n in screen.local_team:choices[n]=root.get_node("UpgradeDatabase").get_random_three(n)
	screen._open_planning({"round":2,"epoch":2,"wins":[1,0],"team":screen.local_team,"cells":[0,1,2,3],"offers":choices})
	await capture("upgrades.png")
	print("PVP visual captures: PASS")
	quit()
