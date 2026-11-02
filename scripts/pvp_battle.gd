extends "res://game.gd"
## Only instantiated on the host. Keeps the normal offline round flow intact.
signal round_finished(winner: int)
var elapsed := 0.0
const ROUND_LIMIT := 120.0

func _process(delta: float) -> void:
	update_battle_ledger()
	if combat_over:
		return
	elapsed += delta
	check_for_winner()
	if combat_over:
		return
	var living := [0, 0]
	for unit in get_tree().get_nodes_in_group("Characters"):
		if unit.get_parent() == self and unit.is_alive:
			living[unit.team_id - 1] += 1
	if living == [0, 0] or elapsed >= ROUND_LIMIT:
		end_round(0) # Draw: replay with upgrades, no win awarded.

func end_round(winning_team: int) -> void:
	if combat_over:
		return
	combat_over = true
	stop_all_combat_processing()
	round_finished.emit(winning_team)
