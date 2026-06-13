extends Node2D

var previous_zone: String = ""
var current_zone: String = ""

var warning_timer: float = 0.0
var warning_duration: float = 3.0
var animation_time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 950
	visible = true
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta

	current_zone = get_current_zone()

	if current_zone != previous_zone:
		if current_zone == "Zona peligrosa":
			show_warning()

		previous_zone = current_zone

	if warning_timer > 0.0:
		warning_timer -= delta

	queue_redraw()


func show_warning() -> void:
	warning_timer = warning_duration

	var main_scene: Node = get_tree().current_scene

	if main_scene != null and main_scene.has_method("play_sound"):
		main_scene.play_sound("storm")


func get_current_zone() -> String:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return ""

	var zone_system: Node = main_scene.get_node_or_null("ZoneSystem")

	if zone_system == null:
		return ""

	var value = zone_system.get("current_zone")

	if value == null:
		return ""

	return str(value)


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


func _draw() -> void:
	if should_hide():
		return

	if warning_timer > 0.0:
		draw_big_warning()

	if current_zone == "Zona peligrosa":
		draw_small_danger_indicator()


func draw_big_warning() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var alpha: float = clamp(warning_timer / 0.35, 0.0, 1.0)
	var pulse: float = 0.65 + sin(animation_time * 8.0) * 0.35

	var panel_size: Vector2 = Vector2(620, 145)
	var panel_pos: Vector2 = Vector2(
		viewport_size.x / 2.0 - panel_size.x / 2.0,
		viewport_size.y * 0.18
	)

	draw_rect(
		Rect2(panel_pos + Vector2(7, 7), panel_size),
		Color(0.0, 0.0, 0.0, 0.38 * alpha)
	)

	draw_rect(
		Rect2(panel_pos, panel_size),
		Color(0.07, 0.02, 0.02, 0.94 * alpha)
	)

	draw_rect(
		Rect2(panel_pos + Vector2(8, 8), panel_size - Vector2(16, 16)),
		Color(0.16, 0.05, 0.04, 0.92 * alpha)
	)

	draw_rect(
		Rect2(panel_pos, panel_size),
		Color(1.0, 0.18, 0.08, 0.18 * pulse * alpha),
		false,
		5
	)

	draw_warning_icon(panel_pos + Vector2(65, 72), alpha)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(125, 52),
		"ZONA PELIGROSA",
		HORIZONTAL_ALIGNMENT_LEFT,
		450,
		34,
		Color(1.0, 0.75, 0.45, alpha)
	)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(125, 86),
		"Frío extremo detectado",
		HORIZONTAL_ALIGNMENT_LEFT,
		450,
		21,
		Color(0.95, 0.98, 1.0, 0.95 * alpha)
	)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(125, 113),
		"Volvé a la base si baja mucho el calor",
		HORIZONTAL_ALIGNMENT_LEFT,
		450,
		17,
		Color(1.0, 0.86, 0.60, 0.90 * alpha)
	)


func draw_small_danger_indicator() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var pulse: float = 0.65 + sin(animation_time * 5.0) * 0.35

	var box_size: Vector2 = Vector2(210, 38)
	var box_pos: Vector2 = Vector2(
		viewport_size.x / 2.0 - box_size.x / 2.0,
		18
	)

	draw_rect(
		Rect2(box_pos + Vector2(4, 4), box_size),
		Color(0.0, 0.0, 0.0, 0.28)
	)

	draw_rect(
		Rect2(box_pos, box_size),
		Color(0.10, 0.02, 0.02, 0.82)
	)

	draw_rect(
		Rect2(box_pos, box_size),
		Color(1.0, 0.18, 0.08, 0.22 + pulse * 0.12),
		false,
		3
	)

	draw_string(
		ThemeDB.fallback_font,
		box_pos + Vector2(0, 25),
		"⚠ FRÍO EXTREMO",
		HORIZONTAL_ALIGNMENT_CENTER,
		box_size.x,
		17,
		Color(1.0, 0.76, 0.45, 0.95)
	)


func draw_warning_icon(center: Vector2, alpha: float) -> void:
	var pulse: float = 0.65 + sin(animation_time * 8.0) * 0.35

	var outer := PackedVector2Array([
		center + Vector2(0, -36),
		center + Vector2(-40, 32),
		center + Vector2(40, 32)
	])

	draw_polygon(outer, PackedColorArray([
		Color(0.04, 0.02, 0.01, 0.90 * alpha),
		Color(0.04, 0.02, 0.01, 0.90 * alpha),
		Color(0.04, 0.02, 0.01, 0.90 * alpha)
	]))

	var inner := PackedVector2Array([
		center + Vector2(0, -27),
		center + Vector2(-30, 24),
		center + Vector2(30, 24)
	])

	draw_polygon(inner, PackedColorArray([
		Color(1.0, 0.55, 0.10, (0.80 + pulse * 0.20) * alpha),
		Color(1.0, 0.55, 0.10, (0.80 + pulse * 0.20) * alpha),
		Color(1.0, 0.55, 0.10, (0.80 + pulse * 0.20) * alpha)
	]))

	draw_line(
		center + Vector2(0, -12),
		center + Vector2(0, 9),
		Color(0.06, 0.03, 0.01, alpha),
		5
	)

	draw_circle(
		center + Vector2(0, 18),
		4,
		Color(0.06, 0.03, 0.01, alpha)
	)
