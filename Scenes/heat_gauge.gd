extends Node2D

var gauge_size: Vector2 = Vector2(250, 54)
var animation_time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 850
	position = Vector2(35, 182)
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	position = Vector2(35, 182)
	queue_redraw()


func _draw() -> void:
	if should_hide():
		return

	draw_panel()
	draw_heat_bar()
	draw_status_icons()


func should_hide() -> bool:
	if get_tree().paused:
		return true

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


func draw_panel() -> void:
	draw_rect(
		Rect2(Vector2(3, 3), gauge_size),
		Color(0.0, 0.0, 0.0, 0.24)
	)

	draw_rect(
		Rect2(Vector2.ZERO, gauge_size),
		Color(0.03, 0.04, 0.05, 0.84)
	)

	draw_rect(
		Rect2(Vector2(5, 5), gauge_size - Vector2(10, 10)),
		Color(0.08, 0.10, 0.12, 0.80)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 18),
		"CALOR",
		HORIZONTAL_ALIGNMENT_LEFT,
		90,
		14,
		Color(1.0, 0.88, 0.48, 0.95)
	)


func draw_heat_bar() -> void:
	var heat: float = get_current_heat()
	var max_heat: float = get_max_heat()

	if max_heat <= 0.0:
		max_heat = 100.0

	var heat_percent: float = clamp(heat / max_heat, 0.0, 1.0)

	var bar_pos: Vector2 = Vector2(12, 27)
	var bar_size: Vector2 = Vector2(160, 14)

	var bar_color: Color = get_heat_color(heat_percent)
	var pulse: float = 0.55 + sin(animation_time * 6.0) * 0.45

	draw_rect(
		Rect2(bar_pos, bar_size),
		Color(0.02, 0.02, 0.025, 1.0)
	)

	draw_rect(
		Rect2(bar_pos + Vector2(2, 2), bar_size - Vector2(4, 4)),
		Color(0.12, 0.15, 0.17, 1.0)
	)

	draw_rect(
		Rect2(bar_pos + Vector2(2, 2), Vector2((bar_size.x - 4.0) * heat_percent, bar_size.y - 4.0)),
		bar_color
	)

	if heat_percent <= 0.35:
		draw_rect(
			Rect2(bar_pos, bar_size),
			Color(0.75, 0.95, 1.0, 0.16 * pulse),
			false,
			2
		)

	if is_storm_active():
		draw_rect(
			Rect2(bar_pos, bar_size),
			Color(0.80, 0.95, 1.0, 0.22 * pulse),
			false,
			2
		)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(182, 40),
		str(int(heat)) + "%",
		HORIZONTAL_ALIGNMENT_LEFT,
		50,
		16,
		Color(0.90, 0.98, 1.0, 1.0)
	)


func draw_status_icons() -> void:
	var icon_x: float = 214.0
	var icon_y: float = 18.0

	if is_in_base():
		draw_base_icon(Vector2(icon_x, icon_y))
	elif is_storm_active():
		draw_storm_icon(Vector2(icon_x, icon_y))
	else:
		draw_cold_icon(Vector2(icon_x, icon_y))


func draw_base_icon(center: Vector2) -> void:
	var pulse: float = 0.5 + sin(animation_time * 4.0) * 0.5

	draw_circle(center, 11, Color(1.0, 0.58, 0.15, 0.14 + pulse * 0.08))
	draw_circle(center, 7, Color(1.0, 0.48, 0.10, 1.0))

	var flame := PackedVector2Array([
		center + Vector2(0, -8),
		center + Vector2(-5, 2),
		center + Vector2(0, 8),
		center + Vector2(5, 2)
	])

	draw_polygon(flame, PackedColorArray([
		Color(1.0, 0.80, 0.25, 1.0),
		Color(1.0, 0.42, 0.05, 1.0),
		Color(1.0, 0.25, 0.02, 1.0),
		Color(1.0, 0.42, 0.05, 1.0)
	]))


func draw_storm_icon(center: Vector2) -> void:
	var pulse: float = 0.5 + sin(animation_time * 7.0) * 0.5

	draw_circle(center, 12, Color(0.70, 0.92, 1.0, 0.14 + pulse * 0.08))

	for i in range(3):
		var y: float = -6.0 + float(i) * 5.0

		draw_line(
			center + Vector2(-8, y),
			center + Vector2(8, y - 4),
			Color(0.80, 0.96, 1.0, 0.75),
			2
		)


func draw_cold_icon(center: Vector2) -> void:
	draw_circle(center, 10, Color(0.55, 0.88, 1.0, 0.14))
	draw_circle(center, 3, Color(0.80, 0.96, 1.0, 1.0))

	for i in range(6):
		var angle: float = TAU * float(i) / 6.0
		var direction: Vector2 = Vector2(cos(angle), sin(angle))

		draw_line(
			center,
			center + direction * 8.5,
			Color(0.80, 0.96, 1.0, 0.90),
			1.6
		)


func get_heat_color(heat_percent: float) -> Color:
	if heat_percent > 0.65:
		return Color(1.0, 0.62, 0.18, 1.0)

	if heat_percent > 0.35:
		return Color(1.0, 0.82, 0.25, 1.0)

	return Color(0.50, 0.90, 1.0, 1.0)


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


func is_storm_active() -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get("is_storm")

	if value == null:
		return false

	return bool(value)


func is_in_base() -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get("is_in_base")

	if value == null:
		return false

	return bool(value)
