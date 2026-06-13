extends Node

var pickup_player: AudioStreamPlayer
var base_player: AudioStreamPlayer
var storm_player: AudioStreamPlayer
var damage_player: AudioStreamPlayer
var upgrade_player: AudioStreamPlayer

var wind_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

var wind_normal_volume_db: float = -24.0
var wind_storm_volume_db: float = -10.0
var music_volume_db: float = -28.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	pickup_player = create_player()
	base_player = create_player()
	storm_player = create_player()
	damage_player = create_player()
	upgrade_player = create_player()

	wind_player = create_player()
	music_player = create_player()

	start_wind()
	start_music()


func _process(_delta: float) -> void:
	update_wind_volume()


func create_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	add_child(player)
	return player


func play_pickup() -> void:
	play_tone(pickup_player, 880.0, 0.08, 0.35)


func play_base_deposit() -> void:
	play_tone(base_player, 520.0, 0.12, 0.35)


func play_storm() -> void:
	play_tone(storm_player, 160.0, 0.35, 0.30)


func play_damage() -> void:
	play_tone(damage_player, 120.0, 0.18, 0.45)


func play_upgrade() -> void:
	play_tone(upgrade_player, 980.0, 0.20, 0.40)


func play_tone(player: AudioStreamPlayer, frequency: float, duration: float, volume: float) -> void:
	if player == null:
		return

	var sample_rate: int = 44100
	var sample_count: int = int(sample_rate * duration)
	var data := PackedByteArray()

	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)

		var fade_in: float = clamp(t / 0.02, 0.0, 1.0)
		var fade_out: float = clamp((duration - t) / 0.04, 0.0, 1.0)
		var envelope: float = min(fade_in, fade_out)

		var wave: float = sin(TAU * frequency * t)
		var sample: int = int(128.0 + wave * 90.0 * volume * envelope)

		sample = clamp(sample, 0, 255)
		data.append(sample)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data

	player.stream = stream
	player.play()


func start_wind() -> void:
	if wind_player == null:
		return

	wind_player.stream = create_wind_stream()
	wind_player.volume_db = wind_normal_volume_db
	wind_player.play()


func start_music() -> void:
	if music_player == null:
		return

	music_player.stream = create_music_stream()
	music_player.volume_db = music_volume_db
	music_player.play()


func update_wind_volume() -> void:
	if wind_player == null:
		return

	var main_scene: Node = get_tree().current_scene
	var target_volume: float = wind_normal_volume_db

	if main_scene != null and "is_storm" in main_scene:
		if bool(main_scene.is_storm):
			target_volume = wind_storm_volume_db

	wind_player.volume_db = lerp(wind_player.volume_db, target_volume, 0.04)


func create_wind_stream() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duration: float = 3.0
	var sample_count: int = int(sample_rate * duration)
	var data := PackedByteArray()

	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)

		var slow_wave: float = sin(TAU * 0.55 * t)
		var mid_wave: float = sin(TAU * 1.35 * t)
		var hiss: float = randf_range(-1.0, 1.0)

		var wind: float = slow_wave * 0.45 + mid_wave * 0.25 + hiss * 0.30
		var sample: int = int(128.0 + wind * 34.0)

		sample = clamp(sample, 0, 255)
		data.append(sample)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count

	return stream


func create_music_stream() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duration: float = 8.0
	var sample_count: int = int(sample_rate * duration)
	var data := PackedByteArray()

	var notes: Array[float] = [
		220.0,
		261.63,
		293.66,
		329.63,
		261.63,
		220.0,
		196.0,
		220.0
	]

	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)

		var note_index: int = int(t) % notes.size()
		var freq: float = notes[note_index]

		var wave1: float = sin(TAU * freq * t)
		var wave2: float = sin(TAU * (freq * 0.5) * t)
		var shimmer: float = sin(TAU * (freq * 2.0) * t) * 0.15

		var envelope: float = 0.45 + sin(TAU * 0.25 * t) * 0.20
		var final_wave: float = (wave1 * 0.35 + wave2 * 0.45 + shimmer) * envelope

		var sample: int = int(128.0 + final_wave * 32.0)

		sample = clamp(sample, 0, 255)
		data.append(sample)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count

	return stream
