extends Node2D

var slot_size: Vector2 = Vector2(46, 46)
var slot_gap: float = 6.0
var slot_count: int = 6

var animation_time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 860
	position = Vector2.ZERO
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	position = Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	if should_hide():
		return

	draw_hotbar()


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


func draw_hotbar() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	var total_width: float = float(slot_count) * slot_size.x + float(slot_count - 1) * slot_gap
	var start_pos: Vector2 = Vector2(
		viewport_size.x / 2.0 - total_width / 2.0,
		viewport_size.y - 60.0
	)

	draw_bar_background(start_pos, total_width)

	for i in range(slot_count):
		var slot_pos: Vector2 = start_pos + Vector2(float(i) * (slot_size.x + slot_gap), 0.0)
		draw_slot(slot_pos, i)


func draw_bar_background(start_pos: Vector2, total_width: float) -> void:
	var panel_pos: Vector2 = start_pos + Vector2(-9, -8)
	var panel_size: Vector2 = Vector2(total_width + 18, slot_size.y + 16)

	draw_rect(
		Rect2(panel_pos + Vector2(4, 4), panel_size),
		Color(0.0, 0.0, 0.0, 0.24)
	)

	draw_rect(
		Rect2(panel_pos, panel_size),
		Color(0.03, 0.04, 0.05, 0.82)
	)

	draw_rect(
		Rect2(panel_pos + Vector2(5, 5), panel_size - Vector2(10, 10)),
		Color(0.08, 0.10, 0.12, 0.72)
	)


func draw_slot(pos: Vector2, index: int) -> void:
	var label_text: String = get_slot_label(index)
	var count_text: String = get_slot_count_text(index)
	var available: bool = get_slot_available(index)

	var border_color: Color = Color(0.55, 0.35, 0.14, 0.95)

	if available:
		border_color = Color(1.0, 0.60, 0.18, 0.95)

	if index == get_highlighted_slot():
		border_color = Color(1.0, 0.84, 0.35, 1.0)

	draw_rect(
		Rect2(pos, slot_size),
		Color(0.02, 0.02, 0.025, 0.96)
	)

	draw_rect(
		Rect2(pos + Vector2(3, 3), slot_size - Vector2(6, 6)),
		Color(0.09, 0.09, 0.09, 0.92)
	)

	draw_rect(
		Rect2(pos, slot_size),
		border_color,
		false,
		2
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(0, 11),
		label_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		slot_size.x,
		9,
		Color(0.82, 0.88, 0.90, 0.80)
	)

	draw_slot_icon(pos + slot_size / 2.0 + Vector2(0, 2), index, available)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(0, slot_size.y - 5),
		count_text,
		HORIZONTAL_ALIGNMENT_RIGHT,
		slot_size.x - 4,
		13,
		get_count_color(index, available)
	)


func get_highlighted_slot() -> int:
	if not get_bool_from_main("backpack_upgraded"):
		return 0

	if not get_bool_from_main("boiler_upgraded"):
		return 0

	if not get_bool_from_main("thermal_boots_upgraded"):
		if get_special_part_count("battery") < 2:
			return 1

		if get_special_part_count("cable") < 2:
			return 2

		return 4

	if not get_bool_from_main("antenna_repaired"):
		if get_special_part_count("rare_gear") < 2:
			return 3

		return 5

	return -1


func get_slot_label(index: int) -> String:
	match index:
		0:
			return "CHAT"
		1:
			return "BAT"
		2:
			return "CAB"
		3:
			return "RAR"
		4:
			return "BOT"
		5:
			return "ANT"

	return ""


func get_slot_count_text(index: int) -> String:
	match index:
		0:
			return str(get_int_from_main("scrap_count"))
		1:
			return str(get_special_part_count("battery"))
		2:
			return str(get_special_part_count("cable"))
		3:
			return str(get_special_part_count("rare_gear"))
		4:
			if get_bool_from_main("thermal_boots_upgraded"):
				return "OK"
			return "NO"
		5:
			if get_bool_from_main("antenna_repaired"):
				return "OK"
			return "-"

	return ""


func get_slot_available(index: int) -> bool:
	match index:
		0:
			return get_int_from_main("scrap_count") > 0
		1:
			return get_special_part_count("battery") > 0
		2:
			return get_special_part_count("cable") > 0
		3:
			return get_special_part_count("rare_gear") > 0
		4:
			return get_bool_from_main("thermal_boots_upgraded")
		5:
			return get_bool_from_main("antenna_repaired")

	return false


func get_count_color(index: int, available: bool) -> Color:
	if index == 4 and not available:
		return Color(1.0, 0.35, 0.28, 1.0)

	if available:
		return Color(1.0, 0.88, 0.40, 1.0)

	return Color(0.86, 0.92, 0.95, 0.55)


func draw_slot_icon(center: Vector2, index: int, available: bool) -> void:
	match index:
		0:
			draw_scrap_icon(center, available)
		1:
			draw_battery_icon(center, available)
		2:
			draw_cable_icon(center, available)
		3:
			draw_gear_icon(center, available)
		4:
			draw_boots_icon(center, available)
		5:
			draw_antenna_icon(center, available)


func draw_scrap_icon(center: Vector2, available: bool) -> void:
	var color: Color = Color(0.45, 0.25, 0.12, 1.0)

	if not available:
		color = Color(0.25, 0.25, 0.25, 1.0)

	draw_circle(center, 13, Color(0.03, 0.03, 0.035, 1.0))

	for i in range(6):
		var angle: float = TAU * float(i) / 6.0 + animation_time * 0.7
		var dir: Vector2 = Vector2(cos(angle), sin(angle))

		draw_line(
			center + dir * 5.0,
			center + dir * 13.0,
			Color(0.85, 0.50, 0.15, 0.85 if available else 0.25),
			2
		)

	draw_circle(center, 7, color)
	draw_circle(center, 3, Color(1.0, 0.60, 0.20, 1.0 if available else 0.35))


func draw_battery_icon(center: Vector2, available: bool) -> void:
	var body_color: Color = Color(0.22, 0.65, 1.0, 1.0)

	if not available:
		body_color = Color(0.25, 0.25, 0.25, 1.0)

	draw_rect(
		Rect2(center + Vector2(-9, -10), Vector2(18, 20)),
		Color(0.02, 0.02, 0.025, 1.0)
	)

	draw_rect(
		Rect2(center + Vector2(-6, -7), Vector2(12, 14)),
		body_color
	)

	draw_rect(
		Rect2(center + Vector2(-3, -13), Vector2(6, 3)),
		Color(0.75, 0.85, 0.90, 1.0 if available else 0.35)
	)

	draw_line(
		center + Vector2(-3, 0),
		center + Vector2(3, 0),
		Color(1.0, 0.90, 0.30, 1.0 if available else 0.35),
		2
	)


func draw_cable_icon(center: Vector2, available: bool) -> void:
	var color: Color = Color(1.0, 0.62, 0.18, 1.0)

	if not available:
		color = Color(0.35, 0.35, 0.35, 1.0)

	var last_point: Vector2 = center + Vector2(-15, 0)

	for i in range(1, 8):
		var x: float = -15.0 + float(i) * 5.0
		var y: float = sin(float(i) * 1.5 + animation_time * 3.0) * 6.0
		var point: Vector2 = center + Vector2(x, y)

		draw_line(last_point, point, color, 2.5)
		last_point = point

	draw_circle(center + Vector2(-16, 0), 3, Color(0.90, 0.90, 0.85, 1.0))
	draw_circle(center + Vector2(16, 0), 3, Color(0.90, 0.90, 0.85, 1.0))


func draw_gear_icon(center: Vector2, available: bool) -> void:
	var color: Color = Color(1.0, 0.82, 0.22, 1.0)

	if not available:
		color = Color(0.35, 0.35, 0.35, 1.0)

	draw_circle(center, 14, Color(0.02, 0.02, 0.025, 1.0))

	for i in range(8):
		var angle: float = TAU * float(i) / 8.0 + animation_time
		var dir: Vector2 = Vector2(cos(angle), sin(angle))

		draw_line(
			center + dir * 7.0,
			center + dir * 13.0,
			color,
			2.5
		)

	draw_circle(center, 8, color)
	draw_circle(center, 3.5, Color(0.03, 0.04, 0.05, 1.0))


func draw_boots_icon(center: Vector2, available: bool) -> void:
	var color: Color = Color(0.45, 0.90, 1.0, 1.0)

	if not available:
		color = Color(0.35, 0.35, 0.35, 1.0)

	draw_rect(
		Rect2(center + Vector2(-12, -3), Vector2(11, 12)),
		color
	)

	draw_rect(
		Rect2(center + Vector2(2, -3), Vector2(11, 12)),
		color
	)

	draw_rect(
		Rect2(center + Vector2(-13, 7), Vector2(14, 4)),
		Color(0.05, 0.05, 0.06, 1.0)
	)

	draw_rect(
		Rect2(center + Vector2(1, 7), Vector2(14, 4)),
		Color(0.05, 0.05, 0.06, 1.0)
	)

	if not available:
		draw_line(
			center + Vector2(-17, 15),
			center + Vector2(17, -15),
			Color(1.0, 0.15, 0.10, 0.95),
			3
		)


func draw_antenna_icon(center: Vector2, available: bool) -> void:
	var color: Color = Color(0.45, 0.90, 1.0, 1.0)

	if not available:
		color = Color(0.35, 0.35, 0.35, 1.0)

	draw_line(center + Vector2(0, 12), center + Vector2(0, -12), color, 3)
	draw_line(center + Vector2(-9, -3), center + Vector2(9, -3), color, 3)

	draw_circle(center + Vector2(0, -15), 5, color)

	for i in range(2):
		draw_arc(
			center + Vector2(0, -15),
			10.0 + float(i) * 6.0,
			-0.9,
			0.9,
			20,
			Color(color.r, color.g, color.b, 0.35 if available else 0.12),
			2
		)


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


func get_special_part_count(part_name: String) -> int:
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
