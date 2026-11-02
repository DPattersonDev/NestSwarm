extends SceneTree
## Launch host and guest in separate OS processes; see PRIVATE_PVP_README.md.
var screen
var role := "host"
var started := 0
var phase_started := 0
var previous_phase := ""
var saw_snapshots := false
var saw_upgrades := false
var saw_rematch := false
var result_count := 0
var forced_epoch := -1
var last_planning_epoch := -1
var pass_ready := false
var natural := false
var saw_result := false
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--natural":
			natural = true
		if arg.begins_with("--role="):
			role = arg.trim_prefix("--role=")
	call_deferred("run")
func run() -> void:
	started = Time.get_ticks_msec()
	screen = load("res://Scene/PrivatePvp.tscn").instantiate()
	root.add_child(screen)
	if role == "host":
		screen.host_match(24568)
	else:
		screen.join_match("127.0.0.1", 24568)
func _process(_delta: float) -> bool:
	if screen == null:
		return false
	var now := Time.get_ticks_msec()
	if now - started > 150000:
		push_error("PVP network timeout: %s %s" % [role, screen.phase])
		quit(1)
	if screen.phase != previous_phase:
		print("NETWORK %s phase=%s round=%d" % [role, screen.phase, screen.round_number])
		previous_phase = screen.phase
		phase_started = now
	if screen.phase == "planning" and not screen.local_locked and now - phase_started > (300 if role == "host" else 700):
		if screen.round_number > 1:
			if screen.remote_view.get_child_count() != 0 or screen.battle != null:
				push_error("Battle visuals must clear before planning")
				quit(1)
			saw_upgrades = screen.upgrade_pickers.size() == 4
		if screen.epoch > 3 and screen.round_number == 1:
			saw_rematch = true
		if saw_rematch:
			if role == "host":
				print("PVP NETWORK HOST PASS: rounds, upgrades, result, rematch")
				screen._abort("Test disconnect")
				quit(0)
			return false
		if screen.epoch != last_planning_epoch:
			last_planning_epoch = screen.epoch
			if role == "host":
				# First player ready must not start or reveal the opponent.
				screen.submit_ready()
				if screen.phase != "planning" or not screen.teams[2].is_empty() and screen.round_number == 1:
					push_error("Private formation barrier failed")
					quit(1)
			else:
				screen.submit_ready()
	if screen.phase == "battle":
		if role == "guest" and screen.last_snapshot.size() > 0:
			saw_snapshots = true
			if screen.battle != null:
				push_error("Client must never simulate combat")
				quit(1)
		if not natural and role == "host" and now - phase_started > 4000 and forced_epoch != screen.epoch:
			# Exercise real combat for four seconds, then accelerate the match lifecycle.
			forced_epoch = screen.epoch
			screen.battle.end_round(1)
	if natural and screen.phase in ["result", "match_over"]:
		if role == "guest" and not saw_snapshots:
			push_error("No natural battle snapshots")
			quit(1)
		saw_result = true
		if now - phase_started > (100 if role == "guest" else 400):
			print("PVP NATURAL COMBAT %s PASS winner=%d score=%s" % [role, screen.result_winner, screen.wins])
			quit(0)
		return false
	if natural and saw_result and screen.phase == "lobby":
		print("PVP NATURAL COMBAT %s PASS after peer exit" % role)
		quit(0)
	if screen.phase == "match_over":
		if not saw_upgrades or (role == "guest" and not saw_snapshots):
			push_error("Missing upgrade or snapshot coverage")
			quit(1)
		if now - phase_started > 400:
			screen.request_rematch()
	if role == "guest" and screen.phase == "lobby" and saw_upgrades and saw_snapshots and screen.epoch > 3:
		print("PVP NETWORK GUEST PASS: snapshots, upgrades, rematch and host disconnect")
		quit(0)
	return false
