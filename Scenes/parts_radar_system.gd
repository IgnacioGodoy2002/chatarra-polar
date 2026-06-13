extends Node2D

const RADAR_SAVE_PATH: String = "user://chatarra_polar_parts_radar.json"
const MAIN_SAVE_PATH: String = "user://chatarra_polar_save.json"

var radar_unlocked: bool = false

var scrap_cost: int = 6
var battery_cost: int = 1
var cable_cost: int = 1
var rare_gear_cost: int = 1

var panel_size: Vector2 = Vector2(315, 88)
var radar_panel_size: Vector2 = Vector2(285, 74)

var animation_time: float = 0.0
var key_cooldown: float = 0.0

var toast_message: String = ""
var toast_timer: float = 0.0
var toast_duration: float = 2.8


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 847
	position = Vector2(35, 512)

	sync_with_main_save_state()
	load_radar_state()

	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	position = Vector2(35, 512)

	if key_cooldown > 0.0:
		key_cooldown -= delta

	if toast_timer > 0.0:
		toast_timer -= delta

	if not radar_unlocked:
		check_purchase_input()

	queue_redraw()


func sync_with_main_save_state() -> void:
	if FileAccess.file_exists(MAIN_SAVE_PATH):
		return

	delete_radar_save()


func delete_radar_save() -> void:
	var dir := DirAccess.open("user://")

	if dir == null:
		return

	if dir.file_exists("chatarra_polar_parts_radar.json"):
		dir.remove("chatarra_polar_parts_radar.json")


func check_purchase_input() -> void:
	if should_hide():
		return

	if not should_show_purchase_panel():
		return

	if key_cooldown > 0.0:
		return

	if Input.is_key_pressed(KEY_K):
		key_cooldown = 0.30
		try_buy_radar()


func try_buy_radar() -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	if not can_buy_radar():
		show_toast("Faltan materiales para el radar de piezas")
		return

	var base_scrap: int = int(main_scene.get("base_scrap"))
	main_scene.set("base_scrap", base_scrap - scrap_cost)

	var parts_value = main_scene.get("special_parts")

	if typeof(parts_value) == TYPE_DICTIONARY:
		var parts: Dictionary = parts_value
		parts["battery"] = int(parts.get("battery", 0)) - battery_cost
		parts["cable"] = int(parts.get("cable", 0)) - cable_cost
		parts["rare_gear"] = int(parts.get("rare_gear", 0)) - rare_gear_cost
		main_scene.set("special_parts", parts)

	radar_unlocked = true
	save_radar_state()

	if main_scene.has_method("save_progress"):
		main_scene.save_progress()

	if main_scene.has_method("update_labels"):
		main_scene.update_labels()

	if main_scene.has_method("play_sound"):
		main_scene.play_sound("upgrade")

	show_toast("¡Radar de piezas instalado! Ahora detectás piezas cercanas")


func should_show_purchase_panel() -> bool:
	if radar_unlocked:
		return false

	if not get_bool_from_main("is_in_base"):
		return false

	if not get_bool_from_main("boiler_upgraded"):
		return false

	if get_bool_from_main("demo_completed"):
		return false

	return true


func should_hide() -> bool:
	if get_tree().paused:
		return true

	var canvas_layer: Node = get_parent()

	if canvas_layer == null:
		return false

	var story_intro: Node = canvas_layer.get_node_or_null("StoryIntro")
	var demo_overlay: Node = canvas_layer.get_node_or_null("DemoCompleteOverlay")
	var pause_menu: Node = canvas_layer.get_node_or_null("PauseMenu")
	var tito_radio: Node = canvas_layer.get_node_or_null("TitoRadio")

	if story_intro != null and story_intro.visible:
		return true

	if demo_overlay != null and demo_overlay.visible:
		return true

	if pause_menu != null and pause_menu.visible:
		return true

	if tito_radio != null and tito_radio.visible:
		return true

	return false


func can_buy_radar() -> bool:
	if get_base_scrap() < scrap_cost:
		return false

	if get_special_part_count("battery") < battery_cost:
		return false

	if get_special_part_count("cable") < cable_cost:
		return false

	if get_special_part_count("rare_gear") < rare_gear_cost:
		return false

	return true


func _draw() -> void:
	if should_hide():
		return

	if should_show_purchase_panel():
		draw_purchase_panel()

	if radar_unlocked and not get_bool_from_main("demo_completed"):
		draw_radar_panel()

	if toast_timer > 0.0:
		draw_toast()


func draw_purchase_panel() -> void:
	draw_panel_background(panel_size)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 21),
		"RADAR DE PIEZAS",
		HORIZONTAL_ALIGNMENT_LEFT,
		230,
		14,
		Color(1.0, 0.88, 0.48, 0.95)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 44),
		"Costo: 6 chat + 1 bat + 1 cab + 1 rara",
		HORIZONTAL_ALIGNMENT_LEFT,
		290,
		13,
		Color(0.88, 0.96, 1.0, 0.90)
	)

	var buy_text: String = "Faltan materiales"
	var buy_color: Color = Color(1.0, 0.72, 0.45, 0.95)

	if can_buy_radar():
		buy_text = "Presioná K para instalar"
		buy_color = Color(0.45, 0.90, 1.0, 1.0)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 67),
		buy_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		250,
		13,
		buy_color
	)

	draw_radar_icon(Vector2(274, 43), can_buy_radar())


func draw_radar_panel() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_pos: Vector2 = Vector2(
		viewport_size.x - radar_panel_size.x - 25.0,
		128.0
	)

	var old_position: Vector2 = position
	position = panel_pos

	draw_panel_background(radar_panel_size)

	var nearest_part: Node2D = get_nearest_special_part()
	var player: Node2D = get_player()

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 21),
		"RADAR DE PIEZAS",
		HORIZONTAL_ALIGNMENT_LEFT,
		180,
		14,
		Color(1.0, 0.88, 0.48, 0.95)
	)

	if nearest_part == null or player == null:
		draw_string(
			ThemeDB.fallback_font,
			Vector2(12, 49),
			"Sin piezas detectadas",
			HORIZONTAL_ALIGNMENT_LEFT,
			190,
			14,
			Color(0.88, 0.96, 1.0, 0.75)
		)

		draw_radar_icon(Vector2(242, 36), false)
		position = old_position
		return

	var part_type: String = str(nearest_part.get("part_type"))
	var distance: int = int(player.global_position.distance_to(nearest_part.global_position))
	var display_name: String = get_part_display_name(part_type)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 49),
		display_name + "  " + str(distance) + "m",
		HORIZONTAL_ALIGNMENT_LEFT,
		190,
		14,
		get_part_color(part_type)
	)

	draw_direction_arrow(Vector2(242, 36), player.global_position, nearest_part.global_position)
	position = old_position


func get_nearest_special_part() -> Node2D:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return null

	var player: Node2D = get_player()

	if player == null:
		return null

	var container: Node = main_scene.get_node_or_null("SpecialPartContainer")

	if container == null:
		return null

	var nearest: Node2D = null
	var nearest_distance: float = INF

	for child in container.get_children():
		var part_node: Node2D = child as Node2D

		if part_node == null:
			continue

		var distance: float = player.global_position.distance_to(part_node.global_position)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest = part_node

	return nearest


func draw_direction_arrow(center: Vector2, from_position: Vector2, to_position: Vector2) -> void:
	var direction: Vector2 = to_position - from_position

	if direction.length() < 8.0:
		draw_arrived_icon(center)
		return

	direction = direction.normalized()

	var angle: float = direction.angle()
	var pulse: float = 0.5 + sin(animation_time * 5.0) * 0.5

	draw_circle(center, 25, Color(0.02, 0.02, 0.025, 1.0))
	draw_circle(center, 20, Color(0.10, 0.13, 0.15, 1.0))
	draw_circle(center, 27, Color(0.45, 0.90, 1.0, 0.10 + pulse * 0.06))

	var tip: Vector2 = center + Vector2(cos(angle), sin(angle)) * 18.0
	var left: Vector2 = center + Vector2(cos(angle + 2.45), sin(angle + 2.45)) * 10.0
	var right: Vector2 = center + Vector2(cos(angle - 2.45), sin(angle - 2.45)) * 10.0

	var arrow := PackedVector2Array([
		tip,
		left,
		center,
		right
	])

	draw_polygon(arrow, PackedColorArray([
		Color(0.45, 0.90, 1.0, 1.0),
		Color(0.20, 0.60, 0.95, 1.0),
		Color(0.35, 0.80, 1.0, 1.0),
		Color(0.20, 0.60, 0.95, 1.0)
	]))


func draw_arrived_icon(center: Vector2) -> void:
	draw_circle(center, 25, Color(0.02, 0.02, 0.025, 1.0))
	draw_circle(center, 19, Color(0.15, 0.35, 0.28, 1.0))

	draw_line(
		center + Vector2(-10, 0),
		center + Vector2(-3, 8),
		Color(0.45, 1.0, 0.70, 1.0),
		4
	)

	draw_line(
		center + Vector2(-3, 8),
		center + Vector2(13, -10),
		Color(0.45, 1.0, 0.70, 1.0),
		4
	)


func draw_panel_background(size: Vector2) -> void:
	draw_rect(
		Rect2(Vector2(3, 3), size),
		Color(0.0, 0.0, 0.0, 0.24)
	)

	draw_rect(
		Rect2(Vector2.ZERO, size),
		Color(0.03, 0.04, 0.05, 0.84)
	)

	draw_rect(
		Rect2(Vector2(5, 5), size - Vector2(10, 10)),
		Color(0.08, 0.10, 0.12, 0.80)
	)

	draw_line(
		Vector2(12, size.y - 9),
		Vector2(size.x - 12, size.y - 9),
		Color(1.0, 0.60, 0.20, 0.82),
		2
	)


func draw_radar_icon(center: Vector2, is_ready: bool) -> void:
	var icon_color: Color = Color(0.45, 0.45, 0.45, 1.0)

	if is_ready:
		icon_color = Color(0.45, 0.90, 1.0, 1.0)

	draw_circle(center, 22, Color(0.02, 0.02, 0.025, 1.0))
	draw_circle(center, 16, Color(0.08, 0.12, 0.15, 1.0))

	for i in range(3):
		draw_arc(
			center,
			7.0 + float(i) * 6.0,
			-0.9,
			0.9,
			20,
			Color(icon_color.r, icon_color.g, icon_color.b, 0.85 - float(i) * 0.20),
			2
		)

	draw_circle(center, 3, icon_color)


func draw_toast() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var alpha: float = clamp(toast_timer / 0.35, 0.0, 1.0)

	var toast_size: Vector2 = Vector2(650, 54)
	var toast_pos: Vector2 = Vector2(
		viewport_size.x / 2.0 - toast_size.x / 2.0,
		viewport_size.y * 0.13
	)

	draw_rect(
		Rect2(toast_pos + Vector2(4, 4), toast_size),
		Color(0.0, 0.0, 0.0, 0.35 * alpha)
	)

	draw_rect(
		Rect2(toast_pos, toast_size),
		Color(0.03, 0.04, 0.05, 0.92 * alpha)
	)

	draw_rect(
		Rect2(toast_pos + Vector2(5, 5), toast_size - Vector2(10, 10)),
		Color(0.10, 0.13, 0.15, 0.90 * alpha)
	)

	draw_line(
		toast_pos + Vector2(14, toast_size.y - 10),
		toast_pos + Vector2(toast_size.x - 14, toast_size.y - 10),
		Color(1.0, 0.65, 0.22, alpha),
		3
	)

	draw_string(
		ThemeDB.fallback_font,
		toast_pos + Vector2(0, 34),
		toast_message,
		HORIZONTAL_ALIGNMENT_CENTER,
		toast_size.x,
		16,
		Color(1.0, 0.88, 0.48, alpha)
	)


func show_toast(text: String) -> void:
	toast_message = text
	toast_timer = toast_duration

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		var status_value = main_scene.get("status_label")

		if status_value != null and status_value is Label:
			var status_label: Label = status_value as Label
			status_label.text = text


func get_part_display_name(part_type: String) -> String:
	match part_type:
		"battery":
			return "Batería"
		"cable":
			return "Cable"
		"rare_gear":
			return "Engranaje raro"

	return "Pieza"


func get_part_color(part_type: String) -> Color:
	match part_type:
		"battery":
			return Color(0.45, 0.90, 1.0, 1.0)
		"cable":
			return Color(1.0, 0.65, 0.22, 1.0)
		"rare_gear":
			return Color(1.0, 0.88, 0.35, 1.0)

	return Color(0.88, 0.96, 1.0, 1.0)


func get_player() -> Node2D:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return null

	return main_scene.get_node_or_null("Player") as Node2D


func get_base_scrap() -> int:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 0

	var value = main_scene.get("base_scrap")

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


func get_bool_from_main(property_name: String) -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get(property_name)

	if value == null:
		return false

	return bool(value)


func save_radar_state() -> void:
	var data: Dictionary = {
		"radar_unlocked": radar_unlocked
	}

	var file := FileAccess.open(RADAR_SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("No se pudo guardar el radar de piezas")
		return

	file.store_string(JSON.stringify(data))
	file.close()


func load_radar_state() -> void:
	if not FileAccess.file_exists(RADAR_SAVE_PATH):
		return

	var file := FileAccess.open(RADAR_SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)

	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var data: Dictionary = parsed
	radar_unlocked = bool(data.get("radar_unlocked", false))
