extends Control

const GameStateScript = preload("res://scripts/game_state.gd")
const AudioConductorScript = preload("res://scripts/audio_conductor.gd")


class UpgradeShelfIcon:
	extends Control

	var palette: Dictionary = {}
	var upgrade_id := ""
	var lane := "melody"
	var icon_path := ""
	var icon_texture: Texture2D

	func set_icon_data(new_palette: Dictionary, new_upgrade_id: String, new_lane: String, new_icon_path: String = "") -> void:
		palette = new_palette
		upgrade_id = new_upgrade_id
		lane = new_lane
		if icon_path != new_icon_path:
			icon_path = new_icon_path
			icon_texture = _load_texture(icon_path)
		queue_redraw()

	func _draw() -> void:
		var panel = Color(palette.get("panel", "#fffaf0"))
		var panel_alt = Color(palette.get("panel_alt", "#f6e8c8"))
		var accent = Color(palette.get("accent", "#f59f4c"))
		var ink = Color(palette.get("text", "#3a2c28"))
		var cat_primary = Color(palette.get("scene_cat_primary", "#ffd67b"))
		var cat_secondary = Color(palette.get("scene_cat_secondary", "#f3a251"))
		var yarn = Color(palette.get("scene_yarn", "#ffc766"))
		var rect = Rect2(Vector2.ZERO, size)
		var badge_rect = Rect2(4, 4, rect.size.x - 8, rect.size.y - 8)
		var medallion_center = rect.get_center() + Vector2(0, 2)
		var medallion_radius = min(rect.size.x, rect.size.y) * 0.33

		draw_rect(rect, panel_alt.lightened(0.02))
		draw_rect(badge_rect, panel.lightened(0.02))
		draw_circle(medallion_center, medallion_radius, panel_alt.lightened(0.08))
		draw_arc(medallion_center, min(rect.size.x, rect.size.y) * 0.43, 0.0, TAU, 28, accent.darkened(0.10), 2.0)
		draw_circle(medallion_center + Vector2(0, medallion_radius * 0.74), medallion_radius * 0.52, Color(0, 0, 0, 0.06))

		if icon_texture != null:
			_draw_loaded_icon(Rect2(8, 8, rect.size.x - 16, rect.size.y - 18))
		else:
			match upgrade_id:
				"kitten":
					_draw_cat_icon(rect.get_center() + Vector2(0, 6), 0.72, cat_primary, ink)
				"house_cat":
					_draw_cat_icon(rect.get_center() + Vector2(0, 8), 0.92, cat_secondary, ink)
				"scratching_post":
					draw_rect(Rect2(rect.get_center() + Vector2(-8, -18), Vector2(16, 38)), cat_secondary.darkened(0.18))
					draw_rect(Rect2(rect.get_center() + Vector2(-14, 18), Vector2(28, 10)), ink.darkened(0.05))
					for i in range(4):
						draw_line(rect.get_center() + Vector2(-6 + i * 4, -14), rect.get_center() + Vector2(-6 + i * 4, 14), panel.lightened(0.04), 1.4)
				"yarn_basket":
					draw_arc(rect.get_center() + Vector2(0, 8), 18.0, PI, TAU, 18, ink, 3.0)
					draw_line(rect.get_center() + Vector2(-18, 8), rect.get_center() + Vector2(-12, 22), ink, 3.0)
					draw_line(rect.get_center() + Vector2(18, 8), rect.get_center() + Vector2(12, 22), ink, 3.0)
					draw_circle(rect.get_center() + Vector2(-8, 4), 8.0, yarn)
					draw_circle(rect.get_center() + Vector2(6, 1), 9.0, yarn.lightened(0.08))
				"cat_tower":
					draw_rect(Rect2(rect.get_center() + Vector2(-10, -22), Vector2(20, 48)), cat_secondary)
					draw_rect(Rect2(rect.get_center() + Vector2(-18, -26), Vector2(36, 8)), accent)
					draw_rect(Rect2(rect.get_center() + Vector2(-18, 0), Vector2(36, 8)), accent.darkened(0.06))
				"cat_choir":
					for offset in [-18, 0, 18]:
						_draw_cat_icon(rect.get_center() + Vector2(offset, 10), 0.48, cat_primary.lightened(0.04), ink)
				"grand_meowstro":
					_draw_cat_icon(rect.get_center() + Vector2(0, 8), 1.0, cat_secondary, ink)
					draw_line(rect.get_center() + Vector2(16, -18), rect.get_center() + Vector2(28, -30), accent.darkened(0.12), 3.0)
					draw_circle(rect.get_center() + Vector2(30, -32), 3.0, accent)
				_:
					draw_circle(rect.get_center(), 16.0, accent)

		var lane_color = accent
		match lane:
			"percussion":
				lane_color = accent.darkened(0.12)
			"bass":
				lane_color = cat_secondary.darkened(0.10)
			"texture":
				lane_color = panel_alt.darkened(0.28)
		draw_circle(Vector2(rect.size.x - 12, 12), 6.0, lane_color)

	func _load_texture(path: String) -> Texture2D:
		if path.is_empty():
			return null
		if not ResourceLoader.exists(path):
			return null
		return load(path) as Texture2D

	func _draw_loaded_icon(target_rect: Rect2) -> void:
		var texture_size = icon_texture.get_size()
		if texture_size.x <= 0.0 or texture_size.y <= 0.0:
			return
		var scale = min(target_rect.size.x / texture_size.x, target_rect.size.y / texture_size.y)
		var draw_size = texture_size * scale
		var draw_position = target_rect.position + (target_rect.size - draw_size) * 0.5
		draw_texture_rect(icon_texture, Rect2(draw_position, draw_size), false)

	func _draw_cat_icon(center: Vector2, scale: float, body: Color, ink: Color) -> void:
		var s = 18.0 * scale
		var chest = Color.WHITE.lerp(body, 0.55)
		var ear_inner = body.lightened(0.16)
		draw_circle(center + Vector2(0, 4 * scale), s * 0.65, body)
		draw_circle(center + Vector2(-5, 10) * scale, s * 0.16, body.darkened(0.02))
		draw_circle(center + Vector2(5, 10) * scale, s * 0.16, body.darkened(0.02))
		draw_circle(center + Vector2(0, -9 * scale), s * 0.52, body)
		var left_ear = PackedVector2Array([
			center + Vector2(-9, -20) * scale,
			center + Vector2(-2, -11) * scale,
			center + Vector2(-12, -9) * scale
		])
		var right_ear = PackedVector2Array([
			center + Vector2(9, -20) * scale,
			center + Vector2(2, -11) * scale,
			center + Vector2(12, -9) * scale
		])
		draw_colored_polygon(left_ear, body.darkened(0.04))
		draw_colored_polygon(right_ear, body.darkened(0.04))
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(-7, -17) * scale,
			center + Vector2(-3, -11) * scale,
			center + Vector2(-8, -10) * scale
		]), ear_inner)
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(7, -17) * scale,
			center + Vector2(3, -11) * scale,
			center + Vector2(8, -10) * scale
		]), ear_inner)
		draw_circle(center + Vector2(0, 7) * scale, s * 0.20, chest)
		draw_circle(center + Vector2(-5, -10) * scale, 1.9 * scale, ink)
		draw_circle(center + Vector2(5, -10) * scale, 1.9 * scale, ink)
		draw_circle(center + Vector2(-4, -11) * scale, 0.7 * scale, Color.WHITE)
		draw_circle(center + Vector2(6, -11) * scale, 0.7 * scale, Color.WHITE)
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(0, -5) * scale,
			center + Vector2(-2.8, -2) * scale,
			center + Vector2(2.8, -2) * scale
		]), ink.lightened(0.18))
		draw_arc(center + Vector2(0, -4) * scale, 4.5 * scale, 0.2, PI - 0.2, 8, ink, 1.4 * scale)


class PushPin:
	extends Control

	var pin_color := Color("#f59f4c")

	func set_pin_color(new_color: Color) -> void:
		pin_color = new_color
		queue_redraw()

	func _draw() -> void:
		var center = size * 0.5
		draw_circle(center + Vector2(0, 1), min(size.x, size.y) * 0.32, pin_color.darkened(0.10))
		draw_circle(center + Vector2(-2, -2), min(size.x, size.y) * 0.10, Color.WHITE)
		draw_line(center + Vector2(0, 4), center + Vector2(0, size.y * 0.45), pin_color.darkened(0.35), 2.0)


class ToyboxMillScene:
	extends Control

	signal yarn_pressed(reward_multiplier: float, timing_label: String)

	var palette: Dictionary = {}
	var stage_name = "Starter Skein"
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
	var beat_flash = 0.0
	var bpm = 96.0
	var background_asset_path := ""
	var centerpiece_asset_paths: PackedStringArray = []
	var cat_asset_paths: PackedStringArray = []
	var upgrade_order: PackedStringArray = []
	var upgrade_icon_paths: Dictionary = {}
	var background_texture: Texture2D
	var centerpiece_textures: Array = []
	var cat_textures: Array = []
	var upgrade_icon_textures: Dictionary = {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _process(delta: float) -> void:
		pulse += delta
		yarn_bump = max(0.0, yarn_bump - delta * 4.0)
		beat_flash = max(0.0, beat_flash - delta * 2.8)
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
		bpm = float(data.get("bpm", bpm))
		lane_intensities = data.get("lane_intensities", {})
		owned_upgrades = data.get("owned_upgrades", {})
		upgrade_order = PackedStringArray(data.get("upgrade_order", []))
		_set_upgrade_icons(data.get("upgrade_icons", {}))
		_set_scene_assets(data.get("scene_assets", {}))
		queue_redraw()

	func _set_scene_assets(scene_assets: Dictionary) -> void:
		var next_background_path = String(scene_assets.get("background", ""))
		var next_centerpiece_paths = PackedStringArray(scene_assets.get("centerpiece_stages", []))
		var next_cat_paths = PackedStringArray(scene_assets.get("cat_variants", []))
		if next_background_path == background_asset_path and next_centerpiece_paths == centerpiece_asset_paths and next_cat_paths == cat_asset_paths:
			return
		background_asset_path = next_background_path
		centerpiece_asset_paths = next_centerpiece_paths
		cat_asset_paths = next_cat_paths
		background_texture = _load_texture(background_asset_path)
		centerpiece_textures.clear()
		for path in centerpiece_asset_paths:
			centerpiece_textures.append(_load_texture(String(path)))
		cat_textures.clear()
		for path in cat_asset_paths:
			cat_textures.append(_load_texture(String(path)))

	func _set_upgrade_icons(icons: Dictionary) -> void:
		if icons == upgrade_icon_paths:
			return
		upgrade_icon_paths = icons.duplicate(true)
		upgrade_icon_textures.clear()
		for upgrade_id in upgrade_icon_paths.keys():
			upgrade_icon_textures[upgrade_id] = _load_texture(String(upgrade_icon_paths[upgrade_id]))

	func _load_texture(path: String) -> Texture2D:
		if path.is_empty():
			return null
		if not ResourceLoader.exists(path):
			return null
		return load(path) as Texture2D

	func trigger_yarn_bop(strength: float = 1.0) -> void:
		yarn_bump = max(yarn_bump, strength)
		beat_flash = max(beat_flash, 0.28 + strength * 0.22)
		queue_redraw()

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _is_in_yarn(event.position):
				var timing = _evaluate_click_timing()
				trigger_yarn_bop(float(timing.get("strength", 1.0)))
				yarn_pressed.emit(float(timing.get("multiplier", 1.0)), String(timing.get("label", "Off Beat")))

	func _draw() -> void:
		var bg = Color(palette.get("background", "#f8f3e6"))
		var panel = Color(palette.get("panel", "#fffaf0"))
		var panel_alt = Color(palette.get("panel_alt", "#f6e8c8"))
		var accent = Color(palette.get("accent", "#f59f4c"))
		var text = Color(palette.get("text", "#3a2c28"))
		var muted = Color(palette.get("muted_text", "#6f5a52"))
		var floor_color = Color(palette.get("scene_sea", panel_alt))
		var rug_color = Color(palette.get("scene_island_sand", panel))
		var yarn_color = Color(palette.get("scene_yarn", "#ffc766"))
		var cat_primary = Color(palette.get("scene_cat_primary", "#ffd67b"))
		var cat_secondary = Color(palette.get("scene_cat_secondary", "#f3a251"))
		var rect = Rect2(Vector2.ZERO, size)

		if background_texture != null:
			draw_texture_rect(background_texture, rect, false)
			draw_rect(rect, Color(1.0, 0.97, 0.90, 0.10))
		else:
			draw_rect(rect, bg)
			_draw_wallpaper(bg, panel_alt)
			_draw_floor(floor_color, rug_color)
			_draw_shelves(panel, muted)
			_draw_center_board(panel, panel_alt, accent)
		_draw_beat_lane(accent, panel, muted)
		_draw_progression_props(panel, panel_alt, accent, text)
		_draw_music_staff(accent, muted)
		_draw_cats(text, cat_primary, cat_secondary)
		_draw_yarn(accent, yarn_color, text)
		_draw_lane_lights(accent, panel, muted)
		_draw_scene_labels(text, muted)

	func _draw_wallpaper(bg: Color, stripe: Color) -> void:
		var sky_top = Color(palette.get("scene_sky_top", bg.lightened(0.03)))
		var sky_bottom = Color(palette.get("scene_sky_bottom", stripe.lightened(0.10)))
		for i in range(10):
			var t = float(i) / 9.0
			var band_color = sky_top.lerp(sky_bottom, t)
			draw_rect(Rect2(0, size.y * 0.06 * i, size.x, size.y * 0.07 + 2.0), band_color)
		var cloud = stripe.lightened(0.18)
		cloud.a = 0.50
		for center in [
			Vector2(size.x * 0.18, size.y * 0.14),
			Vector2(size.x * 0.44, size.y * 0.10),
			Vector2(size.x * 0.77, size.y * 0.16)
		]:
			draw_circle(center + Vector2(-24, 8), 20.0, cloud)
			draw_circle(center, 26.0, cloud)
			draw_circle(center + Vector2(28, 6), 18.0, cloud)
		draw_circle(Vector2(size.x * 0.83, size.y * 0.15), 42.0, Color(palette.get("accent", "#f59f4c")).lightened(0.18))

	func _draw_floor(floor_color: Color, rug_color: Color) -> void:
		var sea_top = size.y * 0.56
		draw_rect(Rect2(0, sea_top, size.x, size.y - sea_top), floor_color.darkened(0.02))
		for i in range(4):
			var wave = floor_color.lightened(0.18)
			wave.a = 0.28
			draw_arc(Vector2(size.x * (0.22 + i * 0.2), sea_top + 38 + (i % 2) * 16), 90.0, 0.2, PI - 0.2, 24, wave, 3.0)
		var rug_rect = Rect2(size.x * 0.14, size.y * 0.66, size.x * 0.72, max(110.0, size.y * 0.20))
		draw_rounded_rect(rug_rect, rug_color.lightened(0.03), 40.0)
		var grass = Color(palette.get("scene_island_grass", "#8fb972"))
		var grass_rect = Rect2(size.x * 0.21, size.y * 0.63, size.x * 0.58, max(64.0, size.y * 0.10))
		draw_rounded_rect(grass_rect, grass, 34.0)
		draw_arc(rug_rect.get_center(), Vector2(rug_rect.size.x * 0.42, rug_rect.size.y * 0.42).length() * 0.16, 0.0, TAU, 96, floor_color.darkened(0.13), 3.0)

	func _draw_shelves(panel: Color, muted: Color) -> void:
		var leaf = Color(palette.get("scene_leaf", "#6d9751"))
		var trunk = Color(palette.get("scene_island_sand", "#f0d7a4")).darkened(0.30)
		for root in [Vector2(size.x * 0.18, size.y * 0.54), Vector2(size.x * 0.82, size.y * 0.53)]:
			draw_line(root, root + Vector2(0, -68), trunk, 7.0)
			for angle in [-2.2, -1.6, -1.1, -0.6, -0.1]:
				var tip = root + Vector2(0, -68) + Vector2(cos(angle), sin(angle)) * 52.0
				draw_line(root + Vector2(0, -68), tip, leaf, 5.0)
		var hut = Rect2(size.x * 0.12, size.y * 0.56, 74.0, 42.0)
		draw_rounded_rect(hut, panel.lightened(0.02), 10.0)
		draw_rect(Rect2(hut.position + Vector2(-8, -10), Vector2(hut.size.x + 16, 14)), panel.darkened(0.10))

	func _draw_music_staff(accent: Color, muted: Color) -> void:
		var base_y = size.y * 0.17
		var note_color = accent
		note_color.a = 0.34
		var active = _total_lane_intensity()
		for i in active:
			var x = size.x * (0.18 + (i % 8) * 0.085)
			var y = base_y + 12 + sin(pulse * 1.8 + i * 0.5) * 8.0 + (i % 3) * 12
			draw_circle(Vector2(x, y), 6.0 + sin(pulse * 4.0 + i) * 1.0, note_color)
			draw_line(Vector2(x + 6, y), Vector2(x + 6, y - 32), note_color, 3.0)

	func _draw_cats(text: Color, cat_primary: Color, cat_secondary: Color) -> void:
		var cat_count = clamp(_owned_total(), 0, 9)
		for i in cat_count:
			var anchor = _cat_anchor(i, cat_count)
			var x = anchor.x
			var y = anchor.y + sin(pulse * 2.2 + i * 0.75) * 3.2
			var scale = 0.48 + (i % 3) * 0.05
			if not cat_textures.is_empty():
				var cat_texture = cat_textures[i % cat_textures.size()] as Texture2D
				if cat_texture != null:
					var width = 96.0 * scale
					var height = 96.0 * scale
					if i % cat_textures.size() == 1:
						width = 104.0 * scale
						height = 104.0 * scale
					var shadow_color = Color(0, 0, 0, 0.11)
					draw_circle(Vector2(x, y + height * 0.22), width * 0.22, shadow_color)
					var art_rect = Rect2(Vector2(x - width * 0.5, y - height * 0.56), Vector2(width, height))
					draw_texture_rect(cat_texture, art_rect, false)
					continue
			var body = cat_primary if i % 2 == 0 else cat_secondary
			_draw_cat(Vector2(x, y), scale, body, text)

	func _cat_anchor(index: int, total: int) -> Vector2:
		var center = _yarn_center()
		var ring = Vector2(_yarn_radius() * 1.86, _yarn_radius() * 1.42)
		var normalized_anchors = [
			Vector2(-0.52, -0.42),
			Vector2(0.52, -0.42),
			Vector2(0.70, 0.02),
			Vector2(0.46, 0.44),
			Vector2(-0.46, 0.44),
			Vector2(-0.70, 0.02),
			Vector2(0.00, -0.58),
			Vector2(0.00, 0.58),
			Vector2(-0.24, -0.60)
		]
		if total <= normalized_anchors.size():
			var normalized = normalized_anchors[index]
			return center + Vector2(normalized.x * ring.x, normalized.y * ring.y)
		var angle = -PI / 2.0 + TAU * float(index) / max(1.0, float(total))
		return center + Vector2(cos(angle) * ring.x, sin(angle) * ring.y)

	func _draw_cat(center: Vector2, scale: float, body: Color, ink: Color) -> void:
		var s = 34.0 * scale
		var chest = Color.WHITE.lerp(body, 0.55)
		var cheek = Color.WHITE.lerp(body, 0.70)
		var ear_inner = body.lightened(0.16)
		draw_circle(center + Vector2(0, 9 * scale), s * 0.54, body)
		draw_circle(center + Vector2(-11, 18) * scale, s * 0.18, body.darkened(0.02))
		draw_circle(center + Vector2(11, 18) * scale, s * 0.18, body.darkened(0.02))
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
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(-15, -31) * scale,
			center + Vector2(-8, -22) * scale,
			center + Vector2(-17, -20) * scale
		]), ear_inner)
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(15, -31) * scale,
			center + Vector2(8, -22) * scale,
			center + Vector2(17, -20) * scale
		]), ear_inner)
		draw_circle(center + Vector2(0, 14) * scale, s * 0.22, chest)
		draw_circle(center + Vector2(-8, -10) * scale, s * 0.16, cheek)
		draw_circle(center + Vector2(8, -10) * scale, s * 0.16, cheek)
		draw_circle(center + Vector2(-10, -18) * scale, 2.8 * scale, ink)
		draw_circle(center + Vector2(10, -18) * scale, 2.8 * scale, ink)
		draw_circle(center + Vector2(-9, -19) * scale, 0.9 * scale, Color.WHITE)
		draw_circle(center + Vector2(11, -19) * scale, 0.9 * scale, Color.WHITE)
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(0, -9) * scale,
			center + Vector2(-4, -4) * scale,
			center + Vector2(4, -4) * scale
		]), ink.lightened(0.18))
		draw_arc(center + Vector2(0, -6) * scale, 6.5 * scale, 0.3, PI - 0.3, 16, ink, 1.7 * scale)
		for whisker_y in [-8.0, -4.0]:
			draw_line(center + Vector2(-5, whisker_y) * scale, center + Vector2(-18, whisker_y - 2) * scale, ink, 1.2 * scale)
			draw_line(center + Vector2(5, whisker_y) * scale, center + Vector2(18, whisker_y - 2) * scale, ink, 1.2 * scale)
		draw_arc(center + Vector2(25, 8) * scale, 22.0 * scale, -1.5, 0.55, 18, body.darkened(0.06), 5.0 * scale)
		draw_arc(center + Vector2(25, 8) * scale, 17.0 * scale, -1.42, 0.48, 18, ear_inner.darkened(0.08), 2.4 * scale)

	func _draw_yarn(accent: Color, yarn_base: Color, ink: Color) -> void:
		var center = _yarn_center()
		var radius = _yarn_radius()
		var r = radius * (1.0 + yarn_bump * 0.06)
		var yarn = yarn_base
		var detail_level = mini(stage_index, 4)
		if beat_flash > 0.0:
			var beat_glow = accent.lightened(0.26)
			beat_glow.a = 0.06 + beat_flash * 0.16
			draw_circle(center, r * (1.36 + beat_flash * 0.10), beat_glow)
		var glow = accent.lightened(0.18)
		glow.a = 0.10 + stage_ratio * 0.05 + beat_flash * 0.05
		draw_circle(center + Vector2(0, r * 0.10), r * (1.05 + detail_level * 0.01), glow)
		draw_circle(center + Vector2(0, r * 0.16), r * 1.05, Color(0, 0, 0, 0.10))
		draw_circle(center, r * 1.00, yarn.darkened(0.07))
		draw_circle(center, r * 0.91, yarn)
		draw_circle(center + Vector2(-r * 0.24, -r * 0.24), r * 0.21, yarn.lightened(0.14))
		for i in range(10 + detail_level):
			var phase = pulse * 0.52 + i * 0.62
			var a = phase
			var b = phase + PI * 1.05
			var color = yarn.darkened(0.13 + (i % 3) * 0.025)
			color.a = 0.58
			draw_arc(center, r * (0.26 + i * 0.055), a, b, 36, color, 2.8)
		for i in range(detail_level):
			var knot_angle = -PI / 2.0 + i * TAU / max(1.0, float(detail_level))
			var knot_center = center + Vector2(cos(knot_angle), sin(knot_angle)) * (r * 0.74)
			draw_circle(knot_center, r * 0.06, yarn.lightened(0.10))
			draw_arc(knot_center, r * 0.05, -PI * 0.15, PI * 1.15, 16, accent.darkened(0.04), 1.4)
		var highlight = Color.WHITE
		highlight.a = 0.22
		draw_circle(center + Vector2(-r * 0.28, -r * 0.32), r * 0.16, highlight)
		var ring = accent.lightened(0.2)
		ring.a = 0.22 + stage_ratio * 0.22 + beat_flash * 0.06
		draw_arc(center, r + 18.0, -PI / 2.0, -PI / 2.0 + TAU * stage_ratio, 80, ring, 8.0)

	func _get_stage_centerpiece_texture() -> Texture2D:
		if centerpiece_textures.is_empty():
			return null
		var index = clamp(stage_index, 0, centerpiece_textures.size() - 1)
		return centerpiece_textures[index] as Texture2D

	func _draw_orbit_star(center: Vector2, radius: float, color: Color) -> void:
		var points = PackedVector2Array()
		for i in range(10):
			var angle = -PI / 2.0 + i * TAU / 10.0
			var point_radius = radius if i % 2 == 0 else radius * 0.46
			points.append(center + Vector2(cos(angle), sin(angle)) * point_radius)
		draw_colored_polygon(points, color)

	func _draw_lane_lights(accent: Color, panel: Color, muted: Color) -> void:
		var labels = ["Pulse", "Melody", "Bass", "Texture"]
		var lanes = ["percussion", "melody", "bass", "texture"]
		var start = Vector2(size.x * 0.12, size.y * 0.90)
		var spacing = size.x * 0.18
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
		draw_string(font, Vector2(30, 70), "Center Beat  |  Tap the yarn on the pulse for bonus %s" % resource_name, HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.82, 15, muted)
		var auto_text = "Island chorus at %0.1f / sec  |  Beat bonus x1.75" % auto_rate
		draw_string(font, Vector2(30, 94), auto_text, HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.8, 15, muted)

	func _is_in_yarn(position: Vector2) -> bool:
		return position.distance_to(_yarn_center()) <= _yarn_radius() * 1.42

	func _yarn_center() -> Vector2:
		return Vector2(size.x * 0.50, size.y * 0.50)

	func _yarn_radius() -> float:
		return min(size.x, size.y) * 0.16

	func _seconds_per_beat() -> float:
		return 60.0 / max(1.0, bpm)

	func _beat_progress() -> float:
		return fposmod(pulse / _seconds_per_beat(), 1.0)

	func _beat_distance() -> float:
		var progress = _beat_progress()
		return min(progress, 1.0 - progress)

	func _evaluate_click_timing() -> Dictionary:
		var distance = _beat_distance()
		if distance <= 0.08:
			return {"multiplier": 1.75, "label": "Perfect Beat", "strength": 1.28}
		if distance <= 0.17:
			return {"multiplier": 1.35, "label": "On Beat", "strength": 1.08}
		return {"multiplier": 1.0, "label": "Off Beat", "strength": 0.88}

	func _draw_center_board(panel: Color, panel_alt: Color, accent: Color) -> void:
		var center = _yarn_center()
		var board_color = Color(palette.get("scene_island_sand", panel)).lightened(0.04)
		var board_edge = board_color.darkened(0.14)
		var grass = Color(palette.get("scene_island_grass", "#8fb972"))
		var board_rect = Rect2(center - Vector2(size.x * 0.29, size.y * 0.20), Vector2(size.x * 0.58, size.y * 0.40))
		draw_rounded_rect(board_rect, board_color, 52.0)
		draw_arc(board_rect.get_center(), min(board_rect.size.x, board_rect.size.y) * 0.48, 0.0, TAU, 72, board_edge, 4.0)
		var grass_rect = Rect2(center - Vector2(size.x * 0.17, size.y * 0.12), Vector2(size.x * 0.34, size.y * 0.24))
		draw_rounded_rect(grass_rect, grass, 34.0)
		var sheen = accent.lightened(0.18)
		sheen.a = 0.06
		draw_rounded_rect(board_rect.grow(-18.0), sheen, 40.0)

	func _draw_beat_lane(accent: Color, panel: Color, muted: Color) -> void:
		var center = _yarn_center()
		var lane_half = _yarn_radius() * 2.45
		var lane_start = center + Vector2(-lane_half, 0)
		var lane_end = center + Vector2(lane_half, 0)
		var phase = _beat_progress()
		var beat_hit = pow(max(0.0, 1.0 - (_beat_distance() / 0.14)), 2.4)
		var beat_color = accent.lightened(0.08)
		beat_color.a = 0.24
		draw_line(lane_start, lane_end, beat_color, 4.0)
		draw_line(lane_start + Vector2(0, -15), lane_end + Vector2(0, -15), Color(1, 1, 1, 0.07), 1.2)
		draw_line(lane_start + Vector2(0, 15), lane_end + Vector2(0, 15), Color(0, 0, 0, 0.05), 1.2)
		for peg_center in [lane_start, lane_end]:
			draw_circle(peg_center, 11.0, panel.darkened(0.10))
			draw_circle(peg_center, 8.0, accent.lightened(0.10))
		for marker in [-0.66, -0.33, 0.33, 0.66]:
			var marker_center = center + Vector2(lane_half * marker, 0)
			var marker_color = Color(1, 1, 1, 0.09 + beat_hit * 0.06)
			draw_circle(marker_center, 4.5 + beat_hit * 0.6, marker_color)
		var center_glow = accent.lightened(0.24)
		center_glow.a = 0.16 + beat_flash * 0.10 + beat_hit * 0.12
		draw_circle(center, _yarn_radius() * (0.30 + beat_hit * 0.06), center_glow)
		if beat_hit > 0.01:
			var ripple = accent.lightened(0.18)
			ripple.a = 0.10 * beat_hit
			draw_arc(center, _yarn_radius() * (0.84 + beat_hit * 0.34), 0.0, TAU, 56, ripple, 3.0)
		for i in range(4):
			var offset = fposmod(phase + float(i) / 4.0, 1.0)
			var left_x = lerp(lane_start.x, center.x - _yarn_radius() * 0.34, offset)
			var right_x = lerp(lane_end.x, center.x + _yarn_radius() * 0.34, offset)
			var pulse_radius = 7.0 + (1.0 - offset) * 4.6
			var pulse_color = accent.lightened(0.10)
			pulse_color.a = 0.18 + (1.0 - offset) * 0.28
			_draw_lane_pulse(Vector2(left_x, center.y), -1.0, pulse_radius, pulse_color, offset)
			_draw_lane_pulse(Vector2(right_x, center.y), 1.0, pulse_radius, pulse_color, offset)
		var perfect_window = accent.lightened(0.20)
		perfect_window.a = 0.12 + beat_hit * 0.05
		draw_circle(center, _yarn_radius() * (0.56 + beat_hit * 0.02), perfect_window)
		draw_string(get_theme_default_font(), Vector2(center.x - 48, center.y - _yarn_radius() - 28), "Beat Window", HORIZONTAL_ALIGNMENT_LEFT, 120, 14, muted)

	func _draw_lane_pulse(center_point: Vector2, direction: float, radius: float, color: Color, offset: float) -> void:
		var glow = color
		glow.a *= 0.42
		draw_circle(center_point, radius * 1.55, glow)
		draw_circle(center_point, radius, color)
		draw_circle(center_point, radius * 0.34, Color(1, 1, 1, min(0.32, color.a + 0.08)))
		for trail_index in range(2):
			var trail_scale = 0.60 - trail_index * 0.18
			var trail_offset = 16.0 + trail_index * 12.0
			var trail_center = center_point + Vector2(direction * trail_offset * (1.0 - offset), 0)
			var trail_color = color
			trail_color.a *= 0.32 - trail_index * 0.10
			draw_circle(trail_center, radius * trail_scale, trail_color)

	func _draw_progression_props(panel: Color, panel_alt: Color, accent: Color, ink: Color) -> void:
		var visible_upgrades: Array = []
		for upgrade_id in upgrade_order:
			var count = int(owned_upgrades.get(String(upgrade_id), 0))
			if count > 0:
				visible_upgrades.append({"id": String(upgrade_id), "count": count})
		if visible_upgrades.is_empty():
			return
		var center = _yarn_center()
		for i in visible_upgrades.size():
			var entry: Dictionary = visible_upgrades[i]
			var anchor = _progression_anchor(i, visible_upgrades.size())
			draw_circle(anchor + Vector2(0, 16), 20.0, Color(0, 0, 0, 0.08))
			draw_circle(anchor, 23.0, panel.lightened(0.03))
			draw_circle(anchor, 20.0, panel_alt.lightened(0.03))
			draw_arc(anchor, 22.0, 0.0, TAU, 24, accent.darkened(0.08), 1.4)
			var icon_texture = upgrade_icon_textures.get(String(entry.get("id", ""))) as Texture2D
			if icon_texture != null:
				draw_texture_rect(icon_texture, Rect2(anchor - Vector2(16, 16), Vector2(32, 32)), false)
			else:
				draw_circle(anchor, 9.0, accent)
			var count = int(entry.get("count", 0))
			if count > 1:
				var badge_center = anchor + Vector2(14, -14)
				draw_circle(badge_center, 10.0, accent.darkened(0.04))
				draw_string(get_theme_default_font(), badge_center + Vector2(-5, 5), str(count), HORIZONTAL_ALIGNMENT_LEFT, 14, 12, ink)

	func _progression_anchor(index: int, total: int) -> Vector2:
		var center = _yarn_center()
		var ring = Vector2(_yarn_radius() * 2.52, _yarn_radius() * 1.76)
		var normalized_anchors = [
			Vector2(0.00, -0.58),
			Vector2(-0.36, -0.52),
			Vector2(0.36, -0.52),
			Vector2(0.68, -0.34),
			Vector2(0.74, 0.12),
			Vector2(0.42, 0.52),
			Vector2(-0.42, 0.52),
			Vector2(-0.74, 0.12),
			Vector2(-0.68, -0.34),
			Vector2(0.00, 0.62)
		]
		if total <= normalized_anchors.size():
			var normalized = normalized_anchors[index]
			return center + Vector2(normalized.x * ring.x, normalized.y * ring.y)
		var angle = -PI / 2.0 + TAU * float(index) / max(1.0, float(total))
		return center + Vector2(cos(angle) * ring.x, sin(angle) * ring.y)

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
var status_message = "Catch the beat on the yarn to wake up the first little melody."
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
var interaction_hint_label: Label
var prestige_button: Button
var theme_option_button: OptionButton
var shelf_header_rect: TextureRect
var upgrade_container: VBoxContainer
var music_toggle: CheckBox
var scene_view: ToyboxMillScene
var shop_panel_node: PanelContainer
var lane_bar_map = {}
var lane_slider_map = {}
var panel_nodes: Array = []
var alt_panel_nodes: Array = []
var shelf_card_nodes: Array = []
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
			status_message = "The centerpiece unfurled into %s." % String(result["stages"][-1])

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
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var root = VBoxContainer.new()
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	root.add_child(_build_top_bar())

	var main_split = HSplitContainer.new()
	main_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_split.split_offset = 980
	root.add_child(main_split)

	var left_column = VBoxContainer.new()
	left_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.add_theme_constant_override("separation", 10)
	main_split.add_child(left_column)

	var scene_panel = _make_panel(false)
	scene_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_column.add_child(scene_panel)
	scene_view = ToyboxMillScene.new()
	scene_view.custom_minimum_size = Vector2(620, 500)
	scene_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene_view.yarn_pressed.connect(_on_click_button_pressed)
	scene_panel.add_child(scene_view)

	left_column.add_child(_build_bottom_bar())

	shop_panel_node = _make_panel(false)
	shop_panel_node.custom_minimum_size = Vector2(300, 0)
	shop_panel_node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_split.add_child(shop_panel_node)
	var shop_box = _make_panel_content(shop_panel_node)
	shelf_header_rect = TextureRect.new()
	shelf_header_rect.custom_minimum_size = Vector2(0, 82)
	shelf_header_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shelf_header_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shop_box.add_child(shelf_header_rect)
	shop_box.add_child(_make_section_title("Toy Shelf"))

	var shop_hint = _make_body_label("A sun-warmed wooden rack of toys, performers, and tiny melody makers.")
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
	title_label.add_theme_font_size_override("font_size", 28)
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
	theme_option_button.custom_minimum_size = Vector2(170, 36)
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
	controls_panel.custom_minimum_size = Vector2(300, 0)
	bottom.add_child(controls_panel)
	var controls_box = _make_panel_content(controls_panel)
	controls_box.add_theme_constant_override("separation", 6)

	interaction_hint_label = _make_body_label("Tap the central yarn on the beat to farm Yarn and wake the island melody.")
	interaction_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_box.add_child(interaction_hint_label)
	muted_label_nodes.append(interaction_hint_label)

	prestige_button = Button.new()
	prestige_button.text = "Spin"
	prestige_button.custom_minimum_size = Vector2(0, 46)
	prestige_button.pressed.connect(_on_prestige_button_pressed)
	controls_box.add_child(prestige_button)
	button_nodes.append(prestige_button)

	music_toggle = CheckBox.new()
	music_toggle.text = "Music"
	music_toggle.button_pressed = true
	music_toggle.toggled.connect(_on_music_toggled)
	controls_box.add_child(music_toggle)
	button_nodes.append(music_toggle)

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
	subtitle_label.text = "Cozy island rhythm mill - build a tiny cat orchestra around the central yarn."
	resource_label.text = "%s  %s" % [resource_name, game_state.format_number(float(mill_state.get("resource", 0.0)))]
	harmony_label.text = "Harmony  %s" % game_state.get_harmony_points()
	stage_label.text = String(current_stage.get("name", "Unknown Stage"))
	stage_bar.value = game_state.get_stage_progress_ratio(current_mill_id)
	production_label.text = "Tap +%s    On-beat x1.75    Auto %s/sec    Run %s" % [
		game_state.format_number(click_power),
		game_state.format_number(auto_rate),
		game_state.format_number(float(mill_state.get("run_resource", 0.0)))
	]
	interaction_hint_label.text = "Tap the central yarn for +%s %s, and land the pulse for a bigger bundle." % [
		game_state.format_number(click_power),
		resource_name
	]

	var prestige_reward = game_state.get_prestige_reward(current_mill_id)
	if game_state.can_prestige(current_mill_id):
		prestige_button.disabled = false
		prestige_button.text = "%s +%s" % [game_state.get_prestige_action_name(current_mill_id), prestige_reward]
	else:
		prestige_button.disabled = true
		prestige_button.text = "Spin Into Harmony (Locked)"
	status_label.text = status_message


func _refresh_scene_view() -> void:
	if scene_view == null:
		return
	var mill_state = game_state.get_mill_state(current_mill_id)
	var current_stage = game_state.get_current_stage(current_mill_id)
	var active_theme = game_state.get_active_theme_pack(current_mill_id)
	var scene_upgrade_order = PackedStringArray()
	for upgrade in game_state.get_mill_definition(current_mill_id).get("upgrades", []):
		scene_upgrade_order.append(String(upgrade.get("id", "")))
	scene_view.set_scene_data({
		"palette": active_theme.get("palette", {}),
		"stage_name": String(current_stage.get("name", "Starter Skein")),
		"stage_index": int(mill_state.get("stage_index", 0)),
		"stage_ratio": game_state.get_stage_progress_ratio(current_mill_id),
		"resource_name": game_state.get_resource_display_name(current_mill_id),
		"click_action_name": game_state.get_click_action_name(current_mill_id),
		"click_power": game_state.get_click_power(current_mill_id),
		"auto_rate": game_state.get_auto_production_per_second(current_mill_id),
		"bpm": conductor.bpm,
		"lane_intensities": game_state.get_lane_intensities(current_mill_id),
		"owned_upgrades": mill_state.get("upgrades", {}),
		"upgrade_order": scene_upgrade_order,
		"upgrade_icons": active_theme.get("upgrade_icons", {}),
		"scene_assets": active_theme.get("scene_assets", {})
	})


func _refresh_theme() -> void:
	_prune_themed_references()
	var theme = game_state.get_active_theme_pack(current_mill_id)
	current_theme_id = String(theme.get("id", ""))
	var palette: Dictionary = theme.get("palette", {})
	var scene_assets: Dictionary = theme.get("scene_assets", {})
	var bg = Color(palette.get("background", "#f8f3e6"))
	var panel = Color(palette.get("panel", "#fffaf0"))
	var panel_alt = Color(palette.get("panel_alt", "#f6e8c8"))
	var accent = Color(palette.get("accent", "#f59f4c"))
	var wood = Color(palette.get("scene_island_sand", "#d7b07f")).darkened(0.12)
	var wood_edge = wood.darkened(0.28)
	var paper = panel.lightened(0.02)
	var paper_edge = panel_alt.darkened(0.18)
	var button = Color(palette.get("button", "#ffd27a"))
	var button_text = Color(palette.get("button_text", "#3a2c28"))
	var text = Color(palette.get("text", "#3a2c28"))
	var muted = Color(palette.get("muted_text", "#6f5a52"))

	background_rect.color = bg
	for panel_node in panel_nodes:
		panel_node.add_theme_stylebox_override("panel", _style_box(panel))
	for panel_node in alt_panel_nodes:
		panel_node.add_theme_stylebox_override("panel", _style_box(panel_alt))
	for shelf_card in shelf_card_nodes:
		shelf_card.add_theme_stylebox_override("panel", _paper_card_style_box(paper, paper_edge))
	if is_instance_valid(shop_panel_node):
		shop_panel_node.add_theme_stylebox_override("panel", _wood_rack_style_box(wood, wood_edge))
	if is_instance_valid(shelf_header_rect):
		var shelf_header_path = String(scene_assets.get("shelf_header", ""))
		if not shelf_header_path.is_empty() and ResourceLoader.exists(shelf_header_path):
			shelf_header_rect.texture = load(shelf_header_path) as Texture2D
			shelf_header_rect.visible = true
		else:
			shelf_header_rect.texture = null
			shelf_header_rect.visible = false
	for button_node in button_nodes:
		if button_node is Button:
			if button_node is CheckBox:
				button_node.add_theme_stylebox_override("normal", _button_style_box(panel, panel_alt.darkened(0.12), 0))
				button_node.add_theme_stylebox_override("hover", _button_style_box(panel.lightened(0.04), accent, 0))
				button_node.add_theme_stylebox_override("pressed", _button_style_box(panel_alt, accent, 0))
				button_node.add_theme_color_override("font_color", text)
				button_node.add_theme_font_size_override("font_size", 15)
				continue
			button_node.add_theme_stylebox_override("normal", _button_style_box(button, accent.darkened(0.08), 3))
			button_node.add_theme_stylebox_override("hover", _button_style_box(button.lightened(0.08), accent, 4))
			button_node.add_theme_stylebox_override("pressed", _button_style_box(accent, accent.darkened(0.22), 1))
			button_node.add_theme_stylebox_override("disabled", _button_style_box(panel_alt.darkened(0.08), panel_alt.darkened(0.18), 0))
			button_node.add_theme_color_override("font_color", button_text)
			button_node.add_theme_color_override("font_disabled_color", muted)
			button_node.add_theme_font_size_override("font_size", 15)
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

	var active_theme = game_state.get_active_theme_pack(current_mill_id)
	var theme_palette: Dictionary = active_theme.get("palette", {})
	var theme_upgrade_icons: Dictionary = active_theme.get("upgrade_icons", {})

	for upgrade in game_state.get_mill_definition(current_mill_id).get("upgrades", []):
		var upgrade_panel = _make_shelf_card()
		upgrade_container.add_child(upgrade_panel)
		var card_box = VBoxContainer.new()
		card_box.add_theme_constant_override("separation", 6)
		upgrade_panel.add_child(card_box)
		upgrade_panel.add_theme_constant_override("margin_left", 9)
		upgrade_panel.add_theme_constant_override("margin_right", 9)
		upgrade_panel.add_theme_constant_override("margin_top", 9)
		upgrade_panel.add_theme_constant_override("margin_bottom", 9)

		var top_row = HBoxContainer.new()
		top_row.add_theme_constant_override("separation", 8)
		card_box.add_child(top_row)

		var upgrade_id = String(upgrade["id"])
		var lane_id = String(upgrade.get("lane", "melody"))
		var icon = UpgradeShelfIcon.new()
		icon.custom_minimum_size = Vector2(58, 58)
		icon.set_icon_data(theme_palette, upgrade_id, lane_id, String(theme_upgrade_icons.get(upgrade_id, "")))
		top_row.add_child(icon)

		var copy = VBoxContainer.new()
		copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		copy.add_theme_constant_override("separation", 2)
		top_row.add_child(copy)

		var owned = game_state.get_upgrade_count(current_mill_id, upgrade_id)
		var cost = game_state.get_upgrade_cost(current_mill_id, upgrade_id)
		var lane_name = lane_id.capitalize()

		var pin_row = HBoxContainer.new()
		pin_row.add_theme_constant_override("separation", 6)
		copy.add_child(pin_row)

		var pin = PushPin.new()
		pin.custom_minimum_size = Vector2(18, 18)
		pin.set_pin_color(_lane_color(lane_id))
		pin_row.add_child(pin)

		var lane_label = _make_body_label("%s lane" % lane_name)
		pin_row.add_child(lane_label)
		muted_label_nodes.append(lane_label)

		var header_row = HBoxContainer.new()
		header_row.add_theme_constant_override("separation", 6)
		copy.add_child(header_row)

		var name_label = _make_value_label(15)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.text = game_state.get_upgrade_display_name(current_mill_id, upgrade_id)
		header_row.add_child(name_label)

		var owned_label = _make_body_label("Owned %s" % owned)
		header_row.add_child(owned_label)
		muted_label_nodes.append(owned_label)

		var desc_label = _make_body_label(String(upgrade.get("description", "")))
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		copy.add_child(desc_label)
		muted_label_nodes.append(desc_label)

		var meta_label = _make_body_label(_build_upgrade_meta_text(upgrade))
		meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		copy.add_child(meta_label)
		muted_label_nodes.append(meta_label)

		var buy_button = Button.new()
		buy_button.text = "Add to Shelf  %s" % game_state.format_number(cost)
		buy_button.custom_minimum_size = Vector2(0, 40)
		buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_button.disabled = not game_state.can_purchase_upgrade(current_mill_id, upgrade_id)
		buy_button.pressed.connect(_on_upgrade_pressed.bind(upgrade_id))
		card_box.add_child(buy_button)
		button_nodes.append(buy_button)

	_refresh_theme()


func _build_upgrade_meta_text(upgrade: Dictionary) -> String:
	var fragments: Array = []
	var click_bonus = float(upgrade.get("click_bonus", 0.0))
	var auto_rate = float(upgrade.get("auto_rate", 0.0))
	var auto_multiplier = float(upgrade.get("auto_multiplier", 0.0))
	var production_multiplier = float(upgrade.get("production_multiplier", 0.0))

	if click_bonus > 0.0:
		fragments.append("+%s tap" % game_state.format_number(click_bonus))
	if auto_rate > 0.0:
		fragments.append("+%s/s" % game_state.format_number(auto_rate))
	if auto_multiplier > 0.0:
		fragments.append("+%s%% auto" % int(round(auto_multiplier * 100.0)))
	if production_multiplier > 0.0:
		fragments.append("+%s%% output" % int(round(production_multiplier * 100.0)))
	if fragments.is_empty():
		return "Adds another soft voice around the yarn."
	return "  ".join(fragments)


func _refresh_music_meter() -> void:
	var lane_intensities = game_state.get_lane_intensities(current_mill_id)
	conductor.set_lane_intensities(lane_intensities)
	for lane in lane_bar_map.keys():
		var bar: ProgressBar = lane_bar_map[lane]
		bar.value = int(lane_intensities.get(lane, 0))


func _on_click_button_pressed(reward_multiplier: float = 1.0, timing_label: String = "Off Beat") -> void:
	var amount = game_state.get_click_power(current_mill_id) * reward_multiplier
	var result = game_state.earn_resource(current_mill_id, amount)
	conductor.play_click()
	if not result["stages"].is_empty():
		status_message = "The centerpiece unfurled into %s." % String(result["stages"][-1])
	elif timing_label == "Perfect Beat":
		status_message = "Perfect beat. The yarn burst open for %s %s." % [
			game_state.format_number(amount),
			game_state.get_resource_display_name(current_mill_id)
		]
	elif timing_label == "On Beat":
		status_message = "On beat. The island answered with a richer bundle of %s." % game_state.get_resource_display_name(current_mill_id)
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


func _make_shelf_card() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _paper_card_style_box(Color("#fffaf0"), Color("#d9c39c")))
	shelf_card_nodes.append(panel)
	return panel


func _make_panel_content(panel: PanelContainer) -> VBoxContainer:
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	panel.add_theme_constant_override("margin_left", 10)
	panel.add_theme_constant_override("margin_right", 10)
	panel.add_theme_constant_override("margin_top", 10)
	panel.add_theme_constant_override("margin_bottom", 10)
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


func _button_style_box(color: Color, edge: Color, shadow_size: int) -> StyleBoxFlat:
	var style = _style_box(color)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 3
	style.border_color = edge
	style.shadow_size = shadow_size
	style.shadow_color = Color(0, 0, 0, 0.12)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style


func _wood_rack_style_box(color: Color, edge: Color) -> StyleBoxFlat:
	var style = _style_box(color)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 8
	style.border_width_bottom = 6
	style.border_color = edge
	style.shadow_size = 6
	style.shadow_color = Color(0, 0, 0, 0.16)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style


func _paper_card_style_box(color: Color, edge: Color) -> StyleBoxFlat:
	var style = _style_box(color)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 3
	style.border_color = edge
	style.shadow_size = 4
	style.shadow_color = Color(0, 0, 0, 0.10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 12
	style.content_margin_bottom = 12
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
		"The yarn gives a soft little off-beat bounce.",
		"A tiny bell note slips into the room.",
		"The cats are still feeling out the rhythm.",
		"The toybox hums a little warmer."
	]
	return messages[randi() % messages.size()]


func _prune_themed_references() -> void:
	panel_nodes = panel_nodes.filter(func(node): return is_instance_valid(node))
	alt_panel_nodes = alt_panel_nodes.filter(func(node): return is_instance_valid(node))
	shelf_card_nodes = shelf_card_nodes.filter(func(node): return is_instance_valid(node))
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
