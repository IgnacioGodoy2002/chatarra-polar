extends Node2D

var last_heat: float = -1.0
var flash_timer: float = 0.0
var flash_duration: float = 0.65

var cold_pulse_time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	position = Vector2.ZERO
	z_index = 1000
	visible = true
	queue_redraw()


func _process(delta: float) -> void:
	position = Vector2.ZERO
	cold_pulse_time += delta

	var current_heat: float = get_current_heat()
	var heat_drop: float = 0.0

	if last_heat >= 0.0:
		heat_drop = last_heat - current_heat

	if heat_drop >= 6.0:
		flash_timer = flash_duration

	last_heat = current_heat

	if flash_timer > 0.0:
		flash_timer -= delta

	queue_redraw()


func _draw() -> void:
	if should_hide_overlay():
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var heat: float = get_current_heat()
	var max_heat: float = get_max_heat()

	draw_low_heat_overlay(viewport_size, heat, max_heat)
	draw_frost_corners(viewport_size, heat, max_heat)
	draw_damage_flash(viewport_size)

	if is_player_frozen():
		draw_frozen_screen(viewport_size)


func should_hide_overlay() -> bool:
	var canvas_layer: Node = get_parent()

	if canvas_layer == null:
		return false

	var story_intro: Node = canvas_layer.get_node_or_null("StoryIntro")
	var demo_overlay: Node = canvas_layer.get_node_or_null("DemoCompleteOverlay")
	var pause_menu: Node = canvas_layer.get_node_or_null("PauseMenu")

	if story_intro != null and story_intro.visible:
		return true

	if demo_overlay != null and demo_overlay.visible:
		return true

	if pause_menu != null and pause_menu.visible:
		return true

	return false


func get_current_heat() -> float:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 100.0

	var value = main_scene.get("heat")

	if value == null:
		return 100.0

	return float(value)


func get_max_heat() -> float:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 100.0

	var value = main_scene.get("max_heat")

	if value == null:
		return 100.0

	return float(value)


func is_player_frozen() -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get("is_frozen")

	if value == null:
		return false

	return bool(value)


func draw_damage_flash(viewport_size: Vector2) -> void:
	if flash_timer <= 0.0:
		return

	var alpha: float = clamp(flash_timer / flash_duration, 0.0, 1.0)

	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.90, 0.05, 0.02, 0.25 * alpha)
	)

	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.55, 0.90, 1.0, 0.18 * alpha)
	)

	draw_screen_border(
		viewport_size,
		Color(1.0, 0.18, 0.08, 0.75 * alpha),
		16.0
	)

	draw_screen_border(
		viewport_size,
		Color(0.75, 0.95, 1.0, 0.45 * alpha),
		26.0
	)


func draw_low_heat_overlay(viewport_size: Vector2, heat: float, max_heat: float) -> void:
	if max_heat <= 0.0:
		return

	var heat_percent: float = heat / max_heat

	if heat_percent > 0.60:
		return

	var danger_alpha: float = clamp((0.60 - heat_percent) / 0.60, 0.0, 1.0)
	var pulse: float = 0.65 + sin(cold_pulse_time * 5.0) * 0.35

	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.40, 0.85, 1.0, 0.12 * danger_alpha * pulse)
	)

	draw_screen_border(
		viewport_size,
		Color(0.70, 0.94, 1.0, 0.48 * danger_alpha),
		22.0
	)


func draw_frost_corners(viewport_size: Vector2, heat: float, max_heat: float) -> void:
	if max_heat <= 0.0:
		return

	var heat_percent: float = heat / max_heat

	if heat_percent > 0.65:
		return

	var frost_alpha: float = clamp((0.65 - heat_percent) / 0.65, 0.0, 1.0)

	draw_corner_frost(Vector2(0, 0), Vector2(1, 1), frost_alpha)
	draw_corner_frost(Vector2(viewport_size.x, 0), Vector2(-1, 1), frost_alpha)
	draw_corner_frost(Vector2(0, viewport_size.y), Vector2(1, -1), frost_alpha)
	draw_corner_frost(Vector2(viewport_size.x, viewport_size.y), Vector2(-1, -1), frost_alpha)


func draw_corner_frost(corner: Vector2, direction: Vector2, alpha: float) -> void:
	for i in range(10):
		var length: float = 46.0 + float(i) * 15.0
		var offset: float = float(i) * 15.0

		var start_a: Vector2 = corner + Vector2(direction.x * offset, 0)
		var end_a: Vector2 = start_a + Vector2(direction.x * length, direction.y * length * 0.35)

		draw_line(
			start_a,
			end_a,
			Color(0.82, 0.96, 1.0, 0.30 * alpha),
			4
		)

		var start_b: Vector2 = corner + Vector2(0, direction.y * offset)
		var end_b: Vector2 = start_b + Vector2(direction.x * length * 0.35, direction.y * length)

		draw_line(
			start_b,
			end_b,
			Color(0.82, 0.96, 1.0, 0.26 * alpha),
			4
		)


func draw_frozen_screen(viewport_size: Vector2) -> void:
	var pulse: float = 0.65 + sin(cold_pulse_time * 4.0) * 0.35

	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.02, 0.08, 0.13, 0.72)
	)

	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.55, 0.90, 1.0, 0.18 + pulse * 0.08)
	)

	draw_screen_border(
		viewport_size,
		Color(0.75, 0.96, 1.0, 0.85),
		34.0
	)

	draw_big_frost(viewport_size)
	draw_frozen_panel(viewport_size)
	draw_frozen_penguin(viewport_size)


func draw_big_frost(viewport_size: Vector2) -> void:
	for i in range(18):
		var x: float = float(i) * viewport_size.x / 17.0

		draw_line(
			Vector2(x, 0),
			Vector2(x - 80.0, 120.0),
			Color(0.85, 0.98, 1.0, 0.18),
			5
		)

		draw_line(
			Vector2(x, viewport_size.y),
			Vector2(x + 80.0, viewport_size.y - 120.0),
			Color(0.85, 0.98, 1.0, 0.18),
			5
		)


func draw_frozen_panel(viewport_size: Vector2) -> void:
	var panel_size: Vector2 = Vector2(620, 290)
	var panel_pos: Vector2 = viewport_size / 2.0 - panel_size / 2.0

	draw_rect(
		Rect2(panel_pos + Vector2(8, 8), panel_size),
		Color(0.0, 0.0, 0.0, 0.38)
	)

	draw_rect(
		Rect2(panel_pos, panel_size),
		Color(0.02, 0.04, 0.06, 0.95)
	)

	draw_rect(
		Rect2(panel_pos + Vector2(8, 8), panel_size - Vector2(16, 16)),
		Color(0.08, 0.15, 0.19, 0.94)
	)

	draw_line(
		panel_pos + Vector2(24, panel_size.y - 22),
		panel_pos + Vector2(panel_size.x - 24, panel_size.y - 22),
		Color(0.75, 0.95, 1.0, 1.0),
		4
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, viewport_size.y / 2.0 - 72),
		"TE CONGELASTE",
		HORIZONTAL_ALIGNMENT_CENTER,
		viewport_size.x,
		46,
		Color(0.82, 0.98, 1.0, 1.0)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, viewport_size.y / 2.0 - 18),
		"El frío venció a Chispa.",
		HORIZONTAL_ALIGNMENT_CENTER,
		viewport_size.x,
		24,
		Color(0.92, 0.98, 1.0, 0.95)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, viewport_size.y / 2.0 + 42),
		"Presioná R para empezar de cero",
		HORIZONTAL_ALIGNMENT_CENTER,
		viewport_size.x,
		22,
		Color(1.0, 0.88, 0.45, 1.0)
	)


func draw_frozen_penguin(viewport_size: Vector2) -> void:
	var center: Vector2 = Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0 + 112.0)

	draw_circle(center + Vector2(0, 4), 34, Color(0.02, 0.03, 0.04, 1.0))
	draw_circle(center + Vector2(0, 13), 23, Color(0.88, 0.96, 1.0, 1.0))
	draw_circle(center + Vector2(0, -22), 24, Color(0.02, 0.03, 0.04, 1.0))

	draw_line(center + Vector2(-12, -25), center + Vector2(-5, -25), Color(0.85, 0.98, 1.0, 1.0), 3)
	draw_line(center + Vector2(5, -25), center + Vector2(12, -25), Color(0.85, 0.98, 1.0, 1.0), 3)

	var beak := PackedVector2Array([
		center + Vector2(-8, -14),
		center + Vector2(8, -14),
		center + Vector2(0, -5)
	])

	draw_polygon(beak, PackedColorArray([
		Color(0.85, 0.55, 0.25, 1.0),
		Color(0.85, 0.55, 0.25, 1.0),
		Color(0.85, 0.55, 0.25, 1.0)
	]))

	draw_circle(center, 48, Color(0.65, 0.92, 1.0, 0.15))


func draw_screen_border(viewport_size: Vector2, color: Color, thickness: float) -> void:
	draw_rect(
		Rect2(Vector2.ZERO, Vector2(viewport_size.x, thickness)),
		color
	)

	draw_rect(
		Rect2(Vector2(0, viewport_size.y - thickness), Vector2(viewport_size.x, thickness)),
		color
	)

	draw_rect(
		Rect2(Vector2.ZERO, Vector2(thickness, viewport_size.y)),
		color
	)

	draw_rect(
		Rect2(Vector2(viewport_size.x - thickness, 0), Vector2(thickness, viewport_size.y)),
		color
	)
