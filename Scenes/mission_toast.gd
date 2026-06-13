extends Node2D

var animation_time: float = 0.0

var toast_message: String = ""
var toast_subtitle: String = ""
var toast_timer: float = 0.0
var toast_duration: float = 2.2

var initialized: bool = false

var last_mission_completed: bool = false
var last_backpack_upgraded: bool = false
var last_boiler_upgraded: bool = false
var last_thermal_boots_upgraded: bool = false
var last_antenna_repaired: bool = false
var last_demo_completed: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 900
	visible = true
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta

	check_progress_changes()

	if toast_timer > 0.0:
		toast_timer -= delta

	queue_redraw()


func check_progress_changes() -> void:
	var mission_completed: bool = get_bool_from_main("mission_completed")
	var backpack_upgraded: bool = get_bool_from_main("backpack_upgraded")
	var boiler_upgraded: bool = get_bool_from_main("boiler_upgraded")
	var thermal_boots_upgraded: bool = get_bool_from_main("thermal_boots_upgraded")
	var antenna_repaired: bool = get_bool_from_main("antenna_repaired")
	var demo_completed: bool = get_bool_from_main("demo_completed")

	if not initialized:
		last_mission_completed = mission_completed
		last_backpack_upgraded = backpack_upgraded
		last_boiler_upgraded = boiler_upgraded
		last_thermal_boots_upgraded = thermal_boots_upgraded
		last_antenna_repaired = antenna_repaired
		last_demo_completed = demo_completed
		initialized = true
		return

	if mission_completed and not last_mission_completed:
		show_toast("Mini caldera reparada", "La base vuelve a tener calor.")

	if backpack_upgraded and not last_backpack_upgraded:
		show_toast("Mochila mejorada", "Ahora llevás más chatarra.")

	if boiler_upgraded and not last_boiler_upgraded:
		show_toast("Caldera mejorada", "El frío baja más lento.")

	if thermal_boots_upgraded and not last_thermal_boots_upgraded:
		show_toast("Botas térmicas creadas", "Zona peligrosa más soportable.")

	if antenna_repaired and not last_antenna_repaired:
		show_toast("Antena reparada", "Villa Escarcha vuelve a tener señal.")

	if demo_completed and not last_demo_completed:
		show_toast("Demo completada", "Buen trabajo, Chispa.")

	last_mission_completed = mission_completed
	last_backpack_upgraded = backpack_upgraded
	last_boiler_upgraded = boiler_upgraded
	last_thermal_boots_upgraded = thermal_boots_upgraded
	last_antenna_repaired = antenna_repaired
	last_demo_completed = demo_completed


func show_toast(message: String, subtitle: String = "") -> void:
	toast_message = message
	toast_subtitle = subtitle
	toast_timer = toast_duration


func should_hide() -> bool:
	if get_tree().paused:
		return true

	var canvas_layer: Node = get_parent()

	if canvas_layer == null:
		return false

	if node_is_visible(canvas_layer, "StoryIntro"):
		return true

	if node_is_visible(canvas_layer, "DemoCompleteOverlay"):
		return true

	if node_is_visible(canvas_layer, "PauseMenu"):
		return true

	return false


func node_is_visible(parent_node: Node, node_name: String) -> bool:
	var node: Node = parent_node.get_node_or_null(node_name)

	if node == null:
		return false

	var canvas_item: CanvasItem = node as CanvasItem

	if canvas_item == null:
		return false

	return canvas_item.visible


func _draw() -> void:
	if should_hide():
		return

	if toast_timer <= 0.0:
		return

	draw_compact_toast()


func draw_compact_toast() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	var alpha: float = clamp(toast_timer / 0.25, 0.0, 1.0)

	if toast_timer < 0.35:
		alpha = clamp(toast_timer / 0.35, 0.0, 1.0)

	var toast_size: Vector2 = Vector2(410, 58)
	var toast_pos: Vector2 = Vector2(
		viewport_size.x / 2.0 - toast_size.x / 2.0,
		104.0
	)

	var pulse: float = 0.55 + sin(animation_time * 5.0) * 0.45

	draw_rect(
		Rect2(toast_pos + Vector2(4, 4), toast_size),
		Color(0.0, 0.0, 0.0, 0.28 * alpha)
	)

	draw_rect(
		Rect2(toast_pos, toast_size),
		Color(0.03, 0.04, 0.05, 0.88 * alpha)
	)

	draw_rect(
		Rect2(toast_pos + Vector2(5, 5), toast_size - Vector2(10, 10)),
		Color(0.10, 0.13, 0.15, 0.84 * alpha)
	)

	draw_line(
		toast_pos + Vector2(14, toast_size.y - 9),
		toast_pos + Vector2(toast_size.x - 14, toast_size.y - 9),
		Color(1.0, 0.60, 0.20, alpha),
		2
	)

	draw_upgrade_icon(toast_pos + Vector2(34, 29), alpha, pulse)

	draw_string(
		ThemeDB.fallback_font,
		toast_pos + Vector2(65, 25),
		toast_message,
		HORIZONTAL_ALIGNMENT_LEFT,
		320,
		18,
		Color(1.0, 0.88, 0.48, alpha)
	)

	if toast_subtitle != "":
		draw_string(
			ThemeDB.fallback_font,
			toast_pos + Vector2(65, 46),
			toast_subtitle,
			HORIZONTAL_ALIGNMENT_LEFT,
			320,
			13,
			Color(0.86, 0.96, 1.0, 0.86 * alpha)
		)


func draw_upgrade_icon(center: Vector2, alpha: float, pulse: float) -> void:
	draw_circle(
		center,
		18,
		Color(0.02, 0.02, 0.025, 0.95 * alpha)
	)

	draw_circle(
		center,
		12,
		Color(1.0, 0.58, 0.12, (0.35 + pulse * 0.12) * alpha)
	)

	for i in range(8):
		var angle: float = TAU * float(i) / 8.0
		var dir: Vector2 = Vector2(cos(angle), sin(angle))

		draw_line(
			center + dir * 7.0,
			center + dir * 14.0,
			Color(1.0, 0.70, 0.25, alpha),
			2
		)

	draw_circle(center, 5, Color(1.0, 0.76, 0.28, alpha))
	draw_circle(center, 2, Color(0.03, 0.04, 0.05, alpha))


func get_bool_from_main(property_name: String) -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get(property_name)

	if value == null:
		return false

	return bool(value)
