extends Node2D

var panel_size: Vector2 = Vector2(255, 66)
var margin_right: float = 22.0
var margin_top: float = 38.0
var animation_time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 900
	update_position()
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	update_position()
	queue_redraw()


func update_position() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	position = Vector2(
		viewport_size.x - panel_size.x - margin_right,
		margin_top
	)


func _draw() -> void:
	if should_hide():
		return

	draw_panel()
	draw_content()


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

	if node_is_visible(canvas_layer, "TitoRadio"):
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


func draw_panel() -> void:
	draw_rect(
		Rect2(Vector2(3, 3), panel_size),
		Color(0.0, 0.0, 0.0, 0.26)
	)

	draw_rect(
		Rect2(Vector2.ZERO, panel_size),
		Color(0.03, 0.04, 0.05, 0.86)
	)

	draw_rect(
		Rect2(Vector2(5, 5), panel_size - Vector2(10, 10)),
		Color(0.08, 0.10, 0.12, 0.78)
	)

	draw_line(
		Vector2(12, panel_size.y - 8),
		Vector2(panel_size.x - 12, panel_size.y - 8),
		Color(1.0, 0.60, 0.20, 0.88),
		2
	)


func draw_content() -> void:
	var objective_name: String = get_objective_name()
	var objective_hint: String = get_objective_hint()
	var target_position: Vector2 = get_target_position()

	draw_string(
		ThemeDB.fallback_font,
		Vector2(14, 19),
		"OBJETIVO",
		HORIZONTAL_ALIGNMENT_LEFT,
		130,
		12,
		Color(1.0, 0.88, 0.48, 0.95)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(14, 39),
		objective_name,
		HORIZONTAL_ALIGNMENT_LEFT,
		165,
		16,
		Color(0.90, 0.98, 1.0, 1.0)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(14, 57),
		objective_hint,
		HORIZONTAL_ALIGNMENT_LEFT,
		165,
		11,
		Color(0.78, 0.90, 0.95, 0.82)
	)

	draw_compass_arrow(Vector2(215, 34), target_position)


func draw_compass_arrow(center: Vector2, target_position: Vector2) -> void:
	var player: Node2D = get_player()

	if player == null:
		draw_question_mark(center)
		return

	var direction: Vector2 = target_position - player.global_position

	if direction.length() < 8.0:
		draw_arrived_icon(center)
		return

	direction = direction.normalized()

	var angle: float = direction.angle()
	var pulse: float = 0.5 + sin(animation_time * 5.0) * 0.5

	draw_circle(center, 24, Color(0.02, 0.02, 0.025, 1.0))
	draw_circle(center, 19, Color(0.10, 0.13, 0.15, 1.0))
	draw_circle(center, 25, Color(1.0, 0.65, 0.20, 0.10 + pulse * 0.05))

	draw_arc(
		center,
		19,
		0.0,
		TAU,
		40,
		Color(1.0, 0.70, 0.30, 0.90),
		2
	)

	var tip: Vector2 = center + Vector2(cos(angle), sin(angle)) * 17.0
	var left: Vector2 = center + Vector2(cos(angle + 2.45), sin(angle + 2.45)) * 9.0
	var right: Vector2 = center + Vector2(cos(angle - 2.45), sin(angle - 2.45)) * 9.0

	var arrow := PackedVector2Array([
		tip,
		left,
		center,
		right
	])

	draw_polygon(arrow, PackedColorArray([
		Color(1.0, 0.82, 0.35, 1.0),
		Color(1.0, 0.58, 0.15, 1.0),
		Color(1.0, 0.70, 0.22, 1.0),
		Color(1.0, 0.58, 0.15, 1.0)
	]))

	draw_circle(center, 3, Color(0.05, 0.04, 0.03, 1.0))


func draw_question_mark(center: Vector2) -> void:
	draw_circle(center, 22, Color(0.02, 0.02, 0.025, 1.0))

	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-7, 9),
		"?",
		HORIZONTAL_ALIGNMENT_LEFT,
		24,
		20,
		Color(1.0, 0.88, 0.48, 1.0)
	)


func draw_arrived_icon(center: Vector2) -> void:
	var pulse: float = 0.5 + sin(animation_time * 5.0) * 0.5

	draw_circle(center, 24, Color(0.02, 0.02, 0.025, 1.0))
	draw_circle(center, 18, Color(0.15, 0.35, 0.28, 1.0))
	draw_circle(center, 24, Color(0.35, 1.0, 0.70, 0.12 + pulse * 0.08))

	draw_line(
		center + Vector2(-9, 0),
		center + Vector2(-2, 8),
		Color(0.45, 1.0, 0.70, 1.0),
		4
	)

	draw_line(
		center + Vector2(-2, 8),
		center + Vector2(12, -10),
		Color(0.45, 1.0, 0.70, 1.0),
		4
	)


func get_objective_name() -> String:
	if get_bool_from_main("demo_completed"):
		return "Demo completada"

	if not get_bool_from_main("mission_completed"):
		if get_int_from_main("scrap_count") >= get_int_from_main("max_scrap"):
			return "Volvé a la base"
		return "Juntá chatarra"

	if not get_bool_from_main("backpack_upgraded"):
		return "Mejorá mochila"

	if not get_bool_from_main("boiler_upgraded"):
		return "Mejorá caldera"

	if not get_bool_from_main("thermal_boots_upgraded"):
		return "Creá botas"

	if not get_bool_from_main("antenna_repaired"):
		return "Repará antena"

	return "Explorá"


func get_objective_hint() -> String:
	if get_bool_from_main("demo_completed"):
		return "Villa Escarcha a salvo"

	if not get_bool_from_main("mission_completed"):
		if get_int_from_main("scrap_count") >= get_int_from_main("max_scrap"):
			return "Descargá materiales"
		return "Buscá piezas sueltas"

	if not get_bool_from_main("backpack_upgraded"):
		return "Usá el taller"

	if not get_bool_from_main("boiler_upgraded"):
		return "Usá el taller"

	if not get_bool_from_main("thermal_boots_upgraded"):
		return "6 chat + 2 bat + 2 cab"

	if not get_bool_from_main("antenna_repaired"):
		return "Andá al noreste"

	return "Seguimos puliendo"


func get_target_position() -> Vector2:
	if get_bool_from_main("demo_completed"):
		return get_base_position()

	if not get_bool_from_main("mission_completed"):
		if get_int_from_main("scrap_count") >= get_int_from_main("max_scrap"):
			return get_base_position()
		return Vector2(760, 360)

	if not get_bool_from_main("backpack_upgraded"):
		return get_base_position()

	if not get_bool_from_main("boiler_upgraded"):
		return get_base_position()

	if not get_bool_from_main("thermal_boots_upgraded"):
		if get_int_from_special_parts("battery") < 2:
			return Vector2(760, 360)

		if get_int_from_special_parts("cable") < 2:
			return Vector2(-650, -420)

		return get_base_position()

	if not get_bool_from_main("antenna_repaired"):
		return get_antenna_position()

	return get_base_position()


func get_player() -> Node2D:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return null

	return main_scene.get_node_or_null("Player") as Node2D


func get_base_position() -> Vector2:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return Vector2.ZERO

	var base_node: Node2D = main_scene.get_node_or_null("Base") as Node2D

	if base_node == null:
		return Vector2.ZERO

	return base_node.global_position


func get_antenna_position() -> Vector2:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return Vector2(900, -500)

	var antenna_node: Node2D = main_scene.get_node_or_null("Antenna") as Node2D

	if antenna_node == null:
		return Vector2(900, -500)

	return antenna_node.global_position


func get_bool_from_main(property_name: String) -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get(property_name)

	if value == null:
		return false

	return bool(value)


func get_int_from_main(property_name: String) -> int:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 0

	var value = main_scene.get(property_name)

	if value == null:
		return 0

	return int(value)


func get_int_from_special_parts(part_name: String) -> int:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 0

	var parts_value = main_scene.get("special_parts")

	if typeof(parts_value) != TYPE_DICTIONARY:
		return 0

	var parts: Dictionary = parts_value

	if not parts.has(part_name):
		return 0

	return int(parts[part_name])
