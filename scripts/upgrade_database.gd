extends Node


# =========================================================
# NESTSWARM UPGRADE DATABASE
# =========================================================
#
# BASIC ABILITIES
# - Automatic
# - One per character
# - Never appear as upgrade choices
#
# CLASS UPGRADES
# - Four per class
# - Shared by every character in that class
# - Non-repeatable per character
#
# SPECIAL UPGRADES
# - One unique Special per character
# - Non-repeatable
#
# EQUIPMENT
# - Shared by everyone
# - Repeatable
#
# Card categories:
# Special = Gold
# Class   = Green
# Item    = Crimson / Red
# =========================================================


# =========================================================
# BASIC ABILITIES
# =========================================================

var basic_abilities: Dictionary = {

	"royal_guard": {
		"id": "royal_guard",
		"name": "Royal Guard",
		"type": "Basic",
		"description": "The first time an enemy targets a backline ally within medium range, Veyra retargets that enemy and gains a 15 HP shield for 4 seconds. Once per round."
	},

	"predator_sting": {
		"id": "predator_sting",
		"name": "Predator Sting",
		"type": "Basic",
		"description": "At combat start, Zekrin prioritizes the farthest living enemy and gains +20 Move Speed until his first attack. That first hit deals +4 damage."
	},

	"royal_nectar": {
		"id": "royal_nectar",
		"name": "Royal Nectar",
		"type": "Basic",
		"description": "Every 5th basic attack heals the lowest-health living ally for 7 HP. Melora can target herself."
	},

	"wing_rush": {
		"id": "wing_rush",
		"name": "Wing Rush",
		"type": "Basic",
		"description": "When Tharos's target moves more than 90 pixels outside his attack range, he gains +25 Move Speed for up to 2 seconds while chasing. 4-second internal cooldown."
	},

	"needle_line": {
		"id": "needle_line",
		"name": "Needle Line",
		"type": "Basic",
		"description": "Every 4th basic attack can pierce one enemy behind the main target within 110 pixels for 40% basic attack damage."
	},

	"horn_charge": {
		"id": "horn_charge",
		"name": "Horn Charge",
		"type": "Basic",
		"description": "At combat start, Kaelor charges up to 120 pixels toward his initial target. The first enemy contacted takes +3 damage and is staggered for 0.5 seconds."
	},

	"ambush_leap": {
		"id": "ambush_leap",
		"name": "Ambush Leap",
		"type": "Basic",
		"description": "At combat start, Syrra leaps near a random enemy in the back two rows, prioritizing Marksmen and Supports. She gains +10% Attack Speed for 2 seconds after landing."
	},

	"territorial_guard": {
		"id": "territorial_guard",
		"name": "Territorial Guard",
		"type": "Basic",
		"description": "When an enemy within 100 pixels changes target from Droven toward an ally, that enemy is forced to retarget Droven for 2 seconds. 6-second cooldown."
	},

	"acid_shot": {
		"id": "acid_shot",
		"name": "Acid Shot",
		"type": "Basic",
		"description": "Every 5th basic attack applies Corroded. The next allied attack against that enemy deals +4 damage. The mark lasts up to 4 seconds and does not stack."
	},

	"marked_prey": {
		"id": "marked_prey",
		"name": "Marked Prey",
		"type": "Basic",
		"description": "Velkara's first successful attack marks the target for 5 seconds. Allies give that enemy +25% targeting priority and deal +1 damage to it. Once per round."
	},

	"moon_veil": {
		"id": "moon_veil",
		"name": "Moon Veil",
		"type": "Basic",
		"description": "When the lowest-health ally is about to take a damaging hit, Lunara reduces that hit by 30%. 7-second cooldown."
	},

	"phase_step": {
		"id": "phase_step",
		"name": "Phase Step",
		"type": "Basic",
		"description": "The first time Vorren falls to 50% HP or lower, he shifts 70 pixels away from his current target and gains +20 Move Speed for 2 seconds. Once per round."
	},

	"shadow_slip": {
		"id": "shadow_slip",
		"name": "Shadow Slip",
		"type": "Basic",
		"description": "After Noctren's first successful attack against a new target, he blinks to the opposite side of that target and gains +15 Move Speed for 1.5 seconds. 5-second cooldown."
	},

	"lunar_sight": {
		"id": "lunar_sight",
		"name": "Lunar Sight",
		"type": "Basic",
		"description": "Solvyr gives higher target priority to enemies with no ally within 100 pixels. While attacking an isolated target, he gains +25 Attack Range."
	},

	"wingstep": {
		"id": "wingstep",
		"name": "Wingstep",
		"type": "Basic",
		"description": "After 3 consecutive attacks against the same target, Mavros sidesteps 40 pixels around them and gains +15 Move Speed for 2 seconds. Switching targets resets the counter."
	},

	"hold_the_line": {
		"id": "hold_the_line",
		"name": "Hold the Line",
		"type": "Basic",
		"description": "Karnyx completely ignores the first knockback, stagger, displacement, or forced-movement effect each round and then gains an 8 HP shield."
	},

	"chain_work": {
		"id": "chain_work",
		"name": "Chain Work",
		"type": "Basic",
		"description": "When Raxen attacks an enemy another Formicara ally hit within the previous 2 seconds, the attack deals +3 damage. 2-second cooldown."
	},

	"weak_point": {
		"id": "weak_point",
		"name": "Weak Point",
		"type": "Basic",
		"description": "Vexira gives increased priority to enemies below 50% HP. When she switches to one, she gains +20 Move Speed for 2 seconds. 4-second cooldown."
	},

	"coordinated_fire": {
		"id": "coordinated_fire",
		"name": "Coordinated Fire",
		"type": "Basic",
		"description": "Tarsik's basic attack deals +3 damage when the target was hit by any ally within the previous 1.5 seconds."
	},

	"colony_signal": {
		"id": "colony_signal",
		"name": "Colony Signal",
		"type": "Basic",
		"description": "Every 5th basic attack gives the lowest-health ally +20 Move Speed and 10% damage reduction for 2.5 seconds. Does not stack; refreshes duration."
	},

	"heavy_shell": {
		"id": "heavy_shell",
		"name": "Heavy Shell",
		"type": "Basic",
		"description": "Brontis starts combat with a 20 HP shield lasting up to 8 seconds. While the shield remains, he cannot be staggered or knocked back."
	},

	"groundbreaker": {
		"id": "groundbreaker",
		"name": "Groundbreaker",
		"type": "Basic",
		"description": "Every 4th basic attack slows the target's Move Speed by 25% for 2 seconds. The slow does not stack; it refreshes."
	},

	"shellbreaker": {
		"id": "shellbreaker",
		"name": "Shellbreaker",
		"type": "Basic",
		"description": "Virex gives shielded enemies slightly higher targeting priority. Against a shielded enemy, he deals +6 damage directly to the shield before normal attack damage. 3-second cooldown."
	},

	"heavy_bolt": {
		"id": "heavy_bolt",
		"name": "Heavy Bolt",
		"type": "Basic",
		"description": "Every 5th basic attack knocks the target backward 55 pixels. Vanguard targets are pushed only 30 pixels."
	},

	"shell_mend": {
		"id": "shell_mend",
		"name": "Shell Mend",
		"type": "Basic",
		"description": "Every 5th basic attack grants the lowest-health ally a 10 HP shield for up to 5 seconds. A new Shell Mend replaces the old Shell Mend shield."
	},

	"toxic_guard": {
		"id": "toxic_guard",
		"name": "Toxic Guard",
		"type": "Basic",
		"description": "The first enemy to damage Mordrax becomes marked for 5 seconds. Mordrax deals +2 damage whenever he attacks that enemy. Only one enemy may be marked at a time."
	},

	"blood_rush": {
		"id": "blood_rush",
		"name": "Blood Rush",
		"type": "Basic",
		"description": "After 3 consecutive attacks on the same target, Scyrix gains +12% Attack Speed for 3 seconds. Switching targets resets the counter. The buff refreshes but does not stack."
	},

	"flashstep": {
		"id": "flashstep",
		"name": "Flashstep",
		"type": "Basic",
		"description": "At combat start, Nyzara dashes up to 140 pixels toward the lowest-health enemy in the back three rows. Her first attack afterward has 20% faster recovery."
	},

	"venom_shot": {
		"id": "venom_shot",
		"name": "Venom Shot",
		"type": "Basic",
		"description": "Every 4th basic attack applies venom dealing 2 damage after 1 second and 2 more after 2 seconds. Reapplying refreshes the venom instead of stacking."
	},

	"adrenal_venom": {
		"id": "adrenal_venom",
		"name": "Adrenal Venom",
		"type": "Basic",
		"description": "Every 5th basic attack grants the lowest-health living ally +15% Attack Speed for 3 seconds. It can target Thesira and refreshes instead of stacking."
	}
}


# =========================================================
# GENERIC EQUIPMENT
# =========================================================

var equipment: Array = [

	{
		"id": "up_armored",
		"name": "Up-Armored",
		"type": "Item",
		"description": "+40 Maximum Health",
		"health_bonus": 40
	},

	{
		"id": "kinetic_overcharge",
		"name": "Kinetic Overcharge",
		"type": "Item",
		"description": "+6 Damage",
		"damage_bonus": 6
	},

	{
		"id": "quantum_thrusters",
		"name": "Quantum Thrusters",
		"type": "Item",
		"description": "+30 Move Speed",
		"move_speed_bonus": 30
	},

	{
		"id": "targeting_system",
		"name": "Targeting System",
		"type": "Item",
		"description": "+25 Attack Range",
		"range_bonus": 25
	},

	{
		"id": "rapid_cycle_mechanism",
		"name": "Rapid Cycle Mechanism",
		"type": "Item",
		"description": "-0.15s Attack Cooldown",
		"cooldown_reduction": 0.15
	},

	{
		"id": "fragmentation_plating",
		"name": "Fragmentation Plating",
		"type": "Item",
		"description": "+30 Maximum Health\n+2 Damage",
		"health_bonus": 30,
		"damage_bonus": 2
	},

	{
		"id": "reactive_exoframe",
		"name": "Reactive Exoframe",
		"type": "Item",
		"description": "+25 Maximum Health\n+15 Move Speed",
		"health_bonus": 25,
		"move_speed_bonus": 15
	},

	{
		"id": "overdrive_ignition",
		"name": "Overdrive Ignition",
		"type": "Item",
		"description": "+4 Damage\n+12 Move Speed",
		"damage_bonus": 4,
		"move_speed_bonus": 12
	},

	{
		"id": "long_barrel_conversion",
		"name": "Long-Barrel Conversion",
		"type": "Item",
		"description": "+3 Damage\n+15 Attack Range",
		"damage_bonus": 3,
		"range_bonus": 15
	},

	{
		"id": "rapid_chamber",
		"name": "Rapid Chamber",
		"type": "Item",
		"description": "+2 Damage\n-0.10s Attack Cooldown",
		"damage_bonus": 2,
		"cooldown_reduction": 0.10
	}
]


# =========================================================
# CLASS UPGRADES
# =========================================================

var class_upgrades: Dictionary = {

	"Vanguard": [
		{"id": "guardians_reach", "name": "Guardian's Reach", "type": "Class", "description": "Allies within 90 pixels take 10% less basic-attack damage. The Vanguard does not receive this reduction. Multiple Guardian's Reach effects do not stack.", "effect_id": "guardians_reach"},
		{"id": "shield_bash", "name": "Shield Bash", "type": "Class", "description": "Every 5th basic attack staggers the target for 0.5 seconds. The same target cannot be staggered by Shield Bash more than once every 4 seconds.", "effect_id": "shield_bash"},
		{"id": "last_stand", "name": "Last Stand", "type": "Class", "description": "The first time this Vanguard falls to 30% HP or lower, gain 25% damage reduction for 3 seconds. Once per round.", "effect_id": "last_stand"},
		{"id": "retaliation_protocol", "name": "Retaliation Protocol", "type": "Class", "description": "After receiving 4 damaging basic attacks, the next basic attack deals +5 damage and forces that enemy to target the Vanguard for 1.5 seconds.", "effect_id": "retaliation_protocol"}
	],

	"Fighter": [
		{"id": "combo_breaker", "name": "Combo Breaker", "type": "Class", "description": "The 4th consecutive attack against the same target deals +6 damage. Switching targets resets the counter.", "effect_id": "combo_breaker"},
		{"id": "adrenal_surge", "name": "Adrenal Surge", "type": "Class", "description": "The first time this Fighter reaches 50% HP or lower, gain +15% Attack Speed for 4 seconds. Once per round.", "effect_id": "adrenal_surge"},
		{"id": "sweeping_strike", "name": "Sweeping Strike", "type": "Class", "description": "Every 5th basic attack hits one additional enemy within 70 pixels of the target for 40% basic attack damage.", "effect_id": "sweeping_strike"},
		{"id": "battle_pursuit", "name": "Battle Pursuit", "type": "Class", "description": "When the current target dies, gain +25 Move Speed for 2.5 seconds. The first attack against the next target deals +3 damage. The speed buff refreshes but does not stack.", "effect_id": "battle_pursuit"}
	],

	"Assassin": [
		{"id": "serrated_edge", "name": "Serrated Edge", "type": "Class", "description": "The first attack against a new target applies a bleed dealing 2 damage after 1 second and 2 more after 2 seconds. Bleed from the same Assassin does not stack.", "effect_id": "serrated_edge"},
		{"id": "shadow_momentum", "name": "Shadow Momentum", "type": "Class", "description": "Whenever the Assassin switches to a new target, gain +12% Attack Speed for 2.5 seconds. Refreshes but does not stack.", "effect_id": "shadow_momentum"},
		{"id": "quick_exit", "name": "Quick Exit", "type": "Class", "description": "After getting a kill, immediately prioritize the lowest-health living enemy and gain +30 Move Speed for 2 seconds. The speed bonus does not stack.", "effect_id": "quick_exit"},
		{"id": "evasive_step", "name": "Evasive Step", "type": "Class", "description": "When taking damage below 40% HP, reduce that hit by 40% and dash 60 pixels away from the attacker. 7-second cooldown.", "effect_id": "evasive_step"}
	],

	"Marksman": [
		{"id": "ricochet_round", "name": "Ricochet Round", "type": "Class", "description": "Every 4th basic attack bounces to the nearest second enemy within 100 pixels for 35% of the original basic attack damage. One bounce maximum.", "effect_id": "ricochet_round"},
		{"id": "longshot_calibration", "name": "Longshot Calibration", "type": "Class", "description": "When attacking from at least 180 pixels away, deal +3 damage.", "effect_id": "longshot_calibration"},
		{"id": "suppressing_fire", "name": "Suppressing Fire", "type": "Class", "description": "After 4 consecutive attacks against the same enemy, reduce that enemy's Attack Speed by 10% for 3 seconds. Refreshes but does not stack.", "effect_id": "suppressing_fire"},
		{"id": "entrenched_position", "name": "Entrenched Position", "type": "Class", "description": "After remaining stationary for 2 seconds, gain +25 Attack Range until moving again.", "effect_id": "entrenched_position"}
	],

	"Support": [
		{"id": "emergency_aid", "name": "Emergency Aid", "type": "Class", "description": "The first time any ally falls below 30% HP, immediately restore 8 HP to that ally. Once per round per Support.", "effect_id": "emergency_aid"},
		{"id": "rally_pulse", "name": "Rally Pulse", "type": "Class", "description": "Every 6th basic attack grants the Support and the nearest living ally +10% Attack Speed for 3 seconds. Refreshes but does not stack.", "effect_id": "rally_pulse"},
		{"id": "protective_field", "name": "Protective Field", "type": "Class", "description": "Every 7 seconds, grant the lowest-health living ally an 8 HP shield for up to 4 seconds. A new Protective Field from the same Support replaces the old one.", "effect_id": "protective_field"},
		{"id": "purifying_pulse", "name": "Purifying Pulse", "type": "Class", "description": "Every 8 seconds, remove one removable debuff from the lowest-health affected ally and grant +15 Move Speed for 2 seconds. If nobody has a removable debuff, check again after 2 seconds.", "effect_id": "purifying_pulse"}
	]
}


# =========================================================
# CHARACTER SPECIALS
# =========================================================

var specials: Dictionary = {
	"Veyra": {"id": "queens_bastion", "name": "Queen's Bastion", "type": "Special", "description": "The first time Veyra falls below 40% HP, she gains a 30 HP shield for 5 seconds and every living ally gains a 12 HP shield for 4 seconds. Once per round.", "effect_id": "queens_bastion"},
	"Zekrin": {"id": "predators_dive", "name": "Predator's Dive", "type": "Special", "description": "The first time Zekrin's current target falls below 50% HP, he dashes behind them, deals +8 damage, and gains +20% Attack Speed for 3 seconds. Once per round.", "effect_id": "predators_dive"},
	"Melora": {"id": "royal_bloom", "name": "Royal Bloom", "type": "Special", "description": "Every 10th basic attack heals all living allies for 8 HP and the lowest-health ally for an additional 8 HP. Cannot trigger more often than once every 8 seconds.", "effect_id": "royal_bloom"},
	"Tharos": {"id": "frenzy_tempest", "name": "Frenzy Tempest", "type": "Special", "description": "The first time Tharos falls below 50% HP, gain +20% Attack Speed, +20 Move Speed, and +4 Damage for 4 seconds. Once per round.", "effect_id": "frenzy_tempest"},
	"Aurex": {"id": "golden_barrage", "name": "Golden Barrage", "type": "Special", "description": "Every 8th basic attack pierces up to 3 enemies in a line. The first takes normal damage, the second 70%, and the third 45%.", "effect_id": "golden_barrage"},
	"Kaelor": {"id": "stampede", "name": "Stampede", "type": "Special", "description": "The first time Kaelor acquires a new target after his initial target dies, charge up to 160 pixels toward it. Enemies crossed take 6 damage and are staggered for 0.4 seconds. Once per round.", "effect_id": "stampede"},
	"Syrra": {"id": "apex_pounce", "name": "Apex Pounce", "type": "Special", "description": "When Syrra's initial Ambush Leap target reaches 50% HP or lower, she leaps directly behind them, deals +7 damage, and is untargetable for 0.5 seconds during the leap. Once per round.", "effect_id": "apex_pounce"},
	"Droven": {"id": "dominant_territory", "name": "Dominant Territory", "type": "Special", "description": "The first time Droven falls below 50% HP, enemies within 120 pixels are forced to target him for 2.5 seconds while he gains 20% damage reduction. Once per round.", "effect_id": "dominant_territory"},
	"Nyxis": {"id": "corrosive_volley", "name": "Corrosive Volley", "type": "Special", "description": "Every second Acid Shot activation applies Corroded to the target and the two nearest enemies. Their next allied hit receives +4 damage.", "effect_id": "corrosive_volley"},
	"Velkara": {"id": "grand_hunt", "name": "Grand Hunt", "type": "Special", "description": "When Velkara's Marked Prey target dies, immediately mark the lowest-health living enemy for 5 seconds. Allies deal +2 damage to the new marked target. Once per round.", "effect_id": "grand_hunt"},
	"Lunara": {"id": "lunar_sanctuary", "name": "Lunar Sanctuary", "type": "Special", "description": "The first time any ally falls below 30% HP, that ally gains 40% damage reduction for 3 seconds and heals 6 HP. Once per round.", "effect_id": "lunar_sanctuary"},
	"Vorren": {"id": "phantom_bulwark", "name": "Phantom Bulwark", "type": "Special", "description": "After Phase Step activates, Vorren leaves a 20 HP phantom at his old position for 3 seconds. Nearby enemies temporarily prioritize the phantom. Once per round.", "effect_id": "phantom_bulwark"},
	"Noctren": {"id": "eclipse_dance", "name": "Eclipse Dance", "type": "Special", "description": "After Shadow Slip activates 3 times, Noctren performs 3 rapid strikes against his current target at 60% normal basic damage each while blinking around them. Once per round.", "effect_id": "eclipse_dance"},
	"Solvyr": {"id": "moonshot", "name": "Moonshot", "type": "Special", "description": "After attacking an isolated enemy 4 consecutive times, the next shot gains battlefield-wide range and deals 150% basic attack damage. 6-second cooldown after firing.", "effect_id": "moonshot"},
	"Mavros": {"id": "phantom_assault", "name": "Phantom Assault", "type": "Special", "description": "Every second Wingstep activation performs 2 additional attacks against the current target at 50% damage each. 7-second cooldown.", "effect_id": "phantom_assault"},
	"Karnyx": {"id": "unbreakable_line", "name": "Unbreakable Line", "type": "Special", "description": "The first time Karnyx falls below 40% HP, gain a 20 HP shield and become immune to displacement and stagger for 4 seconds. Allies within 80 pixels gain 10% damage reduction during that time. Once per round.", "effect_id": "unbreakable_line"},
	"Raxen": {"id": "swarm_assault", "name": "Swarm Assault", "type": "Special", "description": "After Chain Work activates 3 times, Raxen and the Formicara ally who most recently attacked his target gain +15% Attack Speed for 3 seconds. Does not stack; can trigger again after another 3 Chain Work activations.", "effect_id": "swarm_assault"},
	"Vexira": {"id": "colony_execution", "name": "Colony Execution", "type": "Special", "description": "Against an enemy below 25% HP, deal +8 damage. If that attack kills the target, gain +25 Move Speed for 3 seconds and immediately search for another wounded enemy. 5-second cooldown.", "effect_id": "colony_execution"},
	"Tarsik": {"id": "suppression_volley", "name": "Suppression Volley", "type": "Special", "description": "After Coordinated Fire activates 4 times, fire at the current target plus the two nearest enemies. Secondary targets take 70% basic attack damage. 7-second cooldown.", "effect_id": "suppression_volley"},
	"Myraxa": {"id": "colony_command", "name": "Colony Command", "type": "Special", "description": "The first time an ally falls below 35% HP, all living allies gain +15 Move Speed and 10% damage reduction for 3 seconds. The endangered ally gains +20 Move Speed instead. Once per round.", "effect_id": "colony_command"},
	"Brontis": {"id": "fortress_shell", "name": "Fortress Shell", "type": "Special", "description": "When Heavy Shell is destroyed, immediately gain a second 25 HP shield and 25% damage reduction for 3 seconds. Once per round.", "effect_id": "fortress_shell"},
	"Kharvos": {"id": "seismic_breaker", "name": "Seismic Breaker", "type": "Special", "description": "Every second Groundbreaker activation damages all enemies within 90 pixels for 60% basic attack damage and slows them by 30% for 2 seconds. 6-second internal cooldown.", "effect_id": "seismic_breaker"},
	"Virex": {"id": "shatterstrike", "name": "Shatterstrike", "type": "Special", "description": "The first attack against a shielded enemy removes up to 15 shield HP before the normal attack. 30% of the shield removed becomes bonus damage, rounded down. 5-second cooldown.", "effect_id": "shatterstrike"},
	"Ignivar": {"id": "siege_cannon", "name": "Siege Cannon", "type": "Special", "description": "Every 10th attack deals 140% basic attack damage and knocks the target back 100 pixels. Enemies struck by the knocked-back target take 4 damage and are pushed 30 pixels. Vanguard primary targets are pushed only 60 pixels.", "effect_id": "siege_cannon"},
	"Aurelia": {"id": "citadel_shell", "name": "Citadel Shell", "type": "Special", "description": "The first time two or more allies are below 50% HP simultaneously, all living allies gain an 8 HP shield for 5 seconds and the lowest-health ally receives 18 HP instead. Once per round.", "effect_id": "citadel_shell"},
	"Mordrax": {"id": "toxic_retribution", "name": "Toxic Retribution", "type": "Special", "description": "When Mordrax's Toxic Guard marked enemy has attacked him 4 times, that enemy takes 8 damage over 4 seconds and suffers 10% slower Attack Speed during the poison. Once per marked enemy.", "effect_id": "toxic_retribution"},
	"Scyrix": {"id": "blood_frenzy", "name": "Blood Frenzy", "type": "Special", "description": "When Blood Rush activates for the second time, Scyrix gains +20% Attack Speed and +3 Damage for 4 seconds. Once per round.", "effect_id": "blood_frenzy"},
	"Nyzara": {"id": "venom_flash", "name": "Venom Flash", "type": "Special", "description": "The first time Nyzara's target dies, dash up to 180 pixels toward the lowest-health enemy and immediately attack for 80% normal damage. Once per round.", "effect_id": "venom_flash"},
	"Veltrix": {"id": "toxic_barrage", "name": "Toxic Barrage", "type": "Special", "description": "Every third Venom Shot activation poisons the current target and the nearest enemy within 100 pixels. Each takes 3 damage after 1 second and 3 more after 2 seconds. Existing Veltrix poison refreshes instead of stacking.", "effect_id": "toxic_barrage"},
	"Thesira": {"id": "frenzy_injection", "name": "Frenzy Injection", "type": "Special", "description": "The first time any ally falls below 35% HP, all living allies gain +15% Attack Speed for 4 seconds. The endangered ally receives +20% instead. Once per round.", "effect_id": "frenzy_injection"}
}


# =========================================================
# LOOKUPS
# =========================================================

func get_basic_ability(
	ability_id: String
) -> Dictionary:

	if basic_abilities.has(ability_id):
		return basic_abilities[ability_id]

	return {}


func get_special(
	character_name: String
) -> Dictionary:

	if specials.has(character_name):
		return specials[character_name]

	return {}


# =========================================================
# CHARACTER DATA LOOKUP
# =========================================================

func get_character_data(
	character_name: String
) -> CharacterData:

	var data_path: String = (
		"res://Data/"
		+ character_name
		+ ".tres"
	)

	if not ResourceLoader.exists(data_path):
		return null

	return load(data_path) as CharacterData


# =========================================================
# CHECK OWNED NON-REPEATABLE UPGRADE
# =========================================================

func character_has_upgrade(
	character_name: String,
	upgrade_id: String
) -> bool:

	if not GameState.character_upgrades.has(character_name):
		return false

	for upgrade in GameState.character_upgrades[character_name]:

		if (
			upgrade.has("id")
			and upgrade["id"] == upgrade_id
		):
			return true

	return false


# =========================================================
# GET UPGRADE POOL
# =========================================================

func get_upgrade_pool(
	character_name: String
) -> Array:

	var upgrade_pool: Array = []


	# Repeatable equipment.
	for item in equipment:
		upgrade_pool.append(item)


	var character_data: CharacterData = (
		get_character_data(character_name)
	)


	if character_data == null:
		return upgrade_pool


	# Non-repeatable class upgrades.
	var role_name: String = character_data.class_role

	if class_upgrades.has(role_name):

		for class_upgrade in class_upgrades[role_name]:

			if not character_has_upgrade(
				character_name,
				class_upgrade["id"]
			):
				upgrade_pool.append(class_upgrade)


	# Non-repeatable unique Special.
	if specials.has(character_name):

		var special_upgrade: Dictionary = specials[character_name]

		if not character_has_upgrade(
			character_name,
			special_upgrade["id"]
		):
			upgrade_pool.append(special_upgrade)


	return upgrade_pool


# =========================================================
# RANDOM THREE
# =========================================================

func get_random_three(
	character_name: String
) -> Array:

	var upgrade_pool: Array = (
		get_upgrade_pool(character_name)
	)

	upgrade_pool.shuffle()

	var choices: Array = []

	var choice_count: int = min(
		3,
		upgrade_pool.size()
	)

	for i in range(choice_count):
		choices.append(upgrade_pool[i])

	return choices
