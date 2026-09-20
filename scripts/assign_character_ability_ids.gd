@tool
extends EditorScript


func _run() -> void:

	var assignments: Dictionary = {

		"Veyra": {
			"basic": "royal_guard",
			"special": "queens_bastion"
		},

		"Zekrin": {
			"basic": "predator_sting",
			"special": "predators_dive"
		},

		"Melora": {
			"basic": "royal_nectar",
			"special": "royal_bloom"
		},

		"Tharos": {
			"basic": "wing_rush",
			"special": "frenzy_tempest"
		},

		"Aurex": {
			"basic": "needle_line",
			"special": "golden_barrage"
		},

		"Kaelor": {
			"basic": "horn_charge",
			"special": "stampede"
		},

		"Syrra": {
			"basic": "ambush_leap",
			"special": "apex_pounce"
		},

		"Droven": {
			"basic": "territorial_guard",
			"special": "dominant_territory"
		},

		"Nyxis": {
			"basic": "acid_shot",
			"special": "corrosive_volley"
		},

		"Velkara": {
			"basic": "marked_prey",
			"special": "grand_hunt"
		},

		"Lunara": {
			"basic": "moon_veil",
			"special": "lunar_sanctuary"
		},

		"Vorren": {
			"basic": "phase_step",
			"special": "phantom_bulwark"
		},

		"Noctren": {
			"basic": "shadow_slip",
			"special": "eclipse_dance"
		},

		"Solvyr": {
			"basic": "lunar_sight",
			"special": "moonshot"
		},

		"Mavros": {
			"basic": "wingstep",
			"special": "phantom_assault"
		},

		"Karnyx": {
			"basic": "hold_the_line",
			"special": "unbreakable_line"
		},

		"Raxen": {
			"basic": "chain_work",
			"special": "swarm_assault"
		},

		"Vexira": {
			"basic": "weak_point",
			"special": "colony_execution"
		},

		"Tarsik": {
			"basic": "coordinated_fire",
			"special": "suppression_volley"
		},

		"Myraxa": {
			"basic": "colony_signal",
			"special": "colony_command"
		},

		"Brontis": {
			"basic": "heavy_shell",
			"special": "fortress_shell"
		},

		"Kharvos": {
			"basic": "groundbreaker",
			"special": "seismic_breaker"
		},

		"Virex": {
			"basic": "shellbreaker",
			"special": "shatterstrike"
		},

		"Ignivar": {
			"basic": "heavy_bolt",
			"special": "siege_cannon"
		},

		"Aurelia": {
			"basic": "shell_mend",
			"special": "citadel_shell"
		},

		"Mordrax": {
			"basic": "toxic_guard",
			"special": "toxic_retribution"
		},

		"Scyrix": {
			"basic": "blood_rush",
			"special": "blood_frenzy"
		},

		"Nyzara": {
			"basic": "flashstep",
			"special": "venom_flash"
		},

		"Veltrix": {
			"basic": "venom_shot",
			"special": "toxic_barrage"
		},

		"Thesira": {
			"basic": "adrenal_venom",
			"special": "frenzy_injection"
		}
	}


	for character_name in assignments.keys():

		var data_path: String = (
			"res://Data/"
			+ character_name
			+ ".tres"
		)


		if not ResourceLoader.exists(
			data_path
		):

			print(
				"SKIPPED - Missing file: "
				+ data_path
			)

			continue


		var character_data: CharacterData = (
			load(
				data_path
			) as CharacterData
		)


		if character_data == null:

			print(
				"SKIPPED - Could not load: "
				+ data_path
			)

			continue


		var ability_info: Dictionary = (
			assignments[
				character_name
			]
		)


		character_data.basic_ability_id = (
			ability_info[
				"basic"
			]
		)


		character_data.special_ability_id = (
			ability_info[
				"special"
			]
		)


		var save_result: Error = (
			ResourceSaver.save(
				character_data,
				data_path
			)
		)


		if save_result == OK:

			print(
				"UPDATED "
				+ character_name
				+ " -> Basic: "
				+ character_data.basic_ability_id
				+ " | Special: "
				+ character_data.special_ability_id
			)

		else:

			print(
				"FAILED TO SAVE "
				+ character_name
				+ " Error: "
				+ str(save_result)
			)


	print(
		"Finished assigning NESTSWARM ability IDs."
	)
