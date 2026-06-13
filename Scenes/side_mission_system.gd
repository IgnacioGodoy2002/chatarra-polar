extends Node2D

const SIDE_SAVE_PATH: String = "user://chatarra_polar_side_missions.json"
const MAIN_SAVE_PATH: String = "user://chatarra_polar_save.json"

var compact_panel_size: Vector2 = Vector2(315, 72)
var expanded_panel_size: Vector2 = Vector2(315, 112)

var animation_time: float = 0.0
var expanded: bool = false
var toggle_cooldown: float = 0.0

var dangerous_zone_visited: bool = false
var low_heat_reached: bool = false

var explorer_completed: bool = false
var collector_completed: bool = false
var survivor_completed: bool = false

var toast_message: String = ""
var toast_timer: float = 0.0
var toast_duration: float = 2.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 840
	position = Vector2(35, 248)

	sync_with_main_save_state()
	load_side_missions()

	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	position = Vector2(35, 248)

	if toggle_cooldown > 0.0:
		toggle_cooldown -= delta

	if toggle_cooldown <= 0.0 and Input.is_key_pressed(KEY_TAB):
		toggle_cooldown = 0.25
		expanded = not expanded

	check_side_missions()

	if toast_timer > 0.0:
		toast_timer -= delta

	queue_redraw()


func sync_with_main_save_state() -> void:
	if FileAccess.file_exists(MAIN_SAVE_PATH):
		return

	delete_side_missions_save()


func delete_side_missions_save() -> void:
	var dir := DirAccess.open("user://")

	if dir == null:
		return

	if dir.file_exists("chatarra_polar_side_missions.json"):
		dir.remove("chatarra_polar_side_missions.json")


func check_side_missions() -> void:
	if should_hide():
		return

	var current_zone: String = get_current_zone()
	var heat: float = get_float_from_main("heat")
	var is_in_base: bool = get_bool_from_main("is_in_base")

	if current_zone == "Zona peligrosa" and not dangerous_zone_visited:
		dangerous_zone_visited = true
		save_side_missions()

	if heat <= 40.0 and not low_heat_reached:
		low_heat_reached = true
		save_side_missions()

	if dangerous_zone_visited and is_in_base and not explorer_completed:
		complete_explorer_mission()

	if get_total_special_parts() >= 3 and not collector_completed:
		complete_collector_mission()

	if low_heat_reached and is_in_base and not survivor_completed:
		complete_survivor_mission()


func complete_explorer_mission() -> void:
	explorer_completed = true
	add_base_scrap(3)
	show_toast("Explorador prudente completa  +3 chatarras")
	save_side_missions()


func complete_collector_mission() -> void:
	collector_completed = true
	add_base_scrap(2)
	show_toast("Recolector eléctrico completa  +2 chatarras")
	save_side_missions()


func complete_survivor_mission() -> void:
	survivor_completed = true
	add_special_part("cable", 1)
	show_toast("Sobreviviente del frío completa  +1 cable")
	save_side_missions()


func add_base_scrap(amount: int) -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	var current_base_scrap: int = int(main_scene.get("base_scrap"))
	main_scene.set("base_scrap", current_base_scrap + amount)

	if main_scene.has_method("check_mission_completed"):
		main_scene.check_mission_completed()

	if main_scene.has_method("save_progress"):
		main_scene.save_progress()

	if main_scene.has_method("update_labels"):
		main_scene.update_labels()

	if main_scene.has_method("play_sound"):
		main_scene.play_sound("upgrade")


func add_special_part(part_name: String, amount: int) -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	var parts_value = main_scene.get("special_parts")

	if typeof(parts_value) != TYPE_DICTIONARY:
		return

	var parts: Dictionary = parts_value

	if not parts.has(part_name):
		parts[part_name] = 0

	parts[part_name] = int(parts[part_name]) + amount
	main_scene.set("special_parts", parts)

	if main_scene.has_method("save_progress"):
		main_scene.save_progress()

	if main_scene.has_method("update_labels"):
		main_scene.update_labels()

	if main_scene.has_method("play_sound"):
		main_scene.play_sound("upgrade")


func show_toast(text: String) -> void:
	toast_message = text
	toast_timer = toast_duration

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		var status_value = main_scene.get("status_label")

		if status_value != null and status_value is Label:
			var status_label: Label = status_value as Label
			status_label.text = text


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

	if expanded:
		draw_expanded_panel()
	else:
		draw_compact_panel()

	if toast_timer > 0.0:
		draw_toast()


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


func draw_compact_panel() -> void:
	draw_panel_background(compact_panel_size)

	var completed_count: int = get_completed_count()
	var active_name: String = get_active_mission_name()
	var active_progress: String = get_active_mission_progress()

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 21),
		"MISIONES  " + str(completed_count) + " / 3",
		HORIZONTAL_ALIGNMENT_LEFT,
		170,
		14,
		Color(1.0, 0.88, 0.48, 0.95)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(214, 21),
		"TAB",
		HORIZONTAL_ALIGNMENT_LEFT,
		40,
		13,
		Color(0.45, 0.90, 1.0, 0.90)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(250, 21),
		"ver",
		HORIZONTAL_ALIGNMENT_LEFT,
		50,
		13,
		Color(0.85, 0.95, 1.0, 0.70)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 48),
		active_name,
		HORIZONTAL_ALIGNMENT_LEFT,
		180,
		14,
		Color(0.88, 0.96, 1.0, 0.90)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(200, 48),
		active_progress,
		HORIZONTAL_ALIGNMENT_LEFT,
		100,
		14,
		get_active_progress_color()
	)


func draw_expanded_panel() -> void:
	draw_panel_background(expanded_panel_size)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 21),
		"MISIONES SECUNDARIAS",
		HORIZONTAL_ALIGNMENT_LEFT,
		200,
		14,
		Color(1.0, 0.88, 0.48, 0.95)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(220, 21),
		"TAB cerrar",
		HORIZONTAL_ALIGNMENT_LEFT,
		90,
		12,
		Color(0.45, 0.90, 1.0, 0.85)
	)

	draw_mission_line(
		Vector2(12, 46),
		"Explorador prudente",
		explorer_completed,
		get_explorer_progress_text()
	)

	draw_mission_line(
		Vector2(12, 68),
		"Recolector eléctrico",
		collector_completed,
		get_collector_progress_text()
	)

	draw_mission_line(
		Vector2(12, 90),
		"Sobreviviente del frío",
		survivor_completed,
		get_survivor_progress_text()
	)


func draw_mission_line(pos: Vector2, mission_name: String, completed: bool, progress_text: String) -> void:
	var icon_text: String = "--"
	var icon_color: Color = Color(0.85, 0.95, 1.0, 0.65)

	if completed:
		icon_text = "OK"
		icon_color = Color(0.45, 1.0, 0.70, 1.0)

	draw_string(
		ThemeDB.fallback_font,
		pos,
		icon_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		28,
		13,
		icon_color
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(36, 0),
		mission_name,
		HORIZONTAL_ALIGNMENT_LEFT,
		165,
		13,
		Color(0.88, 0.96, 1.0, 0.90)
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(200, 0),
		progress_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		95,
		13,
		get_progress_color(completed)
	)


func draw_toast() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	var alpha: float = clamp(toast_timer / 0.25, 0.0, 1.0)

	if toast_timer < 0.35:
		alpha = clamp(toast_timer / 0.35, 0.0, 1.0)

	var toast_size: Vector2 = Vector2(430, 44)
	var toast_pos: Vector2 = Vector2(
		viewport_size.x / 2.0 - toast_size.x / 2.0,
		72.0
	)

	draw_rect(
		Rect2(toast_pos + Vector2(4, 4), toast_size),
		Color(0.0, 0.0, 0.0, 0.28 * alpha)
	)

	draw_rect(
		Rect2(toast_pos, toast_size),
		Color(0.03, 0.04, 0.05, 0.90 * alpha)
	)

	draw_rect(
		Rect2(toast_pos + Vector2(5, 5), toast_size - Vector2(10, 10)),
		Color(0.10, 0.13, 0.15, 0.86 * alpha)
	)

	draw_line(
		toast_pos + Vector2(12, toast_size.y - 8),
		toast_pos + Vector2(toast_size.x - 12, toast_size.y - 8),
		Color(1.0, 0.65, 0.22, alpha),
		2
	)

	draw_circle(
		toast_pos + Vector2(26, 22),
		12,
		Color(0.45, 1.0, 0.70, 0.20 * alpha)
	)

	draw_string(
		ThemeDB.fallback_font,
		toast_pos + Vector2(18, 27),
		"OK",
		HORIZONTAL_ALIGNMENT_LEFT,
		34,
		13,
		Color(0.45, 1.0, 0.70, alpha)
	)

	draw_string(
		ThemeDB.fallback_font,
		toast_pos + Vector2(60, 28),
		toast_message,
		HORIZONTAL_ALIGNMENT_LEFT,
		350,
		14,
		Color(1.0, 0.88, 0.48, alpha)
	)


func get_completed_count() -> int:
	var count: int = 0

	if explorer_completed:
		count += 1

	if collector_completed:
		count += 1

	if survivor_completed:
		count += 1

	return count


func get_active_mission_name() -> String:
	if not explorer_completed:
		return "Explorador prudente"

	if not collector_completed:
		return "Recolector eléctrico"

	if not survivor_completed:
		return "Sobreviviente del frío"

	return "Todas completas"


func get_active_mission_progress() -> String:
	if not explorer_completed:
		return get_explorer_progress_text()

	if not collector_completed:
		return get_collector_progress_text()

	if not survivor_completed:
		return get_survivor_progress_text()

	return "OK"


func get_active_progress_color() -> Color:
	if get_completed_count() >= 3:
		return Color(0.45, 1.0, 0.70, 1.0)

	return Color(1.0, 0.80, 0.45, 0.90)


func get_explorer_progress_text() -> String:
	if explorer_completed:
		return "Completa"

	if dangerous_zone_visited:
		return "Volvé base"

	return "Zona pelig."


func get_collector_progress_text() -> String:
	if collector_completed:
		return "Completa"

	return str(get_total_special_parts()) + " / 3"


func get_survivor_progress_text() -> String:
	if survivor_completed:
		return "Completa"

	if low_heat_reached:
		return "Volvé base"

	return "Calor < 40"


func get_progress_color(completed: bool) -> Color:
	if completed:
		return Color(0.45, 1.0, 0.70, 1.0)

	return Color(1.0, 0.80, 0.45, 0.90)


func get_total_special_parts() -> int:
	return get_special_part_count("battery") + get_special_part_count("cable") + get_special_part_count("rare_gear")


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


func get_bool_from_main(property_name: String) -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get(property_name)

	if value == null:
		return false

	return bool(value)


func get_float_from_main(property_name: String) -> float:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 0.0

	var value = main_scene.get(property_name)

	if value == null:
		return 0.0

	return float(value)


func save_side_missions() -> void:
	var data: Dictionary = {
		"dangerous_zone_visited": dangerous_zone_visited,
		"low_heat_reached": low_heat_reached,
		"explorer_completed": explorer_completed,
		"collector_completed": collector_completed,
		"survivor_completed": survivor_completed
	}

	var file := FileAccess.open(SIDE_SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("No se pudieron guardar las misiones secundarias")
		return

	file.store_string(JSON.stringify(data))
	file.close()


func load_side_missions() -> void:
	if not FileAccess.file_exists(SIDE_SAVE_PATH):
		return

	var file := FileAccess.open(SIDE_SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)

	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var data: Dictionary = parsed

	dangerous_zone_visited = bool(data.get("dangerous_zone_visited", false))
	low_heat_reached = bool(data.get("low_heat_reached", false))
	explorer_completed = bool(data.get("explorer_completed", false))
	collector_completed = bool(data.get("collector_completed", false))
	survivor_completed = bool(data.get("survivor_completed", false))
