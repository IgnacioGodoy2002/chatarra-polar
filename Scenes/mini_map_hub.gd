extends Node2D

var panel_size: Vector2 = Vector2(126, 116)
var map_radius: float = 39.0
var animation_time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 855
	update_position()
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	update_position()
	queue_redraw()


func update_position() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	var target_y: float = viewport_size.y - panel_size.y - 24.0

	if should_move_up_for_workshop():
		target_y = 326.0

	position = Vector2(
		viewport_size.x - panel_size.x - 20.0,
		target_y
	)


func should_move_up_for_workshop() -> bool:
	if get_bool_from_main("demo_completed"):
		return false

	if not get_bool_from_main("is_in_base"):
		return false

	if not get_bool_from_main("boiler_upgraded"):
		return false

	return true


func _draw() -> void:
	if should_hide():
		return

	draw_panel()
	draw_minimap()
	draw_clock_text()


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
		Color(0.0, 0.0, 0.0, 0.24)
	)

	draw_rect(
		Rect2(Vector2.ZERO, panel_size),
		Color(0.03, 0.04, 0.05, 0.82)
	)

	draw_rect(
		Rect2(Vector2(5, 5), panel_size - Vector2(10, 10)),
		Color(0.08, 0.10, 0.12, 0.72)
	)

	draw_line(
		Vector2(10, panel_size.y - 8),
		Vector2(panel_size.x - 10, panel_size.y - 8),
		Color(1.0, 0.60, 0.20, 0.78),
		2
	)


func draw_minimap() -> void:
	var center: Vector2 = Vector2(panel_size.x / 2.0, 45.0)
	var pulse: float = 0.5 + sin(animation_time * 4.0) * 0.5

	draw_circle(center, map_radius + 4.0, Color(0.02, 0.02, 0.025, 0.95))
	draw_circle(center, map_radius, Color(0.24, 0.52, 0.62, 0.72))
	draw_circle(center, map_radius - 4.0, Color(0.52, 0.86, 0.96, 0.42))

	draw_arc(
		center,
		map_radius,
		0.0,
		TAU,
		64,
		Color(1.0, 0.72, 0.22, 0.80),
		2
	)

	draw_compass_letters(center)
	draw_map_dots(center)
	draw_player_dot(center, pulse)


func draw_compass_letters(center: Vector2) -> void:
	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-4, -map_radius + 10),
		"N",
		HORIZONTAL_ALIGNMENT_LEFT,
		20,
		10,
		Color(1.0, 0.88, 0.48, 0.85)
	)

	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-4, map_radius - 3),
		"S",
		HORIZONTAL_ALIGNMENT_LEFT,
		20,
		10,
		Color(1.0, 0.88, 0.48, 0.55)
	)


func draw_map_dots(center: Vector2) -> void:
	var player: Node2D = get_player()

	if player == null:
		return

	draw_world_point(center, get_base_position(), player.global_position, Color(1.0, 0.55, 0.18, 1.0), 4.0)
	draw_world_point(center, get_antenna_position(), player.global_position, Color(0.45, 0.90, 1.0, 1.0), 3.5)

	draw_container_points(center, "ScrapContainer", player.global_position, Color(0.75, 0.45, 0.18, 0.85), 2.0, 10)
	draw_container_points(center, "SpecialPartContainer", player.global_position, Color(1.0, 0.84, 0.30, 0.92), 2.4, 8)
	draw_container_points(center, "EnemyContainer", player.global_position, Color(1.0, 0.22, 0.10, 0.85), 2.6, 8)


func draw_world_point(center: Vector2, world_position: Vector2, player_position: Vector2, color: Color, radius: float) -> void:
	var offset: Vector2 = (world_position - player_position) * 0.035

	if offset.length() > map_radius - 7.0:
		offset = offset.normalized() * (map_radius - 7.0)

	draw_circle(center + offset, radius, Color(0.02, 0.02, 0.025, 0.85))
	draw_circle(center + offset, radius - 1.0, color)


func draw_container_points(center: Vector2, container_name: String, player_position: Vector2, color: Color, radius: float, max_points: int) -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	var container: Node = main_scene.get_node_or_null(container_name)

	if container == null:
		return

	var drawn: int = 0

	for child in container.get_children():
		if drawn >= max_points:
			return

		var node_2d: Node2D = child as Node2D

		if node_2d == null:
			continue

		var offset: Vector2 = (node_2d.global_position - player_position) * 0.035

		if offset.length() > map_radius - 7.0:
			continue

		draw_circle(center + offset, radius, color)
		drawn += 1


func draw_player_dot(center: Vector2, pulse: float) -> void:
	draw_circle(center, 6.0 + pulse * 1.0, Color(0.0, 0.0, 0.0, 0.50))
	draw_circle(center, 4.0, Color(1.0, 0.62, 0.20, 1.0))
	draw_circle(center, 2.0, Color(1.0, 0.88, 0.40, 1.0))


func draw_clock_text() -> void:
	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, 94),
		"DÍA " + str(get_day_number()),
		HORIZONTAL_ALIGNMENT_CENTER,
		panel_size.x,
		14,
		Color(1.0, 0.88, 0.48, 0.95)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, 111),
		get_time_text(),
		HORIZONTAL_ALIGNMENT_CENTER,
		panel_size.x,
		13,
		Color(0.86, 0.96, 1.0, 0.88)
	)


func get_day_number() -> int:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 1

	var possible_names: Array[String] = [
		"day",
		"current_day",
		"day_number",
		"day_count",
		"current_day_number",
		"game_day"
	]

	for property_name in possible_names:
		var value = main_scene.get(property_name)

		if value != null:
			return int(value)

	return 1


func get_time_text() -> String:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return "18:00"

	var method_names: Array[String] = [
		"get_time_text",
		"get_clock_text",
		"get_time_string",
		"get_formatted_time",
		"format_time_text"
	]

	for method_name in method_names:
		if main_scene.has_method(method_name):
			var result = main_scene.call(method_name)

			if result != null:
				return str(result)

	var text_properties: Array[String] = [
		"time_text",
		"clock_text",
		"current_time_text",
		"formatted_time",
		"hour_text"
	]

	for property_name in text_properties:
		var value = main_scene.get(property_name)

		if value != null:
			return str(value)

	var minute_properties: Array[String] = [
		"time_minutes",
		"current_minutes",
		"game_minutes",
		"day_minutes",
		"minutes_of_day",
		"current_time_minutes",
		"world_minutes",
		"total_minutes",
		"clock_minutes"
	]

	for property_name in minute_properties:
		var value = main_scene.get(property_name)

		if value != null:
			return format_minutes(float(value))

	var hour_properties: Array[String] = [
		"time_of_day",
		"current_hour",
		"game_hour",
		"hour",
		"clock_hour"
	]

	for property_name in hour_properties:
		var value = main_scene.get(property_name)

		if value != null:
			return format_hour_value(float(value))

	var hour_value = main_scene.get("hours")
	var minute_value = main_scene.get("minutes")

	if hour_value != null and minute_value != null:
		return two_digits(int(hour_value)) + ":" + two_digits(int(minute_value))

	return "18:00"


func format_minutes(minutes_value: float) -> String:
	var total_minutes: int = int(minutes_value)

	total_minutes = total_minutes % 1440

	if total_minutes < 0:
		total_minutes += 1440

	var hour: int = floori(float(total_minutes) / 60.0)
	var minute: int = total_minutes % 60

	return two_digits(hour) + ":" + two_digits(minute)


func format_hour_value(hour_value: float) -> String:
	if hour_value >= 0.0 and hour_value <= 1.0:
		hour_value = hour_value * 24.0

	var hour: int = int(floor(hour_value))
	var minute: int = int((hour_value - float(hour)) * 60.0)

	hour = hour % 24

	if hour < 0:
		hour += 24

	minute = clamp(minute, 0, 59)

	return two_digits(hour) + ":" + two_digits(minute)


func two_digits(value: int) -> String:
	if value < 10:
		return "0" + str(value)

	return str(value)


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
