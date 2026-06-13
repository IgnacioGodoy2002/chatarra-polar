extends Node2D

var flakes: Array[Dictionary] = []
var flake_count: int = 95
var wind_time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	create_flakes()
	queue_redraw()


func create_flakes() -> void:
	flakes.clear()

	var viewport_size: Vector2 = get_viewport_rect().size

	for i in range(flake_count):
		var flake: Dictionary = {
			"position": Vector2(
				randf_range(0.0, viewport_size.x),
				randf_range(0.0, viewport_size.y)
			),
			"speed": randf_range(35.0, 95.0),
			"size": randf_range(1.5, 4.0),
			"alpha": randf_range(0.25, 0.75),
			"drift": randf_range(-18.0, 18.0)
		}

		flakes.append(flake)


func _process(delta: float) -> void:
	wind_time += delta

	var viewport_size: Vector2 = get_viewport_rect().size
	var storm_active: bool = is_storm_active()

	for i in range(flakes.size()):
		var flake: Dictionary = flakes[i]

		var flake_pos: Vector2 = flake["position"]
		var speed: float = flake["speed"]
		var drift: float = flake["drift"]

		var wind_strength: float = 25.0 + sin(wind_time * 1.4) * 12.0
		var fall_multiplier: float = 1.0

		if storm_active:
			wind_strength = 155.0 + sin(wind_time * 3.0) * 45.0
			fall_multiplier = 2.4

		flake_pos.y += speed * fall_multiplier * delta
		flake_pos.x += (drift + wind_strength) * delta

		if flake_pos.y > viewport_size.y + 20.0:
			flake_pos.y = -20.0
			flake_pos.x = randf_range(-80.0, viewport_size.x)

		if flake_pos.x > viewport_size.x + 80.0:
			flake_pos.x = -80.0

		if flake_pos.x < -100.0:
			flake_pos.x = viewport_size.x + 80.0

		flake["position"] = flake_pos
		flakes[i] = flake

	queue_redraw()


func is_storm_active() -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	if not ("is_storm" in main_scene):
		return false

	return bool(main_scene.is_storm)


func _draw() -> void:
	var storm_active: bool = is_storm_active()

	if storm_active:
		draw_storm_haze()

	for flake in flakes:
		draw_flake(flake, storm_active)


func draw_flake(flake: Dictionary, storm_active: bool) -> void:
	var flake_pos: Vector2 = flake["position"]
	var size: float = flake["size"]
	var alpha: float = flake["alpha"]

	if storm_active:
		draw_line(
			flake_pos,
			flake_pos + Vector2(-28, 12),
			Color(1.0, 1.0, 1.0, alpha * 0.75),
			size
		)
	else:
		draw_circle(
			flake_pos,
			size,
			Color(1.0, 1.0, 1.0, alpha)
		)


func draw_storm_haze() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.82, 0.94, 1.0, 0.09)
	)

	for i in range(8):
		var y: float = float(i) * 90.0 + fmod(wind_time * 60.0, 90.0)

		draw_line(
			Vector2(-100, y),
			Vector2(viewport_size.x + 100, y - 65.0),
			Color(1.0, 1.0, 1.0, 0.08),
			18
		)
