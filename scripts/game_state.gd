extends RefCounted
class_name GameState

const SAVE_PATH = "user://melody_mill_save.json"
const MILL_DATA_DIR = "res://data/mills"
const THEME_DATA_DIR = "res://data/theme_packs"
const HARMONY_TREE_NODES = [
	{
		"id": "better_claws",
		"name": "Better Claws",
		"branch": "Craft",
		"cost": 1,
		"description": "+1 click power in every Mill.",
		"effect_type": "click_flat",
		"effect_value": 1.0
	},
	{
		"id": "quick_paws",
		"name": "Quick Paws",
		"branch": "Rhythm",
		"cost": 2,
		"description": "+15% auto production in every Mill.",
		"effect_type": "auto_mult",
		"effect_value": 0.15
	},
	{
		"id": "resonant_strings",
		"name": "Resonant Strings",
		"branch": "Harmony",
		"cost": 3,
		"description": "+10% all production.",
		"effect_type": "all_mult",
		"effect_value": 0.10
	},
	{
		"id": "steady_beat",
		"name": "Steady Beat",
		"branch": "Rhythm",
		"cost": 5,
		"description": "+1 music layer intensity in every Mill.",
		"effect_type": "extra_layers",
		"effect_value": 1.0
	},
	{
		"id": "echo_chamber",
		"name": "Echo Chamber",
		"branch": "Discovery",
		"cost": 6,
		"description": "+1 Harmony Point on each prestige.",
		"effect_type": "prestige_flat",
		"effect_value": 1.0
	},
	{
		"id": "starter_refrain",
		"name": "Starter Refrain",
		"branch": "Craft",
		"cost": 4,
		"description": "Begin each new run with 25 resource.",
		"effect_type": "starting_resource",
		"effect_value": 25.0
	},
	{
		"id": "bright_hook",
		"name": "Bright Hook",
		"branch": "Harmony",
		"cost": 7,
		"description": "+25% click power.",
		"effect_type": "click_mult",
		"effect_value": 0.25
	},
	{
		"id": "open_score",
		"name": "Open Score",
		"branch": "Discovery",
		"cost": 8,
		"description": "Reserve a future Theme Pack slot. +10% all production for now.",
		"effect_type": "all_mult",
		"effect_value": 0.10
	}
]

var mill_definitions: Dictionary = {}
var upgrade_lookup: Dictionary = {}
var theme_packs: Dictionary = {}
var save_data: Dictionary = {}
var dirty = false


func _init() -> void:
	load_content()
	load_save()


func load_content() -> void:
	mill_definitions.clear()
	upgrade_lookup.clear()
	theme_packs.clear()
	_load_json_dir(MILL_DATA_DIR, mill_definitions)
	_load_json_dir(THEME_DATA_DIR, theme_packs)

	for mill_id in mill_definitions.keys():
		var lookup = {}
		for upgrade in get_mill_definition(mill_id).get("upgrades", []):
			lookup[upgrade["id"]] = upgrade
		upgrade_lookup[mill_id] = lookup


func load_save() -> void:
	save_data = _default_save_data()
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			var parsed = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				save_data = _merge_save_with_defaults(parsed)
	for mill_id in mill_definitions.keys():
		_ensure_mill_state(mill_id)
	dirty = false


func save_to_disk() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(save_data, "\t"))
	dirty = false


func flush_if_dirty() -> void:
	if dirty:
		save_to_disk()


func get_mill_definition(mill_id: String) -> Dictionary:
	return mill_definitions.get(mill_id, {})


func get_upgrade_definition(mill_id: String, upgrade_id: String) -> Dictionary:
	return upgrade_lookup.get(mill_id, {}).get(upgrade_id, {})


func get_mill_state(mill_id: String) -> Dictionary:
	_ensure_mill_state(mill_id)
	return save_data["mills"][mill_id]


func get_harmony_tree_nodes() -> Array:
	return HARMONY_TREE_NODES


func get_harmony_points() -> int:
	return int(save_data.get("harmony_points", 0))


func get_theme_pack(theme_id: String) -> Dictionary:
	return theme_packs.get(theme_id, {})


func get_available_theme_packs(mill_id: String) -> Array:
	var available = []
	for theme_id in theme_packs.keys():
		var theme: Dictionary = theme_packs[theme_id]
		var supported: Array = theme.get("supported_mills", [])
		if supported.has(mill_id):
			available.append(theme)
	available.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a.get("name", "")) < String(b.get("name", "")))
	return available


func get_active_theme_pack(mill_id: String) -> Dictionary:
	var mill_state = get_mill_state(mill_id)
	return get_theme_pack(String(mill_state.get("active_theme_pack", _get_default_theme_for_mill(mill_id))))


func set_active_theme_pack(mill_id: String, theme_id: String) -> void:
	var available_ids = []
	for theme in get_available_theme_packs(mill_id):
		available_ids.append(theme["id"])
	if not available_ids.has(theme_id):
		return
	get_mill_state(mill_id)["active_theme_pack"] = theme_id
	dirty = true


func get_mill_display_name(mill_id: String) -> String:
	var theme = get_active_theme_pack(mill_id)
	return String(theme.get("labels", {}).get("mill_title", get_mill_definition(mill_id).get("name", mill_id)))


func get_resource_display_name(mill_id: String) -> String:
	var theme = get_active_theme_pack(mill_id)
	return String(theme.get("labels", {}).get("resource_name", get_mill_definition(mill_id).get("resource_name", "Resource")))


func get_click_action_name(mill_id: String) -> String:
	var theme = get_active_theme_pack(mill_id)
	return String(theme.get("labels", {}).get("click_action_name", get_mill_definition(mill_id).get("click_action_name", "Click")))


func get_prestige_action_name(mill_id: String) -> String:
	var theme = get_active_theme_pack(mill_id)
	return String(theme.get("labels", {}).get("prestige_action_name", get_mill_definition(mill_id).get("prestige_action_name", "Prestige")))


func get_upgrade_display_name(mill_id: String, upgrade_id: String) -> String:
	var theme = get_active_theme_pack(mill_id)
	var overrides: Dictionary = theme.get("upgrade_name_overrides", {})
	if overrides.has(upgrade_id):
		return String(overrides[upgrade_id])
	return String(get_upgrade_definition(mill_id, upgrade_id).get("name", upgrade_id))


func get_upgrade_count(mill_id: String, upgrade_id: String) -> int:
	return int(get_mill_state(mill_id).get("upgrades", {}).get(upgrade_id, 0))


func get_upgrade_cost(mill_id: String, upgrade_id: String) -> int:
	var definition = get_upgrade_definition(mill_id, upgrade_id)
	var owned = get_upgrade_count(mill_id, upgrade_id)
	var base_cost = float(definition.get("base_cost", 10))
	var cost_growth = float(definition.get("cost_growth", 1.15))
	return int(ceil(base_cost * pow(cost_growth, owned)))


func can_purchase_upgrade(mill_id: String, upgrade_id: String) -> bool:
	return float(get_mill_state(mill_id).get("resource", 0.0)) >= get_upgrade_cost(mill_id, upgrade_id)


func purchase_upgrade(mill_id: String, upgrade_id: String) -> bool:
	if not can_purchase_upgrade(mill_id, upgrade_id):
		return false
	var mill_state = get_mill_state(mill_id)
	var upgrades: Dictionary = mill_state.get("upgrades", {})
	mill_state["resource"] = float(mill_state.get("resource", 0.0)) - get_upgrade_cost(mill_id, upgrade_id)
	upgrades[upgrade_id] = int(upgrades.get(upgrade_id, 0)) + 1
	mill_state["upgrades"] = upgrades
	dirty = true
	return true


func earn_resource(mill_id: String, amount: float) -> Dictionary:
	var result = {
		"amount": amount,
		"stages": []
	}
	if amount <= 0.0:
		return result

	var mill_state = get_mill_state(mill_id)
	mill_state["resource"] = float(mill_state.get("resource", 0.0)) + amount
	mill_state["run_resource"] = float(mill_state.get("run_resource", 0.0)) + amount
	mill_state["all_time_resource"] = float(mill_state.get("all_time_resource", 0.0)) + amount
	mill_state["stage_progress"] = float(mill_state.get("stage_progress", 0.0)) + amount

	var stages: Array = get_mill_definition(mill_id).get("stages", [])
	while int(mill_state.get("stage_index", 0)) < stages.size() - 1:
		var current_index = int(mill_state.get("stage_index", 0))
		var goal = float(stages[current_index].get("goal", 1.0))
		if float(mill_state.get("stage_progress", 0.0)) < goal:
			break
		mill_state["stage_progress"] = float(mill_state.get("stage_progress", 0.0)) - goal
		mill_state["stage_index"] = current_index + 1
		result["stages"].append(stages[current_index + 1].get("name", ""))

	dirty = true
	return result


func get_current_stage(mill_id: String) -> Dictionary:
	var stages: Array = get_mill_definition(mill_id).get("stages", [])
	if stages.is_empty():
		return {}
	return stages[int(get_mill_state(mill_id).get("stage_index", 0))]


func get_current_stage_goal(mill_id: String) -> float:
	var stages: Array = get_mill_definition(mill_id).get("stages", [])
	if stages.is_empty():
		return 1.0
	var index = int(get_mill_state(mill_id).get("stage_index", 0))
	if index >= stages.size():
		index = stages.size() - 1
	return float(stages[index].get("goal", 1.0))


func get_stage_progress_ratio(mill_id: String) -> float:
	var goal = get_current_stage_goal(mill_id)
	if goal <= 0.0:
		return 0.0
	var progress = float(get_mill_state(mill_id).get("stage_progress", 0.0))
	return clamp(progress / goal, 0.0, 1.0)


func get_click_power(mill_id: String) -> float:
	var click_power = 1.0 + get_tree_effect_total("click_flat")
	for upgrade in get_mill_definition(mill_id).get("upgrades", []):
		click_power += get_upgrade_count(mill_id, String(upgrade["id"])) * float(upgrade.get("click_bonus", 0.0))
	click_power *= get_total_production_multiplier(mill_id)
	click_power *= 1.0 + get_tree_effect_total("click_mult")
	return click_power


func get_auto_production_per_second(mill_id: String) -> float:
	var auto_rate = 0.0
	for upgrade in get_mill_definition(mill_id).get("upgrades", []):
		auto_rate += get_upgrade_count(mill_id, String(upgrade["id"])) * float(upgrade.get("auto_rate", 0.0))
	auto_rate *= get_total_production_multiplier(mill_id)
	auto_rate *= 1.0 + get_tree_effect_total("auto_mult")
	return auto_rate


func get_total_production_multiplier(mill_id: String) -> float:
	var multiplier = 1.0 + get_tree_effect_total("all_mult")
	for upgrade in get_mill_definition(mill_id).get("upgrades", []):
		var owned = get_upgrade_count(mill_id, String(upgrade["id"]))
		multiplier += owned * float(upgrade.get("production_multiplier", 0.0))
		multiplier += owned * float(upgrade.get("auto_multiplier", 0.0))
	return multiplier


func get_lane_intensities(mill_id: String) -> Dictionary:
	var intensities = {
		"percussion": 0,
		"melody": 0,
		"bass": 0,
		"texture": 0
	}
	for upgrade in get_mill_definition(mill_id).get("upgrades", []):
		var owned = get_upgrade_count(mill_id, String(upgrade["id"]))
		if owned <= 0:
			continue
		var lane = String(upgrade.get("lane", "melody"))
		var current_value = int(intensities.get(lane, 0))
		intensities[lane] = min(3, current_value + int(ceil(float(owned) / 2.0)))
	if get_total_owned_upgrades(mill_id) > 0:
		intensities["melody"] = max(intensities["melody"], 1)
	var extra_layers = int(get_tree_effect_total("extra_layers"))
	intensities["texture"] = min(3, int(intensities["texture"]) + extra_layers)
	return intensities


func get_total_owned_upgrades(mill_id: String) -> int:
	var total = 0
	for upgrade in get_mill_definition(mill_id).get("upgrades", []):
		total += get_upgrade_count(mill_id, String(upgrade["id"]))
	return total


func can_prestige(mill_id: String) -> bool:
	var stages: Array = get_mill_definition(mill_id).get("stages", [])
	if stages.is_empty():
		return false
	return int(get_mill_state(mill_id).get("stage_index", 0)) >= stages.size() - 1 and get_prestige_reward(mill_id) > 0


func get_prestige_reward(mill_id: String) -> int:
	if int(get_mill_state(mill_id).get("stage_index", 0)) < get_mill_definition(mill_id).get("stages", []).size() - 1:
		return 0
	var run_resource = float(get_mill_state(mill_id).get("run_resource", 0.0))
	var goal = float(get_mill_definition(mill_id).get("prestige_goal_resource", 80000.0))
	var reward = int(floor(sqrt(max(run_resource, 0.0) / goal) * 4.0))
	reward += int(get_tree_effect_total("prestige_flat"))
	return max(reward, 1)


func prestige_mill(mill_id: String) -> int:
	var reward = get_prestige_reward(mill_id)
	if reward <= 0:
		return 0

	save_data["harmony_points"] = int(save_data.get("harmony_points", 0)) + reward

	var old_state = get_mill_state(mill_id).duplicate(true)
	var preserved_theme = String(old_state.get("active_theme_pack", _get_default_theme_for_mill(mill_id)))
	var preserved_prestige_count = int(old_state.get("prestige_count", 0)) + 1
	var preserved_all_time = float(old_state.get("all_time_resource", 0.0))

	save_data["mills"][mill_id] = _default_mill_state(mill_id)
	var new_state = get_mill_state(mill_id)
	new_state["active_theme_pack"] = preserved_theme
	new_state["prestige_count"] = preserved_prestige_count
	new_state["all_time_resource"] = preserved_all_time
	new_state["resource"] = get_tree_effect_total("starting_resource")
	new_state["run_resource"] = new_state["resource"]
	dirty = true
	return reward


func can_buy_tree_node(node_id: String) -> bool:
	if has_tree_node(node_id):
		return false
	var node = get_tree_node(node_id)
	if node.is_empty():
		return false
	return get_harmony_points() >= int(node.get("cost", 0))


func buy_tree_node(node_id: String) -> bool:
	if not can_buy_tree_node(node_id):
		return false
	save_data["harmony_points"] = int(save_data.get("harmony_points", 0)) - int(get_tree_node(node_id).get("cost", 0))
	var purchased: Array = save_data.get("purchased_tree_nodes", [])
	purchased.append(node_id)
	save_data["purchased_tree_nodes"] = purchased
	dirty = true
	return true


func has_tree_node(node_id: String) -> bool:
	return save_data.get("purchased_tree_nodes", []).has(node_id)


func get_tree_node(node_id: String) -> Dictionary:
	for node in HARMONY_TREE_NODES:
		if node["id"] == node_id:
			return node
	return {}


func get_tree_effect_total(effect_type: String) -> float:
	var total = 0.0
	for node in HARMONY_TREE_NODES:
		if node["effect_type"] == effect_type and has_tree_node(String(node["id"])):
			total += float(node.get("effect_value", 0.0))
	return total


func format_number(value: float) -> String:
	if value < 1000.0:
		return str(snappedf(value, 0.1))
	var suffixes = ["K", "M", "B", "T", "Qa", "Qi"]
	var size = value
	var suffix_index = -1
	while size >= 1000.0 and suffix_index < suffixes.size() - 1:
		size /= 1000.0
		suffix_index += 1
	return "%0.2f%s" % [size, suffixes[suffix_index]]


func _default_save_data() -> Dictionary:
	return {
		"harmony_points": 0,
		"purchased_tree_nodes": [],
		"mills": {}
	}


func _default_mill_state(mill_id: String) -> Dictionary:
	var upgrades = {}
	for upgrade in get_mill_definition(mill_id).get("upgrades", []):
		upgrades[upgrade["id"]] = 0
	return {
		"resource": 0.0,
		"run_resource": 0.0,
		"all_time_resource": 0.0,
		"stage_index": 0,
		"stage_progress": 0.0,
		"prestige_count": 0,
		"upgrades": upgrades,
		"active_theme_pack": _get_default_theme_for_mill(mill_id)
	}


func _ensure_mill_state(mill_id: String) -> void:
	if not save_data["mills"].has(mill_id):
		save_data["mills"][mill_id] = _default_mill_state(mill_id)
		dirty = true
		return

	var current_state: Dictionary = save_data["mills"][mill_id]
	var default_state = _default_mill_state(mill_id)
	for key in default_state.keys():
		if not current_state.has(key):
			current_state[key] = default_state[key]
			dirty = true

	var upgrade_defaults: Dictionary = default_state["upgrades"]
	var current_upgrades: Dictionary = current_state.get("upgrades", {})
	for upgrade_id in upgrade_defaults.keys():
		if not current_upgrades.has(upgrade_id):
			current_upgrades[upgrade_id] = 0
			dirty = true
	current_state["upgrades"] = current_upgrades


func _merge_save_with_defaults(raw_save: Dictionary) -> Dictionary:
	var merged = _default_save_data()
	for key in merged.keys():
		if raw_save.has(key):
			merged[key] = raw_save[key]
	return merged


func _load_json_dir(dir_path: String, target: Dictionary) -> void:
	var dir = DirAccess.open(dir_path)
	if dir == null:
		return
	for file_name in dir.get_files():
		if not String(file_name).ends_with(".json"):
			continue
		var data = _load_json_file(dir_path.path_join(file_name))
		if data is Dictionary and data.has("id"):
			target[data["id"]] = data


func _load_json_file(path: String):
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null:
		return {}
	return parsed


func _get_default_theme_for_mill(mill_id: String) -> String:
	for theme in get_available_theme_packs(mill_id):
		return String(theme["id"])
	return ""
