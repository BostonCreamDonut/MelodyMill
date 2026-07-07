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
	var upgrade_lanes: Dictionary = {}
	var upgrade_types: Dictionary = {}
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
		upgrade_lanes = data.get("upgrade_lanes", {})
		upgrade_types = data.get("upgrade_types", {})
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
		var performers = _build_performer_layout()
		for i in performers.size():
			var performer: Dictionary = performers[i]
			var anchor = performer.get("anchor", _yarn_center()) as Vector2
			var x = anchor.x
			var motion = performer.get("motion", 0.0) as float
			var zone = String(performer.get("zone", "melody"))
			var base_y = anchor.y + sin(pulse * (1.8 + motion * 0.25) + i * 0.7) * (2.0 + motion * 0.35)
			var scale = performer.get("scale", 0.48) as float
			if not cat_textures.is_empty():
				var texture_index = int(performer.get("texture_index", i % cat_textures.size())) % max(1, cat_textures.size())
				var cat_texture = cat_textures[texture_index] as Texture2D
				if cat_texture != null:
					var width = 92.0 * scale
					var height = 92.0 * scale
					if texture_index == 1:
						width = 98.0 * scale
						height = 98.0 * scale
					var shadow_color = Color(0, 0, 0, 0.11)
					draw_circle(Vector2(x, base_y + height * 0.22), width * 0.20, shadow_color)
					var art_rect = Rect2(Vector2(x - width * 0.5, base_y - height * 0.56), Vector2(width, height))
					draw_texture_rect(cat_texture, art_rect, false)
					continue
			var body = cat_primary if i % 2 == 0 else cat_secondary
			_draw_cat(Vector2(x, base_y), scale, body, text)

	func _build_performer_layout() -> Array:
		var performers: Array = []
		var melody_anchor = _zone_anchor(Vector2(0.0, -1.24))
		var percussion_anchor = _zone_anchor(Vector2(-1.10, -0.52))
		var texture_anchor = _zone_anchor(Vector2(1.10, -0.48))
		var bass_anchor = _zone_anchor(Vector2(0.0, 1.18))
		var kitten_count = mini(_upgrade_count("kitten"), 4)
		var house_cat_count = mini(_upgrade_count("house_cat"), 3)
		var scratching_post_count = mini(_upgrade_count("scratching_post"), 2)
		var yarn_basket_count = mini(_upgrade_count("yarn_basket"), 1)
		var cat_choir_count = mini(_upgrade_count("cat_choir"), 2)
		var cat_tower_count = mini(_upgrade_count("cat_tower"), 2)
		var grand_meowstro_count = mini(_upgrade_count("grand_meowstro"), 1)
		var total_owned = _owned_total()
		for slot in _zone_slots(melody_anchor, "melody", kitten_count + house_cat_count):
			var entry: Dictionary = slot
			var slot_index = int(entry.get("slot_index", 0))
			entry["texture_index"] = 1 if slot_index >= kitten_count and house_cat_count > 0 else 0
			entry["scale"] = 0.44 if slot_index < kitten_count else 0.50
			entry["motion"] = 1.4 + slot_index * 0.2
			performers.append(entry)
		for slot in _zone_slots(percussion_anchor, "percussion", scratching_post_count):
			var entry: Dictionary = slot
			entry["texture_index"] = 0
			entry["scale"] = 0.42
			entry["motion"] = 1.9
			performers.append(entry)
		for slot in _zone_slots(texture_anchor, "texture", yarn_basket_count + cat_choir_count):
			var entry: Dictionary = slot
			entry["texture_index"] = 1 if int(entry.get("slot_index", 0)) >= yarn_basket_count and cat_choir_count > 0 else 0
			entry["scale"] = 0.43
			entry["motion"] = 1.1
			performers.append(entry)
		for slot in _zone_slots(bass_anchor, "bass", cat_tower_count + grand_meowstro_count):
			var entry: Dictionary = slot
			entry["texture_index"] = 1 if int(entry.get("slot_index", 0)) >= cat_tower_count and grand_meowstro_count > 0 else 0
			entry["scale"] = 0.46 if int(entry.get("slot_index", 0)) < cat_tower_count else 0.52
			entry["motion"] = 0.9
			performers.append(entry)
		if performers.is_empty() and total_owned > 0:
			performers.append({
				"anchor": melody_anchor + Vector2(0, 8),
				"zone": "melody",
				"texture_index": 0,
				"scale": 0.44,
				"motion": 1.2,
				"slot_index": 0
			})
		return performers

	func _zone_slots(anchor: Vector2, zone: String, count: int) -> Array:
		var slots: Array = []
		if count <= 0:
			return slots
		var offsets: Array = []
		match zone:
			"melody":
				offsets = [
					Vector2(-16, 16),
					Vector2(16, 16),
					Vector2(-5, 26),
					Vector2(8, 26),
					Vector2(0, 6)
				]
			"percussion":
				offsets = [
					Vector2(-11, 14),
					Vector2(10, 18),
					Vector2(0, 6)
				]
			"texture":
				offsets = [
					Vector2(-10, 16),
					Vector2(12, 16),
					Vector2(0, 6)
				]
			"bass":
				offsets = [
					Vector2(-20, 12),
					Vector2(18, 10),
					Vector2(0, 22)
				]
			_:
				offsets = [Vector2.ZERO]
		for slot_index in range(mini(count, offsets.size())):
			slots.append({
				"anchor": anchor + offsets[slot_index],
				"zone": zone,
				"slot_index": slot_index
			})
		return slots

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
		var sand = Color(palette.get("scene_island_sand", "#f0d7a4"))
		var grass = Color(palette.get("scene_island_grass", "#8fb972"))
		var wood = sand.lerp(accent, 0.22)
		var nest_center = center + Vector2(0, r * 0.44)
		var nest_shadow = wood.darkened(0.54)
		nest_shadow.a = 0.12
		draw_circle(nest_center + Vector2(0, 7), r * 0.90, nest_shadow)
		draw_circle(nest_center, r * 0.80, grass.lerp(sand, 0.40).darkened(0.02))
		draw_circle(nest_center, r * 0.64, sand.lightened(0.08))
		for weave_index in range(8):
			var weave_angle = pulse * 0.10 + weave_index * TAU / 8.0
			var weave_center = nest_center + Vector2(cos(weave_angle), sin(weave_angle)) * (r * 0.48)
			draw_circle(weave_center, r * 0.08, wood.lightened(0.02))
		draw_arc(nest_center, r * 0.72, 0.0, TAU, 48, wood.darkened(0.16), 4.0)
		for peg_index in range(4):
			var peg_angle = -PI / 4.0 + peg_index * TAU / 4.0
			var peg_center = center + Vector2(cos(peg_angle), sin(peg_angle)) * (r * 1.04)
			draw_circle(peg_center, r * 0.09, wood.darkened(0.08))
			draw_circle(peg_center + Vector2(0, -r * 0.03), r * 0.06, sand.lightened(0.10))
		for thread_index in range(3):
			var thread_angle = -1.3 + thread_index * 0.54 + sin(pulse * 0.4 + thread_index) * 0.05
			var thread_start = center + Vector2(cos(thread_angle), sin(thread_angle)) * (r * 0.92)
			var thread_end = center + Vector2(cos(thread_angle + 0.42), sin(thread_angle + 0.42)) * (r * (1.20 + thread_index * 0.06))
			draw_line(thread_start, thread_end, yarn.lightened(0.12), 2.2)
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
		return min(size.x, size.y) * 0.145

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
		var lane_half = _yarn_radius() * 2.75
		var lane_start = center + Vector2(-lane_half, 0)
		var lane_end = center + Vector2(lane_half, 0)
		var phase = _beat_progress()
		var beat_hit = pow(max(0.0, 1.0 - (_beat_distance() / 0.14)), 2.4)
		var line_spacing = 8.0
		var staff_color = accent.lightened(0.05)
		staff_color.a = 0.18
		for line_index in range(5):
			var line_y = center.y + (line_index - 2) * line_spacing
			draw_line(Vector2(lane_start.x, line_y), Vector2(lane_end.x, line_y), staff_color, 1.8)
		var bar_color = accent.darkened(0.08)
		bar_color.a = 0.42
		for peg_center in [lane_start, lane_end]:
			draw_line(peg_center + Vector2(0, -line_spacing * 2.5), peg_center + Vector2(0, line_spacing * 2.5), bar_color, 3.0)
			draw_circle(peg_center + Vector2(0, line_spacing * 2.8), 7.0, panel.darkened(0.10))
		for marker in [-0.66, -0.33, 0.33, 0.66]:
			var marker_center = center + Vector2(lane_half * marker, 0)
			var marker_color = Color(1, 1, 1, 0.08 + beat_hit * 0.04)
			draw_line(marker_center + Vector2(0, -line_spacing * 1.6), marker_center + Vector2(0, line_spacing * 1.6), marker_color, 1.4)
		var center_glow = accent.lightened(0.24)
		center_glow.a = 0.16 + beat_flash * 0.10 + beat_hit * 0.12
		draw_circle(center, _yarn_radius() * (0.30 + beat_hit * 0.06), center_glow)
		if beat_hit > 0.01:
			var ripple = accent.lightened(0.18)
			ripple.a = 0.10 * beat_hit
			draw_arc(center, _yarn_radius() * (0.84 + beat_hit * 0.34), 0.0, TAU, 56, ripple, 3.0)
		var center_bar_color = accent.lightened(0.12)
		center_bar_color.a = 0.30 + beat_hit * 0.12
		draw_line(center + Vector2(-5, -line_spacing * 2.4), center + Vector2(-5, line_spacing * 2.4), center_bar_color, 2.2)
		draw_line(center + Vector2(5, -line_spacing * 2.4), center + Vector2(5, line_spacing * 2.4), center_bar_color, 4.0)
		if beat_hit > 0.12:
			var flash = accent.lightened(0.22)
			flash.a = beat_hit * 0.24
			draw_rect(
				Rect2(
					center + Vector2(-_yarn_radius() * 0.64, -line_spacing * 2.8),
					Vector2(_yarn_radius() * 1.28, line_spacing * 5.6)
				),
				flash
			)
			for accent_index in range(4):
				var sweep = lerp(-line_spacing * 1.5, line_spacing * 1.5, float(accent_index) / 3.0)
				var flare_start = center + Vector2(-_yarn_radius() * (1.00 + beat_hit * 0.25), sweep)
				var flare_end = center + Vector2(_yarn_radius() * (1.00 + beat_hit * 0.25), sweep)
				draw_line(flare_start, flare_end, Color(1, 1, 1, 0.05 + beat_hit * 0.08), 1.2)
		for i in range(4):
			var offset = fposmod(phase + float(i) / 4.0, 1.0)
			var left_x = lerp(lane_start.x, center.x - _yarn_radius() * 0.34, offset)
			var right_x = lerp(lane_end.x, center.x + _yarn_radius() * 0.34, offset)
			var line_offset = float(((i * 2) % 5) - 2) * line_spacing * 0.64
			var pulse_radius = 6.8 + (1.0 - offset) * 3.6
			var pulse_color = accent.lightened(0.10)
			pulse_color.a = 0.18 + (1.0 - offset) * 0.24
			_draw_lane_pulse(Vector2(left_x, center.y + line_offset), -1.0, pulse_radius, pulse_color, offset)
			_draw_lane_pulse(Vector2(right_x, center.y - line_offset), 1.0, pulse_radius, pulse_color, offset)
		var perfect_window = accent.lightened(0.20)
		perfect_window.a = 0.12 + beat_hit * 0.05
		draw_circle(center, _yarn_radius() * (0.56 + beat_hit * 0.02), perfect_window)
		if beat_hit > 0.45:
			_draw_center_note_burst(center, accent, beat_hit)
		draw_string(get_theme_default_font(), Vector2(center.x - 48, center.y - _yarn_radius() - 28), "Beat Window", HORIZONTAL_ALIGNMENT_LEFT, 120, 14, muted)

	func _draw_lane_pulse(center_point: Vector2, direction: float, radius: float, color: Color, offset: float) -> void:
		var glow = color
		glow.a *= 0.34
		draw_circle(center_point, radius * 1.22, glow)
		draw_circle(center_point + Vector2(0, 1.0), radius * 0.84, color)
		var highlight = Color(1, 1, 1, min(0.28, color.a + 0.06))
		draw_circle(center_point + Vector2(-radius * 0.10, -radius * 0.10), radius * 0.26, highlight)
		var stem_color = color
		stem_color.a *= 0.92
		var stem_direction = -1.0 if center_point.y <= _yarn_center().y else 1.0
		draw_line(
			center_point + Vector2(radius * 0.62, 0),
			center_point + Vector2(radius * 0.62, stem_direction * (radius * 2.3)),
			stem_color,
			1.8
		)
		for trail_index in range(2):
			var trail_scale = 0.54 - trail_index * 0.18
			var trail_offset = 18.0 + trail_index * 14.0
			var trail_center = center_point + Vector2(direction * trail_offset * (1.0 - offset), 0)
			var trail_color = color
			trail_color.a *= 0.24 - trail_index * 0.08
			draw_circle(trail_center, radius * trail_scale, trail_color)

	func _draw_center_note_burst(center: Vector2, accent: Color, beat_hit: float) -> void:
		var burst_color = accent.lightened(0.26)
		burst_color.a = 0.20 * beat_hit
		for i in range(6):
			var angle = -PI / 2.0 + TAU * float(i) / 6.0
			var start = center + Vector2(cos(angle), sin(angle)) * (_yarn_radius() * 0.62)
			var tip = center + Vector2(cos(angle), sin(angle)) * (_yarn_radius() * (0.98 + beat_hit * 0.12))
			draw_line(start, tip, burst_color, 2.0)
		for i in range(3):
			var note_center = center + Vector2((-1 + i) * (_yarn_radius() * 0.40), -_yarn_radius() * (0.88 + i * 0.08))
			draw_circle(note_center, 4.0 + beat_hit * 1.4, burst_color)
			draw_line(note_center + Vector2(4.0, 0), note_center + Vector2(4.0, -11.0 - beat_hit * 3.0), burst_color, 1.6)

	func _draw_progression_props(panel: Color, panel_alt: Color, accent: Color, ink: Color) -> void:
		var kitten_count = _upgrade_count("kitten")
		var house_cat_count = _upgrade_count("house_cat")
		var scratching_post_count = _upgrade_count("scratching_post")
		var yarn_basket_count = _upgrade_count("yarn_basket")
		var cat_choir_count = _upgrade_count("cat_choir")
		var cat_tower_count = _upgrade_count("cat_tower")
		var grand_meowstro_count = _upgrade_count("grand_meowstro")
		var melody_total = kitten_count + house_cat_count
		var texture_total = yarn_basket_count + cat_choir_count
		var bass_total = cat_tower_count + grand_meowstro_count
		var total_owned = melody_total + scratching_post_count + texture_total + bass_total
		if total_owned <= 0:
			return
		var center = _yarn_center()
		var sand = Color(palette.get("scene_island_sand", "#f0d7a4"))
		var wood = sand.lerp(accent, 0.22)
		var highlight = sand.lightened(0.12)
		var melody_anchor = _zone_anchor(Vector2(0.0, -1.24))
		var percussion_anchor = _zone_anchor(Vector2(-1.10, -0.52))
		var texture_anchor = _zone_anchor(Vector2(1.10, -0.48))
		var bass_anchor = _zone_anchor(Vector2(0.0, 1.18))
		_draw_mill_foundations(
			center,
			melody_anchor,
			percussion_anchor,
			texture_anchor,
			bass_anchor,
			sand,
			wood,
			accent,
			melody_total,
			scratching_post_count,
			texture_total,
			bass_total
		)
		if melody_total > 0:
			_draw_zone_aura(melody_anchor, int(lane_intensities.get("melody", 0)), accent, "melody")
		if scratching_post_count > 0:
			_draw_zone_aura(percussion_anchor, int(lane_intensities.get("percussion", 0)), accent, "percussion")
		if texture_total > 0:
			_draw_zone_aura(texture_anchor, int(lane_intensities.get("texture", 0)), accent, "texture")
		if bass_total > 0:
			_draw_zone_aura(bass_anchor, int(lane_intensities.get("bass", 0)), accent, "bass")
		_draw_melody_nook(
			melody_anchor,
			kitten_count,
			house_cat_count,
			upgrade_icon_textures.get("kitten") as Texture2D,
			upgrade_icon_textures.get("house_cat") as Texture2D,
			sand,
			wood,
			accent,
			ink
		)
		_draw_percussion_deck(
			percussion_anchor,
			scratching_post_count,
			upgrade_icon_textures.get("scratching_post") as Texture2D,
			sand,
			wood,
			accent
		)
		_draw_texture_corner(
			texture_anchor,
			yarn_basket_count,
			cat_choir_count,
			upgrade_icon_textures.get("yarn_basket") as Texture2D,
			upgrade_icon_textures.get("cat_choir") as Texture2D,
			sand,
			wood,
			accent
		)
		_draw_bass_terrace(
			bass_anchor,
			cat_tower_count,
			grand_meowstro_count,
			upgrade_icon_textures.get("cat_tower") as Texture2D,
			upgrade_icon_textures.get("grand_meowstro") as Texture2D,
			sand,
			wood,
			accent,
			highlight
		)

	func _upgrade_count(upgrade_id: String) -> int:
		return int(owned_upgrades.get(upgrade_id, 0))

	func _zone_anchor(offset: Vector2) -> Vector2:
		var center = _yarn_center()
		return center + Vector2(offset.x * _yarn_radius() * 1.44, offset.y * _yarn_radius() * 1.16)

	func _draw_mill_foundations(center: Vector2, melody_anchor: Vector2, percussion_anchor: Vector2, texture_anchor: Vector2, bass_anchor: Vector2, sand: Color, wood: Color, accent: Color, melody_total: int, percussion_total: int, texture_total: int, bass_total: int) -> void:
		var r = _yarn_radius()
		var hub_color = sand.lerp(wood, 0.20)
		var trim_color = wood.darkened(0.10)
		draw_arc(center, r * 1.18, 0.0, TAU, 64, trim_color.lerp(sand, 0.08), 6.0)
		draw_arc(center, r * 1.04, 0.0, TAU, 64, hub_color.lightened(0.08), 3.0)
		if melody_total > 0:
			_draw_mill_attachment(center, melody_anchor, 16.0, sand.lightened(0.08), wood, accent)
		if percussion_total > 0:
			_draw_mill_attachment(center, percussion_anchor, 16.0, sand.lightened(0.08), wood, accent)
		if texture_total > 0:
			_draw_mill_attachment(center, texture_anchor, 18.0, sand.lightened(0.08), wood, accent)
		if bass_total > 0:
			_draw_mill_attachment(center, bass_anchor, 22.0, sand.lightened(0.08), wood, accent)

	func _draw_mill_attachment(center: Vector2, anchor: Vector2, width: float, body: Color, trim: Color, accent: Color) -> void:
		var direction = (anchor - center).normalized()
		var start = center + direction * (_yarn_radius() * 1.08)
		var end = anchor - direction * 24.0
		draw_line(start, end, body, width)
		draw_line(start, end, trim.darkened(0.06), max(2.0, width * 0.24))
		var bridge_length = start.distance_to(end)
		var plank_count = maxi(2, int(bridge_length / 16.0))
		var cross = Vector2(-direction.y, direction.x)
		for plank_index in range(plank_count + 1):
			var t = float(plank_index) / float(plank_count)
			var plank_center = start.lerp(end, t)
			draw_line(
				plank_center - cross * (width * 0.28),
				plank_center + cross * (width * 0.28),
				trim.darkened(0.14),
				1.6
			)
		for post_center in [start, end]:
			draw_circle(post_center, width * 0.22, trim.darkened(0.10))
			draw_circle(post_center + Vector2(0, -1), width * 0.14, accent.lerp(body, 0.65))

	func _draw_building_shadow(rect: Rect2) -> void:
		draw_rounded_rect(Rect2(rect.position + Vector2(0, 6), rect.size), Color(0, 0, 0, 0.10), 10.0)

	func _draw_small_building(body_rect: Rect2, roof_color: Color, wall_color: Color, wood: Color, roof_height: float = 18.0) -> void:
		var shadow = Color(0, 0, 0, 0.10)
		draw_rounded_rect(Rect2(body_rect.position + Vector2(0, 5), body_rect.size), shadow, 8.0)
		draw_rounded_rect(body_rect, wall_color, 8.0)
		var roof = PackedVector2Array([
			body_rect.position + Vector2(-8, 2),
			body_rect.position + Vector2(body_rect.size.x * 0.5, -roof_height),
			body_rect.position + Vector2(body_rect.size.x + 8, 2),
			body_rect.position + Vector2(body_rect.size.x + 2, 10),
			body_rect.position + Vector2(2, 10)
		])
		draw_colored_polygon(roof, roof_color)
		draw_line(body_rect.position + Vector2(4, 9), body_rect.position + Vector2(body_rect.size.x - 4, 9), wood.darkened(0.16), 1.6)

	func _draw_mill_room(body_rect: Rect2, sand: Color, wood: Color, accent: Color, roof_height: float, window_offsets: Array, door_rect: Rect2 = Rect2()) -> void:
		_draw_building_shadow(body_rect)
		_draw_small_building(body_rect, accent.lerp(sand, 0.18), sand.lightened(0.08), wood, roof_height)
		draw_line(
			body_rect.position + Vector2(8, body_rect.size.y - 6),
			body_rect.position + Vector2(body_rect.size.x - 8, body_rect.size.y - 6),
			wood.darkened(0.12),
			2.0
		)
		for offset_value in window_offsets:
			var offset: Vector2 = offset_value
			_draw_window(
				body_rect.position + offset,
				Vector2(11, 12),
				wood.lightened(0.06),
				sand.lightened(0.18)
			)
		if door_rect.size.x > 0.0 and door_rect.size.y > 0.0:
			_draw_door(door_rect, wood.lightened(0.04), sand.darkened(0.02))

	func _draw_window(center: Vector2, size: Vector2, frame: Color, glow: Color) -> void:
		draw_rounded_rect(Rect2(center - size * 0.5, size), frame, 4.0)
		draw_rounded_rect(Rect2(center - size * 0.38, size * 0.76), glow, 3.0)
		draw_line(center + Vector2(0, -size.y * 0.30), center + Vector2(0, size.y * 0.30), frame.darkened(0.14), 1.2)
		draw_line(center + Vector2(-size.x * 0.30, 0), center + Vector2(size.x * 0.30, 0), frame.darkened(0.14), 1.2)

	func _draw_door(rect: Rect2, frame: Color, fill: Color) -> void:
		draw_rounded_rect(rect, frame, 6.0)
		draw_rounded_rect(rect.grow(-3.0), fill, 4.0)
		draw_circle(rect.position + Vector2(rect.size.x - 6.0, rect.size.y * 0.52), 1.6, frame.darkened(0.18))

	func _draw_foliage_tuft(center: Vector2, leaf: Color, flower: Color, scale: float) -> void:
		var leaf_a = leaf.lightened(0.04)
		var leaf_b = leaf.darkened(0.06)
		draw_circle(center + Vector2(-8, 2) * scale, 9.0 * scale, leaf_a)
		draw_circle(center + Vector2(0, -4) * scale, 11.0 * scale, leaf_b)
		draw_circle(center + Vector2(8, 3) * scale, 8.0 * scale, leaf_a)
		for bloom_offset in [Vector2(-6, -4), Vector2(3, -8), Vector2(8, 1)]:
			draw_circle(center + bloom_offset * scale, 2.4 * scale, flower.lightened(0.08))

	func _draw_zone_aura(anchor: Vector2, intensity: int, accent: Color, zone: String) -> void:
		if intensity <= 0:
			return
		var aura = accent.lightened(0.18)
		match zone:
			"percussion":
				aura = accent.lerp(Color("#ffd27a"), 0.35)
			"texture":
				aura = accent.lightened(0.28)
			"bass":
				aura = accent.darkened(0.04)
		aura.a = 0.05 + intensity * 0.025
		draw_circle(anchor + Vector2(0, 8), 16.0 + intensity * 7.0, aura)
		for ring_index in range(intensity):
			var ring_color = aura
			ring_color.a *= 0.55 - ring_index * 0.10
			var ring_radius = 18.0 + ring_index * 8.0 + sin(pulse * (1.2 + ring_index * 0.2)) * 1.6
			draw_arc(anchor, ring_radius, 0.0, TAU, 28, ring_color, 1.2)

	func _draw_melody_nook(anchor: Vector2, kitten_count: int, house_cat_count: int, kitten_icon: Texture2D, house_cat_icon: Texture2D, sand: Color, wood: Color, accent: Color, ink: Color) -> void:
		var total = kitten_count + house_cat_count
		if total <= 0:
			return
		if kitten_count > 0:
			_draw_island_upgrade_icon(kitten_icon, anchor + Vector2(-18, 6), 40.0, 13.0)
			if kitten_count > 1:
				_draw_island_upgrade_icon(kitten_icon, anchor + Vector2(-34, 22), 26.0, 9.0)
			if kitten_count > 2:
				_draw_island_upgrade_icon(kitten_icon, anchor + Vector2(-4, 25), 24.0, 8.0)
			if kitten_count > 3:
				_draw_island_upgrade_icon(kitten_icon, anchor + Vector2(-24, 32), 22.0, 7.0)
		if house_cat_count > 0:
			_draw_island_upgrade_icon(house_cat_icon, anchor + Vector2(24, -6), 46.0, 15.0)
			if house_cat_count > 1:
				_draw_island_upgrade_icon(house_cat_icon, anchor + Vector2(30, 22), 28.0, 9.0)
			if house_cat_count > 2:
				_draw_island_upgrade_icon(house_cat_icon, anchor + Vector2(12, 30), 24.0, 8.0)
		var melody_notes = mini(kitten_count + house_cat_count, 5)
		for note_index in range(melody_notes):
			var note_center = anchor + Vector2(-18.0 + note_index * 9.0, -20.0 - (note_index % 2) * 4.0)
			draw_circle(note_center, 3.4, accent.lightened(0.18))
			draw_line(note_center + Vector2(2.8, 0), note_center + Vector2(2.8, -8.0), ink, 1.2)

	func _draw_percussion_deck(anchor: Vector2, scratching_post_count: int, icon_texture: Texture2D, sand: Color, wood: Color, accent: Color) -> void:
		if scratching_post_count <= 0:
			return
		_draw_island_upgrade_icon(icon_texture, anchor + Vector2(0, 4), 52.0, 16.0)
		if scratching_post_count > 1:
			_draw_island_upgrade_icon(icon_texture, anchor + Vector2(-22, 22), 30.0, 10.0)
		if scratching_post_count > 2:
			_draw_island_upgrade_icon(icon_texture, anchor + Vector2(24, 20), 28.0, 9.0)
		if scratching_post_count > 3:
			_draw_island_upgrade_icon(icon_texture, anchor + Vector2(0, 28), 24.0, 8.0)

	func _draw_texture_corner(anchor: Vector2, yarn_basket_count: int, cat_choir_count: int, basket_icon: Texture2D, choir_icon: Texture2D, sand: Color, wood: Color, accent: Color) -> void:
		var total = yarn_basket_count + cat_choir_count
		if total <= 0:
			return
		if yarn_basket_count > 0:
			_draw_island_upgrade_icon(basket_icon, anchor + Vector2(-10, 4), 62.0, 18.0)
			if yarn_basket_count > 1:
				_draw_island_upgrade_icon(basket_icon, anchor + Vector2(-26, 28), 32.0, 10.0)
			if yarn_basket_count > 2:
				_draw_island_upgrade_icon(basket_icon, anchor + Vector2(10, 30), 28.0, 9.0)
		if cat_choir_count > 0:
			_draw_island_upgrade_icon(choir_icon, anchor + Vector2(28, -2), 44.0, 14.0)
			if cat_choir_count > 1:
				_draw_island_upgrade_icon(choir_icon, anchor + Vector2(30, 24), 28.0, 9.0)

	func _draw_bass_terrace(anchor: Vector2, cat_tower_count: int, grand_meowstro_count: int, tower_icon: Texture2D, meowstro_icon: Texture2D, sand: Color, wood: Color, accent: Color, highlight: Color) -> void:
		var total = cat_tower_count + grand_meowstro_count
		if total <= 0:
			return
		if cat_tower_count > 0:
			_draw_island_upgrade_icon(tower_icon, anchor + Vector2(-8, -2), 70.0, 20.0)
			if cat_tower_count > 1:
				_draw_island_upgrade_icon(tower_icon, anchor + Vector2(-34, 24), 34.0, 10.0)
			if cat_tower_count > 2:
				_draw_island_upgrade_icon(tower_icon, anchor + Vector2(16, 26), 30.0, 9.0)
		if grand_meowstro_count > 0:
			_draw_island_upgrade_icon(meowstro_icon, anchor + Vector2(34, -4), 46.0, 14.0)

	func _draw_island_upgrade_icon(icon_texture: Texture2D, center: Vector2, size_value: float, shadow_radius: float) -> void:
		if icon_texture == null:
			return
		draw_circle(center + Vector2(0, shadow_radius * 0.72), shadow_radius, Color(0, 0, 0, 0.10))
		_draw_upgrade_icon_texture(icon_texture, center, size_value)

	func _draw_upgrade_icon_texture(icon_texture: Texture2D, center: Vector2, size_value: float) -> void:
		if icon_texture == null:
			return
		draw_texture_rect(icon_texture, Rect2(center - Vector2.ONE * size_value * 0.5, Vector2.ONE * size_value), false)

	func _draw_paw_print(center: Vector2, scale: float, color: Color) -> void:
		draw_circle(center + Vector2(0, 3) * scale, 3.8 * scale, color)
		draw_circle(center + Vector2(-3.0, -2.2) * scale, 1.7 * scale, color)
		draw_circle(center + Vector2(0, -3.0) * scale, 1.6 * scale, color)
		draw_circle(center + Vector2(3.0, -2.0) * scale, 1.7 * scale, color)

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
	var scene_upgrade_lanes = {}
	var scene_upgrade_types = {}
	for upgrade in game_state.get_mill_definition(current_mill_id).get("upgrades", []):
		scene_upgrade_order.append(String(upgrade.get("id", "")))
		scene_upgrade_lanes[String(upgrade.get("id", ""))] = String(upgrade.get("lane", "melody"))
		scene_upgrade_types[String(upgrade.get("id", ""))] = String(upgrade.get("type", "common"))
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
		"upgrade_lanes": scene_upgrade_lanes,
		"upgrade_types": scene_upgrade_types,
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
