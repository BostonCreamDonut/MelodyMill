extends Node
class_name AudioConductor

const LANE_ORDER = ["percussion", "melody", "bass", "texture"]

var bpm = 96.0
var enabled = true
var lane_intensity = {
	"percussion": 0,
	"melody": 0,
	"bass": 0,
	"texture": 0
}
var lane_volume = {
	"percussion": 0.9,
	"melody": 0.8,
	"bass": 0.75,
	"texture": 0.65
}
var lane_players = {}
var click_player: AudioStreamPlayer
var step_timer: Timer
var step_index = 0
var stream_cache = {}
var lane_patterns = {
	"percussion": [
		[48, -1, 48, -1, 48, -1, 50, -1, 48, -1, 48, -1, 51, -1, 50, -1],
		[48, -1, 50, -1, 48, 50, -1, -1, 48, -1, 50, -1, 51, -1, 48, -1],
		[48, -1, 48, 50, 48, -1, 50, -1, 48, 51, 48, -1, 50, -1, 48, -1],
		[48, 50, -1, 48, -1, 50, 48, -1, 51, -1, 48, 50, -1, 48, 50, -1]
	],
	"melody": [
		[72, -1, 74, -1, 76, -1, 79, -1, 76, -1, 74, -1, 72, -1, 69, -1],
		[72, -1, 76, -1, 79, -1, 76, -1, 74, -1, 72, -1, 67, -1, 69, -1],
		[76, -1, 79, -1, 81, -1, 79, -1, 76, -1, 74, -1, 72, -1, 74, -1],
		[79, -1, 76, -1, 74, -1, 72, -1, 74, -1, 76, -1, 79, -1, 81, -1]
	],
	"bass": [
		[48, -1, -1, -1, 48, -1, -1, -1, 50, -1, -1, -1, 43, -1, -1, -1],
		[48, -1, -1, -1, 55, -1, -1, -1, 50, -1, -1, -1, 43, -1, -1, -1],
		[48, -1, 48, -1, 50, -1, 43, -1, 48, -1, 55, -1, 50, -1, 43, -1]
	],
	"texture": [
		[60, -1, -1, -1, -1, -1, 67, -1, -1, -1, -1, -1, 64, -1, -1, -1],
		[64, -1, -1, -1, -1, -1, 69, -1, -1, -1, -1, -1, 67, -1, -1, -1],
		[67, -1, -1, -1, -1, -1, 72, -1, -1, -1, -1, -1, 69, -1, -1, -1]
	]
}


func _ready() -> void:
	_create_players()
	_prepare_click_stream()
	step_timer = Timer.new()
	step_timer.wait_time = 60.0 / bpm / 2.0
	step_timer.autostart = true
	step_timer.timeout.connect(_on_step)
	add_child(step_timer)


func set_enabled(value: bool) -> void:
	enabled = value


func set_lane_intensities(intensities: Dictionary) -> void:
	for lane in LANE_ORDER:
		lane_intensity[lane] = int(clamp(int(intensities.get(lane, 0)), 0, 3))


func get_lane_intensities() -> Dictionary:
	return lane_intensity.duplicate()


func set_lane_volume(lane: String, value: float) -> void:
	lane_volume[lane] = clamp(value, 0.0, 1.0)
	var player: AudioStreamPlayer = lane_players.get(lane)
	if player != null:
		player.volume_db = _linear_to_db(lane_volume[lane])


func play_click() -> void:
	if not enabled:
		return
	click_player.play()


func _on_step() -> void:
	if not enabled:
		return

	for lane in LANE_ORDER:
		var intensity = int(lane_intensity.get(lane, 0))
		if intensity <= 0:
			continue

		var patterns: Array = lane_patterns.get(lane, [])
		if patterns.is_empty():
			continue

		var available_patterns = max(1, min(patterns.size(), intensity + 1))
		var pattern = patterns[int(step_index / 16) % available_patterns]
		var note = int(pattern[step_index % pattern.size()])
		if note >= 0:
			_play_lane_note(lane, note)

	step_index += 1


func _play_lane_note(lane: String, midi_note: int) -> void:
	var player: AudioStreamPlayer = lane_players.get(lane)
	if player == null:
		return

	var cache_key = "%s:%s" % [lane, midi_note]
	if not stream_cache.has(cache_key):
		stream_cache[cache_key] = _generate_stream_for_lane(lane, midi_note)

	player.stream = stream_cache[cache_key]
	player.volume_db = _linear_to_db(float(lane_volume.get(lane, 0.7)))
	player.play()


func _create_players() -> void:
	for lane in LANE_ORDER:
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		lane_players[lane] = player

	click_player = AudioStreamPlayer.new()
	click_player.bus = "Master"
	add_child(click_player)


func _prepare_click_stream() -> void:
	click_player.stream = _generate_tone_stream(880.0, 0.08, "square", 0.18)


func _generate_stream_for_lane(lane: String, midi_note: int) -> AudioStreamWAV:
	var frequency = 440.0 * pow(2.0, (midi_note - 69.0) / 12.0)
	match lane:
		"percussion":
			return _generate_tone_stream(frequency, 0.09, "square", 0.18)
		"melody":
			return _generate_tone_stream(frequency, 0.18, "triangle", 0.20)
		"bass":
			return _generate_tone_stream(frequency / 2.0, 0.28, "sine", 0.24)
		_:
			return _generate_tone_stream(frequency, 0.34, "sine", 0.14)


func _generate_tone_stream(freq: float, duration: float, waveform: String, volume: float) -> AudioStreamWAV:
	var sample_rate = 44100
	var frame_count = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(frame_count * 2)

	for i in frame_count:
		var t = float(i) / sample_rate
		var envelope = 1.0 - (float(i) / max(1.0, float(frame_count)))
		envelope = pow(envelope, 1.4)
		var phase = TAU * freq * t
		var raw = 0.0
		match waveform:
			"square":
				raw = 1.0 if sin(phase) >= 0.0 else -1.0
			"triangle":
				raw = (2.0 / PI) * asin(sin(phase))
			_:
				raw = sin(phase)

		var sample_value = clamp(raw * envelope * volume, -1.0, 1.0)
		var sample_int = int(sample_value * 32767.0)
		bytes[i * 2] = sample_int & 0xFF
		bytes[i * 2 + 1] = (sample_int >> 8) & 0xFF

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _linear_to_db(value: float) -> float:
	if value <= 0.001:
		return -60.0
	return 20.0 * (log(value) / log(10.0))
