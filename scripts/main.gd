extends Control

const GameStateScript = preload("res://scripts/game_state.gd")
const AudioConductorScript = preload("res://scripts/audio_conductor.gd")


class ToyboxMillScene:
	extends Control

	signal yarn_pressed

	var palette: Dictionary = {}
	var stage_name = "Small Yarn Ball"
	var stage_index = 0
	var stage_ratio = 0.0
	var resource_name = "Yarn"
	var click_action_name = "Bat the Yarn"
	var click_power = 1.0
	var auto_rate = 0.0
	var lane_intensities: Dictionary = {}
	var owned_upgrades: Dictionary = {}
	var pulse = 0.0
	var yarn_bump = 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _process(delta: float) -> void:
		pulse += delta
		yarn_bump = max(0.0, yarn_bump - delta * 4.0)
		queue_redraw()

	func set_scene_data(data: Dictionary) -> void:
		palette = data.get("palette", {})
		stage_name = String(data.get("stage_name", stage_name))
		stage_index = int(data.get("stage_index", 0))
		stage_ratio = float(data.get("stage_ratio", 0.0))
		resource_name = String(data.get("resource_name", resource_name))
		click_action_name = String(data.get("click_action_name", click_action_name))
		click_power = float(data.get("click_power", 1.0))
		auto_rate = float(data.get("auto_rate", 0.0))
		lane_intensities = data.get("lane_intensities", {})
		owned_upgrades = data.get("owned_upgrades", {})
		queue_redraw()

	func trigger_yarn_bop() -> void:
		yarn_bump = 1.0
		queue_redraw()

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _is_in_yarn(event.position):
				trigger_yarn_bop()
				yarn_pressed.emit()

	func _draw() -> void:
		var bg = Color(palette.get("background", "#f8f3e6"))
		var panel = Color(palette.get("panel", "#fffaf0"))
		var panel_alt = Color(palette.get("panel_alt", "#f6e8c8"))
		var accent = Color(palette.get("accent", "#f59f4c"))
		var button = Color(palette.get("button", "#ffd27a"))
		var text = Color(palette.get("text", "#3a2c28"))
		var muted = Color(palette.get("muted_text", "#6f5a52"))
		var rect = Rect2(Vector2.ZERO, size)

		draw_rect(rect, bg)
		_draw_wallpaper(bg, panel_alt)
		_draw_floor(panel_alt, panel)
		_draw_shelves(panel, muted)
		_draw_music_staff(accent, muted)
		_draw_cats(text, accent, button)
		_draw_yarn(accent, button, text)
		_draw_lane_lights(accent, panel, muted)
		_draw_scene_labels(text, muted)

	func _draw_wallpaper(bg: Color, stripe: Color) -> void:
		var stripe_color = stripe.lightened(0.08)
		stripe_color.a = 0.34
		for x in range(-80, int(size.x) + 120, 96):
			draw_line(Vector2(x, 0), Vector2(x + 160, size.y * 0.62), stripe_color, 8.0)

	func _draw_floor(floor_color: Color, rug_color: Color) -> void:
		var floor_y = size.y * 0.68
		draw_rect(Rect2(0, floor_y, size.x, size.y - floor_y), floor_color.darkened(0.06))
		var rug_rect = Rect2(size.x * 0.12, floor_y + 36, size.x * 0.76, max(90.0, size.y * 0.18))
		draw_rounded_rect(rug_rect, rug_color.lightened(0.05), 34.0)
		draw_arc(rug_rect.get_center(), Vector2(rug_rect.size.x * 0.42, rug_rect.size.y * 0.42).length() * 0.16, 0.0, TAU, 96, floor_color.darkened(0.13), 3.0)

	func _draw_shelves(panel: Color, muted: Color) -> void:
		var y = size.y * 0.18
		for i in 3:
			var shelf_rect = Rect2(size.x * (0.12 + i * 0.24), y + i * 10, size.x * 0.14, 12)
			draw_rounded_rect(shelf_rect, muted.darkened(0.05), 5.0)
			draw_circle(shelf_rect.position + Vector2(24, -12), 12, panel.darkened(0.05))
			draw_circle(shelf_rect.position + Vector2(56, -16), 9, panel.lightened(0.05))
			draw_rect(Rect2(shelf_rect.position + Vector2(86, -28), Vector2(18, 28)), panel.darkened(0.12))

	func _draw_music_staff(accent: Color, muted: Color) -> void:
		var base_y = size.y * 0.32
		var color = muted
		color.a = 0.18
		for i in 5:
			draw_line(Vector2(size.x * 0.08, base_y + i * 14), Vector2(size.x * 0.92, base_y + i * 14), color, 2.0)
		var note_color = accent
		note_color.a = 0.45
		var active = _total_lane_intensity()
		for i in active:
			var x = size.x * (0.18 + (i % 8) * 0.09)
			var y = base_y + 7 + (i % 4) * 14
			draw_circle(Vector2(x, y), 7.0 + sin(pulse * 4.0 + i) * 1.2, note_color)
			draw_line(Vector2(x + 6, y), Vector2(x + 6, y - 32), note_color, 3.0)

	func _draw_cats(text: Color, accent: Color, button: Color) -> void:
		var cat_count = clamp(_owned_total(), 0, 9)
		var floor_y = size.y * 0.70
		for i in cat_count:
			var x = size.x * (0.19 + (i % 5) * 0.15)
			var y = floor_y + 34 + int(i / 5) * 48 + sin(pulse * 2.0 + i) * 4.0
			var body = button.lightened(0.08) if i % 2 == 0 else accent.lightened(0.18)
			_draw_cat(Vector2(x, y), 0.72 + (i % 3) * 0.08, body, text)

	func _draw_cat(center: Vector2, scale: float, body: Color, ink: Color) -> void:
		var s = 34.0 * scale
		draw_circle(center + Vector2(0, 8 * scale), s * 0.54, body)
		draw_circle(center + Vector2(0, -16 * scale), s * 0.42, body)
		var left_ear = PackedVector2Array([
			center + Vector2(-18, -36) * scale,
			center + Vector2(-5, -23) * scale,
			center + Vector2(-24, -18) * scale
		])
		var right_ear = PackedVector2Array([
			center + Vector2(18, -36) * scale,
			center + Vector2(5, -23) * scale,
			center + Vector2(24, -18) * scale
		])
		draw_colored_polygon(left_ear, body.darkened(0.03))
		draw_colored_polygon(right_ear, body.darkened(0.03))
		draw_circle(center + Vector2(-10, -18) * scale, 2.8 * scale, ink)
		draw_circle(center + Vector2(10, -18) * scale, 2.8 * scale, ink)
		draw_arc(center + Vector2(0, -8) * scale, 7.0 * scale, 0.2, PI - 0.2, 16, ink, 1.8 * scale)
		draw_arc(center + Vector2(24, 10) * scale, 22.0 * scale, -1.5, 0.45, 18, body.darkened(0.06), 6.0 * scale)

	func _draw_yarn(accent: Color, button: Color, ink: Color) -> void:
		var center = _yarn_center()
		var radius = _yarn_radius()
		var growth = 1.0 + stage_index * 0.12 + yarn_bump * 0.08
		var r = radius * growth
		var yarn = button.lerp(accent, 0.30)
		draw_circle(center + Vector2(0, r * 0.12), r * 1.05, Color(0, 0, 0, 0.08))
		draw_circle(center, r, yarn)
		draw_circle(center + Vector2(-r * 0.25, -r * 0.22), r * 0.22, yarn.lightened(0.12))
		for i in 10:
			var phase = pulse * 0.6 + i * 0.55
			var a = phase
			var b = phase + PI * 1.15
			var color = yarn.darkened(0.16 + (i % 3) * 0.03)
			color.a = 0.62
			draw_arc(center, r * (0.28 + i * 0.055), a, b, 36, color, 3.0)
		var highlight = Color.WHITE
		highlight.a = 0.22
		draw_circle(center + Vector2(-r * 0.28, -r * 0.32), r * 0.16, highlight)
		var ring = accent.lightened(0.2)
		ring.a = 0.22 + stage_ratio * 0.22
		draw_arc(center, r + 18.0, -PI / 2.0, -PI / 2.0 + TAU * stage_ratio, 80, ring, 8.0)

	func _draw_lane_lights(accent: Color, panel: Color, muted: Color) -> void:
		var labels = ["Pulse", "Melody", "Bass", "Texture"]
		var lanes = ["percussion", "melody", "bass", "texture"]
		var start = Vector2(size.x * 0.08, size.y * 0.88)
		var spacing = size.x * 0.21
		for i in lanes.size():
			var lane = lanes[i]
			var intensity = int(lane_intensities.get(lane, 0))
			var x = start.x + i * spacing
			draw_string(get_theme_default_font(), Vector2(x, start.y - 22), labels[i], HORIZONTAL_ALIGNMENT_LEFT, 120, 14, muted)
			for pip in 3:
				var color = accent if pip < intensity else panel.darkened(0.12)
				if pip < intensity:
					color = color.lightened(0.08 + sin(pulse * 5.0 + pip + i) * 0.04)
				draw_circle(Vector2(x + pip * 24, start.y), 8, color)

	func _draw_scene_labels(text: Color, muted: Color) -> void:
		var font = get_theme_default_font()
		draw_string(font, Vector2(30, 42), stage_name, HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.6, 24, text)
		draw_string(font, Vector2(30, 70), "%s for +%0.1f %s" % [click_action_name, click_power, resource_name], HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.8, 15, muted)
		var auto_text = "Cats are humming at %0.1f / sec" % auto_rate
		draw_string(font, Vector2(30, 94), auto_text, HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.8, 15, muted)

	func _is_in_yarn(position: Vector2) -> bool:
		return position.distance_to(_yarn_center()) <= _yarn_radius() * (1.0 + stage_index * 0.12 + 0.16)

	func _yarn_center() -> Vector2:
		return Vector2(size.x * 0.52, size.y * 0.50)

	func _yarn_radius() -> float:
		return min(size.x, size.y) * 0.17

	func _owned_total() -> int:
		var total = 0
		for value in owned_upgrades.values():
			total += int(value)
		return total

	func _total_lane_intensity() -> int:
		var total = 0
		for value in lane_intensities.values():
			total += int(value)
		return total

	func draw_rounded_rect(rect: Rect2, color: Color, radius: float) -> void:
		draw_rect(rect.grow(-radius), color)
		draw_rect(Rect2(rect.position + Vector2(radius, 0), Vector2(rect.size.x - radius * 2.0, rect.size.y)), color)
		draw_rect(Rect2(rect.position + Vector2(0, radius), Vector2(rect.size.x, rect.size.y - radius * 2.0)), color)
		draw_circle(rect.position + Vector2(radius, radius), radius, color)
		draw_circle(rect.position + Vector2(rect.size.x - radius, radius), radius, color)
		draw_circle(rect.position + Vector2(radius, rect.size.y - radius), radius, color)
		draw_circle(rect.position + Vector2(rect.size.x - radius, rect.size.y - radius), radius, color)


var game_state
var conductor
var current_mill_id = "cat_mill"
var current_theme_id = ""
var status_message = "Tap the yarn to wake up the first little melody."
var ui_refresh_accumulator = 0.0
var upgrade_refresh_accumulator = 0.0

var background_rect: ColorRect
var title_label: Label
var subtitle_label: Label
var resource_label: Label
var harmony_label: Label
var production_label: Label
var stage_label: Label
var stage_bar: ProgressBar
var status_label: Label
var click_button: Button
var prestige_button: Button
var theme_option_button: OptionButton
var upgrade_container: VBoxContainer
var music_toggle: CheckBox
var scene_view: ToyboxMillScene
var lane_bar_map = {}
var lane_slider_map = {}
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

	var autosave_timer = Timer.new()
	autosave_timer.wait_time = 5.0
	autosave_timer.autostart = true
	autosave_timer.timeout.connect(_on_autosave_timeout)
	add_child(autosave_timer)


func _process(delta: float) -> void:
	var auto_gain = game_state.get_auto_production_per_second(current_mill_id) * delta
	if auto_gain > 0.0:
		var result = game_state.earn_resource(current_mill_id, auto_gain)
		if not result["stages"].is_empty():
			status_message = "The yarn grew into %s." % String(result["stages"][-1])

	ui_refresh_accumulator += delta
	upgrade_refresh_accumulator += delta
	if ui_refresh_accumulator >= 0.1:
		ui_refresh_accumulator = 0.0
		_refresh_runtime_labels()
		_refresh_music_meter()
		_refresh_scene_view()
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

	var margin = MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var root = VBoxContainer.new()
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	root.add_child(_build_top_bar())

	var main_split = HSplitContainer.new()
	main_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_split.split_offset = 1040
	root.add_child(main_split)

	var left_column = VBoxContainer.new()
	left_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.add_theme_constant_override("separation", 10)
	main_split.add_child(left_column)

	var scene_panel = _make_panel(false)
	scene_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_column.add_child(scene_panel)
	scene_view = ToyboxMillScene.new()
	scene_view.custom_minimum_size = Vector2(720, 500)
	scene_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene_view.yarn_pressed.connect(_on_click_button_pressed)
	scene_panel.add_child(scene_view)

	left_column.add_child(_build_bottom_bar())

	var shop_panel = _make_panel(false)
	shop_panel.custom_minimum_size = Vector2(420, 0)
	shop_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_split.add_child(shop_panel)
	var shop_box = _make_panel_content(shop_panel)
	shop_box.add_child(_make_section_title("Toy Shelf"))

	var shop_hint = _make_body_label("Buy cats and cozy contraptions to make the mill busier and the song fuller.")
	shop_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shop_box.add_child(shop_hint)
	muted_label_nodes.append(shop_hint)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_box.add_child(scroll)
	upgrade_container = VBoxContainer.new()
	upgrade_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_container.add_theme_constant_override("separation", 8)
	scroll.add_child(upgrade_container)

	_refresh_theme_options()
	_rebuild_upgrade_list()


func _build_top_bar() -> Control:
	var top = HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)

	var title_box = VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title_box)

	title_label = Label.new()
	title_label.text = "Melody Mill"
	title_label.add_theme_font_size_override("font_size", 32)
	title_box.add_child(title_label)
	label_nodes.append(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = "Cat Mill"
	subtitle_label.add_theme_font_size_override("font_size", 14)
	title_box.add_child(subtitle_label)
	muted_label_nodes.append(subtitle_label)

	resource_label = _make_stat_pill("")
	top.add_child(resource_label)
	harmony_label = _make_stat_pill("")
	top.add_child(harmony_label)

	theme_option_button = OptionButton.new()
	theme_option_button.custom_minimum_size = Vector2(190, 42)
	theme_option_button.item_selected.connect(_on_theme_selected)
	top.add_child(theme_option_button)
	button_nodes.append(theme_option_button)

	return top


func _build_bottom_bar() -> Control:
	var bottom = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 10)

	var progress_panel = _make_panel(true)
	progress_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(progress_panel)
	var progress_box = _make_panel_content(progress_panel)

	stage_label = _make_value_label(18)
	progress_box.add_child(stage_label)

	stage_bar = ProgressBar.new()
	stage_bar.min_value = 0.0
	stage_bar.max_value = 1.0
	stage_bar.show_percentage = false
	stage_bar.custom_minimum_size = Vector2(0, 18)
	progress_box.add_child(stage_bar)

	production_label = _make_body_label()
	progress_box.add_child(production_label)

	status_label = _make_body_label()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	progress_box.add_child(status_label)
	muted_label_nodes.append(status_label)

	var controls_panel = _make_panel(false)
	controls_panel.custom_minimum_size = Vector2(360, 0)
	bottom.add_child(controls_panel)
	var controls_box = _make_panel_content(controls_panel)

	var button_row = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	controls_box.add_child(button_row)

	click_button = Button.new()
	click_button.text = "Bat Yarn"
	click_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	click_button.pressed.connect(_on_click_button_pressed)
	button_row.add_child(click_button)
	button_nodes.append(click_button)

	prestige_button = Button.new()
	prestige_button.text = "Spin"
	prestige_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prestige_button.pressed.connect(_on_prestige_button_pressed)
	button_row.add_child(prestige_button)
	button_nodes.append(prestige_button)

	music_toggle = CheckBox.new()
	music_toggle.text = "Music"
	music_toggle.button_pressed = true
	music_toggle.toggled.connect(_on_music_toggled)
	controls_box.add_child(music_toggle)
	button_nodes.append(music_toggle)

	for lane in AudioConductorScript.LANE_ORDER:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		controls_box.add_child(row)

		var lane_label = _make_body_label(_lane_label(lane))
		lane_label.custom_minimum_size = Vector2(82, 0)
		row.add_child(lane_label)

		var lane_bar = ProgressBar.new()
		lane_bar.min_value = 0
		lane_bar.max_value = 3
		lane_bar.show_percentage = false
		lane_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lane_bar)

		var lane_slider = HSlider.new()
		lane_slider.min_value = 0.0
		lane_slider.max_value = 1.0
		lane_slider.step = 0.01
		lane_slider.value = 0.8
		lane_slider.custom_minimum_size = Vector2(82, 0)
		lane_slider.value_changed.connect(_on_lane_volume_changed.bind(lane))
		row.add_child(lane_slider)

		lane_bar_map[lane] = lane_bar
		lane_slider_map[lane] = lane_slider

	return bottom


func _refresh_everything() -> void:
	_refresh_theme()
	_refresh_runtime_labels()
	_refresh_music_meter()
	_refresh_scene_view()
	_rebuild_upgrade_list()


func _refresh_runtime_labels() -> void:
	var mill_state = game_state.get_mill_state(current_mill_id)
	var resource_name = game_state.get_resource_display_name(current_mill_id)
	var click_power = game_state.get_click_power(current_mill_id)
	var auto_rate = game_state.get_auto_production_per_second(current_mill_id)
	var current_stage = game_state.get_current_stage(current_mill_id)

	title_label.text = game_state.get_mill_display_name(current_mill_id)
	subtitle_label.text = "Cozy toybox island - build a tiny cat orchestra around the yarn."
	resource_label.text = "%s  %s" % [resource_name, game_state.format_number(float(mill_state.get("resource", 0.0)))]
	harmony_label.text = "Harmony  %s" % game_state.get_harmony_points()
	stage_label.text = String(current_stage.get("name", "Unknown Stage"))
	stage_bar.value = game_state.get_stage_progress_ratio(current_mill_id)
	production_label.text = "Tap +%s    Auto %s/sec    Run %s" % [
		game_state.format_number(click_power),
		game_state.format_number(auto_rate),
		game_state.format_number(float(mill_state.get("run_resource", 0.0)))
	]
	click_button.text = game_state.get_click_action_name(current_mill_id)

	var prestige_reward = game_state.get_prestige_reward(current_mill_id)
	if game_state.can_prestige(current_mill_id):
		prestige_button.disabled = false
		prestige_button.text = "%s +%s" % [game_state.get_prestige_action_name(current_mill_id), prestige_reward]
	else:
		prestige_button.disabled = true
		prestige_button.text = "Spin Later"
	status_label.text = status_message


func _refresh_scene_view() -> void:
	if scene_view == null:
		return
	var mill_state = game_state.get_mill_state(current_mill_id)
	var current_stage = game_state.get_current_stage(current_mill_id)
	scene_view.set_scene_data({
		"palette": game_state.get_active_theme_pack(current_mill_id).get("palette", {}),
		"stage_name": String(current_stage.get("name", "Small Yarn Ball")),
		"stage_index": int(mill_state.get("stage_index", 0)),
		"stage_ratio": game_state.get_stage_progress_ratio(current_mill_id),
		"resource_name": game_state.get_resource_display_name(current_mill_id),
		"click_action_name": game_state.get_click_action_name(current_mill_id),
		"click_power": game_state.get_click_power(current_mill_id),
		"auto_rate": game_state.get_auto_production_per_second(current_mill_id),
		"lane_intensities": game_state.get_lane_intensities(current_mill_id),
		"owned_upgrades": mill_state.get("upgrades", {})
	})


func _refresh_theme() -> void:
	_prune_themed_references()
	var theme = game_state.get_active_theme_pack(current_mill_id)
	current_theme_id = String(theme.get("id", ""))
	var palette: Dictionary = theme.get("palette", {})
	var bg = Color(palette.get("background", "#f8f3e6"))
	var panel = Color(palette.get("panel", "#fffaf0"))
	var panel_alt = Color(palette.get("panel_alt", "#f6e8c8"))
	var accent = Color(palette.get("accent", "#f59f4c"))
	var button = Color(palette.get("button", "#ffd27a"))
	var button_text = Color(palette.get("button_text", "#3a2c28"))
	var text = Color(palette.get("text", "#3a2c28"))
	var muted = Color(palette.get("muted_text", "#6f5a52"))

	background_rect.color = bg
	for panel_node in panel_nodes:
		panel_node.add_theme_stylebox_override("panel", _style_box(panel))
	for panel_node in alt_panel_nodes:
		panel_node.add_theme_stylebox_override("panel", _style_box(panel_alt))
	for button_node in button_nodes:
		if button_node is Button:
			if button_node is CheckBox:
				button_node.add_theme_stylebox_override("normal", _style_box(panel))
				button_node.add_theme_stylebox_override("hover", _style_box(panel.lightened(0.04)))
				button_node.add_theme_stylebox_override("pressed", _style_box(panel_alt))
				button_node.add_theme_color_override("font_color", text)
				continue
			button_node.add_theme_stylebox_override("normal", _style_box(button))
			button_node.add_theme_stylebox_override("hover", _style_box(button.lightened(0.08)))
			button_node.add_theme_stylebox_override("pressed", _style_box(accent.darkened(0.08)))
			button_node.add_theme_stylebox_override("disabled", _style_box(panel_alt.darkened(0.08)))
			button_node.add_theme_color_override("font_color", button_text)
			button_node.add_theme_color_override("font_disabled_color", muted)
	for label in label_nodes:
		label.add_theme_color_override("font_color", text)
	for label in muted_label_nodes:
		label.add_theme_color_override("font_color", muted)
	for lane in lane_bar_map.keys():
		var bar: ProgressBar = lane_bar_map[lane]
		bar.add_theme_stylebox_override("fill", _style_box(accent))
		bar.add_theme_stylebox_override("background", _style_box(panel_alt.darkened(0.08)))


func _refresh_theme_options() -> void:
	theme_option_button.clear()
	var available = game_state.get_available_theme_packs(current_mill_id)
	for index in available.size():
		var theme: Dictionary = available[index]
		theme_option_button.add_item(String(theme.get("name", theme["id"])))
		theme_option_button.set_item_metadata(index, theme["id"])
		if String(theme["id"]) == current_theme_id:
			theme_option_button.select(index)


func _rebuild_upgrade_list() -> void:
	if upgrade_container == null:
		return
	for child in upgrade_container.get_children():
		child.queue_free()

	for upgrade in game_state.get_mill_definition(current_mill_id).get("upgrades", []):
		var upgrade_panel = _make_panel(true)
		upgrade_container.add_child(upgrade_panel)
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		upgrade_panel.add_child(row)
		upgrade_panel.add_theme_constant_override("margin_left", 10)
		upgrade_panel.add_theme_constant_override("margin_right", 10)
		upgrade_panel.add_theme_constant_override("margin_top", 10)
		upgrade_panel.add_theme_constant_override("margin_bottom", 10)

		var icon = ColorRect.new()
		icon.custom_minimum_size = Vector2(42, 42)
		icon.color = _lane_color(String(upgrade.get("lane", "melody")))
		row.add_child(icon)

		var copy = VBoxContainer.new()
		copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		copy.add_theme_constant_override("separation", 2)
		row.add_child(copy)

		var upgrade_id = String(upgrade["id"])
		var owned = game_state.get_upgrade_count(current_mill_id, upgrade_id)
		var cost = game_state.get_upgrade_cost(current_mill_id, upgrade_id)

		var name_label = _make_value_label(16)
		name_label.text = "%s  x%s" % [game_state.get_upgrade_display_name(current_mill_id, upgrade_id), owned]
		copy.add_child(name_label)

		var desc_label = _make_body_label(String(upgrade.get("description", "")))
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		copy.add_child(desc_label)
		muted_label_nodes.append(desc_label)

		var buy_button = Button.new()
		buy_button.text = "Buy\n%s" % game_state.format_number(cost)
		buy_button.custom_minimum_size = Vector2(86, 46)
		buy_button.disabled = not game_state.can_purchase_upgrade(current_mill_id, upgrade_id)
		buy_button.pressed.connect(_on_upgrade_pressed.bind(upgrade_id))
		row.add_child(buy_button)
		button_nodes.append(buy_button)

	_refresh_theme()


func _refresh_music_meter() -> void:
	var lane_intensities = game_state.get_lane_intensities(current_mill_id)
	conductor.set_lane_intensities(lane_intensities)
	for lane in lane_bar_map.keys():
		var bar: ProgressBar = lane_bar_map[lane]
		bar.value = int(lane_intensities.get(lane, 0))


func _on_click_button_pressed() -> void:
	var result = game_state.earn_resource(current_mill_id, game_state.get_click_power(current_mill_id))
	conductor.play_click()
	if scene_view != null:
		scene_view.trigger_yarn_bop()
	if not result["stages"].is_empty():
		status_message = "The yarn grew into %s." % String(result["stages"][-1])
	else:
		status_message = _random_click_message()
	_rebuild_upgrade_list()
	_refresh_runtime_labels()
	_refresh_music_meter()
	_refresh_scene_view()


func _on_upgrade_pressed(upgrade_id: String) -> void:
	if game_state.purchase_upgrade(current_mill_id, upgrade_id):
		status_message = "%s hopped onto the toy shelf." % game_state.get_upgrade_display_name(current_mill_id, upgrade_id)
	_rebuild_upgrade_list()
	_refresh_runtime_labels()
	_refresh_music_meter()
	_refresh_scene_view()


func _on_prestige_button_pressed() -> void:
	var reward = game_state.prestige_mill(current_mill_id)
	if reward > 0:
		status_message = "The yarn spun into Harmony and left %s bright point(s)." % reward
	_rebuild_upgrade_list()
	_refresh_runtime_labels()
	_refresh_music_meter()
	_refresh_scene_view()


func _on_theme_selected(index: int) -> void:
	var theme_id = String(theme_option_button.get_item_metadata(index))
	game_state.set_active_theme_pack(current_mill_id, theme_id)
	current_theme_id = theme_id
	status_message = "The toybox changed into %s." % theme_option_button.get_item_text(index)
	_rebuild_upgrade_list()
	_refresh_everything()


func _on_music_toggled(toggled_on: bool) -> void:
	conductor.set_enabled(toggled_on)
	status_message = "Music is %s." % ("back in the room" if toggled_on else "resting")
	_refresh_runtime_labels()


func _on_lane_volume_changed(value: float, lane: String) -> void:
	conductor.set_lane_volume(lane, value)


func _on_autosave_timeout() -> void:
	game_state.flush_if_dirty()


func _make_panel(is_alt: bool) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style_box(Color("#ffffff")))
	if is_alt:
		alt_panel_nodes.append(panel)
	else:
		panel_nodes.append(panel)
	return panel


func _make_panel_content(panel: PanelContainer) -> VBoxContainer:
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	panel.add_theme_constant_override("margin_left", 12)
	panel.add_theme_constant_override("margin_right", 12)
	panel.add_theme_constant_override("margin_top", 12)
	panel.add_theme_constant_override("margin_bottom", 12)
	return box


func _make_section_title(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	label_nodes.append(label)
	return label


func _make_value_label(font_size: int) -> Label:
	var label = Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label_nodes.append(label)
	return label


func _make_body_label(text: String = "") -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	label_nodes.append(label)
	return label


func _make_stat_pill(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(170, 42)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label_nodes.append(label)
	return label


func _style_box(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _lane_color(lane: String) -> Color:
	var palette: Dictionary = game_state.get_active_theme_pack(current_mill_id).get("palette", {})
	var accent = Color(palette.get("accent", "#f59f4c"))
	match lane:
		"percussion":
			return accent.darkened(0.05)
		"melody":
			return accent.lightened(0.16)
		"bass":
			return Color(palette.get("button", "#ffd27a")).darkened(0.12)
		_:
			return Color(palette.get("panel", "#fffaf0")).darkened(0.20)


func _random_click_message() -> String:
	var messages = [
		"The yarn gives a soft little bounce.",
		"A tiny bell note joins the room.",
		"The cats are considering the rhythm.",
		"The toybox hums a little warmer."
	]
	return messages[randi() % messages.size()]


func _prune_themed_references() -> void:
	panel_nodes = panel_nodes.filter(func(node): return is_instance_valid(node))
	alt_panel_nodes = alt_panel_nodes.filter(func(node): return is_instance_valid(node))
	button_nodes = button_nodes.filter(func(node): return is_instance_valid(node))
	label_nodes = label_nodes.filter(func(node): return is_instance_valid(node))
	muted_label_nodes = muted_label_nodes.filter(func(node): return is_instance_valid(node))


func _lane_label(lane: String) -> String:
	match lane:
		"percussion":
			return "Pulse"
		"melody":
			return "Melody"
		"bass":
			return "Bass"
		_:
			return "Texture"
