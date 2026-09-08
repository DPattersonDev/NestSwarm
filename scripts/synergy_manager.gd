extends Node


# =========================================================
# SYNERGY THRESHOLDS
# =========================================================

# Faction bonuses activate at:
# 2 members
# 4 members
const FACTION_SMALL_THRESHOLD: int = 2
const FACTION_FULL_THRESHOLD: int = 4


# Class bonuses activate at:
# 2 members
# 4 members
const CLASS_SMALL_THRESHOLD: int = 2
const CLASS_FULL_THRESHOLD: int = 4


# =========================================================
# COUNT FACTIONS
# =========================================================

func count_factions(
	team: Array
) -> Dictionary:

	var faction_counts: Dictionary = {}


	for character in team:

		if character == null:
			continue


		var faction_name: String = (
			character.faction
		)


		if faction_name == "":
			continue


		if not faction_counts.has(
			faction_name
		):

			faction_counts[
				faction_name
			] = 0


		faction_counts[
			faction_name
		] += 1


	return faction_counts


# =========================================================
# COUNT CLASSES
# =========================================================

func count_classes(
	team: Array
) -> Dictionary:

	var class_counts: Dictionary = {}


	for character in team:

		if character == null:
			continue


		var role_name: String = (
			character.class_role
		)


		if role_name == "":
			continue


		if not class_counts.has(
			role_name
		):

			class_counts[
				role_name
			] = 0


		class_counts[
			role_name
		] += 1


	return class_counts


# =========================================================
# ACTIVE FACTION SYNERGIES
# =========================================================

func get_active_faction_synergies(
	team: Array
) -> Dictionary:

	var faction_counts = (
		count_factions(
			team
		)
	)


	var active_synergies: Dictionary = {}


	for faction_name in faction_counts:

		var count: int = (
			faction_counts[
				faction_name
			]
		)


		if count >= FACTION_FULL_THRESHOLD:

			active_synergies[
				faction_name
			] = FACTION_FULL_THRESHOLD


		elif count >= FACTION_SMALL_THRESHOLD:

			active_synergies[
				faction_name
			] = FACTION_SMALL_THRESHOLD


	return active_synergies


# =========================================================
# ACTIVE CLASS SYNERGIES
# =========================================================

func get_active_class_synergies(
	team: Array
) -> Dictionary:

	var class_counts = (
		count_classes(
			team
		)
	)


	var active_synergies: Dictionary = {}


	for role_name in class_counts:

		var count: int = (
			class_counts[
				role_name
			]
		)


		if count >= CLASS_FULL_THRESHOLD:

			active_synergies[
				role_name
			] = CLASS_FULL_THRESHOLD


		elif count >= CLASS_SMALL_THRESHOLD:

			active_synergies[
				role_name
			] = CLASS_SMALL_THRESHOLD


	return active_synergies


# =========================================================
# GET FACTION TIER
# =========================================================

# Returns:
#
# 0 = no faction bonus
# 2 = small faction bonus
# 4 = full faction bonus
func get_faction_tier(
	team: Array,
	faction_name: String
) -> int:

	var active_factions = (
		get_active_faction_synergies(
			team
		)
	)


	if active_factions.has(
		faction_name
	):

		return active_factions[
			faction_name
		]


	return 0


# =========================================================
# GET CLASS TIER
# =========================================================

# Returns:
#
# 0 = no class bonus
# 2 = small class bonus
# 4 = full class bonus
func get_class_tier(
	team: Array,
	role_name: String
) -> int:

	var active_classes = (
		get_active_class_synergies(
			team
		)
	)


	if active_classes.has(
		role_name
	):

		return active_classes[
			role_name
		]


	return 0


# =========================================================
# GET CLASS COUNT
# =========================================================

# Returns how many characters of a certain
# class are currently on the team.
func get_class_count(
	team: Array,
	role_name: String
) -> int:

	var class_counts = (
		count_classes(
			team
		)
	)


	if class_counts.has(
		role_name
	):

		return class_counts[
			role_name
		]


	return 0


# =========================================================
# CHECK CLASS SYNERGY
# =========================================================

# Returns true when the class has at least
# the 2-character synergy active.
func has_class_synergy(
	team: Array,
	role_name: String
) -> bool:

	return (
		get_class_tier(
			team,
			role_name
		)
		>= CLASS_SMALL_THRESHOLD
	)


# =========================================================
# CHECK FULL CLASS SYNERGY
# =========================================================

# Returns true when the class has the
# 4-character synergy active.
func has_full_class_synergy(
	team: Array,
	role_name: String
) -> bool:

	return (
		get_class_tier(
			team,
			role_name
		)
		>= CLASS_FULL_THRESHOLD
	)


# =========================================================
# GET TEAM FROM TEAM ID
# =========================================================

# Team 1 currently represents the player.
#
# Team 2 currently represents the AI opponent.
#
# Later Team 2 can be replaced by another
# multiplayer player's team data.
func get_team_from_id(
	team_id: int
) -> Array:

	if team_id == 1:

		return GameState.selected_team


	if team_id == 2:

		return GameState.enemy_team


	return []


# =========================================================
# GET UNIT FACTION TIER
# =========================================================

# Makes it easy for Character.gd to ask:
#
# "What faction bonus should THIS unit receive?"
func get_unit_faction_tier(
	team_id: int,
	faction_name: String
) -> int:

	var team = (
		get_team_from_id(
			team_id
		)
	)


	return (
		get_faction_tier(
			team,
			faction_name
		)
	)


# =========================================================
# GET UNIT CLASS TIER
# =========================================================

# Makes it easy for Character.gd to ask:
#
# "What class bonus should THIS unit receive?"
func get_unit_class_tier(
	team_id: int,
	role_name: String
) -> int:

	var team = (
		get_team_from_id(
			team_id
		)
	)


	return (
		get_class_tier(
			team,
			role_name
		)
	)


# =========================================================
# PRINT TEAM SYNERGIES
# =========================================================

func print_team_synergies(
	team: Array
) -> void:

	var faction_counts = (
		count_factions(
			team
		)
	)


	var class_counts = (
		count_classes(
			team
		)
	)


	var active_factions = (
		get_active_faction_synergies(
			team
		)
	)


	var active_classes = (
		get_active_class_synergies(
			team
		)
	)


	print("====================")
	print("TEAM SYNERGIES")
	print("====================")


	print("FACTIONS:")


	if faction_counts.is_empty():

		print("None")


	else:

		for faction_name in faction_counts:

			print(
				faction_name,
				": ",
				faction_counts[
					faction_name
				]
			)


	print("CLASSES:")


	if class_counts.is_empty():

		print("None")


	else:

		for role_name in class_counts:

			print(
				role_name,
				": ",
				class_counts[
					role_name
				]
			)


	print("ACTIVE FACTION BONUSES:")


	if active_factions.is_empty():

		print("None")


	else:

		for faction_name in active_factions:

			print(
				faction_name,
				" tier ",
				active_factions[
					faction_name
				],
				" active"
			)


	print("ACTIVE CLASS BONUSES:")


	if active_classes.is_empty():

		print("None")


	else:

		for role_name in active_classes:

			print(
				role_name,
				" tier ",
				active_classes[
					role_name
				],
				" active"
			)


	print("====================")
