extends Node


# =========================================================
# MATCH TEAMS
# =========================================================

# The four characters selected by the player.
var selected_team: Array[CharacterData] = []

# Opponent team.
var enemy_team: Array = []


# =========================================================
# CHARACTER UPGRADES
# =========================================================

# Stores all upgrades earned by each player character.
var character_upgrades: Dictionary = {}


# =========================================================
# PLAYER PLACEMENT
# =========================================================

var player_placements: Dictionary = {}


# =========================================================
# OPPONENT PLACEMENT
# =========================================================

var enemy_placements: Dictionary = {}


# =========================================================
# ROUND / MATCH STATE
# =========================================================

var current_round: int = 1

var player_round_wins: int = 0
var enemy_round_wins: int = 0

var wins_needed: int = 3


# =========================================================
# BETWEEN-ROUND TIMER
# =========================================================

# The entire decision phase shares ONE timer.
#
# This covers:
#
# Replacement decision
# Replacement selection
# Replacement catch-up upgrades
# Normal character upgrades
const BETWEEN_ROUND_TIME_LIMIT: float = 60.0


var between_round_time_left: float = 0.0

var between_round_phase_active: bool = false


# =========================================================
# REPLACEMENT STATE
# =========================================================

# Name of the character sacrificed this round.
var sacrificed_character_name: String = ""


# Name of the replacement character.
var replacement_character_name: String = ""


# Number of catch-up upgrade selections
# the replacement still needs.
var replacement_upgrade_picks_remaining: int = 0


# Prevents the replacement from also receiving
# a normal upgrade after completing catch-up.
var replacement_completed_this_phase: bool = false


# Characters sacrificed during this match.
#
# They cannot immediately return later
# through another replacement.
var retired_character_names: Array[String] = []


# =========================================================
# TIMER PROCESS
# =========================================================

func _process(
	delta: float
) -> void:

	if not between_round_phase_active:
		return


	if between_round_time_left <= 0.0:

		between_round_time_left = 0.0
		return


	between_round_time_left -= delta


	if between_round_time_left < 0.0:

		between_round_time_left = 0.0


# =========================================================
# START BETWEEN-ROUND PHASE
# =========================================================

func start_between_round_phase() -> void:

	between_round_time_left = (
		BETWEEN_ROUND_TIME_LIMIT
	)


	between_round_phase_active = true


	# Clear replacement information
	# from the previous between-round phase.
	sacrificed_character_name = ""

	replacement_character_name = ""

	replacement_upgrade_picks_remaining = 0

	replacement_completed_this_phase = false


# =========================================================
# END BETWEEN-ROUND PHASE
# =========================================================

func end_between_round_phase() -> void:

	between_round_phase_active = false

	between_round_time_left = 0.0


# =========================================================
# GET NEXT ROUND NUMBER
# =========================================================

func get_next_round_number() -> int:

	return (
		current_round
		+ 1
	)


# =========================================================
# GET REPLACEMENT CATCH-UP PICKS
# =========================================================
#
# Preparing for Round 2 = 2 picks
# Preparing for Round 3 = 3 picks
# Preparing for Round 4 = 4 picks
# Preparing for Round 5 = 5 picks
func get_replacement_catchup_count() -> int:

	return (
		get_next_round_number()
	)


# =========================================================
# RECORD REPLACEMENT
# =========================================================

func record_replacement(
	old_character_name: String,
	new_character_name: String
) -> void:

	sacrificed_character_name = (
		old_character_name
	)


	replacement_character_name = (
		new_character_name
	)


	replacement_upgrade_picks_remaining = (
		get_replacement_catchup_count()
	)


	replacement_completed_this_phase = false


	if not retired_character_names.has(
		old_character_name
	):

		retired_character_names.append(
			old_character_name
		)


# =========================================================
# NEW MATCH
# =========================================================

func reset_match() -> void:

	selected_team.clear()

	enemy_team.clear()


	character_upgrades.clear()


	player_placements.clear()

	enemy_placements.clear()


	current_round = 1

	player_round_wins = 0

	enemy_round_wins = 0


	# Reset timer.
	between_round_time_left = 0.0

	between_round_phase_active = false


	# Reset replacement state.
	sacrificed_character_name = ""

	replacement_character_name = ""

	replacement_upgrade_picks_remaining = 0

	replacement_completed_this_phase = false

	retired_character_names.clear()


# =========================================================
# ROUND WINNER
# =========================================================

func record_round_winner(
	winning_team: int
) -> void:

	if winning_team == 1:

		player_round_wins += 1


	elif winning_team == 2:

		enemy_round_wins += 1


# =========================================================
# MATCH WINNER CHECK
# =========================================================

func is_match_over() -> bool:

	return (
		player_round_wins >= wins_needed
		or enemy_round_wins >= wins_needed
	)


# =========================================================
# GET MATCH WINNER
# =========================================================

func get_match_winner() -> int:

	if player_round_wins >= wins_needed:

		return 1


	if enemy_round_wins >= wins_needed:

		return 2


	return 0
