extends Control

const GameStateScript := preload("res://scripts/game_state.gd")
const AudioConductorScript := preload("res://scripts/audio_conductor.gd")

var game_state: GameState
var conductor: AudioConductor
var current_mill_id := "cat_mill"
var current_theme_id := ""
var status_message := "Build the first melody by buying cats and spinning the yarn."
var ui_refresh_accumulator := 0.0
var upgrade_refresh_accumulator := 0.0

var background_rect: ColorRect
var title_label: Label
var subtitle_label: Label
var mill_label: Label
var resource_label: Label
var harmony_label: Label
var production_label: Label
var stage_label: Label
var stage_bar: ProgressBar
var stage_progress_label: Label
var click_button: Button
var click_hint_label: Label
var prestige_info_label: Label
var prestige_button: Button
var theme_option_button: OptionButton
var upgrade_container: VBoxContainer
var harmony_tree_container: VBoxContainer
var lane_bar_map := {}
var lane_slider_map := {}
var music_toggle: CheckBox
var status_label: Label

var panel_nodes: Array = []
var alt_panel_nodes: Array = []
var button_nodes: Array = []
var label_nodes: Array = []
var muted_label_nodes: Array = []


func _ready() -> void:
	game_state = GameStateScript.new()
	current_theme_id = String(game_state.get_active_theme_pack(current_mill_id).get("id", ""))

	conductor = AudioConductorScript.new()
	add_child(conductor)
	conductor.set_lane_intensities(game_state.get_lane_intensities(current_mill_id))

	_build_ui()
	_refresh_everything()

	var autosave_timer := Timer.new()
	autosave_timer.wait_time = 5.0
	autosave_timer.autostart = true
	autosave_timer.timeout.connect(_on_autosave_timeout)
	add_child(autosave_timer)


func _process(delta: float) -> void:
	var auto_gain := game_state.get_auto_production_per_second(current_mill_id) * delta
	if auto_gain > 0.0:
		var result := game_state.earn_resource(current_mill_id, auto_gain)
		if not result["stages"].is_empty():
			status_message = "A bigger yarn ball has appeared: %s." % String(result["stages"][-1])

	ui_refresh_accumulator += delta
	upgrade_refresh_accumulator += delta
	if ui_refresh_accumulator >= 0.1:
		ui_refresh_accumulator = 0.0
		_refresh_runtime_labels()
		_refresh_music_meter()
	if upgrade_refresh_accumulator >= 0.5:
		upgrade_refresh_accumulator = 0.0
		_rebuild_upgrade_list()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		game_state.flush_if_dirty()


func _build_ui() -> void:
	background_rect = ColorRect.new()
	background_rect.anchor_right = 1.0
	background_rect.anchor_bottom = 1.0
	add_child(background_rect)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 16)
	margin.add_child(root)

	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	root.add_child(header)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 34)
	header.add_child(title_label)
	label_nodes.append(title_label)

	subtitle_label = Label.new()
	subtitle_label.add_theme_font_size_override("font_size", 15)
	header.add_child(subtitle_label)
	muted_label_nodes.append(subtitle_label)

	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(split)

	var left_column := VBoxContainer.new()
	left_column.custom_minimum_size = Vector2(560, 0)
	left_column.add_theme_constant_override("separation", 12)
	split.add_child(left_column)

	var right_column := VBoxContainer.new()
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_column.add_theme_constant_override("separation", 12)
	split.add_child(right_column)

	var summary_panel := _make_panel(false)
	left_column.add_child(summary_panel)
	var summary_box := _make_panel_content(summary_panel)

	mill_label = _make_value_label(20)
	summary_box.add_child(mill_label)

	resource_label = _make_value_label(28)
	summary_box.add_child(resource_label)

	harmony_label = _make_value_label(18)
	summary_box.add_child(harmony_label)

	production_label = _make_body_label()
	summary_box.add_child(production_label)

	stage_label = _make_value_label(20)
	summary_box.add_child(stage_label)

	stage_bar = ProgressBar.new()
	stage_bar.min_value = 0.0
	stage_bar.max_value = 1.0
	stage_bar.show_percentage = false
	stage_bar.custom_minimum_size = Vector2(0, 24)
	summary_box.add_child(stage_bar)

	stage_progress_label = _make_body_label()
	summary_box.add_child(stage_progress_label)

	click_button = Button.new()
	click_button.custom_minimum_size = Vector2(0, 180)
	click_button.pressed.connect(_on_click_button_pressed)
	summary_box.add_child(click_button)
	button_nodes.append(click_button)

	click_hint_label = _make_body_label()
	summary_box.add_child(click_hint_label)

	var theme_panel := _make_panel(true)
	left_column.add_child(theme_panel)
	var theme_box := _make_panel_content(theme_panel)

	var theme_title := _make_section_title("Theme Packs")
	theme_box.add_child(theme_title)

	theme_option_button = OptionButton.new()
	theme_option_button.item_selected.connect(_on_theme_selected)
	theme_box.add_child(theme_option_button)
	button_nodes.append(theme_option_button)

	var theme_hint := _make_body_label("Prototype hook for future local packs and Steam Workshop support.")
	theme_box.add_child(theme_hint)
	muted_label_nodes.append(theme_hint)

	var prestige_panel := _make_panel(false)
	left_column.add_child(prestige_panel)
	var prestige_box := _make_panel_content(prestige_panel)

	var prestige_title := _make_section_title("Spin Into Harmony")
	prestige_box.add_child(prestige_title)

	prestige_info_label = _make_body_label()
	prestige_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prestige_box.add_child(prestige_info_label)

	prestige_button = Button.new()
	prestige_button.text = "Prestige"
	prestige_button.pressed.connect(_on_prestige_button_pressed)
	prestige_box.add_child(prestige_button)
	button_nodes.append(prestige_button)

	status_label = _make_body_label()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prestige_box.add_child(status_label)
	muted_label_nodes.append(status_label)

	var upgrades_panel := _make_panel(false)
	right_column.add_child(upgrades_panel)
	var upgrades_box := _make_panel_content(upgrades_panel)

	var upgrades_title := _make_section_title("Upgrades")
	upgrades_box.add_child(upgrades_title)

	upgrade_container = VBoxContainer.new()
	upgrade_container.add_theme_constant_override("separation", 8)
	upgrades_box.add_child(upgrade_container)

	var harmony_panel := _make_panel(true)
	right_column.add_child(harmony_panel)
	var harmony_box := _make_panel_content(harmony_panel)

	var harmony_title := _make_section_title("Harmony Tree")
	harmony_box.add_child(harmony_title)

	harmony_tree_container = VBoxContainer.new()
	harmony_tree_container.add_theme_constant_override("separation", 8)
	harmony_box.add_child(harmony_tree_container)

	var music_panel := _make_panel(false)
	right_column.add_child(music_panel)
	var music_box := _make_panel_content(music_panel)

	var music_title := _make_section_title("Music Mix")
	music_box.add_child(music_title)

	music_toggle = CheckBox.new()
	music_toggle.text = "Music Enabled"
	music_toggle.button_pressed = true
	music_toggle.toggled.connect(_on_music_toggled)
	music_box.add_child(music_toggle)
	button_nodes.append(music_toggle)

	for lane in AudioConductor.LANE_ORDER:
		var lane_row := VBoxContainer.new()
		lane_row.add_theme_constant_override("separation", 4)
		music_box.add_child(lane_row)

		var lane_label := _make_body_label(_lane_label(lane))
		lane_row.add_child(lane_label)

		var lane_bar := ProgressBar.new()
		lane_bar.min_value = 0
		lane_bar.max_value = 3
		lane_bar.show_percentage = false
		lane_row.add_child(lane_bar)

		var lane_slider := HSlider.new()
		lane_slider.min_value = 0.0
		lane_slider.max_value = 1.0
		lane_slider.step = 0.01
		lane_slider.value = 0.8
		lane_slider.value_changed.connect(_on_lane_volume_changed.bind(lane))
		lane_row.add_child(lane_slider)

		lane_bar_map[lane] = lane_bar
		lane_slider_map[lane] = lane_slider

	_refresh_theme_options()
	_rebuild_upgrade_list()
	_rebuild_harmony_tree()


func _refresh_everything() -> void:
	_refresh_theme()
	_refresh_runtime_labels()
	_refresh_music_meter()
	_rebuild_upgrade_list()
	_rebuild_harmony_tree()


func _refresh_runtime_labels() -> void:
	var mill_state := game_state.get_mill_state(current_mill_id)
	var resource_name := game_state.get_resource_display_name(current_mill_id)
	var click_power := game_state.get_click_power(current_mill_id)
	var auto_rate := game_state.get_auto_production_per_second(current_mill_id)
	var current_stage := game_state.get_current_stage(current_mill_id)

	title_label.text = "Melody Mill"
	subtitle_label.text = "Cat Mill vertical slice with prestige, a Harmony Tree, and theme-pack hooks."
	mill_label.text = "%s  |  Prestige Count: %s" % [game_state.get_mill_display_name(current_mill_id), int(mill_state.get("prestige_count", 0))]
	resource_label.text = "%s: %s" % [resource_name, game_state.format_number(float(mill_state.get("resource", 0.0)))]
	harmony_label.text = "Harmony Points: %s" % game_state.get_harmony_points()
	production_label.text = "Click Power: %s    Auto / Sec: %s    Run Total: %s" % [
		game_state.format_number(click_power),
		game_state.format_number(auto_rate),
		game_state.format_number(float(mill_state.get("run_resource", 0.0)))
	]
	stage_label.text = "Current Yarn Stage: %s" % String(current_stage.get("name", "Unknown Stage"))
	stage_bar.value = game_state.get_stage_progress_ratio(current_mill_id)
	stage_progress_label.text = "Progress to next stage: %s / %s" % [
		game_state.format_number(float(mill_state.get("stage_progress", 0.0))),
		game_state.format_number(game_state.get_current_stage_goal(current_mill_id))
	]
	click_button.text = "%s\n+%s %s" % [
		game_state.get_click_action_name(current_mill_id),
		game_state.format_number(click_power),
		resource_name
	]
	click_hint_label.text = "Clicking matters early, while upgrades turn the mill into a song."

	var prestige_reward := game_state.get_prestige_reward(current_mill_id)
	if game_state.can_prestige(current_mill_id):
		prestige_info_label.text = "%s is ready. Reset this run and gain %s Harmony Point(s)." % [
			game_state.get_prestige_action_name(current_mill_id),
			prestige_reward
		]
	else:
		prestige_info_label.text = "Reach the final yarn stage to unlock %s. Current reward preview: %s Harmony." % [
			game_state.get_prestige_action_name(current_mill_id),
			prestige_reward
		]
	prestige_button.text = game_state.get_prestige_action_name(current_mill_id)
	prestige_button.disabled = not game_state.can_prestige(current_mill_id)
	status_label.text = status_message


func _refresh_theme() -> void:
	_prune_themed_references()
	var theme := game_state.get_active_theme_pack(current_mill_id)
	current_theme_id = String(theme.get("id", ""))
	var palette: Dictionary = theme.get("palette", {})

	background_rect.color = Color(palette.get("background", "#f5f1e8"))
	for panel in panel_nodes:
		panel.add_theme_stylebox_override("panel", _style_box(Color(palette.get("panel", "#fffaf0"))))
	for panel in alt_panel_nodes:
		panel.add_theme_stylebox_override("panel", _style_box(Color(palette.get("panel_alt", "#f0e6cd"))))
	for button in button_nodes:
		if button is Button:
			var style := _style_box(Color(palette.get("button", "#ffd27a")))
			button.add_theme_stylebox_override("normal", style)
			button.add_theme_stylebox_override("hover", _style_box(Color(palette.get("accent", "#f59f4c")).lightened(0.1)))
			button.add_theme_stylebox_override("pressed", _style_box(Color(palette.get("accent", "#f59f4c")).darkened(0.15)))
			button.add_theme_color_override("font_color", Color(palette.get("button_text", "#2b2420")))

	for label in label_nodes:
		label.add_theme_color_override("font_color", Color(palette.get("text", "#2b2420")))
	for label in muted_label_nodes:
		label.add_theme_color_override("font_color", Color(palette.get("muted_text", "#645751")))

	for lane in lane_bar_map.keys():
		var bar: ProgressBar = lane_bar_map[lane]
		bar.add_theme_stylebox_override("fill", _style_box(Color(palette.get("accent", "#f59f4c"))))
		bar.add_theme_stylebox_override("background", _style_box(Color(palette.get("panel_alt", "#f0e6cd")).darkened(0.05)))


func _refresh_theme_options() -> void:
	theme_option_button.clear()
	var available := game_state.get_available_theme_packs(current_mill_id)
	for index in available.size():
		var theme: Dictionary = available[index]
		theme_option_button.add_item(String(theme.get("name", theme["id"])))
		theme_option_button.set_item_metadata(index, theme["id"])
		if String(theme["id"]) == current_theme_id:
			theme_option_button.select(index)


func _rebuild_upgrade_list() -> void:
	for child in upgrade_container.get_children():
		child.queue_free()

	for upgrade in game_state.get_mill_definition(current_mill_id).get("upgrades", []):
		var upgrade_panel := _make_panel(true)
		upgrade_container.add_child(upgrade_panel)
		var row := _make_panel_content(upgrade_panel)

		var owned := game_state.get_upgrade_count(current_mill_id, String(upgrade["id"]))
		var cost := game_state.get_upgrade_cost(current_mill_id, String(upgrade["id"]))

		var name_label := _make_value_label(18)
		name_label.text = "%s  |  Owned: %s" % [game_state.get_upgrade_display_name(current_mill_id, String(upgrade["id"])), owned]
		row.add_child(name_label)

		var desc_label := _make_body_label(String(upgrade.get("description", "")))
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(desc_label)
		muted_label_nodes.append(desc_label)

		var buy_button := Button.new()
		buy_button.text = "Buy for %s %s" % [game_state.format_number(cost), game_state.get_resource_display_name(current_mill_id)]
		buy_button.disabled = not game_state.can_purchase_upgrade(current_mill_id, String(upgrade["id"]))
		buy_button.pressed.connect(_on_upgrade_pressed.bind(String(upgrade["id"])))
		row.add_child(buy_button)
		button_nodes.append(buy_button)

	_refresh_theme()


func _rebuild_harmony_tree() -> void:
	for child in harmony_tree_container.get_children():
		child.queue_free()

	for node in game_state.get_harmony_tree_nodes():
		var node_panel := _make_panel(true)
		harmony_tree_container.add_child(node_panel)
		var row := _make_panel_content(node_panel)

		var purchased := game_state.has_tree_node(String(node["id"]))

		var title := _make_value_label(18)
		title.text = "[%s] %s  |  Cost: %s" % [String(node.get("branch", "")), String(node.get("name", "")), int(node.get("cost", 0))]
		row.add_child(title)

		var description := _make_body_label(String(node.get("description", "")))
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(description)
		muted_label_nodes.append(description)

		var buy_button := Button.new()
		buy_button.text = "Purchased" if purchased else "Spend Harmony"
		buy_button.disabled = purchased or not game_state.can_buy_tree_node(String(node["id"]))
		buy_button.pressed.connect(_on_harmony_node_pressed.bind(String(node["id"])))
		row.add_child(buy_button)
		button_nodes.append(buy_button)

	_refresh_theme()


func _refresh_music_meter() -> void:
	var lane_intensities := game_state.get_lane_intensities(current_mill_id)
	conductor.set_lane_intensities(lane_intensities)
	for lane in lane_bar_map.keys():
		var bar: ProgressBar = lane_bar_map[lane]
		bar.value = int(lane_intensities.get(lane, 0))


func _on_click_button_pressed() -> void:
	var result := game_state.earn_resource(current_mill_id, game_state.get_click_power(current_mill_id))
	conductor.play_click()
	if not result["stages"].is_empty():
		status_message = "You farmed through the yarn and spawned %s." % String(result["stages"][-1])
	_rebuild_upgrade_list()
	_refresh_runtime_labels()
	_refresh_music_meter()


func _on_upgrade_pressed(upgrade_id: String) -> void:
	if game_state.purchase_upgrade(current_mill_id, upgrade_id):
		status_message = "%s joined the mill." % game_state.get_upgrade_display_name(current_mill_id, upgrade_id)
	_rebuild_upgrade_list()
	_refresh_runtime_labels()
	_refresh_music_meter()


func _on_harmony_node_pressed(node_id: String) -> void:
	if game_state.buy_tree_node(node_id):
		status_message = "Unlocked %s." % game_state.get_tree_node(node_id).get("name", node_id)
	_rebuild_harmony_tree()
	_refresh_runtime_labels()
	_refresh_music_meter()


func _on_prestige_button_pressed() -> void:
	var reward := game_state.prestige_mill(current_mill_id)
	if reward > 0:
		status_message = "You spun the yarn into Harmony and gained %s point(s)." % reward
	_rebuild_upgrade_list()
	_rebuild_harmony_tree()
	_refresh_runtime_labels()
	_refresh_music_meter()


func _on_theme_selected(index: int) -> void:
	var theme_id = String(theme_option_button.get_item_metadata(index))
	game_state.set_active_theme_pack(current_mill_id, theme_id)
	current_theme_id = theme_id
	status_message = "Applied Theme Pack: %s." % theme_option_button.get_item_text(index)
	_rebuild_upgrade_list()
	_rebuild_harmony_tree()
	_refresh_everything()


func _on_music_toggled(toggled_on: bool) -> void:
	conductor.set_enabled(toggled_on)
	status_message = "Music %s." % ("enabled" if toggled_on else "muted")
	_refresh_runtime_labels()


func _on_lane_volume_changed(value: float, lane: String) -> void:
	conductor.set_lane_volume(lane, value)


func _on_autosave_timeout() -> void:
	game_state.flush_if_dirty()


func _make_panel(is_alt: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := _style_box(Color("#ffffff"))
	panel.add_theme_stylebox_override("panel", style)
	if is_alt:
		alt_panel_nodes.append(panel)
	else:
		panel_nodes.append(panel)
	return panel


func _make_panel_content(panel: PanelContainer) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	panel.add_theme_constant_override("margin_left", 16)
	panel.add_theme_constant_override("margin_right", 16)
	panel.add_theme_constant_override("margin_top", 16)
	panel.add_theme_constant_override("margin_bottom", 16)
	return box


func _make_section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	label_nodes.append(label)
	return label


func _make_value_label(font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label_nodes.append(label)
	return label


func _make_body_label(text: String = "") -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label_nodes.append(label)
	return label


func _style_box(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style


func _prune_themed_references() -> void:
	panel_nodes = panel_nodes.filter(func(node): return is_instance_valid(node))
	alt_panel_nodes = alt_panel_nodes.filter(func(node): return is_instance_valid(node))
	button_nodes = button_nodes.filter(func(node): return is_instance_valid(node))
	label_nodes = label_nodes.filter(func(node): return is_instance_valid(node))
	muted_label_nodes = muted_label_nodes.filter(func(node): return is_instance_valid(node))


func _lane_label(lane: String) -> String:
	match lane:
		"percussion":
			return "Pulse / Percussion"
		"melody":
			return "Melody"
		"bass":
			return "Bass"
		_:
			return "Harmony / Texture"
